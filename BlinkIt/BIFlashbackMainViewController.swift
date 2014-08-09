//
//  BIFlashbackPageViewController.swift
//  BlinkIt
//
//  Created by Kimberly Hsiao on 7/28/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

import UIKit

class BIFlashbackMainViewController: BIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    var pageViewController:UIPageViewController!
    var testVC:UIViewController?
    var myFlashbackVC:UIViewController!
    
    init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController.navigationBar.translucent = false
        setupPageVC()
    }
    
    func setupPageVC() {
        testVC = UIViewController(nibName: nil, bundle: nil)
        testVC!.view.backgroundColor = UIColor.redColor()
        
        myFlashbackVC = self.storyboard.instantiateViewControllerWithIdentifier("BIFlashbackViewController") as BIFlashbackViewController
        
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
