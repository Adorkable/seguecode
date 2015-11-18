//
//  NSFileHandle+Utility.swift
//  seguecode
//
//  Created by Ian Grossberg on 11/17/15.
//  Copyright © 2015 Adorkable. All rights reserved.
//

import Foundation

extension NSFileHandle {
    
    var availableString : String? {
        
        return NSString(data: self.availableData, encoding: NSUTF8StringEncoding) as? String
    }
}