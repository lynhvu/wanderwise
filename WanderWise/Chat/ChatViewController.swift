//
//  ChatViewController.swift
//  WanderWise
//
//  Created by Daphne Lopez on 4/6/24.
//

import UIKit
import GoogleGenerativeAI

var messages: [String] = []

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageField: UITextField!
    @IBOutlet weak var messageFieldBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var sendButtonBottomConstraint: NSLayoutConstraint!
    
    var location: String!
    var model: GenerativeModel!
    var chat: Chat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        messageField.delegate = self
        tableView.reloadData()
        scrollToBottom()
        
        // set up keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        // set up the AI Model
        setUpModel()
    }
    
    func setUpModel() {
        model = GenerativeModel(name: "gemini-pro", apiKey: getAPIKey())
        if messages.count == 0 {
            let firstMessage = "Hi! Welcome to \(location ?? "your new adventure")! I'm happy to be your tour guide during your trip, what would you like to know? I can give you recommendations for things to do, places to eat, or how to get around. Just let me know what you're interested in and I'll be happy to help."
            messages.append("\(firstMessage)")
            model = GenerativeModel(name: "gemini-pro", apiKey: getAPIKey())
            let history = [
                ModelContent(role: "user", parts: "You are my tour guide while I am visiting \(String(describing: location)). Please answer any questions I may have."),
                ModelContent(role: "model", parts: messages[0]),
            ]
            chat = model.startChat(history: history)
        } else {
            var history: [ModelContent] = []
            var role = "user"
            for message in messages {
                history.append(ModelContent(role: role, parts: message))
                // change role
                if role == "user" {
                    role = "model"
                } else {
                    role = "user"
                }
            }
            chat = model.startChat(history: history)
        }
    }
    
    // Handle keyboard show event
    @objc func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
                    return
                }
        let distance = keyboardFrame.height - view.safeAreaInsets.bottom
                
        // Animate movement of the message field
        UIView.animate(withDuration: 0.3) {
            self.messageFieldBottomConstraint.constant = distance
            self.sendButtonBottomConstraint.constant = distance
            self.view.layoutIfNeeded()
        }
    }
    
    // Handle keyboard hide event
    @objc func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.3) {
            self.messageFieldBottomConstraint.constant = 70
            self.sendButtonBottomConstraint.constant = 70
            self.view.layoutIfNeeded()
        }
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath)
        cell.textLabel?.text = messages[indexPath.row]
        return cell
    }

    @IBAction func sendButtonPressed(_ sender: Any) {
        // send user's message
        let newMessage = messageField.text!
        messages.append(newMessage)
        messageField.text = ""
        tableView.reloadData()
        scrollToBottom()
        
        // get model's message
        getModelResponse(newMessage: newMessage)
    }
    
    // Scroll to the bottom of the table view
    func scrollToBottom() {
        if !messages.isEmpty {
            let indexPath = IndexPath(row: messages.count - 1, section: 0)
            tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    func getModelResponse(newMessage: String) {
        Task {
            do {
                let response = try await chat.sendMessage(newMessage)
                if let text = response.text {
                    messages.append(text)
                    print(text)
                    tableView.reloadData()
                    scrollToBottom()
                }
            } catch {
                print("\(error)")
            }
        }
    }
    
    func getAPIKey() -> String {
        guard let filePath = Bundle.main.path(forResource: "GenerativeAI-Info", ofType: "plist")
        else {
          fatalError("Couldn't find file 'GenerativeAI-Info.plist'.")
        }
        let plist = NSDictionary(contentsOfFile: filePath)
        guard let value = plist?.object(forKey: "API_KEY") as? String else {
          fatalError("Couldn't find key 'API_KEY' in 'GenerativeAI-Info.plist'.")
        }
        if value.starts(with: "_") {
          fatalError(
            "Follow the instructions at https://ai.google.dev/tutorials/setup to get an API key."
          )
        }
        return value
    }

}