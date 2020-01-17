//
//  defaultColors.swift
//  synapsewear
//
//  Copyright © 2017 art and program, Inc. For license and other information refer to https://github.com/artandprogram/synapseWear. All rights reserved.
//

import UIKit

extension UIColor {

    class var violetaElectra: UIColor { return #colorLiteral(red: 0.3568627451, green: 0.07058823529, blue: 0.537254902, alpha: 1) }
    class var fluorescentPink: UIColor { return #colorLiteral(red: 0.9019607843, green: 0.07450980392, blue: 0.3921568627, alpha: 1) }
    class var darkPurple: UIColor { return #colorLiteral(red: 0.3921568627, green: 0.2941176471, blue: 0.5294117647, alpha: 1) }
    class var graphCO2: UIColor { return #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) }
    class var graphTemp: UIColor { return #colorLiteral(red: 0.862745098, green: 0.1254901961, blue: 0.4039215686, alpha: 1) }
    class var graphHumi: UIColor { return #colorLiteral(red: 0, green: 0.8980392157, blue: 0.8117647059, alpha: 1) }
    class var graphIllu: UIColor { return #colorLiteral(red: 0.8901960784, green: 0.9450980392, blue: 0.231372549, alpha: 1) }
    class var graphAirP: UIColor { return #colorLiteral(red: 0.537254902, green: 0.2862745098, blue: 0.9647058824, alpha: 1) }
    class var graphEnvS: UIColor { return #colorLiteral(red: 0.2156862745, green: 0.462745098, blue: 1, alpha: 1) }
    class var graphMagF: UIColor { return #colorLiteral(red: 0.4117647059, green: 0.9764705882, blue: 0.2431372549, alpha: 1) }
    class var graphMove: UIColor { return #colorLiteral(red: 0.9921568627, green: 0.2823529412, blue: 0.7921568627, alpha: 1) }
    class var graphAngl: UIColor { return #colorLiteral(red: 0.9960784314, green: 0.5568627451, blue: 0.2392156863, alpha: 1) }
    class var graphVolt: UIColor { return #colorLiteral(red: 0.9960784314, green: 0.5568627451, blue: 0.2392156863, alpha: 1) }
    class var grayBGColor: UIColor { return #colorLiteral(red: 0.8705882353, green: 0.8745098039, blue: 0.8901960784, alpha: 1) }
    class var darkGrayBGColor: UIColor { return #colorLiteral(red: 0.1098039216, green: 0.1098039216, blue: 0.1176470588, alpha: 1) }

    public class func dynamicColor(light: UIColor, dark: UIColor) -> UIColor {

        if #available(iOS 13, *) {
            return UIColor { (traitCollection) -> UIColor in
                if traitCollection.userInterfaceStyle == .dark {
                    return dark
                }
                else {
                    return light
                }
            }
        }
        return light
    }
}
