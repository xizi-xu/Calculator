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
        
        var description: String { //compute property (readonly)
            get {
                switch self {
                case .Operand(let operand):
                    return "\(operand)"
                case .UnaryOperation(let symbol, _):
                    return symbol
                case .BinaryOperation(let symbol, _):
                    return symbol
                case .PiValue(let symbol, _):
                    return symbol
                }
            }
        }
    }
    
    private var opStack = Array<Op>()   //[Op]()
    private var knownOps = Dictionary<String, Op>() //[String:Op]()
    
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
                
            case .PiValue(_, let pi3):
                return (pi3, remainingOps)
            }
            //all cases are handled, so default is not needed
        }
        //failure case
        return (nil, ops)
    }
    
    // return needs to be double optional, because operation may not have any operend at the beginning
    func evaluate() -> Double? {
        let (result, reminder) = evaluate(opStack)  // let a tuple be a result instead of a tuple var
        println("\(opStack) = \(result) with \(reminder) left over")
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
    
}