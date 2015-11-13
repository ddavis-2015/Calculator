//
//  Brain.swift
//  Calculator
//
//  Created by David Davis on 11/12/15.
//  Copyright © 2015 David Davis. All rights reserved.
//

import Foundation


class Brain
{
    enum Operation : CustomStringConvertible
    {
        case Multiply
        case Divide
        case Add
        case Subtract
        case SquareRoot

        var description : String
        {
            switch self
            {
            case .Multiply:
                return "×"
            case .Divide:
                return "÷"
            case .Add:
                return "+"
            case .Subtract:
                return "−"
            case .SquareRoot:
                return "√"
            }
        }
    }

    private enum StackOp : CustomStringConvertible
    {
        case Binary(Operation, (Double, Double) -> Double)
        case Unary(Operation, (Double) -> Double)
        case Operand(Double)

        func operation() -> Operation?
        {
            switch self
            {
            case .Operand(_):
                return nil
            case .Binary(let operation, _):
                return operation
            case .Unary(let operation, _):
                return operation
            }
        }

        var description : String
        {
            switch self
            {
            case .Operand(let operand):
                return String(operand)
            case.Binary(let operation, _):
                return String(operation)
            case .Unary(let operation, _):
                return String(operation)
            }
        }
    }

    private var opStack = [StackOp]()
    private var knownOps = [Operation : StackOp]()

    init()
    {
        func addOp(op: StackOp)
        {
            self.knownOps[op.operation()!] = op
        }

        addOp(.Binary(.Multiply, { $0 * $1 } ))
        addOp(.Binary(.Divide, { $1 / $0 } ))
        addOp(.Binary(.Add, { $0 + $1 } ))
        addOp(.Binary(.Subtract, { $1 - $0 } ))
        addOp(.Unary(.SquareRoot, sqrt))
    }

    private func showStack()
    {
        print("stack:", opStack)
    }

    private func evaluate(var stack: [StackOp]) -> (value: Double, stack: [StackOp])?
    {
        guard let op = stack.popLast() else
        {
            return nil
        }

        switch op
        {
        case .Operand(let operand):
            return (operand, stack)
        case .Unary(_, let functor):
            if let (operand, stack) = evaluate(stack)
            {
                return (functor(operand), stack)
            }
        case .Binary(_, let functor):
            if let (leftOperand, stack1) = evaluate(stack), (rightOperand, stack2) = evaluate(stack1)
            {
                return (functor(leftOperand, rightOperand), stack2)
            }
        }

        return nil
    }

    func evaluate() -> Double?
    {
        let result = evaluate(opStack)
        opStack = result?.stack ?? opStack
        print("result:", result?.value ?? " Error")
        showStack()
        return result?.value
    }

    func pushOperation(operation: Operation)
    {
        if let newOp = knownOps[operation]
        {
            opStack.append(newOp)
        }
        showStack()
    }

    func pushOperand(operand: Double)
    {
        opStack.append(.Operand(operand))
        showStack()
    }

    func clear()
    {
        opStack.removeAll()
        showStack()
    }
}
