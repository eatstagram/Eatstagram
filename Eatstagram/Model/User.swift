//
//  User.swift
//  Eatstagram
//
//  Created by hor kimleng on 4/20/19.
//  Copyright © 2019 hor kimleng. All rights reserved.
//

import Foundation

struct User {
    var imageUrl: String?
    var username: String?
    
    init(dictionary: [String: Any]) {
        self.imageUrl = dictionary["image"] as? String
        self.username = dictionary["username"] as? String
    }
}
