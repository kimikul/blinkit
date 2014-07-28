//
//  BIFlashbackViewController.swift
//  BlinkIt
//
//  Created by Kimberly Hsiao on 7/27/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

import UIKit

class BIFlashbackViewController: BITableViewController, BIHomeTableViewCellDelegate {

    var segmentedControl:UISegmentedControl
    var flashbackDates:Array<NSDate>
    var flashbackBlinks:Dictionary<NSDate,PFObject>
    var currentBlink:PFObject?
    
    @IBOutlet weak var noPostsView: UIView!
    @IBOutlet weak var noPostsLabel: UILabel!
    
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
        
        let timePeriod = timeElapsedString()

        var secondaryText = "Try to blink every day so you have more to look back on :)"

        if let joinedDate = BIDataStore.shared().dateJoined() {
            let comparison = joinedDate.compare(date)
        
            if comparison == NSComparisonResult.OrderedDescending {
                secondaryText = String(format:"But it's okay because you actually haven't been on BlinkIt for that long yet :)",timePeriod)
            }
        }
        
        noPostsLabel.text = String(format: "You didn't post anything %@\n\n%@", timePeriod, secondaryText)
        noPostsView.hidden = currentBlink == nil ? false : true
        reloadTableData()
    }
   
    func timeElapsedString() -> String {
        let index = segmentedControl.selectedSegmentIndex

        var timePeriod = ""
        switch index {
        case 0:
            timePeriod = "1 month ago"
        case 1:
            timePeriod = "3 months ago"
        case 2:
            timePeriod = "6 months ago"
        case 3:
            timePeriod = "1 year ago"
        default:
            timePeriod = ""
        }
        
        return timePeriod
    }
    
// pragma mark : tableview
    
    func setupTableView() {
        tableView.registerNib(UINib(nibName: BIHomePhotoTableViewCell.reuseIdentifier(), bundle: NSBundle.mainBundle()), forCellReuseIdentifier: BIHomePhotoTableViewCell.reuseIdentifier())
        tableView.registerNib(UINib(nibName: BIHomeTableViewCell.reuseIdentifier(), bundle: NSBundle.mainBundle()), forCellReuseIdentifier: BIHomeTableViewCell.reuseIdentifier())
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
            self.segmentedControlChanged(self.segmentedControl)
        }
    }
    
// pragma mark : tableviewdelegate
    override func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        var isBlink = currentBlink != nil;
        return isBlink ? 1 : 0
    }
    
    override func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        var isBlink = currentBlink != nil;
        return isBlink ? 1 : 0
    }
    
    override func tableView(tableView: UITableView!, heightForHeaderInSection section: Int) -> CGFloat {
        return 34
    }
    
    override func tableView(tableView: UITableView!, viewForHeaderInSection section: Int) -> UIView! {
        let dateString:String = String(format:"%@, you said...",timeElapsedString())
        
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
        
        var cell:BIHomeTableViewCell?
        println("tableview is : \(tableView)")
        println("currentblink : \(currentBlink)")
        if let imageFile:PFFile = currentBlink!["imageFile"] as? PFFile {
            cell = tableView!.dequeueReusableCellWithIdentifier(BIHomePhotoTableViewCell.reuseIdentifier()) as BIHomePhotoTableViewCell
        } else {
            cell = tableView!.dequeueReusableCellWithIdentifier(BIHomeTableViewCell.reuseIdentifier()) as? BIHomeTableViewCell
        }
        
        cell!.blink = currentBlink
        cell!.delegate = self

        return cell
    }
    
// pragma mark : BIHomeTableViewCellDelegate
    
    func homeCell(feedCell: BIHomeTableViewCell!, didTapImageView imageView: UIImageView!) {
//        let expandImageHelper = BIExpandImageHelper()
//        expandImageHelper.delegate = self
//        expandImageHelper.animateImageView(imageView)
    }
    
    func homeCell(homeCell: BIHomeTableViewCell!, togglePrivacyTo `private`: Bool) {
        // do nothing
    }
    
//    func homeCellCell(feedCell: BIFeedTableViewCell!, didTapUserProfile user: PFUser!) {
//        let mainStoryboard = self.storyboard
//        
//        let profileNav:UINavigationController = mainStoryboard.instantiateViewControllerWithIdentifier("BIProfileNavigationController") as UINavigationController
//        let profileVC:BIProfileViewController = profileNav.topViewController as BIProfileViewController
//        profileVC.user = user
//        
//        presentViewController(profileNav, animated: true, completion: nil)
//    }
}
