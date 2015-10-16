//
//  Template+seguecode.swift
//  seguecode
//
//  Created by Ian Grossberg on 8/22/15.
//  Copyright (c) 2015 Adorkable. All rights reserved.
//

import Foundation

import Stencil

extension Template
{
    class func write(templateString templateString : String, outputPath : NSURL, fileName : String, context : Context) {
        
        let template = Template(templateString: templateString)
        template.write(outputPath: outputPath, fileName: fileName, context: context)
    }
    
    func write(outputPath outputPath : NSURL, fileName : String, context : Context) {
        do
        {
            let contents = try self.render(context)
            Template.writeContents(outputPath: outputPath, fileName: fileName, contents: contents)
            
        } catch let error as NSError
        {
            NSLog("Error while rendering contents: \(error).")
        }
    }
    
    private class func writeContents(outputPath outputPath : NSURL, fileName : String, contents : String) {

        do
        {
            try NSFileManager.defaultManager().createDirectoryAtURL(outputPath, withIntermediateDirectories: true, attributes: nil)
        } catch let error as NSError
        {
            NSLog("Error while creating output directory \(outputPath): \(error)")
        }
        
        if let path = outputPath.path
        {
            let fullFilePath = path + "/" + fileName
            
            do
            {
                try contents.writeToFile(fullFilePath, atomically: true, encoding: NSUTF8StringEncoding)
                NSLog("Exported \(fileName)")
            } catch let error as NSError
            {
                NSLog("Error while writing to file \(fullFilePath): \(error)")
            }
        }
    }
}