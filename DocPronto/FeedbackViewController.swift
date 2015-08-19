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
    weak var picker: UIPickerView! = UIPickerView()
    
    @IBOutlet weak var keyboardShiftView: UIView!
    @IBOutlet weak var constraintTopOffset: NSLayoutConstraint!
    @IBOutlet weak var constraintBottomOffset: NSLayoutConstraint!
    
    var PICKER_TITLES = ["App issues", "Account issues", "General feedback"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.inputCategory.inputAccessoryView = self.picker
        self.picker.delegate = self
        self.picker.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - TextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
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
    
    @IBAction func didClickSubmit(sender: UIButton) {
        
    }
    
    @IBAction func didClickStar(sender: UIButton) {
        // rating stars
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
