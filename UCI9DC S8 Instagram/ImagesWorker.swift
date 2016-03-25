//
//  ImagesWorker.swift
//  UCI9DC S8 Instagram
//
//  Created by Stanislav Sidelnikov on 24/03/16.
//  Copyright © 2016 Stanislav Sidelnikov. All rights reserved.
//

import Foundation
import UIKit
import Parse

class ImagesWorker {
    static let entryClassName = "PhotoEntry"

    func postImage(image: UIImage, withComment comment: String?, _ handler: ((Bool, NSError?) -> Void)?) {
        guard let currentUserId = PFUser.currentUser()?.objectId else {
            handler?(false, nil)
            return
        }
        guard let imageData = UIImageJPEGRepresentation(image, 0.5) else {
            handler?(false, nil)
            return
        }
        let file = PFFile(data: imageData)
        let object = PFObject(className: ImagesWorker.entryClassName)
        object["user"] = currentUserId
        object["comment"] = comment
        object["image"] = file

        object.saveInBackgroundWithBlock { (success, error) in
            handler?(success, error)
        }
    }

    func getFeedForCurrentUser(handler: (([Feed]?, NSError?) -> Void)?) {
        guard let currentUserId = PFUser.currentUser()?.objectId else {
            handler?(nil, nil)
            return
        }
        let queue = dispatch_queue_create("Getting Feed", nil)
        func dispatch_in_calling(operation: ()->Void) {
            dispatch_async(dispatch_get_main_queue(), {
                operation()
            })
        }
        dispatch_async(queue, {
            let usersWorker = UsersWorker()
            var followedUsers: [String]?
            do {
                followedUsers = try usersWorker.getFollowedUsers(byUserWithId: currentUserId)
            } catch let error as NSError {
                dispatch_in_calling({
                    handler?(nil, error)
                })
                return
            }
            if let followedUsers = followedUsers {
                var usernames: [String: String]?
                do {
                    usernames = try usersWorker.getUserNames(byIds: followedUsers)
                } catch let error as NSError {
                    NSLog("Unable to get usernames. Error: \(error.localizedDescription)")
                }
                let feedQuery = PFQuery(className: ImagesWorker.entryClassName)
                feedQuery.whereKey("user", containedIn: followedUsers)
                do {
                    let objects = try feedQuery.findObjects()
                    var feeds = [Feed]()
                    for object in objects {
                        let feed = Feed()
                        if let userId = object["user"] as? String {
                            feed.username = usernames?[userId]
                        }
                        feed.message = object["comment"] as? String
                        if let file = object["image"] as? PFFile {
//                            do {
//                                let data = try file.getData()
//                                feed.image = UIImage(data: data)
//                            } catch let error as NSError {
//                                NSLog("Unable to get image for \(object). Error: \(error.localizedDescription)")
//                            }
                            feed.imageToLoad = file
                        }
                        feeds.append(feed)
                    }
                    dispatch_in_calling({
                        handler?(feeds, nil)
                    })
                } catch let error as NSError {
                    dispatch_in_calling({
                        handler?(nil, error)
                    })
                }
            } else {
                dispatch_in_calling({
                    handler?(nil, nil)
                })
            }
        })
    }

    func loadImageForFeed(feed: Feed, handler: ((Feed, NSError?) -> Void)?) {
        guard let file = feed.imageToLoad else {
            handler?(feed, nil)
            return
        }
        guard feed.image == nil else {
            handler?(feed, nil)
            return
        }
        func dispatch_in_calling(operation: ()->Void) {
            dispatch_async(dispatch_get_main_queue(), {
                operation()
            })
        }
        file.getDataInBackgroundWithBlock { (data, error) in
            if error == nil {
                if let data = data {
                    feed.image = UIImage(data: data)
                    dispatch_in_calling({
                        handler?(feed, nil)
                    })
                } else {
                    NSLog("Unable to get image - data is empty. \(feed)")
                    dispatch_in_calling({
                        handler?(feed, nil)
                    })
                }
            } else {
                NSLog("Unable to get image for \(feed). Error: \(error!.localizedDescription)")
                dispatch_in_calling({
                    handler?(feed, error!)
                })
            }
        }
    }
}