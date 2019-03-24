//#-hidden-code
import UIKit
import PlaygroundSupport

func drawLsystem(_ axiom: String, _ rules: [Character: String], _ iterations: Int, _ drawMode: DrawMode, _ speed: Double, _ angle: Double, _ actions: [Character: Action], _ strokeColor: UIColor) {
    let onFinishedDrawing = DispatchWorkItem {
        /*if path.starts(with: "RFLFLFRFRF") {
         PlaygroundPage.current.assessmentStatus = .pass(message: "Lookin' great! Head to the [next page](@next) to explore what can be done with these letters!")
         }*/
    }
    let config = LSystemConfiguration(axiom: axiom, rules: rules, iterations: iterations, actionMap: actions, angle: CGFloat(angle), strokeColor: strokeColor.cgColor, drawMode: drawMode, speed: speed)
    let lViewController = LSystemViewController(config: config, userInteractionEnabled: true, onFinishedDrawing: onFinishedDrawing)
    PlaygroundPage.current.liveView = lViewController
}

//#-end-hidden-code
/*:

 */
//#-editable-code
let axiom = "FX"
let rules: [Character: String] = [
    "X": "XRYFR",
    "Y": "LFXLY"
]
let angle = Double.pi / 2
let iterations = 6
let drawMode = DrawMode.morphing
let speed = 1.0
let actions : [Character : Action] = [
    "F": Action.forward,
    "R": Action.rotateRight,
    "L": Action.rotateLeft
]
let pathColor = UIColor.green
drawLsystem(axiom, rules, iterations, drawMode, speed, angle, actions, pathColor)
//#-end-editable-code
