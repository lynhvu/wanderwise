//
//  Event.swift
//  WanderWise
//
//  Created by Eduardo Cazares on 4/3/24.
//

import Foundation
import FirebaseFirestore

class Event {
    var id: String
    var name: String
    var date: Date
    var startTime: Date
    var location: String
    var description: String
    
    init(id: String = UUID().uuidString, name: String, date: Date, startTime: Date, location: String, description: String) {
        self.id = id
        self.name = name
        self.date = date
        self.startTime = startTime
        self.location = location
        self.description = description
    }
    
    func toDictionary() -> [String: Any] {
        return [
            "id": id,
            "name": name,
            "date": date,
            "startTime": startTime,
            "location": location,
            "description": description
        ]
    }
    
    static func from(dictionary: [String: Any]) -> Event? {
        guard let id = dictionary["id"] as? String,
              let name = dictionary["name"] as? String,
              let dateTimestamp = dictionary["date"] as? Timestamp,
              let startTimeTimestamp = dictionary["startTime"] as? Timestamp,
              let location = dictionary["location"] as? String,
              let description = dictionary["description"] as? String else {
            return nil
        }
        
        let date = dateTimestamp.dateValue()
        let startTime = startTimeTimestamp.dateValue()
        
        return Event(id: id, name: name, date: date, startTime: startTime, location: location, description: description)
    }
}
