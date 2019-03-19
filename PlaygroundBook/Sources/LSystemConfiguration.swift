//
//  LSystemConfiguration.swift
//  Book_Sources
//
//  Created by Simon Bohnen on 18.03.19.
//

import Foundation
import UIKit

public class LSystemConfiguration {
    public var axiom: String
    public var rules: [Character: String]
    public var iterations: Int
    public var actionMap: [Character: Action]
    public var angle: CGFloat
    public var strokeColor: CGColor
    public var drawMode: DrawMode
    
    public init(axiom: String, rules: [Character: String], iterations: Int, actionMap: [Character: Action], angle: CGFloat, strokeColor: CGColor, drawMode: DrawMode) {
        self.axiom = axiom
        self.rules = rules
        self.iterations = iterations
        self.actionMap = actionMap
        self.angle = angle
        self.strokeColor = strokeColor
        self.drawMode = drawMode
    }
}
