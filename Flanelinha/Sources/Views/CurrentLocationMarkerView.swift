//
//  CurrentLocationMarkerView.swift
//  Flanelinha
//
//  Created by Raul Brito on 23/11/18.
//  Copyright © 2018 Raul Brito. All rights reserved.
//

import UIKit

class CurrentLocationMarkerView: UIView {

	private var shadowLayer: CAShapeLayer!
	private var cornerRadius: CGFloat = 8.5
	private var fillColor: UIColor = UIColor(red: 255/255, green: 147/255, blue: 0/255, alpha: 1)
	
	override func layoutSubviews() {
		super.layoutSubviews()

		if shadowLayer == nil {
			shadowLayer = CAShapeLayer()
			
			shadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
			shadowLayer.fillColor = fillColor.cgColor

			shadowLayer.shadowColor = fillColor.cgColor
			shadowLayer.shadowPath = shadowLayer.path
			shadowLayer.shadowOffset = .zero
			shadowLayer.shadowOpacity = 1
			shadowLayer.shadowRadius = 8.5
			
			shadowLayer.cornerRadius = bounds.height / 2
			shadowLayer.masksToBounds = false

//			layer.insertSublayer(shadowLayer, at: 0)
		}
	}

}
