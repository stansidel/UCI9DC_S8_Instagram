//
//  UsersTVC.swift
//  UCI9DC S8 Instagram
//
//  Created by Stanislav Sidelnikov on 23/03/16.
//  Copyright © 2016 Stanislav Sidelnikov. All rights reserved.
//

import UIKit
import CoreData

class UsersTVC: CoreDataTableViewController {
    private var context: NSManagedObjectContext!

    override func viewDidLoad() {
        context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        super.viewDidLoad()
        UsersWorker().loadAllUsers(inContext: context) { (success, error) in
            print("Loading users finished. \(success). \(error)")
        }
        initializeFetchedResultsController()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("User", forIndexPath: indexPath)
        configureCell(cell, indexPath: indexPath)
        return cell
    }

    private func configureCell(cell: UITableViewCell, indexPath: NSIndexPath) {
        let user = fetchedResultsController!.objectAtIndexPath(indexPath) as! User
        cell.textLabel?.text = user.name
        cell.accessoryType = user.followed ? .Checkmark : .None
    }

    private func initializeFetchedResultsController() {
        let request = NSFetchRequest(entityName: User.entityName)
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
    }

}
