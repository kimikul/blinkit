//
//  BIHashtagViewController.swift
//  BlinkIt
//
//  Created by Kimberly Hsiao on 4/3/15.
//  Copyright (c) 2015 hsiao. All rights reserved.
//

import UIKit

class BIHashtagViewController: BIFeedBaseViewController {
    var hashtag:NSString?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = self.hashtag
        
        self.setupButtons()
        self.fetchBlinks()
    }

    func setupButtons() {
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: Selector("tappedDone:"))
        self.navigationItem.rightBarButtonItem = doneButton
    }
    
    func tappedDone(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func fetchBlinks() {
        if let hash = self.hashtag {
            var query = PFQuery(className: "Blink")
            
            query.whereKey("hashtags", containsAllObjectsInArray:[hash])
            query.orderByDescending("date")
            query.includeKey("user")
            query.findObjectsInBackgroundWithBlock({ (objects: [AnyObject]!, error) -> Void in
                self.allBlinksArray = NSMutableArray(array: objects)
                self.sectionalizeBlinks(self.allBlinksArray, pagination: false)
            })
        }

    }
}
