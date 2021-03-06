//
//  LabelNode.swift
//  synapsewear
//
//  Copyright © 2018 art and program, Inc. For license and other information refer to https://github.com/artandprogram/synapseWear. All rights reserved.
//

import UIKit
import SceneKit

class LabelNode: SCNNode {

    init(text: String, width: CGFloat, textColor: UIColor, panelColor: UIColor, textThickness: CGFloat, panelThickness: CGFloat) {
        super.init()

        let str: SCNText = SCNText(string: text, extrusionDepth: textThickness)
        str.font = UIFont(name: "HelveticaNeue", size: 1)

        let textNode: SCNNode = SCNNode(geometry: str)
        let w: CGFloat = CGFloat(textNode.boundingBox.max.x - textNode.boundingBox.min.x)
        let h: CGFloat = CGFloat(textNode.boundingBox.max.y - textNode.boundingBox.min.y)
        textNode.position = SCNVector3(-(w / 2), -(h / 2) - 0.9, 0.001 + textThickness)
        textNode.geometry?.materials.append(SCNMaterial())
        textNode.geometry?.materials.first?.diffuse.contents = textColor

        let panelNode: SCNNode = SCNNode(geometry: SCNBox(width: w * 1.1, height: h * 1.1, length: panelThickness, chamferRadius: 0))
        panelNode.geometry?.materials.append(SCNMaterial())
        panelNode.geometry?.materials.first?.diffuse.contents = panelColor

        addChildNode(textNode)
        addChildNode(panelNode)

        let ratio: CGFloat = width / w
        scale = SCNVector3(ratio, ratio, ratio)
    }

    required init?(coder aDecoder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }
}
