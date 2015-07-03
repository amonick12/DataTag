//
//  AppDelegate.swift
//  MysteryData
//
//  Created by Aaron Monick on 6/15/15.
//  Copyright (c) 2015 CourseBuddy. All rights reserved.
//

import UIKit
import Parse
import Bolts
import CoreLocation

var majors: [String] = []
var minors: [String] = []

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?
    var locationManager: CLLocationManager?
    var lastProximity: CLProximity?
    var beaconRegion: CLBeaconRegion!
    
    var lastMajor: String?
    var lastMinor: String?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        // https://parse.com/docs/ios_guide#localdatastore/iOS
        Parse.enableLocalDatastore()
        
        // Initialize Parse.
        Parse.setApplicationId("NgkxSeW3qvnz49bOLAxGVrEpbeQP6U8alEYRfZ1x",
            clientKey: "CnnXzg2APKWpFvK9b0NEsJf1K2pBVgazG5xFYgqE")
        
        // [Optional] Track statistics around application opens.
        PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
        
        if PFUser.currentUser() == nil {
            PFAnonymousUtils.logInWithBlock {
                (user: PFUser?, error: NSError?) -> Void in
                if error != nil || user == nil {
                    println("Anonymous login failed.")
                } else {
                    println("Anonymous user logged in.")
                    user!.incrementKey("RunCount")
                    user!.saveInBackground()
                }
            }
        } else {
            PFUser.currentUser()?.incrementKey("RunCount")
            PFUser.currentUser()?.saveInBackground()
        }
        
        
        let appKey = "cqs8bc801ha7lc0"
        let appSecret = "8ic9ew13gps6pvg"
        
        let dropboxSession = DBSession(appKey: appKey, appSecret: appSecret, root: kDBRootAppFolder)
        DBSession.setSharedSession(dropboxSession)
        
        application.setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)

        let uuidString = "DDE7137E-EE5F-4A48-A083-2E48F024F73A"
        let beaconIdentifier = "datatag.com"
        let beaconUUID: NSUUID = NSUUID(UUIDString: uuidString)!
        beaconRegion = CLBeaconRegion(proximityUUID: beaconUUID,
            identifier: beaconIdentifier)
        beaconRegion.notifyOnEntry = true
        beaconRegion.notifyOnExit = true
        
        locationManager = CLLocationManager()
        if(locationManager!.respondsToSelector("requestAlwaysAuthorization")) {
            locationManager!.requestAlwaysAuthorization()
        }
        locationManager!.delegate = self
        //locationManager!.pausesLocationUpdatesAutomatically = false
        
        locationManager!.startMonitoringForRegion(beaconRegion)
        locationManager!.startRangingBeaconsInRegion(beaconRegion)
        locationManager!.startUpdatingLocation()
        
        if(application.respondsToSelector("registerUserNotificationSettings:")) {
            application.registerUserNotificationSettings(
                UIUserNotificationSettings(
                    forTypes: UIUserNotificationType.Alert | UIUserNotificationType.Sound,
                    categories: nil
                )
            )
        }
        
        return true
    }

    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        
        if DBSession.sharedSession().handleOpenURL(url) {
            if DBSession.sharedSession().isLinked() {
                NSNotificationCenter.defaultCenter().postNotificationName("didLinkToDropboxAccountNotification", object: nil)
                return true
            }
        }
        
        return false
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

extension AppDelegate: CLLocationManagerDelegate {
    
    func sendLocalNotificationWithMessage(message: String!) {
        let notification:UILocalNotification = UILocalNotification()
        notification.alertBody = message
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
    
    func locationManager(manager: CLLocationManager!,
        didRangeBeacons beacons: [AnyObject]!,
        inRegion region: CLBeaconRegion!) {
            NSLog("didRangeBeacons");
            var message:String = ""
            
            //beacons = beacons
            //let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            //let vc = storyboard.instantiateViewControllerWithIdentifier("BeaconNav") as! BeaconDataNavViewController
            //let root = vc.visibleViewController as! BeaconDataTableViewController
            //let vc = storyboard.instantiateViewControllerWithIdentifier("BeaconData") as! BeaconDataTableViewController
            //vc.beacons = beacons as! [CLBeacon]
            
            //root.tableView.reloadData()
            
            if let foundBeacons = beacons {
                for beacon in foundBeacons as! [CLBeacon] {
                    let major = String(beacon.major.intValue)
                    let minor = String(beacon.minor.intValue)
                    
                    if major != lastMajor && minor != lastMinor {
                        majors.append(major)
                        minors.append(minor)
                        lastMajor = major
                        lastMinor = minor
                    }
                    
                    
                    let proximity = beacon.proximity
                    var proximityMessage: String!
                    switch proximity {
                    case CLProximity.Immediate:
                        proximityMessage = "Very close"
                        
                    case CLProximity.Near:
                        proximityMessage = "Near"
                        
                    case CLProximity.Far:
                        proximityMessage = "Far"
                        
                    default:
                        proximityMessage = "Where's the beacon?"
                    }

                    message += "\(major)-\(minor) is \(proximityMessage)\n"
                }
                println(message)
                //sendLocalNotificationWithMessage(message)
            }
//            if(beacons.count > 0) {
//                let nearestBeacon:CLBeacon = beacons[0] as! CLBeacon
//                
//                var major = nearestBeacon.major.intValue
//                var minor = nearestBeacon.minor.intValue
//                
//                println("major: \(major)")
//                println("minor: \(minor)")
//                
//                if(nearestBeacon.proximity == lastProximity ||
//                    nearestBeacon.proximity == CLProximity.Unknown) {
//                        return;
//                }
//                lastProximity = nearestBeacon.proximity;
//
//                switch nearestBeacon.proximity {
//                case CLProximity.Far:
//                    message = "You are far away from the beacon"
//                case CLProximity.Near:
//                    message = "You are near the beacon"
//                case CLProximity.Immediate:
//                    message = "You are in the immediate proximity of the beacon"
//                case CLProximity.Unknown:
//                    return
//                }
//            } else {
//                message = "No beacons are nearby"
//            }
//            
//            NSLog("%@", message)
//            
//            sendLocalNotificationWithMessage(message)
    }
    
    func locationManager(manager: CLLocationManager!, didStartMonitoringForRegion region: CLRegion!) {
        locationManager!.requestStateForRegion(region)
    }
    
    func locationManager(manager: CLLocationManager!, didDetermineState state: CLRegionState, forRegion region: CLRegion!) {
        if state == CLRegionState.Inside {
            locationManager!.startRangingBeaconsInRegion(beaconRegion)
        }
        else {
            locationManager!.stopRangingBeaconsInRegion(beaconRegion)
        }
    }
    
    func locationManager(manager: CLLocationManager!,
        didEnterRegion region: CLRegion!) {
            manager.startRangingBeaconsInRegion(region as! CLBeaconRegion)
            manager.startUpdatingLocation()
            
            NSLog("You entered the region")
            //sendLocalNotificationWithMessage("You entered the region")
            sendLocalNotificationWithMessage("You entered a DataTag Beacon Region. Go to DataTag to see the broadcasted data.")
    }
    
    func locationManager(manager: CLLocationManager!,
        didExitRegion region: CLRegion!) {
            manager.stopRangingBeaconsInRegion(region as! CLBeaconRegion)
            manager.stopUpdatingLocation()
            
            NSLog("You exited the region")
            sendLocalNotificationWithMessage("You exited the DataTag Region")
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println(error)
    }
    
    
    func locationManager(manager: CLLocationManager!, monitoringDidFailForRegion region: CLRegion!, withError error: NSError!) {
        println(error)
    }
    
    func locationManager(manager: CLLocationManager!, rangingBeaconsDidFailForRegion region: CLBeaconRegion!, withError error: NSError!) {
        println(error)
    }
}
