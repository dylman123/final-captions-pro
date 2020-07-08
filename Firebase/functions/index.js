/**
 * Copyright 2016 Google Inc. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * 
 * Written by Dylan Klein for the app OpenCaptionsMaker
 * Last modified 30 April 2020
 * 
 */
'use strict';

// [START import]
const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp()
const spawn = require('child-process-promise').spawn;
const path = require('path');
const os = require('os');
const fs = require('fs');
// [END import]

// [START audioToCaptions]
/**
 * When an Audio is uploaded in the Storage bucket, we generate a transcript automatically using
 * Google's longrunningrecognize() function. We then organise the transcribed text into capitions with
 * 2 more functions: formatWords() and generateCaptions().
 */
// [START audioToCaptionsTrigger]
exports.audioToCaptions = functions
    .region('asia-east2')
    .storage
    .object()
    .onFinalize(async (object) => {
// [END audioToCaptionsTrigger]
  // [START eventAttributes]
  const fileBucket = object.bucket; // The Storage bucket that contains the file.
  const filePath = object.name; // File path in the bucket.
  const gcsUri = "gs://" + fileBucket + "/" + filePath; // GCS URI of the file in the bucket.
  const contentType = object.contentType; // File content type.
  const metageneration = object.metageneration; // Number of times metadata has been generated. New objects have a value of 1.
  // [END eventAttributes]

  // [START stopConditions]
  // Exit if this is triggered on a file that is not an Audio.
  if (!contentType.startsWith('audio/wav')) {
    return console.log('This is not an audio file.');
  }
  // Get the file name.
    const fileName = path.basename(filePath, '.wav') + '.json';
  // [END stopConditions]

  // Download file from bucket.
  const bucket = admin.storage().bucket(fileBucket);
  const tempFilePath = path.join(os.tmpdir(), fileName);
  const metadata = {
        contentType: 'application/json',
  };

// Imports the Google Cloud client library
    const speech = require('@google-cloud/speech').v1p1beta1;

    // Creates a client
    const client = new speech.SpeechClient();

    const config = {
        enableWordTimeOffsets: true,
        enableSpeakerDiarization: true,
        diarizationSpeakerCount: 2,  // may want to make this a user input with default = 2
        //encoding: none, // Don't need explicit encoding for WAV format
        //sampleRateHertz: 44100,  // Don't need explicit sampleRateHertz for WAV format
        languageCode: 'en-US', // 'BCP-47 language code, e.g. en-US'
        //useEnhanced: true,
        model: 'video',
    };

    const audio = {
        uri: gcsUri,
    };

    const request = {
        config: config,
        audio: audio,
    };

    // Detects speech in the audio file. This creates a recognition job that you
    // can wait for now, or get its result later.
    const [operation] = await client.longRunningRecognize(request);
    // Get a Promise representation of the final result of the job
    const [response] = await operation.promise();
    const transcription = response.results
        .map(result => result.alternatives[0].transcript)
        .join('\n');
    console.log(`Transcription: ${transcription}`);

    Object.entries(response).forEach((key) => {
        console.log(key);
    })

    // Save transcription data to JSON format
    const json = response.toJSON();

    // Reference the relevant array from the JSON object
    const wordsArray = json.results.pop().alternatives[0].words

    // Modify array into a desirable format 
    const formattedWords = formatWords(wordsArray)

    // Generate captions from the formattedWords array
    const captionsArray = generateCaptions(formattedWords)

    // Package up into JSON result
    var result = {}
    result.captions = captionsArray

    // Write result to file
    var data = JSON.stringify(result);
    const fs = require('fs');
    fs.writeFile(tempFilePath, data, 'utf8', (err) => {
        if (err) {
            console.error(err);
            return;
        }
        console.log("File has been created");
    });

    // Write result to Firebase DB


    // Uploading the captions
    await bucket.upload(tempFilePath, {
        destination: "temp-captions/" + fileName,
        metadata: metadata,
    });

  // Once the captions have been uploaded, delete the local file to free up disk space
  return fs.unlinkSync(tempFilePath);
});
// [END audioToCaptions]

// [START formatWords]
  // Create an array that formats each word
  function formatWords(unformattedWords) {
    var formattedWords = []
  
    for (let idx in unformattedWords) {
      
      // Reference a word in the words array
      const word = unformattedWords[idx]
  
      // Convert startTime into a float
      var start
      if (typeof word.startTime === "undefined") { start = 0.0 }
      else {
        if (typeof word.startTime.seconds === "undefined") { word.startTime.seconds = "0"}
        if (typeof word.startTime.nanos === "undefined") { word.startTime.nanos = 0 }
        start = parseInt(word.startTime.seconds) + word.startTime.nanos/1e9  
        }
      
      // Convert endTime into a float
      var end
      if (typeof word.endTime === "undefined") { end = -1 }
      else {
        if (typeof word.endTime.seconds === "undefined") { word.endTime.seconds = "0"}
        if (typeof word.endTime.nanos === "undefined") { word.endTime.nanos = 0 }
        end = parseInt(word.endTime.seconds) + word.endTime.nanos/1e9
      }
  
      // Calculate duration
      var duration = parseFloat((end - start).toFixed(2))
  
      // Copy speakerTag
      if (typeof word.speakerTag === "undefined") { word.speakerTag = 0 }
      const speaker = word.speakerTag
  
      // Copy word
      if (typeof word.word === "undefined") { word.word = "" }
      const text = word.word
  
      // Populate formattedWords array
      var formattedWord = {}
      formattedWord.start = start
      formattedWord.end = end
      formattedWord.duration = duration
      formattedWord.speaker = speaker
      formattedWord.text = text
      formattedWords[idx] = formattedWord
    }
  
    console.log("formattedWords = ", formattedWords)
    return formattedWords
  }
// [END formatWords]
  
// [START generateCaptions]
  // Create an array which holds captions rather than words
  function generateCaptions(formattedWords) {  
    var captionsArray = []
    const wordLimit = 5  // Maximum allowed words in a caption
    var consecutive = 0  // A counter to track how many consecutive words have been spoken
    
    // Set up a caption template
    var caption = {}
    var id = 0

    // Iterate through all the words
    for (let idx in formattedWords) {
      
      // Reference a word in the words array
      const word = formattedWords[idx]
  
      // Reference the previous word
      var previousWord
      if (idx > 0) {
        previousWord = formattedWords[idx - 1]
      } else {
        previousWord = {
          "start": 0.0,
          "end": 0.0,
          "duration": 0.0,
          "speaker": 0,
          "text": ""
        }
      }
  
      // Declare conditional Booleans for logic
      var sameSpeaker  // Is this words's speaker equal to the previous word's speaker?
      var underWordLimit  // Is the consecutive counter under the word limit?
      var noPause  // Is there a pause between this word and the previous word?
        
      // Evaluate three conditionals for grouping words into captions
      // 1) Compare speaker tag with previous speaker tag
      if (word.speaker === previousWord.speaker) { sameSpeaker = true }
      else { sameSpeaker = false }
      // 2) Check that consecutive counter is under word limit
      if (consecutive < wordLimit - 1) {underWordLimit = true}
      else { underWordLimit = false }
      // 3) Check for pauses in the audio
      if (word.start === previousWord.end) { noPause = true }
      else { noPause = false }
      
      // If all of the above Booleans are true, append word to the existing caption
      if (sameSpeaker && underWordLimit && noPause) {
        consecutive++
        caption.end = word.end
        caption.speaker = word.speaker
        caption.text = caption.text + " " + word.text
      }
      // Else create a new caption
      else {
        caption.duration = parseFloat((caption.end - caption.start).toFixed(2))
        captionsArray.push({ ...caption })  // Save most recent caption to array as a clone
        consecutive = 0
        caption.id = id++
        caption.start = word.start
        caption.end = word.end
        caption.speaker = word.speaker
        caption.text = word.text
      }
      // Catch the final caption
      if (parseInt(idx) === formattedWords.length-1) {
        caption.duration = parseFloat((caption.end - caption.start).toFixed(2))
        captionsArray.push({ ...caption })
        captionsArray.shift()  // Remove blank entry in first index
      }
    }
  
    console.log("captionsArray = ", captionsArray)
    return captionsArray
  }
// [END generateCaptions]
