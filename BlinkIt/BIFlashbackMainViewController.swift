//
//  BIFlashbackMainViewController.swift
//  BlinkIt
//
//  Created by Kimberly Hsiao on 7/28/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

import UIKit

class BIFlashbackMainViewController: BIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, UISearchControllerDelegate, UISearchBarDelegate, UISearchResultsUpdating {

    var flashbackPageViewController:UIPageViewController!
    var pageControl:UIPageControl!
    
    var navTitleLabel:UILabel!
    
    var currentDate:NSDate!
    var possibleFlashbackDates:Array<NSDate>    // all 4 possible flashback dates
    var existingFlashbackDates:Array<NSDate>    // dates with actual blinks associated
    var flashbackBlinks:Array<PFObject>         // blinks for flashback dates
    var flashbackVCs:Array<BIFlashbackViewController>   // vcs for flashback blinks
    
    var searchBar: UISearchBar!
    var searchController: BISearchController!
    var searchResultsVC: BIFlashbackSearchResultsViewController!
    var searchButton:UIBarButtonItem!
    var isSearching:Bool!
    
    @IBOutlet weak var noFlashbacksView: UIView!
    
// pragma mark : lifecycle

    required init(coder aDecoder: NSCoder) {
        self.possibleFlashbackDates = []
        self.flashbackBlinks = []
        self.flashbackVCs = []
        self.existingFlashbackDates = []
        self.isSearching = false
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController!.navigationBar.translucent = false
        
        self.setupSearch()
        self.setupNotifications()
        self.refreshData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.checkIfRefreshIsNecessary()
    }
    
    func setupSearch() {
        self.searchButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Search, target: self, action: "searchTapped:")
        self.navigationItem.rightBarButtonItem = self.searchButton
        
        var searchResultsVC = self.storyboard?.instantiateViewControllerWithIdentifier("BIFlashbackSearchResultsViewController") as BIFlashbackSearchResultsViewController
        searchResultsVC.view.backgroundColor = UIColor.redColor()
        
        var searchController = BISearchController(searchResultsController: searchResultsVC)
        searchController.delegate = self
        searchController.dimsBackgroundDuringPresentation = true
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.searchBar.frame = CGRectMake(10.0, 0, 0, 44.0)
        self.navigationController?.navigationBar.addSubview(searchController.searchBar)
        
        self.searchBar = searchController.searchBar
        self.searchController = searchController
        self.searchResultsVC = searchResultsVC
        
        self.definesPresentationContext = true
    }
    
    func setupNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "checkIfRefreshIsNecessary", name: UIApplicationDidBecomeActiveNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
// pragma mark : refresh on new day
    
    func checkIfRefreshIsNecessary() {
        if possibleFlashbackDates.count > 0 {
            let todaysDate = NSDate.beginningOfDay(NSDate())
            let prevDate = NSDate.beginningOfDay(currentDate)
            if !todaysDate.isEqualToDate(prevDate) {
                self.refreshData()
            }
        }
    }
    
    func refreshData() {
        calculateFlashbackDates()
        fetchFlashbacks()
    }
    
// pragma mark : flashback dates
    
    func calculateFlashbackDates() {
        let today = NSDate()
        currentDate = today
        
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
        }
    }
    
// pragma mark : page control
    
    func setupPageIndicator() {
        let titleView = UIView(frame: CGRectMake(0, 0, 220, 44))
        
        let navTitle = UILabel(frame: CGRectMake(0, 5, 220, 24))
        navTitle.text = NSDate.elapsedTimeFromFlashbackIndex(self.flashbackVCs[0].dateIndex)
        navTitle.textColor = UIColor.darkGrayColor()
        navTitle.textAlignment = NSTextAlignment.Center
        navTitle.font = UIFont.boldSystemFontOfSize(13)
        navTitleLabel = navTitle
        titleView.addSubview(navTitle)
        
        let pageControl = UIPageControl(frame: CGRectMake(0, 24, 220, 20))
        pageControl.numberOfPages = existingFlashbackDates.count
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
        
        let flashbackPageVC = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
        flashbackPageVC.dataSource = self;
        flashbackPageVC.delegate = self;
        
        
        if (flashbackVCs.count > 0) {
            var shouldAnimate = false

            if flashbackPageViewController == nil {
                flashbackPageViewController = flashbackPageVC
                addChildViewController(flashbackPageViewController)
                view.addSubview(flashbackPageViewController.view)
                flashbackPageViewController.didMoveToParentViewController(self)
                
                shouldAnimate = true
            }
            
            flashbackPageViewController.setViewControllers([flashbackVCs[0]], direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion:nil)
            
            self.setupPageIndicator()
        } else {
            self.noFlashbacksView.hidden = false
            self.title = "Flashback"
        }
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
    
// search
    
    func searchTapped(button: UIBarButtonItem) {
        self.navigationItem.titleView!.hidden = true
        self.navigationItem.rightBarButtonItem = nil

        UIView.animateWithDuration(0.2, delay:0, options:nil, animations: {
            self.searchBar.frame = CGRectMake(10, 0, self.view.frameWidth - 20, 44)
        }, completion: { (completed: Bool) in
            self.searchBar.becomeFirstResponder()
            self.isSearching = true
//            self.navigationItem.rightBarButtonItem = nil
            return
        })
    }
    
// pragma mark - UISearchBarDelegate
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.navigationItem.titleView!.hidden = false
        self.navigationItem.rightBarButtonItem = self.searchButton
        
        UIView.animateWithDuration(0.2, delay:0, options:nil, animations: {
                self.searchBar.frame = CGRectMake(10, 0, 0, 44)
            }, completion: { (completed: Bool) in
                self.searchBar.resignFirstResponder()
                self.isSearching = false
                return
        })
    }
    
// pragma mark - UISearchResultsUpdating
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
    }
    
// pragma mark - UISearchControllerDelegate
    
    func willPresentSearchController(searchController: UISearchController) {
        searchController.view.setNeedsLayout()
    }
    
    func didPresentSearchController(searchController: UISearchController) {

    }
    
    func willDismissSearchController(searchController: UISearchController) {
        self.searchBarCancelButtonClicked(self.searchBar)
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
