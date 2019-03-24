//#-hidden-code
import UIKit
import PlaygroundSupport

func drawPath(_ path: String) {
    let rules: [Character: String] = [:]
    let actionMap : [Character : Action] = [
        "F": Action.forward,
        "R": Action.rotateRight,
        "L": Action.rotateLeft
    ]
    let config = LSystemConfiguration(axiom: path, rules: rules, iterations: 0, actionMap: actionMap, angle: CGFloat(Double.pi / 2), strokeColor: UIColor(displayP3Red: 76.0 / 255.0, green: 217.0 / 255.0, blue: 100.0 / 255.0, alpha: 1.0).cgColor, drawMode: .turtle, speed: 10.0)
    let lViewController = LSystemViewController(config: config, userInteractionEnabled: true)
    PlaygroundPage.current.liveView = lViewController
}

//#-end-hidden-code
/*:
 What you just saw is called a dragon curve. A dragon curve is a special kind of **L-system**, which is the topic of this playground. To get started with L-systems, we'll have a look at how motion can be described using letters.
 There's going to be an arrow which we can steer using the following letters:
 1. "F" moves the arrow one step forward
 2. "L" makes it turn left
 3. "R" makes it turn right
 
 Now go ahead and run the code below. You'll see the arrow perform the motions as described by the string.
 Try to extend the path so our arrow moves along an S-shape.
 When you've finished experimenting and ask yourself how this could be interesting, head over to the [next page](@next).
 
 * callout(Tip):
 You can always zoom and drag the path to explore it in further detail.
 */

let path = /*#-editable-code*/"RFLFLFRF"/*#-end-editable-code*/
drawPath(path)

//#-hidden-code
if path.starts(with: "RFLFLFRFRF") {
    PlaygroundPage.current.assessmentStatus = .pass(message: "Lookin' great! Head to the [next page](@next) to explore what can be done with these letters!")
}
//#-end-hidden-code
