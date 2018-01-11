//
//  DrawingCell.swift
//  Drawy
//
//  Created by Gal Orlanczyk on 11/01/2018.
//  Copyright © 2018 GO. All rights reserved.
//

import UIKit

class DrawingCell: UITableViewCell {

    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var creationDateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
