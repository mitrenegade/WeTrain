//
//  TutorialViewController.swift
//  WeTrain
//
//  Created by Bobby Ren on 10/19/15.
//  Copyright © 2015 Bobby Ren. All rights reserved.
//

import UIKit
import Parse

class TutorialViewController: UIViewController, TutorialScrollDelegate {
    
    @IBOutlet weak var tutorialView: TutorialScrollView!
    var tutorialCreated: Bool = false
    
    var allPages: [String] = ["IntroTutorial0", "IntroTutorial1", "IntroTutorial2", "IntroTutorial3", "IntroTutorial4", "IntroTutorial5"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let right: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .Done, target: self, action: "done")
        self.navigationItem.rightBarButtonItem = right
        let left: UIBarButtonItem = UIBarButtonItem(title: "", style: .Done, target: self, action: "nothing")
        self.navigationItem.leftBarButtonItem = left
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !self.tutorialCreated {
            self.tutorialView.setTutorialPages(allPages)
            self.tutorialCreated = true
            self.tutorialView.delegate = self
        }
    }
    
    func done() {
        self.appDelegate().didLogin()
    }
    
    func nothing() {
        // hides left button
    }

    // MARK: TutorialScrollDelegate
    func didScrollToPage(page: Int32) {
        if Int(page) == self.allPages.count - 1 {
            self.navigationItem.rightBarButtonItem?.enabled = true
        }
        else {
            self.navigationItem.rightBarButtonItem?.enabled = false
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
