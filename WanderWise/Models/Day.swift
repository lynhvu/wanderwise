//
//  Day.swift
//  WanderWise
//
//  Created by Eduardo Cazares on 4/3/24.
//

import Foundation
import FirebaseFirestore

class Day {
    var date: Date
    var events: [Event]
    
    init(date: Date, events: [Event] = []) {
        self.date = date
        self.events = events
    }
    
    func toDictionary() -> [String: Any] {
        return [
            "date": date,
            "events": events.map { $0.toDictionary() }
        ]
    }
    
    static func from(dictionary: [String: Any]) -> Day? {
        guard let timestamp = dictionary["date"] as? Timestamp,
              let eventsDictionaries = dictionary["events"] as? [[String: Any]] else {
            return nil
        }
        
        let date = timestamp.dateValue()
        let events = eventsDictionaries.compactMap(Event.from(dictionary:))
        return Day(date: date, events: events)
    }
}

