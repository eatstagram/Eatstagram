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
import SwiftLocation

let addNewPostNotificationKey = "com.kimleng.Eatstagram.addPost"

class NewpostViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource {

    //IBOutlets
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var detailTextView: UITextView!
    @IBOutlet weak var uploadImageButton: UIButton!
    @IBOutlet weak var foodImageView: UIImageView!
    @IBOutlet weak var locationTableView: UITableView!
    
    //Variables
    fileprivate let postHUD = JGProgressHUD(style: .dark)
    fileprivate var places = [PlaceMatch]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupTapGesture()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc fileprivate func handleTextFieldChanged() {
        if let place = locationTextField.text {
            LocationManager.shared.autocomplete(partialMatch: .placeDetail(place), service: .apple(nil)) { result in
                switch result {
                case .failure(let error):
                    debugPrint("Request failed: \(error)")
                case .success(let places):
                    self.places = places
                    self.locationTableView.isHidden = false
                    self.locationTableView.reloadData()
//                    debugPrint("Find \(places.count) places")
//                    for place in places {
//                        debugPrint("Place: \(place.fullMatch?.formattedAddress)")
//                    }
                }
            }
        }
    }
    
    func setupTapGesture() {
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handletapDismiss)))
    }
    
    @objc fileprivate func handletapDismiss(tapGestureRecognizer: UITapGestureRecognizer) {
        tapGestureRecognizer.cancelsTouchesInView = false
        self.locationTableView.isHidden = true
        self.view.endEditing(true)
    }
    
    fileprivate func setupView() {
        locationTableView.isHidden = true
        locationTableView.layer.borderWidth = 1
        locationTableView.layer.cornerRadius = 7
        locationTableView.layer.borderColor = #colorLiteral(red: 0.937254902, green: 0.937254902, blue: 0.937254902, alpha: 1)
        locationTextField.addTarget(self, action: #selector(handleTextFieldChanged), for: .editingChanged)
        locationTableView.delegate = self
        locationTableView.dataSource = self
        
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
    
//    fileprivate func saveImageToFirebase() {
//        postHUD.textLabel.text = "Posting"
//        postHUD.show(in: self.view, animated: true)
//        let filename = UUID().uuidString
//        let ref = Storage.storage().reference(withPath: "/images/\(filename)")
//        ref.putData(foodImageView!.image?.jpegData(compressionQuality: 0.5) ?? Data(), metadata: nil) { (_, error) in
//            if let error = error {
//                print("cannot save image to Firebase", error)
//                return
//            }
//            print("finish upload of image")
//            ref.downloadURL(completion: { (url, error) in
//                if let error = error {
//                    print("cannot get url of image", error)
//                    return
//                }
//                let imageURL = url?.absoluteString ?? ""
//
//                // Save into Firestore DB
//                self.savePostToFirestore(imageUrl: imageURL)
//            })
//        }
//    }
    
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
            self.clearInputs()
        }
    }

    fileprivate func clearInputs() {
        locationTextField.text = ""
        detailTextView.text = ""
        foodImageView.image = nil
        detailTextView.resignFirstResponder()
        locationTextField.resignFirstResponder()
    }
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        postHUD.textLabel.text = "Posting"
        postHUD.show(in: self.view, animated: true)
        saveImageToFirebase(imageView: foodImageView) { (url) in
            self.savePostToFirestore(imageUrl: url)
        }
        print("Done")
    }
    
    @IBAction func dismissButtonPressed(_ sender: Any) {
        self.tabBarController?.selectedIndex = 0
    }
    
    //tableview
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "locationCell") as! LocationViewCell
        cell.locationLabel.text = places[indexPath.row].fullMatch?.formattedAddress
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        locationTextField.text = places[indexPath.row].fullMatch?.formattedAddress
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
}
