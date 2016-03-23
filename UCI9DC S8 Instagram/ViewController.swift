//
//  ViewController.swift
//  UCI9DC S8 Instagram
//
//  Created by Stanislav Sidelnikov on 20/03/16.
//  Copyright © 2016 Stanislav Sidelnikov. All rights reserved.
//

import UIKit
import Parse

class ViewController: UIViewController {
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var modeSwitchButton: UIButton!
    @IBOutlet weak var modeSwitchLabel: UILabel!
    
    private var activityIndicator: UIActivityIndicatorView?
    
    enum FormMode {
        case Registration
        case Login
    }
    private var currentMode = FormMode.Registration

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setMode(.Registration)
        setActivityIndicator()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        activityIndicator?.center = self.view.center
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if PFUser.currentUser() != nil {
            performSegueWithIdentifier("Login", sender: self)
        }
    }
    
    @IBAction func actionButtonPressed(sender: UIButton) {
        if checkFieldsAndShowError() {
            switch currentMode {
            case .Registration:
                signupUser()
            case .Login:
                loginUser()
            }
        }
    }
    
    @IBAction func switchModeButtonPressed(sender: UIButton) {
        setMode(currentMode == .Registration ? .Login : .Registration)
    }
    
    private func setMode(mode: FormMode) {
        currentMode = mode
        switch mode {
        case .Registration:
            actionButton.setTitle(NSLocalizedString("Sign Up", comment: "Action button on the auth form for registration"), forState: .Normal)
            modeSwitchButton.setTitle(NSLocalizedString("Login", comment: "Mode switch button on the auth form for registration"), forState: .Normal)
            modeSwitchLabel.text = NSLocalizedString("Already registered?", comment: "Mode switch label text for registration")
        case .Login:
            actionButton.setTitle(NSLocalizedString("Log In", comment: "Action button on the auth form for login"), forState: .Normal)
            modeSwitchButton.setTitle(NSLocalizedString("Signup", comment: "Mode switch button on the auth form for login"), forState: .Normal)
            modeSwitchLabel.text = NSLocalizedString("Don't have an account", comment: "Mode switch label text for login")
        }
    }
    
    private func setActivityIndicator() {
        let view = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        view.hidesWhenStopped = true
        view.activityIndicatorViewStyle = .Gray
        view.center = self.view.center
        self.view.addSubview(view)
    }
    
    private func startBlockingUI() {
        activityIndicator?.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
    }
    
    private func stopBlockingUI() {
        UIApplication.sharedApplication().endIgnoringInteractionEvents()
        activityIndicator?.stopAnimating()
    }
    
    private func signupUser() {
        startBlockingUI()
        let user = PFUser()
        user.username = usernameTextField.text
        user.password = passwordTextField.text
        user.signUpInBackgroundWithBlock { (success, error) -> Void in
            self.stopBlockingUI()
            if success {
                self.performSegueWithIdentifier("Login", sender: self)
            } else {
                var errorMessage = NSLocalizedString("Please try again later", comment: "Auth form general network error")
                if let error = error {
                    errorMessage = error.localizedDescription
                }
                let errorTitle = NSLocalizedString("Failed Signup", comment: "Auth form signup failed error title")
                self.displayError(withTitle: errorTitle, message: errorMessage)
            }
        }
    }
    
    private func loginUser() {
        startBlockingUI()
        PFUser.logInWithUsernameInBackground(usernameTextField.text!, password: passwordTextField.text!) { (user, error) -> Void in
            self.stopBlockingUI()
            if error == nil {
                self.performSegueWithIdentifier("Login", sender: self)
            } else {
                var errorMessage = NSLocalizedString("Please try again later", comment: "Auth form general network error")
                if let error = error {
                    errorMessage = error.localizedDescription
                }
                let errorTitle = NSLocalizedString("Failed Login", comment: "Auth form login failed error title")
                self.displayError(withTitle: errorTitle, message: errorMessage)
            }

        }
    }
    
    private func checkFieldsAndShowError() -> Bool {
        if (usernameTextField.text ?? "").isEmpty || (passwordTextField.text ?? "").isEmpty {
            displayError(withTitle: NSLocalizedString("Form error", comment: "Auth form error title"), message: NSLocalizedString("You must fill in username and password", comment: "Auth form error message - username and password"))
            return false
        }
        return true
    }
    
    private func displayError(withTitle title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alertController.addAction(
            UIAlertAction(title: NSLocalizedString("OK", comment: "Auth form error alert action"), style: .Default, handler: { (action) -> Void in
                self.dismissViewControllerAnimated(true, completion: nil)
            })
        )
        presentViewController(alertController, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

