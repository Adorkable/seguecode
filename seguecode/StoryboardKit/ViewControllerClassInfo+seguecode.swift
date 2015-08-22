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
            if segueInstances.count > 0
            {
                var segueCases = [ [String : String] ]()
                var performFunctions = [ [String : String] ]()
                for segueInstance in segueInstances
                {
                    if let segueInstance = segueInstance as? SegueInstanceInfo
                    {
                        if let segueCaseStencilContext = segueInstance.segueCaseStencilContext()
                        {
                            segueCases.append(segueCaseStencilContext)
                        }
                        
                        if let peformFunctionStencilContext = segueInstance.peformFunctionStencilContext()
                        {
                            performFunctions.append(peformFunctionStencilContext)
                        }
                    }
                }
                if segueCases.count > 0
                {
                    contextDictionary[DefaultTemplate.Keys.ViewController.SegueCases] = segueCases
                }
                
                if performFunctions.count > 0
                {
                    contextDictionary[DefaultTemplate.Keys.ViewController.PerformFunctions] = performFunctions
                }
                
                result = contextDictionary
            }
        }
        
        return result
    }
}