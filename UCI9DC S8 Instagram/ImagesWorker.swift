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
        let object = PFObject(className: "PhotoEntry")
        object["user"] = currentUserId
        object["comment"] = comment
        object["image"] = file

        object.saveInBackgroundWithBlock { (success, error) in
            handler?(success, error)
        }
    }
}