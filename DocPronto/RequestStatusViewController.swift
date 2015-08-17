//
//  RequestStatusViewController.swift
//  DocPronto
//
//  Created by Bobby Ren on 8/17/15.
//  Copyright (c) 2015 Bobby Ren. All rights reserved.
//

import UIKit

class RequestStatusViewController: UIViewController {

    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelMessage: UILabel!
    @IBOutlet weak var buttonTop: UIButton!
    @IBOutlet weak var buttonBottom: UIButton!
    
    @IBAction func didClickButton(sender: UIButton) {
        if sender == buttonTop {
            println("top button")
        }
        else if sender == buttonBottom {
            println("bottom button")
        }
    }
    
    func updateTitle(title: String, message: String, top: String?, bottom: String) {
        self.labelTitle.text = title
        self.labelMessage.text = message
        if top == nil {
            self.buttonTop.hidden = true
        }
        else {
            self.buttonTop.setTitle(top, forState: .Normal)
        }
        
        self.buttonBottom.setTitle(bottom, forState: .Normal)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
