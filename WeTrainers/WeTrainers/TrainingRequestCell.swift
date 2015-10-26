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
        
        request.fetchIfNeededInBackgroundWithBlock { (object, error) -> Void in
            let clientObj: PFObject = request.objectForKey("client") as! PFObject
            clientObj.fetchIfNeededInBackgroundWithBlock({ (object, error) -> Void in
                let firstName = clientObj.objectForKey("firstName") as? String
                let lastName = clientObj.objectForKey("lastName") as? String
                self.labelName.text = firstName!
                if lastName != nil {
                    self.labelName.text = "\(firstName!) \(lastName!)"
                }
            })
            
            let exercise = request.objectForKey("type") as? String

            var ago: String = ""
            if let time = request.objectForKey("time") as? NSDate {
                var minElapsed:Int = Int(NSDate().timeIntervalSinceDate(time) / 60)
                let hourElapsed:Int = Int(minElapsed / 60)
                minElapsed = Int(minElapsed) - Int(hourElapsed * 60)
                if minElapsed < 0 {
                    minElapsed = 0
                }
                ago = ", \(hourElapsed)h \(minElapsed)m ago"
            }
            
            self.labelExercise.text = "\(exercise!)\(ago)"
            
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
