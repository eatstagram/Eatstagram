//
//  Post.swift
//  Eatstagram
//
//  Created by hor kimleng on 4/20/19.
//  Copyright © 2019 hor kimleng. All rights reserved.
//

import Foundation
import Firebase

struct Post {
    var imageUrl: String
    var numLikes: Int
    var detail: String?
    var createdAt: Timestamp?
    var location: String?
    var userId: String?
    var userImageUrl: String?
    var username: String?
    var isLiked = false
    
    init(dictionary: [String: Any], user: User) {
        self.imageUrl = dictionary["imageUrl"] as? String ?? ""
        self.numLikes = dictionary["numLikes"] as? Int ?? 0
        self.detail = dictionary["detail"] as? String
        self.createdAt = dictionary["createdAt"] as? Timestamp
        self.location = dictionary["location"] as? String
        self.userId = dictionary["uid"] as? String
        self.userImageUrl = user.imageUrl
        self.username = user.username
    }
}
