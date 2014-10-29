#!/usr/bin/env xcrun swift
//
//  File.swift
//  
//
//  Created by Daniel Cloud on 10/29/14.
//
//

import Foundation

let values: [NSString:AnyObject] = ["ding": "dong", "baz": "bat"]

var dataErr = NSErrorPointer()
let plistData = NSPropertyListSerialization.dataWithPropertyList(values, format: NSPropertyListFormat.XMLFormat_v1_0, options: 0, error: dataErr)

let fileManager = NSFileManager.defaultManager()

let path = "foo.plist"

let result:Bool = fileManager.createFileAtPath(path, contents: plistData, attributes: nil)

let statusString = result ? "success" : "failure"

println("File write: \(statusString)")