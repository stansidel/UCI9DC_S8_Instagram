//
//  User.swift
//  UCI9DC S8 Instagram
//
//  Created by Stanislav Sidelnikov on 23/03/16.
//  Copyright © 2016 Stanislav Sidelnikov. All rights reserved.
//

import Foundation
import CoreData


class User: NSManagedObject {
    static let entityName = "User"

    static func getById(id: String, inContext context: NSManagedObjectContext) throws -> User? {
        let request = NSFetchRequest(entityName: User.entityName)
        request.predicate = NSPredicate(format: "id == %@", id)

        let objects = try! context.executeFetchRequest(request)
        return objects.first as? User
    }

    static func createUpdateUser(withId id: String, name: String?, isFollowed: Bool, inContext context: NSManagedObjectContext) throws {
        let user = try! getById(id, inContext: context)
        if let user = user {
            user.name = name
            user.followed = isFollowed
        } else {
            let user = NSEntityDescription.insertNewObjectForEntityForName(User.entityName, inManagedObjectContext: context) as! User
            user.id = id
            user.name = name
            user.followed = isFollowed
        }
    }

}
