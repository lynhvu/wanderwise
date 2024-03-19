//
//  Day.swift
//  WanderWise
//
//  Created by Daphne Lopez on 3/4/24.
//

import Foundation

public class Day {
    var date: String
    var events: [TripEvent] = []
    
    init(date: String) {
        self.date = date
        events = [
            TripEvent(title: "Family dinner", location: "Restaurant", notes: "Order the lasagna", time: "7:00pm"),
            TripEvent(title: "Star gazing", location: "Rooftop", notes: "Should be a meteor shower at 11pm!", time: "10:30pm")
        ]
    }
}
