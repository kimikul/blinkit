//
//  BIFlashbackSearchResultsViewController.swift
//  BlinkIt
//
//  Created by Kimberly Hsiao on 3/29/15.
//  Copyright (c) 2015 hsiao. All rights reserved.
//

import UIKit

class BIFlashbackSearchResultsViewController: BIMyBlinksBaseViewController {
    var searchText:String?
    var searchBar:UISearchBar?
    var isSearching:Bool
    @IBOutlet weak var noResultsView: UIView!
    
    required init(coder aDecoder: NSCoder) {
        isSearching = false
        
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupTableView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupTableView() {
        self.tableView.registerNib(UINib(nibName: BIRecentSearchCell.reuseIdentifier(), bundle: NSBundle.mainBundle()), forCellReuseIdentifier: BIRecentSearchCell.reuseIdentifier())
        self.tableView.registerNib(UINib(nibName: BIPaginationTableViewCell.reuseIdentifier(), bundle: NSBundle.mainBundle()), forCellReuseIdentifier: BIPaginationTableViewCell.reuseIdentifier())

        self.tableView.tableFooterView = UIView(frame: CGRectZero)
    }
    
// pragma mark - requests
    
    func searchForText(searchText: NSString) {
        let str = searchText.lowercaseString
        
        self.isSearching = true
        self.tableView.reloadData()
        
        self.searchText = str
        self.searchBar?.resignFirstResponder()
        
        var searchTerms = str.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        // words query
        var wordsQuery = PFQuery(className: "Blink")
        wordsQuery.whereKey("words", containsAllObjectsInArray: searchTerms)
        wordsQuery.whereKey("user", equalTo:PFUser.currentUser())
        
        // hashtag query
        var hashtagQuery = PFQuery(className: "Blink")
        hashtagQuery.whereKey("hashtags", containsAllObjectsInArray: searchTerms)
        hashtagQuery.whereKey("user", equalTo:PFUser.currentUser())
        
        var query = PFQuery.orQueryWithSubqueries([wordsQuery, hashtagQuery])
        query.orderByDescending("date")

        query.findObjectsInBackgroundWithBlock({ (objects: [AnyObject]!, error) -> Void in
            self.allBlinksArray = NSMutableArray(array: objects)
            self.isSearching = false
            
            if self.allBlinksArray.count == 0 {
                self.noResultsView.fadeInWithDuration(0.2, completion: nil)
            } else {
                self.noResultsView.hidden = true
                self.reloadTableData()
            }
        })
    }
    
    func clearResults() {
        self.searchText = nil
        self.noResultsView.hidden = true
        self.allBlinksArray.removeAllObjects()
        self.reloadTableData()
    }
    
//// pragma mark - UITableViewDelegate
    
    override func tableView(tableView:UITableView, numberOfRowsInSection section:Int)->Int {
        if self.allBlinksArray.count > 0 {
            return allBlinksArray.count
        }
        
        return 1
    }
    
    override func numberOfSectionsInTableView(tableView:UITableView)->Int {
        return 1
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if self.allBlinksArray.count > 0 {
            return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
        }
        
        return 40
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if self.allBlinksArray.count > 0 {
            return super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        }
        
        if self.isSearching == true {
            let cell: BIPaginationTableViewCell! = tableView.dequeueReusableCellWithIdentifier(BIPaginationTableViewCell.reuseIdentifier()) as BIPaginationTableViewCell
            return cell
        }
        
        let cell: BIRecentSearchCell! = tableView.dequeueReusableCellWithIdentifier(BIRecentSearchCell.reuseIdentifier()) as BIRecentSearchCell
        
        if let text = self.searchText {
            cell?.titleLabel.text = "Tap to search for \"" + text + "\""
        } else {
            cell?.titleLabel.text = "Tap to search"
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if self.allBlinksArray.count <= 0 && self.isSearching == false {
            self.searchForText(self.searchText!)
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
}
