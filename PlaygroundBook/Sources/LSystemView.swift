//
//  TestView.swift
//  Book_Sources
//
//  Created by Simon Bohnen on 16.03.19.
//

import Foundation
import UIKit

public enum DrawMode {
    case morph, turtle, draw, display
}

public class LSystemView: UIView, UIGestureRecognizerDelegate {
    var paths: [CGPath]?
    //The sequences this LSystemView will display. These are generated using increasingly many interations.
    var sequences: [[Action]]?
    //The configuration describing the rules, axioms etc.
    var config: LSystemConfiguration
    //The main layer displaying the path(s)
    var mainLayer = CAShapeLayer()
    
    var strokeEndValues: [CGFloat]?
    var transforms: [CATransform3D]?
    var startingPoint: CGPoint?
    var turtleKeyTimes: [NSNumber]?
    var forwardCount: Int?
    var lastTransform: CGAffineTransform?
    
    public init(frame: CGRect, config: LSystemConfiguration) {
        self.config = config
        super.init(frame: frame)
        generateSequences()
        generatePaths()
        if config.drawMode == .turtle {
            generateTurtleKeyTimes()
        }
        //setNeedsDisplay()
    }
     
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var isInitialDraw: Bool = true
    
    public override func draw(_ rect: CGRect) {
        /*if isInitialDraw {
            isInitialDraw = false
            return
        }*/
        let borderLayer = CAShapeLayer()
        let borderPath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        borderLayer.path = borderPath.cgPath
        borderLayer.strokeColor = UIColor.black.cgColor
        borderLayer.fillColor = nil
        layer.addSublayer(borderLayer)
        
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
                
                // 1
                let textLayer = CATextLayer()
                textLayer.frame = self.bounds
                
                // 2
                let string = String(Double(frame.width)) + " " + String(Double(frame.height)) + "\n"
                
                textLayer.string = string
                
                // 3
                textLayer.font = CTFontCreateWithName("Helvetica" as CFString, 20, nil)
                
                // 4
                textLayer.foregroundColor = UIColor.darkGray.cgColor
                textLayer.isWrapped = true
                textLayer.alignmentMode = CATextLayerAlignmentMode.left
                textLayer.contentsScale = UIScreen.main.scale
                layer.addSublayer(textLayer)
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
                let drawingAnimation = CAKeyframeAnimation(keyPath: "strokeEnd")
                drawingAnimation.values = strideArray(total: forwardCount!)
                drawingAnimation.keyTimes = turtleKeyTimes
                drawingAnimation.duration = Double(sequences!.last!.count) / 2.0
                
                //Describing the turtle as an arrow
                let turtle = UIBezierPath()
                turtle.move(to: CGPoint(x: 0, y: -3))
                turtle.addLine(to: CGPoint(x: 2, y: 2))
                turtle.addLine(to: CGPoint(x: 0, y: 1))
                turtle.addLine(to: CGPoint(x: -2, y: 2))
                turtle.addLine(to: CGPoint(x: 0, y: -3))
                
                let turtleLayer = CAShapeLayer()
                turtleLayer.path = turtle.cgPath //.copy(using: &lastTransform!)
                turtleLayer.fillColor = UIColor.red.cgColor
                let turtleAnimaton = CAKeyframeAnimation(keyPath: "transform")
                
                var newTurtleTransforms: [CATransform3D] = []
                let lastTransform3D = CATransform3DMakeAffineTransform(lastTransform!)
                for transform in transforms! {
                    newTurtleTransforms.append(CATransform3DConcat(transform, lastTransform3D))
                }
                
                turtleAnimaton.values = newTurtleTransforms
                turtleAnimaton.duration = Double(sequences!.last!.count) / 2.0
                turtleAnimaton.isRemovedOnCompletion = false
                
                turtleLayer.add(turtleAnimaton, forKey: "turtleAnimation")
                mainLayer.add(drawingAnimation, forKey: "drawingAnimation")
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
            let startAndBox = getBoxAndStartPoint(sequence: sequence, config: config)
            let width = startAndBox.2
            let height = startAndBox.3
            var step: CGFloat = 10
            if width > height {
                step = frame.width / width
            } else {
                step = frame.height / height
            }
            let start = CGPoint(x: startAndBox.0 * step, y: startAndBox.1 * step) //CGPoint(x: 200, y: 200)
            paths?.append(getPath(sequence: sequence, startingPoint: start, config: config, step: step))
        }
    }
    
    /*func getAngle(vector: CGPoint) -> CGFloat {
        if vector.x == 0 {
            if vector.y > 0 {
                return .pi
            } else {
                return 0
            }
        }
        if vector.y == 0 {
            if vector.x > 0 {
                return .pi / 2
            } else {
                return -.pi / 2
            }
        }
        return atan2(vector.y, vector.x)
    }*/
    
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
