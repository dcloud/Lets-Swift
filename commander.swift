#!/usr/bin/env xcrun swift
//
//  commander.swift
//  
//
//  Created by Daniel Cloud on 11/19/14.
//
//

import Foundation

let rawkey = getenv("SUNLIGHT_KEY")

let apiKey: String? = String.fromCString(rawkey)

let valid_options = ["--apikey", "--file"]

var arg_list = Process.arguments[1..<Process.arguments.count]

class Argument {
    let rawValue: String
    var booleanValue: Bool {
        get {
            return self.rawValue.lowercaseString == "true" ? true : false
        }
    }
    var integerValue: Int? {
        get {
            return self.rawValue.toInt()
        }
    }
    var stringValue: String {
        get {
            return self.rawValue
        }
    }

    init(_ rawArg: String) {
        self.rawValue = rawArg
    }
}

class Option<T> {
    let name: String
    let defaultValue: T
    let numArguments: Int
    let aliases: [String]

    init(_ name: String, defaultValue: T, numArguments: Int = 1, aliases: String...) {
        self.name = name
        self.defaultValue = defaultValue
        self.numArguments = numArguments
        self.aliases = aliases
    }
}

class Parser {
    var option_types = ["-", "--"]
    var options: [Option<Any>] = []
    var arguments: [Argument] = []

    init(arguments: [Argument]?, options: [Option<Any>]?) {
        if let arguments = arguments {
            self.arguments = arguments
        }
        if let options = options {
            self.options = options
        }
    }

    public func parseArguments(arguments: [String]) {
        for (n, arg) in enumerate(rawArguments) {
            if arg.hasPrefix("-") {
                println("Option: \(arg)")
            } else {
                println("Argument: \(arg)")
            }
        }
    }
}