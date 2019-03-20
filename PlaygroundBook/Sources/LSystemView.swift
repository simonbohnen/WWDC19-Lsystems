//
//  TestView.swift
//  Book_Sources
//
//  Created by Simon Bohnen on 16.03.19.
//

import Foundation
import UIKit
import PlaygroundSupport

public enum DrawMode {
    case morph, turtle, draw, display
}

public class LSystemView: UIView, UIGestureRecognizerDelegate, PlaygroundLiveViewSafeAreaContainer {
    var paths: [CGPath]?
    //The sequences this LSystemView will display. These are generated using increasingly many interations.
    var sequences: [[Action]]?
    //The configuration describing the rules, axioms etc.
    var config: LSystemConfiguration
    //The main layer displaying the path(s)
    var mainLayer = CAShapeLayer()
    
    var strokeEndValues: [CGFloat]?
    //var transforms: [CATransform3D]?
    var startingPoint: CGPoint?
    var turtleKeyTimes: [NSNumber]?
    var forwardCount: Int?
    var lastTransform: CGAffineTransform?
    
    public init(frame: CGRect, config: LSystemConfiguration) {
        self.config = config
        super.init(frame: frame)
        generateSequences()
    }
     
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func draw(_ rect: CGRect) {
        generatePaths()
        if config.drawMode == .turtle {
            generateTurtleKeyTimes()
        }
        
        if let paths = paths {
            mainLayer.path = paths.last!
            mainLayer.strokeColor = config.strokeColor
            mainLayer.lineWidth = 1
            mainLayer.fillColor = nil
            switch(config.drawMode) {
            case .morph:
                let animation = CAKeyframeAnimation(keyPath: "path")
                
                animation.values = paths
                animation.duration = Double(paths.count) / 3.0
                
                //animation.fillMode = CAMediaTimingFillMode.forwards
                animation.isRemovedOnCompletion = false
                
                mainLayer.add(animation, forKey: "drawPathAnimation")
                layer.addSublayer(mainLayer)
            case .draw:
                let animation = CABasicAnimation(keyPath: "strokeEnd")
                animation.fromValue = 0.0
                animation.toValue = 1.0
                animation.duration = 5
                mainLayer.add(animation, forKey: "drawPathAnimation")
                layer.addSublayer(mainLayer)
            case .display:
                //TODO: implement
                break
            case .turtle:
                /*let drawingAnimation = CAKeyframeAnimation(keyPath: "strokeEnd")
                drawingAnimation.values = strideArray(total: forwardCount!)
                drawingAnimation.keyTimes = turtleKeyTimes
                drawingAnimation.duration = Double(sequences!.last!.count) / 2.0*/
                
                let animation = CABasicAnimation(keyPath: "strokeEnd")
                animation.fromValue = 0.0
                animation.toValue = 1.0
                animation.duration = 5
                //mainLayer.add(animation, forKey: "drawPathAnimation")
                
                //Describing the turtle as an arrow
                let turtle = UIBezierPath()
                turtle.move(to: CGPoint(x: 0, y: -3))
                turtle.addLine(to: CGPoint(x: 2, y: 2))
                turtle.addLine(to: CGPoint(x: 0, y: 1))
                turtle.addLine(to: CGPoint(x: -2, y: 2))
                turtle.addLine(to: CGPoint(x: 0, y: -3))
                
                let turtleLayer = CAShapeLayer()
                turtleLayer.path = turtle.cgPath
                turtleLayer.fillColor = UIColor.red.cgColor
                let turtleAnimaton = CAKeyframeAnimation(keyPath: "transform")
                
                let startAndStep = getStartAndStep(sequence: sequences!.last!)
                let transforms: [CATransform3D] = getTurtleTransforms(sequence: sequences!.last!, startingPoint: startAndStep.0, config: config, step: startAndStep.1)
                
                turtleAnimaton.values = transforms
                turtleAnimaton.duration = Double(sequences!.last!.count) / 2.0
                turtleAnimaton.isRemovedOnCompletion = false
                
                turtleLayer.add(turtleAnimaton, forKey: "turtleAnimation")
                mainLayer.add(animation, forKey: "drawingAnimation")
                layer.addSublayer(mainLayer)
                layer.insertSublayer(turtleLayer, above: mainLayer)
            }
        }
    }
    
    func strideArray(total: Int) -> [CGFloat] {
        var values: [CGFloat] = []
        for i in 0..<total {
            values.append(CGFloat(i) / CGFloat(total))
        }
        return values
    }
    
    func generatePaths() {
        paths = []
        for sequence in sequences! {
            let startAndStep = getStartAndStep(sequence: sequence)
            paths?.append(getPath(sequence: sequence, startingPoint: startAndStep.0, config: config, step: startAndStep.1))
        }
    }
    
    func getStartAndStep(sequence: [Action]) -> (CGPoint, CGFloat){
        let startAndBox = getBoxAndStartPoint(sequence: sequence, config: config)
        let width = startAndBox.2
        let height = startAndBox.3
        var step: CGFloat
        var start: CGPoint
        if width > height {
            step = bounds.width / width
            start = CGPoint(x: startAndBox.0 * step, y: startAndBox.1 * step + bounds.midY - height * step / 2)
        } else {
            step = bounds.height / height
            start = CGPoint(x: startAndBox.0 * step + bounds.midX - width * step / 2, y: startAndBox.1 * step)
        }
        
        return (start, step)
    }
    
    func generateTurtleKeyTimes() {
        var time: Int = 0
        var keyTimesInt: [Int] = [0]
        for action in sequences!.last! {
            time += 1
            if action == .forward {
                keyTimesInt.append(time)
            }
        }
        turtleKeyTimes = []
        for val in keyTimesInt {
            turtleKeyTimes!.append(NSNumber(value: Double(val) / Double(keyTimesInt.last!)))
        }
    }
    
    func generateSequences() {
        //Generating the sequences for any number of iterations to allow morphing
        var sequences: [[Action]] = []
        for i in 1...config.iterations {
            let finishedSequence = replace(iterations: i, axiom: config.axiom, rules: config.rules)
            sequences.append(stringToSequence(string: finishedSequence, actionMap: config.actionMap))
        }
        
        self.sequences = sequences
    }
}
