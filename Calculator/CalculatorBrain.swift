//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by John Xu on 5/9/15.
//  Copyright (c) 2015 Liuxizi Xu. All rights reserved.
//

import Foundation

class CalculatorBrain {
    
    private let pi3 = M_PI
    
    private enum Op: Printable //printable is a protocal
    {
        case Operand(Double)
        case UnaryOperation(String, Double ->Double)
        case BinaryOperation(String, (Double, Double) ->Double)
        case PiValue (String, Double)
        case Variable(String)
        
        var description: String { //compute property (readonly)
            get {
                switch self {
                case .Operand(let operand):
                    return "\(operand)"
                case .PiValue(let symbol, _):
                    return symbol
                case .Variable(let symbol):
                    return symbol
                case .UnaryOperation(let symbol, _):
                    return symbol
                case .BinaryOperation(let symbol, _):
                    return symbol
                }
                
            }
        }
    }
    
    var description: String {
        let (result, reminder) = description(opStack)
//        println("\(opStack) = \(result) with \(reminder) left over")
        if result != nil {
            return result!
        } else {
            return "oooops"
        }
    }
    
    private func description(ops: [Op]) -> (result: String?, remainingOps: [Op]) {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            
            switch op {
            case .Operand(let operand):
                return ("\(operand)", remainingOps)
            case .PiValue(let symbol, _):
                return (symbol, remainingOps)
            case .Variable(let symbol):
                return (symbol, remainingOps)
                
            case .UnaryOperation(let operation, _):
                let opDescription = description(remainingOps)
                if let operand = opDescription.result {
                    return ("\(operation)(\(operand))", opDescription.remainingOps)
                } else {
                    return ("\(operation)(?)", opDescription.remainingOps)
                }
                
            case .BinaryOperation(let operation, _):
                // temp returning var
                var op1 = "?"
                var op2 = "?"
                var returningOps = remainingOps
                // check for first operand
                let op1Description = description(remainingOps)
                if let operand1 = op1Description.result {
                    // update returning var
                    returningOps = op1Description.remainingOps
                    op2 = operand1
                    // check for second operand
                    let op2Description = description(op1Description.remainingOps)
                    if let operand2 = op2Description.result {
                        // update returning var
                        returningOps = op2Description.remainingOps
                        op1 = operand2
                    }
                    // flip operands if its ÷ or -
//                    if operation == "÷" || operation == "−" {
//                        var temp = op1
//                        op1 = op2
//                        op2 = temp
//                    }
                }
                return ("(\(op1)" + "\(operation)" + "\(op2))", returningOps)
            }
            
        }
        return (nil, ops)
    }
    
    private var opStack = Array<Op>()   //[Op]()
    private var knownOps = Dictionary<String, Op>() //[String:Op]()
    var varibaleValues = [String: Double]()
    
    init (){
        func learnOp(op: Op) {knownOps[op.description] = op}
        learnOp(Op.BinaryOperation("×", *))
        //        knownOps["×"] = Op.BinaryOperation("×", *)
        knownOps["÷"] = Op.BinaryOperation("÷") {$1 / $0}
        knownOps["−"] = Op.BinaryOperation("−") {$1 - $0}
        knownOps["+"] = Op.BinaryOperation("+", +)
        knownOps["√"] = Op.UnaryOperation("√", sqrt)
        knownOps["cos"] = Op.UnaryOperation("cos", cos)
        knownOps["sin"] = Op.UnaryOperation("sin", sin)
        knownOps["π"] = Op.PiValue("π", pi3)
    }
    
    // return tuple (result, the rest of opStack)
    private func evaluate(ops: [Op]) -> (result: Double?, remainingOps: [Op]) {
        // this is a recursive function
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            
            switch op {
            case .Operand(let operand): // let Operand in op equal operand
                return (operand, remainingOps)
                
            case .UnaryOperation(_, let operation): //refer operation within the case
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result {
                    return (operation(operand), operandEvaluation.remainingOps)
                }
                
            case .BinaryOperation(_, let operation):
                let op1Evaluation = evaluate(remainingOps)
                if let operand1 = op1Evaluation.result {
                    let op2Evaluation = evaluate(op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result {
                        return (operation(operand1, operand2), op2Evaluation.remainingOps)
                    }
                }
                
            case .PiValue(_, let value):
                return (value, remainingOps)
                
            case .Variable(let symbol):
                var temp_operand = varibaleValues[symbol]
                return (temp_operand, remainingOps)
            }
            //all cases are handled, so default is not needed
        }
        //failure case
        return (nil, ops)
    }
    
    // return needs to be double optional, because operation may not have any operend at the beginning
    func evaluate() -> Double? {
        let (result, reminder) = evaluate(opStack)  // let a tuple be a result instead of a tuple var
//        println("\(opStack) = \(result) with \(reminder) left over")
        return result
    }
    
    func pushOperand(operand: Double) -> Double? {
        opStack.append(Op.Operand(operand))
        return evaluate()
    }
    
    func performOperation(symbol: String) -> Double? {
        // operation may not be in the knownOps, since the symbol key does not exisit
        if let operation = knownOps[symbol]{
            opStack.append(operation)
        }
        return evaluate()
    }
    
    func pushOperand(symbol:String) -> Double? {
        opStack.append(Op.Variable(symbol))
        return evaluate()
    }
}