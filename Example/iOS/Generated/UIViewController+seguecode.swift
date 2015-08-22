//
//  UIViewController+seguecode.swift
//  seguecode
//
//  Created by Ian Grossberg on 8/22/15.
//  Copyright (c) 2015 Adorkable. All rights reserved.
//

import UIKit

extension UIViewController {
    
    class Segue
    {
        let identifier : String
        
        init(identifier : String) {
            self.identifier = identifier
        }
    }
    
    func performSegue(segue : Segue, sender : AnyObject?) {
        // TODO: validate that we're calling from the correct instance of the VC class for classes in multiple instances in storyboards
        
        self.performSegueWithIdentifier(segue.identifier, sender: sender)
    }
}