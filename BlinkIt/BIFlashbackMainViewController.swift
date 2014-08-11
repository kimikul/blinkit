//
//  BIFlashbackMainViewController.swift
//  BlinkIt
//
//  Created by Kimberly Hsiao on 7/28/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

import UIKit

class BIFlashbackMainViewController: BIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    var segmentedControl:UISegmentedControl
    var pageViewController:UIPageViewController!
    var feedFlashbackVC:BIFlashbackFeedViewController!
    var myFlashbackVC:BIFlashbackViewController!
    var flashbackDates:Array<NSDate>
    var pageControl:UIPageControl!
    
// pragma mark : lifecycle

    required init(coder aDecoder: NSCoder!) {
        self.segmentedControl = UISegmentedControl(items: ["1 mo","3 mo","6 mo","1 yr"])
        self.flashbackDates = []
        
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController.navigationBar.translucent = false
        setupSegmentedControl()
        setupPageVC()
        calculateFlashbackDates()
    }
    
// pragma mark : flashback dates
    
    func calculateFlashbackDates() {
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
        
        let flashbackDatesArray:Array<NSDate> = [oneMonthAgo,threeMonthsAgo,sixMonthsAgo,oneYearAgo]
        flashbackDates = flashbackDatesArray
        
        myFlashbackVC.flashbackDates = flashbackDatesArray
        myFlashbackVC.fetchFlashbacks()
        
        feedFlashbackVC.flashbackDates = flashbackDatesArray
        feedFlashbackVC.fetchFlashbackFeed()
    }
    
// pragma mark : segmented control
    
    func setupSegmentedControl() {
        let titleView = UIView(frame: CGRectMake(0, 0, 300, 44))
        segmentedControl.frame = CGRectMake(0, 2, 220, 26)
        segmentedControl.center.x = titleView.center.x
        segmentedControl.addTarget(self, action: "segmentedControlChanged:", forControlEvents: UIControlEvents.ValueChanged)
        titleView.addSubview(segmentedControl)
        
        let pageControl = UIPageControl(frame: CGRectMake(0, 26, 300, 20))
        pageControl.numberOfPages = 2
        pageControl.currentPage = 0
        pageControl.userInteractionEnabled = false
        pageControl.currentPageIndicatorTintColor = UIColor.coral()
        pageControl.pageIndicatorTintColor = UIColor.lightGrayColor()
        self.pageControl = pageControl
        titleView.addSubview(pageControl)
        
        navigationItem.titleView = titleView
    }
    
    func segmentedControlChanged(segmentedControl: UISegmentedControl) {
        myFlashbackVC.segmentedControlChanged(segmentedControl)
        feedFlashbackVC.segmentedControlChanged(segmentedControl)
    }
    
// pragma mark : pageVC

    func setupPageVC() {
        myFlashbackVC = self.storyboard.instantiateViewControllerWithIdentifier("BIFlashbackViewController") as BIFlashbackViewController
        myFlashbackVC.segmentedControl = segmentedControl
        
        feedFlashbackVC = self.storyboard.instantiateViewControllerWithIdentifier("BIFlashbackFeedViewController") as BIFlashbackFeedViewController
        feedFlashbackVC.segmentedControl = segmentedControl
        
        pageViewController = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
        pageViewController.dataSource = self;
        pageViewController.delegate = self;
        
        let viewControllers:NSArray = [myFlashbackVC]
        pageViewController.setViewControllers(viewControllers, direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion:nil)
        
        addChildViewController(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.didMoveToParentViewController(self)
    }
    
    func pageViewController(pageViewController: UIPageViewController!, viewControllerBeforeViewController viewController: UIViewController!) -> UIViewController! {
        if viewController.isEqual(feedFlashbackVC) {
            return myFlashbackVC
        }
        
        return nil
    }
    
    func pageViewController(pageViewController: UIPageViewController!, viewControllerAfterViewController viewController: UIViewController!) -> UIViewController! {
        if viewController.isEqual(myFlashbackVC) {
            return feedFlashbackVC
        }
        
        return nil
    }
    
    func pageViewController(pageViewController: UIPageViewController!, didFinishAnimating finished: Bool, previousViewControllers: [AnyObject]!, transitionCompleted completed: Bool) {
        if completed {
            if previousViewControllers[0].isEqual(myFlashbackVC) {
                pageControl.currentPage = 1
            } else {
                pageControl.currentPage = 0
            }
        }
    }
}
