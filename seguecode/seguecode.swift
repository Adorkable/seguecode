//
//  seguecode.swift
//  seguecode
//
//  Created by Ian Grossberg on 8/22/15.
//  Copyright (c) 2015 Adorkable. All rights reserved.
//

import Foundation

import StoryboardKit

import Stencil

import CommandLine

public class seguecode : NSObject
{
    public class func handleParametersAndRun(parameters : [String]) {
        let cli = CommandLine(arguments: parameters)
        
        let storyboardFilePath = StringOption(shortFlag: "s", longFlag: "storyboardFile", required: true, helpMessage: "Path to storyboard to process.")
        let outputPath = StringOption(shortFlag: "o", longFlag: "outputPath", required: true, helpMessage: "Path to output generated files.")
        let projectName = StringOption(shortFlag: "p", longFlag: "project", required: false, helpMessage: "Name of project (Optional).")
        let exportTogether = BoolOption(shortFlag: "c", longFlag: "combine", helpMessage: "Export the View Controllers combined in one file (Optional).")
        
        cli.addOptions([storyboardFilePath, outputPath, projectName, exportTogether])
        
        var result = cli.parse(strict: true)
        if result.0 == true
        {
            if let storyboardFilePath = storyboardFilePath.value,
                let storyboardFilePathUrl = NSURL(fileURLWithPath: storyboardFilePath),
                let outputPath = outputPath.value,
                let outputPathUrl = NSURL(fileURLWithPath: outputPath)
            {
                self.parse(storyboardFilePathUrl, outputPath: outputPathUrl, projectName: projectName.value, exportTogether: exportTogether.value)
                exit(EX_OK)
            } else
            {
                cli.printUsage()
                exit(EX_USAGE)
            }
        } else
        {
            if let feedback = result.1
            {
                println("Error: \(feedback)")
            }
            cli.printUsage()
            exit(EX_USAGE)
        }
    }
    
    public class func parse(storyboardFilePath : NSURL, outputPath : NSURL, projectName : String?, exportTogether : Bool) {
        var application = ApplicationInfo()
        
        if let storyboardFilePathString = storyboardFilePath.path,
            let storyboardFileName = storyboardFilePath.lastPathComponent?.stringByDeletingPathExtension
        {
            
            let result = StoryboardFileParser.parse(application, pathFileName: storyboardFilePathString)
            
            if let storyboard = result.0
            {
                if exportTogether == true
                {
                    self.exportTogether(outputPath: outputPath, application: application, storyboard: storyboard, storyboardFileName: storyboardFileName, projectName: projectName)
                } else
                {
                    self.exportSeperately(outputPath: outputPath, application: application, storyboard: storyboard, storyboardFileName: storyboardFileName, projectName : projectName)
                }
                self.exportSharedDefinitions(outputPath: outputPath, projectName: projectName)
                
            } else if let error = result.1
            {
                NSLog("Error while parsing storyboard \(storyboardFilePathString): \(error)")
            } else
            {
                NSLog("Unknown Error while parsing storyboard \(storyboardFilePathString)")
            }
        } else
        {
            NSLog("Need to specify --storyboardFilePath with a valid Storyboard file, received \(storyboardFilePath)")
        }
    }
    
    internal class func fileStencilContext(#outputPath : NSURL, fileName : String, projectName : String?) -> [String : AnyObject]?
    {
        let generatedOn = NSDate()
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "M/d/YY"
        let generatedOnString = dateFormatter.stringFromDate(generatedOn)
        
        var result : [String : AnyObject] = [
            DefaultTemplate.Keys.FileName : fileName,
            DefaultTemplate.Keys.GeneratedOn : generatedOnString
        ]
        
        if let projectName = projectName
        {
            result[DefaultTemplate.Keys.ProjectName] = projectName
        }
        
        return result
    }
    
    internal class func exportSeperately(#outputPath : NSURL, application : ApplicationInfo, storyboard : StoryboardInstanceInfo, storyboardFileName : String, projectName : String?) {
        
        for viewControllerClass in application.viewControllerClasses
        {
            var contextDictionary : [String : AnyObject]
            
            let fileName = viewControllerClass.separateFileName(storyboardFileName) + ".swift"

            if let fileStencilContext = self.fileStencilContext(outputPath: outputPath, fileName: fileName, projectName: projectName)
            {
                contextDictionary = fileStencilContext
                
                var viewControllers = [ [String : AnyObject] ]()
                if let viewControllerContext = viewControllerClass.stencilContext()
                {
                    viewControllers.append(viewControllerContext)
                }
                
                if viewControllers.count > 0
                {
                    contextDictionary[DefaultTemplate.Keys.ViewControllers] = viewControllers
                    
                    let stencilContext = Context(dictionary: contextDictionary)
                    Template.write(templateString: DefaultTemplate.sourceFile, outputPath: outputPath, fileName: fileName, context: stencilContext)
                } else
                {
                    // TODO: delete output file? output empty file?
                    NSLog("No information to export for view controller class \(viewControllerClass)")
                }
            }
        }
    }
    
    internal class func exportTogether(#outputPath : NSURL, application : ApplicationInfo, storyboard : StoryboardInstanceInfo, storyboardFileName : String, projectName : String?) {
    
        let fileName = storyboardFileName + ".swift"
        
        if let fileStencilContext = self.fileStencilContext(outputPath: outputPath, fileName: fileName, projectName: projectName)
        {
            var contextDictionary = fileStencilContext
            
            var viewControllers = [ [String : AnyObject] ]()
            for viewControllerClass in application.viewControllerClasses
            {
                if let viewControllerContext = viewControllerClass.stencilContext()
                {
                    viewControllers.append(viewControllerContext)
                }
            }
            
            if viewControllers.count > 0
            {
                contextDictionary[DefaultTemplate.Keys.ViewControllers] = viewControllers
                
                let stencilContext = Context(dictionary: contextDictionary)
                Template.write(templateString: DefaultTemplate.sourceFile, outputPath: outputPath, fileName: fileName, context: stencilContext)
            } else
            {
                // TODO: delete output file? output empty file?
                NSLog("No information to export")
            }
        }
    }
    
    internal class func exportSharedDefinitions(#outputPath : NSURL, projectName : String?) {
        var contextDictionary : [String : AnyObject]
        
        let fileName = "UIViewController+seguecode.swift"
        
        if let fileStencilContext = self.fileStencilContext(outputPath: outputPath, fileName: fileName, projectName: projectName)
        {
            var contextDictionary = fileStencilContext
            
            let stencilContext = Context(dictionary: contextDictionary)
            Template.write(templateString: DefaultTemplate.sharedFile, outputPath: outputPath, fileName: fileName, context: stencilContext)
        }
    }
    
    
}