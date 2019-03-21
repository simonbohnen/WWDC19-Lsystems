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
    //Indicates whether the drawn path is too large, is used to display error to user
    var pathTooLarge: Bool = false
    
    public init(frame: CGRect, config: LSystemConfiguration) {
        self.config = config
        super.init(frame: frame)
        generateSequences()
    }
     
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func draw(_ rect: CGRect) {
        if pathTooLarge {
            let errorLayer = LCTextLayer()
            errorLayer.frame = bounds
            errorLayer.alignmentMode = .center
            errorLayer.string = "The L-System you've generated is too large. Please try decreasing the number of iterations or shortening the replacement rules and try again."
            errorLayer.font = CTFontCreateWithName("Helvetica" as CFString, 20.0, nil)
            
            errorLayer.foregroundColor = UIColor.white.cgColor
            errorLayer.isWrapped = true
            errorLayer.alignmentMode = CATextLayerAlignmentMode.left
            errorLayer.contentsScale = UIScreen.main.scale
            layer.addSublayer(errorLayer)
        } else {
            generatePaths()
            
            if let paths = paths {
                mainLayer.path = paths.last!
                mainLayer.strokeColor = config.strokeColor
                let step = getStartAndStep(sequence: sequences!.last!).1
                mainLayer.lineWidth = 0.5 //step / 20.0
                mainLayer.fillColor = nil
                
                switch(config.drawMode) {
                case .morph:
                    let animation = CAKeyframeAnimation(keyPath: "path")
                    var pathsDuplicated: [CGPath] = []
                    for path in paths {
                        pathsDuplicated.append(path)
                        pathsDuplicated.append(path)
                    }
                    animation.values = pathsDuplicated
                    animation.duration = Double(paths.count) / 1.0
                    
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
                    let drawingAnimation = CAKeyframeAnimation(keyPath: "strokeEnd")
                    drawingAnimation.values = generateStrokeEndValues()
                    drawingAnimation.duration = 10 //Double(sequences!.last!.count) / 10.0
                    mainLayer.add(drawingAnimation, forKey: "drawingAnimation")
                    
                    let startAndStep = getStartAndStep(sequence: sequences!.last!)
                    let start = startAndStep.0
                    let step = startAndStep.1
                    let transforms: [CATransform3D] = getTurtleTransforms(sequence: sequences!.last!, startingPoint: start, config: config, step: step)
                    
                    //Describing the turtle as an arrow
                    let turtle = UIBezierPath()
                    turtle.move(to: CGPoint(x: 0, y: -step / 3.0))
                    turtle.addLine(to: CGPoint(x: step / 5.0, y: step / 5.0))
                    turtle.addLine(to: CGPoint(x: 0, y: step / 10.0))
                    turtle.addLine(to: CGPoint(x: -step / 5.0, y: step / 5.0))
                    turtle.addLine(to: CGPoint(x: 0, y: -step / 3.0))
                    
                    let turtleLayer = CAShapeLayer()
                    turtleLayer.path = turtle.cgPath
                    turtleLayer.transform = transforms.last!
                    turtleLayer.fillColor = UIColor.red.cgColor
                    
                    let turtleAnimaton = CAKeyframeAnimation(keyPath: "transform")
                    turtleAnimaton.values = transforms
                    turtleAnimaton.duration = 10 //Double(sequences!.last!.count) / 10.0
                    turtleAnimaton.isRemovedOnCompletion = false
                    turtleLayer.add(turtleAnimaton, forKey: "turtleAnimation")
                    
                    layer.addSublayer(mainLayer)
                    layer.insertSublayer(turtleLayer, above: mainLayer)
                }
            }
        }
    }
    
    func generateStrokeEndValues() -> [CGFloat] {
        var forwardCount: CGFloat = 0
        for action in sequences!.last! {
            if action == .forward {
                forwardCount += 1
            }
        }
        
        let step: CGFloat = 1.0 / forwardCount
        var strokeEndValues: [CGFloat] = []
        var strokeEnd: CGFloat = 0
        for action in sequences!.last! {
            if action == .forward {
                strokeEnd += step
            }
            strokeEndValues.append(strokeEnd)
        }
        
        return strokeEndValues
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
    
    func generateSequences() {
        //Generating the sequences for any number of iterations to allow morphing
        var sequences: [[Action]] = []
        for i in 0...config.iterations {
            let finishedSequence = replace(iterations: i, axiom: config.axiom, rules: config.rules)
            if finishedSequence == nil {
                pathTooLarge = true
                return
            }
            sequences.append(stringToSequence(string: finishedSequence!, actionMap: config.actionMap))
        }
        
        self.sequences = sequences
    }
}

class LCTextLayer : CATextLayer {
    // REF: http://lists.apple.com/archives/quartz-dev/2008/Aug/msg00016.html
    // CREDIT: David Hoerl - https://github.com/dhoerl
    // USAGE: To fix the vertical alignment issue that currently exists within the CATextLayer class. Change made to the yDiff calculation.
    
    override init() {
        super.init()
    }
    
    override init(layer: Any?) {
        super.init(layer: layer!)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(layer: aDecoder)
    }
    
    override func draw(in ctx: CGContext) {
        let height = self.bounds.size.height
        let fontSize = self.fontSize
        let yDiff = (height-fontSize)/2 - fontSize/10
        
        ctx.saveGState()
        ctx.translateBy(x: 0.0, y: yDiff)
        super.draw(in: ctx)
        ctx.restoreGState()
    }
}
