//
//  SignUpViewController.swift
//  WanderWise
//
//  Created by L V on 3/29/24.
//

import UIKit
import FirebaseAuth

class SignUpViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
                    self.performSegue(withIdentifier: "ProfileInfoSegue", sender: self)
                }
            }
            print("New user created!")
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
