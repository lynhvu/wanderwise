//
//  ItineraryHeaderView.swift
//  WanderWise
//
//  Created by Daphne Lopez on 3/6/24.
//

import UIKit

class ItineraryHeaderView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let cornerRadius: CGFloat = 10
        let maskLayer = CAShapeLayer()
       
        // Create a path for the rounded corners and apply it
        // to the view's layers
        let path = UIBezierPath(roundedRect: bounds,
                                byRoundingCorners: [.topLeft, .topRight],
                                cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
        maskLayer.path = path.cgPath
        layer.mask = maskLayer
    }

}
