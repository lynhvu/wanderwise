//
//  Day.swift
//  WanderWise
//
//  Created by Daphne Lopez on 3/4/24.
//

import Foundation

class Day {
    var date: String
    var events: [TripEvent] = []
    
    init(date: String) {
        self.date = date
    }
}
