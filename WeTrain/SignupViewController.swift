//
//  SignupViewController.swift
//  WeTrainers
//
//  Created by Bobby Ren on 9/24/15.
//  Copyright © 2015 Bobby Ren. All rights reserved.
//

import UIKit
import Parse

class SignupViewController: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate {
    @IBOutlet var inputUsername: UITextField!
    @IBOutlet var inputPassword: UITextField!
    @IBOutlet var inputConfirmation: UITextField!
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var viewScrollContent: UIView!
    @IBOutlet var constraintContentWidth: NSLayoutConstraint!
    @IBOutlet var constraintContentHeight: NSLayoutConstraint!
    
    @IBOutlet var constraintTopOffset: NSLayoutConstraint!
    @IBOutlet var constraintBottomOffset: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .Done, target: self, action: "didSignup:")

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)

        self.scrollView.scrollEnabled = false

        let tap = UITapGestureRecognizer(target: self, action: "handleGesture:")
        tap.delegate = self
        self.viewScrollContent.addGestureRecognizer(tap)
        let tap2 = UITapGestureRecognizer(target: self, action: "handleGesture:")
        self.view.addGestureRecognizer(tap2)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .Done, target: self, action: "close")
    }
    
    func close() {
        self.navigationController!.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.constraintContentWidth.constant = (self.appDelegate().window?.bounds.size.width)!
        self.constraintContentHeight.constant = self.inputConfirmation.frame.origin.y + self.inputConfirmation.frame.size.height + 50
    }

    func handleGesture(sender: UIGestureRecognizer) {
        if sender.isKindOfClass(UITapGestureRecognizer) {
            self.view.endEditing(true)
        }
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if gestureRecognizer.isKindOfClass(UITapGestureRecognizer) {
            let location: CGPoint = touch.locationInView(self.viewScrollContent)
            for input: UIView in [self.inputUsername, self.inputPassword, self.inputConfirmation] {
                if CGRectContainsPoint(input.frame, location) {
                    return false
                }
            }
        }
        return true
    }
    
    func didSignup(sender: AnyObject) {
        if self.inputUsername.text?.characters.count == 0 {
            self.simpleAlert("Please enter a username", message: nil)
            return
        }
        if self.inputPassword.text?.characters.count == 0 {
            self.simpleAlert("Please enter a password", message: nil)
            return
        }
        if self.inputConfirmation.text?.characters.count == 0 {
            self.simpleAlert("Please enter a password confirmation", message: nil)
            return
        }
        if self.inputConfirmation.text! != self.inputPassword.text! {
            self.simpleAlert("Please make sure password matches confirmation", message: nil)
            return
        }
        
        let username = self.inputUsername.text
        let password = self.inputPassword.text
        
        let user = PFUser()
        user.username = username
        user.password = password
        
        user.signUpInBackgroundWithBlock { (success, error) -> Void in
            if success {
                print("signup succeeded")
                self.performSegueWithIdentifier("GoToUserInfo", sender: nil)
            }
            else {
                let title = "Signup error"
                var message: String?
                if error?.code == 100 {
                    message = "Please check your internet connection"
                }
                else if error?.code == 202 {
                    message = "Username already taken"
                }
                
                self.simpleAlert(title, message: message)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - keyboard notifications
    func keyboardWillShow(n: NSNotification) {
        let size = n.userInfo![UIKeyboardFrameBeginUserInfoKey]?.CGRectValue.size
        
//        self.constraintTopOffset.constant = -size!.height
        self.constraintBottomOffset.constant = size!.height
        self.view.layoutIfNeeded()
    }
    
    func keyboardWillHide(n: NSNotification) {
        self.constraintTopOffset.constant = 0
        self.constraintBottomOffset.constant = 0
        
        self.view.layoutIfNeeded()
    }
    
    // MARK: - TextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == self.inputUsername {
            self.inputPassword.becomeFirstResponder()
        }
        else if textField == self.inputPassword {
            self.inputConfirmation.becomeFirstResponder()
        }
        else {
            textField.resignFirstResponder()
        }
        return true
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        return true
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "GoToUserInfo" {
            let controller: UserInfoViewController = segue.destinationViewController as! UserInfoViewController
            controller.isSignup = true
        }
    }

}
