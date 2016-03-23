//
//  UsersLoader.swift
//  UCI9DC S8 Instagram
//
//  Created by Stanislav Sidelnikov on 23/03/16.
//  Copyright © 2016 Stanislav Sidelnikov. All rights reserved.
//

import Foundation
import Parse
import CoreData

class UsersWorker {
    func loadAllUsers(inContext context: NSManagedObjectContext, withHandler handler: ((Bool, NSError?) -> Void)?) {
        guard let currentUserId = PFUser.currentUser()?.objectId else {
            handler?(false, nil)
            return
        }
        let queue = dispatch_queue_create("Users Update", nil)
        func dispatch_in_calling(operation: ()->Void) {
            dispatch_async(dispatch_get_main_queue(), {
                operation()
            })
        }
        dispatch_async(queue, {
            let query = PFUser.query()
            var users: [PFObject]?
            do {
                users = try query?.findObjects()
            } catch let error as NSError {
                dispatch_in_calling({ handler?(false, error) })
                return
            }

            let queryFollowers = PFQuery(className: "Followers")
            queryFollowers.whereKey("follower", equalTo: currentUserId)
            var followings: [PFObject]?
            do {
                followings = try queryFollowers.findObjects()
            } catch let error as NSError {
                dispatch_in_calling({ handler?(false, error) })
                return
            }
            let followingUsers = followings?.filter({$0["following"] as? String != nil}).map({ $0["following"] as! String })

            if let users = users {
                var savedUserIds = [String]()
                for user in users {
                    guard let user = user as? PFUser else {
                        NSLog("user cannot be represented as PFUser")
                        continue
                    }
                    guard let userId = user.objectId else {
                        NSLog("objectId is not set for user \(user).")
                        continue
                    }
                    if userId == currentUserId {
                        continue
                    }
                    let followed = followingUsers?.indexOf(userId) != nil
                    do {
                        try User.createUpdateUser(withId: userId, name: user.username, isFollowed: followed, inContext: context)
                    } catch let error as NSError {
                        NSLog("Unable to create or update user with id \(userId) due to error: \(error.localizedDescription)")
                        continue
                    }
                    savedUserIds.append(userId)
                }
                do {
                    try self.removeUsersNotInList(savedUserIds, inContext: context)
                } catch let error as NSError {
                    NSLog("Unable to delete old users. Error: \(error.localizedDescription)")
                }
                do {
                    try context.save()
                } catch let error as NSError {
                    NSLog("Unable to save context. Error: \(error.localizedDescription)")
                }
                dispatch_in_calling({ handler?(true, nil) })
            } else {
                dispatch_in_calling({ handler?(false, nil) })
            }
        })
    }
    private func removeUsersNotInList(idsList: [String], inContext context: NSManagedObjectContext) throws {
        let request = NSFetchRequest(entityName: User.entityName)
        request.predicate = NSPredicate(format: "NOT(id IN %@)", idsList)
        let users = try! context.executeFetchRequest(request)
        for user in users {
            if let user = user as? NSManagedObject {
                context.deleteObject(user)
            }
        }
    }
}
