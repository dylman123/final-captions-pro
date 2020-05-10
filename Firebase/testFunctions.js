var sample = {"results": [
    {
      "alternatives": [
        {
          "transcript":"I'm fucking competitive okay don't get me started like what do you most competitive",
          "confidence":0.8948637843132019,
          "words": [
            {
              "startTime":{
                //"seconds": "1",
                //"nanos": 100000000
              },
              "endTime":{
                //"seconds": "1",
                "nanos":300000000
              },
              "word":"I'm",
              "speakerTag": 1
            },
            {
              "startTime":{
                "seconds": "1",
                "nanos":300000000
              },
              "endTime":{
                "seconds": "1",
                "nanos":600000000
              },
              "word":"fucking",
              "speakerTag": 1
            },
            {
              "startTime":{
                "seconds": "1",
                "nanos":600000000
              },
              "endTime":{
                "seconds":"2",
                "nanos":500000000
              },
              "word":"competitive",
              "speakerTag": 2
            }
          ]
        }
      ]
    }]
  }
  
  // Create an array that formats each word
  function formatWordsOLD(unformattedWords) {
    var formattedWords = []
  
    for (let idx in unformattedWords) {
      
      // Reference a word in the words array
      const word = unformattedWords[idx]
  
      // Convert startTime into a float
      var start = parseInt(word.startTime.seconds) + word.startTime.nanos/1e9
      if (isNaN(start)) { start = 0.0 }
      
      // Convert endTime into a float
      var end = parseInt(word.endTime.seconds) + word.endTime.nanos/1e9
      if (isNaN(end)) { end = 0.0 }
  
      // Calculate duration
      var duration = parseFloat((end - start).toFixed(2))
  
      // Copy speakerTag
      const speaker = word.speakerTag
  
      // Copy word
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
  
  // Create an array which holds captions rather than words
  function generateCaptionsOLD(formattedWords) {  
    var captionsArray = []
    const wordLimit = 7  // Maximum allowed words in a caption
    var consecutive = 0  // A counter to track how many consecutive words have been spoken
    
    // Set up a caption template
    var caption = {}

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
      if (word.speaker == previousWord.speaker) { sameSpeaker = true }
      else { sameSpeaker = false }
      // 2) Check that consecutive counter is under word limit
      if (consecutive < wordLimit - 1) {underWordLimit = true}
      else { underWordLimit = false }
      // 3) Check for pauses in the audio
      if (word.start == previousWord.end) { noPause = true }
      else { noPause = false }
      
      // If all of the above Booleans are true, append word to the existing caption
      if (sameSpeaker && underWordLimit && noPause) {
        consecutive++
        caption.start = caption.start
        caption.end = word.end
        caption.speaker = word.speaker
        caption.text = caption.text + " " + word.text
      }
      // Else create a new caption
      else {
        caption.duration = parseFloat((caption.end - caption.start).toFixed(2))
        captionsArray.push({ ...caption })  // Save most recent caption to array as a clone
        consecutive = 0
        caption.start = word.start
        caption.end = word.end
        caption.speaker = word.speaker
        caption.text = word.text
      }
      // Catch the final caption
      if (idx == formattedWords.length-1) {
        caption.duration = parseFloat((caption.end - caption.start).toFixed(2))
        captionsArray.push({ ...caption })
        captionsArray.shift()  // Remove blank entry in first index
      }
    }
  
    console.log("captionsArray = ", captionsArray)
    return captionsArray
  }
  
  const unformattedWords = sample.results[0].alternatives[0].words
  const formattedWords = formatWords(unformattedWords)
  const captionsArray = generateCaptions(formattedWords)
  
  var results = {}
  results.captionsArray = captionsArray

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
      //if (isNaN(start)) { start = 0.0 }
      
      // Convert endTime into a float
      var end
      if (typeof word.endTime === "undefined") { end = -1 }
      else {
        if (typeof word.endTime.seconds === "undefined") { word.endTime.seconds = "0"}
        if (typeof word.endTime.nanos === "undefined") { word.endTime.nanos = 0 }
        end = parseInt(word.endTime.seconds) + word.endTime.nanos/1e9
      }
      //if (isNaN(end)) { end = 0.0 }
  
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
    const wordLimit = 7  // Maximum allowed words in a caption
    var consecutive = 0  // A counter to track how many consecutive words have been spoken
    
    // Set up a caption template
    var caption = {}

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
        //caption.start = caption.start
        caption.end = word.end
        caption.speaker = word.speaker
        caption.text = caption.text + " " + word.text
      }
      // Else create a new caption
      else {
        caption.duration = parseFloat((caption.end - caption.start).toFixed(2))
        captionsArray.push({ ...caption })  // Save most recent caption to array as a clone
        consecutive = 0
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