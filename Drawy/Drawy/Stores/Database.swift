//
//  Database.swift
//  Drawy
//
//  Created by Gal Orlanczyk on 07/01/2018.
//  Copyright © 2018 GO. All rights reserved.
//

import Foundation

class MockDb {
   
    static func drawing(for id: String) -> Drawing? {
        return MockDb.db[id]
    }
    
    static func add(drawing: Drawing) {
        MockDb.db[drawing.id] = drawing
    }
    
    static func add(_ drawableLines: [DrawableLine], for id: String) {
        if var drawing = MockDb.db[id] {
            drawing.lines.append(contentsOf: drawableLines)
        }
    }
    
    private static var db = [String: Drawing]()
}
