//
//  Database.swift
//  Drawy
//
//  Created by Gal Orlanczyk on 07/01/2018.
//  Copyright © 2018 GO. All rights reserved.
//

import Foundation
import RealmSwift

protocol Database {
    func drawing(for id: String) -> Drawing?
    func update(drawing: Drawing, writeHandler: ((Drawing) -> Void)?)
    func delete(drawing: Drawing)
}

final class RealmDatabase: Database {
    
    func drawing(for id: String) -> Drawing? {
        do {
            let realm = try Realm()
            return realm.object(ofType: Drawing.self, forPrimaryKey: id)
        } catch {
            print("error: \(error)")
            return nil
        }
    }
    
    func add(line: DrawableLine, in drawing: Drawing) {
        do {
            let realm = try Realm()
            try realm.write {
                drawing.lines.append(line)
            }
        } catch {
            print("error: \(error)")
        }
    }
    
    func update(drawing: Drawing, writeHandler: ((Drawing) -> Void)? = nil) {
        do {
            let realm = try Realm()
            try realm.write {
                writeHandler?(drawing)
                realm.add(drawing, update: true)
            }
        } catch {
            print("error: \(error)")
        }
    }
    
    func delete(drawing: Drawing) {
        do {
            let realm = try Realm()
            try realm.write {
                realm.delete(drawing)
            }
        } catch {
            print("error: \(error)")
        }
    }
}
