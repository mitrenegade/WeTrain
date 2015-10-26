//
//  RequestStatusViewController.swift
//  WeTrain
//
//  Created by Bobby Ren on 8/17/15.
//  Copyright (c) 2015 Bobby Ren. All rights reserved.
//

import UIKit
import Parse

typealias RequestStatusButtonHandler = () -> Void

class RequestStatusViewController: UIViewController {

    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelMessage: UILabel!
    @IBOutlet weak var buttonTop: UIButton!
    @IBOutlet weak var buttonBottom: UIButton!
    
    @IBOutlet weak var constraintDetailsHeight: NSLayoutConstraint!
    
    @IBOutlet weak var progressView: ProgressView!
    
    var state: RequestState = .NoRequest
    var currentRequest: PFObject?
    var currentTrainer: PFObject?
    
    var timer: NSTimer?

    var topButtonHandler: RequestStatusButtonHandler? = nil
    var bottomButtonHandler: RequestStatusButtonHandler? = nil
    
    var trainerController: TrainerProfileViewController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        if let previousState: String = self.currentRequest?.objectForKey("status") as? String{
            let newState: RequestState = RequestState(rawValue: previousState)!
            if newState == RequestState.Matched {
                self.goToTrainerInfo()
                return
            }
            else {
                self.updateRequestState()
            }
        }
        
        if self.timer == nil {
            self.timer = NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: "updateRequestState", userInfo: nil, repeats: true)
            self.timer?.fire()
        }
    }
    
    @IBAction func didClickButton(sender: UIButton) {
        if sender == buttonTop {
            print("top button")
            if self.topButtonHandler != nil {
                self.topButtonHandler!()
            }
        }
        else if sender == buttonBottom {
            print("bottom button")
            if self.bottomButtonHandler != nil {
                self.bottomButtonHandler!()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateRequestState() {
        let client: PFObject = PFUser.currentUser()!.objectForKey("client") as! PFObject
        if let request: PFObject = client.objectForKey("currentRequest") as? PFObject {
            request.fetchInBackgroundWithBlock({ (object, error) -> Void in
                self.currentRequest = object
                if self.currentRequest == nil {
                    // if request is still nil, then it got cancelled/deleted somehow.
                    self.toggleRequestState(.NoRequest)
                    return
                }
                
                if let previousState: String = self.currentRequest!.objectForKey("status") as? String{
                    let newState: RequestState = RequestState(rawValue: previousState)!
                    
                    if let trainer: PFObject = request.objectForKey("trainer") as? PFObject {
                        trainer.fetchInBackgroundWithBlock({ (object, error) -> Void in
                            print("trainer: \(object) newState: \(newState.rawValue)")
                            self.currentTrainer = trainer
                            self.toggleRequestState(newState)
                        })
                    }
                    else {
                        self.toggleRequestState(newState)
                    }
                }
            })
        }
    }

    func updateTitle(title: String, message: String, top: String?, bottom: String, topHandler: RequestStatusButtonHandler?, bottomHandler: RequestStatusButtonHandler) {
        self.labelTitle.text = title
        self.labelMessage.text = message

        let string:NSString = self.labelMessage.text! as NSString
        let bounds = CGSizeMake(self.labelMessage.frame.size.width, 500)
        let rect = string.boundingRectWithSize(bounds, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName:self.labelMessage.font], context:nil)
        self.constraintDetailsHeight.constant = rect.size.height;

        self.labelMessage.superview!.layoutSubviews()
        
        if top == nil {
            self.buttonTop.hidden = true
        }
        else {
            self.buttonTop.hidden = false
            self.buttonTop.setTitle(top!, forState: .Normal)
        }
        
        self.buttonBottom.setTitle(bottom, forState: .Normal)
        
        self.topButtonHandler = topHandler
        self.bottomButtonHandler = bottomHandler
    }
    
    
    func toggleRequestState(newState: RequestState) {
        self.state = newState
        print("going to state \(newState.rawValue)")
        
        switch self.state {
        case .NoRequest:
            let title = "No current workout"
            let message = "You're not currently in a workout or waiting for a trainer. Please click OK to go back to the training menu."
            self.updateTitle(title, message: message, top: nil, bottom: "Close", topHandler: nil, bottomHandler: { () -> Void in
                // dismiss the current stack and go back
                self.navigationController!.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
            })
            
            if self.timer != nil {
                self.timer!.invalidate()
                self.timer = nil
            }
            self.progressView.stopActivity()
        case .Cancelled:
            // request state is set to .NoRequest if cancelled from an app action.
            // "cancelled" state is set on the web in order to trigger this state
            let title = "Search was cancelled"
            var message: String? = self.currentRequest!.objectForKey("cancelReason") as? String
            if message == nil {
                message = "You have cancelled the training session. You have not been charged for this training session since no trainer was matched. Please click OK to go back to the training menu."
            }
            
            self.currentRequest = nil
            self.updateTitle(title, message: message!, top: nil, bottom: "OK", topHandler: nil, bottomHandler: { () -> Void in
                // dismiss the current stack and go back
                self.navigationController!.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
            })
            
            if self.timer != nil {
                self.timer!.invalidate()
                self.timer = nil
            }
            self.progressView.stopActivity()
        case .Searching:
            
            var title = "Calling all trainers near you"
            var message = "Please be patient while we connect you with a trainer. Meanwhile, you can make sure you have all your gear."
            if let addressString: String = self.currentRequest?.objectForKey("address") as? String {
                title = "Calling all trainers near:"
                message = "\(addressString)\n\n\(message)"
            }
            self.updateTitle(title, message: message, top: nil, bottom: "Cancel Request", topHandler: nil, bottomHandler: { () -> Void in
                self.promptForCancel()
            })
            self.progressView.startActivity()
        case .Matched:
            let title = "Trainer found"
            let message = "You have been matched with a trainer!"
            self.updateTitle(title, message: message, top: nil, bottom: "Cancel Request", topHandler: nil, bottomHandler: { () -> Void in
            })
            self.goToTrainerInfo()
            if self.timer != nil {
                self.timer!.invalidate()
                self.timer = nil
            }
            self.progressView.stopActivity()
        case .Training:
            let title = "Training in session"
            let message = ""
            self.updateTitle(title, message: message, top: nil, bottom: "Cancel Request", topHandler: nil, bottomHandler: { () -> Void in
            })
            self.goToTrainerInfo()
            if self.timer != nil {
                self.timer!.invalidate()
                self.timer = nil
            }
            self.progressView.stopActivity()
        default:
            break
        }
    }

    func goToTrainerInfo() {
        if self.trainerController != nil {
            return
        }
        print("display info")
        if let trainer: PFObject = self.currentRequest!.objectForKey("trainer") as? PFObject {
            trainer.fetchInBackgroundWithBlock({ (object, error) -> Void in
                print("trainer: \(object)")
                self.currentTrainer = trainer
                self.performSegueWithIdentifier("GoToViewTrainer", sender: nil)
            })
        }
    }
    
    func promptForCancel() {
        let alert = UIAlertController(title: "Cancel request?", message: "Are you sure you want to cancel your training request?", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Cancel training", style: .Cancel, handler: { (action) -> Void in
            if self.currentRequest != nil {
                self.currentRequest!.setObject(RequestState.Cancelled.rawValue, forKey: "status")
                self.currentRequest!.saveInBackgroundWithBlock({ (success, error) -> Void in
                    self.toggleRequestState(RequestState.Cancelled)
                })
            }
        }))
        alert.addAction(UIAlertAction(title: "Keep waiting", style: .Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let controller: TrainerProfileViewController = segue.destinationViewController as! TrainerProfileViewController
        controller.request = self.currentRequest
        controller.trainer = self.currentTrainer
        
        self.trainerController = controller
    }

}
