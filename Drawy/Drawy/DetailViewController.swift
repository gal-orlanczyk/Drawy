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

    let toolSelectorViewTag = 1
    let toolSelectorAnimationDuration = 0.5
    
    /// The drawing model, holds all the data of the drawing.
    var drawing: Drawing?
    var isFirstViewDidLayoutSubviews = true
    
    @IBOutlet weak var canvas: Canvas!
    @IBOutlet weak var colorView: ColorView!
    
    weak var toolSelectorView: ToolSelector?
    /// used to catch taps outside the tool selector view when visible to dismiss it.
    weak var toolBackgroundView: UIView?
    weak var toolSelectorViewCenterYConstraint: NSLayoutConstraint?
    
    override func viewDidLayoutSubviews() {
        if self.isFirstViewDidLayoutSubviews {
            if let drawing = self.drawing {
                canvas.drawing = drawing
                canvas.draw()
                self.drawing = nil
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if splitViewController?.isCollapsed == true {
            if let image = self.canvas?.getImage() {
                let db: Database = RealmDatabase()
                if db.drawing(for: canvas.drawing.id) != nil {
                    db.update(drawing: canvas.drawing) { (drawing) in
                        drawing.thumbnailImageData = UIImagePNGRepresentation(image)
                    }
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

/************************************************************/
// MARK: - Actions
/************************************************************/

private extension DetailViewController {
    
    @IBAction func colorTapped(_ sender: UITapGestureRecognizer) {
        guard self.view.subviews.first(where: { $0.tag == self.toolSelectorViewTag }) == nil else { return }
        // sets the selector size based on the size class, larger for ipad.
        let size: CGFloat = self.traitCollection.horizontalSizeClass == .regular &&
            self.traitCollection.verticalSizeClass == .regular ? 400 : 280
        // add the tool selector view and position it at the center.
        let toolSelectorView = self.addToolSelectorView(size: size)
        let topConstraint = toolSelectorView.topAnchor.constraint(equalTo: self.view.bottomAnchor)
        topConstraint.isActive = true
        // add gesture recognizers to dismiss the selector tool
        self.addDismissBehaviorForToolSelector()
        // setup the tool view with current canvas tool
        self.toolSelectorView?.setup(with: self.canvas.tool, animated: true)
        // animate the tool from the bottom of the screen
        UIView.animate(withDuration: self.toolSelectorAnimationDuration, animations: {
            topConstraint.isActive = false
            self.toolSelectorViewCenterYConstraint = toolSelectorView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
            self.toolSelectorViewCenterYConstraint!.isActive = true
            self.view.layoutIfNeeded()
        }) { (finished) in
            if finished {
                toolSelectorView.removeConstraint(topConstraint)
            }
        }
    }
    
    @objc func toolSelectorSwiped(swipeGesture: UISwipeGestureRecognizer) {
        guard let toolSelectorView = self.toolSelectorView else { return }
        self.updateTool(tool: toolSelectorView.getToolFromSelection())
        
        let newConstraint: NSLayoutConstraint
        if swipeGesture.direction == .down {
            newConstraint = toolSelectorView.topAnchor.constraint(equalTo: self.view.bottomAnchor)
        } else {
            newConstraint = toolSelectorView.bottomAnchor.constraint(equalTo: self.view.topAnchor)
        }
        
        UIView.animate(withDuration: self.toolSelectorAnimationDuration, animations: {
            self.toolSelectorViewCenterYConstraint?.isActive = false
            newConstraint.isActive = true
            self.view.layoutIfNeeded()
        }) { (finished) in
            if finished {
                self.dismissToolSelectorView()
            }
        }
    }
    
    /// called when tool selector view is visable and was tapped outside of his frame.
    @objc func toolSelectorTappedOutside(gesture: UITapGestureRecognizer) {
        guard let toolSelectorView = self.toolSelectorView else { return }
        self.updateTool(tool: toolSelectorView.getToolFromSelection())
        
        UIView.animate(withDuration: self.toolSelectorAnimationDuration, animations: {
            self.toolSelectorView?.alpha = 0
        }) { (finished) in
            if finished {
                self.dismissToolSelectorView()
            }
        }
    }
    
    @IBAction func clearTouched(_ sender: UIBarButtonItem) {
        self.showClearCanvasAlert()
    }
    
    @IBAction func shareTouched(_ sender: UIBarButtonItem) {
        guard let image = self.canvas.getImage() else { return }
        let activity = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(activity, animated: true, completion: nil)
    }
}

/************************************************************/
// MARK: - Motion
/************************************************************/

extension DetailViewController {
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        guard motion == .motionShake else { return } // device was shaked
        self.showClearCanvasAlert()
    }
}

/************************************************************/
// MARK: - Private Implementation
/************************************************************/

private extension DetailViewController {
    
    func showClearCanvasAlert() {
        let title = "Clear the canvas?"
        let message = "The canvas will be cleared from all of his content this is unreversable"
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Clear Canvas", style: .destructive, handler: { [weak self] (action) in
            self?.canvas.clear()
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func updateTool(tool: Tool) {
        self.canvas.tool = tool
        self.colorView.fillColor = tool.color
    }
    
    func dismissToolSelectorView() {
        self.toolSelectorView?.removeFromSuperview()
        self.toolBackgroundView?.removeFromSuperview()
    }
    
    func addToolSelectorView(size: CGFloat) -> ToolSelector {
        let toolSelectorView = ToolSelector(frame: CGRect.zero)
        self.toolSelectorView = toolSelectorView
        toolSelectorView.tag = self.toolSelectorViewTag
        toolSelectorView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(toolSelectorView)
        toolSelectorView.widthAnchor.constraint(equalToConstant: size).isActive = true
        toolSelectorView.heightAnchor.constraint(equalToConstant: size).isActive = true
        toolSelectorView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        return toolSelectorView
    }
    
    func addDismissBehaviorForToolSelector() {
        guard let toolSelectorView = self.toolSelectorView else { return }
        let swipeDownGesutreRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(toolSelectorSwiped(swipeGesture:)))
        swipeDownGesutreRecognizer.direction = .down
        toolSelectorView.addGestureRecognizer(swipeDownGesutreRecognizer)
        let swipeUpGesutreRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(toolSelectorSwiped(swipeGesture:)))
        swipeUpGesutreRecognizer.direction = .up
        toolSelectorView.addGestureRecognizer(swipeUpGesutreRecognizer)
        // add a background view to catch tap to dismiss for the tool selector
        let toolBackgroundView = UIView()
        toolBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        self.view.insertSubview(toolBackgroundView, belowSubview: toolSelectorView)
        toolBackgroundView.pin(to: self.view)
        toolBackgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toolSelectorTappedOutside(gesture:))))
        self.toolBackgroundView = toolBackgroundView
        self.view.layoutIfNeeded()
    }
}
