//
//  SettingsViewController.swift
//  WanderWise
//
//  Created by Daphne Lopez on 3/27/24.
//

import UIKit
import FirebaseAuth
import FirebaseStorage

class SettingsViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var notificationSwitch: UISwitch!
    
    var imagePicker = UIImagePickerController()
    
    var currUserProfile: UserProfile?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        firstNameField.delegate = self
        lastNameField.delegate = self
        usernameField.delegate = self
        emailField.delegate = self
        
        imagePicker.delegate = self
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
        profileImageView.clipsToBounds = true
        
        cancelButton.isHidden = true
        saveButton.isHidden = true
        
        emailField.isEnabled = false
        
        // load in user's profile information
        guard let userId = Auth.auth().currentUser?.uid else {
            print("No user is currently signed in.")
            return
        }
        
        if currUserProfile == nil {
            currUserProfile = UserProfile()
            currUserProfile?.getUserInfo(userId: userId) { error in
                if let error = error {
                    print("Error getting user profile: \(error.localizedDescription)")
                } else {
                    print("UserProfile info retrieved successfully")
                    DispatchQueue.main.async {
                        self.reflectUserInfo()
                    }
                }
            }
        }
        reflectUserInfo()
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
    
    @IBAction func editPictureButtonPressed(_ sender: Any) {
        cancelButton.isHidden = false
        saveButton.isHidden = false
        
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            imagePicker.sourceType = .savedPhotosAlbum
            imagePicker.allowsEditing = false
            
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let newProfilePic = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            profileImageView.image = newProfilePic
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    // Linh
    @IBAction func logoutPressed(_ sender: Any) {
        do {
            let confirmAlert = UIAlertController(title: "Logout", message: "Are you sure you want to logout?", preferredStyle: UIAlertController.Style.alert)
            
            confirmAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                do {
                    try Auth.auth().signOut()
                    self.performSegue(withIdentifier: "LogoutToWelcomeScreenSegue", sender: self)
                    print("Handle Ok logic here")
                } catch let signOutError as NSError {
                    print("Error signing out: \(signOutError)")
                    // Handle sign out error here
                }
            }))
            
            confirmAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
                print("Handle Cancel Logic here")
            }))
            
            present(confirmAlert, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func infoEdited(_ sender: Any) {
        cancelButton.isHidden = false
        saveButton.isHidden = false
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        cancelButton.isHidden = true
        saveButton.isHidden = true
        reflectUserInfo()
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("No user is currently signed in.")
            return
        }
        
        let saveAlert = UIAlertController(
            title: "Save Information",
            message: "Are you sure you want to save this information to your profile? This action cannot be undone.",
            preferredStyle: .alert)
        saveAlert.addAction(UIAlertAction(
            title: "Cancel",
            style: .destructive))
        saveAlert.addAction(UIAlertAction(
            title: "Save",
            style: .default) { _ in
                if let profileImage = self.profileImageView.image {
                    self.uploadProfileImage(profileImage, userId: userId) { [weak self] result in
                        switch result {
                        case .success(let imageURL):
                            self?.saveUserProfile(userId: userId, imageURL: imageURL)
                        case .failure(let error):
                            print("Error uploading profile image: \(error)")
                        }
                    }
                } else {
                    self.saveUserProfile(userId: userId, imageURL: nil)
                }
                
            })
        self.present(saveAlert, animated: true)
    }
    
    func reflectUserInfo() {
        firstNameField.text = currUserProfile?.firstName
        lastNameField.text = currUserProfile?.lastName
        usernameField.text = currUserProfile?.username
        emailField.text = currUserProfile?.email
        notificationSwitch.setOn(currUserProfile?.notifications ?? false, animated: false)
        
        // Default image
        let defaultImage = UIImage(named: "Image.png")
        
        // Check if imageURL exists and is not an empty string
        if let imageURLString = currUserProfile?.imageURL, !imageURLString.isEmpty, let imageURL = URL(string: imageURLString) {
            // Fetch and set the user profile image
            URLSession.shared.dataTask(with: imageURL) { data, _, error in
                guard let data = data, error == nil else {
                    DispatchQueue.main.async {
                        self.profileImageView.image = defaultImage // Use default image in case of error
                    }
                    return
                }
                DispatchQueue.main.async {
                    self.profileImageView.image = UIImage(data: data)
                }
            }.resume()
        } else {
            // Set to default image if imageURL is empty or nil
            self.profileImageView.image = defaultImage
        }
    }

    
    func uploadProfileImage(_ image: UIImage, userId: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.4) else {
            return
        }
        
        let storageRef = Storage.storage().reference().child("profileImages/\(userId).jpg")
        storageRef.putData(imageData, metadata: nil) { metadata, error in
            guard metadata != nil else {
                completion(.failure(error!))
                return
            }
            
            storageRef.downloadURL { url, error in
                guard let downloadURL = url else {
                    completion(.failure(error!))
                    return
                }
                completion(.success(downloadURL.absoluteString))
            }
        }
    }
    
    
    private func saveUserProfile(userId: String, imageURL: String?) {
        let updatedUserProfile = UserProfile(
            userId: userId,
            firstName: self.firstNameField.text ?? "",
            lastName: self.lastNameField.text ?? "",
            username: self.usernameField.text ?? "",
            email: self.emailField.text ?? "",
            notifications: self.notificationSwitch.isOn,
            imageURL: imageURL ?? ""
        )
        
        updatedUserProfile.saveUserInfo(userId: userId) { [weak self] error in
            if let error = error {
                // Handle error
                print("Error saving user updated info: \(error.localizedDescription)")
                // Optionally, show an alert to the user
            } else {
                // User info saved successfully
                print("UserProfile updated info saved successfully")
                self?.currUserProfile = updatedUserProfile
                DispatchQueue.main.async {
                    self?.reflectUserInfo()
                    self?.cancelButton.isHidden = true
                    self?.saveButton.isHidden = true
                    // Optionally, show a success message to the user
                }
            }
        }
    }
    
    // TODO: add checks so the data they want to save is safe
}
