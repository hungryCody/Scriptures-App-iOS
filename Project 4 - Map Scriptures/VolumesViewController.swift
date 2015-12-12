//
//  VolumesViewController.swift
//  Project 4 - Map Scriptures
//
//  Created by Michael Perry on 11/27/15.
//  Copyright © 2015 Michael Perry. All rights reserved.
//

import UIKit

class VolumesViewController: UITableViewController {
    
    // Mark: - Properties
    
    var volumes = GeoDatabase.sharedGeoDatabase.volumes()
    
    // mark: - segways
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showBooks" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                if let destVC = segue.destinationViewController as? BooksViewController {
                    destVC.books = GeoDatabase.sharedGeoDatabase.booksForParentId(indexPath.row + 1)
                    destVC.title = volumes[indexPath.row]
                }
            }
        }
    }
    
    // Mark: - Table view data source
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("VolumeCell")!
        
        cell.textLabel?.text = volumes[indexPath.row]
        
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return volumes.count
    }
}