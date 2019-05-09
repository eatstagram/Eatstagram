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
        
        //print("The location is ",post.location)
        
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
    
    @IBAction func goButtonPressed(_ sender: Any) {
        var locationQuery = ""
        if post != nil {
            locationQuery = post.location?.replacingOccurrences(of: " ", with: "+") ?? ""
        } else {
            locationQuery = imagePost.location?.replacingOccurrences(of: " ", with: "+") ?? ""
        }
        
        if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
            UIApplication.shared.open(URL(string:"comgooglemaps://?q=\(locationQuery)")!, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.open(URL(string:"https://www.google.com/maps/search/?api=1&query=\(locationQuery)")!, options: [:], completionHandler: nil)
        }
    }
}
