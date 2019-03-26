//#-hidden-code
import UIKit
import PlaygroundSupport

func drawLsystem(_ axiom: String, _ rules: [Character: String], _ iterations: Int, _ drawMode: DrawMode, _ speed: Double) {
    let actionMap : [Character : Action] = [
        "F": Action.forward,
        "R": Action.rotateRight,
        "L": Action.rotateLeft
    ]
    let onFinishedDrawing = DispatchWorkItem {
        if rules["F"] == "FLFRFRFLF" && speed == 1.0 {
            PlaygroundPage.current.assessmentStatus = .pass(message: "Beautiful, isn't it? Go to the [next page](@next) to see what else we can generate!")
        }
    }
    let config = LSystemConfiguration(axiom: axiom, rules: rules, iterations: iterations, actionMap: actionMap, angle: CGFloat(Double.pi / 2), strokeColor: UIColor(displayP3Red: 76.0 / 255.0, green: 217.0 / 255.0, blue: 100.0 / 255.0, alpha: 1.0).cgColor, drawMode: drawMode, speed: speed)
    let lViewController = LSystemViewController(config: config, userInteractionEnabled: true, onFinishedDrawing: onFinishedDrawing)
    PlaygroundPage.current.liveView = lViewController
}

//#-end-hidden-code
/*:
 Instead of writing the string ourselves, we will now let the computer generate it. We start with some string, let's say `F`, which we call *axiom*. We then define replacement rules in the style of "Replace every `F` with the string `RFF`". If we apply this rule to our axiom once, we obviously just get `RFF`. If we apply it to this result again, we get `RRFFRFF` and so forth. The axiom and the replacement rules make up our **L-system**.
 
 Go ahead and run the code to see the different iterations for the axiom and rule described above.
 
 Now let's change things up a bit.
 
 1. Edit the rule such that `F` gets replaced with `FLFRFRFLF`
 2. Set the draw mode to `.morphBetweenIterations`
 3. Decrease the speed to `1.0`
 4. Run your code!
 */
//#-code-completion(everything, hide)
//The string we start out with
let axiom = "F"
//The rules as a dictionary mapping from characters to replacements
//#-code-completion(literal, show, string)
let rules: [Character: String] = [
    "F": /*#-editable-code*/"RFF"/*#-end-editable-code*/
]
//How often we want to apply our rules
let iterations = 4
//How the L-system should be drawn
//#-code-completion(identifier, show, morphBetweenIterations)
let drawMode = DrawMode/*#-editable-code*/.showEveryIteration/*#-end-editable-code*/
let speed = /*#-editable-code*/3.0/*#-end-editable-code*/
drawLsystem(axiom, rules, iterations, drawMode, speed)
