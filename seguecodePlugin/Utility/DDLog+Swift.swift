//
//  DDLog.swift
//  Eunomia
//
//  Created by Ian on 4/30/15.
//  Copyright (c) 2015 Adorkable. All rights reserved.
//

import Foundation

import CocoaLumberjack
#if DEBUG
    import NSLogger_CocoaLumberjack_connector
#endif

extension DDLog {
    
    public class func setupLogger(consoleLogLevel : DDLogLevel = DDLogLevel.Info) {
        #if DEBUG
            // NSLogger connection
            DDLog.addLogger(DDNSLoggerLogger.sharedInstance())
        #else
        #endif
        
        // Xcode Console connection
        let ddttyLogger = DDTTYLogger.sharedInstance()
        
        ddttyLogger.colorsEnabled = true
        ddttyLogger.setForegroundColor(NSColor(red: 0.973, green: 0.153, blue: 0.218, alpha: 1.0), backgroundColor: NSColor.whiteColor(), forFlag: DDLogFlag.Error)
        ddttyLogger.setForegroundColor(NSColor(red: 0.9337, green:0.6441, blue:0.254, alpha:1.0), backgroundColor: NSColor.whiteColor(), forFlag: DDLogFlag.Warning)
        ddttyLogger.setForegroundColor(NSColor(white: 0.212, alpha: 1.0), backgroundColor: NSColor.whiteColor(), forFlag: DDLogFlag.Info)
        ddttyLogger.setForegroundColor(NSColor(red:0.391, green:0.520, blue:0.417, alpha: 1.0), backgroundColor: NSColor.whiteColor(), forFlag: DDLogFlag.Debug)
        ddttyLogger.setForegroundColor(NSColor(white: 0.675, alpha: 1.0), backgroundColor: NSColor.whiteColor(), forFlag: DDLogFlag.Verbose)
        
        ddttyLogger.logFormatter = EunomiaCocoaLumberjackFormatter()
        
        // addLogger is inclusive from specified level and up, ie saying withLevel: Info means Info, Warning, Error
        DDLog.addLogger(ddttyLogger, withLevel: consoleLogLevel)
        
        // Crashlytics connection
        // TODO: check if Crashlytics Cocoapods is ok to use again
        //        var crashlyticsLogger = CrashlyticsLumberjack.sharedInstance()
        //        crashlyticsLogger.logFormatter = EunomiaCocoaLumberjackFormatter()
        //        DDLog.addLogger(crashlyticsLogger)
    }
    
    public class func log(message: String, level: DDLogLevel, flag: DDLogFlag, file: String, function: String, line: Int) {
        self.log(true, message: message, level: level, flag: flag, context: 0, file: (file as NSString).UTF8String, function: (function as NSString).UTF8String, line: UInt(line), tag: "")
    }
    
    public class func error(message : String, fileName : String = __FILE__, functionName : String = __FUNCTION__, line : Int = __LINE__) {
        self.log(message, level: DDLogLevel.Error, flag: DDLogFlag.Error, file: fileName, function: functionName, line: line)
    }
    
    public class func warning(message : String, fileName : String = __FILE__, functionName : String = __FUNCTION__, line : Int = __LINE__) {
        self.log(message, level: DDLogLevel.Warning, flag: DDLogFlag.Warning, file: fileName, function: functionName, line: line)
    }
    
    public class func info(message : String, fileName : String = __FILE__, functionName : String = __FUNCTION__, line : Int = __LINE__) {
        self.log(message, level: DDLogLevel.Info, flag: DDLogFlag.Info, file: fileName, function: functionName, line: line)
    }
    
    public class func debug(message : String, fileName : String = __FILE__, functionName : String = __FUNCTION__, line : Int = __LINE__) {
        self.log(message, level: DDLogLevel.Debug, flag: DDLogFlag.Debug, file: fileName, function: functionName, line: line)
    }
    
    public class func verbose(message : String, fileName : String = __FILE__, functionName : String = __FUNCTION__, line : Int = __LINE__) {
        self.log(message, level: DDLogLevel.Verbose, flag: DDLogFlag.Verbose, file: fileName, function: functionName, line: line)
    }
    
    public class func logFlagAsString(logFlag : DDLogFlag) -> String {
        var result : String
        
        switch (logFlag)
        {
        case DDLogFlag.Error:
            result = "E"
            break
        case DDLogFlag.Warning:
            result = "W"
            break
        case DDLogFlag.Info:
            result = "I"
            break
        case DDLogFlag.Debug:
            result = "D"
            break
        case DDLogFlag.Verbose:
            result = "V"
            break
        default:
            result = "?"
        }
        
        return result
    }
    
    public class EunomiaCocoaLumberjackFormatter : NSObject, DDLogFormatter {
        public func formatLogMessage(logMessage: DDLogMessage!) -> String! {
            
            var result = String()
            
            result += DDLog.logFlagAsString(logMessage.flag)
            
            if logMessage.threadName.characters.count > 0
            {
                result += " | thrd:\(logMessage.threadName)"
            }
            if logMessage.queueLabel.characters.count > 0
            {
                result += " | gcd:\(logMessage.queueLabel)"
            }
            
            result += ": \(logMessage.message)"
            
            var fileFunction = String()
            if logMessage.file.characters.count > 0
            {
                fileFunction += "\((logMessage.file as NSString).lastPathComponent):\(logMessage.line):"
            }
            if logMessage.function.characters.count > 0
            {
                fileFunction += "\(logMessage.function)"
            }
            if fileFunction.characters.count > 0
            {
                result += " | {\(fileFunction)}"
            }
            
            return result;
        }
    }
}
