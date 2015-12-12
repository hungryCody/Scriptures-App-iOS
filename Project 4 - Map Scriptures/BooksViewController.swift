//
//  BooksViewController.swift
//  Project 4 - Map Scriptures
//
//  Created by Michael Perry on 11/27/15.
//  Copyright © 2015 Michael Perry. All rights reserved.
//

import UIKit

class BooksViewController: UITableViewController {
    
    // Mark: - Properties
    
    var books: [Book]!
    
    // Mark: - Table view data source
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BookCell")!
        
        cell.textLabel?.text = books[indexPath.row].fullName
        
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return books.count
    }
    
    // mark: - table view delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if books[indexPath.row].numChapters == nil {
            performSegueWithIdentifier("showScripture", sender: self)
        } else {
            performSegueWithIdentifier("showChapter", sender: self)
        }
    }
    
    // mark: - segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "showChapter" {
            if let indexPath = tableView.indexPathForSelectedRow {
                if let destVC = segue.destinationViewController as? ChaptersViewController {
                    
                    destVC.book = books[indexPath.row]
                    destVC.numberOfChapters = books[indexPath.row].numChapters!
                    destVC.title = books[indexPath.row].fullName
                    
                }
            }
        } else if segue.identifier == "showScripture" {
            if let indexPath = tableView.indexPathForSelectedRow {
                if let destVC = segue.destinationViewController as? ScripturesViewController {
                    destVC.book = books[indexPath.row]
                    destVC.title = books[indexPath.row].fullName
                }
            }
        }
    }
}
