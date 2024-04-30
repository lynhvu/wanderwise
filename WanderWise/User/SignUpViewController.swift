//
//  SignUpViewController.swift
//  WanderWise
//
//  Created by L V on 3/29/24.
//

import UIKit
import FirebaseAuth

class SignUpViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    
    var userId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        firstNameField.delegate = self
        lastNameField.delegate = self
        usernameField.delegate = self
        emailField.delegate = self
        passwordField.delegate = self
        confirmPasswordField.delegate = self
        
        // hide text for password
        passwordField.isSecureTextEntry = true
        confirmPasswordField.isSecureTextEntry = true
    }
    
    // Called when 'return' key pressed
    func textFieldShouldReturn(_ textField:UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // Called when the user clicks on the view outside of the UITextField
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func createAccountPressed(_ sender: Any) {
        if (allFieldsFilled()) {
            // create a new user
            if self.passwordField.text! == self.confirmPasswordField.text! {
                Auth.auth().createUser(withEmail: self.emailField.text!, password: self.passwordField.text!)  {
                    (authResult, error) in
                    if let error = error as NSError? {
                        let signUpErrorAlert = UIAlertController(
                            title: "Error",
                            message: "\(error.localizedDescription)",
                            preferredStyle: .alert)
                        signUpErrorAlert.addAction(UIAlertAction(
                            title: "OK",
                            style: .default))
                        self.present(signUpErrorAlert, animated: true)
                    } else {
                        if (self.saveUserProfile(authResult: authResult)) {
                            self.performSegue(withIdentifier: "SignUpToHomeSegue", sender: self)
                        }
                    }
                }
            } else {
                // Alert for mismatching password fields
                let signUpErrorAlert = UIAlertController(
                    title: "Error",
                    message: "Passwords do not match",
                    preferredStyle: .alert)
                signUpErrorAlert.addAction(UIAlertAction(
                    title: "OK",
                    style: .default))
                self.present(signUpErrorAlert, animated: true)
            }
        }
    }
    
    // Save the user profile information to the database
    func saveUserProfile(authResult: AuthDataResult?) -> Bool {
        var successfulSave = false
        
        let firstName = self.firstNameField.text ?? ""
        let lastName = self.lastNameField.text ?? ""
        let username = self.usernameField.text ?? ""
        let email = self.emailField.text ?? ""
        let notifications = false
        let imageURL = ""
        
        let userId = authResult?.user.uid ?? ""
        
        let newUser = UserProfile(userId: userId, firstName: firstName, lastName: lastName, username: username, email: email, notifications: notifications, imageURL: imageURL)
        
        newUser.saveUserInfo(userId: userId) { error in
            if let error = error {
                // Handle error
                print("Error saving user info: \(error.localizedDescription)")
            } else {
                // User info saved successfully
                print("UserProfile info saved successfully")
                successfulSave = true
            }
        }
        return successfulSave
    }
    
    // Helper function to verify all fields are filled
    func allFieldsFilled() -> Bool {
        let firstName = self.firstNameField.text ?? ""
        let lastName = self.lastNameField.text ?? ""
        let username = self.usernameField.text ?? ""
        let email = self.emailField.text ?? ""
        let psw = self.passwordField.text ?? ""
        let confirmPsw = self.confirmPasswordField.text ?? ""
        
        var allFieldsFilled = false
        
        if (firstName == "" || lastName == "" || username == "" || email == "" || psw == "" || confirmPsw == "") {
            let signUpErrorAlert = UIAlertController(
                title: "Missing Information",
                message: "Please fill in all fields.",
                preferredStyle: .alert)
            signUpErrorAlert.addAction(UIAlertAction(
                title: "OK",
                style: .default))
            self.present(signUpErrorAlert, animated: true)
        } else {
            allFieldsFilled = true
        }
        return allFieldsFilled
    }
    
}


