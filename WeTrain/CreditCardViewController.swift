//
//  CreditCardViewController.swift
//  WeTrain
//
//  Created by Bobby Ren on 8/2/15.
//  Copyright (c) 2015 Bobby Ren. All rights reserved.
//

import UIKit
import Parse
import Stripe

protocol CreditCardDelegate: class {
    func didSaveCreditCard(token: String, lastFour: String) // saved to client
}

class CreditCardViewController: UIViewController, UITextFieldDelegate, STPPaymentCardTextFieldDelegate {

    @IBOutlet var labelCurrentCard: UILabel!
    @IBOutlet var viewCreditCardBG: UIView!

    @IBOutlet var paymentView: UIView!
    var paymentTextField: STPPaymentCardTextField?
    weak var delegate: CreditCardDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: UIBarButtonItemStyle.Done, target: self, action: "close")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: UIBarButtonItemStyle.Done, target: self, action: "save")
        self.navigationItem.rightBarButtonItem!.enabled = false

        self.labelCurrentCard.text = "Please enter a new credit card"
        if let client: PFObject = PFUser.currentUser()!.objectForKey("client") as? PFObject {
            client.fetchInBackgroundWithBlock({ (clientObject, error) -> Void in
                if clientObject != nil {
                    print("client: \(clientObject)")
                    if let last4: String = clientObject!.objectForKey("stripeFour") as? String{
                        self.labelCurrentCard.text = "Your current credit card is *\(last4)"
                        self.navigationItem.rightBarButtonItem!.title = "Update"
                    }
                }
                else {
                    print("client: \(client)")
                    if let last4: String = client.objectForKey("stripeFour") as? String{
                        self.labelCurrentCard.text = "Your current credit card is *\(last4)"
                        self.navigationItem.rightBarButtonItem!.title = "Update"
                    }
                }
            })
        }

        self.paymentTextField = STPPaymentCardTextField()
        self.paymentTextField!.delegate = self
        self.paymentView.addSubview(self.paymentTextField!)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.paymentTextField!.frame = self.paymentView.frame
        self.paymentTextField!.center = CGPointMake(self.paymentView.frame.size.width/2, self.paymentView.frame.size.height/2)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func close() {
        self.navigationController!.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: PTKViewDelegate
    func paymentCardTextFieldDidChange(textField: STPPaymentCardTextField) {
        print("card entered")
        self.navigationItem.rightBarButtonItem?.enabled = true
    }
    
    func save() {
        print("save card")
        let card: STPCardParams = STPCardParams()
        card.number = self.paymentTextField!.cardNumber
        card.expMonth = self.paymentTextField!.expirationMonth
        card.expYear = self.paymentTextField!.expirationYear
        card.cvc = self.paymentTextField!.cvc
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
            else if token == nil {
                self.simpleAlert("Error updating credit card", message: "There was an unknown error. Please try again.")
            }
            else {
                self.saveToken(token!)
            }
        })
    }
    
    func saveToken(token: STPToken) {
        let tokenId: String = token.tokenId
        let number: String = self.paymentTextField!.cardNumber!
        let last4:String = number.substringFromIndex(number.endIndex.advancedBy(-4))
        if self.delegate != nil {
            self.delegate!.didSaveCreditCard(tokenId, lastFour: last4)
        }
        self.close()
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
