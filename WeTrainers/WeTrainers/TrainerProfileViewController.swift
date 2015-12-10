//
//  TrainerProfileViewController.swift
//  WeTrain
//
//  Created by Bobby Ren on 8/4/15.
//  Copyright (c) 2015 Bobby Ren. All rights reserved.
//

import UIKit
import Parse
import MessageUI

class TrainerProfileViewController: UIViewController {

    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var labelName: UILabel!
    
    @IBOutlet weak var viewInfo: UIView!
    @IBOutlet weak var labelInfo: UITextView!
    
    var trainer: PFObject?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.photoView.layer.borderWidth = 2
        self.photoView.layer.borderColor = UIColor(red: 112/255.0, green: 150/255.0, blue: 67/255.0, alpha: 1).CGColor
        self.photoView.layer.cornerRadius = 5
        
        self.viewInfo.layer.borderWidth = 1
        self.viewInfo.layer.borderColor = UIColor(red: 112/255.0, green: 150/255.0, blue: 67/255.0, alpha: 1).CGColor
        self.viewInfo.layer.cornerRadius = 5

        self.setTitleBarColor(UIColor.blackColor(), tintColor: UIColor.whiteColor())
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]

        let user = PFUser.currentUser()!
        self.trainer = user.objectForKey("trainer") as! PFObject
        trainer?.fetchInBackgroundWithBlock({ (object, error) -> Void in
            self.updateTrainerInfo()
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateTrainerInfo() {
        if let file = self.trainer!.objectForKey("photo") as? PFFile {
            file.getDataInBackgroundWithBlock { (data, error) -> Void in
                if data != nil {
                    let photo: UIImage = UIImage(data: data!)!
                    self.photoView.image = photo
                }
            }
        }
        let firstName = self.trainer!.objectForKey("firstName") as? String
        let lastName = self.trainer!.objectForKey("lastName") as? String
        self.labelName.text = firstName!
        if lastName != nil {
            self.labelName.text = "About me: \(firstName!) \(lastName!)"
        }
  
        var infoText = ""
        if let bio: String = self.trainer!.objectForKey("bio") as? String {
            infoText = "\(bio)\n\n"
        }
        self.labelInfo.text = infoText
        self.labelInfo.contentOffset = CGPointMake(0, 0)
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
