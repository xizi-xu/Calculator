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
//    var operandStack = Array<Double>()
//    let pi3 = M_PI
//    var performed = false
    var clearHistory = false
    
    var brain = CalculatorBrain()
    
    //computed property
    var displayValue: Double? {
        get {
            // check if display.text is nil
            if let temp = NSNumberFormatter().numberFromString(display.text!) {
                return temp.doubleValue
            } else {
                return nil
            }
            // return NSNumberFormatter().numberFromString(display.text!)!.doubleValue
        }
        set {
            display.text = "\(newValue!)"
            userIsInTheMiddleOfTypingANumber = false
        }
    }
    
    @IBAction func reset() {
//        display.text = "0"
        displayValue = 0
        history.text = ""
//        operandStack = Array<Double>()
        brain = CalculatorBrain()
    }
    
    @IBAction func backspace() {
        if userIsInTheMiddleOfTypingANumber {
            if (display.text != nil || display.text! != "") {
                display.text = display.text!.substringToIndex(display.text!.endIndex.predecessor())
                if display.text! == "" {
                    display.text! = "0"
                    userIsInTheMiddleOfTypingANumber = false
                }
            }
        }
    }
    
    @IBAction func signReverse() {
        if displayValue != nil {
            if userIsInTheMiddleOfTypingANumber {
                display.text = "-" + display.text!
            } else {
                displayValue = -1 * displayValue!
            }
        }
    }
    
    @IBAction func appendDigit(sender: UIButton) {
        // read which button is pressed
        let digit = sender.currentTitle!
        
        if userIsInTheMiddleOfTypingANumber {
            // only one dot is added to the number
            if (display.text!.rangeOfString(".") == nil && digit == ".") || digit != "." {
                // append digits
                display.text = display.text! + digit
            }
        } else {
            display.text = digit
            userIsInTheMiddleOfTypingANumber = true
            history.text = clearHistory ? "" : history.text!
            clearHistory = false
        }
    }
    
    @IBAction func enter() {
        //if a number is entered, a new number will be added to the stack
//        if displayValue != nil {
//            operandStack.append(displayValue!)
//            println("OperandStack = \(operandStack)")
//            userIsInTheMiddleOfTypingANumber = false
        
//            history.text = history.text! + display.text! + " "
//            
//            if performed {
//                history.text = history.text! + " = "
//                performed = false
//            }
//
//        }
        
        if displayValue != nil {
            history.text = history.text! + display.text! + " "
            
            userIsInTheMiddleOfTypingANumber = false
            if let result = brain.pushOperand(displayValue!) {
                displayValue = result
            } else {
                displayValue = 0
            }
        }
    }
    
    
    @IBAction func operate(sender: UIButton) {
        if userIsInTheMiddleOfTypingANumber {
            enter()
        }
        
        if let operation = sender.currentTitle {
            if let result = brain.performOperation(operation) {
                displayValue = result
                history.text = history.text! + operation + " "
                if operation != "π" {
                    history.text = history.text! + "= "
                    clearHistory = true
                }
                else {
                    clearHistory = false
                }
            } else {
                displayValue = 0
                history.text = ""
            }
        }
        
//        if operation != "π" {
//            history.text = history.text! + " " + operation
//            clearHistory = true
//        }
        
//        switch operation {
//        case "π":
//            displayValue = pi3
//            enter()
//        case "cos":performOperationSingle {cos($0)}
//        case "sin":performOperationSingle {sin($0)}
//        case "√": performOperationSingle {sqrt($0)}
//            
//        case "÷": performOperation {$1 / $0} //if this is the only argument, no () needed
//        case "−": performOperation(){$1 - $0} //if this is the last argument, it can be outside ()
//        case "+": performOperation({$0 + $1}) //swift knows the input and output types
//        case "×": performOperation {$0 * $1}
//        default:
//            break
//        }
//    }
//    
//    func performOperation(operation: (Double, Double) -> Double) {
//        if operandStack.count >= 2 {
//            displayValue = operation(operandStack.removeLast(), operandStack.removeLast())
//            performed = true
//            enter()
//        }
//    }
//    
//    func performOperationSingle(operation: Double -> Double) {
//        if operandStack.count >= 1 {
//            displayValue = operation(operandStack.removeLast())
//            performed = true
//            enter()
//        }
//    }
    }
}

