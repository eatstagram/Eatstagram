//
//  DesignView.swift
//  Eatstagram
//
//  Created by hor kimleng on 4/17/19.
//  Copyright © 2019 hor kimleng. All rights reserved.
//
import UIKit

var gradientLayer: CAGradientLayer!

func createGradientLayer(gradientView: UIView) {
    gradientLayer = CAGradientLayer()
    gradientLayer.frame = gradientView.bounds
    gradientLayer.colors = [#colorLiteral(red: 0.1568627451, green: 0.1960784314, blue: 0.5725490196, alpha: 1).cgColor, #colorLiteral(red: 1, green: 0.3725490196, blue: 0.4274509804, alpha: 1).cgColor]
    gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
    gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
    gradientView.layer.addSublayer(gradientLayer)
}
