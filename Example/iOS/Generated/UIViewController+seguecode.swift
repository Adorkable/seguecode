//
//  UIViewController+seguecode.swift
//  seguecode
//
//  Created by Ian Grossberg on 8/22/15.
//  Copyright (c) 2015 Adorkable. All rights reserved.
//

import UIKit

protocol SegueProtocol {
    var identifier : String { get }
}

extension UIViewController {
    func performSegue(segue : SegueProtocol, sender : AnyObject?) {
        // TODO: validate that we're calling from the correct instance of the VC class for classes in multiple instances in storyboards
        
        self.performSegueWithIdentifier(segue.identifier, sender: sender)
    }
}