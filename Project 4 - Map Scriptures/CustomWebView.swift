//
//  CustomWebView.swift
//  Project 4 - Map Scriptures
//
//  Created by Michael Perry on 12/8/15.
//  Copyright © 2015 Michael Perry. All rights reserved.
//

import UIKit

protocol SuggestionDisplayDelegate {
    func displaySuggestionDialog()
}

class CustomWebView: UIWebView {
    
    var suggestionDelegate: SuggestionDisplayDelegate?
    
    func suggestGeocoding(sender: AnyObject) {
        suggestionDelegate?.displaySuggestionDialog()
    }
    override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        if action == "suggestGeocoding:" {
            return true
        }
        
        return super.canPerformAction(action, withSender: sender)
    }
}
