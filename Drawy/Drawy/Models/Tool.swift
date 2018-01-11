//
//  Tool.swift
//  Drawy
//
//  Created by Gal Orlanczyk on 11/01/2018.
//  Copyright © 2018 GO. All rights reserved.
//

import Foundation
import RealmSwift

final class Tool: Object {
    
    /// Pattern types of tool
    enum Pattern: Int {
        case regular = 0
        case eraser
        
        static var all: [Pattern] {
            return [.regular, .eraser]
        }
        
        var title: String {
            switch self {
            case .regular: return "Regular"
            case .eraser: return "Eraser"
            }
        }
        
        init(title: String) {
            switch title {
            case "Regular": self = .regular
            case "Eraser": self = .eraser
            default: self = .regular
            }
        }
    }
    
    /// The internval value of the pattern type that will be saved in the db.
    @objc private dynamic var _pattern: Int = 0
    /// The width of the tool, will affect how big the pattern is.
    @objc dynamic var width: CGFloat = 5.0
    @objc dynamic var alpha: CGFloat = 1.0
    
    /* Tool RGB */
    @objc dynamic var red: Double = 0
    @objc dynamic var green: Double = 0
    @objc dynamic var blue: Double = 0
    
    /// The pattern of the tool
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

