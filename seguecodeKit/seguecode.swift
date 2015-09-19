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

public class seguecode : NSObject
{
    public class func parse(storyboardFilePath : NSURL, outputPath : NSURL, projectName : String?, exportTogether : Bool, verboseLogging : Bool) {
        let application = ApplicationInfo()
        
        NSLog("Writing to output path \(outputPath)")
        if let projectName = projectName
        {
            NSLog("Using project name \"\(projectName)\"")
        }
        
        NSLog("\n")
        
        if let storyboardFilePathString = storyboardFilePath.path
        {
            
            do {
                let result = try StoryboardFileParser.parse(application, pathFileName: storyboardFilePathString)
                
                if verboseLogging == true
                {
                    if let logs = result.1
                    {
                        if logs.count > 0
                        {
                            NSLog("Verbose Logs:")
                            for message in logs
                            {
                                NSLog("\(message)")
                            }
                            NSLog("\n")
                        }
                    }
                }
                
                
                if let storyboard = result.0,
                    let storyboardFileNameWithExtension = storyboardFilePath.lastPathComponent
                {
                    let storyboardFileName = (storyboardFileNameWithExtension as NSString).stringByDeletingPathExtension
                    
                    if exportTogether == true
                    {
                        self.exportTogether(outputPath: outputPath, application: application, storyboard: storyboard, storyboardFileName: storyboardFileName, projectName: projectName)
                    } else
                    {
                        self.exportSeperately(outputPath: outputPath, application: application, storyboard: storyboard, storyboardFileName: storyboardFileName, projectName : projectName)
                    }
                    self.exportSharedDefinitions(outputPath: outputPath, projectName: projectName)
                    
                }else
                {
                    NSLog("Unknown Error while parsing storyboard \(storyboardFilePathString)")
                }
            
            } catch let error as NSError
            {
                NSLog("Error while parsing storyboard \(storyboardFilePathString): \(error)")
            }
        } else
        {
            NSLog("Need to specify --storyboardFilePath with a valid Storyboard file, received \(storyboardFilePath)")
        }
    }
    
    internal class func fileStencilContext(outputPath outputPath : NSURL, fileName : String, projectName : String?) -> [String : AnyObject]?
    {
        let generatedOn = NSDate()
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "M/d/YY"
        _ = dateFormatter.stringFromDate(generatedOn)
        
        var result : [String : AnyObject] = [
            DefaultTemplate.Keys.FileName : fileName
            // TODO: until we have MD5 checking on the remainder of the file contents we don't to cause unimportant file diffs
            /*, DefaultTemplate.Keys.GeneratedOn : generatedOnString*/
        ]
        
        if let projectName = projectName
        {
            result[DefaultTemplate.Keys.ProjectName] = projectName
        }
        
        return result
    }
    
    internal class func exportSeperately(outputPath outputPath : NSURL, application : ApplicationInfo, storyboard : StoryboardInstanceInfo, storyboardFileName : String, projectName : String?) {
        
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
                    NSLog("No information to export for view controller class \(viewControllerClass.infoClassName)")
                }
            }
        }
    }
    
    internal class func exportTogether(outputPath outputPath : NSURL, application : ApplicationInfo, storyboard : StoryboardInstanceInfo, storyboardFileName : String, projectName : String?) {
    
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
    
    internal class func exportSharedDefinitions(outputPath outputPath : NSURL, projectName : String?) {
        var _ : [String : AnyObject]
        
        let fileName = "UIViewController+seguecode.swift"
        
        if let fileStencilContext = self.fileStencilContext(outputPath: outputPath, fileName: fileName, projectName: projectName)
        {
            let contextDictionary = fileStencilContext
            
            let stencilContext = Context(dictionary: contextDictionary)
            Template.write(templateString: DefaultTemplate.sharedFile, outputPath: outputPath, fileName: fileName, context: stencilContext)
        }
    }
    
    
}