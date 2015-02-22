//
//  BIFlashbackMainViewController.swift
//  BlinkIt
//
//  Created by Kimberly Hsiao on 7/28/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

import UIKit

class BIFlashbackMainViewController: BIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    var pageViewController:UIPageViewController!
    var pageControl:UIPageControl!
    var navTitleLabel:UILabel!
    var possibleFlashbackDates:Array<NSDate>    // all 4 possible flashback dates
    var flashbackBlinks:Array<PFObject>         // blinks for flashback dates
    var existingFlashbackDates:Array<NSDate>    // dates with actual blinks associated
    var flashbackVCs:Array<BIFlashbackViewController>

    
// pragma mark : lifecycle

    required init(coder aDecoder: NSCoder) {
        self.possibleFlashbackDates = []
        self.flashbackBlinks = []
        self.flashbackVCs = []
        self.existingFlashbackDates = []
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController!.navigationBar.translucent = false
        calculateFlashbackDates()
        fetchFlashbacks()
    }
    
// pragma mark : flashback dates
    
    func calculateFlashbackDates() {
        let today = NSDate()
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
        
        var flashbackDatesArray:Array<NSDate> = [oneMonthAgo!,threeMonthsAgo!,sixMonthsAgo!,oneYearAgo!]
        possibleFlashbackDates = flashbackDatesArray
    }
    
// pragma mark : fetch flashbacks for given dates
    
    func fetchFlashbacks() {
        let begOneMonthDate = possibleFlashbackDates[0]
        let endOneMonthDate = NSDate.endOfDay(possibleFlashbackDates[0])
        let begThreeMonthsDate = possibleFlashbackDates[1]
        let endThreeMonthsDate = NSDate.endOfDay(possibleFlashbackDates[1])
        let begSixMonthsDate = possibleFlashbackDates[2]
        let endSixMonthsDate = NSDate.endOfDay(possibleFlashbackDates[2])
        let begOneYearDate = possibleFlashbackDates[3]
        let endOneYearDate = NSDate.endOfDay(possibleFlashbackDates[3])
        
        let predicate = NSPredicate(format: "((date >= %@) AND (date < %@)) OR ((date >= %@) AND (date < %@)) OR ((date >= %@) AND (date < %@)) OR ((date >= %@) AND (date < %@))", begOneMonthDate, endOneMonthDate, begThreeMonthsDate, endThreeMonthsDate, begSixMonthsDate, endSixMonthsDate, begOneYearDate, endOneYearDate)
        
        let query = PFQuery(className: "Blink", predicate: predicate)
        query.whereKey("user", equalTo: PFUser.currentUser())
        query.includeKey("user")
        query.orderByDescending("date")
        
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            var blinksArray:Array<PFObject> = []
            var datesArray:Array<NSDate> = []
            
            for blink in objects {
                let truncatedDate = NSDate.beginningOfDay(blink["date"] as NSDate)
                datesArray.append(truncatedDate)
                blinksArray.append(blink as PFObject)
            }
            
            self.flashbackBlinks = blinksArray
            self.existingFlashbackDates = datesArray
            
            self.setupPageVC()
            self.setupPageIndicator()
        }
    }
    
// pragma mark : page control
    
    func setupPageIndicator() {
        let titleView = UIView(frame: CGRectMake(0, 0, 300, 44))
        
        let navTitle = UILabel(frame: CGRectMake(0, 2, 300, 24))
        navTitle.text = NSDate.elapsedTimeFromFlashbackIndex(self.flashbackVCs[0].dateIndex)
        navTitle.textColor = UIColor.darkGrayColor()
        navTitle.textAlignment = NSTextAlignment.Center
        navTitle.font = UIFont.boldSystemFontOfSize(17)
        navTitleLabel = navTitle
        titleView.addSubview(navTitle)
        
        let pageControl = UIPageControl(frame: CGRectMake(0, 24, 300, 20))
        pageControl.numberOfPages = 4
        pageControl.currentPage = 0
        pageControl.userInteractionEnabled = false
        pageControl.currentPageIndicatorTintColor = UIColor.coral()
        pageControl.pageIndicatorTintColor = UIColor.whiteColor()
        titleView.addSubview(pageControl)
        
        self.pageControl = pageControl
        
        navigationItem.titleView = titleView
    }
    
// pragma mark : pageVC

    func setupPageVC() {
        var viewControllers:Array<BIFlashbackViewController> = []
        for var i = 0; i < existingFlashbackDates.count; i++ {
            let date = existingFlashbackDates[i]
            let blink = flashbackBlinks[i]
            
            let flashbackVC = self.storyboard!.instantiateViewControllerWithIdentifier("BIFlashbackViewController") as BIFlashbackViewController
            flashbackVC.flashbackDate = date
            flashbackVC.flashbackBlink = blink
            flashbackVC.dateIndex = self.indexOfObject(date, inArray: possibleFlashbackDates)
            viewControllers.append(flashbackVC)
        }
        
        flashbackVCs = viewControllers
        
        pageViewController = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
        pageViewController.dataSource = self;
        pageViewController.delegate = self;

        pageViewController.setViewControllers([flashbackVCs[0]], direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion:nil)

        addChildViewController(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.didMoveToParentViewController(self)
    }

    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {

        var index = self.indexOfObject(viewController, inArray:flashbackVCs)
        
        if index < 1 {
            return nil;
        } else {
            return flashbackVCs[index-1]
        }
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {

        var index = self.indexOfObject(viewController, inArray:flashbackVCs)
        if index < -1 || index >= (flashbackVCs.count-1) {
            return nil;
        } else {
            return flashbackVCs[index+1]
        }
    }
    
    func pageViewController(pageViewController: UIPageViewController!, didFinishAnimating finished: Bool, previousViewControllers: [AnyObject]!, transitionCompleted completed: Bool) {
        let currentPage:BIFlashbackViewController = pageViewController.viewControllers[0] as BIFlashbackViewController
        
        let indexOfCurrentPage = self.indexOfObject(currentPage, inArray: flashbackVCs)
        
        if completed {
            pageControl.currentPage = indexOfCurrentPage
            navTitleLabel.text = NSDate.elapsedTimeFromFlashbackIndex(currentPage.dateIndex)
            navTitleLabel.fadeTransitionWithDuration(0.4)
        }
    }
    
// pragma mark - helpers
    
    func indexOfObject(obj: AnyObject, inArray array:Array<AnyObject>) -> Int {
        var index = -1
        
        for var i = 0; i < array.count; i++ {
            let page:AnyObject = array[i]
            if page.isEqual(obj) {
                index = i;
            }
        }
        
        return index
    }
}
