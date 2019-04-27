//
//  Comment.swift
//  Eatstagram
//
//  Created by hor kimleng on 4/24/19.
//  Copyright © 2019 hor kimleng. All rights reserved.
//

import Foundation
import Firebase

struct Comment {
    var imageUrl: String?
    var createdAt: Timestamp?
    var comment: String?
    var username: String?
    
    init(dictionary: [String: Any]) {
        self.imageUrl = dictionary["imageUrl"] as? String
        self.createdAt = dictionary["createdAt"] as? Timestamp
        self.comment = dictionary["comment"] as? String
        self.username = dictionary["username"] as? String
    }
}
