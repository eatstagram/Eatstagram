//
//  MarketCell.swift
//  Eatstagram
//
//  Created by hor kimleng on 5/6/19.
//  Copyright © 2019 hor kimleng. All rights reserved.
//

import UIKit

class MarketCell: UITableViewCell {

    
    //IBOutlets
    @IBOutlet weak var priceView: UIView!
    @IBOutlet weak var priceLabel: UILabel!
    
    //Variables
    let priceArray = ["5", "10", "15", "20", "25", "30"]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        priceView.layer.cornerRadius = 7
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setUpView(index: Int) {
        priceLabel.text = priceArray[index]
    }

}
