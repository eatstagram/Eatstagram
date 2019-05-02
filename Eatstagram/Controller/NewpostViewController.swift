//
//  NewpostViewController.swift
//  Eatstagram
//
//  Created by hor kimleng on 4/17/19.
//  Copyright © 2019 hor kimleng. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import JGProgressHUD

let addNewPostNotificationKey = "com.kimleng.Eatstagram.addPost"

class NewpostViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    //IBOutlets
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var detailTextView: UITextView!
    @IBOutlet weak var uploadImageButton: UIButton!
    @IBOutlet weak var foodImageView: UIImageView!
    
    //Variables
    fileprivate let postHUD = JGProgressHUD(style: .dark)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupTapGesture()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    func setupTapGesture() {
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handletapDismiss)))
    }
    
    @objc fileprivate func handletapDismiss() {
        self.view.endEditing(true)
    }
    
    fileprivate func setupView() {
        foodImageView.layer.cornerRadius = 7
        foodImageView.layer.borderWidth = 1
        foodImageView.layer.borderColor = #colorLiteral(red: 0.937254902, green: 0.937254902, blue: 0.937254902, alpha: 1)
        detailTextView.layer.cornerRadius = 7
        detailTextView.layer.borderWidth = 1
        detailTextView.layer.borderColor = #colorLiteral(red: 0.937254902, green: 0.937254902, blue: 0.937254902, alpha: 1)
    }
    
    @IBAction func uploadImageButtonPressed(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let image = info[.originalImage] as! UIImage
        
        foodImageView.image = image
        dismiss(animated: true, completion: nil)
    }
    
    fileprivate func saveImageToFirebase() {
        postHUD.textLabel.text = "Posting"
        postHUD.show(in: self.view, animated: true)
        let filename = UUID().uuidString
        let ref = Storage.storage().reference(withPath: "/images/\(filename)")
        ref.putData(foodImageView!.image?.jpegData(compressionQuality: 0.8) ?? Data(), metadata: nil) { (_, error) in
            if let error = error {
                print("cannot save image to Firebase", error)
                return
            }
            print("finish upload of image")
            ref.downloadURL(completion: { (url, error) in
                if let error = error {
                    print("cannot get url of image", error)
                    return
                }
                let imageURL = url?.absoluteString ?? ""
                
                // Save into Firestore DB
                self.savePostToFirestore(imageUrl: imageURL)
            })
        }
    }
    
    fileprivate func savePostToFirestore(imageUrl: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let timeCreated = FieldValue.serverTimestamp()
        let docData: [String: Any] = [
            "uid": uid,
            "imageUrl": imageUrl,
            "createdAt": timeCreated,
            "detail": detailTextView.text ?? "",
            "numLikes": 0,
            "location": locationTextField.text ?? ""
        ]
        
        Firestore.firestore().collection("posts").document().setData(docData) { (error) in
            if let error = error {
                print("Failed to upload post ", error)
                return
            }
            print("Finish uploading post")
        }
        
        let imageData: [String: Any] = [
            "createdAt": timeCreated,
            "imageUrl": imageUrl,
            "location": locationTextField.text ?? "",
            "detail": detailTextView.text ?? "",
            "uid": uid
        ]
    Firestore.firestore().collection("userImagePosts").document(uid).collection("images").document().setData(imageData) { (error) in
            if let error = error {
                print("Failed to upload image post ", error)
                return
            }
            print("Finish uploading image post")
        
            //Post the notification
            let name = Notification.Name(rawValue: addNewPostNotificationKey)
            NotificationCenter.default.post(name: name, object: nil)
            self.postHUD.dismiss()
            self.tabBarController?.selectedIndex = 0
        }
    }

    @IBAction func doneButtonPressed(_ sender: Any) {
        saveImageToFirebase()
        print("Done")
    }
    
    @IBAction func dismissButtonPressed(_ sender: Any) {
        self.tabBarController?.selectedIndex = 0
    }
}
