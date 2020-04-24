//
//  finishReview.swift
//  OpenCaptionsMaker
//
//  Created by Dylan Klein on 24/4/20.
//  Copyright © 2020 Dylan Klein. All rights reserved.
//

//  Top level function which is called upon user finishing their review of the captions list
func finishReview(of captionData: CaptionData) {
    
    //  Create XML document
    var rootElement: XMLObject
    rootElement = createXML(from: captionData)
    
    //  Save XML document to disk
    saveXML(of: rootElement, at: xmlPath)
    
    //  Open newly saved XML document in FCP X
    openXML(at: xmlPath)
}
