//
//  finishReview.swift
//  OpenCaptionsMaker
//
//  Created by Dylan Klein on 24/4/20.
//  Copyright © 2020 Dylan Klein. All rights reserved.
//
import Foundation
import AEXML

// Finishes the caption review and opens .fcpxml file
func finishReview(inAppState app: AppState, andSaveFileAs xmlPath: URL) -> Void {
    
    // Set the path of the file to be saved - TODO: Change this to a user selected URL
    let testPath = getDocumentsDirectory().appendingPathComponent("test.fcpxml")
           
    //  Create XML document structure
    let xmlTree = createXML(forVideo: app.videoURL, withCaptions: app.userData)

    //  Save XML document to disk
    saveXML(of: xmlTree, as: testPath)
    
    //  Open newly saved XML document in Final Cut Pro X
    openXML(at: testPath)
    
}

func createXML(forVideo videoURL: URL, withCaptions captionData: [StyledCaption]) -> AEXMLDocument {
    
    // Set up document scaffolding, parse template.fcpxml as AEXMLDocument
    guard
        let templateURL = Bundle.main.url(forResource: "template", withExtension: "fcpxml"),
        let templateData = try? Data(contentsOf: templateURL)
    else { return AEXMLDocument() }
    
    do {
        // Define important AEXMLElements
        let root = try AEXMLDocument(xml: templateData)
        let asset: AEXMLElement = root["fcpxml"]["resources"]["asset"]
        let assetClip: AEXMLElement = root["fcpxml"]["library"]["event"]["project"]["sequence"]["spine"]["asset-clip"]
        
        // Write video filename into the appropriate fields (in order to pass DTD validation)
        asset.attributes["src"] = String(describing: videoURL)
        assetClip.attributes["name"] = videoURL.lastPathComponent
        
        // Returns the frame duration as an array of Ints
        func getFrameDuration(_ formatName: String) -> [Int]? {
            for child in root["fcpxml"]["resources"].children {
                if (child.name == "format") && (child.attributes["name"] == formatName) {
                    let fd: String = child.attributes["frameDuration"]!
                    var fdStrings: [Substring] = fd.split(separator: "/")
                    fdStrings[1] = fdStrings[1].split(separator: "s")[0]
                    var fdArray: [Int] = []
                    fdArray.append(Int(String(fdStrings[0]))!)
                    fdArray.append(Int(String(fdStrings[1]))!)
                    return fdArray
                }
            }
            return nil
        }
        
        // Get frame duration values (note: they must exist in template.fcpxml in order to use them!)
        var frameDuration30: [Int]? {
            return getFrameDuration("FFVideoFormat1080p30")
        }
        var frameDuration2997: [Int]? {
            return getFrameDuration("FFVideoFormat1080p2997")
        }
        /* DOES NOT CURRENTLY EXIST IN template.fcpxml
        var frameDuration5994: [Int]? {
            return getFrameDuration("FFVideoFormat1080p5994")
        }*/
        
        /* Converts a timestamp value (float in secs) into a string of format:
        {numerator}/{denomenator}s" to satisfy FCPX timing attribute requirements.
        This silences warnings that timing values do not lie on edit frame boundaries,
        and makes sure that any shorter clips are not discarded by FCPX. */
        func formatTimestamp(val time: Float, fd fdArray: [Int]) -> String {
            // Extract frame duration values
            let num: Int = fdArray[0]
            let den: Int = fdArray[1]
            let fd: Float = Float(num) / Float(den)
            
            // Do calculation on time value
            let quotient: Float = time / fd
            let rounded: Int = Int(roundf(quotient))
            let timeNum: Int64 =  Int64(rounded * num)
            
            // Check that the time numerator is a whole multiple of the fd numerator
            let remainder = Float(timeNum).remainder(dividingBy: Float(num))
            if  remainder != 0 {
                print("Remainder is \(remainder)")
                print("Warning, \(timeNum) is not a whole multple of \(num)!")
            }
            
            let formattedTimestamp = "\(timeNum)/\(den)s"
            return formattedTimestamp
        }
        
        // Iterate through the list of captions
        var ts: Int = 0  // Text style id
        for data in captionData {
                        
            // Make an instance of a title and modify its template according to the caption
            let newTitle = AEXMLElement(name: "title", attributes: [
                "name": data.caption.text,
                "lane": "1",
                "offset": formatTimestamp(val: data.caption.startTime, fd: frameDuration2997!),
                "ref": "r4",
                "duration": formatTimestamp(val: data.caption.duration, fd: frameDuration30!)
            ])
            
            // TODO: Integrate font config
            let textStyle = AEXMLElement(name: "text-style", attributes: [
                "font": "Futura",
                "fontSize": "60",
                "fontFace": "Condensed ExtraBold",
                "fontColor": "1 1 1 1",
                "bold": "1",
                "strokeColor": "0 0 0 1",
                "strokeWidth": "3",
                "alignment": "center"
            ])
            
            ts += 1
            let textStyleDef = AEXMLElement(name: "text-style-def", attributes: ["id": "ts\(ts)"])
            let captionText = AEXMLElement(name: "text-style", value: data.caption.text, attributes: ["ref": "ts\(ts)"])
            
            let text = AEXMLElement(name: "text")
            
            let position = AEXMLElement(name: "param", attributes: [
                "name": "Position",
                "key": "9999/999166631/999166633/1/100/101",
                "value": "\(data.style.xPos) \(data.style.yPos)"
            ])
            
            let flatten = AEXMLElement(name: "param", attributes: [
                "name": "Flatten",
                "key": "9999/999166631/999166633/2/351",
                "value": "1"
            ])
            
            // TODO: Integrate alignment config
            let alignment = AEXMLElement(name: "param", attributes: [
                "name": "Alignment",
                "key": "9999/999166631/999166633/2/354/999169573/401",
                "value": "1 (Center)"
            ])
            
            // Organise elements into the appropriate hierarchy
            newTitle.addChild(position)
            newTitle.addChild(flatten)
            newTitle.addChild(alignment)
            newTitle.addChild(text).addChild(captionText)
            newTitle.addChild(textStyleDef).addChild(textStyle)
            
            // Add the title into the root element
            assetClip.addChild(newTitle)
        }
        
        // Reorder elements of the <asset-clip> (in order to pass DTD validation)
        let audioChannelSource: AEXMLElement = assetClip["audio-channel-source"]
        assetClip.firstDescendant(where: { element in
            element.name == "audio-channel-source"})?.removeFromParent()
        assetClip.addChild(audioChannelSource)
        
        return root
        
    } catch {
        print("\(error.localizedDescription)")
        return AEXMLDocument()
    }
}

func saveXML(of rootElement: AEXMLDocument, as xmlPath: URL) -> Void {

    // Save the .fcpxml file to disk
    do {
        try rootElement.xml.write(to: xmlPath, atomically: true, encoding: String.Encoding.utf8)
        print("Successfully saved .fcpxml file as: \(xmlPath)")
    } catch {
        // failed to write file – bad permissions, bad filename, missing permissions, or more likely it can't be converted to the encoding
        print("Error saving .fcpxml file to disk: \(error.localizedDescription)")
    }
    
    // Validate the saved .fcpxml file against its DTD schema
    guard let dtdURL = Bundle.main.url(forResource: "fcpxml-v1.8", withExtension: "dtd") else {
        return
    }
    let result: String? = shell("xmllint --noout --dtdvalid \(dtdURL) \(xmlPath)")
    if result != "" {  // DTD validation has failed
        print("Error in DTD validation. \(result!)")
        // Open the .fcpxml file in a text editor for debugging purposes
        let _ = shell("open -a 'TextEdit' \(xmlPath)")
        return
    }
    else {  // DTD validation has passed
        print("Successfully passed DTD validation.")
        return
    }
}

func openXML(at xmlPath: URL) -> Void {
    
    // Open the .fcpxml in its native application (Final Cut Pro X)
    let _ = shell("open -a 'Final Cut Pro' \(xmlPath)")
    
    return
}
