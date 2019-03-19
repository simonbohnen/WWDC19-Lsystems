//
//  TestView.swift
//  Book_Sources
//
//  Created by Simon Bohnen on 16.03.19.
//

import Foundation
import UIKit

public class ColorStackView: UIView, UIGestureRecognizerDelegate {
    var colors: [CGColor] = []
    var layers: [CALayer] = []
    var wasAdded: Bool = false
    var isInitialDraw = true
    var maxHeight: CGFloat
    static let blobRadius: CGFloat = 10
    static let cellHeight: CGFloat = 20
    
    public init(frame: CGRect, config: LSystemConfiguration) {
        maxHeight = frame.maxY
        super.init(frame: frame)
        backgroundColor = UIColor.black
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func draw(_ rect: CGRect) {
        if isInitialDraw {
            isInitialDraw = false
            
        }
        if wasAdded {
            maxHeight -= ColorStackView.cellHeight
            let newLayer = CAShapeLayer()
            let newPath = UIBezierPath(arcCenter: CGPoint(x: frame.midX, y: maxHeight + ColorStackView.cellHeight / 2.0), radius: ColorStackView.blobRadius, startAngle: 0, endAngle: CGFloat(2 * Double.pi), clockwise: true)
            newLayer.strokeColor = colors.last!
            newLayer.fillColor = colors.last!
            newLayer.path = newPath.cgPath
            layer.addSublayer(newLayer)
        } else {
            
        }
    }
    
    public func push(color: CGColor) {
        colors.append(color)
        setNeedsDisplay()
    }
    
    public func pop() {
        _ = colors.popLast()
        setNeedsDisplay()
    }
}
