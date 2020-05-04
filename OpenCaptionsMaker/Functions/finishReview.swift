//
//  finishReview.swift
//  OpenCaptionsMaker
//
//  Created by Dylan Klein on 24/4/20.
//  Copyright © 2020 Dylan Klein. All rights reserved.
//

import Foundation
import AEXML

func createXML(from captionData: [Caption]) -> AEXMLDocument {
    
    // Set up document scaffolding
    // Parse template.fcpxml as AEXMLDocument
    guard
        let templateURL = Bundle.main.url(forResource: "template", withExtension: "fcpxml"),
        let templateData = try? Data(contentsOf: templateURL)
    else { return AEXMLDocument() }
    
    do {
        let root = try AEXMLDocument(xml: templateData)
        
        var ts: Int = 0  // Text style id
        
        // Iterate through the list of captions
        for caption in captionData {
            
            // Make an instance of a title and modify its template according to the caption
            let newTitle = AEXMLElement(name: "title", attributes: [
                "name": caption.text,
                "lane": "1",
                "offset": String(caption.start) + "s",
                "ref": "r4",
                "duration": String(caption.duration) + "s"
            ])
            
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
            let captionText = AEXMLElement(name: "text-style", value: caption.text, attributes: ["ref": "ts\(ts)"])  // FIXME: apostrophes are not handled well in caption.text field
            
            let text = AEXMLElement(name: "text")
            
            let position = AEXMLElement(name: "param", attributes: [
                "name": "Position",
                "key": "9999/999166631/999166633/1/100/101",
                "value": "200 -300"
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
            root["fcpxml"]["library"]["event"]["project"]["sequence"]["spine"]["asset-clip"].addChild(newTitle)  // FIXME: Need to move <audio-channel-source> to the end of the <asset-clip>
        }
        
        return root
        
    } catch {
        print("\(error.localizedDescription)")
        return AEXMLDocument()
    }
}

func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
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
    print(result)
    if result != nil {  // DTD validation has failed
         print("Error in DTD validation. \(result)")
        // TODO: delete the .fcpxml file
    }
    else {  // DTD validation has passed
        print("Successfully passed DTD validation.")
        return
    }
}

func openXML(at xmlPath: URL) -> Void {
    
    // Open the .fcpxml in its native application (Final Cut Pro X)
    let _ = shell("open \(xmlPath)")
    
    return
}
