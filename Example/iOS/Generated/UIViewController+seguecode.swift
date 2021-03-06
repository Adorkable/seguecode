//
//  UIViewController+seguecode.swift
//  Example
//
//  Generated by seguecode [http://bit.ly/seguecode]
//

import UIKit

extension UIViewController {
    class Segue : NSObject
    {
        let identifier : String

        init(identifier : String) {
            self.identifier = identifier
        }
    }

    func performSegue(segue : Segue, sender : AnyObject?) {
        self.performSegueWithIdentifier(segue.identifier, sender: sender)
    }

    class StoryboardInstance : NSObject
    {
        let identifier : String

        init(identifier : String) {
            self.identifier = identifier
        }
    }
}

extension UIStoryboard {
    func instantiateViewController(instance : UIViewController.StoryboardInstance) -> UIViewController {

        return self.instantiateViewControllerWithIdentifier(instance.identifier)
    }
}

extension UITableView {
    class TableViewCellPrototype : NSObject
    {
        let reuseIdentifier : String

        init(reuseIdentifier : String) {
            self.reuseIdentifier = reuseIdentifier
        }
    }

    func dequeueReusableCell(cellPrototype : TableViewCellPrototype) -> UITableViewCell? {
        return self.dequeueReusableCellWithIdentifier(cellPrototype.reuseIdentifier)
    }

    func dequeueReusableCell(cellPrototype : TableViewCellPrototype, forIndexPath indexPath : NSIndexPath) -> UITableViewCell {
        return self.dequeueReusableCellWithIdentifier(cellPrototype.reuseIdentifier, forIndexPath: indexPath)
    }
}

extension UICollectionView {
    class CollectionViewCellPrototype : NSObject
    {
        let reuseIdentifier : String

        init(reuseIdentifier : String) {
            self.reuseIdentifier = reuseIdentifier
        }
    }

    func dequeueReusableCell(cellPrototype : CollectionViewCellPrototype, forIndexPath indexPath : NSIndexPath) -> UICollectionViewCell {
        return self.dequeueReusableCellWithReuseIdentifier(cellPrototype.reuseIdentifier, forIndexPath: indexPath)
    }
}
