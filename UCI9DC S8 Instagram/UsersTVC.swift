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
    private let usersWorker = UsersWorker()

    override func viewDidLoad() {
        context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        super.viewDidLoad()
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(UsersTVC.updateData), forControlEvents: .AllEvents)
        updateData()
        initializeFetchedResultsController()
    }

    func updateData() {
        refreshControl?.beginRefreshing()
        usersWorker.loadAllUsers(inContext: context) { (success, error) in
            self.refreshControl?.endRefreshing()
            print("Loading users finished. \(success). \(error)")
        }
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

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let user = fetchedResultsController!.objectAtIndexPath(indexPath) as! User
        guard let userId = user.id else {
            NSLog("Cannot get id for user \(user).")
            return
        }
        if user.followed {
            usersWorker.unfollowUser(withId: userId, inContext: context, handler: { (success) in
                if success {
                    self.reloadCell(atIndexPath: indexPath)
                }
            })
        } else {
            usersWorker.followUser(withId: userId, inContext: context, handler: { (success) in
                if success {
                    self.reloadCell(atIndexPath: indexPath)
                }
            })
        }
    }

    private func reloadCell(atIndexPath indexPath: NSIndexPath) {
        tableView.beginUpdates()
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        tableView.endUpdates()
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
