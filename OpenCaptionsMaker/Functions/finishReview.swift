//
//  finishReview.swift
//  OpenCaptionsMaker
//
//  Created by Dylan Klein on 24/4/20.
//  Copyright © 2020 Dylan Klein. All rights reserved.
//

import Foundation

func createXML(from captionData: [Caption]) -> XMLDocument {
    
    // Set up document scaffolding
    let root: XMLElement = XMLElement(name: "root")
    let fcpxml: XMLDocument = XMLDocument(rootElement: root)
    
    // Read blank.fcpxml from Resources directory as a string
    var blank: String?
    if let blankURL = Bundle.main.url(forResource: "blank", withExtension: "fcpxml") {
        do {
            blank = try String(contentsOf: blankURL, encoding: .utf8)
        } catch {
            print("Error reading blank.fcpxml.")
        }
    }
    
    // Parse blank.fcpxml as XMLElement
    do {
        try root.addChild(XMLElement(xmlString: blank!))
    } catch {
        print("Error parsing blank XML file.")
    }
    
    print(fcpxml.xmlString)
    
    return fcpxml
}

func saveXML(of rootElement: XMLNode, as xmlPath: String) -> Void {
    
    //  Insert code to save XML document to disk
    
    return
}

func openXML(at xmlPath: String) -> Void {
    
    //  Insert code to open XML file in Final Cut Pro X
    
    return
}
