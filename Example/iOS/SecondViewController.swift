//
//  SecondViewController.swift
//  seguecode
//
//  Created by Ian on 5/11/15.
//  Copyright (c) 2015 Adorkable. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {
}

extension SecondViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return self.dequeueReusableSecondTableCell(tableView, forIndexPath : indexPath)
    }
    
    @IBAction func instanciateSecondSecond(sender : AnyObject) {
        AppDelegate.sharedInstance().window?.rootViewController = self.storyboard?.instantiateViewController(SecondViewController.StoryboardInstances.SecondSecond)
    }
}
