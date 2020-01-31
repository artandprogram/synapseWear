//
//  CheckmarkView.swift
//  synapsewear
//
//  Copyright © 2018 art and program, Inc. For license and other information refer to https://github.com/artandprogram/synapseWear. All rights reserved.
//

import UIKit

class CheckmarkView: UIView {

    var triangleColor: UIColor?

    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {

        self.triangleColor?.setStroke()

        let path: UIBezierPath = UIBezierPath()
        path.move(to: CGPoint(x: 1.0, y: rect.size.height * 0.6))
        path.addLine(to: CGPoint(x: rect.size.width * 0.3, y: rect.size.height - 2.0))
        path.lineWidth = 2.0
        path.stroke()

        path.move(to: CGPoint(x: rect.size.width * 0.3 - 1.0, y: rect.size.height - 2.0))
        path.addLine(to: CGPoint(x: rect.size.width - 2.0, y: 2.0))
        path.lineWidth = 2.0
        path.stroke()
    }
}
