//
//  Networking.swift
//  OpenCaptionsMaker
//
//  Created by Dylan Klein on 1/5/20.
//  Copyright © 2020 Dylan Klein. All rights reserved.
//

import Foundation

enum LongPollError:ErrorType{
    case IncorrectlyFormattedUrl
    case HttpError
}

public class LongPollingRequest: NSObject {
    var GlobalUserInitiatedQueue: dispatch_queue_t {
        return dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.rawValue), 0)
    }

    var GlobalBackgroundQueue: dispatch_queue_t {
        return dispatch_get_global_queue(Int(QOS_CLASS_BACKGROUND.rawValue), 0)
    }

    var longPollDelegate: LongPollingDelegate
    var request: NSURLRequest?

    init(delegate:LongPollingDelegate){
        longPollDelegate = delegate
    }

    public func poll(endpointUrl:String) throws -> Void{
        let url = NSURL(string: endpointUrl)
        if(url == nil){
            throw LongPollError.IncorrectlyFormattedUrl
        }
        request = NSURLRequest(url: url! as URL)
        poll()
    }

    private func poll(){
        dispatch_async(GlobalBackgroundQueue) {
            self.longPoll()
        }
    }

    private func longPoll() -> Void{
        autoreleasepool{
            do{
                let urlSession = URLSession.shared
                let dataTask = urlSession.dataTaskWithRequest(self.request!, completionHandler: {
                    (data: NSData?, response: URLResponse?, error: NSError?) -> Void in
                    if( error == nil ) {
                        self.longPollDelegate.dataReceived(data)
                        self.poll()
                    } else {
                        self.longPollDelegate.errorReceived()
                    }
                })
                dataTask.resume()
            }
        }
    }
}
