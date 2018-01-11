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
// MARK: - Point
/* ***********************************************************/

final class Point: Object {
    
    @objc dynamic var x: Double = 0
    @objc dynamic var y: Double = 0
    var cgPoint: CGPoint {
        return CGPoint(x: self.x, y: self.y)
    }
    @objc dynamic var timestamp: TimeInterval = 0
    
    convenience init(x: Double, y: Double, timestamp: TimeInterval) {
        self.init()
        self.x = x
        self.y = y
        self.timestamp = timestamp
    }
    
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

final class Line: Object {
    let points = List<Point>()
    
    convenience init(points: [Point]) {
        self.init()
        self.points.append(objectsIn: points)
    }
}

/* ***********************************************************/
// MARK: - DrawableLine
/* ***********************************************************/

final class DrawableLine: Object {
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

final class Drawing: Object {
    @objc dynamic var id: String = ""
    let lines = List<DrawableLine>()
    @objc dynamic var endTime: TimeInterval = 0
    @objc dynamic var creationDate: Date = Date()
    @objc dynamic var thumbnailImageData: Data? = nil
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    convenience init(id: String) {
        self.init()
        self.id = id
    }
}
