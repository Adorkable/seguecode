//
//  SecondViewController+Main_iPhone.swift
//  Example
//
//  Generated by seguecode [http://bit.ly/1JqWiqR] on 8/22/15
//

import UIKit

extension SecondViewController {

   struct Segues {
       static let SecondSecondBackToFirst = Segue(identifier: "BackTo")
       static let FirstSecondBackToFirst = Segue(identifier: "BackTo")
   }

   @IBAction func performSecondSecondBackToFirst(sender : AnyObject? = nil) {
       self.performSegue(SecondViewController.Segues.SecondSecondBackToFirst, sender: sender)
   }

   @IBAction func performFirstSecondBackToFirst(sender : AnyObject? = nil) {
       self.performSegue(SecondViewController.Segues.FirstSecondBackToFirst, sender: sender)
   }
}