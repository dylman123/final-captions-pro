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
    
//    // Set up document scaffolding
//    let root: XMLElement = XMLElement(name: "root")
//    //let fcpxml: XMLDocument = XMLDocument(rootElement: root)
//    let fcpxml: XMLDocument = XMLDocument(rootElement: root)
//
//    // Read blank.fcpxml from Resources directory as a string
//    var blank: String?
//    if let blankURL = Bundle.main.url(forResource: "blank", withExtension: "fcpxml") {
//        do {
//            blank = try String(contentsOf: blankURL, encoding: .utf8)
//        } catch {
//            print("Error reading blank.fcpxml.")
//        }
//    }
//
//    // Parse blank.fcpxml as XMLElement
//    do {
//        try root.addChild(XMLElement(xmlString: blank!))
//    } catch {
//        print("Error parsing blank.fcpxml.")
//    }
    
    /*// Read titleTemplate.fcpxml from Resources directory as a string
    var template: String?
    if let templateURL = Bundle.main.url(forResource: "titleTemplate", withExtension: "fcpxml") {
        do {
            template = try String(contentsOf: templateURL, encoding: .utf8)
        } catch {
            print("Error reading titleTemplate.fcpxml")
        }
    }
    
    // Parse titleTemplate.fcpxml as XMLElement
    var title: XMLElement?
    do {
        title = try XMLElement(xmlString: template!)
    } catch {
        print("Error parsing titleTemplate.fcpxml.")
    }
    
    // Make an instance of a title and modify its template
    guard let newTitle = title?.copy() else {
        return fcpxml
    }
    print("newTitle: \(newTitle)")
    
    //let testAttr = ["key1": "val1", "key2": "val2", "key3": "val3"]
    //let testChild = fcpxml.addChild(name: "Child1", value: "100", attributes: testAttr)
    
    print(fcpxml.xmlString)*/
    
    // Parse blank.fcpxml as AEXMLDocument
    guard
        let blankURL = Bundle.main.url(forResource: "blank", withExtension: "fcpxml"),
        let blankData = try? Data(contentsOf: blankURL)
    else { return AEXMLDocument() }
    
    do {
        let blankRoot = try AEXMLDocument(xml: blankData)
        
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
        let testElement = try AEXMLElement(name: "test", value: "dylan")
        blankRoot.addChild(testElement)
        print(blankRoot.xml)
        
        } catch {
            print("\(error.localizedDescription)")
        }
    
        //try root.addChild(XMLElement(xmlString: titleRoot.xml))
        
        //print(fcpxml)
        
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
