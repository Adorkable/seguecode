//
//  AppDelegate.swift
//  seguecode
//
//  Created by Ian on 5/3/15.
//  Copyright (c) 2015 Adorkable. All rights reserved.
//

import Cocoa

import StoryboardKit

import Stencil

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        
        var outputDirectory : NSURL?
        var storyboardFilePath : NSURL?
        var projectName : String?
        
        let arguments = NSProcessInfo.processInfo().arguments
        var index = 0
        while index < arguments.count
        {
            if let argument = arguments[index] as? String
            {
                if argument == "--outputPath"
                {
                    index += 1
                    outputDirectory = NSURL(fileURLWithPath: arguments[index] as! String)
                } else if argument == "--storyboardFile"
                {
                    index += 1
                    storyboardFilePath = NSURL(fileURLWithPath: arguments[index] as! String)
                } else if argument == "--projectName"
                {
                    index += 1
                    projectName = arguments[index] as? String
                }
            }
            
            index += 1
        }
        
        var applicationInfo = ApplicationInfo()
        
        if let storyboardFilePath = storyboardFilePath,
            let storyboardFilePathString = storyboardFilePath.path,
            let storyboardFileName = storyboardFilePath.lastPathComponent?.stringByDeletingPathExtension
        {
            
            let result = StoryboardFileParser.parse(applicationInfo, pathFileName: storyboardFilePathString)

            if let outputDirectory = outputDirectory
            {
                if let storyboard = result.0
                {
                    self.export(outputPath: outputDirectory, application: applicationInfo, storyboard: storyboard, storyboardFileName: storyboardFileName, projectName : projectName)
                } else if let error = result.1
                {
                    NSLog("Error while parsing storyboard \(storyboardFilePathString): \(error)")
                } else
                {
                    NSLog("Unknown Error while parsing storyboard \(storyboardFilePathString)")
                }
            } else
            {
                NSLog("Need to specify --outputPath with a valid path")
            }
        } else
        {
            NSLog("Need to specify --storyboardFilePath with a valid Storyboard file")
        }
        
        NSApplication.sharedApplication().stop(nil)
    }
    
    func export(#outputPath : NSURL, application : ApplicationInfo, storyboard : StoryboardInstanceInfo, storyboardFileName : String, projectName : String?) {
        
        for viewControllerClass in application.viewControllerClasses
        {
            let fileName = viewControllerClass.separateFileName(storyboardFileName)
            if let stencilContext = viewControllerClass.stencilContext(fileName + ".swift", projectName: projectName)
            {
                let template = Template(templateString: DefaultStencil.separateFile)
                let result = template.render(stencilContext)
                
                switch result
                {
                case .Success(let contents):
                    self.write(outputPath: outputPath, fileName: fileName + ".swift", contents: contents)
                    break
                case .Error(let error):
                    NSLog("Error while rendering contents: \(error).")
                    break
                }
            } else
            {
                // TODO: delete output file
                NSLog("No information to export for view controller class \(viewControllerClass)")
            }
        }
    }
    
    func write(#outputPath : NSURL, fileName : String, contents : String) {
        var createDirectoryError : NSError? = nil
        NSFileManager.defaultManager().createDirectoryAtURL(outputPath, withIntermediateDirectories: true, attributes: nil, error: &createDirectoryError)
        
        if let error = createDirectoryError
        {
            NSLog("Error while creating output directory \(outputPath): \(error)")
        }
        
        if let path = outputPath.path
        {
            let fullFilePath = path + "/" + fileName
            
            var writeToFileError : NSError? = nil
            contents.writeToFile(fullFilePath, atomically: true, encoding: NSUTF8StringEncoding, error: &writeToFileError)
            if let error = writeToFileError
            {
                NSLog("Error while writing to file \(fullFilePath): \(error)")
            }
        }
    }
}