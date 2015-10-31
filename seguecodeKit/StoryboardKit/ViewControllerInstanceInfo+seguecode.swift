//
//  ViewControllerInstanceInfo+seguecode.swift
//  seguecode
//
//  Created by Ian Grossberg on 10/30/15.
//  Copyright © 2015 Adorkable. All rights reserved.
//

import Foundation

import StoryboardKit

import Stencil

extension ViewControllerInstanceInfo
{
    var storyboardInstanceIdentifier : String? {
        return self.storyboardIdentifier
    }
    
    var storyboardInstanceValue : String? {
        return self.storyboardIdentifier
    }
    
    func storyboardInstanceStencilContext() -> [String : String]? {
        
        var result : [String : String]?
        
        if let storyboardInstanceIdentifier = self.storyboardInstanceIdentifier,
            let storyboardInstanceValue = self.storyboardInstanceValue
        {
            let context = [
                DefaultTemplate.Keys.ViewController.StoryboardInstance.Identifier : storyboardInstanceIdentifier,
                DefaultTemplate.Keys.ViewController.StoryboardInstance.Value : storyboardInstanceValue]
            
            result = context
        }
        
        return result
    }
}