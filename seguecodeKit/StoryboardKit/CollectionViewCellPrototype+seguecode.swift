//
//  CollectionViewCellPrototype+seguecode.swift
//  seguecode
//
//  Created by Ian Grossberg on 10/30/15.
//  Copyright © 2015 Adorkable. All rights reserved.
//

import Foundation

import StoryboardKit

extension CollectionViewInstanceInfo.CollectionViewCellPrototypeInfo
{
    func cellPrototypeStencilContext() -> [String : String]? {
        var result : [String : String]?
        
        if let reuseIdentifier = self.reuseIdentifier
        {
            let context = [DefaultTemplate.Keys.ViewController.CollectionViewCellPrototype.ReuseIdentifier : reuseIdentifier]
            result = context
        }
        
        return result
    }
    
    func dequeueFunctionStencilContext() -> [String : String]? {
        var result : [String : String]?
        
        if let reuseIdentifier = self.reuseIdentifier
        {
            let context = [DefaultTemplate.Keys.ViewController.DequeueCollectionViewCellFunction.ReuseIdentifier : reuseIdentifier]
            result = context
        }
        
        return result
    }
}