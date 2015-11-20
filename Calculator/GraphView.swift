//
//  GraphView.swift
//  Calculator
//
//  Created by David Davis on 11/19/15.
//  Copyright © 2015 David Davis. All rights reserved.
//

import UIKit



protocol GraphViewDataSource
{
    func xForY(x: Double) -> Double?
}

@IBDesignable
class GraphView: UIView
{
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect)
    {
        // Drawing code
        super.drawRect(rect)
    }

    @IBInspectable
    var scale : Double = 1.0

    var dataSource : GraphViewDataSource?
}

