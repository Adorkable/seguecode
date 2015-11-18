//
//  NSNotification+XcodePlugin.swift
//  seguecode
//
//  Created by Ian Grossberg on 11/17/15.
//  Copyright © 2015 Adorkable. All rights reserved.
//

import Foundation

import CocoaLumberjack

extension NSNotification
{
    static var TransitionFromOneFileToAnotherName : String {
        return "transition from one file to another"
    }
    
    var isTransitionFromOneFileToAnother : Bool {
        return self.name == NSNotification.TransitionFromOneFileToAnotherName
    }
    
    var transitionFromOneFileToAnotherInfo : NSDictionary? {
        guard self.isTransitionFromOneFileToAnother else {

            DDLog.warning("\"Not a Transition from One File To Another\" Notification: \(self)")
            return nil
        }

        guard let info = self.object as? NSDictionary else {

            DDLog.warning("Unable to retrieve info object from \(self)")
            return nil
        }
        
        return info
    }
    
    var transitionFromOneFileToAnotherNext : AnyObject? {
        
        guard self.isTransitionFromOneFileToAnother else {
            
            DDLog.warning("\"Not a Transition from One File To Another\" Notification: \(self)")
            return nil
        }
        
        guard let info = self.transitionFromOneFileToAnotherInfo else {
            
            DDLog.warning("Unable to retrieve info object from \(self)")
            return nil
        }
        
        guard let next = info.objectForKey("next") else {
            
            DDLog.warning("Unable to retrieve next from info object \(info) from \(self)")
            return nil
        }
        
        return next
    }
    
    var transitionFromOneFileToAnotherNextDocumentUrl : NSURL? {
        
        guard self.isTransitionFromOneFileToAnother else {
            
            DDLog.warning("\"Not a Transition from One File To Another\" Notification: \(self)")
            return nil
        }
        
        guard let next = self.transitionFromOneFileToAnotherNext else {
            
            DDLog.warning("Unable to retrieve next from \(self)")
            return nil
        }
        
        guard let DVTDocumentLocation = Constants.Xcode.Plugin.DVTDocumentLocation.classInstance else {
            
            DDLog.error("Unable to get instance of DVTDocumentLocation class")
            return nil
        }
        
        guard next.isKindOfClass(DVTDocumentLocation) else {
            
            DDLog.warning("next is not an instance of DVTDocumentLocation class as expected, instead \(next.dynamicType)")
            return nil
        }
        
        let documentUrlSelector = Constants.Xcode.Plugin.DVTDocumentLocation.documentUrlSelectorInstance
        
        guard next.respondsToSelector(documentUrlSelector) else {
            
            DDLog.warning("next does not respond to selector \(documentUrlSelector) as expected")
            return nil
        }
        
        guard let documentUrlObject = next.performSelector(documentUrlSelector) else {
            
            DDLog.warning("next's \(documentUrlSelector) did not return an object as expected")
            return nil
        }
        
        guard let documentUrl = documentUrlObject.takeUnretainedValue() as? NSURL else {
            
            DDLog.warning("next's \(documentUrlSelector) returned object is not an NSURL as expected, instead \(documentUrlObject.dynamicType)")
            return nil
        }
        
        return documentUrl
    }
    
    static var IdeEditorDocumentDidSaveName : String {
        return "IDEEditorDocumentDidSaveNotification"
    }
    
    var isIdeEditorDocumentDidSaveName : Bool {
        return self.name == NSNotification.IdeEditorDocumentDidSaveName
    }
    
    var isXcodeEvent : Bool {
        let prefix = "NS"
        
        let range = (self.name as NSString).rangeOfString(prefix)
        
        guard range.location == 0 && range.length == prefix.characters.count else {
            return false
        }
        
        return true
    }
}