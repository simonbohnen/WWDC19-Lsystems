///#-hidden-code
import UIKit
import PlaygroundSupport

func drawSequence(axiom: String, rules: [Character: String], iterations: Int) {
    //let lViewController = LSystemViewController(axiom: axiom, rules: rules, iterations: iterations, userInteractionEnabled: true, angle: CGFloat(Double.pi / 2))
    //    PlaygroundPage.current.liveView = lViewController
}

///#-end-hidden-code
//: This is going to be an introduction.
let axiom = "F"
let rules : [Character: String] = [
    "F": "FRFLFLFRF"
]
let iterations = 3
let actionMap : [Character : Action] = [
    "F": Action.forward,
    "R": Action.rotateRight,
    "L": Action.rotateLeft
]

let config = LSystemConfiguration(axiom: axiom, rules: rules, iterations: iterations, actionMap: actionMap, angle: CGFloat(Double.pi / 2), strokeColor: UIColor.green)
let lViewController = LSystemViewController(config: config, userInteractionEnabled: true)
PlaygroundPage.current.liveView = lViewController
