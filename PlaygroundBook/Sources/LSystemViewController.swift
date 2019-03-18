//
//  TestViewController.swift
//  Book_Sources
//
//  Created by Simon Bohnen on 16.03.19.
//

import Foundation
import UIKit

public class LSystemViewController: UIViewController {
    var lsystemView : LSystemView?
    var rules: [Character: String]
    var iterations: Int
    var axiom: String
    var userInteractionEnabled: Bool
    var angle: CGFloat
    
    /// Minimum scale to which the user may ‘pinch to zoom’
    private let maxScaleLimit: CGFloat = CGFloat.greatestFiniteMagnitude
    /// Maximum scale to which the user may ‘pinch to zoom’
    private let minScaleLimit: CGFloat = 0.3
    /// Variable to track how far the spiralView has been cumulatively scaled
    private var spiralViewCumulativeScale: CGFloat = 1.0
    
    public init(axiom: String, rules: [Character: String], iterations: Int, userInteractionEnabled: Bool, angle: CGFloat) {
        self.axiom = axiom
        self.rules = rules
        self.iterations = iterations
        self.userInteractionEnabled = userInteractionEnabled
        self.angle = angle
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        lsystemView = LSystemView(frame: CGRect(x: 0, y: 0, width: view.frame.width / 2, height: view.frame.height), angle: angle)
        view = lsystemView //view.addSubview(lsystemView!)
        view.backgroundColor = UIColor.black
        
        if userInteractionEnabled {
            let pinchGesture = UIPinchGestureRecognizer(target: self,
                                                        action: #selector(zoom(gestureRecognizer:)))
            view.addGestureRecognizer(pinchGesture)
            
            let panGesture = UIPanGestureRecognizer(target: self,
                                                    action: #selector(pan(gestureRecognizer:)))
            view.addGestureRecognizer(panGesture)
        }
    }
    
    //var lastPoint: CGPoint?
    //FIXME: fix zooming
    @objc func zoom(gestureRecognizer: UIPinchGestureRecognizer) {
        guard let lsystemView = lsystemView else { return }
        
        /*if gestureRecognizer.state == .began {
            lastPoint = gestureRecognizer.location(in: lsystemView)
        }*/
        
        if gestureRecognizer.state == .changed || gestureRecognizer.state == .ended {
            
            // Ensure the cumulative scale is within the set range
            if spiralViewCumulativeScale > minScaleLimit && spiralViewCumulativeScale < maxScaleLimit {
                
                // Increment the scale
                spiralViewCumulativeScale *= gestureRecognizer.scale
                //lsystemView.center = gestureRecognizer.location(in: view)
                // Execute the transform
                lsystemView.transform = lsystemView.transform.scaledBy(x: gestureRecognizer.scale,
                                                                     y: gestureRecognizer.scale);
                
                /*let point = gestureRecognizer.location(in: lsystemView)
                lsystemView.transform = lsystemView.transform.translatedBy(x: point.x - lastPoint!.x, y: point.y - lastPoint!.y)
                lastPoint = point*/
            } else {
                // If the cumulative scale has extended beyond the range, check
                // to see if the user is attempting to scale it back within range
                let nextScale = spiralViewCumulativeScale * gestureRecognizer.scale
                
                if spiralViewCumulativeScale < minScaleLimit && nextScale > minScaleLimit
                    || spiralViewCumulativeScale > maxScaleLimit && nextScale < maxScaleLimit {
                    
                    // If the user is trying to get back in-range, allow the transform
                    spiralViewCumulativeScale *= gestureRecognizer.scale
                    lsystemView.transform = lsystemView.transform.scaledBy(x: gestureRecognizer.scale,
                                                                         y: gestureRecognizer.scale);
                }
            }
        }
        
        gestureRecognizer.scale = 1;
    }
    
    @objc func pan(gestureRecognizer: UIPanGestureRecognizer) {
        guard let lsystemView = lsystemView else { return }
        
        let translation = gestureRecognizer.translation(in: view)
        
        lsystemView.center = CGPoint(x: lsystemView.center.x + translation.x,
                                    y: lsystemView.center.y + translation.y)
        
        gestureRecognizer.setTranslation(CGPoint(x: 0, y: 0), in: view)
        
    }
    
    public func drawSequences() {
        let actionMap : [Character : Action] = [
            "F": Action.forward,
            "R": Action.rotateRight,
            "L": Action.rotateLeft
        ]
        var sequences: [[Action]] = []
        for i in 1...iterations {
            let finishedSequence = replace(iterations: i, axiom: axiom, rules: rules)
            sequences.append(stringToSequence(string: finishedSequence, actionMap: actionMap))
        }
        
        lsystemView!.setSequences(sequences: sequences)
    }
}
