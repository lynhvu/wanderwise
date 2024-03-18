//
//  TripEvent.swift
//  WanderWise
//
//  Created by Daphne Lopez on 3/4/24.
//

import Foundation

class TripEvent {
    var title: String
    var location: String
    var time: String
    var notes: String
    
    init(title: String, location: String, notes: String, time: String) {
        self.title = title
        self.location = location
        self.time = time
        self.notes = notes
    }
}
