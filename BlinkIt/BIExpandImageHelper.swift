//
//  BIExpandImageHelper.swift
//  BlinkIt
//
//  Created by Kimberly Hsiao on 7/22/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

import UIKit

@objc protocol BIExpandImageHelperDelegate {
    var view:UIView { get }
    var storyboard:UIStoryboard { get }
    func presentViewController(viewController:UIViewController, animated:Bool, completion:() -> ())
}

@objc class BIExpandImageHelper: NSObject {
    // properties
    lazy var zoomImageView : UIImageViewModeScaleAspect = {
        var tempZoomImageView : UIImageViewModeScaleAspect = UIImageViewModeScaleAspect(frame:CGRectZero)
        tempZoomImageView.backgroundColor = UIColor.blackColor()
        return tempZoomImageView
    } ()
    
    var delegate: BIExpandImageHelperDelegate?
    
    func animateImageView(imageView: UIImageView) {
        if let containerView = delegate?.view.window {
            let fullScreenFrame = CGRectMake(0, 0, containerView.frame.width, containerView.frame.height)
            let originalZoomFrame = containerView.convertRect(imageView.frame, fromView:imageView.superview)
            
            self.zoomImageView.contentMode = UIViewContentMode.ScaleAspectFill
            self.zoomImageView.image = imageView.image
            self.zoomImageView.frame = originalZoomFrame
            self.zoomImageView.alpha = 1.0
            
            let animationDuration = 0.2
            let imageViewController:BIImageViewController = BIImageViewController(nibName: "BIImageViewController", bundle: nil)
            imageViewController.image = imageView.image!
            imageViewController.shouldDismissAnimated = false
            imageViewController.willDismissBlock = { (fromFrame: CGRect) in
                self.zoomImageView.contentMode = UIViewContentMode.ScaleAspectFit
                self.zoomImageView.image = imageView.image
                self.zoomImageView.frame = fromFrame
                containerView.addSubview(self.zoomImageView)
            }
            
            imageViewController.didDismissBlock = {
                self.zoomImageView.initToScaleAspectFillToFrame(originalZoomFrame)
                UIView.animateWithDuration(animationDuration, animations: {
                        self.zoomImageView.animaticToScaleAspectFill()
                    }, completion: { (finished: Bool) in
                        self.zoomImageView.animateFinishToScaleAspectFill()
                        UIView.animateWithDuration(animationDuration, animations: {
                                self.zoomImageView.alpha = 0
                            }, completion: { (finished: Bool) in
                                self.zoomImageView.removeFromSuperview()
                            })
                    })
            }
            
            containerView.addSubview(zoomImageView)
            zoomImageView.frame = originalZoomFrame
            zoomImageView.initToScaleAspectFitToFrame(fullScreenFrame)
            
            UIView.animateWithDuration(animationDuration, animations: {
                    self.zoomImageView.animaticToScaleAspectFit()
                }, completion: {(finished: Bool) in
                    self.zoomImageView.animateFinishToScaleAspectFit()
                    self.delegate?.presentViewController(imageViewController, animated: false, completion: {
                            self.zoomImageView.removeFromSuperview()
                        })
                })
        }
    }
}
