//
//  FirstViewController+Main_iPhone.swift
//
//  Generated by seguecode [http://bit.ly/seguecode] on 8/24/15
//

import UIKit

extension FirstViewController {

   struct Segues {
       static let FirstForwardToUIVC = Segue(identifier: "ForwardToUIVC")
       static let FirstGoToSecondSecond = Segue(identifier: "GoTo")
       static let FirstForwardToFirstSecond = Segue(identifier: "ForwardTo")
   }

   @IBAction func performFirstForwardToUIVC(sender : AnyObject? = nil) {
       self.performSegue(FirstViewController.Segues.FirstForwardToUIVC, sender: sender)
   }

   @IBAction func performFirstGoToSecondSecond(sender : AnyObject? = nil) {
       self.performSegue(FirstViewController.Segues.FirstGoToSecondSecond, sender: sender)
   }

   @IBAction func performFirstForwardToFirstSecond(sender : AnyObject? = nil) {
       self.performSegue(FirstViewController.Segues.FirstForwardToFirstSecond, sender: sender)
   }
}
