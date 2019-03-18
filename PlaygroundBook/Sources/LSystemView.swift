//
//  TestView.swift
//  Book_Sources
//
//  Created by Simon Bohnen on 16.03.19.
//

import Foundation
import UIKit

public class LSystemView: UIView {
    static let step = CGFloat(10)
    var paths : [CGPath]?
    var config: LSystemConfiguration
    var mainLayer = CAShapeLayer()
    
    public init(frame: CGRect, config: LSystemConfiguration) {
        self.config = config
        super.init(frame: frame)
        generatePaths()
    }
     
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func draw(_ rect: CGRect) {
        if let paths = paths {
            mainLayer.path = paths.last!
            mainLayer.strokeColor = UIColor.green.cgColor
            let animation = CAKeyframeAnimation(keyPath: "path")
            
            animation.values = paths
            animation.duration = Double(paths.count)
            
            //animation.fillMode = CAMediaTimingFillMode.forwards
            animation.isRemovedOnCompletion = false
            
            mainLayer.add(animation, forKey: "drawLineAnimation")
            layer.addSublayer(mainLayer)
        }
    }
    
    func generatePaths() {
        var sequences: [[Action]] = []
        for i in 1...config.iterations {
            let finishedSequence = replace(iterations: i, axiom: config.axiom, rules: config.rules)
            sequences.append(stringToSequence(string: finishedSequence, actionMap: config.actionMap))
        }
        
        paths = []
        for sequence in sequences {
            let newPath = UIBezierPath()
            var point = CGPoint(x: bounds.midX, y: bounds.midY)
            newPath.move(to: point)
            var direction = CGPoint(x: 0, y: -1)
            for action in sequence {
                switch action {
                case .forward:
                    point.move(x: LSystemView.step * direction.x, y: LSystemView.step * direction.y)
                    newPath.addLine(to: point)
                case .rotateLeft:
                    direction = direction.applying(CGAffineTransform(rotationAngle: config.angle))
                case .rotateRight:
                    direction = direction.applying(CGAffineTransform(rotationAngle: config.angle))
                case .push:
                    break
                case .pop:
                    break
                case .sneakForward:
                    break
                }
            }
            paths!.append(newPath.cgPath)
        }
        setNeedsDisplay()
    }
}

extension CGPoint {
    mutating func move(x: CGFloat, y: CGFloat) {
        self.x += x
        self.y += y
    }
}
