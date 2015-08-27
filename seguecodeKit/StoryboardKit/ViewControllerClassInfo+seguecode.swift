//
//  ViewControllerClassInfo+seguecode.swift
//  seguecode
//
//  Created by Ian Grossberg on 8/21/15.
//  Copyright (c) 2015 Adorkable. All rights reserved.
//

import Foundation

import StoryboardKit

import Stencil

extension ViewControllerClassInfo
{
    func separateFileName(category : String) -> String {
        return "\(self.infoClassName)+\(category)"
    }
    
    func stencilContext() -> [String : AnyObject]? {
        var result : [String : AnyObject]?

        var contextDictionary : [String : AnyObject] = [
            DefaultTemplate.Keys.ViewController.Name : self.infoClassName
        ]
        
        let instances = self.instanceInfos
        if instances.count > 0
        {
            var segueInstances = NSMutableOrderedSet()
            for instance in instances
            {
                if let instance = instance.value
                {
                    for segue in instance.segues
                    {
                        segueInstances.addObject(segue)
                    }
                    
                    
                }
            }
            
            ViewControllerClassInfo.addSegueInfoStencilContexts(&contextDictionary, segueInstances: segueInstances)
            
            result = contextDictionary
        }
        
        return result
    }
    
    class func addSegueInfoStencilContexts(inout contextDictionary : [String : AnyObject], segueInstances : NSOrderedSet) {
        var segueResults = self.segueInfoStencilContexts(segueInstances)
        if segueResults.0.count > 0
        {
            contextDictionary[DefaultTemplate.Keys.ViewController.SegueCases] = segueResults.0
        }
        
        if segueResults.1.count > 0
        {
            contextDictionary[DefaultTemplate.Keys.ViewController.PerformFunctions] = segueResults.1
        }
    }
    
    // TODO: clarify segueCases and performFunctions in return results, right now interchangable
    class func segueInfoStencilContexts(segueInstances : NSOrderedSet) -> ([ [String : String] ], [ [String: String] ]) {
        var resultSegueCases = [ [String : String] ]()
        var resultPerformFunctions = [ [String : String] ]()
        
        for segueInstance in segueInstances
        {
            if let segueInstance = segueInstance as? SegueInstanceInfo
            {
                if let segueCaseStencilContext = segueInstance.segueCaseStencilContext()
                {
                    resultSegueCases.append(segueCaseStencilContext)
                }
                
                if let peformFunctionStencilContext = segueInstance.peformFunctionStencilContext()
                {
                    resultPerformFunctions.append(peformFunctionStencilContext)
                }
            }
        }
        
        return (resultSegueCases, resultPerformFunctions)
    }
}