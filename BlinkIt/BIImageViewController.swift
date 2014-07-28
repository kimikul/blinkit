//
//  BIImageViewController.swift
//  BlinkIt
//
//  Created by Kimberly Hsiao on 7/22/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

import UIKit

class BIImageViewController: BIViewController, UIScrollViewDelegate {

// MARK: properties

    var image : UIImage
    var shouldDismissAnimated : Bool
    var willDismissBlock : ((fromFrame: CGRect) -> Void)?
    var didDismissBlock : dispatch_block_t?
    
    @IBOutlet weak var scrollView : UIScrollView?
    @IBOutlet weak var imageView : UIImageView?
    
// MARK: init
    
    init(coder aDecoder: NSCoder!) {
        self.image = UIImage()
        self.shouldDismissAnimated = false
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeScrollView()
        initializeImageView()
    }
    
    func initializeScrollView() {
        scrollView!.maximumZoomScale = 4.0
        scrollView!.bouncesZoom = true
        scrollView!.delegate = self
        
        let tapGR:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "onImageTapped:")
        scrollView!.addGestureRecognizer(tapGR)
    }
    
    func initializeImageView() {
        imageView!.image = image
    }
    
// MARK: IBActions
    
    func onImageTapped(image: UIImage) {
        if let defWillDismissBlock = willDismissBlock? {
            let contentOffset = scrollView!.contentOffset
            let imageViewFrame = CGRectMake(-contentOffset.x, -contentOffset.y, imageView!.frame.width, imageView!.frame.height)
            defWillDismissBlock(fromFrame: imageViewFrame)
        }
        
        self.presentingViewController.dismissViewControllerAnimated(self.shouldDismissAnimated, completion: didDismissBlock)
    }
    
// MARK: ScrollViewDelegate
    
    func viewForZoomingInScrollView(scrollView: UIScrollView!) -> UIView! {
        return imageView
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView!) {
        let offsetX = max((scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5, 0.0)
        let offsetY = max((scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5, 0.0)
        
        imageView!.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
            scrollView.contentSize.height * 0.5 + offsetY)
    }
}
