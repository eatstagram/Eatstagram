//
//  DetailViewController.swift
//  Eatstagram
//
//  Created by hor kimleng on 4/20/19.
//  Copyright © 2019 hor kimleng. All rights reserved.
//

import UIKit
import SDWebImage

class DetailViewController: UIViewController {

    //IBOutlets
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    
    var post: Post!
    var imagePost: ImagePost!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if post != nil {
            if let url = URL(string: post.imageUrl) {
                photoImageView.sd_setImage(with: url)
            }
            locationLabel.text = post.location
            detailLabel.text = post.detail
            usernameLabel.text = "\(post.username ?? ""):"
        } else {
            if let url = URL(string: imagePost.imageURL ?? "") {
                photoImageView.sd_setImage(with: url)
            }
            locationLabel.text = imagePost.location
            detailLabel.text = imagePost.detail
            usernameLabel.text = "\(imagePost.username ?? ""):"
        }
    }

}
