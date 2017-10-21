//
//  GraphViewController.swift
//  Calculator
//
//  Created by David Davis on 11/19/15.
//  Copyright © 2015 David Davis. All rights reserved.
//

import UIKit


class GraphViewController: UIViewController, GraphViewDataSource, UIPopoverPresentationControllerDelegate
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

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.title = String(describing: brain).components(separatedBy: ", ").last
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
        return CGVector(dx: dx, dy: dy)
    }

    private func viewPositionToGraphOrigin(position: CGPoint) -> CGPoint
    {
        var position = position
        position.x -= graphView.bounds.midX
        position.y -= graphView.bounds.midY
        let scaleVector = self.scaleVector
        position.x /= scaleVector.dx
        position.y /= scaleVector.dy
        return position
    }

    @IBAction func pinchAction(_ sender: UIPinchGestureRecognizer)
    {
        switch sender.state
        {
        case .began:
            fallthrough
        case .changed:
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

    @IBAction func tapAction(_ sender: UITapGestureRecognizer)
    {
        switch sender.state
        {
        case .ended:
            graphView.origin = viewPositionToGraphOrigin(position: sender.location(in: graphView))
        default:
            break
        }
    }

    @IBAction func panAction(_ sender: UIPanGestureRecognizer)
    {
        switch sender.state
        {
        case .began:
            fallthrough
        case .changed:
            var newPosition = sender.translation(in: graphView)
            let scaleVector = self.scaleVector
            newPosition.x /= scaleVector.dx
            newPosition.y /= scaleVector.dy
            let origin = graphView.origin
            graphView.origin = CGPoint(x: origin.x + newPosition.x, y: origin.y + newPosition.y)
            sender.setTranslation(CGPoint.zero, in: graphView)
        default:
            break
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "graph detail",
            let gdvc = segue.destination as? GraphDetailViewController
        {
            gdvc.popoverPresentationController?.delegate = self

            var rect = graphView.scaleRect
            rect.origin.y = -rect.origin.y
            rect.size.height = -rect.size.height
            gdvc.scaleRect = rect
            gdvc.majorDivisionScale = Double(graphView.majorDivisionScale)
            gdvc.minorDivisionScale = Double(graphView.minorDivisionScale)
        }
    }

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle
    {
        return UIModalPresentationStyle.none
    }
}

