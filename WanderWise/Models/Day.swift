//
//  Day.swift
//  WanderWise
//
//  Created by Eduardo Cazares on 4/3/24.
//

import Foundation

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
        guard let date = dictionary["date"] as? Date,
              let eventsDictionaries = dictionary["events"] as? [[String: Any]] else {
            return nil
        }
        
        let events = eventsDictionaries.compactMap { Event.from(dictionary: $0) }
        return Day(date: date, events: events)
    }
}

