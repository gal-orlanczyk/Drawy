//
//  ColorView.swift
//  Drawy
//
//  Created by Gal Orlanczyk on 10/01/2018.
//  Copyright © 2018 GO. All rights reserved.
//

import UIKit

@IBDesignable class ColorView: UIView {

    override class var layerClass: AnyClass {
        return CAShapeLayer.self
    }
    
    @IBInspectable var lineWidth: CGFloat = 2.0 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    @IBInspectable var strokeColor: UIColor = UIColor.black {
        didSet {
            self.setNeedsDisplay()
        }
    }
    @IBInspectable var fillColor: UIColor = UIColor.black {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    convenience init(frame: CGRect = CGRect.zero, lineWidth: CGFloat, strokeColor: UIColor, fillColor: UIColor) {
        self.init(frame: frame)
        self.strokeColor = strokeColor
        self.fillColor = fillColor
    }
    
    override func draw(_ rect: CGRect) {
        let layer = self.layer as! CAShapeLayer
        layer .lineWidth = self.lineWidth
        layer.fillColor = self.fillColor.cgColor
        layer.strokeColor = self.strokeColor.cgColor
        let ovalPath = UIBezierPath(ovalIn: self.bounds).cgPath
        layer.path = ovalPath
        layer.shadowPath = ovalPath
        layer.shadowColor = self.strokeColor.cgColor
        layer.shadowRadius = 5
        layer.shadowOpacity = 0.7
        layer.shadowOffset = CGSize(width: 0, height: 0)
    }
}
