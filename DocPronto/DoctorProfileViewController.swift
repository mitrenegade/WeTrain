//
//  DoctorProfileViewController.swift
//  DocPronto
//
//  Created by Bobby Ren on 8/4/15.
//  Copyright (c) 2015 Bobby Ren. All rights reserved.
//

import UIKit

class DoctorProfileViewController: UIViewController {

    @IBOutlet var photoView: UIImageView!
    @IBOutlet var labelName: UILabel!
    @IBOutlet var buttonMeet: UIButton!
    @IBOutlet var labelInfo: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.photoView.layer.borderWidth = 2
        self.photoView.layer.borderColor = UIColor(red: 215.0/255.0, green: 84.0/255.0, blue: 82.0/255.0, alpha: 1).CGColor
        self.photoView.layer.cornerRadius = 5
        
        self.buttonMeet.layer.cornerRadius = 5
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didClickButton(button: UIButton) {
        self.callDoctor()
    }
    
    func callDoctor() {
        var str = "tel://9192740582"
        let url = NSURL(string: str) as NSURL?
        if (url != nil) {
            UIApplication.sharedApplication().openURL(url!)
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
