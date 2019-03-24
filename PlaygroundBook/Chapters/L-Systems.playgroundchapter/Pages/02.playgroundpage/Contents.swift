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
 Instead of writing the string ourselves, we will now let the computer generate it. We start with some string, let's say `F`, which we call *axiom*. We then define replacement rules, which look like this: "Replace every `F` with the string `RFF`". If we apply this rule to our axiom once, we obviously just get `RFF`. If we apply it to this result again, we get `RRFFRFF` and so forth.
 
 Let's see how we can put this into code. After defining our axiom, we specify the rules using a dictionary, which maps characters to the strings they should be replaced with. We specify the number of times we want to apply our rules (*iterations*) and call `drawLsystem`.
 
 Go ahead and run the code to see the different iterations.
 
 Let's change things up a bit.
 
 1. Edit the rule such that `F` gets replaced with `FLFRFRFLF`
 3. Set the draw mode to `.morphing`
 4. Decrease the speed to `1.0`
 5. Run your code!
 
 */
let axiom = "F"
let rules: [Character: String] = [
    "F": /*#-editable-code*/"RFF"/*#-end-editable-code*/
]
let iterations = 4
let drawMode = DrawMode/*#-editable-code*/.showEveryIteration/*#-end-editable-code*/
let speed = /*#-editable-code*/2.0/*#-end-editable-code*/
drawLsystem(axiom, rules, iterations, drawMode, speed)
