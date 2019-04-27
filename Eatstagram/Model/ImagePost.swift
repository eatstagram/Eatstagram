//
//  ImagePost.swift
//  Eatstagram
//
//  Created by hor kimleng on 4/23/19.
//  Copyright © 2019 hor kimleng. All rights reserved.
//

import Foundation
import Firebase

struct ImagePost {
    var imageURL: String?
    var location: String?
    var detail: String?
    var uid: String?
    var username: String?
    
    init(dictionary: [String: Any], username: String) {
        self.imageURL = dictionary["imageUrl"] as? String
        self.location = dictionary["location"] as? String
        self.detail = dictionary["detail"] as? String
        self.uid = dictionary["uid"] as? String
        self.username = username
    }
}
