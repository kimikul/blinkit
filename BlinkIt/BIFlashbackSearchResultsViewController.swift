//
//  BIFlashbackSearchResultsViewController.swift
//  BlinkIt
//
//  Created by Kimberly Hsiao on 3/29/15.
//  Copyright (c) 2015 hsiao. All rights reserved.
//

import UIKit

class BIFlashbackSearchResultsViewController: BIMyBlinksBaseViewController {
    var searchResults:Array<PFObject>?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupTableView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupTableView() {
        let nib:UINib = UINib(nibName: BIRecentSearchCell.reuseIdentifier(), bundle: NSBundle.mainBundle())
        self.tableView.registerNib(nib, forCellReuseIdentifier: BIRecentSearchCell.reuseIdentifier())
        
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
    }
    
// pragma mark - requests
    
    func searchForText(searchText: NSString) {
        var searchTerms = searchText.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        var query = PFQuery(className: "Blink")
        query.whereKey("words", containsAllObjectsInArray: searchTerms)
        query.whereKey("user", equalTo:PFUser.currentUser())
        query.findObjectsInBackgroundWithBlock({ (objects: [AnyObject]!, error) -> Void in
            self.allBlinksArray = NSMutableArray(array: objects)
            self.reloadTableData()
        })
    }
    
//// pragma mark - UITableViewDelegate
//    
//    override func tableView(tableView:UITableView, numberOfRowsInSection section:Int)->Int {
//        return 1
//    }
//    
//    override func numberOfSectionsInTableView(tableView:UITableView)->Int {
//        if searchResults != nil {
//            return searchResults!.count
//        }
//        
//        return 1
//    }
//    
//    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        return 44
//    }
//    
//    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        
//        if searchResults != nil {
//            let blink = self.searchResults![indexPath.row]
//            
//            var cell:BIRecentSearchCell = tableView.dequeueReusableCellWithIdentifier(BIRecentSearchCell.reuseIdentifier()) as BIRecentSearchCell
//            cell.titleLabel.text = blink["content"] as? String
//            return cell
//        }
//        
//        var cell:BIRecentSearchCell = tableView.dequeueReusableCellWithIdentifier(BIRecentSearchCell.reuseIdentifier()) as BIRecentSearchCell
//        cell.titleLabel.text = "no results"
//        return cell
//    }
//
//    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        tableView.deselectRowAtIndexPath(indexPath, animated: true)
//    }
}
