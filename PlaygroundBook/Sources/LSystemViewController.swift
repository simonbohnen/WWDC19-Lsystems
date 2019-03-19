//
//  TestViewController.swift
//  Book_Sources
//
//  Created by Simon Bohnen on 16.03.19.
//

import Foundation
import UIKit
import PlaygroundSupport

public class LSystemViewController: UIViewController, PlaygroundLiveViewSafeAreaContainer {
    var lsystemView : LSystemView?
    var config: LSystemConfiguration
    var userInteractionEnabled: Bool
    
    /// Minimum scale to which the user may ‘pinch to zoom’
    private let maxScaleLimit: CGFloat = .greatestFiniteMagnitude
    /// Maximum scale to which the user may ‘pinch to zoom’
    private let minScaleLimit: CGFloat = 0.3
    /// Variable to track how far the spiralView has been cumulatively scaled
    private var spiralViewCumulativeScale: CGFloat = 1.0
    
    public init(config: LSystemConfiguration, userInteractionEnabled: Bool) {
        self.userInteractionEnabled = userInteractionEnabled
        self.config = config
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        addAndConstrainImageView()
        
        if userInteractionEnabled {
            let pinchGesture = UIPinchGestureRecognizer(target: self,
                                                        action: #selector(zoom(gestureRecognizer:)))
            view.addGestureRecognizer(pinchGesture)
            
            let panGesture = UIPanGestureRecognizer(target: self,
                                                    action: #selector(pan(gestureRecognizer:)))
            view.addGestureRecognizer(panGesture)
        }
    }
    
    private var oldBounds = CGRect()
    private let padding: CGFloat = 20.0
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // If we need to update based on the layoutGuide changing.
        if oldBounds != liveViewSafeAreaGuide.layoutFrame {
            oldBounds = liveViewSafeAreaGuide.layoutFrame
            
            spiralViewCumulativeScale = 1.0
            var scale: CGFloat = 1.0
            
            // Always match scale to the shorter “side” so it fits
            if liveViewSafeAreaGuide.layoutFrame.width < liveViewSafeAreaGuide.layoutFrame.height {
                scale = (liveViewSafeAreaGuide.layoutFrame.width - padding) / (lsystemView?.frame.width)!
            } else {
                scale = (liveViewSafeAreaGuide.layoutFrame.height - padding) / (lsystemView?.frame.height)!
            }
            
            // Increment the scale
            spiralViewCumulativeScale *= scale
            
            // Execute the transform
            lsystemView?.transform = (lsystemView?.transform.scaledBy(x: scale,
                                                                    y: scale))!;
        }
    }
    
    private let tempConstantForLayoutScaling: CGFloat = 700.0
    
    fileprivate func addAndConstrainImageView() {
        let lsystemView = LSystemView(frame: view.frame, config: config)
        view.addSubview(lsystemView)
        //view.backgroundColor = UIColor.black
        
        lsystemView.translatesAutoresizingMaskIntoConstraints = false
        // Always reset the spiralScale when we reset the spiral
        spiralViewCumulativeScale = 1.0
        
        // Constrain `spiralView` to a square whose size matches the shorter of width and height.
        let widthConstraint: NSLayoutConstraint
        let heightConstraint: NSLayoutConstraint
        
        // Set initial constraint values—from here we will only scale up or down
        widthConstraint = lsystemView.widthAnchor.constraint(equalToConstant: tempConstantForLayoutScaling)
        heightConstraint = lsystemView.heightAnchor.constraint(equalToConstant: tempConstantForLayoutScaling)
        
        let centerYConstraint = lsystemView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        let centerXConstraint = lsystemView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        NSLayoutConstraint.activate([widthConstraint,
                                     heightConstraint,
                                     centerYConstraint,
                                     centerXConstraint])
        self.lsystemView = lsystemView
    }
    
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
}
