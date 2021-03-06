//
//  Utils.swift
//  Book_Sources
//
//  Created by Simon Bohnen on 16.03.19.
//

import Foundation
import UIKit
import PlaygroundSupport

public enum Action {
    case forward, rotateRight, rotateLeft, push, pop, sneakForward
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

let maxLength = 20000

public func replace(iterations: Int, axiom: String, rules: [Character: String]) -> String? {
    var cur = axiom
    if iterations == 0 {
        return axiom
    }
    for _ in 1...iterations {
        var new = ""
        for char in cur {
            if let replacement = rules[char] {
                new.append(replacement)
            } else {
                new.append(char)
            }
            if new.count > maxLength {
                return nil
            }
        }
        cur = new
    }
    return cur
}

public func getTurtleTransforms(sequence: [Action], startingPoint: CGPoint, config: LSystemConfiguration, step: CGFloat) -> [CATransform3D] {
    var point = CGPoint(x: startingPoint.x, y: startingPoint.y)
    var transforms: [CATransform3D] = [CATransform3DMakeTranslation(point.x, point.y, 0)]
    var direction = CGPoint(x: 0, y: -1)
    var cumulatedAngle: CGFloat = 0
    var posStack: [(CGPoint, CGPoint)] = []
    
    for action in sequence {
        switch action {
        case .forward:
            point.move(x: step * direction.x, y: step * direction.y)
        case .rotateLeft:
            cumulatedAngle -= config.angle
            direction = direction.applying(CGAffineTransform(rotationAngle: -config.angle))
        case .rotateRight:
            cumulatedAngle += config.angle
            direction = direction.applying(CGAffineTransform(rotationAngle: config.angle))
        case .push:
            posStack.append((point, direction))
            break
        case .pop:
            let popped = posStack.popLast()!
            point = popped.0
            direction = popped.1
            break
        case .sneakForward:
            break
        }
        if cumulatedAngle >= 2 * .pi {
            cumulatedAngle -= 2 * .pi
        }
        var transform = CATransform3DMakeTranslation(point.x, point.y, 0)
        transform = CATransform3DRotate(transform, cumulatedAngle, 0, 0, 1)
        transforms.append(transform)
    }
    
    return transforms
}

public func getPath(sequence: [Action], startingPoint: CGPoint, config: LSystemConfiguration, step: CGFloat) -> CGPath {
    let newPath = UIBezierPath()
    var point = CGPoint(x: startingPoint.x, y: startingPoint.y)
    newPath.move(to: point)
    var direction = CGPoint(x: 0, y: -1)
    var posStack: [(CGPoint, CGPoint)] = []
    
    for action in sequence {
        switch action {
        case .forward:
            point.move(x: step * direction.x, y: step * direction.y)
            newPath.addLine(to: point)
        case .rotateLeft:
            direction = direction.applying(CGAffineTransform(rotationAngle: -config.angle))
        case .rotateRight:
            direction = direction.applying(CGAffineTransform(rotationAngle: config.angle))
        case .push:
            posStack.append((point, direction))
            break
        case .pop:
            let popped = posStack.popLast()!
            point = popped.0
            newPath.move(to: popped.0)
            direction = popped.1
            break
        case .sneakForward:
            break
        }
    }
    
    return newPath.cgPath
}

public func getBoxAndStartPoint(sequence: [Action], config: LSystemConfiguration) -> (CGFloat, CGFloat, CGFloat, CGFloat) {
    var point = CGPoint(x: 0, y: 0)
    var direction = CGPoint(x: 0, y: -1)
    var posStack: [(CGPoint, CGPoint)] = []
    
    var minx: CGFloat = 0
    var maxx: CGFloat = 0
    var miny: CGFloat = 0
    var maxy: CGFloat = 0
    
    for action in sequence {
        switch action {
        case .forward:
            point.move(x: direction.x, y: direction.y)
        case .rotateLeft:
            direction = direction.applying(CGAffineTransform(rotationAngle: -config.angle))
        case .rotateRight:
            direction = direction.applying(CGAffineTransform(rotationAngle: config.angle))
        case .push:
            posStack.append((point, direction))
            break
        case .pop:
            let popped = posStack.popLast()!
            point = popped.0
            direction = popped.1
            break
        case .sneakForward:
            break
        }
        
        if point.x < minx {
            minx = point.x
        }
        if point.y < miny {
            miny = point.y
        }
        if point.x > maxx {
            maxx = point.x
        }
        if point.y > maxy {
            maxy = point.y
        }
    }
    let startX = -minx
    let startY = -miny
    return (startX, startY, maxx - minx, maxy - miny)
}

extension CGPoint {
    mutating func move(x: CGFloat, y: CGFloat) {
        self.x += x
        self.y += y
    }
}
