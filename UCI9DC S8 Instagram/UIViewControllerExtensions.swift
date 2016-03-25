//
//  ViewControllerExtensions.swift
//  UCI9DC S8 Instagram
//
//  Created by Stanislav Sidelnikov on 25/03/16.
//  Copyright © 2016 Stanislav Sidelnikov. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func displayError(withTitle title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alertController.addAction(
            UIAlertAction(title: NSLocalizedString("OK", comment: "Auth form error alert action"), style: .Default, handler: { (action) -> Void in
                self.dismissViewControllerAnimated(true, completion: nil)
            })
        )
        presentViewController(alertController, animated: true, completion: nil)
    }
}