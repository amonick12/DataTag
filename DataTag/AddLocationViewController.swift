//
//  AddLocationViewController.swift
//  DataTag
//
//  Created by Aaron Monick on 7/6/15.
//  Copyright (c) 2015 DataTag. All rights reserved.
//

import UIKit
import MapKit

protocol AddLocationViewControllerDelegate {
    func locationAdded(location: CLLocationCoordinate2D, radius: Int)
}

class AddLocationViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    var delegate: AddLocationViewControllerDelegate?
    var dataObject: AnyObject?
    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    @IBOutlet weak var slider: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.Slide)
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        mapView?.addOverlay(MKCircle(centerCoordinate: mapView.centerCoordinate, radius: CLLocationDistance(slider.value)))

    }

    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        mapView.showsUserLocation = (status == CLAuthorizationStatus.AuthorizedWhenInUse || status == CLAuthorizationStatus.AuthorizedAlways)
        zoomToUserLocationInMapView()
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        var locValue : CLLocationCoordinate2D = manager.location.coordinate
        println("Long: \(locValue.longitude)\nLat: \(locValue.latitude)")
        locationManager.stopUpdatingLocation()
        zoomToUserLocationInMapView()
        getLocationName(manager.location)
        
    }
    
    func getLocationName(location: CLLocation) {
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
            //println(location)
            
            if error != nil {
                println("Reverse geocoder failed with error" + error.localizedDescription)
                return
            }
            
            if placemarks.count > 0 {
                let pm = placemarks[0] as! CLPlacemark
                let locationName = pm.locality
                println(locationName)
                //self.locationName?.text = locationName
                
            }
            else {
                println("Problem with the data received from geocoder")
            }
        })
        
    }
    
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        if overlay is MKCircle {
            var circleRenderer = MKCircleRenderer(overlay: overlay)
            circleRenderer.lineWidth = 1.0
            circleRenderer.strokeColor = UIColor.darkGrayColor()
            circleRenderer.fillColor = UIColor.greenColor().colorWithAlphaComponent(0.4)
            return circleRenderer
        }
        return nil
    }
    
    func mapView(mapView: MKMapView!, regionDidChangeAnimated animated: Bool) {
        let radius = CLLocationDistance(Int(slider.value/10)*10)
        if let overlay = mapView.overlays.first as? MKOverlay {
            mapView.removeOverlay(overlay)
        }
        mapView?.addOverlay(MKCircle(centerCoordinate: mapView.centerCoordinate, radius: radius))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sliderValueChanged(sender: AnyObject) {
        println("slider value: \(Int(slider.value/10)*10)")
        let radius = CLLocationDistance(Int(slider.value/10)*10)
        if let overlay = mapView.overlays.first as? MKOverlay {
            mapView.removeOverlay(overlay)
        }
        mapView?.addOverlay(MKCircle(centerCoordinate: mapView.centerCoordinate, radius: radius))
    }
    
    func zoomToUserLocationInMapView() {
        if let coordinate = mapView.userLocation.location?.coordinate {
            let region = MKCoordinateRegionMakeWithDistance(coordinate, 10000, 10000)
            mapView.setRegion(region, animated: true)
            //mapView?.addOverlay(MKCircle(centerCoordinate: mapView.centerCoordinate, radius: CLLocationDistance(slider.value)))
        }
    }
    
    @IBAction func confirmButtonPressed(sender: AnyObject) {
        println("confirm button pressed")
        closeButtonPressed(self)
        delegate?.locationAdded(mapView.centerCoordinate, radius: Int(slider.value))
    }
    
    @IBAction func closeButtonPressed(sender: AnyObject) {
        println("close button pressed")
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Slide)
        dismissViewControllerAnimated(true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func currentLocation(sender: AnyObject) {
        zoomToUserLocationInMapView()
    }
}
