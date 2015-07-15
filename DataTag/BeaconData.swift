//
//  BeaconData.swift
//  DataTag
//
//  Created by Aaron Monick on 7/14/15.
//  Copyright (c) 2015 DataTag. All rights reserved.
//

import Foundation
import Swift

struct BeaconData: Equatable {
    
    var UUID: String!
    var major: String!
    var minor: String!
    
    init(UUID _uuid: String!, major _major: String!, minor _minor: String!) {
        UUID = _uuid
        major = _major
        minor = _minor
    }
    
}

func ==(lhs: BeaconData, rhs: BeaconData) -> Bool {
    return lhs.UUID == rhs.UUID && lhs.major == rhs.major && lhs.minor == rhs.minor
}
