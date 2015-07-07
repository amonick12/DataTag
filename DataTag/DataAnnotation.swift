//
//  DataAnnotation.swift
//  DataTag
//
//  Created by Aaron Monick on 7/7/15.
//  Copyright (c) 2015 DataTag. All rights reserved.
//

import UIKit
import Foundation
import MapKit

class DataAnnotation: NSObject, MKAnnotation {
    
    let coordinate: CLLocationCoordinate2D
    var title: String
    var subtitle: String
    var radius: Int
    var data: AnyObject
    
    init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String, radius: Int, data: AnyObject) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.radius = radius
        self.data = data
    }
    
}
