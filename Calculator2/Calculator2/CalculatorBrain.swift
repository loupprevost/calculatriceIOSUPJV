//
//  CalculatorBrain.swift
//  calculator
//
//  Created by William on 12/10/2023.
//

import Foundation

struct CalculatorBrain {
    private var accumulator: Double?

    var result: Double? {
        get {
            if (pbo?.result != nil) {
                return pbo?.result
            }
            return accumulator
        }
    }
    
    public enum Operations {
        case constant(Double)
        case unaryOperation((Double) -> Double)
        case binaryOperations((Double, Double) -> Double)
        case equal
    }
    
    public var operations: Dictionary<String, Operations> = [
        "π": Operations.constant(Double.pi),
        "√": Operations.unaryOperation(sqrt),
        "cos": Operations.unaryOperation(cos),
        "±": Operations.unaryOperation({-$0}),
        "+": Operations.binaryOperations({$0 + $1}),
        "-": Operations.binaryOperations({$0 - $1}),
        "*": Operations.binaryOperations({$0 * $1}),
        "/": Operations.binaryOperations({$0 / $1}),
        "=": Operations.equal,
    ]
    
    private struct PendingBinaryOperation {
        let function: (Double, Double) -> Double
        let firstOperand: Double
        func perform(with secondOperand: Double) -> Double {
            return function(firstOperand, secondOperand)
        }
        var result: Double?
    }

    private var pbo: PendingBinaryOperation?
    
    mutating func performOperation(_ symbol: String) {
        if let operation = operations[symbol] {
            switch operation {
            case .constant(let value):
                accumulator = value
                break
            case .unaryOperation(let function):
                if accumulator != nil {
                    accumulator = function(accumulator!)
                }
                break
            case .binaryOperations(let function):
                if (pbo?.result != nil) {
                    accumulator = pbo?.result
                    pbo = nil
                }
                if pbo != nil && accumulator != nil {
                    accumulator = pbo?.perform(with: accumulator!)
                }
                if accumulator != nil {
                    pbo = PendingBinaryOperation(function: function, firstOperand: accumulator!)
                    accumulator = nil
                }
                break
            case .equal:
                if pbo != nil && accumulator != nil {
                    let result = pbo?.perform(with: accumulator!)
                    pbo = PendingBinaryOperation(function: pbo!.function, firstOperand: result!, result: result!)
                    //accumulator = pbo?.perform(with: accumulator!)
                }
                break
            }
        }
    }
    
    mutating func setOperand(_ operand: Double) {
            accumulator = operand
    }
    
    mutating func clear() {
        accumulator = nil
        pbo = nil
    }
}
