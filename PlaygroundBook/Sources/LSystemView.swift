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
    static let step = CGFloat(30)
    var paths: [CGPath]?
    var sequences: [[Action]]?
    var config: LSystemConfiguration
    var mainLayer = CAShapeLayer()
    var strokeEndValues: [CGFloat]?
    var transforms: [CATransform3D]?
    var startingPoint: CGPoint?
    var turtleKeyTimes: [NSNumber]?
    var forwardCount: Int?
    var lastPathOriginal: CGPath?
    
    public init(frame: CGRect, config: LSystemConfiguration) {
        self.config = config
        super.init(frame: frame)
        startingPoint = CGPoint(x: bounds.midX, y: bounds.midY)
        generatePaths()
        if config.drawMode == .turtle {
            generateTurtleKeyTimes()
        }
        setNeedsDisplay()
    }
     
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func draw(_ rect: CGRect) {
        //backgroundColor = UIColor.black
        if let paths = paths {
            lastPathOriginal = paths.last!
            scalePaths()
            mainLayer.path = paths.last!
            mainLayer.strokeColor = config.strokeColor
            mainLayer.lineWidth = 0.5
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
                break
            case .turtle:
                let drawingAnimation = CAKeyframeAnimation(keyPath: "strokeEnd")
                drawingAnimation.values = strideArray(total: forwardCount!)
                drawingAnimation.keyTimes = turtleKeyTimes
                drawingAnimation.duration = 5
                
                //Describing the turtle as an arrow
                let turtle = UIBezierPath()
                turtle.move(to: CGPoint(x: 0, y: -3))
                turtle.addLine(to: CGPoint(x: 2, y: 2))
                turtle.addLine(to: CGPoint(x: 0, y: 1))
                turtle.addLine(to: CGPoint(x: -2, y: 2))
                turtle.addLine(to: CGPoint(x: 0, y: -3))
                
                let turtleLayer = CAShapeLayer()
                var lastTransform = scalePath(path: lastPathOriginal!)
                turtleLayer.path = turtle.cgPath.copy(using: &lastTransform)
                turtleLayer.fillColor = UIColor.red.cgColor
                let turtleAnimaton = CAKeyframeAnimation(keyPath: "transform")
                turtleAnimaton.values = transforms
                turtleAnimaton.duration = 5
                turtleAnimaton.isRemovedOnCompletion = false
                
                turtleLayer.add(turtleAnimaton, forKey: "turtleAnimation")
                layer.addSublayer(turtleLayer)
                mainLayer.add(drawingAnimation, forKey: "drawingAnimation")
                layer.insertSublayer(mainLayer, below: turtleLayer)
                break
            }
        }
    }
    
    func scalePaths() {
        var scaledPaths: [CGPath] = []
        for path in paths! {
            var transform = scalePath(path: path)
            scaledPaths.append(path.copy(using: &transform)!)
        }
        paths = scaledPaths
    }
    
    func scalePath(path: CGPath) -> CGAffineTransform {
        // I'm assuming that the view and original shape layer is already created
        let boundingBox = path.boundingBoxOfPath
        
        let boundingBoxAspectRatio = boundingBox.width / boundingBox.height
        let viewAspectRatio = self.frame.width / self.frame.height
        
        var scaleFactor: CGFloat = 1.0;
        if boundingBoxAspectRatio > viewAspectRatio {
            // Width is limiting factor
            scaleFactor = self.frame.width / boundingBox.width
        } else {
            // Height is limiting factor
            scaleFactor = self.frame.height / boundingBox.height
        }
        
        // Scaling the path ...
        var scaleTransform = CGAffineTransform.identity
        // Scale down the path first
        scaleTransform = scaleTransform.scaledBy(x: scaleFactor, y: scaleFactor)
        // Then translate the path to the upper left corner
        scaleTransform = scaleTransform.translatedBy(x: -boundingBox.minX, y: -boundingBox.minY);
        
        // If you want to be fancy you could also center the path in the view
        // i.e. if you don't want it to stick to the top.
        // It is done by calculating the heigth and width difference and translating
        // half the scaled value of that in both x and y (the scaled side will be 0)
        let scaledSize = boundingBox.size.applying(CGAffineTransform(scaleX: scaleFactor, y: scaleFactor))
        let centerOffset = CGSize(width:  (frame.width - scaledSize.width) / (scaleFactor * 2.0),
                                  height: (frame.height - scaledSize.height) / (scaleFactor * 2.0))
        scaleTransform = scaleTransform.translatedBy(x: centerOffset.width, y: centerOffset.height)
        // End of "center in view" transformation code
        
        return scaleTransform
    }
    
    func strideArray(total: Int) -> [CGFloat] {
        var values: [CGFloat] = []
        for i in 0..<total {
            values.append(CGFloat(i) / CGFloat(total))
        }
        return values
    }
    
    func generatePaths() {
        //Generating the sequences for any number of iterations to allow morphing
        var sequences: [[Action]] = []
        for i in 1...config.iterations {
            let finishedSequence = replace(iterations: i, axiom: config.axiom, rules: config.rules)
            sequences.append(stringToSequence(string: finishedSequence, actionMap: config.actionMap))
        }
        
        self.sequences = sequences
        paths = []
        for sequence in sequences {
            transforms = []
            let newPath = UIBezierPath()
            var point = CGPoint(x: startingPoint!.x, y: startingPoint!.y)
            newPath.move(to: point)
            var direction = CGPoint(x: 0, y: -1)
            var cumulatedAngle: CGFloat = 0
            var posStack: [(CGPoint, CGPoint)] = []
            
            for action in sequence {
                switch action {
                case .forward:
                    point.move(x: LSystemView.step * direction.x, y: LSystemView.step * direction.y)
                    newPath.addLine(to: point)
                case .rotateLeft:
                    direction = direction.applying(CGAffineTransform(rotationAngle: config.angle))
                    cumulatedAngle += config.angle
                case .rotateRight:
                    direction = direction.applying(CGAffineTransform(rotationAngle: -config.angle))
                    cumulatedAngle -= config.angle
                case .push:
                    posStack.append((point, direction))
                    break
                case .pop:
                    let popped = posStack.popLast()! //TODO: Was machen wenns keine mehr gibt?
                    point = popped.0
                    newPath.move(to: popped.0)
                    direction = popped.1
                    break
                case .sneakForward:
                    break
                }
                if cumulatedAngle >= 2 * .pi {
                    cumulatedAngle -= 2 * .pi
                }
                if config.drawMode == .turtle {
                    var transform = CATransform3DMakeTranslation(point.x, point.y, 0)
                    transform = CATransform3DRotate(transform, cumulatedAngle, 0, 0, 1)
                    transforms?.append(transform)
                }
            }
            
            paths!.append(newPath.cgPath)
        }
        
        forwardCount = 0
        for action in sequences.last! {
            if action == .forward {
                forwardCount! += 1
            }
        }
    }
    
    func getAngle(vector: CGPoint) -> CGFloat {
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
}

extension CGPoint {
    mutating func move(x: CGFloat, y: CGFloat) {
        self.x += x
        self.y += y
    }
}
