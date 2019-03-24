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
 You've successfully learned the basics of L-systems! To round things up, here's the dragon curve you saw in the beginning written as an L-system. Use this page to experiment with all the options you had on the previous pages.
 
 Thank you so much for trying out my playground, I hope to see you at WWDC19!
 */
//When experimenting with your own axiom and rules, try to keep them symmetric to generate the coolest patterns!
let axiom = /*#-editable-code*/"FX"/*#-end-editable-code*/
let rules: [Character: String] = [
    //#-editable-code
    "X": "XRYFR",
    "Y": "LFXLY"
    //#-end-editable-code
]
let angle = /*#-editable-code*/Double.pi / 2/*#-end-editable-code*/
let iterations = /*#-editable-code*/6/*#-end-editable-code*/
let drawMode = DrawMode/*#-editable-code*/.morphing/*#-end-editable-code*/
let speed = /*#-editable-code*/1.0/*#-end-editable-code*/
let actions : [Character : Action] = [
    //#-editable-code
    "F": Action.forward,
    "R": Action.rotateRight,
    "L": Action.rotateLeft
    //#-end-editable-code
]
let pathColor = /*#-editable-code*/#colorLiteral(red: 0.2980392157, green: 0.8509803922, blue: 0.3921568627, alpha: 1)/*#-end-editable-code*/
drawLsystem(axiom, rules, iterations, drawMode, speed, angle, actions, pathColor)
