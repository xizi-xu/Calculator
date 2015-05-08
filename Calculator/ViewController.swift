//
//  ViewController.swift
//  Calculator
//
//  Created by John Xu on 5/4/15.
//  Copyright (c) 2015 Liuxizi Xu. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var history: UILabel!
    
    var userIsInTheMiddleOfTypingANumber = false
    let pi3 = M_PI
    var clearHistory = true
    var operandStack = Array<Double>()
    
    //computed property
    var displayValue: Double {
        get {
            //wtf is this?
            return NSNumberFormatter().numberFromString(display.text!)!.doubleValue
        }
        set {
            display.text = "\(newValue)"
            userIsInTheMiddleOfTypingANumber = false
        }
    }
    
    @IBAction func reset() {
        display.text = ""
        history.text = ""
        operandStack = Array<Double>()
    }
    
    @IBAction func appendDigit(sender: UIButton) {
        // read which button is pressed
        let digit = sender.currentTitle!
        
        if userIsInTheMiddleOfTypingANumber {
            // only one dot is added to the number
            if (display.text!.rangeOfString(".") == nil && digit == ".") || digit != "." {
                // append digits
                display.text = display.text! + digit
                history.text = history.text! + digit + " "
            }
        } else {
            display.text = digit
            userIsInTheMiddleOfTypingANumber = true
            history.text = clearHistory ? digit + " " : history.text! + digit
            clearHistory = false
        }
        //println("digit = \(digit)")
    }
    
    @IBAction func enter() {
        //if a number is entered, a new number will be added to the stack
        userIsInTheMiddleOfTypingANumber = false
        operandStack.append(displayValue)
        println("OperandStack = \(operandStack)")
        history.text = history.text!
    }

    
    @IBAction func operate(sender: UIButton) {
        let operation = sender.currentTitle!
        history.text = history.text! + " " + operation
        clearHistory = true
        if userIsInTheMiddleOfTypingANumber {
            enter()
        }
        
        switch operation {
            case "π":
                displayValue = pi3
                enter()
            case "cos": performOperationSingle {cos($0)}
            case "sin": performOperationSingle {sin($0)}
            case "√": performOperationSingle {sqrt($0)}
            case "÷": performOperation {$1 / $0} //if this is the only argument, no () needed
            case "−": performOperation(){$1 - $0} //if this is the last argument, it can be outside ()
            case "+": performOperation({$0 + $1}) //swift knows the input and output types
            case "×": performOperation {$0 * $1}
//            if operandStack.count >= 2 {
//                displayValue = operandStack.removeLast() * operandStack.removeLast()
//                enter()
//            }
            default:
                break
        }
    }
    
    func performOperation(operation: (Double, Double) -> Double) {
        if operandStack.count >= 2 {
            displayValue = operation(operandStack.removeLast(), operandStack.removeLast())
            enter()
        }
    }
    
    func performOperationSingle(operation: Double -> Double) {
        if operandStack.count >= 1 {
            displayValue = operation(operandStack.removeLast())
            enter()
        }
    }

//    func multiply(op1: Double, op2: Double) -> Double {
//        return op1 * op2
//    }
}

