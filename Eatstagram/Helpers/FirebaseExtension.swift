//
//  FetchUser.swift
//  Eatstagram
//
//  Created by hor kimleng on 4/26/19.
//  Copyright © 2019 hor kimleng. All rights reserved.
//

import Foundation
import Firebase

func fetchUserFromFirestore(completion: @escaping (_ user: User)-> (), uid: String) {
    Firestore.firestore().collection("users").document(uid).getDocument { (snapshot, error) in
        
        if let data = snapshot?.data() {
            let user = User(dictionary: data)
            completion(user)
        }
    }
}

//duplicate code
func saveImageToFirebase(imageView: UIImageView, completion: @escaping (_ url: String)->()) {
    let filename = UUID().uuidString
    let ref = Storage.storage().reference(withPath: "/images/\(filename)")
    ref.putData(imageView.image?.jpegData(compressionQuality: 0.3) ?? Data(), metadata: nil) { (_, error) in
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
            completion(imageURL)
            
            //self.changeImageInFirebase(imageURL: imageURL)
        })
    }
}
