//
//  AppDelegate.swift
//  Project 4 - Map Scriptures
//
//  Created by Michael Perry on 11/27/15.
//  Copyright © 2015 Michael Perry. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {
    
    // mark: - peroperties
    
    var window: UIWindow?
    
    // mark: - application lifecycle
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        //This value is used for saying whether or not a user pin should exist
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "showUser")
        NSUserDefaults.standardUserDefaults().synchronize()
        
        let splitViewController = self.window!.rootViewController as! UISplitViewController
        let navigationController = splitViewController.viewControllers.last as! UINavigationController
        
        navigationController.topViewController!.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem()
        splitViewController.delegate = self
        
        UIMenuController.sharedMenuController().menuItems = [UIMenuItem(title: "Suggest Geocoding", action: "suggestGeocoding:")]
        
        return true
    }
    
    // MARK: - Split view
    
    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController:UIViewController, ontoPrimaryViewController primaryViewController:UIViewController) -> Bool {
        
        guard let secondaryAsNavController = secondaryViewController as? UINavigationController else { return false }
        guard let _ = secondaryAsNavController.topViewController as? MapViewController else { return false }
        
        return true
    }
    
    func splitViewController(splitViewController: UISplitViewController, separateSecondaryViewControllerFromPrimaryViewController primaryViewController: UIViewController) -> UIViewController? {

        if let navVC = primaryViewController as? UINavigationController {
            for controller in navVC.viewControllers {
                if let controllerVC = controller as? UINavigationController {
                    //we found our detail VC on the master nav VC stack
                    return controllerVC
                }
            }
        }

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let detailView = storyboard.instantiateViewControllerWithIdentifier("detailVC") as! UINavigationController
        
        if let controller = detailView.visibleViewController {
            controller.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem()
            controller.navigationItem.leftItemsSupplementBackButton = true
        }
        
        return detailView
    }
    
    
    
}

