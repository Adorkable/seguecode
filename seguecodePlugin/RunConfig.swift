//
//  RunConfig.swift
//  seguecode
//
//  Created by Ian Grossberg on 11/17/15.
//  Copyright © 2015 Adorkable. All rights reserved.
//

import Foundation

class RunConfig: NSObject {
    
    static let FileNameSuffix = ".seguecode.json"
    
    var combine = false
    var outputPath = "./Generated"
    var projectName : String? = nil
    
    override init() {
        super.init()
    }
    
    init?(url : NSURL) throws {
        super.init()
        
        guard let json = try NSJSONSerialization.JSONObjectWithContentsOfURL(url) else {

            // TODO:
            return nil // TODO: throw?
        }
        
        if let combine = (json["combine"] as? NSNumber)?.boolValue {
            self.combine = combine
        }

        if let outputPath = json["outputPath"] as? String {
            self.outputPath = outputPath
        }
        
        if let projectName = json["projectName"] as? String {
            self.projectName = projectName
        }
    }
    
    convenience init?(forStoryboardAtUrl storyboardUrl : NSURL) throws {
        guard let url = RunConfig.urlForRunConfigForStoryboard(storyboardUrl: storyboardUrl) else {

            // TODO: throws?
            self.init()
            return nil
        }
        
        try self.init(url: url)
    }
    
    class func urlForRunConfigForStoryboard(storyboardUrl storyboardUrl : NSURL) -> NSURL? {
        
        guard let storyboardLocationWithName = storyboardUrl.URLByDeletingPathExtension else {
            // TODO:
            return nil
        }
        
        return NSURL(string: "\(storyboardLocationWithName)\(self.FileNameSuffix)")
    }
    
    func writeForStoryboard(storyboardUrl storyboardUrl : NSURL) throws {
        guard let url = RunConfig.urlForRunConfigForStoryboard(storyboardUrl: storyboardUrl) else {
            
            // TODO: throws?
            return
        }
        
        let json = [
            "combine" : self.combine,
            "outputPath" : self.outputPath
        ]
        
        if let projectName = self.projectName {
            json.setValue(projectName, forKey: "projectName")
        }
        
        try NSJSONSerialization.writeJSONObjectToURL(json, url: url)
    }
    
    class func removeForStoryboard(storyboardUrl storyboardUrl : NSURL) throws {
        
        guard let url = RunConfig.urlForRunConfigForStoryboard(storyboardUrl: storyboardUrl) else {
            
            // TODO: throws?
            return
        }
        
        try NSFileManager.defaultManager().removeItemAtURL(url)
    }
}
