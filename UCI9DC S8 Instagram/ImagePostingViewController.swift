//
//  ImagePostingViewController.swift
//  UCI9DC S8 Instagram
//
//  Created by Stanislav Sidelnikov on 24/03/16.
//  Copyright © 2016 Stanislav Sidelnikov. All rights reserved.
//

import UIKit

class ImagePostingViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!

    private var imagePicker = UIImagePickerController()
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(frame: self.view.frame)
        view.backgroundColor = UIColor(white: 1.0, alpha: 0.5)
        view.hidesWhenStopped = true
        view.activityIndicatorViewStyle = .Gray
        view.center = self.view.center
        self.view.addSubview(view)
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        imagePicker.delegate = self
        imagePicker.sourceType = .PhotoLibrary
        imagePicker.allowsEditing = false

        NSNotificationCenter.defaultCenter().addObserver(
            self, selector: #selector(ImagePostingViewController.keyboardWasShown(_:)),
            name: UIKeyboardDidShowNotification,
            object: nil
        )

        NSNotificationCenter.defaultCenter().addObserver(
            self, selector: #selector(ImagePostingViewController.keyboardWillBeHidden(_:)),
            name: UIKeyboardWillHideNotification,
            object: nil
        )
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func chooseImage(sender: AnyObject) {
        presentViewController(imagePicker, animated: true, completion: nil)
    }

    @IBAction func postImage(sender: AnyObject) {
        if let image = imageView.image {
            let imagesWorker = ImagesWorker()
            blockUI()
            imagesWorker.postImage(image, withComment: commentTextField.text) { (success, error) in
                self.unblockUI()
                print("Posting image. \(success), \(error?.localizedDescription)")
                self.performSegueWithIdentifier("Unwind", sender: self)
            }
        }
    }

    private func blockUI() {
        activityIndicator.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
    }

    private func unblockUI() {
        activityIndicator.stopAnimating()
        UIApplication.sharedApplication().endIgnoringInteractionEvents()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: - TextFields
    private var activeField: UITextField?

    // MARK: - Keyboard
    private let keyboardTopPadding: CGFloat = 10.0

    func keyboardWasShown(notification: NSNotification) {
        guard let info = notification.userInfo else {
            NSLog("Unable to get userInfo")
            return
        }
        guard let kbFrame = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() else {
            NSLog("Unable to get the keyboard frame")
            return
        }
        let kbSize = kbFrame.size


        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: kbSize.height + keyboardTopPadding, right: 0.0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets

        if let activeField = activeField {
            var rect = view.frame
            rect.size.height -= kbSize.height
            if !rect.contains(activeField.frame.origin) {
                scrollView.scrollRectToVisible(activeField.frame, animated: true)
            }
        }
    }

    func keyboardWillBeHidden(notification: NSNotification) {
        let contentInsets = UIEdgeInsetsZero
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
}

extension ImagePostingViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        imageView.image = image
        dismissViewControllerAnimated(true, completion: nil)
    }
}

extension ImagePostingViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(textField: UITextField) {
        activeField = textField
    }
    func textFieldDidEndEditing(textField: UITextField) {
        activeField = nil
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}


