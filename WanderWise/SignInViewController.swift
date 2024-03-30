//
//  SignInViewController.swift
//  WanderWise
//
//  Created by L V on 3/29/24.
//

import UIKit
import FirebaseAuth

class SignInViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func loginPressed(_ sender: Any) {
        Auth.auth().signIn(withEmail: self.emailField.text!, password: self.passwordField.text!) {
            (authResult, error) in
            if let error = error as NSError? {
                var errorMessage =  "\(error.localizedDescription)"
                print(errorMessage)
            } else {
                print("Successfully logged in!")
            }
        }
    }
    
}
