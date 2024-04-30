//
//  Trip.swift
//  WanderWise
//
//  Created by Eduardo Cazares on 4/3/24.
//

import Foundation
import FirebaseFirestore

class Trip: Hashable {
    var id: String
    var userId: String
    var name: String
    var startDate: Date
    var endDate: Date
    var location: String
    var placeId: String
    var days: [Day]
    
    init(id: String = UUID().uuidString, userId: String, name: String, startDate: Date, endDate: Date, location: String, placeId: String, days: [Day] = []) {
        self.id = id
        self.userId = userId
        self.name = name
        self.startDate = startDate
        self.endDate = endDate
        self.location = location
        self.placeId = placeId
        self.days = days
    }
    
    func toDictionary() -> [String: Any] {
        return [
            "id": id,
            "userId": userId,
            "name": name,
            "startDate": startDate,
            "endDate": endDate,
            "location": location,
            "placeId": placeId,
            "days": days.map { $0.toDictionary() }
        ]
    }
    
    func toString() -> String {
        var itinerary = ""
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a"
        
        for day in days {
            for event in day.events {
                itinerary += "\(dateFormatter.string(from: day.date)), \(timeFormatter.string(from: event.startTime)), \(event.location), \(event.description) \n"
            }
        }
        return itinerary
    }
    
    static func from(dictionary: [String: Any]) -> Trip? {
        guard let id = dictionary["id"] as? String,
              let userId = dictionary["userId"] as? String,
              let name = dictionary["name"] as? String,
              let startDateTimestamp = dictionary["startDate"] as? Timestamp,
              let endDateTimestamp = dictionary["endDate"] as? Timestamp,
              let location = dictionary["location"] as? String,
              let placeId = dictionary["placeId"] as? String,
              let daysDictionaries = dictionary["days"] as? [[String: Any]] else {
            return nil
        }
        
        let startDate = startDateTimestamp.dateValue()
        let endDate = endDateTimestamp.dateValue()
        
        let days = daysDictionaries.compactMap { Day.from(dictionary: $0) }
        return Trip(id: id, userId: userId, name: name, startDate: startDate, endDate: endDate, location: location, placeId: placeId, days: days)
    }
    
    func deleteEventInTrip(event: Event) {
        for day in days {
            if let index = day.events.firstIndex(where: { $0.id == event.id }) {
                day.events.remove(at: index)
                break
            }
        }
        
        saveToDatabase { error in
            if let error = error {
                print("Error deleting event from trip: \(error.localizedDescription)")
            } else {
                print("Trip successfully updated with new event details")
            }
        }
    }
    
    func updateEventInTrip(updatedEvent: Event) {
        if let dayIndex = days.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: updatedEvent.date) }) {
            if let eventIndex = days[dayIndex].events.firstIndex(where: { $0.id == updatedEvent.id }) {
                days[dayIndex].events[eventIndex] = updatedEvent
            } else {
                for day in days {
                    if let index = day.events.firstIndex(where: { $0.id == updatedEvent.id }) {
                        day.events.remove(at: index)
                        break
                    }
                }
                days[dayIndex].events.append(updatedEvent)
            }
            days[dayIndex].events.sort { $0.startTime < $1.startTime }
        }
        
        saveToDatabase { error in
            if let error = error {
                print("Error updating trip with new event details: \(error.localizedDescription)")
            } else {
                print("Trip successfully updated with new event details")
            }
        }
    }
    
    func addEventToDay(event: Event, forDate date: Date) {
        if let dayIndex = self.days.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: date) }) {
            self.days[dayIndex].events.append(event)
            self.days[dayIndex].events.sort { $0.startTime < $1.startTime }
        }
        
        self.saveToDatabase { error in
            if let error = error {
                print("Error saving trip: \(error.localizedDescription)")
            } else {
                print("Trip successfully saved")
            }
        }
    }
    
    func saveToDatabase(completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()
        let tripDictionary = self.toDictionary()
        
        // Save or update the trip in Firestore
        db.collection("trips").document(self.id).setData(tripDictionary) { error in
            completion(error)
        }
    }
    
    static func deleteTripById(tripId: String, completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()
        db.collection("trips").document(tripId).delete() { error in
            completion(error)
        }
    }
    
    static func getTripsByUserId(userId: String, completion: @escaping ([Trip]?) -> Void) {
        let db = Firestore.firestore()
        db.collection("trips").whereField("userId", isEqualTo: userId).getDocuments { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("No documents for user \(userId)")
                completion(nil)
                return
            }
            
            let trips = documents.compactMap { docSnapshot -> Trip? in
                var tripData = docSnapshot.data()
                tripData["id"] = docSnapshot.documentID // Ensure the trip ID is included
                return Trip.from(dictionary: tripData)
            }
            completion(trips)
        }
    }
    
    static func getUpcomingTripsByUserId(userId: String, completion: @escaping ([Trip]?) -> Void) {
        let db = Firestore.firestore()
        let now = Date()
        
        db.collection("trips")
            .whereField("userId", isEqualTo: userId)
            .whereField("endDate", isGreaterThanOrEqualTo: now)
            .order(by: "startDate")
            .getDocuments { (querySnapshot, error) in
                guard let documents = querySnapshot?.documents else {
                    print("No upcoming trips for user \(userId)")
                    completion(nil)
                    return
                }
                
                let trips = documents.compactMap { docSnapshot -> Trip? in
                    var tripData = docSnapshot.data()
                    tripData["id"] = docSnapshot.documentID
                    return Trip.from(dictionary: tripData)
                }
                completion(trips)
            }
    }
    
    static func getPastTripsByUserId(userId: String, completion: @escaping ([Trip]?) -> Void) {
        let db = Firestore.firestore()
        let now = Date()
        
        db.collection("trips")
            .whereField("userId", isEqualTo: userId)
            .whereField("endDate", isLessThan: now)
            .getDocuments { (querySnapshot, error) in
                guard let documents = querySnapshot?.documents else {
                    print("No past trips for user \(userId)")
                    completion(nil)
                    return
                }
                
                let trips = documents.compactMap { docSnapshot -> Trip? in
                    var tripData = docSnapshot.data()
                    tripData["id"] = docSnapshot.documentID
                    return Trip.from(dictionary: tripData)
                }
                completion(trips)
            }
    }
    
    static func == (lhs: Trip, rhs: Trip) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
