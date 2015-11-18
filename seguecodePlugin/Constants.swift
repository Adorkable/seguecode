//
//  Constants.swift
//  seguecode
//
//  Created by Ian Grossberg on 11/17/15.
//  Copyright © 2015 Adorkable. All rights reserved.
//

import Foundation

import AppKit

class Constants {
    
    struct Storyboard {
        static let extensionString = "storyboard"
    }
    
    struct Xcode {
        struct IDE {
            static let submenuName = "Edit"
            
            static var submenuInstance : NSMenuItem? {

                guard let mainMenu = NSApp.mainMenu else {
                    // TODO:
                    return nil
                }
                
                return mainMenu.itemWithTitle(self.submenuName)
            }
        }
        
        struct Plugin {
            
            struct DVTDocumentLocation {
                static let className = "DVTDocumentLocation"
                
                static var classInstance : AnyClass? {
                    return NSClassFromString(self.className)
                }
                
                static let documentUrlSelector = "documentURL"
                
                static var documentUrlSelectorInstance : Selector {
                    return NSSelectorFromString(self.documentUrlSelector)
                }
            }
        }
    }
}