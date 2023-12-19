//
//  Extension.swift
//  Le Baluchon
//
//  Created by Nicolas Hecker on 14/11/2023.
//

import UIKit

extension UILabel {
    func applyCornerRadius(_ radius: CGFloat) {
            self.layer.cornerRadius = radius
            self.layer.masksToBounds = true
        }
}

extension UIView {
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let maskPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let maskLayer = CAShapeLayer()
        maskLayer.path = maskPath.cgPath
        layer.mask = maskLayer
    }
}
