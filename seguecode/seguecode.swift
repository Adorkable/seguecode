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
    public class func handleParameters(parameters : [String]) {
        let cli = CommandLine(arguments: parameters)
        
        let storyboardFilePath = StringOption(shortFlag: "s", longFlag: "storyboardFile", required: true, helpMessage: "Path to storyboard to process.")
        let outputPath = StringOption(shortFlag: "o", longFlag: "outputPath", required: true, helpMessage: "Path to output generated files.")
        let projectName = StringOption(shortFlag: "p", longFlag: "project", required: false, helpMessage: "Name of project (Optional).")
        
        cli.addOptions([storyboardFilePath, outputPath, projectName])
        
        var result = cli.parse(strict: true)
        if result.0 == true
        {
            if let storyboardFilePath = storyboardFilePath.value,
                let storyboardFilePathUrl = NSURL(fileURLWithPath: storyboardFilePath),
                let outputPath = outputPath.value,
                let outputPathUrl = NSURL(fileURLWithPath: outputPath)
            {
                self.parse(storyboardFilePathUrl, outputPath: outputPathUrl, projectName: projectName.value)
                exit(EX_USAGE)
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
    
    public class func parse(storyboardFilePath : NSURL, outputPath : NSURL, projectName : String?) {
        var applicationInfo = ApplicationInfo()
        
        if let storyboardFilePathString = storyboardFilePath.path,
            let storyboardFileName = storyboardFilePath.lastPathComponent?.stringByDeletingPathExtension
        {
            
            let result = StoryboardFileParser.parse(applicationInfo, pathFileName: storyboardFilePathString)
            

            if let storyboard = result.0
            {
                self.export(outputPath: outputPath, application: applicationInfo, storyboard: storyboard, storyboardFileName: storyboardFileName, projectName : projectName)
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
    
    public class func export(#outputPath : NSURL, application : ApplicationInfo, storyboard : StoryboardInstanceInfo, storyboardFileName : String, projectName : String?) {
        
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
    
    public class func write(#outputPath : NSURL, fileName : String, contents : String) {
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