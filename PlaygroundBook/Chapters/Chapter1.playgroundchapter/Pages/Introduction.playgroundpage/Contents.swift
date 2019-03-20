//#-hidden-code
import UIKit
import PlaygroundSupport

func drawPath(_ path: String) {
    let rules: [Character: String] = [:]
    let actionMap : [Character : Action] = [
        "F": Action.forward,
        "R": Action.rotateRight,
        "L": Action.rotateLeft
    ]
    let config = LSystemConfiguration(axiom: path, rules: rules, iterations: 0, actionMap: actionMap, angle: CGFloat(Double.pi / 2), strokeColor: UIColor.green.cgColor, drawMode: .turtle)
    let lViewController = LSystemViewController(config: config, userInteractionEnabled: true)
    PlaygroundPage.current.liveView = lViewController
}

//#-end-hidden-code
/*:
 In this playground you'll learn about L-Systems.
 */

let path = /*#-editable-code*/"RFLFLFRF"/*#-end-editable-code*/
drawPath(path)
