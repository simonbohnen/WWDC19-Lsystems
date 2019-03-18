///#-hidden-code
import UIKit
import PlaygroundSupport

func drawSequence(axiom: String, rules: [Character: String], iterations: Int) {
    let lViewController = LSystemViewController(axiom: axiom, rules: rules, iterations: iterations, userInteractionEnabled: true, angle: .pi / 2)
    PlaygroundPage.current.liveView = lViewController
}

///#-end-hidden-code
//: This is going to be an introduction.
let axiom = "F"
let rules : [Character: String] = [
    "F": "FRFLFLFRF"
]
let iterations = 3
drawSequence(axiom: axiom, rules: rules, iterations: iterations)
