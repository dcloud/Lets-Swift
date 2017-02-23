#!/usr/bin/env xcrun swift
//
//  fetchstates.swift
//  
//
//  Created by Daniel Cloud on 11/21/14.
//
//

import Foundation

let rawkey = getenv("SUNLIGHT_KEY")

let apiKey: String? = String.fromCString(rawkey)

if let key = apiKey {
    let config = NSURLSessionConfiguration.ephemeralSessionConfiguration()
    let session = NSURLSession(configuration: config)
    var URL = NSURL(string: "https://api.opencivicdata.org/ocd-division/country:us/")

    let request = NSMutableURLRequest(URL: URL!)
    request.HTTPMethod = "GET"
    request.addValue(key, forHTTPHeaderField: "X-APIKEY")

    let task = session.dataTaskWithRequest(request, completionHandler: { (data : NSData!, response : NSURLResponse!, error : NSError!) -> Void in
        if (error == nil) {
            // Success
            let statusCode = (response as NSHTTPURLResponse).statusCode
            println("URL Session Task Succeeded: HTTP \(statusCode)")

            var jsonError: NSError?
            let jsonObject: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &jsonError)
            if let e = jsonError {
                println("NSJSONSerialization Failed: %@", e.localizedDescription);
            }

            if let JSON: AnyObject = jsonObject {
                let filePath = "States.plist"
                var error: NSError?
                let data = NSPropertyListSerialization.dataWithPropertyList(JSON, format: NSPropertyListFormat.XMLFormat_v1_0, options:0, error: &error)
                //            let fileURL = NSURL(fileURLWithPath: "States.plist", isDirectory: false)
                if let e = error {
                    println("NSPropertyListSerialization Failed: %@", e.localizedDescription);
                }
            }

        }
        else {
            // Failure
            println("URL Session Task Failed: %@", error.localizedDescription);
        }
    })
    println("Fetching: \(URL!.absoluteString!)");
    task.resume()
    sleep(10)
}