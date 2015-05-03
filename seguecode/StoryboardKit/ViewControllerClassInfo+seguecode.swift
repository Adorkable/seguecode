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
    
    func stencilContext(fileName : String, projectName : String) -> Context? {
        var result : Context?
        
        let generatedOn = NSDate()
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "M/d/YY"
        let generatedOnString = dateFormatter.stringFromDate(generatedOn)

        var contextDictionary : [String : AnyObject] = [
            DefaultStencil.Keys.FileName : fileName,
            DefaultStencil.Keys.ProjectName : projectName,
            
            DefaultStencil.Keys.GeneratedOn : generatedOnString,
            DefaultStencil.Keys.ViewControllerName : self.infoClassName
        ]
        
        let instances = self.instanceInfos
        if instances.count > 0
        {
            var segueInstances = Set<SegueInstanceInfo>()
            for instance in instances
            {
                if let instance = instance.value
                {
                    for segue in instance.segues
                    {
                        segueInstances.insert(segue)
                    }
                }
            }
            if segueInstances.count > 0
            {
                var segueCases = [ [String : String] ]()
                var performFunctions = [ [String : String] ]()
                for segueInstance in segueInstances
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
                if segueCases.count > 0
                {
                    contextDictionary[DefaultStencil.Keys.SegueCases] = segueCases
                }
                
                if performFunctions.count > 0
                {
                    contextDictionary[DefaultStencil.Keys.PerformFunctions] = performFunctions
                }
                
                result = Context(dictionary: contextDictionary)
            }
        }
        
        return result
    }
}