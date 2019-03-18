//
//  Utils.swift
//  Book_Sources
//
//  Created by Simon Bohnen on 16.03.19.
//

import Foundation

public enum Action {
    case forward, rotateRight, rotateLeft, push, pop, sneakForward //TODO besserer name
}

public func stringToSequence(string: String, actionMap: [Character: Action]) -> [Action] {
    var actionSequence : [Action] = []
    for char in string {
        if let action = actionMap[char] {
            actionSequence.append(action)
        }
    }
    return actionSequence
}

public func replace(iterations: Int, axiom: String, rules: [Character: String]) -> String {
    var cur = axiom
    for _ in 1...iterations {
        var new = ""
        for char in cur {
            if let replacement = rules[char] {
                new.append(replacement)
            } else {
                new.append(char)
            }
        }
        cur = new
    }
    return cur
}
