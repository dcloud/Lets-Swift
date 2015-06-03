// Playground - noun: a place where people can play

import Foundation

//system("say 'Hi there'")

2^2

//: https://gist.githubusercontent.com/erica/5820cb05acb58820ae37/raw/gistfile1.txt

public struct RandomGenerator<C: CollectionType> : GeneratorType, SequenceType {
    private var backingGenerator : PermutationGenerator<C, [C.Index]>
    public init(_ elements : C) {
        var indices = Array(elements.startIndex..<elements.endIndex)
        for index in 0..<count(indices) {
            var swapIndex = index + Int(arc4random_uniform(UInt32(count(indices) - index)))
            if swapIndex != index {
                swap(&indices[index], &indices[swapIndex])
            }
        }
        backingGenerator = PermutationGenerator(elements: elements, indices: indices)
    }
    public typealias Element = C.Generator.Element
    public typealias Generator = PermutationGenerator<C, [C.Index]>
    public mutating func next() -> Element? {return backingGenerator.next()}
    public func generate() -> PermutationGenerator<C, [C.Index]> {return backingGenerator}
}

let a = "😤😣😨😭😱😷😸😽😾👣🙀👤😓"
let b = "Hello There"
let c = [1, 2, 3, 4, 5, 6, 7, 8, 9]
let d = ["A":"B", "C":"D", "E":"F", "G":"H"]
let e = ["A":1, "B":2, "C":3, "D":4]
var f = Set(1...10)

println(Array(RandomGenerator(a)))
println(Array(RandomGenerator(b)))
println(Array(RandomGenerator(c)))
println(Array(RandomGenerator(d)))
println(Array(RandomGenerator(e)))
println(Array(RandomGenerator(f)))


let sentence = "Daniel Cloud is a really cool guy and he likes pizza."
let options: NSLinguisticTaggerOptions = .OmitWhitespace | .OmitPunctuation | .JoinNames
let schemes = NSLinguisticTagger.availableTagSchemesForLanguage("en")

let tagger = NSLinguisticTagger(tagSchemes: schemes, options: Int(options.rawValue))

tagger.string = sentence

var newString = ""

tagger.enumerateTagsInRange(NSMakeRange(0, (sentence as NSString).length),
                            scheme: NSLinguisticTagSchemeNameTypeOrLexicalClass,
                            options: options) { (tag, tokenRange, sentenceRange, _) in
    var token = (sentence as NSString).substringWithRange(tokenRange)
    if tag == NSLinguisticTagPersonalName {
        newString += "The Flash "
    } else {
        newString += "\(token) "
                                }
//    println("\(token): \(tag)")
}

println(newString)

