//
//  NewpostViewController.swift
//  Eatstagram
//
//  Created by hor kimleng on 4/17/19.
//  Copyright © 2019 hor kimleng. All rights reserved.
//

import UIKit
import Firebase


class NewpostViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var locationTextField: UITextField!
    
    @IBOutlet weak var detailTextView: UITextView!
    
    @IBOutlet weak var uploadImageButton: UIButton!
    
    @IBOutlet weak var foodImageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    @IBAction func uploadImageAction(_ sender: Any) {
        
        var imagePicker = UIImagePickerController()
        
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
    
    func saveImageToFirebase() {
        
        let filename = UUID().uuidString
        let ref = Storage.storage().reference(withPath: "/images/\(filename)")
        ref.putData(foodImageView!.image?.jpegData(compressionQuality: 0.8) ?? Data(), metadata: nil) { (_, error) in
            if let error = error {
                print("cannot save image to Firebase")
                return
            }
            print("finish upload of image")
            ref.downloadURL(completion: { (url, error) in
                if let error = error {
                    print("cannot get url of image")
                    return
                }
                let imageURL = url?.absoluteString ?? ""
                
                // Save into Firestore DB
                
                
            })
            
        }
        
    }
    
    
    @IBAction func doneButton(_ sender: Any) {
        saveImageToFirebase()
    }
    
}
