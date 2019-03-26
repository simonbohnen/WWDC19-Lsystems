//#-hidden-code
//Angle modification using Koch snowflake

import UIKit
import PlaygroundSupport

func drawLsystem(_ axiom: String, _ rules: [Character: String], _ iterations: Int, _ drawMode: DrawMode, _ speed: Double, _ angle: Double) {
    let actionMap : [Character : Action] = [
        "F": Action.forward,
        "R": Action.rotateRight,
        "L": Action.rotateLeft
    ]
    let onFinishedDrawing = DispatchWorkItem {
        if axiom == "FRRFRRF" && rules["F"] == "FLFRRFLF" && angle == Double.pi / 3 {
            PlaygroundPage.current.assessmentStatus = .pass(message: "Well done! You're becoming a pro at this!")
        }
    }
    let config = LSystemConfiguration(axiom: axiom, rules: rules, iterations: iterations, actionMap: actionMap, angle: CGFloat(angle), strokeColor: UIColor(displayP3Red: 76.0 / 255.0, green: 217.0 / 255.0, blue: 100.0 / 255.0, alpha: 1.0).cgColor, drawMode: drawMode, speed: speed)
    let lViewController = LSystemViewController(config: config, userInteractionEnabled: true, onFinishedDrawing: onFinishedDrawing)
    PlaygroundPage.current.liveView = lViewController
}
//#-end-hidden-code
/*:
 So far we've always turned by an angle of 90°. We'll change that now by defining a new variable which sets our angle in radians.
 
 Complete the following steps to see a beautiful Koch snowflake emerge.
 
 1. Set the axiom to `FRRFRRF`
 2. Let `F` be replaced with `FLFRRFLF`
 3. Set the angle to 60° in radians
 4. Run your code!
 */
let axiom = /*#-editable-code enter axiom*/""/*#-end-editable-code*/
let rules: [Character: String] = [
    "F": /*#-editable-code enter replacement*/""/*#-end-editable-code*/
]
let iterations = 4
let angle = /*#-editable-code enter angle*/Double.pi / 2/*#-end-editable-code*/
let drawMode = DrawMode.morphBetweenIterations
let speed = 1.0
drawLsystem(axiom, rules, iterations, drawMode, speed, angle)
