//
//  UserInfoViewController.swift
//  WeTrain
//
//  Created by Bobby Ren on 10/19/15.
//  Copyright © 2015 Bobby Ren. All rights reserved.
//

import UIKit
import Parse

let genders = ["Select gender", "Male", "Female", "Lesbian", "Gay", "Bisexual", "Transgender", "Queer", "Other"]
class UserInfoViewController: UIViewController, UITextFieldDelegate, CreditCardDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UIGestureRecognizerDelegate {

    @IBOutlet var inputFirstName: UITextField!
    @IBOutlet var inputLastName: UITextField!
    @IBOutlet var inputEmail: UITextField!
    @IBOutlet var inputPhone: UITextField!
    @IBOutlet var inputGender: UITextField!
    @IBOutlet var inputAge: UITextField!
    @IBOutlet var inputInjuries: UITextField!
    @IBOutlet var inputCreditCard: UITextField!
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var viewScrollContent: UIView!
    @IBOutlet var constraintContentWidth: NSLayoutConstraint!
    @IBOutlet var constraintContentHeight: NSLayoutConstraint!
    
    @IBOutlet var constraintTopOffset: NSLayoutConstraint!
    @IBOutlet var constraintBottomOffset: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .Done, target: self, action: "didUpdateInfo:")
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
        let picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
        self.inputGender.inputView = picker

        let keyboardDoneButtonView: UIToolbar = UIToolbar()
        keyboardDoneButtonView.sizeToFit()
        keyboardDoneButtonView.barStyle = UIBarStyle.Black
        keyboardDoneButtonView.tintColor = UIColor.whiteColor()
        let button: UIBarButtonItem = UIBarButtonItem(title: "Close", style: UIBarButtonItemStyle.Done, target: self, action: "dismissKeyboard")
        let flex: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        keyboardDoneButtonView.setItems([flex, button], animated: true)
        self.inputGender.inputAccessoryView = keyboardDoneButtonView
        
        let tap = UITapGestureRecognizer(target: self, action: "handleGesture:")
        tap.delegate = self
        self.viewScrollContent.addGestureRecognizer(tap)
        let tap2 = UITapGestureRecognizer(target: self, action: "handleGesture:")
        self.view.addGestureRecognizer(tap2)

        let left: UIBarButtonItem = UIBarButtonItem(title: "", style: .Done, target: self, action: "nothing")
        self.navigationItem.leftBarButtonItem = left
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.constraintContentWidth.constant = (self.appDelegate().window?.bounds.size.width)!
        self.constraintContentHeight.constant = self.inputCreditCard.frame.origin.y + self.inputCreditCard.frame.size.height + 50
    }
    
    @IBAction func didClickAddPhoto(sender: UIButton) {
        
    }
    
    func nothing() {
        // hides left button
    }

    func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    func handleGesture(sender: UIGestureRecognizer) {
        if sender.isKindOfClass(UITapGestureRecognizer) {
            self.view.endEditing(true)
        }
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if gestureRecognizer.isKindOfClass(UITapGestureRecognizer) {
            let location: CGPoint = touch.locationInView(self.viewScrollContent)
            for input: UIView in [self.inputFirstName, self.inputLastName, self.inputEmail, self.inputPhone, self.inputGender, self.inputAge, self.inputInjuries, self.inputCreditCard] {
                if CGRectContainsPoint(input.frame, location) {
                    return false
                }
            }
        }
        return true
    }

    func didUpdateInfo(sender: AnyObject) {

        let firstName = self.inputFirstName.text
        if firstName?.characters.count == 0 {
            self.simpleAlert("Please enter your first name", message: nil)
            return
        }
        
        let email = self.inputEmail.text
        if email?.characters.count == 0 {
            self.simpleAlert("Please enter an email", message: nil)
            return
        }
        if !self.isValidEmail(email!) {
            self.simpleAlert("Please enter a valid email address", message: nil)
            return
        }
        
        let phone = self.inputPhone.text
        if phone?.characters.count == 0 {
            self.simpleAlert("Please enter a valid phone number", message: nil)
            return
        }
        /*
        let gender = self.inputGender.text
        if gender?.characters.count == 0 {
        self.simpleAlert("Please enter your gender", message: nil)
        return
        }
        
        let age = self.inputAge.text
        if age?.characters.count == 0 {
        self.simpleAlert("Please enter your age", message: nil)
        return
        }
        */
        // TODO: remove credit card restriction for initial app release
        /*
        let four = self.inputCreditCard.text
        if four?.characters.count == 0 {
        self.simpleAlert("Please enter a payment method. (For the test app, use credit card number 4242424242424242", message: nil)
        return
        }
        */
        
        // make sure user exists
        let user = PFUser.currentUser()
        if user == nil {
            self.simpleAlert("Invalid user", message: "You are not currently signed in. Please sign in again", completion: { () -> Void in
                self.appDelegate().goToLogin()
            })
        }
        
        // load existing trainer or create one
        var client: PFObject!
        if let clientObject: PFObject = PFUser.currentUser()!.objectForKey("client") as? PFObject {
            client = clientObject
            client.fetchInBackgroundWithBlock({ (object, error) -> Void in
                if error != nil {
                    self.simpleAlert("Error fetching your profile", message: "We could not load your profile to update it.", completion: nil)
                    return
                }
                else {
                    self.updateClientProfile(client)
                }
            })
        }
        else {
            client = PFObject(className: "Client")
            self.updateClientProfile(client)
        }
    }
    
    func updateClientProfile(client: PFObject) {
        // create trainer object
        var clientDict = ["firstName": self.inputFirstName.text!, "email": self.inputEmail.text!, "phone": self.inputPhone.text!];
        if self.inputLastName.text != nil {
            clientDict["lastName"] = self.inputLastName.text!
        }
        if self.inputAge.text != nil {
            clientDict["age"] = self.inputAge.text!
        }
        if self.inputGender.text != nil {
            clientDict["gender"] = self.inputGender.text!
        }
        if self.inputInjuries.text != nil {
            clientDict["injuries"] = self.inputInjuries.text!
        }
        client.setValuesForKeysWithDictionary(clientDict)
        let user = PFUser.currentUser()!
        client.setObject(user, forKey: "user")
        
        client.saveInBackgroundWithBlock { (success, error) -> Void in
            if error != nil {
                self.simpleAlert("Error creating profile", message: "We could not create your user profile.", completion: nil)
                return
            }
            else {
                user.setObject(client, forKey: "client")
                user.saveInBackgroundWithBlock({ (success, error) -> Void in
                    if success {
                        print("signup succeeded")
                        self.performSegueWithIdentifier("GoToTutorial", sender: nil)
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
                })
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
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        if textField == self.inputCreditCard {
            self.view.endEditing(true)
            self.goToCreditCard()
            return false
        }
        return true
    }
    
    func goToCreditCard() {
        let nav = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("CreditCardNavigationController") as! UINavigationController
        let controller: CreditCardViewController = nav.viewControllers[0] as! CreditCardViewController
        controller.delegate = self
        
        self.presentViewController(nav, animated: true) { () -> Void in
        }
    }
    
    // MARK: - CreditCardDelegate
    func didSaveCreditCard() {
        let client: PFObject = PFUser.currentUser()!.objectForKey("client") as! PFObject
        if let last4: String = client.objectForKey("stripeFour") as? String{
            self.inputCreditCard.text = "Credit Card: *\(last4)"
        }
    }
    
    // MARK: - UIPickerViewDelegate
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 9 // MFLGBTQO
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        print("row: \(row)")
        print("genders \(genders)")
        return genders[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row == 0 {
            self.inputGender.text = nil
        }
        self.inputGender.text = genders[row]
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