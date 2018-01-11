//
//  UIView+Constraints.swift
//  Drawy
//
//  Created by Gal Orlanczyk on 10/01/2018.
//  Copyright © 2018 GO. All rights reserved.
//

import UIKit

extension UIView {
    
    func pin(to view: UIView) {
        self.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        self.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        self.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
}
