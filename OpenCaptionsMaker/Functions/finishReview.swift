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
            
            for child in titleRoot.children {
                
                // Edit attributes in the <title> tag
                if child.name == "title" {
                    child.attributes = ["name": "Hello World", "lane": "1", "offset": "1001", "ref": "r4", "duration": "1.2"]
                }
                for grandchild in child.children {
                    
                    // Edit positional coordinate values
                    if grandchild.attributes["name"] == "Position" {
                        grandchild.attributes["value"] = "1.0 -2.0"
                    }
                    
                    // Edit caption values in the <text><text-style> tag
                    if grandchild.name == "text" {
                        for greatgrandchild in grandchild.children {
                            if greatgrandchild.name == "text-style" {
                                greatgrandchild.attributes["ref"] = "ts1"
                                greatgrandchild.value = "Hello World"
                            }
                        }
                    }
                    
                    // Edit font values in the <text-style-def><text-style> tag
                    if grandchild.name == "text-style-def" {
                        grandchild.attributes["id"] = "ts1"
                        for greatgrandchild in grandchild.children {
                            greatgrandchild.attributes = [
                                "font": "Futura",
                                "fontSize": "60",
                                "fontFace": "Condensed ExtraBold",
                                "fontColor": "1 1 1 1",
                                "bold": "1",
                                "strokeColor": "0 0 0 1",
                                "strokeWidth": "3",
                                "alignment": "center"
                            ]
                        }
                    }
                }
            }
            
        root["fcpxml"]["library"]["event"]["project"]["sequence"]["spine"]["asset-clip"].addChild(titleRoot)

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
