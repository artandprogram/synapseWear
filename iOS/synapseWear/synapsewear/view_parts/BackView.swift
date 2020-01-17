//
//  BackView.swift
//  synapsewear
//
//  Copyright © 2018 art and program, Inc. For license and other information refer to https://github.com/artandprogram/synapseWear. All rights reserved.
//

import UIKit

class BackView: UIView {

    var lineColor: UIColor?

    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {

        self.lineColor?.setStroke()

        let path = UIBezierPath()
        path.move(to: CGPoint(x: rect.size.width, y: 0))
        path.addLine(to: CGPoint(x: 1.0, y: rect.size.height / 2 + 0.1))
        path.lineWidth = 1.4
        path.stroke()

        path.move(to: CGPoint(x: 1.0, y: rect.size.height / 2 - 0.1))
        path.addLine(to: CGPoint(x: rect.size.width, y: rect.size.height))
        path.lineWidth = 1.4
        path.stroke()
    }

}
