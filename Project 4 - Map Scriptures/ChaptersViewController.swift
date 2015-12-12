//
//  ChaptersViewController.swift
//  Project 4 - Map Scriptures
//
//  Created by Michael Perry on 11/27/15.
//  Copyright © 2015 Michael Perry. All rights reserved.
//

import UIKit

class ChaptersViewController: UITableViewController {
    
    // Mark: - Properties
    
    var book: Book!
    var numberOfChapters = 0
    
    // Mark: - Table view data source
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ChapterCell")!
        
        cell.textLabel?.text = "\(book.fullName) \(indexPath.row + 1)"
        
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfChapters
    }
    
    // mark; - segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showScripture" {
            if let indexPath = tableView.indexPathForSelectedRow {
                if let destVC = segue.destinationViewController as? ScripturesViewController {
                    destVC.book = self.book
                    destVC.chapter = indexPath.row + 1
                    destVC.title = tableView.cellForRowAtIndexPath(indexPath)?.textLabel!.text
                }
            }
        }
    }

}