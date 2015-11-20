//
//  CalculatorViewController.swift
//  Calculator
//
//  Created by David Davis on 11/12/15.
//  Copyright © 2015 David Davis. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController
{

    @IBOutlet weak var displayLabel: UILabel!
    @IBOutlet weak var historyLabel: UILabel!

    let brain = Brain()

    var displayValue: Double?
    {
        get
        {
            return Double(displayLabel.text!)
        }
        set
        {
            if let value = newValue
            {
                let formatter = NSNumberFormatter()
                formatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
                formatter.maximumFractionDigits = 6
                displayLabel.text = formatter.stringFromNumber(value)
            }
            else
            {
                displayLabel.attributedText = NSAttributedString(string: "Error\t",
                    attributes:
                    [
                        NSFontAttributeName: displayLabel.font,
                        NSObliquenessAttributeName: NSNumber(double: 0.2)
                    ]
                )
            }
        }
    }

    var digitsHolder: String = ""

    @IBAction func functionPressed(sender: UIButton)
    {
        let operation: Brain.Operation

        switch sender.accessibilityLabel!
        {
        case "divide":
            operation = Brain.Operation.Divide
        case "multiply":
            operation = Brain.Operation.Multiply
        case "subtract":
            operation = Brain.Operation.Subtract
        case "add":
            operation = Brain.Operation.Add
        case "pi":
            operation = Brain.Operation.Pi
        case "negation":
            operation = Brain.Operation.Negation
        case "cosine":
            operation = Brain.Operation.Cosine
        case "sine":
            operation = Brain.Operation.Sine
        case "square root":
            operation = Brain.Operation.SquareRoot
        default:
            print("unknown function:", sender.accessibilityLabel)
            return
        }

        pushDigitsHolder()
        brain.pushOperation(operation)
        evaluate()
    }

    @IBAction func storeMemory()
    {
        if let value = displayValue
        {
            brain.userVars["M"] = value
            digitsHolder.removeAll()
            evaluate()
        }
    }

    @IBAction func pushMemory()
    {
        pushDigitsHolder()
        brain.pushOperand("M")
        digitsHolder.removeAll()
        evaluate()
    }

    func pushDigitsHolder()
    {
        if !digitsHolder.isEmpty
        {
            brain.pushOperand(Double(digitsHolder)!)
            digitsHolder.removeAll()
        }
    }

    func evaluate()
    {
        displayValue = brain.evaluate()
        historyLabel.text = String(brain) + " ="
    }

    func clearAll()
    {
        brain.popAll()
        brain.removeAllUserVars()
        displayValue = 0
        digitsHolder = "0"
        historyLabel.text = String(brain)
    }

    @IBAction func clearAllPressed()
    {
        clearAll()
    }

    @IBAction func deletePressed()
    {
        if !digitsHolder.isEmpty
        {
            digitsHolder.removeAtIndex(digitsHolder.endIndex.predecessor())
            if !digitsHolder.isEmpty
            {
                displayLabel.text = digitsHolder
            }
            else
            {
                displayValue = brain.evaluate()
            }
        }
        else
        {
            brain.popTop()
            evaluate()
        }
    }

    @IBAction func decimalPointPressed()
    {
        if digitsHolder.containsString(".")
        {
            return
        }
        digitsHolder += digitsHolder.isEmpty ? "0." : "."
        displayLabel.text = digitsHolder
    }

    @IBAction func enterPressed()
    {
        if let value = displayValue
        {
            if !digitsHolder.isEmpty || !brain.duplicateTop()
            {
                brain.pushOperand(value)
            }
            displayValue = value // normalize display
        }
        digitsHolder.removeAll()
        historyLabel.text = String(brain)
    }

    @IBAction func digitPressed(sender: UIButton)
    {
        let newDigit = String(sender.tag)
        if digitsHolder.characters.first == "0" && !digitsHolder.containsString(".")
        {
            digitsHolder.removeAll()
        }

        digitsHolder += newDigit
        displayLabel.text = digitsHolder
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        clearAll()
        loadProgram()
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private static let PROGRAM_KEY_NAME = "Program"

    private func loadProgram()
    {
        if let program = NSUserDefaults.standardUserDefaults().objectForKey(CalculatorViewController.PROGRAM_KEY_NAME)
        {
            brain.program = program
            evaluate()
            if displayValue != nil
            {
                digitsHolder.removeAll()
            }
        }
    }

    func saveProgram()
    {
        NSUserDefaults.standardUserDefaults().setObject(
            brain.program,
            forKey: CalculatorViewController.PROGRAM_KEY_NAME
        )
        assert(NSUserDefaults.standardUserDefaults().synchronize(), "NSUserDefaults synchronize failed")
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.identifier == "graph", let gvc = segue.destinationViewController as? GraphViewController
        {
            gvc.program = brain.program
        }
    }

    override func viewWillAppear(animated: Bool)
    {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
}


