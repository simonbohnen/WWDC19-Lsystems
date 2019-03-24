//#-hidden-code
//Angle modification using Kpch snowflake

import UIKit
import PlaygroundSupport

func drawLsystem(_ axiom: String, _ rules: [Character: String], _ iterations: Int, _ angle: CGFloat) {
    let actionMap : [Character : Action] = [
        "F": Action.forward,
        "R": Action.rotateRight,
        "L": Action.rotateLeft
    ]
    let config = LSystemConfiguration(axiom: axiom, rules: rules, iterations: iterations, actionMap: actionMap, angle: CGFloat(Double.pi / 2), strokeColor: UIColor.green.cgColor, drawMode: .turtle)
    let lViewController = LSystemViewController(config: config, userInteractionEnabled: true)
    PlaygroundPage.current.liveView = lViewController
}

//#-end-hidden-code
/*:
 So far we've always turned by an angle of 90 degrees. We'll change that now by defining a new variable which sets our angle. We'll use radians as a unit of angle.
 */

let axiom = /*#-editable-code enter axiom*/""/*#-end-editable-code*/
let rules: [Character: String] = [
    "F": /*#-editable-code enter replacement*/""/*#-end-editable-code*/
]
let iterations = 4
let angle = /*#-editable-code 60° in radians*//*#-end-editable-code*/
drawLsystem(axiom, rules, iterations, angle)

//#-hidden-code

//#-end-hidden-code
