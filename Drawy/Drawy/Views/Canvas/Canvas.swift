//
//  Canvas.swift
//  Drawy
//
//  Created by Gal Orlanczyk on 08/01/2018.
//  Copyright © 2018 GO. All rights reserved.
//

import UIKit

protocol CanvasDelegate: class {
    func canvas(_ canvas: Canvas, didUpdateDrawing drawing: Drawing, withLine line: DrawableLine)
}

class Canvas: UIView {
    
    weak var delegate: CanvasDelegate?
    
    var firstDrawableTimestamp: TimeInterval?
    var drawing: Drawing {
        get {
            let offset = Date().timeIntervalSince1970 - (self.firstDrawableTimestamp ?? ProcessInfo.processInfo.systemUptime)
            self._drawing.endTime = offset
            return self._drawing
        }
        set {
            self._drawing = newValue
        }
    }
    
    fileprivate var _drawing: Drawing! {
        didSet(drawing) {
            guard drawing != nil else { return }
            self.firstDrawableTimestamp = ProcessInfo.processInfo.systemUptime - drawing.endTime
        }
    }
    
    fileprivate var mainImageView = UIImageView()
    fileprivate var tempImageView = UIImageView()
    fileprivate var backgroundImageView = UIImageView()
    
    /// The current tool used for the drawing.
    fileprivate var tool = Tool.regular(properties: Tool.Properties())
    /// The path to draw, has points only on touches.
    fileprivate let path: UIBezierPath = {
        let path = UIBezierPath()
        path.lineCapStyle = .round
        return path
    }()
    fileprivate let scale = UIScreen.main.scale // TODO: check if needed
    fileprivate var pointIndex = 0
    /// The current aggregated points for the touch events.
    fileprivate var points = [Point]()
    /// indicates if the last touch event moved. used to infer if user had a continues touch or just one tap.
    fileprivate var isTouchMoved = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialize()
    }
    
    private func initialize() {
        // save the first touch in the drawing if doesn't exist, for existing drawing will have the last time.
        self.firstDrawableTimestamp = ProcessInfo.processInfo.systemUptime
        self.addSubview(self.backgroundImageView)
        self.backgroundImageView.backgroundColor = UIColor.white
        self.backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundImageView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.backgroundImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        self.backgroundImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        self.backgroundImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        self.addSubview(self.mainImageView)
        self.mainImageView.translatesAutoresizingMaskIntoConstraints = false
        self.mainImageView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.mainImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        self.mainImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        self.mainImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        self.addSubview(self.tempImageView)
        self.tempImageView.translatesAutoresizingMaskIntoConstraints = false
        self.tempImageView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.tempImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        self.tempImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        self.tempImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        self.backgroundColor = UIColor.lightGray
    }
}

/************************************************************/
// MARK: - Internal Implementation
/************************************************************/

extension Canvas {
    
    func draw() {
        UIGraphicsBeginImageContextWithOptions(self.frame.size, false, 0)
        self.mainImageView.image?.draw(in: self.bounds)
        
        for drawableLine in _drawing.lines {
            let path = UIBezierPath()
            path.lineCapStyle = .round
            path.lineWidth = drawableLine.tool.properties.width / self.scale
            drawableLine.tool.properties.color.withAlphaComponent(drawableLine.tool.properties.alpha).setStroke()
            for (i,point) in drawableLine.line.points.enumerated() {
                if i == 0 {
                    path.move(to: point.cgPoint)
                }
                path.addLine(to: point.cgPoint)
            }
            path.stroke(with: drawableLine.tool.blendMode, alpha: 1)
        }
        
        self.mainImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
}

/************************************************************/
// MARK: - Touch Handling
/************************************************************/

extension Canvas {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        self.isTouchMoved = false
        self.pointIndex = 0
        self.points.append(Point(cgPoint: touch.location(in: self), timestamp: touch.timestamp - self.firstDrawableTimestamp!))
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let currentPoint = touch.location(in: self)
        let previousPoint = self.points.last!.cgPoint
        self.isTouchMoved = true
        self.pointIndex += 1
        self.points.append(Point(cgPoint: currentPoint, timestamp: touch.timestamp - self.firstDrawableTimestamp!))
        self.path.move(to: previousPoint)
        self.path.addLine(to: currentPoint)
        self.strokePath()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.touchesEnded(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !self.isTouchMoved {   // only tapped one time
            self.path.move(to: self.points[0].cgPoint)
            self.path.addLine(to: self.points[0].cgPoint)
            self.strokePath()
        }
        let line = Line(points: self.points)
        self._drawing.lines.append(DrawableLine(line: line, tool: self.tool))
        // merge the temp view into the main
        self.mergeImageViews()
        // clear the current handled path
        self.path.removeAllPoints()
        self.points.removeAll()
        self.pointIndex = 0
        self.isTouchMoved = true
    }
}

/************************************************************/
// MARK: - Motion
/************************************************************/

extension Canvas {
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        guard motion == .motionShake else { return }
        // TODO: display an alert with clear canvas option
    }
}

/************************************************************/
// MARK: - Private implementation
/************************************************************/

private extension Canvas {
    
    func strokePath() {
        UIGraphicsBeginImageContextWithOptions(self.frame.size, false, 0)
        // TODO: check the effect of scaling
        self.path.lineWidth = self.calculatePathLineWidth(toolWidth: self.tool.properties.width, scale: self.scale)
        self.tool.properties.color.withAlphaComponent(self.tool.properties.alpha).setStroke()
        
        if self.tool.isEraser {
            // when erasing need to do it on the main image view screen.
            self.mainImageView.image?.draw(in: self.bounds)
        }
        
        self.path.stroke(with: tool.blendMode, alpha: 1)
        
        let targetImageView = self.tool.isEraser ? self.mainImageView : self.tempImageView
        targetImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
    }
    
    func mergeImageViews() {
        UIGraphicsBeginImageContextWithOptions(self.frame.size, false, 0)
        
        self.mainImageView.image?.draw(in: self.bounds)
        self.tempImageView.image?.draw(in: self.bounds)
        
        self.mainImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        // TOOD: for replay maybe append the current drawing here?
        self.tempImageView.image = nil
        
        UIGraphicsEndImageContext()
    }
    
    func calculatePathLineWidth(toolWidth: CGFloat, scale: CGFloat) -> CGFloat {
        return toolWidth / scale
    }
}
