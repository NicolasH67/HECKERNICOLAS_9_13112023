//
//  UILabel+Corner.swift
//  Le Baluchon
//
//  Created by Nicolas Hecker on 17/01/2024.
//

import UIKit

extension UILabel {
    func applyCornerRadius(_ radius: CGFloat) {
            self.layer.cornerRadius = radius
            self.layer.masksToBounds = true
        }
}
