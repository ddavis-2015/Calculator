//
//  Brain.swift
//  Calculator
//
//  Created by David Davis on 11/12/15.
//  Copyright © 2015 David Davis. All rights reserved.
//

import Foundation


private func < (lhs: Brain.StackOp.Precedence, rhs: Brain.StackOp.Precedence) -> Bool
{
    return lhs.value < rhs.value
}

private func <= (lhs: Brain.StackOp.Precedence, rhs: Brain.StackOp.Precedence) -> Bool
{
    return lhs.value <= rhs.value
}

infix operator <!= {}
private func <!= (lhs: Brain.StackOp.Precedence, rhs: Brain.StackOp.Precedence) -> Bool
{
    if case .Binary(let lhsValue) = lhs, .Binary(let rhsValue) = rhs where lhsValue != rhsValue
    {
        return true
    }
    else
    {
        return false
    }
}


class Brain : CustomStringConvertible
{
    enum Operation : CustomStringConvertible
    {
        case Multiply
        case Divide
        case Add
        case Subtract
        case SquareRoot
        case Cosine
        case Sine
        case Pi
        case Negation

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
            case .Cosine:
                return "cos"
            case .Sine:
                return "sin"
            case .Pi:
                return "π"
            case .Negation:
                return "-"
            }
        }
    }

    private enum StackOp : CustomStringConvertible
    {
        case Binary(Operation, (Double, Double) -> Double)
        case Unary(Operation, (Double) -> Double)
        case Operand(Double)
        case Variable(String)
        case Constant(Operation, Double)

        func operation() -> Operation?
        {
            switch self
            {
            case .Constant(let operation, _):
                return operation
            case .Binary(let operation, _):
                return operation
            case .Unary(let operation, _):
                return operation
            default:
                return nil
            }
        }

        var description : String
        {
            switch self
            {
            case .Operand(let operand):
                return String(operand)
            case .Constant(let operation, _):
                return String(operation)
            case.Binary(let operation, _):
                return String(operation)
            case .Unary(let operation, _):
                return String(operation)
            case .Variable(let name):
                return name
            }
        }

        enum Precedence
        {
            case Operand(Int)
            case Constant(Int)
            case Unary(Int)
            case Binary(Int)
            case Variable(Int)

            var value: Int
            {
                switch self
                {
                case .Binary(let value):
                    return value
                case .Constant(let value):
                    return value
                case .Operand(let value):
                    return value
                case .Unary(let value):
                    return value
                case .Variable(let value):
                    return value
                }
            }
        }

        var precedence: Precedence
        {
            switch self
            {
            case .Operand:
                return Precedence.Operand(70)
            case .Constant:
                return Precedence.Constant(70)
            case .Variable:
                return Precedence.Variable(70)
            case .Unary(let operation, _) where operation == .Negation:
                return Precedence.Unary(60)
            case .Unary:
                return Precedence.Unary(100)
            case .Binary(let operation, _) where [.Add, .Subtract].contains(operation):
                return Precedence.Binary(40)
            case .Binary(let operation, _) where [.Multiply, .Divide].contains(operation):
                return Precedence.Binary(50)
            default:
                return Precedence.Operand(0)
            }
        }
    }

    private var opStack = [StackOp]()
    private var knownOps = [Operation : StackOp]()
    var userVars = [String: Double]()

    init()
    {
        func addOp(op: StackOp)
        {
            self.knownOps[op.operation()!] = op
        }

        addOp(.Binary(.Multiply, *))
        addOp(.Binary(.Divide, /))
        addOp(.Binary(.Add, +))
        addOp(.Binary(.Subtract, -))
        addOp(.Unary(.SquareRoot, sqrt))
        addOp(.Unary(.Cosine, cos))
        addOp(.Unary(.Sine, sin))
        addOp(.Constant(.Pi, M_PI))
        addOp(.Unary(.Negation, { -$0 } ))
    }

    private func showStack()
    {
        //print("stack:", opStack)
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
        case .Constant(_, let constant):
            return (constant, stack)
        case .Unary(_, let functor):
            if let (operand, stack) = evaluate(stack)
            {
                return (functor(operand), stack)
            }
        case .Binary(_, let functor):
            if let (rightOperand, stack1) = evaluate(stack), (leftOperand, stack2) = evaluate(stack1)
            {
                return (functor(leftOperand, rightOperand), stack2)
            }
        case .Variable(let name):
            if let value = userVars[name]
            {
                return (value, stack)
            }
        }

        return nil
    }

    private lazy var formatter : NSNumberFormatter =
    {
        let f = NSNumberFormatter()
        f.numberStyle = NSNumberFormatterStyle.DecimalStyle
        f.maximumFractionDigits = 6
        return f
    }()

    private func evaluate2(var stack: [StackOp]) -> (expr: String, stack: [StackOp], precedence: StackOp.Precedence)
    {

        guard let op = stack.popLast() else
        {
            return ("?", stack, StackOp.Precedence.Operand(0))
        }

        switch op
        {
        case .Operand(let operand):
            return (formatter.stringFromNumber(operand)!, stack, op.precedence)

        case .Constant(let operation, _):
            return (String(operation), stack, op.precedence)

        case .Unary(let operation, _):
            var (expr, stack, operandPrecedence) = evaluate2(stack)
            let precedence = op.precedence
            if operandPrecedence <= precedence
            {
                expr = "(" + expr + ")"
            }
            return (String(operation) + expr, stack, precedence)

        case .Binary(let operation, _):
            var (rightOperand, stack1, rightPrecedence) = evaluate2(stack)
            var (leftOperand, stack2, leftPrecedence) = evaluate2(stack1)
            let precedence = op.precedence
            if rightPrecedence <!= precedence
            {
                rightOperand = "(" + rightOperand + ")"
            }
            if leftPrecedence <!= precedence
            {
                leftOperand = "(" + leftOperand + ")"
            }
            let expr = [leftOperand, String(operation), rightOperand].joinWithSeparator(" ")
            return (expr, stack2, precedence)

        case .Variable(let name):
            return (name, stack, op.precedence)
        }
    }

    func evaluate() -> Double?
    {
        let result = evaluate(opStack)
        //print("result:", result?.value ?? "Error")
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

    func pushOperand(operand: String)
    {
        opStack.append(.Variable(operand))
        showStack()
    }

    func duplicateTop() -> Bool
    {
        guard let op = opStack.last else
        {
            return false
        }

        switch op
        {
        case .Operand(_), .Constant(_, _):
            opStack.append(op)
            showStack()
            return true
        default:
            return false
        }
    }

    func popTop()
    {
        opStack.popLast()
        showStack()
    }

    func popAll()
    {
        opStack.removeAll()
        showStack()
    }

    func removeAllUserVars()
    {
        userVars.removeAll()
    }

    var description : String
    {
        var (result, stack, _) = evaluate2(opStack)

        while !stack.isEmpty
        {
            let (expr, stack1, _) = evaluate2(stack)
            stack = stack1
            result = expr + ", " + result
        }

        return result
    }

    typealias PropertyList = AnyObject
    private static let userVarsName = "userVariables"
    private static let stackName = "stack"
    private static let variableName = "Variable"
    private static let operandName = "Operand"
    private static let operationName = "Operation"
    private static let operationNames: [Operation : String] =
    [
        Operation.Negation: "Negation",
        Operation.Add: "Addition",
        Operation.Subtract: "Subtraction",
        Operation.Divide: "Division",
        Operation.Multiply: "Multiplication",
        Operation.Cosine: "Cosine",
        Operation.Sine: "Sine",
        Operation.Pi: "Pi",
        Operation.SquareRoot: "Square Root",
    ]

    var program: PropertyList
    {
        get
        {
            let propList = NSMutableDictionary()
            propList.setObject(userVars, forKey: Brain.userVarsName)

            let stack = NSMutableArray()
            for op in opStack
            {
                switch op
                {
                case .Operand(let value):
                    stack.addObject([Brain.operandName : String(value)])
                case .Variable(let name):
                    stack.addObject([Brain.variableName : name])
                default:
                    if let operation = op.operation(), name = Brain.operationNames[operation]
                    {
                        stack.addObject([Brain.operationName : name])
                    }
                    else
                    {
                        print("program: unknown StackOp:", String(op))
                    }
                }
            }
            propList.setObject(stack, forKey: Brain.stackName)

            return propList
        }

        set (pList)
        {
            guard let propList = pList as? NSDictionary else
            {
                print("program: not a PropertyList: \(pList)")
                return
            }
            guard let vars = propList[Brain.userVarsName] as? [String : Double] else
            {
                print("program: invalid property \(Brain.userVarsName): \(propList[Brain.userVarsName])")
                return
            }
            guard let stack = propList[Brain.stackName] as? [[String : String]] else
            {
                print("program: invalid property \(Brain.stackName): \(propList[Brain.stackName])")
                return
            }

            var newStack = [StackOp]()

            for dict in stack
            {
                for (key, value) in dict
                {
                    switch key
                    {
                    case Brain.variableName:
                        newStack.append(StackOp.Variable(value))
                    case Brain.operandName:
                        if let newValue = Double(value)
                        {
                            newStack.append(StackOp.Operand(newValue))
                        }
                        else
                        {
                            print("program: bad operand value: \(value)")
                            return
                        }
                    case Brain.operationName:
                        if !Brain.operationNames.values.contains(value)
                        {
                            print("program: bad operation value: \(value)")
                            return
                        }
                        for (operation, name) in Brain.operationNames where name == value
                        {
                            if let op = knownOps[operation]
                            {
                                newStack.append(op)
                                break
                            }
                            else
                            {
                                print("program: unknown stackOp: \(String(operation))")
                                return
                            }
                        }
                    default:
                        print("program: unknown op: \(dict)")
                        return
                    }

                    break
                }
            }

            userVars = vars
            opStack = newStack
        }
    }
}

