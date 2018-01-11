//
//  ToolView.swift
//  Drawy
//
//  Created by Gal Orlanczyk on 10/01/2018.
//  Copyright © 2018 GO. All rights reserved.
//

import UIKit

@IBDesignable class ToolView: UIView {

    override class var layerClass: AnyClass {
        return CAShapeLayer.self
    }
    
    @IBInspectable var lineWidth: CGFloat = 5.0 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    @IBInspectable var strokeColor: UIColor = UIColor.black {
        didSet {
            self.setNeedsDisplay()
        }
    }

    func preview(tool: Tool) {
        self.lineWidth = tool.width
        self.strokeColor = tool.color
    }
    
    override func draw(_ rect: CGRect) {
        let layer = self.layer as! CAShapeLayer
        layer .lineWidth = self.lineWidth
        layer.strokeColor = self.strokeColor.cgColor
        layer.lineCap = kCALineCapRound
        let path = UIBezierPath()
        path.lineCapStyle = .round
        path.move(to: CGPoint(x: self.bounds.width / 2, y: self.bounds.height / 2))
        path.addLine(to: CGPoint(x: self.bounds.width / 2, y: self.bounds.height / 2))
        layer.path = path.cgPath
    }
}
