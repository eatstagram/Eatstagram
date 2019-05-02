//
//  CommentCell.swift
//  Eatstagram
//
//  Created by hor kimleng on 4/24/19.
//  Copyright © 2019 hor kimleng. All rights reserved.
//

import UIKit

class CommentCell: UITableViewCell {

    //IBOutlets
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setUpCell(comment: Comment) {
        profileImageView.sd_setImage(with: URL(string: comment.imageUrl ?? ""))
        let boldUserName = comment.username ?? ""
        let attribute = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 15)]
        let attributeString = NSMutableAttributedString(string: boldUserName, attributes: attribute)
        let commentText = NSMutableAttributedString(string: ": \(comment.comment ?? "")")
        attributeString.append(commentText)
        commentLabel.attributedText = attributeString
        
        //convert timestamp to date
        if let date = comment.createdAt?.dateValue() {
            timeLabel.text = date.durationAgo()
        } else {
            timeLabel.text = "1 second ago"
        }
    }
}
