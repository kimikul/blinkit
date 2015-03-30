//
//  BISearchController.swift
//  BlinkIt
//
//  Created by Kimberly Hsiao on 3/29/15.
//  Copyright (c) 2015 hsiao. All rights reserved.
//

import UIKit

class BISearchController: UISearchController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.searchBar.frameWidth = self.view.frameWidth - 20
        self.searchBar.setShowsCancelButton(false, animated: false)
    }

}
