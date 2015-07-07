//
//  MapViewController.swift
//  DataTag
//
//  Created by Aaron Monick on 7/7/15.
//  Copyright (c) 2015 DataTag. All rights reserved.
//

import UIKit
import Parse
import MapKit
import CoreLocation

protocol MapViewControllerDelegate {
    func taggedDataFromMap()
}

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    var delegate: MapViewControllerDelegate?
    let locationManager = CLLocationManager()
    @IBOutlet weak var mapView: MKMapView!
    var dataObjects: [AnyObject]?
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var navTitle: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.Slide)
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        PFGeoPoint.geoPointForCurrentLocationInBackground {
            (geoPoint: PFGeoPoint?, error: NSError?) -> Void in
            if error == nil {
                if geoPoint != nil {
                    self.getNearbyData(geoPoint!)
                    //self.zoomToUserLocationInMapView()
                }
            }
        }
    }

    func getNearbyData(userGeoPoint: PFGeoPoint) {
        var query = PFQuery(className:"Data")
        query.whereKey("geoPoint", nearGeoPoint: userGeoPoint)
        query.limit = 1000
        query.findObjectsInBackgroundWithBlock { (dataObjects, error) -> Void in
            if error == nil {
                if dataObjects != nil {
                    println("\(dataObjects!.count) data objects where found")
                    self.dataObjects = dataObjects
                    self.createAnnotations()
                }
            }
        }
        //placesObjects = query.findObjects()
    }
    
    func createAnnotations() {
        if let data = dataObjects as? [PFObject] {
            for object in data {
                let dataType = object["type"] as! String
                var title: String?
                var type: String?
                switch dataType {
                    case "document":
                        title = object["filename"] as? String
                        type = "Document"
                        break
                    case "image":
                        title = object["title"] as? String
                        type = "Image"
                        break
                    case "url":
                        title = object["title"] as? String
                        type = "Webpage"
                        break
                    default:
                        title = "Unknown"
                        type = "Unknown"
                        break
                }
                let geoPoint = object["geoPoint"] as? PFGeoPoint
                let coordinate = CLLocationCoordinate2D(latitude: geoPoint!.latitude, longitude: geoPoint!.longitude)
                let radius = object["range"] as! Int
                let dataAnnotation = DataAnnotation(coordinate: coordinate, title: title!, subtitle: type!, radius: radius, data: object)
                mapView.addAnnotation(dataAnnotation)
            }
        }
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        let identifier = "dataID"
        if annotation is DataAnnotation {
            var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as? MKPinAnnotationView
            if annotationView == nil {
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true
                var addButton = UIButton.buttonWithType(.Custom) as! UIButton
                addButton.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
                addButton.setImage(UIImage(named: "plus")!, forState: .Normal)
                annotationView?.rightCalloutAccessoryView = addButton
                
            } else {
                annotationView?.annotation = annotation
            }
            return annotationView
        }
        return nil
    }

    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
        var dataAnnotation = view.annotation as! DataAnnotation
        let title = dataAnnotation.title
        println("\(title) was selected")
        if let data = dataAnnotation.data as? PFObject {
            let dataCoordinate = dataAnnotation.coordinate
            let radius = dataAnnotation.radius
            let userCoordinate = locationManager.location
            let distance = userCoordinate.distanceFromLocation(CLLocation(latitude: dataCoordinate.latitude, longitude: dataCoordinate.longitude))
            if distance.distanceTo(Double(radius)) >= 0 {
                println("\(title) is within range")

                let usersRelation = data.relationForKey("unlockedBy")
                usersRelation.addObject(PFUser.currentUser()!)
                let taggedRelation = PFUser.currentUser()!.relationForKey("unlockedData")
                taggedRelation.addObject(data)
                PFUser.currentUser()?.saveInBackgroundWithBlock({ (succeeded: Bool, error: NSError?) -> Void in
                    if error == nil {
                        self.delegate?.taggedDataFromMap()
                        self.closeButtonPressed(self)
                    }
                })
                data.saveInBackground()

            } else {
                println("\(title) is not within range")
            }
        }
        
    }
    
    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {
        if view.annotation is DataAnnotation {
            let radius = CLLocationDistance((view.annotation as! DataAnnotation).radius)
            mapView?.addOverlay(MKCircle(centerCoordinate: view.annotation.coordinate, radius: radius))
        }
    }
    
    func mapView(mapView: MKMapView!, didDeselectAnnotationView view: MKAnnotationView!) {
        if view.annotation is DataAnnotation {
            let overlay = mapView.overlays.first as! MKOverlay
            mapView.removeOverlay(overlay)
        }
    }
    
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        if overlay is MKCircle {
            var circleRenderer = MKCircleRenderer(overlay: overlay)
            circleRenderer.lineWidth = 1.0
            circleRenderer.strokeColor = UIColor.darkGrayColor()
            circleRenderer.fillColor = UIColor.greenColor().colorWithAlphaComponent(0.3)
            return circleRenderer
        }
        return nil
    }
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        mapView.showsUserLocation = (status == CLAuthorizationStatus.AuthorizedWhenInUse || status == CLAuthorizationStatus.AuthorizedAlways)
        zoomToUserLocationInMapView()
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        var locValue : CLLocationCoordinate2D = manager.location.coordinate
        println("Long: \(locValue.longitude)\nLat: \(locValue.latitude)")
        let region = MKCoordinateRegionMakeWithDistance(manager.location.coordinate, 10000, 10000)
        mapView.setRegion(region, animated: true)
        getLocationName(manager.location)
        locationManager.stopUpdatingLocation()
    }
    
    func getLocationName(location: CLLocation) {
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
            println(location)
            
            if error != nil {
                println("Reverse geocoder failed with error" + error.localizedDescription)
                return
            }
            
            if placemarks.count > 0 {
                let pm = placemarks[0] as! CLPlacemark
                let locality = pm.locality
                let address = pm.addressDictionary
                println(address)
                println(locality)
                let street = address["Street"] as! String
                let state = address["State"] as! String
                self.navTitle.title = "\(street), \(state)"
                //self.locationName?.text = locationName
                
            }
            else {
                println("Problem with the data received from geocoder")
            }
        })
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func zoomToUserLocationInMapView() {
        if let coordinate = mapView.userLocation.location?.coordinate {
            let region = MKCoordinateRegionMakeWithDistance(coordinate, 10000, 10000)
            mapView.setRegion(region, animated: true)
            //mapView?.addOverlay(MKCircle(centerCoordinate: mapView.centerCoordinate, radius: CLLocationDistance(slider.value)))
        }
    }
    
    @IBAction func update(sender: AnyObject) {
        navTitle.title = "Updating..."
        locationManager.startUpdatingLocation()
        PFGeoPoint.geoPointForCurrentLocationInBackground {
            (geoPoint: PFGeoPoint?, error: NSError?) -> Void in
            if error == nil {
                if geoPoint != nil {
                    self.getNearbyData(geoPoint!)
                }
            }
        }
    }

    @IBAction func closeButtonPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: { () -> Void in
            UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Slide)

        })
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
