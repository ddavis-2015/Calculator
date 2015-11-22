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
    func yForX(x: Double) -> Double?
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

        var scaleRect : CGRect
        if bounds.width > bounds.height
        {
            let ratio = bounds.width / bounds.height
            scaleRect = CGRectMake(-scale * ratio, -scale, scale * 2 * ratio, scale * 2)
            scaleRect.offsetInPlace(dx: -origin.x * ratio, dy: -origin.y)
        }
        else
        {
            let ratio = bounds.height / bounds.width
            scaleRect = CGRectMake(-scale, -scale * ratio, scale * 2, scale * 2 * ratio)
            scaleRect.offsetInPlace(dx: -origin.x, dy: -origin.y * ratio)
        }
        let xIncr = scaleRect.width / bounds.width
        let yIncr = scaleRect.height / bounds.height

        var originInView = CGPointMake(origin.x / xIncr, origin.y / yIncr)
        originInView.x += bounds.midX
        originInView.y += bounds.midY
        drawAxes(originInViewCoords: originInView)

        if nil == dataSource
        {
            return
        }

        let bp = UIBezierPath()
        var startOfLine = true
        for var x = scaleRect.minX; x < scaleRect.maxX + xIncr; x += xIncr
        {
            if let y = dataSource!.yForX(Double(x)) where y.isNormal || y.isZero
            {
                let viewX = (x / xIncr) + originInView.x
                let viewY = (CGFloat(-y) / yIncr) + originInView.y
                let p = CGPointMake(viewX, viewY)

                if startOfLine
                {
                    bp.moveToPoint(p)
                    startOfLine = false
                }
                else
                {
                    bp.addLineToPoint(p)
                }
            }
            else
            {
                startOfLine = true
            }
        }

        bp.lineWidth = 3
        bp.stroke()
    }

    // scale is in the infinite coordinate space
    @IBInspectable
    var scale : CGFloat = 3.0
    {
        didSet
        {
            if scale < 1
            {
                scale = 1
            }
            else if scale > 100
            {
                scale = 100
            }
            setNeedsDisplay()
        }
    }

    // origin is in the infinite coordinate space
    var origin : CGPoint = CGPointZero
    {
        didSet
        {
            setNeedsDisplay()
        }
    }

    @IBInspectable
    var majorDivisions : UInt = 0
    {
        didSet
        {
            if (majorDivisions & 1) == 0
            {
                majorDivisions++
            }
            setNeedsDisplay()
        }
    }

    @IBInspectable
    var minorDivisions : UInt = 0
    {
        didSet
        {
            setNeedsDisplay()
        }
    }

    var dataSource : GraphViewDataSource?

    func drawAxes(originInViewCoords origin: CGPoint)
    {
        let bp = UIBezierPath()

        let majorDivIncr : CGFloat
        let minorDivIncr : CGFloat

        if bounds.height > bounds.width
        {
            majorDivIncr = bounds.width / CGFloat(majorDivisions + 1)
        }
        else
        {
            majorDivIncr = bounds.height / CGFloat(majorDivisions + 1)
        }
        minorDivIncr = majorDivIncr / CGFloat(minorDivisions + 1)

        let hOffset = fabs(bounds.minX - origin.x)
        let hStart : CGFloat
        if bounds.minX < origin.x
        {
            hStart = origin.x - (ceil(hOffset / majorDivIncr) * majorDivIncr)
        }
        else
        {
            hStart = origin.x + (floor(hOffset / majorDivIncr) * majorDivIncr)
        }

        let vOffset = fabs(bounds.minY - origin.y)
        let vStart : CGFloat
        if bounds.minY < origin.y
        {
            vStart = origin.y - (ceil(vOffset / majorDivIncr) * majorDivIncr)
        }
        else
        {
            vStart = origin.y + (floor(vOffset / majorDivIncr) * majorDivIncr)
        }

        // path horizontal axis
        bp.moveToPoint(CGPointMake(hStart, origin.y))
        bp.addLineToPoint(CGPointMake(bounds.maxX, origin.y))
        // path vertical axis
        bp.moveToPoint(CGPointMake(origin.x, vStart))
        bp.addLineToPoint(CGPointMake(origin.x, bounds.maxY))

        let lineWidth : CGFloat = 1
        let majorDivLineLength = 10 + lineWidth
        let minorDivLineLength = 4 + lineWidth
        var majorDivPoint : CGPoint
        var minorDivPoint : CGPoint

        // path major/minor horizontal divisions
        majorDivPoint = CGPointMake(hStart, origin.y - (majorDivLineLength / 2))
        minorDivPoint = CGPointMake(hStart + minorDivIncr, origin.y - (minorDivLineLength / 2))
        while majorDivPoint.x <= bounds.maxX
        {
            bp.moveToPoint(majorDivPoint)
            bp.addLineToPoint(CGPointMake(majorDivPoint.x, majorDivPoint.y + majorDivLineLength))

            for var index : UInt = 0; index < minorDivisions; index++
            {
                bp.moveToPoint(minorDivPoint)
                bp.addLineToPoint(CGPointMake(minorDivPoint.x, minorDivPoint.y + minorDivLineLength))
                minorDivPoint.x += minorDivIncr
            }
            majorDivPoint.x += majorDivIncr
            minorDivPoint.x = majorDivPoint.x + minorDivIncr
        }

        // path major/minor vertical divisions
        majorDivPoint = CGPointMake(origin.x - (majorDivLineLength / 2), vStart)
        minorDivPoint = CGPointMake(origin.x - (minorDivLineLength / 2), vStart + minorDivIncr)
        while majorDivPoint.y <= bounds.maxY
        {
            bp.moveToPoint(majorDivPoint)
            bp.addLineToPoint(CGPointMake(majorDivPoint.x + majorDivLineLength, majorDivPoint.y))

            for var index : UInt = 0; index < minorDivisions; index++
            {
                bp.moveToPoint(minorDivPoint)
                bp.addLineToPoint(CGPointMake(minorDivPoint.x + minorDivLineLength, minorDivPoint.y))
                minorDivPoint.y += minorDivIncr
            }
            majorDivPoint.y += majorDivIncr
            minorDivPoint.y = majorDivPoint.y + minorDivIncr
        }

        bp.lineWidth = lineWidth
        bp.stroke()
    }
}

