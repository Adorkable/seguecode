//
//  seguecodePlugin.swift
//  seguecode
//
//  Created by Ian Grossberg on 11/17/15.
//  Copyright © 2015 Adorkable. All rights reserved.
//

import AppKit

import CocoaLumberjack

class seguecodePlugin: NSObject {

    private let bundle: NSBundle
    
    private var currentlyEditingStoryboardUrl : NSURL? = nil
    
    private var storyboardEnabledMenuItem : NSMenuItem? = nil
    
    init?(bundle : NSBundle) {
        self.bundle = bundle
        
        super.init()
        
        guard let urlToSeguecode = self.urlToSeguecode else {
            DDLog.error("seguecode binary not found!")
            return nil
        }

        if let path = urlToSeguecode.path {
            DDLog.info("seguecode found at \(path)")
        } else {
            DDLog.info("seguecode found at \(urlToSeguecode)")
        }
    
        self.setupNotifications()
        self.setupMenu()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationFinishedLoading:", name: NSApplicationDidFinishLaunchingNotification, object: nil)
    }
    
    func applicationFinishedLoading(notification : NSNotification) {
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NSApplicationDidFinishLaunchingNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    var urlToSeguecode : NSURL? {
        return self.bundle.URLForResource("seguecode.bundle/Contents/MacOS/seguecode", withExtension: nil)
    }
    
    func setupNotifications() {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "transitionFromOneFileToAnother:", name: NSNotification.TransitionFromOneFileToAnotherName, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "ideEditorDocumentDidSave:", name: NSNotification.IdeEditorDocumentDidSaveName, object: nil)
  
        // For Notification Logging
        #if DEBUG
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "logNotification:", name: nil, object: nil)
        #endif
    }
    
    func setupMenu() {
        
        // TODO: GCD?
        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in

            guard let submenu = Constants.Xcode.IDE.submenuInstance?.submenu else {
                DDLog.error("Unable to find submenu to insert seguecode options into")
                
                // TODO: kill plugin
                return
            }
            
            submenu.addItem(NSMenuItem.separatorItem())
            
            let storyboardEnabled = NSMenuItem(title: "Enable seguecode", action: "toggleEnabled:", keyEquivalent: "")
            self.storyboardEnabledMenuItem = storyboardEnabled
            storyboardEnabled.target = self
            
            submenu.addItem(storyboardEnabled)
            
            DDLog.debug("\(storyboardEnabled.title) menu item added to submenu")
        }
    }
    
    func toggleEnabled(sender : AnyObject) {

        guard let currentlyEditingStoryboardUrl = self.currentlyEditingStoryboardUrl else {
            return
        }

        do
        {
            if self.currentlyEditingStoryboardEnabled {
                try self.removeRunConfigForStoryboard(storyboardUrl: currentlyEditingStoryboardUrl)
            } else {
                try self.createDefaultRunConfigForStoryboard(storyboardUrl: currentlyEditingStoryboardUrl)
            }
        } catch let error as NSError {
            DDLog.error("While toggling Storyboard enabled file for Storyboard \(currentlyEditingStoryboardUrl): \(error)")
        }
    }
    
    private var currentlyEditingStoryboardEnabled : Bool {
        
        guard let currentlyEditingStoryboardUrl = self.currentlyEditingStoryboardUrl else {
            return false
        }
        
        do
        {
            return try RunConfig(forStoryboardAtUrl: currentlyEditingStoryboardUrl) != nil
        } catch let error as NSError {
            
            DDLog.error("While creating a RunConfig for Storyboard at Url \(currentlyEditingStoryboardUrl): \(error)")
            return false
        }
    }
}

extension seguecodePlugin {
    
/*    @objc
    override func validateMenuItem(menuItem: NSMenuItem) -> Bool {
        
        guard menuItem == self.storyboardEnabledMenuItem else {
            return super.validateMenuItem(menuItem)
        }
        
        return self.currentlyEditingStoryboardUrl != nil
    }*/
}

extension seguecodePlugin {

    func transitionFromOneFileToAnother(notification : NSNotification) {
        
        guard let nextUrl = notification.transitionFromOneFileToAnotherNextDocumentUrl else {
            
            // TODO:
            return
        }
        
//        if nextUrl.isFileReferenceURL() {
            
            if nextUrl.pathExtension == Constants.Storyboard.extensionString {
                
                self.currentlyEditingStoryboardUrl = nextUrl
            } else {
                
                // TODO:
            }
/*        } else {
            
            // TODO:
        }*/
        
        // TODO: only if currentlyEditingStoryboardUrl changed (not storyboard -> not storyboard should not trigger update)
        self.updateStoryboardEnabled()
    }
    
    func updateStoryboardEnabled() {

        guard self.currentlyEditingStoryboardUrl != nil else {
            
            self.storyboardEnabledMenuItem?.enabled = false
            self.storyboardEnabledMenuItem?.state = NSOffState
            return
        }
        
        self.storyboardEnabledMenuItem?.enabled = true
        if self.currentlyEditingStoryboardEnabled {
            self.storyboardEnabledMenuItem?.state = NSOnState
        } else {
            self.storyboardEnabledMenuItem?.state = NSOffState
        }
    }
    
    func createDefaultRunConfigForStoryboard(storyboardUrl storyboardUrl : NSURL) throws {
        let runConfig = RunConfig()
        try runConfig.writeForStoryboard(storyboardUrl: storyboardUrl)
    }
    
    func removeRunConfigForStoryboard(storyboardUrl storyboardUrl : NSURL) throws {
        try RunConfig.removeForStoryboard(storyboardUrl: storyboardUrl)
    }
    
    func ideEditorDocumentDidSave(notification : NSNotification) {

        guard let object = notification.object else {
            // TODO:
            return
        }
        
        guard let IBStoryboardDocumentClass = NSClassFromString("IBStoryboardDocument") else {
            // TODO:
            return
        }
        
        // TODO: Is this necessary if we have the next check?
        guard object.isKindOfClass(IBStoryboardDocumentClass) else {
            return
        }

        // TODO: check that object is the currently editing storyboard file
        guard let currentlyEditingStoryboardUrl = self.currentlyEditingStoryboardUrl else {
            return
        }
        
        do
        {
            guard let runConfig = try RunConfig(forStoryboardAtUrl: currentlyEditingStoryboardUrl) else {
                return
            }
            
            self.applyToStoryboard(currentlyEditingStoryboardUrl, runConfig: runConfig)
            
        } catch let error as NSError {
            NSLog("While opening Run Config for Storyboard \(currentlyEditingStoryboardUrl): \(error)")
        }
    }
    
    func applyToStoryboard(storyboardUrl : NSURL, runConfig : RunConfig) -> Bool {
        
        // TODO: look into simplying
        guard let urlToSeguecode = self.urlToSeguecode else {
            // TODO:
            return false
        }
        
        guard let pathToSeguecode = urlToSeguecode.path else {
            // TODO:
            return false
        }
        
        guard let storyboardDirectory = storyboardUrl.URLByDeletingLastPathComponent?.path else {
            // TODO:
            return false
        }
        
        guard let storyboardPath = storyboardUrl.path else {
            // TODO:
            return false
        }
        
        guard let currentDirectory = storyboardUrl.URLByDeletingLastPathComponent?.path else {
            // TODO:
            return false
        }
        
        var arguments = [String]()
        
        arguments += ["--outputPath", "\"\(storyboardDirectory)/\(runConfig.outputPath)\""]
        
        if runConfig.combine {
            arguments.append("--combine")
        }
        
        if let projectName = runConfig.projectName {
            arguments += ["--projectName", projectName]
        }
        
        arguments.append(storyboardPath)
        
        let task = NSTask()
        task.launchPath = pathToSeguecode
        task.arguments = arguments;
        task.currentDirectoryPath = currentDirectory

        let output = NSPipe()
        task.standardOutput = output;
        task.launch()
        task.waitUntilExit()

        if let outputResult = output.fileHandleForReading.availableString {
            
            if outputResult.characters.count > 0 {
                NSLog("seguecode result:\n \(outputResult)")
            }
        }
        
        return task.terminationStatus == 0
    }
    
    func logXcodeNotification(notification : NSNotification) {
        if notification.isXcodeEvent {
            NSLog("Notification: \(notification.name), \(notification.object)")
        }
    }
}
