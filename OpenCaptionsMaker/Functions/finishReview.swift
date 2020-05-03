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
            
            // Make an instance of a title and modify its template
            //let newTitle = AEXMLElement( title.xml.copy()
            
            // Edit attributes in the <title> tag
            titleRoot["title"].attributes = [
                "name": "Hello World",
                "lane": "1",
                "offset": "1001s",
                "ref": "r4",
                "duration": "1.2"
            ]
                
            // Edit positional coordinate values
            for param in titleRoot["title"].children {
                if param.attributes["name"] == "Position" {
                    param.attributes["value"] = "1.0 -2.0"
                }
            }
                
            // Edit caption values in the <text><text-style> tag
            titleRoot["title"]["text"]["text-style"].attributes["ref"] = "ts1"
            titleRoot["title"]["text"]["text-style"].value = "Hello 2 World"
                
            // Edit font values in the <text-style-def><text-style> tag
            titleRoot["title"]["text-style-def"].attributes["id"] = "ts1"
            titleRoot["title"]["text-style-def"]["text-style"].attributes = [
                "font": "Futura",
                "fontSize": "60",
                "fontFace": "Condensed ExtraBold",
                "fontColor": "1 1 1 1",
                "bold": "1",
                "strokeColor": "0 0 0 1",
                "strokeWidth": "3",
                "alignment": "center" ]
            
            print(titleRoot.xml)
            
        root["fcpxml"]["library"]["event"]["project"]["sequence"]["spine"]["asset-clip"].addChild(titleRoot)

        } catch {
            print("\(error.localizedDescription)")
        }
        
        //print(root.xml)
        
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
