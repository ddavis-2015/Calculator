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
    override func draw(_ rect: CGRect)
    {
        // Drawing code
        super.draw(rect)

        let xIncr = scaleRect.width / bounds.width
        let yIncr = scaleRect.height / bounds.height

        var originInView = CGPoint(x: origin.x / xIncr, y: origin.y / yIncr)
        originInView.x += bounds.midX
        originInView.y += bounds.midY
        drawAxes(originInViewCoords: originInView)

        if nil == dataSource
        {
            return
        }

        let bp = UIBezierPath()
        var startOfLine = true
        let minX = bounds.minX
        let maxX = bounds.maxX
        
        for viewX in stride(from: minX, through: maxX, by: 1 / (self.contentScaleFactor * 2))
        //for var viewX = minX; viewX <= maxX; viewX += 1 / (contentScaleFactor * 2)
        {
            let x = (viewX - originInView.x) * xIncr
            if let y = dataSource!.yForX(x: Double(x)), y.isNormal || y.isZero
            {
                let viewY = (CGFloat(-y) / yIncr) + originInView.y
                let p = CGPoint(x: viewX, y: viewY)

                if startOfLine
                {
                    bp.move(to: p)
                    startOfLine = false
                }
                else
                {
                    bp.addLine(to: p)
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

    // scaleRect is in the infinite coordinate space
    var scaleRect : CGRect
    {
        get
        {
            var rect : CGRect
            if bounds.width > bounds.height
            {
                let ratio = bounds.width / bounds.height
                rect = CGRect(x: -scale * ratio, y: -scale, width: scale * 2 * ratio, height: scale * 2)
                rect = rect.offsetBy(dx: -origin.x, dy: -origin.y)
            }
            else
            {
                let ratio = bounds.height / bounds.width
                rect = CGRect(x: -scale, y: -scale * ratio, width: scale * 2, height: scale * 2 * ratio)
                rect = rect.offsetBy(dx: -origin.x, dy: -origin.y)
            }
            return rect
        }
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
    var origin : CGPoint = CGPoint.zero
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
                majorDivisions += 1
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

    // majorDivisionScale is in the infinite coordinate space
    var majorDivisionScale : CGFloat
    {
        get
        {
            if bounds.height > bounds.width
            {
                return scaleRect.width / CGFloat(majorDivisions + 1)
            }
            else
            {
                return scaleRect.height / CGFloat(majorDivisions + 1)
            }
        }
    }

    // minorDivisionScale is in the infinite coordinate space
    var minorDivisionScale : CGFloat
    {
        get
        {
            return majorDivisionScale / CGFloat(minorDivisions + 1)
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
        bp.move(to: CGPoint(x: hStart, y: origin.y))
        bp.addLine(to: CGPoint(x: bounds.maxX, y: origin.y))
        // path vertical axis
        bp.move(to: CGPoint(x: origin.x, y: vStart))
        bp.addLine(to: CGPoint(x: origin.x, y: bounds.maxY))

        let lineWidth : CGFloat = 1
        let majorDivLineLength = 10 + lineWidth
        let minorDivLineLength = 4 + lineWidth
        var majorDivPoint : CGPoint
        var minorDivPoint : CGPoint

        // path major/minor horizontal divisions
        majorDivPoint = CGPoint(x: hStart, y: origin.y - (majorDivLineLength / 2))
        minorDivPoint = CGPoint(x: hStart + minorDivIncr, y: origin.y - (minorDivLineLength / 2))
        while majorDivPoint.x <= bounds.maxX
        {
            bp.move(to: majorDivPoint)
            bp.addLine(to: CGPoint(x: majorDivPoint.x, y: majorDivPoint.y + majorDivLineLength))

            for _ in 0 ..< minorDivisions
            //for var index : UInt = 0; index < minorDivisions; index++
            {
                bp.move(to: minorDivPoint)
                bp.addLine(to: CGPoint(x: minorDivPoint.x, y: minorDivPoint.y + minorDivLineLength))
                minorDivPoint.x += minorDivIncr
            }
            majorDivPoint.x += majorDivIncr
            minorDivPoint.x = majorDivPoint.x + minorDivIncr
        }

        // path major/minor vertical divisions
        majorDivPoint = CGPoint(x: origin.x - (majorDivLineLength / 2), y: vStart)
        minorDivPoint = CGPoint(x: origin.x - (minorDivLineLength / 2), y: vStart + minorDivIncr)
        while majorDivPoint.y <= bounds.maxY
        {
            bp.move(to: majorDivPoint)
            bp.addLine(to: CGPoint(x: majorDivPoint.x + majorDivLineLength, y: majorDivPoint.y))

            for _ in 0 ..< minorDivisions
            {
                bp.move(to: minorDivPoint)
                bp.addLine(to: CGPoint(x: minorDivPoint.x + minorDivLineLength, y: minorDivPoint.y))
                minorDivPoint.y += minorDivIncr
            }
            majorDivPoint.y += majorDivIncr
            minorDivPoint.y = majorDivPoint.y + minorDivIncr
        }

        bp.lineWidth = lineWidth
        bp.stroke()
    }
}

