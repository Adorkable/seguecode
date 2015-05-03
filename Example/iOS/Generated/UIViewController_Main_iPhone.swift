//
//  UIViewController_Main_iPhone.swift
//  seguecode
//
//  Created by Ian on 5/4/15.
//  Copyright (c) 2015 Adorkable. All rights reserved.
//

import UIKit

protocol SegueProtocol {
    var identifier : String { get }
}

extension UIViewController {
    enum Segue : String, SegueProtocol {
        case BackToFirst = "BackTo"
        
        var identifier : String {
            get {
                return self.rawValue
            }
        }
    }
    
    func performSegue(segue : SegueProtocol, sender : AnyObject?) {
        // TODO: validate that we're calling from the correct instance of the VC class for classes in multiple instances in storyboards
        
        self.performSegueWithIdentifier(segue.identifier, sender: sender)
    }
    
    @IBAction func performBackToFirst(sender : AnyObject? = nil) {
        self.performSegue(UIViewController.Segue.BackToFirst, sender: sender)
    }
}