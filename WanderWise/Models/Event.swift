//
//  Event.swift
//  WanderWise
//
//  Created by Eduardo Cazares on 4/3/24.
//

import Foundation

class Event {
    var name: String
    var startTime: Date
    var endTime: Date
    var location: String
    var description: String
    
    init(name: String, startTime: Date, endTime: Date, location: String, description: String) {
        self.name = name
        self.startTime = startTime
        self.endTime = endTime
        self.location = location
        self.description = description
    }
    
    func toDictionary() -> [String: Any] {
        return [
            "name": name,
            "startTime": startTime,
            "endTime": endTime,
            "location": location,
            "description": description
        ]
    }
    
    static func from(dictionary: [String: Any]) -> Event? {
        guard let name = dictionary["name"] as? String,
              let startTime = dictionary["startTime"] as? Date,
              let endTime = dictionary["endTime"] as? Date,
              let location = dictionary["location"] as? String,
              let description = dictionary["description"] as? String else {
            return nil
        }
        
        return Event(name: name, startTime: startTime, endTime: endTime, location: location, description: description)
    }
}
