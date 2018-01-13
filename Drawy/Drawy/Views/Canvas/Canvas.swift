//
//  Canvas.swift
//  Drawy
//
//  Created by Gal Orlanczyk on 08/01/2018.
//  Copyright © 2018 GO. All rights reserved.
//

import UIKit

class Canvas: UIView {
    
    /* ***********************************************************/
    // MARK: - Internal Properties
    /* ***********************************************************/
    
    var firstDrawableTimestamp: TimeInterval?
    var drawing: Drawing {
        get {
            let offset = Date().timeIntervalSince1970 - (self.firstDrawableTimestamp ?? ProcessInfo.processInfo.systemUptime)
            let db: Database = RealmDatabase()
            db.update(drawing: _drawing) { (drawing) in
                drawing.endTime = offset
            }
            return self._drawing
        }
        set {
            self._drawing = newValue
        }
    }
    /// The current tool used for the drawing.
    var tool = Tool(pattern: .regular)
    
    /* ***********************************************************/
    // MARK: - Private Properties
    /* ***********************************************************/
    
    fileprivate var _drawing: Drawing! {
        didSet(drawing) {
            guard drawing != nil else { return }
            self.firstDrawableTimestamp = ProcessInfo.processInfo.systemUptime - drawing.endTime
        }
    }
    
    fileprivate var drawingImageView = UIImageView()
    fileprivate var toolImageView = UIImageView()
    fileprivate var backgroundImageView = UIImageView()
    
    /// The path to draw, has points only on touches.
    fileprivate let path: UIBezierPath = {
        let path = UIBezierPath()
        path.lineCapStyle = .round
        path.lineJoinStyle = .round
        return path
    }()
    fileprivate var lastPoint: CGPoint!
    fileprivate var pointIndex = 0
    /// The current aggregated points for the touch events.
    fileprivate var points = [Point]()
    fileprivate var bufferedPoints = [Point]()
    fileprivate var line: Line!
    /// indicates if the last touch event moved. used to infer if user had a continues touch or just one tap.
    fileprivate var isTouchMoved = false
    
    /* ***********************************************************/
    // MARK: - Init
    /* ***********************************************************/
    
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
        
        self.backgroundImageView.backgroundColor = UIColor.white
        self.backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.backgroundImageView)
        self.backgroundImageView.pin(to: self)
        
        self.drawingImageView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.drawingImageView)
        self.drawingImageView.pin(to: self)
        
        self.toolImageView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.toolImageView)
        self.toolImageView.pin(to: self)
        
        self.backgroundColor = UIColor.lightGray
    }
}

/************************************************************/
// MARK: - Internal Implementation
/************************************************************/

extension Canvas {
    
    func draw() {
        UIGraphicsBeginImageContextWithOptions(self.frame.size, false, 0)
        self.drawingImageView.image?.draw(in: self.bounds)
        
        for drawableLine in _drawing.lines {
            let path = self.path.copy() as! UIBezierPath
            path.lineWidth = drawableLine.tool.width
            drawableLine.tool.color.withAlphaComponent(drawableLine.tool.alpha).setStroke()
            let points = drawableLine.line.points
            path.interpolatePointsWithHermite(interpolationPoints: Array(points))
            path.stroke(with: drawableLine.tool.blendMode, alpha: 1)
        }
        
        self.drawingImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
    func clear() {
        self.drawingImageView.image = nil
        let db: Database = RealmDatabase()
        db.update(drawing: self._drawing) { (drawing) in
            drawing.lines.removeAll()
            drawing.endTime = 0
        }
    }
    
    func getImage() -> UIImage? {
        UIGraphicsBeginImageContext(self.drawingImageView.bounds.size)
        self.drawingImageView.image?.draw(in: self.drawingImageView.frame)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
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
        self.line = Line()
        let currentPoint = touch.location(in: self)
        self.path.move(to: currentPoint)
        self.lastPoint = currentPoint
        self.points.append(Point(cgPoint: currentPoint, timestamp: touch.timestamp - self.firstDrawableTimestamp!))
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        self.isTouchMoved = true
        self.pointIndex += 1
        let currentCgPoint = touch.location(in: self)
        let currentPoint = Point(cgPoint: currentCgPoint, timestamp: touch.timestamp - self.firstDrawableTimestamp!)
        let previousPoint = self.points.last!.cgPoint
    
        if (abs(currentCgPoint.x - previousPoint.x) > 5 || abs(currentCgPoint.y - previousPoint.y) > 5) &&
            touch.timestamp - (self.firstDrawableTimestamp ?? 0) - self.points.last!.timestamp > 0.03 {
            self.points.append(contentsOf: self.bufferedPoints)
            self.bufferedPoints.removeAll()
            self.path.interpolatePointsWithHermite(interpolationPoints: self.points + [currentPoint])
            self.strokePath()
            if self.points.count > 40 {
                self.mergeImageViews()
                self.path.removeAllPoints()
                self.line.points.append(objectsIn: self.points)
                self.points.removeAll()
            }
            self.points.append(currentPoint)
            self.path.move(to: currentPoint.cgPoint)
        } else {
            self.bufferedPoints.append(currentPoint)
        }
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
        if bufferedPoints.count > 0 {
            self.add(points: self.bufferedPoints, to: self.path)
            self.strokePath()
            self.points.append(contentsOf: self.bufferedPoints)
        }
        self.line.points.append(objectsIn: self.points)
        let db: Database = RealmDatabase()
        db.update(drawing: self._drawing) { (drawing) in
            drawing.lines.append(DrawableLine(line: self.line, tool: self.tool))
        }
        // merge the temp view into the main
        self.mergeImageViews()
        // clear the current handled path
        self.path.removeAllPoints()
        self.points.removeAll()
        self.bufferedPoints.removeAll()
        self.line = nil
        self.pointIndex = 0
        self.isTouchMoved = true
    }
}

/************************************************************/
// MARK: - Private implementation
/************************************************************/

private extension Canvas {
    
    func strokePath() {
        UIGraphicsBeginImageContextWithOptions(self.frame.size, false, 0)
        
        self.path.lineWidth = self.tool.width
        self.tool.color.withAlphaComponent(self.tool.alpha).setStroke()
        
        if self.tool.isEraser {
            // when erasing need to do it on the main image view screen.
            self.drawingImageView.image?.draw(in: self.bounds)
        }
        
        self.path.stroke(with: tool.blendMode, alpha: 1)
        
        let targetImageView = self.tool.isEraser ? self.drawingImageView : self.toolImageView
        targetImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
    }
    
    func mergeImageViews() {
        UIGraphicsBeginImageContextWithOptions(self.frame.size, false, 0)
        
        self.drawingImageView.image?.draw(in: self.bounds)
        self.toolImageView.image?.draw(in: self.bounds)
        
        self.drawingImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        self.toolImageView.image = nil
        
        UIGraphicsEndImageContext()
    }
    
    func add(points: [Point], to path: UIBezierPath) {
        for point in points {
            path.addLine(to: point.cgPoint)
        }
    }
}

