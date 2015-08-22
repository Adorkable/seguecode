//
//  SecondViewController+Main_iPhone.swift
//  Example
//
//  Generated by seguecode [http://bit.ly/1JqWiqR] on 8/22/15
//

import UIKit

extension SecondViewController {

    struct Segue
    {
        struct FirstSecondBackToFirst : SegueProtocol
        {
            static var identifier : String {
                return "BackTo"
            }
        }
    }
   static let SecondSecondBackToFirstIdentifer = "BackTo"
    
   @IBAction func performFirstSecondBackToFirst(sender : AnyObject? = nil) {
       self.performSegue(SecondViewController.Segue.FirstSecondBackToFirst(), sender: sender)
   }

   @IBAction func performSecondSecondBackToFirst(sender : AnyObject? = nil) {
       self.performSegue(SecondViewController.Segue.SecondSecondBackToFirst, sender: sender)
   }
}