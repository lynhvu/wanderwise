//
//  Trip.swift
//  WanderWise
//
//  Created by Daphne Lopez on 3/4/24.
//

import Foundation

class Trip {
    var tripName: String
    var days: [Day] = []
    
    init(name: String) {
        tripName = name
    }
}
