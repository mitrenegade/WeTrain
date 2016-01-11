//
//  FeedbackViewController.swift
//  WeTrain
//
//  Created by Bobby Ren on 8/19/15.
//  Copyright (c) 2015 Bobby Ren. All rights reserved.
//

import UIKit
import Parse

class FeedbackViewController: UIViewController, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var inputEmail: UITextField!
    @IBOutlet weak var inputCategory: UITextField!
    @IBOutlet weak var inputMessage: UITextView!
    var picker: UIPickerView! = UIPickerView()
    
    @IBOutlet weak var keyboardShiftView: UIView!
    @IBOutlet weak var constraintTopOffset: NSLayoutConstraint!
    @IBOutlet weak var constraintBottomOffset: NSLayoutConstraint!
    
    @IBOutlet weak var star1: UIButton!
    @IBOutlet weak var star2: UIButton!
    @IBOutlet weak var star3: UIButton!
    @IBOutlet weak var star4: UIButton!
    @IBOutlet weak var star5: UIButton!
    var stars: [UIButton] = [UIButton]()
    
    var PICKER_TITLES = ["Select a category", "App issues", "Account issues", "General feedback"]
    
    var rating: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.inputCategory.inputView = self.picker
        self.picker.delegate = self
        self.picker.dataSource = self
        
        let left = UIBarButtonItem(title: "Close", style: UIBarButtonItemStyle.Done, target: self, action: "close")
        self.navigationItem.leftBarButtonItem = left
        let right = UIBarButtonItem(title: "Submit", style: UIBarButtonItemStyle.Done, target: self, action: "submit")
        self.navigationItem.rightBarButtonItem = right
        
        self.navigationItem.rightBarButtonItem?.enabled = false

        // input/text types
        let keyboardDoneButtonView: UIToolbar = UIToolbar()
        keyboardDoneButtonView.sizeToFit()
        keyboardDoneButtonView.barStyle = UIBarStyle.Black
        keyboardDoneButtonView.tintColor = UIColor.whiteColor()
        let button: UIBarButtonItem = UIBarButtonItem(title: "Close", style: UIBarButtonItemStyle.Done, target: self, action: "dismissKeyboard")
        let flex: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        keyboardDoneButtonView.setItems([flex, button], animated: true)
        self.inputMessage.inputAccessoryView = keyboardDoneButtonView
        
        self.inputMessage.layer.borderWidth = 1
        self.inputMessage.layer.borderColor = UIColor.lightGrayColor().CGColor
        
        self.stars = [star1, star2, star3, star4, star5]

        if (PFUser.currentUser() != nil) {
            if PFUser.currentUser()!.email != nil {
                self.inputEmail.text = PFUser.currentUser()!.email
                self.navigationItem.rightBarButtonItem?.enabled = true
            }
            else if PFUser.currentUser()!.username != nil {
                let usernameString: NSString = PFUser.currentUser()!.username! as NSString
                if usernameString.isValidEmail() {
                    self.inputEmail.text = usernameString as String
                    self.navigationItem.rightBarButtonItem?.enabled = true
                }
            }
        }
        
        let tap = UITapGestureRecognizer(target: self, action: "handleGesture:")
        tap.delegate = self
        self.keyboardShiftView.addGestureRecognizer(tap)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func handleGesture(sender: UIGestureRecognizer) {
        if sender.isKindOfClass(UITapGestureRecognizer) {
            self.view.endEditing(true)
        }
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if gestureRecognizer.isKindOfClass(UITapGestureRecognizer) {
            let location: CGPoint = touch.locationInView(self.view)
            for input: UIView in [self.inputEmail, self.inputCategory, self.inputMessage] {
                if CGRectContainsPoint(input.frame, location) {
                    return false
                }
            }
        }
        return true
    }
    
    func resetStars() {
        for star: UIButton in self.stars {
            star.setImage(UIImage(named: "star")?.imageWithRenderingMode(.AlwaysTemplate), forState: UIControlState.Normal)
            star.tintColor = UIColor.blackColor()
        }
    }
    
    // MARK: - TextFieldDelegate
    func textFieldDidEndEditing(textField: UITextField) {
        if textField == self.inputEmail {
            if self.inputEmail.text?.characters.count > 0 {
                self.navigationItem.rightBarButtonItem?.enabled = true
            }
            else {
                self.navigationItem.rightBarButtonItem?.enabled = false
            }
        }
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    // MARK: - TextViewDelegate
    func dismissKeyboard() {
        self.inputMessage.resignFirstResponder()
    }
    
    // MARK: - PickerViewDelegate
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return PICKER_TITLES.count
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return PICKER_TITLES[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row == 0 {
            self.inputCategory.text = nil
        }
        self.inputCategory.text = self.pickerView(pickerView, titleForRow: row, forComponent: component)
        self.inputCategory.resignFirstResponder()
    }
    
    // MARK: - Rating
    @IBAction func didClickStar(sender: UIButton) {
        // rating stars
        self.resetStars()
        for var i=0; i<sender.tag; i++ {
            let star: UIButton = self.stars[i]
            star.tintColor = UIColor(red: 94/255.0, green: 221/255.0, blue: 161/255.0, alpha: 1)
        }
        self.rating = sender.tag as Int
    }
    
    func close() {
        self.navigationController!.presentingViewController!.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func submit() {
        let email = self.inputEmail.text
        let emailString: NSString = email as! NSString
        if !emailString.isValidEmail() {
            self.simpleAlert("Please enter a valid email so we can get back to you!", message: nil)
            return
        }
        let category = self.inputCategory.text
        let rating = self.rating
        var message = self.inputMessage.text
        print("email: \(email) category: \(category) message: \(message) rating: \(rating)")

        var dict: [String: AnyObject] = ["email": email!]
        
        let info = NSBundle.mainBundle().infoDictionary as [NSObject: AnyObject]?
        let version: AnyObject = info!["CFBundleShortVersionString"]!
        message = "\(message)\n\nVersion: \(version)"
        if PFUser.currentUser() != nil && PFUser.currentUser()?.objectId != nil {
            message = "\(message)\nUser id: \(PFUser.currentUser()!.objectId!)"
            dict["user"] = PFUser.currentUser()!
        }
        dict["message"] = message
        
        if category!.characters.count > 0 {
            dict["category"] = category
        }
        if rating > 0 {
            dict["rating"] = rating
        }
        let feedback: PFObject = PFObject(className: "Feedback", dictionary: dict)
        feedback.saveInBackgroundWithBlock { (success, error) -> Void in
            if success {
                self.simpleAlert("Thanks!", message: "Your feedback has been submitted", completion: { () -> Void in
                    self.navigationController!.presentingViewController!.dismissViewControllerAnimated(true, completion: nil)
                })
            }
            else {
                self.simpleAlert("Error submitting feedback", message: "There was an issue sending your feedback. Please try again!")
            }
        }
    }
    
    func notifyByEmail() {
        // this currently works with our mandrill account. There is a limit of 2000 free messages.
        let params = ["toEmail":"bobbyren@gmail.com","toName":"Bobby Ren","fromEmail":"bobbyren@gmail.com","fromName":"Bobby Ren","text":"testing ManDrill email","subject":"this is just a test"]
        PFCloud.callFunctionInBackground("sendMail", withParameters: params) { (results, error) -> Void in
            print("results: \(results) error: \(error)")
        }
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
