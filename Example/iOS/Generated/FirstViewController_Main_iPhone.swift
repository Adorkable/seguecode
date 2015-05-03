//
//  FirstViewController_Main_iPhone.swift
//  seguecode
//
//  Generated on 5/4/15.
//

import UIKit

extension FirstViewController {
    enum Segue : String, SegueProtocol
    {
        case FirstForwardTo1stSecond = "ForwardTo"
        case FirstGoTo2ndSecond = "GoTo"
        case FirstForwardToUIVC = "ForwardToUIVC"
        
        var identifier : String {
            get {
                return self.rawValue
            }
        }
    }
    
    @IBAction func performFirstForwardTo1stSecond(sender : AnyObject? = nil) {
        self.performSegue(FirstViewController.Segue.FirstForwardTo1stSecond, sender: sender)
    }

    @IBAction func performFirstForwardTo2stSecond(sender : AnyObject? = nil) {
        self.performSegue(FirstViewController.Segue.FirstGoTo2ndSecond, sender: sender)
    }
    
    @IBAction func performFirstForwardToUIVC(sender : AnyObject? = nil) {
        self.performSegue(FirstViewController.Segue.FirstForwardToUIVC, sender: sender)
    }
}