//
//  BIChooseUsernameView.swift
//  BlinkIt
//
//  Created by Kimberly Hsiao on 4/4/15.
//  Copyright (c) 2015 hsiao. All rights reserved.
//

import UIKit

let alertTypeCongrats = 143

class BIChooseUsernameView: UIView, UIAlertViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var usernameTextField: UITextField!
    
    func present() {
        self.fadeInWithDuration(0.3, completion: nil);
        self.usernameTextField.delegate = self
        self.usernameTextField.becomeFirstResponder()
    }
    
    func hide() {
        self.fadeOutWithDuration(0.3, completion: { () -> Void in
            self.removeFromSuperview()
        })
    }

    @IBAction func tappedNotNow(sender: AnyObject) {
        self.hide()
    }
    
    @IBAction func tappedContinue(sender: AnyObject) {
        self.submitUsername()
    }

    
    func submitUsername() {
        let username = self.usernameTextField.text
        let count = ((username.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())) as NSString).length
        
        if (count <= 0) {
            let av = UIAlertView(title: "Error", message: "Username cannot be empty", delegate: self, cancelButtonTitle: "OK")
            av.show()
            return
        } else if (count > 16) {
            let av = UIAlertView(title: "Error", message: "Username cannot be more than 16 characters", delegate: self, cancelButtonTitle: "OK")
            av.show()
            return
        }
        
        var currentUser:PFUser = PFUser.currentUser()
        currentUser["blinkitUsername"] = username != nil ? username : ""
        
        currentUser.saveInBackgroundWithBlock { (succeeded, error) -> Void in
            if error != nil {
                let av = UIAlertView(title: "Error", message: "That username is taken already", delegate: self, cancelButtonTitle: "OK")
                av.show()
            } else {
                let msg = "Congrats! You have set '" + username + "' as your username"
                let av = UIAlertView(title: "Username confirmed", message:msg, delegate: self, cancelButtonTitle: "OK")
                av.tag = alertTypeCongrats
                av.show()
                
                NSNotificationCenter.defaultCenter().postNotificationName(kBIUsernameUpdatedNotification, object: nil)
            }
        }
    }
    
// pragma mark - UITextFieldDelegate
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let blockedCharacters = NSCharacterSet.alphanumericCharacterSet().invertedSet
        return (string as NSString).rangeOfCharacterFromSet(blockedCharacters).location == NSNotFound
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.submitUsername()
        return true
    }

    
// pragma mark - UIAlertViewDelegate
    
    func alertView(alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
        if (alertView.tag == alertTypeCongrats) {
            self.hide()
        }
    }
}
