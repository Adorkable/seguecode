//
//  NSJSONSerialization+Utility.swift
//  seguecode
//
//  Created by Ian Grossberg on 11/17/15.
//  Copyright © 2015 Adorkable. All rights reserved.
//

import Foundation

extension NSJSONSerialization {
    
    class func JSONObjectWithContentsOfURL(url : NSURL, options : NSJSONReadingOptions = []) throws -> AnyObject? {
        guard let data = NSData(contentsOfURL: url) else {
            // TODO:
            return nil // TODO: throw?
        }

        return try self.JSONObjectWithData(data, options: options)
    }
    
    class func writeJSONObjectToURL(json : AnyObject, url : NSURL, jsonOptions : NSJSONWritingOptions = [], writeOptions : NSDataWritingOptions = []) throws {
        
        let data = try self.dataWithJSONObject(json, options: jsonOptions)
        try data.writeToURL(url, options: writeOptions)
    }
}