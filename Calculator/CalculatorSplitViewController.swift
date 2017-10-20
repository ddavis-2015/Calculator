//
//  CalculatorSplitViewController.swift
//  Calculator
//
//  Created by David Davis on 11/19/15.
//  Copyright © 2015 David Davis. All rights reserved.
//

import UIKit

class CalculatorSplitViewController: UISplitViewController, UISplitViewControllerDelegate
{

    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.delegate = self

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController, ontoPrimaryViewController primaryViewController: UIViewController) -> Bool
    {
        if splitViewController.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClass.compact
        {
            return true
        }
        else
        {
            return false
        }
    }
}
