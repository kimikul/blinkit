//
//  BIFlashbackSearchBar.swift
//  BlinkIt
//
//  Created by Kimberly Hsiao on 3/28/15.
//  Copyright (c) 2015 hsiao. All rights reserved.
//

import UIKit

class BIFlashbackSearchBar: UISearchBar {

    override func layoutSubviews() {
        super.layoutSubviews()
        self.setShowsCancelButton(false, animated: false)
    }
}
