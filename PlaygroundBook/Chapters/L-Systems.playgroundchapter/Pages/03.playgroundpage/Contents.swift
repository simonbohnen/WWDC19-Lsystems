//#-hidden-code
import UIKit
import PlaygroundSupport

func drawPath(_ axiom: String, _ rules: [Character: String], _ iterations: Int) {
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
 
 */

let axiom = /*#-editable-code*/"F"/*#-end-editable-code*/
let rules: [Character: String] [
    "F": "RFF"
]
let iterations = 4
drawLsystem(axiom, rules, iterations)

//#-hidden-code
if path.starts(with: "RFLFLFRFRF") {
    PlaygroundPage.current.assessmentStatus = .pass(message: "Lookin' great! Head to the [next page](@next) to explore what can be done with these letters!")
}
//#-end-hidden-code
