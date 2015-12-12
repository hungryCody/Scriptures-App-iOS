//
//  ScriptureViewController.swift
//  Project 4 - Map Scriptures
//
//  Created by Michael Perry on 11/27/15.
//  Copyright © 2015 Michael Perry. All rights reserved.
//

import UIKit
import MapKit

class ScripturesViewController: UIViewController, UIWebViewDelegate, SuggestionDisplayDelegate {
    
    // mark: - properties
    
    var book: Book!
    var chapter = 0
    var geoplace: GeoPlace?
    
    var shouldReloadMap = true
    
    weak var mapViewController: MapViewController?
    
    lazy var backgroundQueue = dispatch_queue_create("background thread", nil)
    
    var selectedTextPlaceName: String?
    var selectedTextOffset: String?
    
    var canAddCustomPin = false {
        didSet {
            mapViewController?.canAddCustomPin = self.canAddCustomPin
        }
    }
    
    var firstAnnotationDropped = false {
        didSet {
            mapViewController?.firstAnnotationDropped = self.firstAnnotationDropped
        }
    }
    
    // mark: - outlets
    
    @IBOutlet weak var webView: CustomWebView!
    
    // mark: - suggestion display delegate
    func displaySuggestionDialog() {
        performSegueWithIdentifier("showSuggestionDialogue", sender: self)
    }
    
    // mark: - actions

    @IBAction func addFromMap(segue: UIStoryboardSegue){
        resetUserInteractionBool()
        
        canAddCustomPin = true
    }
    
    @IBAction func cancelSuggestion(segue: UIStoryboardSegue){
        resetUserInteractionBool()
        if mapViewController!.mapView.annotations.count != 0 && mapViewController!.lastAddedAnnotation != nil {
            mapViewController!.mapView.removeAnnotation(mapViewController!.lastAddedAnnotation!)
        }
        firstAnnotationDropped = false
    }
    
    @IBAction func saveSuggestion(segue: UIStoryboardSegue){
        resetUserInteractionBool()
        firstAnnotationDropped = false
        if mapViewController!.mapView.annotations.count != 0 && mapViewController!.lastAddedAnnotation != nil {
            mapViewController!.mapView.removeAnnotation(mapViewController!.lastAddedAnnotation!)
        }
//        let selectedTextInfo = getSelectedTextInfo()
        
        let placename = selectedTextPlaceName! //"Salt+Lake+City"
        let offset = selectedTextOffset!
        var bookId = 0
        var currentChapter = 0
        var latitude: Double? //= 23.5438
        var longitude: Double? // = 32.234234
        var viewLatitude = 0.0
        var viewLongitude = 0.0
        var viewTilt = 0.0
        var viewRoll = 0.0
        var viewAltitude = 0.0
        var viewHeading = 0.0
        
        if let sourceVC = segue.sourceViewController as? FormTableViewController {
            
            bookId = book.id
            currentChapter = chapter
            if let lat = Double(sourceVC.txtLatitude.text!) {
                latitude = lat
            } else {
                latitude = nil
            }
            if let lon = Double(sourceVC.txtLatitude.text!) {
                longitude = lon
            } else {
                longitude = nil
            }
            viewLatitude = Double(sourceVC.txtViewLatitude.text!)!
            viewLongitude = Double(sourceVC.txtViewLongitude.text!)!
            viewTilt = Double(sourceVC.txtViewTilt.text!)!
            viewRoll = Double(sourceVC.txtViewRoll.text!)!
            viewAltitude = Double(sourceVC.txtViewAltitude.text!)!
            viewHeading = Double(sourceVC.txtViewHeading.text!)!
            
            dispatch_async(backgroundQueue) {
                let sessionConfig = NSURLSessionConfiguration.ephemeralSessionConfiguration()
                
                sessionConfig.allowsCellularAccess = true
                sessionConfig.timeoutIntervalForRequest = 15.0
                sessionConfig.timeoutIntervalForResource = 15.0
                sessionConfig.HTTPMaximumConnectionsPerHost = 2
                
                let session = NSURLSession(configuration: sessionConfig)
                var request: NSURLRequest
                //There is an if else here so that the user will be required to enter in a setting for longitude and latitude
                //If the user doens't enter these in it passes the wrong value into the parameter and stops it from getting into the server
                if latitude == nil || longitude == nil {
                    request = NSURLRequest(URL: NSURL(string: "http://scriptures.byu.edu/mapscrip/suggestpm.php?placename=\(placename)&offset=\(offset)&bookId=\(bookId)&chapter=\(currentChapter)&latitude=\("")&longitude=\("")&viewLatitude=\(viewLatitude)&viewLongitude=\(viewLongitude)&viewTilt=\(viewTilt)&viewRoll=\(viewRoll)&viewAltitude=\(viewAltitude)&viewHeading=\(viewHeading)")!)
                } else {
                    request = NSURLRequest(URL: NSURL(string: "http://scriptures.byu.edu/mapscrip/suggestpm.php?placename=\(placename)&offset=\(offset)&bookId=\(bookId)&chapter=\(currentChapter)&latitude=\(latitude)&longitude=\(longitude)&viewLatitude=\(viewLatitude)&viewLongitude=\(viewLongitude)&viewTilt=\(viewTilt)&viewRoll=\(viewRoll)&viewAltitude=\(viewAltitude)&viewHeading=\(viewHeading)")!)
                }
                
                let task = session.dataTaskWithRequest(request) {
                    (data: NSData?, response: NSURLResponse?, error: NSError?) in
                    var succeeded = false
                    
                    if error == nil {
                        if let resultRecord = try? NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) {
                            if let resultDict = resultRecord as? NSDictionary {
                                if let resultCode = resultDict["result"] as? Int {
                                    if resultCode == 0 {
                                        succeeded = true
                                    } else {
                                        print("request failed: \(resultDict["message"]!)")
                                    }
                                }
                            }
                        }
                    }
                    if !succeeded {
                        let alertController = UIAlertController(title: "Error", message: "Sorry: unable to send suggestion. Check network and make sure longitude and latitude are provided and try again", preferredStyle: .Alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                        
                        self.presentViewController(alertController, animated: true, completion: nil)
                    } else if succeeded {
                        print("POST successful")
                        let alertController = UIAlertController(title: "Congratulations!", message: "You have posted a suggestion on our servers!", preferredStyle: .Alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                        
                        self.presentViewController(alertController, animated: true, completion: nil)
                    }
                }
                task.resume()
            }
        }
    }
    
    // mark: - view controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureDetailViewController()
        
        let html = ScriptureRenderer.sharedRenderer.htmlForBookId(book.id, chapter: chapter)
        
        webView.loadHTMLString(html, baseURL: nil)
        
        webView.suggestionDelegate = self
    }
    

    
    //When the view disappears tell the view not to reload the map. This is so that it doesn't keep reloading it every time the view changes the layout
    override func viewWillDisappear(animated: Bool) {
        shouldReloadMap = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        configureDetailViewController()
        
        if mapViewController != nil && shouldReloadMap {
            loadMap()
        }
    }
    
    // mark: - web view delegate
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if let path = request.URL?.absoluteString {
            if path.hasPrefix("http://scriptures.byu.edu/mapscrip/") {
                let index = path.startIndex.advancedBy("http://scriptures.byu.edu/mapscrip/".lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
                let geoplaceId = path.substringFromIndex(index)
                
                self.geoplace = GeoDatabase.sharedGeoDatabase.geoPlaceForId(Int(geoplaceId)!)
                removeAnnotations()
                if mapViewController == nil {
                    performSegueWithIdentifier("showMap", sender: self)
                } else {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1.5 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
                        
                        let annotation = MKPointAnnotation()
                        
                        annotation.coordinate = CLLocationCoordinate2DMake((self.geoplace?.latitude)!, (self.geoplace?.longitude)!)
                        annotation.title = self.geoplace?.placename
                        annotation.subtitle = self.geoplace?.category.rawValue == 1 ? "Church History" : "Open Bible"
                        
                        self.mapViewController!.mapView.addAnnotation(annotation)
                        self.mapViewController!.mapView.selectAnnotation(annotation, animated: true)
                    })
                    
                    let camera = MKMapCamera(lookingAtCenterCoordinate: CLLocationCoordinate2DMake((geoplace?.latitude)!, (geoplace?.longitude)!), fromEyeCoordinate: CLLocationCoordinate2DMake((geoplace?.latitude)!, (geoplace?.longitude)!), eyeAltitude: (geoplace?.viewAltitude)!)
                    
                    mapViewController!.mapView.setCamera(camera, animated: true)
                    mapViewController!.title = geoplace!.placename
                    setShowUserToFalse()
                }
                return false
            }
        }
        return true
    }
    
    // mark: - segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showMap" {
            if let navVC = segue.destinationViewController as? UINavigationController {
                if let mapVC = navVC.topViewController as? MapViewController {
                    mapVC.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem()
                    mapVC.navigationItem.leftItemsSupplementBackButton = true
                    
                    mapVC.geoPlace = geoplace
                    mapVC.title = geoplace?.placename
                    setShowUserToFalse()
                }
            }
        }
        
        if segue.identifier == "showSuggestionDialogue" {
            getSelectedTextInfo()
            
            if let navVC = segue.destinationViewController as? UINavigationController {
                if let formVC = navVC.topViewController as? FormTableViewController {
                    formVC.selectedPlaceName = selectedTextPlaceName!
                }
            }
        }
    }
    
    // mark: helper methods
    
    func getSelectedTextInfo() {
        selectedTextPlaceName = webView.stringByEvaluatingJavaScriptFromString("document.getSelection().toString()")
        selectedTextOffset = webView.stringByEvaluatingJavaScriptFromString("getSelectionOffset()")
    }
    
    func resetUserInteractionBool () {
        webView.userInteractionEnabled = false
        webView.userInteractionEnabled = true
    }
    
    func configureDetailViewController() {
        if let splitVC = splitViewController {
            mapViewController = (splitVC.viewControllers.last as! UINavigationController).topViewController as? MapViewController
        } else {
            mapViewController = nil
        }
    }
    
    //sets user to false pretty much whenever ScriptureViewController calls MapViewController
    func setShowUserToFalse() {
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: "showUser")
        NSUserDefaults.standardUserDefaults().synchronize()
        if let mapViewCon = mapViewController {
            mapViewCon.mapView.showsUserLocation = NSUserDefaults.standardUserDefaults().boolForKey("showUser")
        }
    }
    
    func zoomToFitMapAnnotations(mapView: MKMapView) {
        if mapView.annotations.count == 0 {
            return
        }
        var topLeftCoord: CLLocationCoordinate2D = CLLocationCoordinate2D()
        topLeftCoord.latitude = -90
        topLeftCoord.longitude = 180
        var bottomRightCoord: CLLocationCoordinate2D = CLLocationCoordinate2D()
        bottomRightCoord.latitude = 90
        bottomRightCoord.longitude = -180
        for annotation: MKAnnotation in mapView.annotations {
            topLeftCoord.longitude = fmin(topLeftCoord.longitude, annotation.coordinate.longitude)
            topLeftCoord.latitude = fmax(topLeftCoord.latitude, annotation.coordinate.latitude)
            bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, annotation.coordinate.longitude)
            bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, annotation.coordinate.latitude)
        }

        var region: MKCoordinateRegion = MKCoordinateRegion()
        region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5
        region.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5
        region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.4
        region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.4
        region = mapView.regionThatFits(region)
        mapView.setRegion(region, animated: true)
    }
    
    func removeAnnotations() {
        if let mapView = mapViewController?.mapView {
            let annotationsToRemove = mapView.annotations
            mapView.removeAnnotations( annotationsToRemove )
        }
    }
    
    func loadMap() {
        firstAnnotationDropped = false
        canAddCustomPin = false
        
        let geoPlaces: [GeoPlace]? = ScriptureRenderer.sharedRenderer.collectedGeocodedPlaces
        
        if let geoplaces = geoPlaces {
            if geoplaces.count > 0 {
                setShowUserToFalse()
                removeAnnotations()
                
                var geoplacesLoaded: [Double] = []
                //i keeps track of all the locations. When i equals the count of the geoplaces then it loads the annotations to the map
                var i = 0
                for geoplc in geoplaces {
                    i++
                    //make sure the annotation hasn't already been added to the map
                    if !geoplacesLoaded.contains(geoplc.latitude/geoplc.longitude) {
                        
                        geoplacesLoaded.append(geoplc.latitude/geoplc.longitude)
                        
                        let annotation = MKPointAnnotation()
                        
                        annotation.coordinate = CLLocationCoordinate2DMake(geoplc.latitude, geoplc.longitude)
                        annotation.title = geoplc.placename
                        annotation.subtitle = geoplc.category.rawValue == 1 ? "Church History" : "Open Bible"
                        self.mapViewController!.mapView.addAnnotation(annotation)
                    }
                    //when all of the geoplaces have been looked through then load annotations
                    if i == geoplaces.count {
                        if geoplacesLoaded.count > 1 {
                            self.zoomToFitMapAnnotations(self.mapViewController!.mapView)
                            self.mapViewController?.title = geoPlaces![0].category.rawValue == 1 ? "Church History" : "Open Bible"
                        } else {
                            let camera = MKMapCamera(lookingAtCenterCoordinate: CLLocationCoordinate2DMake(geoplc.latitude, geoplc.longitude), fromEyeCoordinate: CLLocationCoordinate2DMake(geoplc.latitude, geoplc.longitude), eyeAltitude: geoplc.viewAltitude!)
                            self.mapViewController!.mapView.setCamera(camera, animated: true)
                            self.mapViewController?.title = geoPlaces![0].placename
                        }
                    }
                }
            }
        }
        shouldReloadMap = false
    }
}
