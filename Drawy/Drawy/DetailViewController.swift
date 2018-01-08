//
//  DetailViewController.swift
//  Drawy
//
//  Created by Gal Orlanczyk on 07/01/2018.
//  Copyright © 2018 GO. All rights reserved.
//

import UIKit

// TODO: handle screen rotations
class DetailViewController: UIViewController {

    /// The drawing model, holds all the data of the drawing.
    var drawing: Drawing?
    
    @IBOutlet weak var canvas: Canvas!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let drawing = self.drawing {
            canvas.drawing = drawing
            canvas.draw()
            self.drawing = nil
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        if self.canvas?.drawing != nil {
            MockDb.add(drawing: self.canvas.drawing) // TODO: remove this later and save every new line the user draws
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

/************************************************************/
// MARK: - CanvasDelegate
/************************************************************/

extension DetailViewController: CanvasDelegate {
    
    func canvas(_ canvas: Canvas, didUpdateDrawing drawing: Drawing, withLine line: DrawableLine) {
        
    }
}
