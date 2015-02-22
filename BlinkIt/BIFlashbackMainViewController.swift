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
    var flashbackDates:Array<NSDate>
    var flashbackBlinks:Dictionary<NSDate,PFObject>
    var flashbackVCs:Array<BIFlashbackViewController>

    
// pragma mark : lifecycle

    required init(coder aDecoder: NSCoder) {
        self.flashbackDates = []
        self.flashbackBlinks = Dictionary()
        self.flashbackVCs = []
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
        flashbackDates = flashbackDatesArray
    }
    
// pragma mark : fetch flashbacks for given dates
    
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
            self.setupPageVC()
            self.setupPageIndicator()
        }
    }
    
// pragma mark : page control
    
    func setupPageIndicator() {
        let pageControl = UIPageControl(frame: CGRectMake(0, 26, 300, 20))
        pageControl.numberOfPages = 4
        pageControl.currentPage = 0
        pageControl.userInteractionEnabled = false
        pageControl.currentPageIndicatorTintColor = UIColor.coral()
        pageControl.pageIndicatorTintColor = UIColor.lightGrayColor()
        self.pageControl = pageControl
        
        navigationItem.titleView = pageControl
    }
    
// pragma mark : pageVC

    func setupPageVC() {
        var viewControllers:Array<BIFlashbackViewController> = []
        for (date, blink) in flashbackBlinks {
            let flashbackVC = self.storyboard!.instantiateViewControllerWithIdentifier("BIFlashbackViewController") as BIFlashbackViewController
            flashbackVC.flashbackDate = date
            flashbackVC.flashbackBlink = blink
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
        var index = self.indexOfViewController(viewController, inPageController: pageViewController)
        
        if index < 1 {
            return nil;
        } else {
            return flashbackVCs[index-1]
        }
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        var index = self.indexOfViewController(viewController, inPageController: pageViewController)
        
        if index < -1 || index >= (flashbackVCs.count-1) {
            return nil;
        } else {
            return flashbackVCs[index+1]
        }
    }
    
    func pageViewController(pageViewController: UIPageViewController!, didFinishAnimating finished: Bool, previousViewControllers: [AnyObject]!, transitionCompleted completed: Bool) {
        var indexOfCurrentPage = self.indexOfViewController(pageViewController.viewControllers[0] as UIViewController, inPageController: pageViewController)
        
        if completed {
            pageControl.currentPage = indexOfCurrentPage
        }
    }
    
    func indexOfViewController(viewController: UIViewController, inPageController pageController: UIPageViewController) -> Int {
        var index = -1
        
        for var i = 0; i < flashbackVCs.count; i++ {
            let page:UIViewController = flashbackVCs[i] as UIViewController
            if page.isEqual(viewController) {
                index = i;
            }
        }
        
        return index
    }
}
