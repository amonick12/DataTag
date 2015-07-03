//
//  BeaconDataTableViewController.swift
//  DataTag
//
//  Created by Aaron Monick on 7/3/15.
//  Copyright (c) 2015 DataTag. All rights reserved.
//

import UIKit
import Parse
import CoreLocation

class BeaconDataTableViewController: UITableViewController, CLLocationManagerDelegate {

//    var locationManager: CLLocationManager?
//    var lastProximity: CLProximity?
//    var beaconRegion: CLBeaconRegion!
    //var beacons: [CLBeacon] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
//        locationManager = CLLocationManager()
//        if(locationManager!.respondsToSelector("requestAlwaysAuthorization")) {
//            locationManager!.requestAlwaysAuthorization()
//        }
//        locationManager!.delegate = self
        //locationManager!.pausesLocationUpdatesAutomatically = false
        
//        locationManager!.startMonitoringForRegion(beaconRegion)
//        locationManager!.startRangingBeaconsInRegion(beaconRegion)
//        locationManager!.startUpdatingLocation()

        //println(beacons)
        //tableView.reloadData()
        println("majors: \(majors)")
        println("minors: \(minors)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return majors.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("beaconDataCell", forIndexPath: indexPath) as! UITableViewCell

        // Configure the cell...
        //let beacon = beacons[indexPath.row]
//        let major = String(beacon.major.intValue)
//        let minor = String(beacon.minor.intValue)
        var major = majors[indexPath.row]
        var minor = minors[indexPath.row]
        var query = PFQuery(className: "Data")
        query.whereKey("major", equalTo: major)
        query.whereKey("minor", equalTo: minor)
        query.getFirstObjectInBackgroundWithBlock { (dataObject, error) -> Void in
            if dataObject != nil {
                if let data = dataObject {
                    var dataType = data["type"] as? String
                    var name: String?
                    var type: String?
                    if dataType == "document" {
                        name = data["filename"] as? String
                        type = "Document"
                    }
                    if dataType == "image" {
                        name = data["title"] as? String
                        type = "Image"
                    }
                    if dataType == "url" {
                        name = data["title"] as? String
                        type = "Webpage"
                    }
                    cell.textLabel?.text = name
                    cell.detailTextLabel?.text = type
                }
                
            } else {
                println("error retrieving data from beacon values")
            }
        }
        

        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}

//extension BeaconDataTableViewController: CLLocationManagerDelegate {
//    
//    func locationManager(manager: CLLocationManager!,
//        didRangeBeacons beacons: [AnyObject]!,
//        inRegion region: CLBeaconRegion!) {
//            //NSLog("didRangeBeacons");
//            var message:String = ""
//            
//            self.beacons = beacons as! [CLBeacon]
//            self.tableView.reloadData()
//            
////            if let foundBeacons = beacons {
////                for beacon in foundBeacons as! [CLBeacon] {
////                    let major = String(beacon.major.intValue)
////                    let minor = String(beacon.minor.intValue)
////                    let proximity = beacon.proximity
////                    var proximityMessage: String!
////                    switch proximity {
////                    case CLProximity.Immediate:
////                        proximityMessage = "Very close"
////                        
////                    case CLProximity.Near:
////                        proximityMessage = "Near"
////                        
////                    case CLProximity.Far:
////                        proximityMessage = "Far"
////                        
////                    default:
////                        proximityMessage = "Where's the beacon?"
////                    }
////                    
////                    message += "\(major)-\(minor) is \(proximityMessage)\n"
////                }
////                println(message)
////                //sendLocalNotificationWithMessage(message)
////            }
//    }
//    
//    func locationManager(manager: CLLocationManager!, didStartMonitoringForRegion region: CLRegion!) {
//        locationManager!.requestStateForRegion(region)
//    }
//    
//    func locationManager(manager: CLLocationManager!, didDetermineState state: CLRegionState, forRegion region: CLRegion!) {
//        if state == CLRegionState.Inside {
//            locationManager!.startRangingBeaconsInRegion(beaconRegion)
//        }
//        else {
//            locationManager!.stopRangingBeaconsInRegion(beaconRegion)
//        }
//    }
//    
//    func locationManager(manager: CLLocationManager!,
//        didEnterRegion region: CLRegion!) {
//            manager.startRangingBeaconsInRegion(region as! CLBeaconRegion)
//            manager.startUpdatingLocation()
//            
//            NSLog("You entered the region")
//            //sendLocalNotificationWithMessage("You entered the region")
//            //sendLocalNotificationWithMessage("You entered a DataTag Beacon Region. Go to DataTag to see the broadcasted data.")
//    }
//    
//    func locationManager(manager: CLLocationManager!,
//        didExitRegion region: CLRegion!) {
//            manager.stopRangingBeaconsInRegion(region as! CLBeaconRegion)
//            manager.stopUpdatingLocation()
//            
//            NSLog("You exited the region")
//            //sendLocalNotificationWithMessage("You exited the DataTag Region")
//    }
//    
//    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
//        println(error)
//    }
//    
//    
//    func locationManager(manager: CLLocationManager!, monitoringDidFailForRegion region: CLRegion!, withError error: NSError!) {
//        println(error)
//    }
//    
//    func locationManager(manager: CLLocationManager!, rangingBeaconsDidFailForRegion region: CLBeaconRegion!, withError error: NSError!) {
//        println(error)
//    }
//}
