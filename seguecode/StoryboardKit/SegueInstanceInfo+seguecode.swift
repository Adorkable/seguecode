//
//  SegueInstanceInfo+seguecode.swift
//  seguecode
//
//  Created by Ian Grossberg on 8/22/15.
//  Copyright (c) 2015 Adorkable. All rights reserved.
//

import Foundation

import StoryboardKit

import Stencil

extension SegueInstanceInfo
{
    var segueCaseName : String? {
        var result : String?
        
        if let identifier = self.identifier,
            let source = self.source.value,
            let sourceIdentifier = source.storyboardIdentifier,
            let destination = self.destination.value,
            let destinationIdentifier = destination.storyboardIdentifier
        {
            result = sourceIdentifier + identifier + destinationIdentifier
        }
        
        return result
    }
    
    var segueCaseValue : String? {
        return self.identifier
    }
    
    func segueCaseStencilContext() -> [String : String]? {
        var result : [String : String]?
        
        if let segueCaseName = self.segueCaseName,
            let segueCaseValue = self.segueCaseValue
        {
            result = [
                DefaultStencil.Keys.SegueCase.Name : segueCaseName,
                DefaultStencil.Keys.SegueCase.Value : segueCaseValue
            ]
        }
        
        return result
    }
    
    func peformFunctionStencilContext() -> [String : String]? {
        var result : [String : String]?
        
        if let segueCaseName = self.segueCaseName
        {
            result = [
                DefaultStencil.Keys.PerformFunction.Name : segueCaseName,
                DefaultStencil.Keys.PerformFunction.Segue : segueCaseName
            ]
        }
        
        return result
    }
}