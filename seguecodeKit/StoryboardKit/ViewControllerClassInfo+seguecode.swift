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
            let storyboardInstances = NSMutableOrderedSet()
            let segueInstances = NSMutableOrderedSet()
            var tableViewCellPrototypes = Array<TableViewInstanceInfo.TableViewCellPrototypeInfo>()
            var collectionViewCellPrototypes = Array<CollectionViewInstanceInfo.CollectionViewCellPrototypeInfo>()
            for instance in instances
            {
                if let instance = instance.value
                {
                    if let storyboardIdentifier = instance.storyboardIdentifier
                    {
                        if storyboardIdentifier.characters.count > 0
                        {
                            storyboardInstances.addObject(instance)
                        }
                    }
                    
                    for segue in instance.segues
                    {
                        segueInstances.addObject(segue)
                    }
                    
                    if let view = instance.view
                    {
                        let newTableViewCellPrototypes = ViewControllerClassInfo.tableViewCellPrototypes(view)
                        if newTableViewCellPrototypes.count > 0
                        {
                            tableViewCellPrototypes = tableViewCellPrototypes + newTableViewCellPrototypes
                        }
                        let newCollectionViewCellPrototypes = ViewControllerClassInfo.collectionViewCellPrototypes(view)
                        if newCollectionViewCellPrototypes.count > 0
                        {
                            collectionViewCellPrototypes = collectionViewCellPrototypes + newCollectionViewCellPrototypes
                        }
                    }
                }
            }
            
            if storyboardInstances.count > 0 || segueInstances.count > 0 || tableViewCellPrototypes.count > 0 || collectionViewCellPrototypes.count > 0
            {
                ViewControllerClassInfo.addStoryboardInstanceInfoStencilContexts(&contextDictionary, storyboardInstances: storyboardInstances)
                
                ViewControllerClassInfo.addSegueInfoStencilContexts(&contextDictionary, segueInstances: segueInstances)
                ViewControllerClassInfo.addTableViewCellPrototypeStencilContexts(&contextDictionary, cellPrototypes: tableViewCellPrototypes)
                ViewControllerClassInfo.addCollectionViewCellPrototypeStencilContexts(&contextDictionary, cellPrototypes: collectionViewCellPrototypes)
                
                result = contextDictionary
            }
        }
        
        return result
    }
    
    class func addStoryboardInstanceInfoStencilContexts(inout contextDictionary : [String : AnyObject], storyboardInstances : NSOrderedSet) {
        let storyboardInstanceResults = self.storyboardInstanceInfoStencilContexts(storyboardInstances)
        if storyboardInstanceResults.count > 0
        {
            contextDictionary[DefaultTemplate.Keys.ViewController.StoryboardInstances] = storyboardInstanceResults
        }
    }
    
    class func storyboardInstanceInfoStencilContexts(storyboardInstances : NSOrderedSet) -> [ [String : String] ] {
        var result = [ [String : String] ]()
        
        for storyboardInstance in storyboardInstances
        {
            if let storyboardInstance = storyboardInstance as? ViewControllerInstanceInfo
            {
                if let storyboardInstanceStencilContext = storyboardInstance.storyboardInstanceStencilContext()
                {
                    result.append(storyboardInstanceStencilContext)
                }
            }
        }
        
        return result
    }
    
    class func addSegueInfoStencilContexts(inout contextDictionary : [String : AnyObject], segueInstances : NSOrderedSet) {
        let segueResults = self.segueInfoStencilContexts(segueInstances)
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
    
    class func tableViewCellPrototypes(view : ViewInstanceInfo) -> [TableViewInstanceInfo.TableViewCellPrototypeInfo] {
        var result = Array<TableViewInstanceInfo.TableViewCellPrototypeInfo>()
        
        if let tableView = view as? TableViewInstanceInfo,
            let cellPrototypes = tableView.cellPrototypes
        {
            for cellPrototype in cellPrototypes
            {
                result.append(cellPrototype)
            }
        }
        
        if let subviews = view.subviews
        {
            for subview in subviews
            {
                let subviewResult = self.tableViewCellPrototypes(subview)
                if subviewResult.count > 0
                {
                    result = result + subviewResult
                }
            }
        }
        
        return result
    }
    
    class func addTableViewCellPrototypeStencilContexts(inout contextDictionary : [String : AnyObject], cellPrototypes: [TableViewInstanceInfo.TableViewCellPrototypeInfo]) {
        let cellPrototypeResults = self.cellPrototypeStencilContexts(cellPrototypes)
        if cellPrototypeResults.0.count > 0
        {
            contextDictionary[DefaultTemplate.Keys.ViewController.TableViewCellPrototypes] = cellPrototypeResults.0
        }
        
        if cellPrototypeResults.1.count > 0
        {
            contextDictionary[DefaultTemplate.Keys.ViewController.DequeueTableViewCellFunctions] = cellPrototypeResults.1
        }
    }
    
    class func collectionViewCellPrototypes(view : ViewInstanceInfo) -> [CollectionViewInstanceInfo.CollectionViewCellPrototypeInfo] {
        var result = Array<CollectionViewInstanceInfo.CollectionViewCellPrototypeInfo>()
        
        if let collectionView = view as? CollectionViewInstanceInfo,
            let cellPrototypes = collectionView.cellPrototypes
        {
            for cellPrototype in cellPrototypes
            {
                result.append(cellPrototype)
            }
        }
        
        if let subviews = view.subviews
        {
            for subview in subviews
            {
                let subviewResult = self.collectionViewCellPrototypes(subview)
                if subviewResult.count > 0
                {
                    result = result + subviewResult
                }
            }
        }
        
        return result
    }
    
    class func addCollectionViewCellPrototypeStencilContexts(inout contextDictionary : [String : AnyObject], cellPrototypes: [CollectionViewInstanceInfo.CollectionViewCellPrototypeInfo]) {
        let cellPrototypeResults = self.cellPrototypeStencilContexts(cellPrototypes)
        if cellPrototypeResults.0.count > 0
        {
            contextDictionary[DefaultTemplate.Keys.ViewController.CollectionViewCellPrototypes] = cellPrototypeResults.0
        }
        
        if cellPrototypeResults.1.count > 0
        {
            contextDictionary[DefaultTemplate.Keys.ViewController.DequeueCollectionViewCellFunctions] = cellPrototypeResults.1
        }
    }
    
    // TODO: clarify cellPrototypes and dequeueFunctions in return results, right now interchangable
    class func cellPrototypeStencilContexts(cellPrototypes : [TableViewInstanceInfo.TableViewCellPrototypeInfo]) -> ([ [String : String] ], [ [String: String] ]) {
        var resultCellPrototypes = [ [String : String] ]()
        var resultDequeueFunctions = [ [String : String] ]()
        
        for cellPrototype in cellPrototypes
        {
            if let cellPrototypeStencilContext = cellPrototype.cellPrototypeStencilContext()
            {
                resultCellPrototypes.append(cellPrototypeStencilContext)
            }
            
            if let dequeueFunctionStencilContext = cellPrototype.dequeueFunctionStencilContext()
            {
                resultDequeueFunctions.append(dequeueFunctionStencilContext)
            }
        }
        
        return (resultCellPrototypes, resultDequeueFunctions)
    }
    
    // TODO: clarify cellPrototypes and dequeueFunctions in return results, right now interchangable
    class func cellPrototypeStencilContexts(cellPrototypes : [CollectionViewInstanceInfo.CollectionViewCellPrototypeInfo]) -> ([ [String : String] ], [ [String: String] ]) {
        var resultCellPrototypes = [ [String : String] ]()
        var resultDequeueFunctions = [ [String : String] ]()
        
        for cellPrototype in cellPrototypes
        {
            if let cellPrototypeStencilContext = cellPrototype.cellPrototypeStencilContext()
            {
                resultCellPrototypes.append(cellPrototypeStencilContext)
            }
            
            if let dequeueFunctionStencilContext = cellPrototype.dequeueFunctionStencilContext()
            {
                resultDequeueFunctions.append(dequeueFunctionStencilContext)
            }
        }
        
        return (resultCellPrototypes, resultDequeueFunctions)
    }
}