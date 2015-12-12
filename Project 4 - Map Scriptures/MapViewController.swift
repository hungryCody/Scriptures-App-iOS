//
//  MapViewController.swift
//  Project 4 - Map Scriptures
//
//  Created by Michael Perry on 11/27/15.
//  Copyright © 2015 Michael Perry. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate {

    // mark: - outlets
    
    @IBOutlet weak var mapView: MKMapView!
    
    // mark: - variables
    
    let locationManager = CLLocationManager()

    weak var scripturesViewController: ScripturesViewController?
    
    var geoPlace: GeoPlace?
    
    var canAddCustomPin = false
    var firstAnnotationDropped = false
    
    var lastAddedAnnotation: MKPointAnnotation?
    
    var pinLat: Double?
    var pinLong: Double?
    
    // mark: - view controller lifecycle
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        addSingleTap()
        let showUser = NSUserDefaults.standardUserDefaults().boolForKey("showUser")
        
        //turn users location on
        self.mapView.showsUserLocation = showUser
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() && showUser
        {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            
            //if the user has a location and has approved the app to have its location tracked then it will set the user's location pin
            if let locValue: CLLocationCoordinate2D = locationManager.location?.coordinate {
                let center = CLLocationCoordinate2D(latitude: locValue.latitude, longitude: locValue.longitude)
                let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
                
                self.title = "This is where you are"
                self.mapView.setRegion(region, animated: true)
            }
        }
    
        //this checks if the geoplace is being passed to it from ScriptureViewController and loads the annotation for that geoplace
        if let geoplace = geoPlace {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
                
                let annotation = MKPointAnnotation()
                
                annotation.coordinate = CLLocationCoordinate2DMake(geoplace.latitude, geoplace.longitude)
                annotation.title = geoplace.placename
                annotation.subtitle = geoplace.category.rawValue == 1 ? "Church History" : "Open Bible"
                
                self.mapView.addAnnotation(annotation)
                self.mapView.selectAnnotation(annotation, animated: true)
            })
            
            let camera = MKMapCamera(lookingAtCenterCoordinate: CLLocationCoordinate2DMake(geoplace.latitude, geoplace.longitude), fromEyeCoordinate: CLLocationCoordinate2DMake(geoplace.latitude, geoplace.longitude), eyeAltitude: geoplace.viewAltitude!)
            
            mapView.setCamera(camera, animated: true)
        }
        
        //if there is a splitview when ScripturesViewController is called then it will call load map which will add all of the pins for view being passed
        if let splitVC = splitViewController {
            if let scripturesViewController = (splitVC.viewControllers.first as! UINavigationController).topViewController as? ScripturesViewController {
                scripturesViewController.loadMap()
            }
        }
    }

    // mark: map functions
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {

        if let locValue: CLLocationCoordinate2D = locationManager.location?.coordinate {
            let center = CLLocationCoordinate2D(latitude: locValue.latitude, longitude: locValue.longitude)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
            
            self.title = "This is where you are"
            self.mapView.setRegion(region, animated: true)
        }
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        var view = mapView.dequeueReusableAnnotationViewWithIdentifier("Pin")
        
        if !NSUserDefaults.standardUserDefaults().boolForKey("showUser") {
            
            if view == nil {
                let pinView = MKPinAnnotationView()
                
                pinView.animatesDrop = true
                pinView.canShowCallout = true
                pinView.pinTintColor = UIColor.blueColor()
                
                view = pinView
            } else {
                view?.annotation = annotation
            }
        }
        
        //checks if the pin being dropped is a pin the user created by touching the map. If so it adds an add button
        if canAddCustomPin {
            let button = UIButton(type: UIButtonType.System) as UIButton
            button.frame = CGRectMake(50, 50, 50, 50)
            button.backgroundColor = UIColor.lightGrayColor()
            button.setTitle("Add", forState: UIControlState.Normal)
            
            button.addTarget(self, action: "btnAnnotation_Clicked:", forControlEvents: .TouchUpInside)
            view?.rightCalloutAccessoryView = button
        }
        
        return view
    }
    
    //this function fires in response to the add button on the annotation being pressed
    func btnAnnotation_Clicked (sender: AnyObject) {
        performSegueWithIdentifier("showSuggestionDialogue", sender: self)
    }
    
    func addSingleTap () {
        // This sets up the tap gesture recognizer to un-hide the bars from the UI.
        let singleTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "didTapMap:")
        singleTap.delegate = self
        singleTap.numberOfTapsRequired = 1
        singleTap.numberOfTouchesRequired = 1
        mapView.addGestureRecognizer(singleTap)
    }
    
    func didTapMap(gestureRecognizer: UIGestureRecognizer) {
        if canAddCustomPin {
            setShowUserToFalse()
            if mapView.annotations.count != 0 && firstAnnotationDropped && lastAddedAnnotation != nil {
                mapView.removeAnnotation(lastAddedAnnotation!)
            }
            // Get the spot that was tapped.
            let tapPoint: CGPoint = gestureRecognizer.locationInView(mapView)
            let touchMapCoordinate: CLLocationCoordinate2D = mapView.convertPoint(tapPoint, toCoordinateFromView: mapView)
            
            let lat = touchMapCoordinate.latitude
            let roundedLat = round(lat * 100.0) / 100.0
            pinLat = lat
            
            let long = touchMapCoordinate.longitude
            let roundedLong = round(long * 100.0) / 100.0
            pinLong = long
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = touchMapCoordinate
            annotation.title = "Lat: \(roundedLat), Long: \(roundedLong)"
            
            lastAddedAnnotation = annotation
            
            mapView.addAnnotation(annotation)
            
            firstAnnotationDropped = true
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
                
                self.mapView.selectAnnotation(self.lastAddedAnnotation!, animated: true)
            })
        }
    }
    
    // mark: - segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showSuggestionDialogue" {
            
            //grab the current masterview and formview and use from both to fill out the form
            if let splitVC = splitViewController {
                if let scripturesViewController = (splitVC.viewControllers.first as! UINavigationController).topViewController as? ScripturesViewController {
                    if let navVC = segue.destinationViewController as? UINavigationController {
                        if let formVC = navVC.topViewController as? FormTableViewController {
                            formVC.selectedPlaceName = scripturesViewController.selectedTextPlaceName
                            formVC.latitude = pinLat!
                            formVC.longitude = pinLong!
                            formVC.heading = mapView.camera.heading
                            formVC.altitude = mapView.camera.altitude
                            
                            canAddCustomPin = false
                        }
                    }
                }
            }
        }
    }
    
    // mark: - helper
    
    //sets user to false pretty much whenever ScriptureViewController calls MapViewController
    func setShowUserToFalse() {
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: "showUser")
        NSUserDefaults.standardUserDefaults().synchronize()
        
        mapView.showsUserLocation = NSUserDefaults.standardUserDefaults().boolForKey("showUser")
    }

}

