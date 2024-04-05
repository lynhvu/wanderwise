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
    var startTime: Date
    var endTime: Date
    var location: String
    var description: String
    
    init(id: String = UUID().uuidString, name: String, startTime: Date, endTime: Date, location: String, description: String) {
        self.id = id
        self.name = name
        self.startTime = startTime
        self.endTime = endTime
        self.location = location
        self.description = description
    }
    
    func toDictionary() -> [String: Any] {
        return [
            "id": id,
            "name": name,
            "startTime": startTime,
            "endTime": endTime,
            "location": location,
            "description": description
        ]
    }
    
    static func from(dictionary: [String: Any]) -> Event? {
        guard let id = dictionary["id"] as? String,
              let name = dictionary["name"] as? String,
              let startTimeTimestamp = dictionary["startTime"] as? Timestamp,
              let endTimeTimestamp = dictionary["endTime"] as? Timestamp,
              let location = dictionary["location"] as? String,
              let description = dictionary["description"] as? String else {
            return nil
        }
        
        let startTime = startTimeTimestamp.dateValue()
        let endTime = endTimeTimestamp.dateValue()
        
        return Event(id: id, name: name, startTime: startTime, endTime: endTime, location: location, description: description)
    }
}
