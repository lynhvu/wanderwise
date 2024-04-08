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
    var name: String
    var username: String
    var email: String
    var notifications: Bool
    
    init(userId: String, name: String, username: String, email: String, notifications: Bool) {
        self.userId = userId
        self.name = name
        self.username = username
        self.email = email
        self.notifications = notifications
    }
    
    init() {
        self.userId = ""
        self.name = ""
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
            "name": self.name,
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
                                  let name = userData["name"] as? String,
                                  let username = userData["username"] as? String,
                                  let email = userData["email"] as? String,
                                  let notifications = userData["notifications"] as? Bool else {
                                // Handle error: Invalid user data format or user not found
                                print("User info not found or invalid format")
                                completion(nil)
                                return
                            }
                            self.userId = userId
                            self.name = name
                            self.username = username
                            self.email = email
                            self.notifications = notifications
                            completion(nil)
                        }
            }
    }
}
