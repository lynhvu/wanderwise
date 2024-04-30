//
//  SignInViewController.swift
//  WanderWise
//
//  Created by L V on 3/29/24.
//

import UIKit
import FirebaseAuth

class SignInViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailField.delegate = self
        passwordField.delegate = self
        
        // hide text for password
        passwordField.isSecureTextEntry = true
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
    
    @IBAction func loginPressed(_ sender: Any) {
        Auth.auth().signIn(withEmail: self.emailField.text!, password: self.passwordField.text!) {
            (authResult, error) in
            if let error = error as NSError? {
                print("\(error.localizedDescription)")
                let signInErrorAlert = UIAlertController(
                    title: "Error",
                    message: "\(error.localizedDescription)",
                    preferredStyle: .alert)
                signInErrorAlert.addAction(UIAlertAction(
                    title: "OK",
                    style: .default))
                self.present(signInErrorAlert, animated: true)
            } else {
                print("Successfully logged in!")
                self.performSegue(withIdentifier: "SigninToHome", sender: self)
            }
        }
    }
    
}
