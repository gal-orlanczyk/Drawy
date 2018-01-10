//
//  Drawing.swift
//  Drawy
//
//  Created by Gal Orlanczyk on 08/01/2018.
//  Copyright © 2018 GO. All rights reserved.
//

import Foundation
import CoreGraphics
import RealmSwift

/* ***********************************************************/
// MARK: - Tool
/* ***********************************************************/

class Tool: Object {
    
    enum Pattern: Int {
        case regular = 0
        case eraser
    }
    
    @objc private dynamic var _pattern: Int = 0
    @objc dynamic var width: CGFloat = 5.0
    @objc dynamic var alpha: CGFloat = 1.0
    
    @objc private dynamic var red: Double = 0
    @objc private dynamic var green: Double = 0
    @objc private dynamic var blue: Double = 0
    
    var pattern: Pattern {
        return Pattern(rawValue: self._pattern) ?? .regular
    }
    
    var color: UIColor {
        return UIColor(red: CGFloat(self.red), green: CGFloat(self.green), blue: CGFloat(self.blue), alpha: 1.0)
    }
    
    var blendMode: CGBlendMode {
        switch pattern {
        case .regular: return .normal
        case .eraser: return .clear
        }
    }
    
    var isEraser: Bool {
        switch pattern {
        case .eraser: return true
        default: return false
        }
    }
    
    convenience init(pattern: Pattern, width: CGFloat = 5, alpha: CGFloat = 1, color: UIColor = UIColor.black) {
        self.init()
        self._pattern = pattern.rawValue
        self.width = width
        self.alpha = alpha
        
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: nil)
        self.red = Double(r)
        self.green = Double(g)
        self.blue = Double(b)
    }
}

/* ***********************************************************/
// MARK: - Point
/* ***********************************************************/

class Point: Object {
    
    @objc dynamic var x: Double = 0
    @objc dynamic var y: Double = 0
    var cgPoint: CGPoint {
        return CGPoint(x: self.x, y: self.y)
    }
    @objc dynamic var timestamp: TimeInterval = 0
    
    convenience init(cgPoint: CGPoint, timestamp: TimeInterval) {
        self.init()
        self.x = Double(cgPoint.x)
        self.y = Double(cgPoint.y)
        self.timestamp = timestamp
    }
}

/* ***********************************************************/
// MARK: - Line
/* ***********************************************************/

class Line: Object {
    let points = List<Point>()
    
    convenience init(points: [Point]) {
        self.init()
        self.points.append(objectsIn: points)
    }
}

/* ***********************************************************/
// MARK: - DrawableLine
/* ***********************************************************/

class DrawableLine: Object {
    @objc dynamic var line: Line!
    @objc dynamic var tool: Tool!
    
    convenience init(line: Line, tool: Tool) {
        self.init()
        self.line = line
        self.tool = tool
    }
}

/* ***********************************************************/
// MARK: - Drawing
/* ***********************************************************/

class Drawing: Object {
    @objc dynamic var id: String = ""
    let lines = List<DrawableLine>()
    @objc dynamic var endTime: TimeInterval = 0
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    convenience init(id: String) {
        self.init()
        self.id = id
    }
}
