///#-hidden-code
import UIKit
import PlaygroundSupport

func drawLsystem(_ axiom: String, _ rules: [Character: String], _ iterations: Int) {
    let actionMap : [Character : Action] = [
        "F": Action.forward,
        "R": Action.rotateRight,
        "L": Action.rotateLeft
    ]
    let config = LSystemConfiguration(axiom: axiom, rules: rules, iterations: iterations, actionMap: actionMap, angle: CGFloat(Double.pi / 2), strokeColor: UIColor.green.cgColor, drawMode: .page2mode, speed: 1.0)
    let lViewController = LSystemViewController(config: config, userInteractionEnabled: true)
    PlaygroundPage.current.liveView = lViewController
}

//#-end-hidden-code
/*:
 As you can imagine we could draw arbitrarily complex patterns using this technique. But writing out every letter would get very tedious very quickly. So we let the computer generate more complex patterns based on rules we define. We start with some string, let's say "F", which we call *axiom*.
 We then define replacement rules, which tell the computer how to generate more complex patterns from our axiom. Such a rule looks like this: "Replace every "F" with the string "RFF"". If we apply this rule to our axiom once, we obviously just get "RFF". If we apply it to this result again, we get "RRFFRFF".
 Let's see how we can codify this. After defining our axiom, we specify the rules using a dictionary, which maps characters to the strings they should be replaced with. We specify the number of times we want to apply our rules (*iterations*) and call the "drawLsystem" method which draws the L-system for us.
 */

let axiom = /*-editable-code*/"F"/*-end-editable-code*/
let rules: [Character: String] = [
    "F": "RFF"
]
let iterations = 4
drawLsystem(axiom, rules, iterations)

//#-hidden-code
/*if path.starts(with: "RFLFLFRFRF") {
    PlaygroundPage.current.assessmentStatus = .pass(message: "Lookin' great! Head to the [next page](@next) to explore what can be done with these letters!")
}*/
//#-end-hidden-code
