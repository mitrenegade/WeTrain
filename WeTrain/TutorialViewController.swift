//
//  TutorialViewController.swift
//  WeTrain
//
//  Created by Bobby Ren on 10/19/15.
//  Copyright © 2015 Bobby Ren. All rights reserved.
//

import UIKit
import Parse

protocol TutorialDelegate: class {
    func didCloseTutorial()
}

class TutorialViewController: UIViewController, TutorialScrollDelegate {
    
    @IBOutlet weak var tutorialView: TutorialScrollView!
    var tutorialCreated: Bool = false
    weak var delegate: TutorialDelegate?
    var bgView: UIImageView?
    
    var allPages: [String] = ["IntroTutorial0", "IntroTutorial1", "IntroTutorial2", "IntroTutorial3", "IntroTutorial4", "IntroTutorial5", "IntroTutorial6"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let right: UIBarButtonItem = UIBarButtonItem(title: "Start", style: .Done, target: self, action: "start")
        self.navigationItem.rightBarButtonItem = right

        self.navigationItem.rightBarButtonItem?.enabled = false
        
        self.bgView = UIImageView(image: UIImage(named: "runnerBG")!)
        self.bgView!.frame = self.view.frame
        self.view.insertSubview(self.bgView!, atIndex: 0)
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
        var frame = self.view.frame
        frame.origin.y = 0
        self.bgView!.frame = frame
    }
    
    func start() {
        self.delegate!.didCloseTutorial()
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "tutorial:seen")
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
