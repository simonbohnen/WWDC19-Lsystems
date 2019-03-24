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
    case morphing, turtle, draw, display, showEveryIteration
}

public class LSystemView: UIView, PlaygroundLiveViewSafeAreaContainer {
    var paths: [CGPath]?
    //The sequences this LSystemView will display. These are generated using increasingly many interations.
    var sequences: [[Action]]?
    //The configuration describing the rules, axioms etc.
    var config: LSystemConfiguration
    //The main layer displaying the path(s)
    var mainLayer = CAShapeLayer()
    //Indicates whether the drawn path is too large, is used to display error to user
    var pathTooLarge: Bool = false
    //The WorkItem which is executed once all animations finish.
    //This is used to set the .pass status for the current page
    var onFinishedDrawing: DispatchWorkItem
    
    var pathView: UILabel?
    var words: [String]?
    
    public init(frame: CGRect, config: LSystemConfiguration, pathView: UILabel?, onFinishedDrawing: DispatchWorkItem) {
        self.config = config
        self.pathView = pathView
        self.onFinishedDrawing = onFinishedDrawing
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
                switch(config.drawMode) {
                case .morphing:
                    configureMainLayer()
                    let animation = CAKeyframeAnimation(keyPath: "path")
                    var pathsDuplicated: [CGPath] = []
                    for path in paths {
                        pathsDuplicated.append(path)
                        pathsDuplicated.append(path)
                    }
                    animation.values = pathsDuplicated
                    let duration = Double(paths.count) * 2.0 / config.speed
                    animation.duration = duration
                    
                    mainLayer.add(animation, forKey: "drawPathAnimation")
                    layer.addSublayer(mainLayer)
                    DispatchQueue.main.asyncAfter(deadline: .now() + duration, execute: onFinishedDrawing)
                    
                case .draw:
                    configureMainLayer()
                    let animation = CABasicAnimation(keyPath: "strokeEnd")
                    animation.fromValue = 0.0
                    animation.toValue = 1.0
                    animation.duration = 5.0 / config.speed
                    animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                    mainLayer.add(animation, forKey: "drawPathAnimation")
                    layer.addSublayer(mainLayer)
                    
                case .display:
                    configureMainLayer()
                    layer.addSublayer(mainLayer)
                    
                case .turtle:
                    let duration = getDuration(iteration: words!.count - 1, withDelay: false)
                    addTurtleAnimation(iteration: words!.count - 1, duration: duration)
                    DispatchQueue.main.asyncAfter(deadline: .now() + duration, execute: onFinishedDrawing)
                    
                case .showEveryIteration:
                    addTurtleAnimation(iteration: 0, duration: getDuration(iteration: 0, withDelay: false))
                    
                    var delay = 0.0
                    for i in 1...config.iterations {
                        delay += getDuration(iteration: i - 1, withDelay: true)
                        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
                            self.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
                            self.addTurtleAnimation(iteration: i, duration: self.getDuration(iteration: i, withDelay: false))
                        })
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: onFinishedDrawing)
                }
            }
        }
    }
    
    func getDuration(iteration: Int, withDelay: Bool) -> Double {
        var duration = Double(words![iteration].count)
        if withDelay {
            duration += 3.0
        }
        return duration / config.speed
    }
    
    func addTurtleAnimation(iteration: Int, duration: Double) {
        if let pathView = pathView {
            pathView.text = words![iteration]
        }
        
        let startAndStep = self.getStartAndStep(sequence: self.sequences![iteration])
        let start = startAndStep.0
        let step = startAndStep.1
        
        let newPathLayer = CAShapeLayer()
        let newTurtleLayer = CAShapeLayer()
        
        newPathLayer.path = self.paths![iteration]
        newPathLayer.strokeColor = self.config.strokeColor
        newPathLayer.lineWidth = max(0.5, step / 20.0)
        newPathLayer.fillColor = nil
        
        let drawingAnimation = CAKeyframeAnimation(keyPath: "strokeEnd")
        drawingAnimation.values = self.generateStrokeEndValues(iteration: iteration)
        drawingAnimation.duration = duration
        newPathLayer.add(drawingAnimation, forKey: "drawingAnimation")
        
        let transforms: [CATransform3D] = getTurtleTransforms(sequence: self.sequences![iteration], startingPoint: start, config: self.config, step: step)
        
        //Describing the turtle as an arrow
        let turtle = UIBezierPath()
        turtle.move(to: CGPoint(x: 0, y: -step / 3.0))
        turtle.addLine(to: CGPoint(x: step / 5.0, y: step / 5.0))
        turtle.addLine(to: CGPoint(x: 0, y: step / 10.0))
        turtle.addLine(to: CGPoint(x: -step / 5.0, y: step / 5.0))
        turtle.addLine(to: CGPoint(x: 0, y: -step / 3.0))
        
        newTurtleLayer.path = turtle.cgPath
        newTurtleLayer.transform = transforms.last!
        newTurtleLayer.fillColor = UIColor.red.cgColor
        
        let turtleAnimation = CAKeyframeAnimation(keyPath: "transform")
        turtleAnimation.values = transforms
        turtleAnimation.duration = duration
        newTurtleLayer.add(turtleAnimation, forKey: "turtleAnimation")
        
        self.layer.addSublayer(newPathLayer)
        self.layer.insertSublayer(newTurtleLayer, above: newPathLayer)
    }
    
    func configureMainLayer() {
        mainLayer.path = paths!.last!
        mainLayer.strokeColor = config.strokeColor
        let step = getStartAndStep(sequence: sequences!.last!).1
        mainLayer.lineWidth = max(1, step / 20.0)
        mainLayer.fillColor = nil
    }
    
    func generateStrokeEndValues(iteration: Int) -> [CGFloat] {
        var forwardCount: CGFloat = 0
        for action in sequences![iteration] {
            if action == .forward {
                forwardCount += 1
            }
        }
        
        let step: CGFloat = 1.0 / forwardCount
        var strokeEndValues: [CGFloat] = [0.0]
        var strokeEnd: CGFloat = 0
        for action in sequences![iteration] {
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
        words = []
        for i in 0...config.iterations {
            let finishedSequence = replace(iterations: i, axiom: config.axiom, rules: config.rules)
            if finishedSequence == nil {
                pathTooLarge = true
                return
            }
            words?.append(finishedSequence!)
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
