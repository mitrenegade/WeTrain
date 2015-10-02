//
//  TrainingRequestCell.swift
//  WeTrainers
//
//  Created by Bobby Ren on 10/1/15.
//  Copyright © 2015 Bobby Ren. All rights reserved.
//

import UIKit
import Parse

class TrainingRequestCell: UITableViewCell {
    
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelExercise: UILabel!
    @IBOutlet weak var labelDistance: UILabel!
    @IBOutlet weak var photo: UIImageView?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setupWithRequest(request: PFObject) {
        self.icon.layer.borderWidth = 1
        self.icon.layer.borderColor = UIColor.darkGrayColor().CGColor
        self.icon.layer.cornerRadius = 5
        
        let clientObj: PFObject = request.objectForKey("client") as! PFObject
        request.fetchIfNeededInBackgroundWithBlock { (object, error) -> Void in
            clientObj.fetchIfNeededInBackgroundWithBlock({ (object, error) -> Void in
                let firstName = clientObj.objectForKey("firstName") as? String
                let lastName = clientObj.objectForKey("lastName") as? String
                self.labelName.text = firstName!
                if lastName != nil {
                    self.labelName.text = "\(firstName!) \(lastName!)"
                }
            })
            
            let exercise = request.objectForKey("type") as? String
            self.labelExercise.text = exercise!
            
            let index = TRAINING_TITLES.indexOf(exercise!)
            if index != nil {
                self.icon.image = UIImage(named: TRAINING_ICONS[index!])!
            }
            else {
                self.icon.image = nil
            }

            // TODO: load distance
            // TODO: load photo
        }
    }
}
