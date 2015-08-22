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
        
        if let segueCaseValue = self.segueCaseValue
        {
            var context = [
                DefaultStencil.Keys.ViewController.SegueCase.Value : segueCaseValue
            ]
            
            var minimumRequirement = false
            
            if let identifier = self.identifier
            {
                context[DefaultStencil.Keys.ViewController.SegueCase.Identifier] = identifier
                minimumRequirement = true
            }
            
            if let source = self.source.value,
                let sourceIdentifier = source.storyboardIdentifier
            {
                context[DefaultStencil.Keys.ViewController.SegueCase.SourceIdentifier] = sourceIdentifier
                minimumRequirement = true
            }

            if let destination = self.destination.value,
                let destinationIdentifier = destination.storyboardIdentifier
            {
                context[DefaultStencil.Keys.ViewController.SegueCase.DestinationIdentifier] = destinationIdentifier
                minimumRequirement = true
            }

            if minimumRequirement == true
            {
                result = context
            }
        }
        
        return result
    }
    
    func peformFunctionStencilContext() -> [String : String]? {
        var result : [String : String]?
        
        var context = [String : String]()
        
        var minimumRequirement = false
        
        if let identifier = self.identifier
        {
            context[DefaultStencil.Keys.ViewController.SegueCase.Identifier] = identifier
            minimumRequirement = true
        }
        
        if let source = self.source.value,
            let sourceIdentifier = source.storyboardIdentifier
        {
            context[DefaultStencil.Keys.ViewController.SegueCase.SourceIdentifier] = sourceIdentifier
            minimumRequirement = true
        }
        
        if let destination = self.destination.value,
            let destinationIdentifier = destination.storyboardIdentifier
        {
            context[DefaultStencil.Keys.ViewController.SegueCase.DestinationIdentifier] = destinationIdentifier
            minimumRequirement = true
        }
        
        if minimumRequirement == true
        {
            result = context
        }
        
        return result
    }
}