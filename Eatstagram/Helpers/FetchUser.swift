//
//  FetchUser.swift
//  Eatstagram
//
//  Created by hor kimleng on 4/26/19.
//  Copyright © 2019 hor kimleng. All rights reserved.
//

import Foundation
import Firebase

func fetchUserFromFirestore(completion: @escaping (_ username: User)-> (), uid: String) {
    Firestore.firestore().collection("users").document(uid).getDocument { (snapshot, error) in
        
        if let data = snapshot?.data() {
            let user = User(dictionary: data)
            completion(user)
        }
    }
}
