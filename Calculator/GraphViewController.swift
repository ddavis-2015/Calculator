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
        graphView.scale = 4
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

    func yForX(x: Double) -> Double?
    {
        return brain.evaluate(x)
    }

    private var scaleVector : CGVector
    {
        let xRatio : CGFloat
        let yRatio : CGFloat
        if graphView.bounds.width < graphView.bounds.height
        {
            xRatio = 1.0
            yRatio = graphView.bounds.height / graphView.bounds.width
        }
        else
        {
            xRatio = graphView.bounds.width / graphView.bounds.height
            yRatio = 1.0
        }
        let dx = graphView.bounds.width / (graphView.scale * 2 * xRatio)
        let dy = graphView.bounds.height / (graphView.scale * 2 * yRatio)
        return CGVectorMake(dx, dy)
    }

    private func viewPositionToGraphOrigin(var position: CGPoint) -> CGPoint
    {
        position.x -= graphView.bounds.midX
        position.y -= graphView.bounds.midY
        let scaleVector = self.scaleVector
        position.x /= scaleVector.dx
        position.y /= scaleVector.dy
        return position
    }

    @IBAction func pinchAction(sender: UIPinchGestureRecognizer)
    {
        switch sender.state
        {
        case .Began:
            fallthrough
        case .Changed:
            if graphView.scale <= 1
            {
                var scale = graphView.scale
                scale *= sender.velocity < 0 ? 1.25 : 0.8
                if scale > 1
                {
                    scale = ceil(scale)
                }
                graphView.scale = scale
            }
            else
            {
                graphView.scale += sender.velocity < 0 ? 1 : -1
            }
        default:
            break
        }
    }

    @IBAction func tapAction(sender: UITapGestureRecognizer)
    {
        switch sender.state
        {
        case .Ended:
            graphView.origin = viewPositionToGraphOrigin(sender.locationInView(graphView))
        default:
            break
        }
    }

    @IBAction func panAction(sender: UIPanGestureRecognizer)
    {
        switch sender.state
        {
        case .Began:
            fallthrough
        case .Changed:
            var newPosition = sender.translationInView(graphView)
            let scaleVector = self.scaleVector
            newPosition.x /= scaleVector.dx
            newPosition.y /= scaleVector.dy
            let origin = graphView.origin
            graphView.origin = CGPointMake(origin.x + newPosition.x, origin.y + newPosition.y)
            sender.setTranslation(CGPointZero, inView: graphView)
        default:
            break
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.identifier == "graph detail",
            let nvc = segue.destinationViewController as? UINavigationController,
            let gdvc = nvc.topViewController as? GraphDetailViewController
        {

            if traitCollection.horizontalSizeClass != UIUserInterfaceSizeClass.Compact
            {
                gdvc.navigationController?.setNavigationBarHidden(true, animated: false)
                gdvc.view.backgroundColor = UIColor.clearColor()
            }

            var rect = graphView.scaleRect
            rect.origin.y = -rect.origin.y
            rect.size.height = -rect.size.height
            gdvc.scaleRect = rect
            gdvc.majorDivisionScale = Double(graphView.majorDivisionScale)
            gdvc.minorDivisionScale = Double(graphView.minorDivisionScale)
        }
    }
}

