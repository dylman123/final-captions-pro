//
//  finishReview.swift
//  OpenCaptionsMaker
//
//  Created by Dylan Klein on 24/4/20.
//  Copyright © 2020 Dylan Klein. All rights reserved.
//

import Foundation

//  finishReview() is the top level function which is called upon user finishing their review of the captions list.
//    - Input: Array of Caption objects
//    - Output: Void (function saves XML file to disk and opens it in Final Cut Pro X)

func finishReview(of captionData: [Caption], andSaveAs xmlPath: String) -> Void {
    
    //  Create XML document
    var rootElement: XMLNode
    rootElement = createXML(from: captionData)
    
    //  Save XML document to disk
    saveXML(of: rootElement, as: xmlPath)
    
    //  Open newly saved XML document in FCP X
    openXML(at: xmlPath)
}

func createXML(from captionData: [Caption]) -> XMLNode {
    var rootElement: XMLNode = XMLNode()
    
    //  Insert code to create a XML document from the captionData
    
    return rootElement
}

func saveXML(of rootElement: XMLNode, as xmlPath: String) -> Void {
    
    //  Insert code to save XML document to disk
    
    return
}

func openXML(at xmlPath: String) -> Void {
    
    //  Insert code to open XML file in Final Cut Pro X
    
    return
}
