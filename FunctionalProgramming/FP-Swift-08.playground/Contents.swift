//: # Enumerations

import Foundation


enum Encoding {
    case ASCII
    case NEXTSTEP
    case JapaneseEUC
    case UTF8
    case UTF16
}

/*
// Won't work because Swift enums are distinct from Int (and other types)
let myEncoding = Encoding.ASCII + Encoding.UTF8
*/

func toNSStringEncoding(encoding: Encoding) -> NSStringEncoding
{
    switch encoding {
    case Encoding.ASCII:
        return NSASCIIStringEncoding
    case Encoding.NEXTSTEP:
        return NSNEXTSTEPStringEncoding
    case Encoding.JapaneseEUC:
        return NSJapaneseEUCStringEncoding
    case Encoding.UTF8:
        return NSUTF8StringEncoding
    case Encoding.UTF16:
        return NSUTF16StringEncoding
    }
}


toNSStringEncoding(Encoding.UTF8)

func createEncoding(enc: NSStringEncoding) -> Encoding? {
    switch enc {
    case NSASCIIStringEncoding:
        return Encoding.ASCII
    case NSNEXTSTEPStringEncoding:
        return Encoding.NEXTSTEP
    case NSJapaneseEUCStringEncoding:
        return Encoding.JapaneseEUC
    case NSUTF8StringEncoding:
        return Encoding.UTF8
    case NSUTF16StringEncoding:
        return Encoding.UTF16
    default:
        return nil
    }
}

func localizedEncodingName(encoding: Encoding) -> String {
    return String.localizedNameOfStringEncoding(
                             toNSStringEncoding(encoding))
}

localizedEncodingName(Encoding.ASCII)


// Should work but doesn't ?!?
func readFile1(path: String, encoding: Encoding) -> String? {
    var possibleError: NSError? = nil
    let possibleString = NSString(contentsOfFile: path,
                            encoding: toNSStringEncoding(encoding),
                            error: &possibleError)
    return possibleString as String?
}



enum ReadFileResult {
    case Success(String)
    case Failure(NSError)
}


let exampleSuccess: ReadFileResult = ReadFileResult.Success("File contents go here!")

func readFile(path: String, encoding: Encoding) -> ReadFileResult {
    var possibleError: NSError? = nil
    let stringEncoding = toNSStringEncoding(encoding)
    let possibleString: String? = NSString(contentsOfFile: path,
                                            encoding: stringEncoding,
                                            error: &possibleError) as String?

    if let string = possibleString {
        return ReadFileResult.Success(string)
    } else if let error = possibleError {
        return ReadFileResult.Failure(error)
    } else {
        assert(false, "The impossible error occurred")
    }
}


switch readFile("/Users/dcloud/code/objc/Lets-Swift/fetchstates.swift", Encoding.UTF8) {
    case let ReadFileResult.Success(contents):
        println("File successfully opened...")
    case let ReadFileResult.Failure(error):
        println("Failed to open file. Error code: \(error.code)")
}

class Box<T> {
    let unbox: T
    init(_ value: T) { self.unbox = value }
}

enum Result<T> {
    case Success(Box<T>)
    case Failure(NSError)
}

func readFileImproved(path: String, encoding: Encoding) -> Result<String> {
    var possibleError: NSError? = nil
    let stringEncoding = toNSStringEncoding(encoding)
    let possibleString: String? = NSString(contentsOfFile: path,
        encoding: stringEncoding,
        error: &possibleError) as String?

    if let string = possibleString {
        return Result.Success(Box(string))
    } else if let error = possibleError {
        return Result.Failure(error)
    } else {
        assert(false, "The impossible error occurred")
    }
}

switch readFileImproved("Hello.md", Encoding.UTF8) {
    case let Result.Success(box):
        println("File Sucessfully opened...")
    case let Result.Failure(error):
        println("Failed to open file. Error code: \(error.code)")
}


/*: 

## The algrebra of data types

Wat?

*/

enum Add<T, U> {
    case InLeft(Box<T>)
    case InRight(Box<U>)
}

enum Zero {}

struct Times<T, U> {
    let fst:T
    let snd:U
}

typealias One = ()

