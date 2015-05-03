//
//  AppDelegate.swift
//  seguecodeiOSExample
//
//  Created by Ian on 5/4/15.
//  Copyright (c) 2015 Adorkable. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    class func sharedInstance() -> AppDelegate {
        return UIApplication.sharedApplication().delegate as! AppDelegate
    }
}

