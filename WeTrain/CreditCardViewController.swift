//
//  CreditCardViewController.swift
//  WeTrain
//
//  Created by Bobby Ren on 8/2/15.
//  Copyright (c) 2015 Bobby Ren. All rights reserved.
//

import UIKit
import Parse

protocol CreditCardDelegate: class {
    func didSaveCreditCard()
}

class CreditCardViewController: UIViewController, UITextFieldDelegate, PTKViewDelegate {

    @IBOutlet var labelCurrentCard: UILabel!
    @IBOutlet var viewCreditCardBG: UIView!

    @IBOutlet var paymentView: PTKView?
    weak var delegate: CreditCardDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: UIBarButtonItemStyle.Done, target: self, action: "close")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: UIBarButtonItemStyle.Done, target: self, action: "save")
        self.navigationItem.rightBarButtonItem!.enabled = false

        let client: PFObject = PFUser.currentUser()!.objectForKey("client") as! PFObject
        if let last4: String = client.objectForKey("stripeFour") as? String{
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
        if self.delegate != nil {
            self.delegate!.didSaveCreditCard()
        }
        self.navigationController!.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: PTKViewDelegate
    func paymentView(paymentView: PTKView!, withCard card: PTKCard!, isValid valid: Bool) {
        print("card entered")
        self.navigationItem.rightBarButtonItem?.enabled = valid
    }
    
    func save() {
        print("save card")
        let payment: PTKCard = self.paymentView!.card
        let card: STPCard = STPCard()
        card.number = payment.number
        card.expMonth = payment.expMonth
        card.expYear = payment.expYear
        card.cvc = payment.cvc
        STPAPIClient.sharedClient().createTokenWithCard(card, completion: { (token, error) -> Void in
            if error != nil {
                var message = "There was an error. Please try again"
                print("error: \(error!.userInfo)")
                if let dict: [NSObject: AnyObject] = error!.userInfo as? [NSObject: AnyObject] {
                    if let msg: String = dict["NSLocalizedDescription"] as? String {
                        message = msg
                    }
                }
                self.simpleAlert("Error updating credit card", message: message)
            }
            else {
                self.saveToken(token!)
            }
        })
    }
    
    func saveToken(token: STPToken) {
        let client: PFObject = PFUser.currentUser()!.objectForKey("client") as! PFObject
        let tokenId: String = token.tokenId
        client.setObject(tokenId, forKey: "stripeToken")
        let number: String = self.paymentView!.cardNumber!
        let last4:String = number.substringFromIndex(number.endIndex.advancedBy(-4))
        client.setObject(last4, forKey: "stripeFour")
        client.saveInBackgroundWithBlock { (success, error) -> Void in
            if error != nil {
                self.simpleAlert("Error saving credit card", message: "Please try again.")
            }
            else {
                self.close()
            }
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
