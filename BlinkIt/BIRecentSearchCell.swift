//
//  BIRecentSearchCell.swift
//  BlinkIt
//
//  Created by Kimberly Hsiao on 3/8/15.
//  Copyright (c) 2015 hsiao. All rights reserved.
//

import UIKit

class BIRecentSearchCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    class func reuseIdentifier() -> String {
        return "BIRecentSearchCell"
    }
}
