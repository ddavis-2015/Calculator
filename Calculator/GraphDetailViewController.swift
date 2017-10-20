//
//  GraphDetailViewController.swift
//  Calculator
//
//  Created by David Davis on 11/22/15.
//  Copyright © 2015 David Davis. All rights reserved.
//

import UIKit

class GraphDetailViewController: UIViewController
{

    @IBOutlet weak var label: UILabel!

    var scaleRect : CGRect = CGRect.zero
    var majorDivisionScale : Double = 0
    var minorDivisionScale : Double = 0

    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool)
    {
        var str : String = ""
        str = str.appendingFormat("Scale X: %+8.2f to %+8.2f\n", scaleRect.minX, scaleRect.maxX)
        str = str.appendingFormat("Scale Y: %+8.2f to %+8.2f\n", scaleRect.minY, scaleRect.maxY)
        str += "\n"
        str = str.appendingFormat("Units/Major Div.: %6.2f\n", majorDivisionScale)
        str = str.appendingFormat("Units/Minor Div.: %6.2f", minorDivisionScale)
        label.text = str
        label.sizeToFit()
        preferredContentSize = CGSize(width: label.bounds.width + 10, height: label.bounds.height + 10)
    }
}
