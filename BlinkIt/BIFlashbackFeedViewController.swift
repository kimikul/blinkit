//
//  BIFlashbackFeedViewController.swift
//  BlinkIt
//
//  Created by Kimberly Hsiao on 8/10/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

import UIKit

class BIFlashbackFeedViewController: BIFeedBaseViewController {
    
    var segmentedControl:UISegmentedControl!
    var flashbackDates:Array<NSDate>
    var blinksDict:Dictionary<NSDate, Array<PFObject>>!

    required init(coder aDecoder: NSCoder!) {
        self.flashbackDates = []

        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
// pragma mark : segmented control
    
    func segmentedControlChanged(segmentedControl: UISegmentedControl) {
        let index = segmentedControl.selectedSegmentIndex
        let date = flashbackDates[index]
        if let currentBlinks = blinksDict[date] {
            var mutableCurrentBlinks = NSMutableArray(array: currentBlinks)
            self.blinksArray = mutableCurrentBlinks
            
            var mutableDateArray = NSMutableArray(object: date)
            self.dateArray = mutableDateArray
        } else {
            self.blinksArray = nil
            self.dateArray = nil
        }
        
//        noPostsLabel.text = "No blinks from that day"
        reloadTableData()
    }

    func fetchFlashbackFeed() {
        let begOneMonthDate = flashbackDates[0]
        let endOneMonthDate = NSDate.endOfDay(flashbackDates[0])
        let begThreeMonthsDate = flashbackDates[1]
        let endThreeMonthsDate = NSDate.endOfDay(flashbackDates[1])
        let begSixMonthsDate = flashbackDates[2]
        let endSixMonthsDate = NSDate.endOfDay(flashbackDates[2])
        let begOneYearDate = flashbackDates[3]
        let endOneYearDate = NSDate.endOfDay(flashbackDates[3])
        
        let predicate = NSPredicate(format: "((date >= %@) AND (date < %@)) OR ((date >= %@) AND (date < %@)) OR ((date >= %@) AND (date < %@)) OR ((date >= %@) AND (date < %@))", begOneMonthDate, endOneMonthDate, begThreeMonthsDate, endThreeMonthsDate, begSixMonthsDate, endSixMonthsDate, begOneYearDate, endOneYearDate)
        
        var followedFriends:Array<String> = BIDataStore.shared().followedFriends() as Array<String>
        if let myID:String = PFUser.currentUser().objectForKey("facebookID") as? String {
            followedFriends.append(myID)
            
            let followedUsers = PFUser.query()
            followedUsers.whereKey("facebookID", containedIn: followedFriends)
            
            let query = PFQuery(className: "Blink", predicate: predicate)
            query.whereKey("user", matchesQuery: followedUsers)
            query.whereKey("private", equalTo: false)
            query.includeKey("user")
            query.orderByDescending("date")
            
            query.findObjectsInBackgroundWithBlock {
                (objects: [AnyObject]!, error: NSError!) -> Void in
                var newBlinksDict = Dictionary<NSDate, Array<PFObject>>()
                for blink in objects {
                    let truncatedDate = NSDate.beginningOfDay(blink["date"] as NSDate)
                    
                    if let existingBlinksForDate = newBlinksDict[truncatedDate] {
                        var mutableExistingBlinksForDate = existingBlinksForDate
                    } else {
                        var blinksForDate:Array<PFObject> = [blink]
                        newBlinksDict[truncatedDate] = blinksForDate
                    }
                }
                
                self.blinksDict = newBlinksDict
                self.segmentedControl.selectedSegmentIndex = self.segmentedControl.selectedSegmentIndex
                self.segmentedControlChanged(self.segmentedControl)
            }
        }
    }
}
