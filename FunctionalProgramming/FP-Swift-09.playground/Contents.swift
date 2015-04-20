//: # Purely Functional Data Structures

import UIKit


/*: 
## Using Arrays to represent sets

This is not the best way to go about it.

    func emptySet<T>() -> Array<T> {
        return []
    }

    func isEmptySet<T>(set: [T]) -> Bool {
        return set.isEmpty
    }

    func setContains<T: Equatable>(x: T, set: [T]) -> Bool {
        return contains(set, x)
    }

    func setInsert<T: Equatable>(x: T, set: [T]) -> Bool {
        return setContains(x, set) ? set : [x] + set
    }
*/


//: ## Binary search tree

class Box<T> {
    let unbox: T
    init(_ value: T) { self.unbox = value }
}

enum Tree<T> {
    case Leaf
    case Node(Box<Tree<T>>, Box<T>, Box<Tree<T>>)
}

let leaf: Tree<Int> = Tree.Leaf

let five: Tree<Int> = Tree.Node(Box(leaf), Box(5), Box(leaf))

func single<T>(x: T) -> Tree<T> {
    return Tree.Node(Box(Tree.Leaf), Box(x), Box(Tree.Leaf))
}

func count<T>(tree: Tree<T>) -> Int {
    switch tree {
    case let Tree.Leaf:
        return 0
    case let Tree.Node(left, x, right):
        return 1 + count(left.unbox) + count(right.unbox)
    }
}

func elements<T>(tree: Tree<T>) -> [T] {
    switch tree {
    case let Tree.Leaf:
        return []
    case let Tree.Node(left, x, right):
        return elements(left.unbox) + [x.unbox] + elements(right.unbox)
    }
}

func emptySet<T>() -> Tree<T> {
    return Tree.Leaf
}

func isEmptySet<T>(tree: Tree<T>) -> Bool {
    switch tree {
    case let Tree.Leaf:
        return true
    case let Tree.Node(_, _, _):
        return false
    }
}
/*:

We could define a checker as follows, provided we also created the all function:

    func isBST<T: Comparable>(tree: Tree<T>) -> Bool {
        switch tree {
        case let Tree.Leaf:
            return true
        case let Tree.Node(left, x, right):
            let leftElements = elements(left.unbox)
            let rightElements = elements(right.unbox)
            return all(leftElements) { y in y < x.unbox }
                && all(rightElements) { y in y > x.unbox }
                && isBST(left.unbox)
                && isBST(right.unbox)
        }
    }

*/

//: Making autocomplete using BST
