//
//  TableViewCellPrototype+seguecode.swift
//  seguecode
//
//  Created by Ian Grossberg on 8/26/15.
//  Copyright (c) 2015 Adorkable. All rights reserved.
//

import Foundation

import StoryboardKit

extension TableViewInstanceInfo.TableViewCellPrototypeInfo
{
    func cellPrototypeStencilContext() -> [String : String]? {
        var result : [String : String]?
        
        if let reuseIdentifier = self.reuseIdentifier
        {
            var context = [DefaultTemplate.Keys.ViewController.TableViewCellPrototype.ReuseIdentifier : reuseIdentifier]
            result = context
        }
        
        return result
    }
    
    func dequeueFunctionStencilContext() -> [String : String]? {
        var result : [String : String]?
        
        if let reuseIdentifier = self.reuseIdentifier
        {
            var context = [DefaultTemplate.Keys.ViewController.DequeueFunction.ReuseIdentifier : reuseIdentifier]
            result = context
        }
        
        return result
    }
}