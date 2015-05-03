//
//  DefaultStencil.swift
//  seguecode
//
//  Created by Ian Grossberg on 8/21/15.
//  Copyright (c) 2015 Adorkable. All rights reserved.
//

import Cocoa

class DefaultStencil: NSObject {
    struct Keys
    {
        static let FileName = "FileName"
        static let ProjectName = "ProjectName"
        
        static let GeneratedOn = "GeneratedOn"
        
        static let ViewControllerName = "ViewControllerName"
        
        static let SegueCases = "SegueCases"
        struct SegueCase
        {
            static let Name = "Name"
            static let Value = "Value"
        }
        
        static let PerformFunctions = "PerformFunctions"
        struct PerformFunction
        {
            static let Name = "Name"
            static let Segue = "Segue"
        }
    }
    
    static var separateFile : String {
        // TODO: wrap everything in ifs
        return "//\n" +
            "//  {{ \(Keys.FileName) }}\n" +
            "//  {{ \(Keys.ProjectName) }}\n" +
            "//\n" +
            "//  Generated by seguecode [http://bit.ly/1JqWiqR] on {{ \(Keys.GeneratedOn) }}\n" +
            // TODO: copywrite and company info?
            "//\n" +
            "\n" +
            "import UIKit\n" +
            "\n" +
            "extension {{ \(Keys.ViewControllerName) }} {\n" +
            "{% if \(Keys.SegueCases) %}" +
            "\n" +
            "   enum Segue : String {\n" +
            "{% for segueCase in \(Keys.SegueCases) %}" +
            "       case {{ segueCase.\(Keys.SegueCase.Name) }} = \"{{ segueCase.\(Keys.SegueCase.Value) }}\"\n" +
            "{% endfor %}" +
            "\n" +
            "       var identifier : String {\n" +
            "           return self.rawValue\n" +
            "       }\n" +
            "   }\n" +
            "{% endif %}" +
            "{% if \(Keys.PerformFunctions) %}" +
            "{% for performFunction in \(Keys.PerformFunctions) %}" +
            "\n" +
            "   @IBAction func perform{{ performFunction.\(Keys.PerformFunction.Name) }}(sender : AnyObject? = nil) {\n" +
            "       self.performSegue({{ \(Keys.ViewControllerName) }}.Segue.{{ performFunction.\(Keys.PerformFunction.Segue) }}, sender: sender)\n" +
            "   }\n" +
            "{% endfor %}" +
            "{% endif %}" +
        "}"
    }
}