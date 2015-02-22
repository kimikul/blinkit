//
//  BIFlashbackViewController.swift
//  BlinkIt
//
//  Created by Kimberly Hsiao on 7/27/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

import UIKit

class BIFlashbackViewController: BIMyBlinksBaseViewController {
    var flashbackDate:NSDate!
    var flashbackBlink:PFObject!
    var dateIndex:Int!
    
    @IBOutlet weak var noPostsView: UIView!
    @IBOutlet weak var noPostsLabel: UILabel!
    
// pragma mark : lifecycle
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.useEmptyTableFooter = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadBlink()
    }

// pragma mark : load blink

    func loadBlink() {
        self.allBlinksArray = NSMutableArray(object: flashbackBlink)
        
        let timePeriod = NSDate.elapsedTimeFromFlashbackIndex(dateIndex)
        
        var secondaryText = "Try to blink every day so you have more to look back on :)"
        
        if let joinedDate = BIDataStore.shared().dateJoined() {
            let comparison = joinedDate.compare(flashbackDate)
            
            if comparison == NSComparisonResult.OrderedDescending {
                secondaryText = String(format:"But it's okay because you actually haven't been on BlinkIt for that long yet :)",timePeriod)
            }
        }
        
        noPostsLabel.text = String(format: "You didn't post anything %@\n\n%@", timePeriod, secondaryText)
        reloadTableData()
    }

    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 34
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView {
        let dateString:String = String(format:"%@, you said...",NSDate.elapsedTimeFromFlashbackIndex(dateIndex))
        
        let headerView = UIView(frame: CGRectMake(0, 0, 320, 34))
        headerView.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
        headerView.layer.borderColor = UIColor.whiteColor().CGColor
        headerView.layer.borderWidth = 3.0
        
        let dateLabel = UILabel(frame: CGRectMake(10, 0, 300, 34))
        dateLabel.text = dateString
        dateLabel.font = UIFont(name: "Thonburi", size: 17)
        dateLabel.textColor = UIColor(white: 0.5, alpha: 1)
        headerView.addSubview(dateLabel)
        
        return headerView
    }

}
