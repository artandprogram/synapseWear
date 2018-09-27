//
//  ArrowView.swift
//  synapsewear
//
//  Copyright © 2018年 art and program, Inc. For license and other information refer to https://github.com/artandprogram/synapseWear. All rights reserved.
//

import UIKit

class ArrowView: UIView {

    static let top: String = "top"
    static let left: String = "left"
    static let right: String = "right"
    static let bottom: String = "bottom"
    var type: String = "bottom"
    var triangleColor: UIColor?

    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {

        self.triangleColor?.setStroke()
        let path = UIBezierPath()
        if type == ArrowView.top {
            path.move(to: CGPoint(x: 0, y: rect.size.height))
            path.addLine(to: CGPoint(x: rect.size.width / 2, y: 0))
            path.lineWidth = 1.0
            path.stroke()

            path.move(to: CGPoint(x: rect.size.width / 2, y: 0))
            path.addLine(to: CGPoint(x: rect.size.width, y: rect.size.height))
            path.lineWidth = 1.0
            path.stroke()
        }
        else if type == ArrowView.left {
            path.move(to: CGPoint(x: rect.size.width, y: 0))
            path.addLine(to: CGPoint(x: 0, y: rect.size.height / 2))
            path.lineWidth = 1.0
            path.stroke()

            path.move(to: CGPoint(x: 0, y: rect.size.height / 2))
            path.addLine(to: CGPoint(x: rect.size.width, y: rect.size.height))
            path.lineWidth = 1.0
            path.stroke()
        }
        else if type == ArrowView.right {
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: rect.size.width, y: rect.size.height / 2))
            path.lineWidth = 1.0
            path.stroke()
            
            path.move(to: CGPoint(x: rect.size.width, y: rect.size.height / 2))
            path.addLine(to: CGPoint(x: 0, y: rect.size.height))
            path.lineWidth = 1.0
            path.stroke()
        }
        else {
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: rect.size.width / 2, y: rect.size.height))
            path.lineWidth = 1.0
            path.stroke()

            path.move(to: CGPoint(x: rect.size.width / 2, y: rect.size.height))
            path.addLine(to: CGPoint(x: rect.size.width, y: 0))
            path.lineWidth = 1.0
            path.stroke()
        }
    }
}
