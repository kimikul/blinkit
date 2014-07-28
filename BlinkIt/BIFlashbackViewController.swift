//
//  BIFlashbackViewController.swift
//  BlinkIt
//
//  Created by Kimberly Hsiao on 7/27/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

import UIKit

class BIFlashbackViewController: BITableViewController {

    var segmentedControl:UISegmentedControl
    var flashbackBlinks:Dictionary<NSDate,PFObject>
    
// pragma mark : lifecycle
    
    init(coder aDecoder: NSCoder!) {
        self.segmentedControl = UISegmentedControl(items: ["1 mo","3 mo","6 mo","1 yr"])
        self.flashbackBlinks = Dictionary()
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupSegmentedControl()
        self.fetchFlashbacks()
    }
    
// pragma mark : segmented control
    
    func setupSegmentedControl() {
        self.navigationItem.titleView = segmentedControl
        self.segmentedControl.selectedSegmentIndex = 0
        self.segmentedControl.addTarget(self, action: "segmentedControlChanged:", forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func segmentedControlChanged(segmentedControl: UISegmentedControl) {
        
    }
    
// requests
    func calculateFlashbackDates() -> Array<NSDate> {
        let today = NSDate.date()
        let dateComponents = NSDateComponents()
        
        dateComponents.month = -1
        let oneMonthAgo = NSCalendar.currentCalendar().dateByAddingComponents(dateComponents, toDate: today, options: nil)
        println("one month ago = \(oneMonthAgo)")
        
        dateComponents.month = -3
        let threeMonthsAgo = NSCalendar.currentCalendar().dateByAddingComponents(dateComponents, toDate: today, options: nil)
        
        dateComponents.month = -6
        let sixMonthsAgo = NSCalendar.currentCalendar().dateByAddingComponents(dateComponents, toDate: today, options: nil)
        
        dateComponents.month = 0
        dateComponents.year = -1
        let oneYearAgo = NSCalendar.currentCalendar().dateByAddingComponents(dateComponents, toDate: today, options: nil)
        
        return [oneMonthAgo,threeMonthsAgo,sixMonthsAgo,oneYearAgo]
    }
    
    func fetchFlashbacks() {
        let flashbackDates:Array<NSDate> = self.calculateFlashbackDates()

        let begOneMonthDate = NSDate.beginningOfDay(flashbackDates[0])
        let endOneMonthDate = NSDate.endOfDay(flashbackDates[0])
        let begThreeMonthsDate = NSDate.beginningOfDay(flashbackDates[1])
        let endThreeMonthsDate = NSDate.endOfDay(flashbackDates[1])
        let begSixMonthsDate = NSDate.beginningOfDay(flashbackDates[2])
        let endSixMonthsDate = NSDate.endOfDay(flashbackDates[2])
        let begOneYearDate = NSDate.beginningOfDay(flashbackDates[3])
        let endOneYearDate = NSDate.endOfDay(flashbackDates[3])
        
        println("flashback dates : \(flashbackDates)")
        println("beg: \(begOneMonthDate) \nend: \(endOneMonthDate)")
        
        let predicate = NSPredicate(format: "((date >= %@) AND (date < %@)) OR ((date >= %@) AND (date < %@)) OR ((date >= %@) AND (date < %@)) OR ((date >= %@) AND (date < %@))", begOneMonthDate, endOneMonthDate, begThreeMonthsDate, endThreeMonthsDate, begSixMonthsDate, endSixMonthsDate, begOneYearDate, endOneYearDate)
        
        let query = PFQuery(className: "Blink", predicate: predicate)
        query.whereKey("user", equalTo: PFUser.currentUser())
        query.orderByDescending("date")

        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            var blinksDict = Dictionary<NSDate, PFObject>()
            for blink in objects {
                blinksDict[blink["date"] as NSDate] = blink as? PFObject
            }
            
            println("blink dict is \(blinksDict)")
        }
    }
}
