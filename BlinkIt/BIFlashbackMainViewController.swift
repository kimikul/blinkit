//
//  BIFlashbackPageViewController.swift
//  BlinkIt
//
//  Created by Kimberly Hsiao on 7/28/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

import UIKit

class BIFlashbackMainViewController: BIViewController {

    var pageViewController:UIPageViewController?
    var testVC:UIViewController?
    
    init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        testVC = UIViewController(nibName: nil, bundle: nil)
        testVC!.view.backgroundColor = UIColor.redColor()
        addChildViewController(testVC)
        view.addSubview(testVC!.view)
        
//        pageViewController = self.storyboard.instantiateViewControllerWithIdentifier("FlashbackPageViewController") as UIPageViewController
//        let myFlashbackVC:BIFlashbackViewController = self.storyboard.instantiateViewControllerWithIdentifier("BIFlashbackViewController") as BIFlashbackViewController
//        let otherVC:UIViewController = UIViewController(nibName: nil, bundle: nil)
//        otherVC.view.backgroundColor = UIColor.blueColor()
//        pageViewController!.setViewControllers([myFlashbackVC,otherVC], direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: nil)
    }
    
}
