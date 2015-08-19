//
//  FeedbackViewController.swift
//  DocPronto
//
//  Created by Bobby Ren on 8/19/15.
//  Copyright (c) 2015 Bobby Ren. All rights reserved.
//

import UIKit

class FeedbackViewController: UIViewController, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate {

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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func resetStars() {
        for star: UIButton in self.stars {
            star.setImage(UIImage(named: "star")?.imageWithRenderingMode(.AlwaysTemplate), forState: UIControlState.Normal)
            star.tintColor = UIColor.blackColor()
        }
    }
    
    // MARK: - TextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        if count(self.inputEmail.text) > 0 {
            self.navigationItem.rightBarButtonItem?.enabled = true
        }
        else {
            self.navigationItem.rightBarButtonItem?.enabled = false
        }
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
            star.tintColor = UIColor(red: 55/255.0, green: 123/255.0, blue: 181/255.0, alpha: 1)
        }
    }
    
    func close() {
        self.navigationController!.presentingViewController!.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func submit() {
        let email = self.inputEmail.text
        let category = self.inputCategory.text
        let message = self.inputMessage.text
        let rating = self.rating
        println("email: \(email) category: \(category) message: \(message) rating: \(rating)")
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
