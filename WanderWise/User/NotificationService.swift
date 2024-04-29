//
//  NotificationService.swift
//  WanderWise
//
//  Created by Eduardo Cazares on 4/8/24.
//

import Foundation
import UserNotifications
import FirebaseAuth

class NotificationService {
    static let shared = NotificationService()
    private init() {}
    
    func requestPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
    
    func scheduleNotificationsForUpcomingTrips(userId: String) {
        Trip.getUpcomingTripsByUserId(userId: userId) { [weak self] trips in
            guard let trips = trips, !trips.isEmpty else {
                print("No upcoming trips found or error fetching trips.")
                return
            }
            
            trips.forEach { trip in
                trip.days.forEach { day in
                    day.events.forEach { event in
                        self?.scheduleNotificationForPush(for: event, in: trip)
                    }
                }
            }
        }
    }
    
    func scheduleNotification(for event: Event, in trip: Trip) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User not logged in")
            return
        }
        
        UserProfile.areNotificationsEnabled(userId: userId) { [weak self] isEnabled, error in
            guard let self = self, isEnabled, error == nil else {
                if let error = error {
                    print("Error fetching user info: \(error.localizedDescription)")
                } else if !isEnabled {
                    print("Notifications are disabled in user profile.")
                }
                return
            }
            
            self.scheduleNotificationForPush(for: event, in: trip)
        }
    }
    
    private func scheduleNotificationForPush(for event: Event, in trip: Trip) {
        let content = UNMutableNotificationContent()
        content.title = "Upcoming Event Reminder"
        content.body = "Your event \(event.name) in trip \(trip.name) is coming up soon!"
        content.sound = UNNotificationSound.default
        
        guard let reminderDate = Calendar.current.date(byAdding: .minute, value: -10, to: event.startTime) else { return }
        let triggerDateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDateComponents, repeats: false)
        
        let request = UNNotificationRequest(identifier: event.id, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification for event \(event.name): \(error.localizedDescription)")
            }
        }
    }
    
    func updateEventNotification(oldEvent: Event, newEvent: Event, in trip: Trip) {
        removeNotificationByEvent(event: oldEvent)
        scheduleNotification(for: newEvent, in: trip)
    }
    
    func removeAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    func removeNotificationsByTrip(trip: Trip) {
        let identifiers = trip.days.flatMap { $0.events.map { $0.id } }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }
    
    func removeNotificationByEvent(event: Event) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [event.id])
    }
}
