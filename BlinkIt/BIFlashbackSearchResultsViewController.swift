//
//  BIFlashbackSearchResultsViewController.swift
//  BlinkIt
//
//  Created by Kimberly Hsiao on 3/29/15.
//  Copyright (c) 2015 hsiao. All rights reserved.
//

import UIKit

class BIFlashbackSearchResultsViewController: BITableViewController {
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
    
// pragma mark - UITableViewDelegate
    
    override func tableView(tableView:UITableView, numberOfRowsInSection section:Int)->Int {
        return 1
    }
    
    override func numberOfSectionsInTableView(tableView:UITableView)->Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:BIRecentSearchCell = tableView.dequeueReusableCellWithIdentifier(BIRecentSearchCell.reuseIdentifier()) as BIRecentSearchCell
//        cell.titleLabel.text = "laterblink"
        return cell
    }

}
