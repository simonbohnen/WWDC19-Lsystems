//#-hidden-code
import PlaygroundSupport
import UIKit

func drawLsystem(_ axiom: String, _ rules: [Character: String], _ iterations: Int, _ drawMode: DrawMode, _ speed: Double, _ angle: Double, _ actions: [Character: Action]) {
    let onFinishedDrawing = DispatchWorkItem {
        /*if path.starts(with: "RFLFLFRFRF") {
         PlaygroundPage.current.assessmentStatus = .pass(message: "Lookin' great! Head to the [next page](@next) to explore what can be done with these letters!")
         }*/
    }
    let config = LSystemConfiguration(axiom: axiom, rules: rules, iterations: iterations, actionMap: actions, angle: CGFloat(angle), strokeColor: UIColor(displayP3Red: 76.0 / 255.0, green: 217.0 / 255.0, blue: 100.0 / 255.0, alpha: 1.0).cgColor, drawMode: drawMode, speed: speed)
    let lViewController = LSystemViewController(config: config, userInteractionEnabled: true, onFinishedDrawing: onFinishedDrawing)
    PlaygroundPage.current.liveView = lViewController
}

//#-end-hidden-code
/*:
 To allow more flexibility we can also define which action each symbol stands for. To do this, we create another dictionary which maps a characters to its action.
 */
let axiom = "FLGLG"
let rules: [Character: String] = [
    "F": "FLGRFRGLF",
    "G": "GG"
]
let angle = Double.pi / 3 * 2
let iterations = 6
let drawMode = DrawMode.morphing
let speed = 1.0
let actions : [Character : Action] = [
    "F": Action.forward,
    "G": Action.forward,
    "R": Action.rotateRight,
    "L": Action.rotateLeft
]
drawLsystem(axiom, rules, iterations, drawMode, speed, angle, actions)
