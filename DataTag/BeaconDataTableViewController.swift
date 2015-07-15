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

protocol BeaconDataTableViewControllerDelegate {
    func nearbyDataAdded()
}

class BeaconDataTableViewController: UITableViewController, CLLocationManagerDelegate, NearbyTableViewCellDelegate {

//    var locationManager: CLLocationManager?
//    var lastProximity: CLProximity?
//    var beaconRegion: CLBeaconRegion!
    //var beacons: [CLBeacon] = []

    var delegate: BeaconDataTableViewControllerDelegate?
    var dataObjects: [AnyObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
//        println("\(Beacon)")
//        println("minors: \(minors)")
        println("\(beaconData.count) beacons found")
        getDataFromBeacons()
    }

    func getDataFromBeacons() {
        dataObjects.removeAll(keepCapacity: false)
        for beacon in beaconData {
            let uuid = beacon.UUID
            let major = beacon.major
            let minor = beacon.minor
            var query = PFQuery(className: "Data")
            query.whereKey("major", equalTo: major)
            query.whereKey("minor", equalTo: minor)
            query.whereKey("proximityUUID", equalTo: uuid)
            query.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                if error == nil {
                    println("Found \(objects?.count) objects for \(uuid): \(major)-\(minor)")
                    let objects = objects as! [PFObject]
                    for object in objects {
                        self.dataObjects.append(object)
                        self.tableView.reloadData()
                    }
                } else {
                    println("Error querying object from beacon")
                }
            })
        }
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
        println("Found \(dataObjects.count) objects from beacons")
        return dataObjects.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("nearbyCell", forIndexPath: indexPath) as! NearbyTableViewCell
        
        let data = dataObjects[indexPath.row] as! PFObject
        var dataType = data["type"] as! String
        var file = data["fileData"] as! PFFile
        var mimeType = data["mimeType"] as? String
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

        cell.data = data
        cell.titleLabel.text = name
        cell.typeLabel.text = type
        cell.delegate = self
        cell.indexPath = indexPath
        cell.progressView.progress = 0.0
        file.getDataInBackgroundWithBlock ({
            (data: NSData?, error: NSError?) -> Void in
            cell.progressView.hidden = true
            if error == nil {
                switch dataType {
                case "document":
                    var webView = UIWebView()
                    cell.previewView.addSubview(webView)
                    webView.frame = cell.previewView.bounds
                    //webView.setTranslatesAutoresizingMaskIntoConstraints(false)
                    webView.loadData(data!, MIMEType: mimeType, textEncodingName: "UTF-8", baseURL: nil)
                    webView.backgroundColor = UIColor.clearColor()
                    cell.previewView.backgroundColor = UIColor.clearColor()
                    break
                case "image":
                    var imageView = UIImageView()
                    cell.previewView.addSubview(imageView)
                    imageView.frame = cell.previewView.bounds
                    //imageView.setTranslatesAutoresizingMaskIntoConstraints(false)
                    imageView.image = UIImage(data: data!)
                    imageView.backgroundColor = UIColor.clearColor()
                    imageView.contentMode = UIViewContentMode.ScaleAspectFit
                    cell.previewView.backgroundColor = UIColor.clearColor()
                    break
                case "url":
                    var imageView = UIImageView()
                    cell.previewView.addSubview(imageView)
                    imageView.frame = cell.previewView.bounds
                    //imageView.setTranslatesAutoresizingMaskIntoConstraints(false)
                    imageView.image = UIImage(data: data!)
                    imageView.backgroundColor = UIColor.clearColor()
                    imageView.contentMode = UIViewContentMode.ScaleAspectFill
                    cell.previewView.backgroundColor = UIColor.clearColor()
                    break
                default:
                    break
                    
                }
            } else { println("Error loading document data") }
            }, progressBlock: {
                (percentDone: Int32) -> Void in
                cell.progressView.progress = Float(percentDone)/100
        })
        
        return cell
    }

//    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        //let cell = tableView.dequeueReusableCellWithIdentifier("beaconDataCell", forIndexPath: indexPath) as! UITableViewCell
//        let cell = tableView.dequeueReusableCellWithIdentifier("nearbyCell", forIndexPath: indexPath) as! NearbyTableViewCell
//        
////        var major = majors[indexPath.row]
////        var minor = minors[indexPath.row]
////        var uuid = uuids[indexPath.row]
//        
//        let uuid = beaconData[indexPath.row].UUID
//        let major = beaconData[indexPath.row].major
//        let minor = beaconData[indexPath.row].minor
//        
//        var query = PFQuery(className: "Data")
//        query.whereKey("major", equalTo: major)
//        query.whereKey("minor", equalTo: minor)
//        query.whereKey("proximityUUID", equalTo: uuid)
//        query.getFirstObjectInBackgroundWithBlock { (dataObject, error) -> Void in
//            if dataObject != nil {
//                if let data = dataObject {
//                    var dataType = data["type"] as! String
//                    var file = data["fileData"] as! PFFile
//                    var mimeType = data["mimeType"] as? String
//                    var name: String?
//                    var type: String?
//                    if dataType == "document" {
//                        name = data["filename"] as? String
//                        type = "Document"
//                    }
//                    if dataType == "image" {
//                        name = data["title"] as? String
//                        type = "Image"
//                    }
//                    if dataType == "url" {
//                        name = data["title"] as? String
//                        type = "Webpage"
//                    }
////                    cell.textLabel?.text = name
////                    cell.detailTextLabel?.text = type
//                    cell.data = dataObject
//                    cell.titleLabel.text = name
//                    cell.typeLabel.text = type
//                    cell.delegate = self
//                    cell.indexPath = indexPath
//                    cell.progressView.progress = 0.0
//                    file.getDataInBackgroundWithBlock ({
//                        (data: NSData?, error: NSError?) -> Void in
//                        cell.progressView.hidden = true
//                        if error == nil {
////                            cell.webview.loadData(data, MIMEType: mimeType, textEncodingName: "UTF-8", baseURL: nil)
////                            cell.webview.backgroundColor = UIColor.clearColor()
////                            cell.titleButton.setTitle(filename, forState: .Normal)
////                            cell.delegate = self
////                            cell.indexPath = indexPath
//                            switch dataType {
//                            case "document":
//                                var webView = UIWebView()
//                                cell.previewView.addSubview(webView)
//                                webView.frame = cell.previewView.bounds
//                                //webView.setTranslatesAutoresizingMaskIntoConstraints(false)
//                                webView.loadData(data!, MIMEType: mimeType, textEncodingName: "UTF-8", baseURL: nil)
//                                webView.backgroundColor = UIColor.clearColor()
//                                cell.previewView.backgroundColor = UIColor.clearColor()
//                                break
//                            case "image":
//                                var imageView = UIImageView()
//                                cell.previewView.addSubview(imageView)
//                                imageView.frame = cell.previewView.bounds
//                                //imageView.setTranslatesAutoresizingMaskIntoConstraints(false)
//                                imageView.image = UIImage(data: data!)
//                                imageView.backgroundColor = UIColor.clearColor()
//                                imageView.contentMode = UIViewContentMode.ScaleAspectFit
//                                cell.previewView.backgroundColor = UIColor.clearColor()
//                                break
//                            case "url":
//                                var imageView = UIImageView()
//                                cell.previewView.addSubview(imageView)
//                                imageView.frame = cell.previewView.bounds
//                                //imageView.setTranslatesAutoresizingMaskIntoConstraints(false)
//                                imageView.image = UIImage(data: data!)
//                                imageView.backgroundColor = UIColor.clearColor()
//                                imageView.contentMode = UIViewContentMode.ScaleAspectFill
//                                cell.previewView.backgroundColor = UIColor.clearColor()
//                                break
//                            default:
//                                break
//                                
//                            }
//                        } else { println("Error loading document data") }
//                        }, progressBlock: {
//                            (percentDone: Int32) -> Void in
//                            cell.progressView.progress = Float(percentDone)/100
//                    })
//
//                }
//                
//            } else {
//                println("error retrieving data from beacon values")
//            }
//        }
//        
//
//        return cell
//    }
    
    func addDataButtonPressed(indexPath: NSIndexPath) {
        println("\(indexPath) was added")
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! NearbyTableViewCell
        let data = cell.data as! PFObject
        let usersRelation = data.relationForKey("unlockedBy")
        usersRelation.addObject(PFUser.currentUser()!)
        let taggedRelation = PFUser.currentUser()!.relationForKey("unlockedData")
        taggedRelation.addObject(data)
        PFUser.currentUser()?.saveInBackgroundWithBlock({ (succeeded: Bool, error: NSError?) -> Void in
            if error == nil {
                self.delegate?.nearbyDataAdded()
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        })
        data.saveInBackground()
    }

    @IBAction func cancelButtonPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func updateTable(sender: AnyObject) {
        //tableView.reloadData()
        getDataFromBeacons()
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
