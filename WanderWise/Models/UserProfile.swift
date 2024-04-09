//
//  User.swift
//  WanderWise
//
//  Created by Mariana Hermida Rojas on 4/7/24.
//

import Foundation
import FirebaseFirestore

class UserProfile {
    var userId: String
    var firstName: String
    var lastName: String
    var username: String
    var email: String
    var notifications: Bool
    
    init(userId: String, firstName: String, lastName: String, username: String, email: String, notifications: Bool) {
        self.userId = userId
        self.firstName = firstName
        self.lastName = lastName
        self.username = username
        self.email = email
        self.notifications = notifications
    }
    
    init() {
        self.userId = ""
        self.firstName = ""
        self.lastName = ""
        self.username = ""
        self.email = ""
        self.notifications = false
    }
    
    func saveUserInfo(userId: String, completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()
        
        let userInfoCollection = db.collection("userInfo")
        let userDocument = userInfoCollection.document(userId)
        
        let userData: [String: Any] = [
            "userId": self.userId,
            "firstName": self.firstName,
            "lastName": self.lastName,
            "username": self.username,
            "email": self.email,
            "notifications": self.notifications
        ]
        
        userDocument.setData(userData) { error in
            if let error = error {
                // Handle error
                print("Error saving user info: \(error.localizedDescription)")
                completion(error)
            } else {
                print("User info saved successfully")
                completion(nil)
            }
        }
    }
    
    
    func getUserInfo(userId: String, completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()
        
        db.collection("userInfo")
            .whereField("userId", isEqualTo: userId)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    // Handle error
                    print("Error getting user info: \(error.localizedDescription)")
                    completion(nil)
                } else {
                    guard let documents = querySnapshot?.documents,
                          let userData = documents.first?.data(),
                          let userId = userData["userId"] as? String,
                          let firstName = userData["firstName"] as? String,
                          let lastName = userData["lastName"] as? String,
                          let username = userData["username"] as? String,
                          let email = userData["email"] as? String,
                          let notifications = userData["notifications"] as? Bool else {
                        // Handle error: Invalid user data format or user not found
                        print("User info not found or invalid format")
                        completion(nil)
                        return
                    }
                    print("getuserinfo - " + firstName)
                    self.userId = userId
                    self.firstName = firstName
                    self.lastName = lastName
                    self.username = username
                    self.email = email
                    self.notifications = notifications
                    completion(nil)
                }
            }
    }
    
    static func areNotificationsEnabled(userId: String, completion: @escaping (Bool, Error?) -> Void) {
        let db = Firestore.firestore()
        
        db.collection("userInfo").document(userId).getDocument { document, error in
            if let document = document, document.exists {
                if let notificationsEnabled = document.get("notifications") as? Bool {
                    completion(notificationsEnabled, nil)
                } else {
                    completion(false, nil)
                }
            } else {
                completion(false, error)
            }
        }
    }
}
