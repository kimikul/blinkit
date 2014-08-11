//
//  BIFlashbackViewController.swift
//  BlinkIt
//
//  Created by Kimberly Hsiao on 7/27/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

import UIKit

class BIFlashbackViewController: BIMyBlinksBaseViewController {

    var segmentedControl:UISegmentedControl!
    var flashbackBlinks:Dictionary<NSDate,PFObject>
    var flashbackDates:Array<NSDate>

    @IBOutlet weak var noPostsView: UIView!
    @IBOutlet weak var noPostsLabel: UILabel!
    
// pragma mark : lifecycle
    
    required init(coder aDecoder: NSCoder!) {
        self.flashbackBlinks = Dictionary()
        self.flashbackDates = []
        super.init(coder: aDecoder)
        
        self.useEmptyTableFooter = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

// pragma mark : segmented control

    func segmentedControlChanged(segmentedControl: UISegmentedControl) {
        let index = segmentedControl.selectedSegmentIndex
        let date = flashbackDates[index]
        if let currentBlink = flashbackBlinks[date] {
            self.allBlinksArray = NSMutableArray(object: currentBlink)
        } else {
            self.allBlinksArray = nil
        }
        
        let timePeriod = NSDate.elapsedTimeFromFlashbackIndex(index)
        
        var secondaryText = "Try to blink every day so you have more to look back on :)"
        
        if let joinedDate = BIDataStore.shared().dateJoined() {
            let comparison = joinedDate.compare(date)
            
            if comparison == NSComparisonResult.OrderedDescending {
                secondaryText = String(format:"But it's okay because you actually haven't been on BlinkIt for that long yet :)",timePeriod)
            }
        }
        
        noPostsLabel.text = String(format: "You didn't post anything %@\n\n%@", timePeriod, secondaryText)
        reloadTableData()
    }
    
// pragma mark : requests
    
    func fetchFlashbacks() {
        let begOneMonthDate = flashbackDates[0]
        let endOneMonthDate = NSDate.endOfDay(flashbackDates[0])
        let begThreeMonthsDate = flashbackDates[1]
        let endThreeMonthsDate = NSDate.endOfDay(flashbackDates[1])
        let begSixMonthsDate = flashbackDates[2]
        let endSixMonthsDate = NSDate.endOfDay(flashbackDates[2])
        let begOneYearDate = flashbackDates[3]
        let endOneYearDate = NSDate.endOfDay(flashbackDates[3])
        
        let predicate = NSPredicate(format: "((date >= %@) AND (date < %@)) OR ((date >= %@) AND (date < %@)) OR ((date >= %@) AND (date < %@)) OR ((date >= %@) AND (date < %@))", begOneMonthDate, endOneMonthDate, begThreeMonthsDate, endThreeMonthsDate, begSixMonthsDate, endSixMonthsDate, begOneYearDate, endOneYearDate)
        
        let query = PFQuery(className: "Blink", predicate: predicate)
        query.whereKey("user", equalTo: PFUser.currentUser())
        query.includeKey("user")
        
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            var blinksDict = Dictionary<NSDate, PFObject>()
            for blink in objects {
                let truncatedDate = NSDate.beginningOfDay(blink["date"] as NSDate)
                blinksDict[truncatedDate] = blink as? PFObject
            }
            
            self.flashbackBlinks = blinksDict
            self.segmentedControl.selectedSegmentIndex = 0
            self.segmentedControlChanged(self.segmentedControl)
        }
    }

    override func tableView(tableView: UITableView!, heightForHeaderInSection section: Int) -> CGFloat {
        return 34
    }
    
    override func tableView(tableView: UITableView!, viewForHeaderInSection section: Int) -> UIView! {
        let dateString:String = String(format:"%@, you said...",NSDate.elapsedTimeFromFlashbackIndex(segmentedControl.selectedSegmentIndex))
        
        let headerView = UIView(frame: CGRectMake(0, 0, 320, 34))
        headerView.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
        headerView.layer.borderColor = UIColor.whiteColor().CGColor
        headerView.layer.borderWidth = 3.0
        
        let dateLabel = UILabel(frame: CGRectMake(10, 0, 300, 34))
        dateLabel.text = dateString
        dateLabel.font = UIFont(name: "Thonburi", size: 17)
        dateLabel.textColor = UIColor(white: 0.5, alpha: 1)
        headerView.addSubview(dateLabel)
        
        return headerView
    }

}
