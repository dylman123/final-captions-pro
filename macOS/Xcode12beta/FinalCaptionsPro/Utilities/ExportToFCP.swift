//
//  ExportToFCP.swift
//  FinalCaptionsPro
//
//  Created by Dylan Klein on 30/6/20.
//

import Foundation
import AEXML
import SwiftUI

class Exporter {

    var videoFileDimensions: CGSize = .zero
    
    // Finishes the caption review and opens .fcpxml file
    func finishReview(inAppState app: AppState, andSaveFileAs xmlPath: URL) -> Void {
        
        //  Create XML document structure
        let xmlTree = createXML(forVideo: app.videoURL!, withCaptions: app.captions)

        //  Save XML document to disk
        saveXML(of: xmlTree, as: xmlPath)
        
        //  Open newly saved XML document in Final Cut Pro X
        openXML(at: xmlPath)
        
    }

    func createXML(forVideo videoURL: URL, withCaptions captionData: [Caption]) -> AEXMLDocument {
        
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
            
            func getRGBA(_ color: Color) -> String {
                
                let nsColor = NSColor(color).usingColorSpace(.sRGB)
                let R = nsColor!.redComponent
                let G = nsColor!.greenComponent
                let B = nsColor!.blueComponent
                let A = nsColor!.alphaComponent
                
                // To 3 decimal places
                let output = String(format: "%.3f %.3f %.3f %.3f", R, G, B, A)
                return output
            }
            
            func getAlignment(_ alignment: TextAlignment) -> String {
                switch alignment {
                case .leading: return "left"
                case .center: return "center"
                case .trailing: return "right"
                }
            }
            
            func getAttribute(_ attribute: Bool) -> String {
                if attribute { return "1" }
                else { return "0" }
            }
            
            func getPosition(_ position: CGSize) -> String {
                let x = position.width * videoFileDimensions.width
                let y = position.height * videoFileDimensions.height
                print("\(x) \(-y)")
                return "\(x) \(-y)"
            }
            
            // Iterate through the list of captions
            var ts: Int = 0  // Text style id
            for caption in captionData {
                            
                // Make an instance of a title and modify its template according to the caption
                let newTitle = AEXMLElement(name: "title", attributes: [
                    "name": caption.text,
                    "lane": "1",
                    "offset": formatTimestamp(val: caption.start, fd: frameDuration2997!),
                    "ref": "r4",
                    "duration": formatTimestamp(val: caption.duration, fd: frameDuration30!)
                ])
                
                let textStyle = AEXMLElement(name: "text-style", attributes: [
                    "font": caption.style.font,
                    "fontSize": "\(caption.style.size)",
                    "fontFace": "Regular",
                    "fontColor": getRGBA(caption.style.color),
                    "bold": getAttribute(caption.style.bold),
                    "italic": getAttribute(caption.style.italic),
                    "underline": getAttribute(caption.style.underline),
                    //"strikethrough": getAttribute(caption.style.strikethrough),
                    "strokeColor": "0 0 0 1",  // Black text outline
                    "strokeWidth": "3",  // Text outline thickness
                    "alignment": getAlignment(caption.style.alignment)
                ])
                
                ts += 1
                let textStyleDef = AEXMLElement(name: "text-style-def", attributes: ["id": "ts\(ts)"])
                let captionText = AEXMLElement(name: "text-style", value: caption.text, attributes: ["ref": "ts\(ts)"])
                
                let text = AEXMLElement(name: "text")
                
                let position = AEXMLElement(name: "param", attributes: [
                    "name": "Position",
                    "key": "9999/999166631/999166633/1/100/101",
                    "value": getPosition(caption.style.position)
                ])
                
                let flatten = AEXMLElement(name: "param", attributes: [
                    "name": "Flatten",
                    "key": "9999/999166631/999166633/2/351",
                    "value": "1"
                ])
                
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
        let result: String = shell("xmllint --noout --dtdvalid \(dtdURL) \(xmlPath)")
        print("result of DTD check command: \(String(describing: result))")
        if result != "" {  // DTD validation has failed
            print("Error in DTD validation. \(result)")
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

}
