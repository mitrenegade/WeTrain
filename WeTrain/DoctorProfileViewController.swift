//
//  DoctorProfileViewController.swift
//  WeTrain
//
//  Created by Bobby Ren on 8/4/15.
//  Copyright (c) 2015 Bobby Ren. All rights reserved.
//

import UIKit
import Parse

class DoctorProfileViewController: UIViewController {

    @IBOutlet var photoView: UIImageView!
    @IBOutlet var labelName: UILabel!
    @IBOutlet var buttonMeet: UIButton!
    @IBOutlet var labelInfo: UILabel!
    
    var doctor: PFObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.photoView.layer.borderWidth = 2
        self.photoView.layer.borderColor = UIColor(red: 215.0/255.0, green: 84.0/255.0, blue: 82.0/255.0, alpha: 1).CGColor
        self.photoView.layer.cornerRadius = 5
        
        self.buttonMeet.layer.cornerRadius = 5
        
        doctor?.fetchInBackgroundWithBlock({ (object, error) -> Void in
            self.updateDoctorInfo()
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateDoctorInfo() {
        let file = self.doctor!.objectForKey("photo") as! PFFile
        file.getDataInBackgroundWithBlock { (data, error) -> Void in
            if data != nil {
                let photo: UIImage = UIImage(data: data!)!
                self.photoView.image = photo
            }
        }
        let name = self.doctor!.objectForKey("name") as! String
        self.labelName.text = "Meet Dr. \(name)"
        
        let cred = self.doctor!.objectForKey("credentials") as! String
        let spec = self.doctor!.objectForKey("specialty") as! String
        let text: String = "Credentials: \(cred)\nSpecialty: \(spec)\n\nEstimated Time of Arrival: NOW"
        
        var attributedString = NSMutableAttributedString(string: text, attributes: [NSFontAttributeName: UIFont(name: "HelveticaNeue", size: 16)!])
        let string = text as NSString
        var range = string.rangeOfString("Credentials:")
        attributedString.addAttribute(NSFontAttributeName, value: UIFont(name: "HelveticaNeue-Bold", size: 16)!, range: range)
        range = string.rangeOfString("Specialty:")
        attributedString.addAttribute(NSFontAttributeName, value: UIFont(name: "HelveticaNeue-Bold", size: 16)!, range: range)
        range = string.rangeOfString("Estimated Time of Arrival:")
        attributedString.addAttribute(NSFontAttributeName, value: UIFont(name: "HelveticaNeue-Bold", size: 16)!, range: range)
        
        self.labelInfo.attributedText = attributedString
    }
    
    @IBAction func didClickButton(button: UIButton) {
        self.callDoctor()
    }
    
    func callDoctor() {
        if var phone: String = self.doctor!.objectForKey("phone") as? String {
            phone = phone.stringByReplacingOccurrencesOfString("(", withString: "").stringByReplacingOccurrencesOfString(")", withString: "").stringByReplacingOccurrencesOfString("-", withString: "").stringByReplacingOccurrencesOfString(" ", withString: "")
            var str = "tel://\(phone)"
            let url = NSURL(string: str) as NSURL?
            if (url != nil) {
                UIApplication.sharedApplication().openURL(url!)
                return
            }
        }
        
        let name = self.doctor!.objectForKey("name") as! String
        self.simpleAlert("Could not call phone", message: "The number we had for Dr. \(name) was invalid.")
    }

    func simpleAlert(title: String?, message: String?) {
        var alert: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
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
