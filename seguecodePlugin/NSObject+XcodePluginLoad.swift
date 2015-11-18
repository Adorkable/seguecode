//
//  NSObject+XcodePluginLoad.swift
//
//  Created by Ian Grossberg on 11/17/15.
//  Copyright © 2015 Adorkable. All rights reserved.
//

import Foundation

import CocoaLumberjack

extension NSObject {
    
    private static var staticSharedPlugin : seguecodePlugin? = nil
    private static var createdStaticSharedPluginOnceToken : dispatch_once_t = 0
    
    class func pluginDidLoad(bundle: NSBundle) {
        
        let logLevel : DDLogLevel
        #if DEBUG
            logLevel = .Debug
        #else
            logLevel = .Debug //.Info
        #endif
        DDLog.setupLogger(logLevel)
        
        guard let info = NSBundle.mainBundle().infoDictionary else {
            DDLog.error("Cannot find Info Dictionary from Main Bundle to verify that we're loading in Xcode")
            // TODO:
            return
        }
        
        guard let currentApplicationName = info["CFBundleName"] as? String else {
            DDLog.error("Cannot find Application Name to verify that we're loading in Xcode")
            // TODO:
            return
        }
        
        guard currentApplicationName == "Xcode" else {
            DDLog.error("Current Application is not Xcode")
            return
        }
        
        dispatch_once(&self.createdStaticSharedPluginOnceToken) { () -> Void in
            
            DDLog.debug("Creating static shared plugin instance with bundle \(bundle)")
            self.staticSharedPlugin = seguecodePlugin(bundle: bundle)
        }
    }
    
    class func sharedPlugin() -> seguecodePlugin? {
        return self.staticSharedPlugin
    }
}