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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

/************************************************************/
// MARK: - Motion
/************************************************************/

extension DetailViewController {
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        guard motion == .motionShake else { return } // device was shaked
        let title = "Clear the canvas?"
        let message = "The canvas will be cleared from all of his content this is unreversable"
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Clear Canvas", style: .destructive, handler: { [weak self] (action) in
            self?.canvas.clear()
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
}
