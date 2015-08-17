//
//  CreditCardViewController.swift
//  DocPronto
//
//  Created by Bobby Ren on 8/2/15.
//  Copyright (c) 2015 Bobby Ren. All rights reserved.
//

import UIKit
import Parse

class CreditCardViewController: UIViewController, UITextFieldDelegate, PTKViewDelegate {

    @IBOutlet var labelCurrentCard: UILabel!
    @IBOutlet var viewCreditCardBG: UIView!

    @IBOutlet var paymentView: PTKView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: UIBarButtonItemStyle.Done, target: self, action: "close")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: UIBarButtonItemStyle.Done, target: self, action: "save")
        self.navigationItem.rightBarButtonItem!.enabled = false

        if let last4: String = PFUser.currentUser()!.objectForKey("stripeFour") as? String{
            self.labelCurrentCard.text = "Your current credit card is *\(last4)"
            self.navigationItem.rightBarButtonItem!.title = "Update"
        }
        else {
            self.labelCurrentCard.text = "Please enter a new credit card"
        }
        

        self.paymentView!.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func close() {
        self.navigationController!.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: PTKViewDelegate
    func paymentView(paymentView: PTKView!, withCard card: PTKCard!, isValid valid: Bool) {
        println("card entered")
        self.navigationItem.rightBarButtonItem?.enabled = valid
    }
    
    func save() {
        println("save card")
        let payment: PTKCard = self.paymentView!.card
        let card: STPCard = STPCard()
        card.number = payment.number
        card.expMonth = payment.expMonth
        card.expYear = payment.expYear
        card.cvc = payment.cvc
        STPAPIClient.sharedClient().createTokenWithCard(card, completion: { (token, error) -> Void in
            if error != nil {
                println("error: \(error!.userInfo)")
                self.simpleAlert("Error updating credit card", message: "There was an error. Please try again")
            }
            else {
                self.saveToken(token!)
            }
        })
    }
    
    func saveToken(token: STPToken) {
            let tokenId: String = token.tokenId
            PFUser.currentUser()!.setObject(tokenId, forKey: "stripeToken")
            let number: String = self.paymentView!.card.number
            let last4:String = number.substringFromIndex(advance(number.endIndex, -4))
            PFUser.currentUser()!.setObject(last4, forKey: "stripeFour")
            PFUser.currentUser()!.saveInBackgroundWithBlock { (success, error) -> Void in
                if error != nil {
                    self.simpleAlert("Error saving credit card", message: "Please try again.")
                }
                else {
                    self.close()
                }
        }
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
