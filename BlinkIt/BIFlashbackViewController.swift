//
//  BIFlashbackViewController.swift
//  BlinkIt
//
//  Created by Kimberly Hsiao on 7/27/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

import UIKit

class BIFlashbackViewController: BITableViewController, BIFeedTableViewCellDelegate {

    var segmentedControl:UISegmentedControl
    var flashbackDates:Array<NSDate>
    var flashbackBlinks:Dictionary<NSDate,PFObject>
    var currentBlink:PFObject?
    
// pragma mark : lifecycle
    
    init(coder aDecoder: NSCoder!) {
        self.segmentedControl = UISegmentedControl(items: ["1 mo","3 mo","6 mo","1 yr"])
        self.flashbackBlinks = Dictionary()
        self.flashbackDates = []
        
        super.init(coder: aDecoder)
        
        self.useEmptyTableFooter = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSegmentedControl()
        setupTableView()
        fetchFlashbacks()
    }

// pragma mark : segmented control
    
    func setupSegmentedControl() {
        navigationItem.titleView = segmentedControl
        segmentedControl.addTarget(self, action: "segmentedControlChanged:", forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func segmentedControlChanged(segmentedControl: UISegmentedControl) {
        let index = segmentedControl.selectedSegmentIndex
        let date = flashbackDates[index]
        currentBlink = flashbackBlinks[date]
        reloadTableData()
    }
   
// pragma mark : tableview
    
    func setupTableView() {
        tableView.registerNib(UINib(nibName: BIFeedPhotoTableViewCell.reuseIdentifier(), bundle: NSBundle.mainBundle()), forCellReuseIdentifier: BIFeedPhotoTableViewCell.reuseIdentifier())
        tableView.registerNib(UINib(nibName: BIFeedTableViewCell.reuseIdentifier(), bundle: NSBundle.mainBundle()), forCellReuseIdentifier: BIFeedTableViewCell.reuseIdentifier())
    }
    
// pragma mark : requests
    
    func calculateFlashbackDates() -> Array<NSDate> {
        let today = NSDate.date()
        let dateComponents = NSDateComponents()
        
        dateComponents.month = -1
        var oneMonthAgo = NSCalendar.currentCalendar().dateByAddingComponents(dateComponents, toDate: today, options: nil)
        oneMonthAgo = NSDate.beginningOfDay(oneMonthAgo)
        
        dateComponents.month = -3
        var threeMonthsAgo = NSCalendar.currentCalendar().dateByAddingComponents(dateComponents, toDate: today, options: nil)
        threeMonthsAgo = NSDate.beginningOfDay(threeMonthsAgo)

        dateComponents.month = -6
        var sixMonthsAgo = NSCalendar.currentCalendar().dateByAddingComponents(dateComponents, toDate: today, options: nil)
        sixMonthsAgo = NSDate.beginningOfDay(sixMonthsAgo)

        dateComponents.month = 0
        dateComponents.year = -1
        var oneYearAgo = NSCalendar.currentCalendar().dateByAddingComponents(dateComponents, toDate: today, options: nil)
        oneYearAgo = NSDate.beginningOfDay(oneYearAgo)

        return [oneMonthAgo,threeMonthsAgo,sixMonthsAgo,oneYearAgo]
    }
    
    func fetchFlashbacks() {
        flashbackDates = self.calculateFlashbackDates()

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
            self.reloadTableData()
        }
    }
    
// pragma mark : tableviewdelegate
    override func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return 1;
    }
    
    override func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        var isBlink = currentBlink != nil;
        return isBlink ? 1 : 0
    }
    
    override func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        var height:CGFloat = 0
        let content:String = currentBlink!["content"] as String
        
        if let imageFile:PFFile = currentBlink!["imageFile"] as? PFFile {
            height = BIFeedPhotoTableViewCell.heightForContent(content)
        } else {
            height = BIFeedTableViewCell.heightForContent(content)
        }
        
        return height;
    }
    
    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        
        var cell:BIFeedTableViewCell?
        println("tableview is : \(tableView)")
        println("currentblink : \(currentBlink)")
        if let imageFile:PFFile = currentBlink!["imageFile"] as? PFFile {
            cell = tableView!.dequeueReusableCellWithIdentifier(BIFeedPhotoTableViewCell.reuseIdentifier()) as BIFeedPhotoTableViewCell
        } else {
            cell = tableView!.dequeueReusableCellWithIdentifier(BIFeedTableViewCell.reuseIdentifier()) as? BIFeedTableViewCell
        }
        
        cell!.blink = currentBlink
        cell!.delegate = self

        return cell
    }
    
// pragma mark : BIFeedTableViewCellDelegate
    
    func feedCell(feedCell: BIFeedTableViewCell!, didTapImageView imageView: UIImageView!) {
        
    }
    
    func feedCell(feedCell: BIFeedTableViewCell!, didTapUserProfile user: PFUser!) {
        
    }
}
