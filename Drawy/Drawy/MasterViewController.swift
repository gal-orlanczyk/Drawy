//
//  MasterViewController.swift
//  Drawy
//
//  Created by Gal Orlanczyk on 07/01/2018.
//  Copyright © 2018 GO. All rights reserved.
//

import UIKit
import RealmSwift

class MasterViewController: UITableViewController {

    /// All drawings query result (auto-updating).
    let drawings = (try? Realm())?.objects(Drawing.self)
    /// The detail vc.
    var detailViewController: DetailViewController? = nil
    /// Notification token for observing changes in realm model.
    var notificationToken: NotificationToken? = nil
    var lastSelectedIndexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        navigationItem.leftBarButtonItem = editButtonItem
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
        navigationItem.rightBarButtonItem = addButton
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
            if self.traitCollection.horizontalSizeClass == .regular {
                if drawings?.count ?? 0 == 0 {
                    self.insertNewObject(self)
                }
                self.tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .top)
                self.lastSelectedIndexPath = IndexPath(row: 0, section: 0)
                self.performSegue(withIdentifier: "showDetail", sender: self)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
        // observe changes in realm
        self.setupRealmObserver()
        if let lastSelectedIndexPath = self.lastSelectedIndexPath, let drawing = drawings?[lastSelectedIndexPath.row],
            let image = self.detailViewController?.canvas.getImage() {
            
            let db: Database = RealmDatabase()
            db.update(drawing: drawing) { (drawing) in
                drawing.thumbnailImageData = UIImagePNGRepresentation(image)
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        notificationToken?.invalidate()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func insertNewObject(_ sender: Any) {
        let db: Database = RealmDatabase()
        db.update(drawing: Drawing(id: UUID().uuidString), writeHandler: nil)
    }

    /* ***********************************************************/
    // MARK: - Navigation
    /* ***********************************************************/

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.lastSelectedIndexPath {
                guard let drawing = drawings?[indexPath.row] else { return }
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                self.detailViewController = controller
                controller.drawing = drawing
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    /* ***********************************************************/
    // MARK: - TableView
    /* ***********************************************************/

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return drawings?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! DrawingCell

        if let drawing = drawings?[indexPath.row] {
            cell.creationDateLabel.text = drawing.creationDate.description
            if let imageData = drawing.thumbnailImageData {
                cell.thumbnailImageView.image = UIImage(data: imageData)
            } else {
                cell.thumbnailImageView.image = nil
            }
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.lastSelectedIndexPath = indexPath
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let drawingToRemove = drawings?[indexPath.row] else { return }
            let db: Database = RealmDatabase()
            db.delete(drawing: drawingToRemove)
            if indexPath.row == 0 {
                self.insertNewObject(self)
                tableView.selectRow(at: indexPath, animated: true, scrollPosition: .top)
                self.lastSelectedIndexPath = indexPath
            } else {
                let newIndexPath = IndexPath(row: indexPath.row - 1, section: indexPath.section)
                tableView.selectRow(at: newIndexPath, animated: true, scrollPosition: .top)
                self.lastSelectedIndexPath = newIndexPath
            }
            self.performSegue(withIdentifier: "showDetail", sender: self)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
}

/************************************************************/
// MARK: - Private implementation
/************************************************************/

private extension MasterViewController {
    
    func setupRealmObserver() {
        self.notificationToken = drawings?.observe() { [weak self] (changes) in
            guard let tableView = self?.tableView else { return }
            switch changes {
            case .initial:
                // Results are now populated and can be accessed without blocking the UI
                tableView.reloadData()
            case .update(_, let deletions, let insertions, let modifications):
                // Query results have changed, so apply them to the UITableView
                tableView.beginUpdates()
                tableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }),
                                     with: .automatic)
                tableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0)}),
                                     with: .automatic)
                tableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }),
                                     with: .automatic)
                tableView.endUpdates()
            case .error(let error):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(error)")
            }
        }
    }
}
