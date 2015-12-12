//
//  FormTableViewController.swift
//  Project 4 - Map Scriptures
//
//  Created by Michael Perry on 12/8/15.
//  Copyright © 2015 Michael Perry. All rights reserved.
//

import UIKit

class FormTableViewController: UITableViewController, UITextFieldDelegate {
    
    // mark: - outlets
    
    @IBOutlet weak var txtPlaceName: UITextField!
    @IBOutlet weak var txtLatitude: UITextField!
    @IBOutlet weak var txtLongitude: UITextField!
    @IBOutlet weak var txtViewLatitude: UITextField!
    @IBOutlet weak var txtViewLongitude: UITextField!
    @IBOutlet weak var txtViewTilt: UITextField!
    @IBOutlet weak var txtViewRoll: UITextField!
    @IBOutlet weak var txtViewAltitude: UITextField!
    @IBOutlet weak var txtViewHeading: UITextField!
    
    // mark: - properties
    
    var selectedPlaceName: String?
    var latitude: Double?
    var longitude: Double?
    var heading: Double?
    var altitude: Double?
    
    // mark: - page life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        txtPlaceName.text = selectedPlaceName
        txtLatitude.text = latitude == nil ? "" : "\(latitude!)"
        txtLongitude.text = longitude == nil ? "" : "\(longitude!)"
        txtViewHeading.text = heading == nil ? "0" : "\(heading!)"
        txtViewAltitude.text = altitude == nil ? "0" : "\(altitude!)"
        
        
        txtPlaceName.delegate = self
        txtPlaceName.keyboardType = UIKeyboardType.ASCIICapable
        
        txtLatitude.delegate = self
        txtLatitude.keyboardType = UIKeyboardType.NumberPad
        txtLongitude.delegate = self
        txtLongitude.keyboardType = UIKeyboardType.NumberPad
        txtViewLatitude.delegate = self
        txtViewLatitude.keyboardType = UIKeyboardType.NumberPad
        txtViewLongitude.delegate = self
        txtViewLongitude.keyboardType = UIKeyboardType.NumberPad
        txtViewTilt.delegate = self
        txtViewTilt.keyboardType = UIKeyboardType.NumberPad
        txtViewRoll.delegate = self
        txtViewRoll.keyboardType = UIKeyboardType.NumberPad
        txtViewAltitude.delegate = self
        txtViewAltitude.keyboardType = UIKeyboardType.NumberPad
        txtViewHeading.delegate = self
        txtViewHeading.keyboardType = UIKeyboardType.NumberPad
    }
    
    // mark: - text field delegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if let nextField = view.viewWithTag(textField.tag + 1) {
            nextField.becomeFirstResponder()
        }
        
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.selectAll(nil)
    }
}


