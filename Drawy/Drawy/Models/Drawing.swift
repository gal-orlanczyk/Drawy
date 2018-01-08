//
//  Drawing.swift
//  Drawy
//
//  Created by Gal Orlanczyk on 08/01/2018.
//  Copyright © 2018 GO. All rights reserved.
//

import Foundation
import CoreGraphics

struct Point {
    
    let cgPoint: CGPoint
    let timestamp: TimeInterval
    
    var x: CGFloat {
        return cgPoint.x
    }
    
    var y: CGFloat {
        return cgPoint.y
    }
    
    init(cgPoint: CGPoint, timestamp: TimeInterval) {
        self.cgPoint = cgPoint
        self.timestamp = timestamp
    }
}

struct Line {
    let points: [Point]
    
    init(points: [Point]) {
        self.points = points
    }
}

struct DrawableLine {
    let line: Line
    let tool: Tool
    
    init(line: Line, tool: Tool) {
        self.line = line
        self.tool = tool
    }
}

struct Drawing {
    let id: String
    var lines: [DrawableLine]
    var endTime: TimeInterval
}
