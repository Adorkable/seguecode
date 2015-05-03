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
    
    var outputDirectory : NSURL?

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        for argument in NSProcessInfo.processInfo().arguments
        {
            
        }
        
        var applicationInfo = ApplicationInfo()
        
        let storyboardFileName = "/Users/ian/Documents/Adorkable/seguecode/Example/iOS/Base.lproj/Main_iPhone.storyboard"
        
        let result = StoryboardFileParser.parse(applicationInfo, pathFileName: storyboardFileName)
        
        self.outputDirectory = NSURL(fileURLWithPath: "/Users/ian/Documents/Adorkable/seguecode/TestOutput/")
        
        if let storyboard = result.0
        {
            self.export(outputPath: self.outputDirectory!, application: applicationInfo, storyboard: storyboard, storyboardFileName: "Main_iPhone", projectName : "Example")
        } else if let error = result.1
        {
            NSLog("Error while parsing storyboard \(storyboardFileName): \(error)")
        } else
        {
            NSLog("Unknown Error while parsing storyboard \(storyboardFileName)")
        }
        
        NSApplication.sharedApplication().stop(nil)
    }
    
    func export(#outputPath : NSURL, application : ApplicationInfo, storyboard : StoryboardInstanceInfo, storyboardFileName : String, projectName : String) {
        
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