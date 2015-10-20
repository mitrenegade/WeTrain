//
//  LoginViewController.swift
//  WeTrain
//
//  Created by Bobby Ren on 8/2/15.
//  Copyright (c) 2015 Bobby Ren. All rights reserved.
//

import UIKit
import Parse

class LoginViewController: UIViewController, UITextFieldDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate {

    @IBOutlet var inputLogin: UITextField!
    @IBOutlet var inputPassword: UITextField!
    @IBOutlet var buttonLogin: UIButton!
    @IBOutlet var buttonSignup: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.reset()
        // Do any additional setup after loading the view.

        let tap = UITapGestureRecognizer(target: self, action: "handleGesture:")
        tap.delegate = self
        self.view.addGestureRecognizer(tap)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func reset() {
        self.inputPassword.text = nil;

        self.inputLogin.superview!.layer.borderWidth = 1;
        self.inputLogin.superview!.layer.borderColor = UIColor.lightGrayColor().CGColor;
        self.inputPassword.superview!.layer.borderWidth = 1;
        self.inputPassword.superview!.layer.borderColor = UIColor.lightGrayColor().CGColor;
    }
        
    func handleGesture(sender: UIGestureRecognizer) {
        if sender.isKindOfClass(UITapGestureRecognizer) {
            self.view.endEditing(true)
        }
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if gestureRecognizer.isKindOfClass(UITapGestureRecognizer) {
            let location: CGPoint = touch.locationInView(self.view)
            for input: UIView in [self.inputLogin, self.inputPassword, self.buttonLogin, self.buttonSignup] {
                if CGRectContainsPoint(input.frame, location) {
                    return false
                }
            }
        }
        return true
    }
    
    @IBAction func didClickLogin(sender: UIButton) {
        if self.inputLogin.text?.characters.count == 0 {
            self.simpleAlert("Please enter a login email", message: nil)
            return
        }
        if self.inputPassword.text?.characters.count == 0 {
            self.simpleAlert("Please enter a password", message: nil)
            return
        }
        
        let username: String = self.inputLogin.text!
        let password: String = self.inputPassword.text!
        PFUser.logInWithUsernameInBackground(username, password: password) { (user, error) -> Void in
            print("logged in")
            if user != nil {
                self.loggedIn()
            }
            else {
                let title = "Login error"
                var message: String?
                if error?.code == 100 {
                    message = "Please check your internet connection"
                }
                else if error?.code == 101 {
                    message = "Invalid email or password"
                }
                
                self.simpleAlert(title, message: message)
            }
        }
    }
    
    @IBAction func didClickSignup(sender: UIButton) {
        self.performSegueWithIdentifier("GoToSignup", sender: nil)
    }
    
    func loggedIn() {
        self.appDelegate().didLogin()
    }
    
    // MARK: - TextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == self.inputLogin {
            self.inputPassword.becomeFirstResponder()
            return false
        }
        else {
            textField.resignFirstResponder()
        }
        return true
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
