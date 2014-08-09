//
//  BIFlashbackPageViewController.swift
//  BlinkIt
//
//  Created by Kimberly Hsiao on 7/28/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

import UIKit

@objc protocol FlashbackSegmentedControlDelegate {
    func segmentedControlChanged(segmentedControl:UISegmentedControl)
}

class BIFlashbackMainViewController: BIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    var segmentedControl:UISegmentedControl
    var pageViewController:UIPageViewController!
    var testVC:UIViewController?
    var myFlashbackVC:BIFlashbackViewController!

// pragma mark : lifecycle

    init(coder aDecoder: NSCoder!) {
        self.segmentedControl = UISegmentedControl(items: ["1 mo","3 mo","6 mo","1 yr"])
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController.navigationBar.translucent = false
        setupSegmentedControl()
        setupPageVC()
    }
    
// pragma mark : segmented control
    
    func setupSegmentedControl() {
        navigationItem.titleView = segmentedControl
        segmentedControl.addTarget(self, action: "segmentedControlChanged:", forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func segmentedControlChanged(segmentedControl: UISegmentedControl) {
        let visibleVC:FlashbackSegmentedControlDelegate = pageViewController.viewControllers[0] as FlashbackSegmentedControlDelegate
        visibleVC.segmentedControlChanged(segmentedControl)
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
    
// pragma mark : pageVC

    func setupPageVC() {
        testVC = UIViewController(nibName: nil, bundle: nil)
        testVC!.view.backgroundColor = UIColor.redColor()
        
        myFlashbackVC = self.storyboard.instantiateViewControllerWithIdentifier("BIFlashbackViewController") as BIFlashbackViewController
        myFlashbackVC.segmentedControl = segmentedControl
        
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
        if viewController.isEqual(testVC) {
            return myFlashbackVC
        }
        
        return nil
    }
    
    func pageViewController(pageViewController: UIPageViewController!, viewControllerAfterViewController viewController: UIViewController!) -> UIViewController! {
        if viewController.isEqual(myFlashbackVC) {
            return testVC
        }
        
        return nil
    }
}
