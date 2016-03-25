//
//  FeedTVC.swift
//  UCI9DC S8 Instagram
//
//  Created by Stanislav Sidelnikov on 25/03/16.
//  Copyright © 2016 Stanislav Sidelnikov. All rights reserved.
//

import UIKit

class FeedTVC: UITableViewController {
    private var feeds = [Feed]()
    private let imagesWorker = ImagesWorker()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        let imagesWorker = ImagesWorker()
        imagesWorker.getFeedForCurrentUser { (feeds, error) in
            if error == nil {
                if let feeds = feeds {
                    self.feeds = feeds
                } else {
                    self.feeds.removeAll()
                }
                self.tableView.reloadData()
            } else {
                self.displayError(withTitle: "Unable to get the feed", message: error!.localizedDescription)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return feeds.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FeedCell", forIndexPath: indexPath) as! FeedTVCell

        let feed = feeds[indexPath.row]
        if feed.image == nil && feed.imageToLoad != nil {
            imagesWorker.loadImageForFeed(feed, handler: { (feed, error) in
                if error == nil {
                    let index = self.feeds.indexOf({ $0.imageToLoad != nil && feed.imageToLoad == $0.imageToLoad })
                    if let index = index {
                        let ip = NSIndexPath(forRow: index, inSection: 0)
                        self.tableView.reloadRowsAtIndexPaths([ip], withRowAnimation: .None)
                    }
                }
            })
        }
        cell.postedImage.image = feed.image
        cell.usernameLabel.text = feed.username
        cell.messageLabel.text = feed.message

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
