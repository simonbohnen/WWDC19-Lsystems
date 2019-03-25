//#-hidden-code
import PlaygroundSupport
import UIKit

func drawLsystem(_ axiom: String, _ rules: [Character: String], _ iterations: Int, _ drawMode: DrawMode, _ speed: Double, _ angle: Double, _ actions: [Character: Action]) {
    let onFinishedDrawing = DispatchWorkItem {
        if actions["F"] == .forward && actions["G"] == .forward {
            PlaygroundPage.current.assessmentStatus = .pass(message: "That's lookin' good! The self-similarity is mesmerizing, isn't it?")
        }
    }
    let config = LSystemConfiguration(axiom: axiom, rules: rules, iterations: iterations, actionMap: actions, angle: CGFloat(angle), strokeColor: UIColor(displayP3Red: 76.0 / 255.0, green: 217.0 / 255.0, blue: 100.0 / 255.0, alpha: 1.0).cgColor, drawMode: drawMode, speed: speed)
    let lViewController = LSystemViewController(config: config, userInteractionEnabled: true, onFinishedDrawing: onFinishedDrawing)
    PlaygroundPage.current.liveView = lViewController
}

//#-end-hidden-code
/*:
 To allow more flexibility we can also define which action each letter stands for. To do this, we create another dictionary which maps a character to its action.
 
 Go ahead and make both `F` and `G` stand for a move forward to generate the famous **Sierpinski triangle**!
 */
//#-code-completion(everything, hide)
let axiom = "FLGLG"
let rules: [Character: String] = [
    "F": "FLGRFRGLF",
    "G": "GG"
]
let angle = Double.pi / 3 * 2
let iterations = 6
let drawMode = DrawMode.morphBetweenIterations
let speed = 1.4
//#-code-completion(identifier, show, forward)
let actions : [Character : Action] = [
    "F": Action/*#-editable-code*/.<#enter action#>/*#-end-editable-code*/,
    "G": Action/*#-editable-code*/.<#enter action#>/*#-end-editable-code*/,
    "R": Action.rotateRight,
    "L": Action.rotateLeft
]
drawLsystem(axiom, rules, iterations, drawMode, speed, angle, actions)
