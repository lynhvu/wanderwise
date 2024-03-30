//
//  SignUpViewController.swift
//  WanderWise
//
//  Created by L V on 3/29/24.
//

import UIKit
import FirebaseAuth

class SignUpViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    

    @IBAction func createAccountPressed(_ sender: Any) {
        // create a new user
        Auth.auth().createUser(withEmail: self.emailField.text!, password: self.passwordField.text!)  {
            (authResult, error) in
            if let error = error as NSError? {
                print("\(error.localizedDescription)")
            } else {
                print("New user created!")
            }
        }
    }
    
}
