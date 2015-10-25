//
//  ProgressView.swift
//  WeTrain
//
//  Created by Bobby Ren on 10/25/15.
//  Copyright © 2015 Bobby Ren. All rights reserved.
//

import UIKit

class ProgressView: UIView {
    
    let pageControl: UIPageControl = UIPageControl()
    var timer: NSTimer?
    var currentProgress: Int = -1

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

    override func awakeFromNib() {
        super.awakeFromNib()
        self.addSubview(pageControl)
        self.pageControl.numberOfPages = 5
        self.pageControl.hidden = true
        self.pageControl.pageIndicatorTintColor = UIColor.blackColor()
        self.pageControl.currentPageIndicatorTintColor = UIColor(red: 83.0/255.0, green: 221.0/255.0, blue: 159.0/255.0, alpha: 1)
    }
    
    func startActivity() {
        self.pageControl.hidden = false
        if self.timer != nil {
            return
        }
        
        self.currentProgress = -1
        self.timer = NSTimer.scheduledTimerWithTimeInterval(0.25, target: self, selector: "tick", userInfo: nil, repeats: true)
    }
    
    func stopActivity() {
        if self.timer != nil {
            self.timer!.invalidate()
            self.timer = nil
        }
        self.pageControl.hidden = true
        self.currentProgress = -1
    }
    
    func tick() {
        self.pageControl.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2)
        
        self.currentProgress = self.currentProgress + 1
        if self.currentProgress >= self.pageControl.numberOfPages {
            self.currentProgress = 0
        }
        self.pageControl.currentPage = self.currentProgress
    }
    
    
}
