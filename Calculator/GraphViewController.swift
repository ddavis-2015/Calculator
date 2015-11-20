//
//  GraphViewController.swift
//  Calculator
//
//  Created by David Davis on 11/19/15.
//  Copyright © 2015 David Davis. All rights reserved.
//

import UIKit


class GraphViewController: UIViewController, GraphViewDataSource
{
    @IBOutlet weak var graphView: GraphView!

    override func viewDidLoad()
    {
        super.viewDidLoad()
        graphView.dataSource = self

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.title = String(brain).componentsSeparatedByString(", ").last
    }

    private let brain = Brain()

    var program : Brain.PropertyList
    {
        set (newProgram)
        {
            brain.program = newProgram
        }
        get
        {
            return brain.program
        }
    }

    func xForY(x: Double) -> Double?
    {
        brain.userVars["M"] = x
        return brain.evaluate()
    }
}

