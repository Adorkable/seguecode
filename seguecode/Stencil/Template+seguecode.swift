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
    class func write(#templateString : String, outputPath : NSURL, fileName : String, context : Context) {
        
        let template = Template(templateString: templateString)
        template.write(outputPath: outputPath, fileName: fileName, context: context)
    }
    
    func write(#outputPath : NSURL, fileName : String, context : Context) {
        let result = self.render(context)
        
        switch result
        {
        case .Success(let contents):
            self.writeContents(outputPath: outputPath, fileName: fileName, contents: contents)
            break
        case .Error(let error):
            NSLog("Error while rendering contents: \(error).")
            break
        }
    }
    
    private func writeContents(#outputPath : NSURL, fileName : String, contents : String) {
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
            } else
            {
                NSLog("Exported \(fileName)")
            }
        }
    }
}