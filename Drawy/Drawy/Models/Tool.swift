//
//  Tool.swift
//  Drawy
//
//  Created by Gal Orlanczyk on 08/01/2018.
//  Copyright © 2018 GO. All rights reserved.
//

import Foundation
import UIKit

enum Tool {
    case regular(properties: Properties)
    case eraser(properties: Properties)
    // TODO: add more brushes?
    
    struct Properties {
        var color: UIColor
        var width: CGFloat
        var alpha: CGFloat
        
        init(color: UIColor = UIColor.black, width: CGFloat = 5.0, alpha: CGFloat = 1.0) {
            self.color = color
            self.width = width
            self.alpha = alpha
        }
    }
    
    var properties: Properties {
        switch self {
        case .regular(let properties): return properties
        case .eraser(let properties): return properties
        }
    }
    
    var blendMode: CGBlendMode {
        switch self {
        case .regular: return .normal
        case .eraser: return .clear
        }
    }
    
    var isEraser: Bool {
        switch self {
        case .eraser: return true
        default: return false
        }
    }
}
