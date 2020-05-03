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
    // Parse blank.fcpxml as AEXMLDocument
    guard
        let blankURL = Bundle.main.url(forResource: "blank", withExtension: "fcpxml"),
        let blankData = try? Data(contentsOf: blankURL)
    else { return AEXMLDocument() }
    
    do {
        let root = try AEXMLDocument(xml: blankData)
        
        // Parse titleTemplate.fcpxml as AEXMLDocument
        guard
            let titleURL = Bundle.main.url(forResource: "titleTemplate", withExtension: "fcpxml"),
            let titleData = try? Data(contentsOf: titleURL)
        else { return AEXMLDocument() }
        
        do {
            let titleRoot = try AEXMLDocument(xml: titleData)
            
            // Iterate through the list of captions
            for caption in captionData {

                // Make an instance of a title and modify its template
                //let newTitle = titleRoot.copy() as! AEXMLDocument
                let newTitle = try AEXMLDocument(xml: titleRoot.xml)
                        
                // Edit attributes in the <title> tag
                newTitle["title"].attributes = [
                    "name": caption.text,
                    "lane": "1",
                    "offset": String(caption.start) + "s",
                    "ref": "r4",
                    "duration": String(caption.duration) + "s"
                ]
                    
                // Edit positional coordinate values
                for param in newTitle["title"].children {
                    if param.attributes["name"] == "Position" {
                        param.attributes["value"] = "-355.0 -268.0"
                    }
                }
                    
                // Edit caption values in the <text><text-style> tag
                newTitle["title"]["text"]["text-style"].attributes["ref"] = "ts1"
                newTitle["title"]["text"]["text-style"].value = caption.text
                    
                // Edit font values in the <text-style-def><text-style> tag
                newTitle["title"]["text-style-def"].attributes["id"] = "ts1"
                newTitle["title"]["text-style-def"]["text-style"].attributes = [
                    "font": "Futura",
                    "fontSize": "60",
                    "fontFace": "Condensed ExtraBold",
                    "fontColor": "1 1 1 1",
                    "bold": "1",
                    "strokeColor": "0 0 0 1",
                    "strokeWidth": "3",
                    "alignment": "center" ]
                
                root["fcpxml"]["library"]["event"]["project"]["sequence"]["spine"]["asset-clip"].addChild(newTitle)
                
            }

        } catch {
            print("\(error.localizedDescription)")
        }
        
        print(root.xml)
        
    } catch {
        print("\(error.localizedDescription)")
    }
    
    return AEXMLDocument()
}

func saveXML(of rootElement: XMLNode, as xmlPath: String) -> Void {
    
    //  Insert code to save XML document to disk
    
    return
}

func openXML(at xmlPath: String) -> Void {
    
    //  Insert code to open XML file in Final Cut Pro X
    
    return
}
