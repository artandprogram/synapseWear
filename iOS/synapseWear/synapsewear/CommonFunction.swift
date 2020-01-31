//
//  CommonFunction.swift
//  synapsewear
//
//  Copyright © 2017 art and program, Inc. For license and other information refer to https://github.com/artandprogram/synapseWear. All rights reserved.
//

import UIKit

protocol CommonFunctionProtocol {
}
extension CommonFunctionProtocol {

    func getAppinfoValue(_ key: String) -> Any? {

        if let path = Bundle.main.path(forResource: "appinfo", ofType: "plist"), let dic = NSDictionary(contentsOfFile: path) as? [String: Any], let value = dic[key] {
            //print("getAppinfoValue: \(key) -> \(value)")
            return value
        }
        return nil
    }

    func getImageFromView(_ view: UIView) -> UIImage? {

        var image: UIImage? = nil

        UIGraphicsBeginImageContextWithOptions(view.frame.size, false, 0)
        if let context = UIGraphicsGetCurrentContext() {
            context.translateBy(x: -view.frame.origin.x, y: -view.frame.origin.y)
            view.layer.render(in: context)

            image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        return image
    }

    func makeAttributedLabel(_ str: String?, width: CGFloat, color: UIColor? = nil, font: UIFont? = nil, lineHeight: CGFloat, alignment: NSTextAlignment = NSTextAlignment.left) -> UILabel {

        let label: UILabel = UILabel()
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0

        if let str = str {
            var attributes: [NSAttributedString.Key: Any] = [:]
            if let color = color {
                attributes[.foregroundColor] = color
            }
            if let font = font {
                attributes[.font] = font
            }
            let paragrahStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
            paragrahStyle.minimumLineHeight = lineHeight
            paragrahStyle.maximumLineHeight = lineHeight
            paragrahStyle.alignment = alignment
            attributes[.paragraphStyle] = paragrahStyle

            let attributedString: NSAttributedString? = NSAttributedString(string: str, attributes: attributes)
            if let attributedString = attributedString {
                label.attributedText = attributedString
                let size: CGSize = CGSize(width: width, height: width * 1000)
                let rect: CGRect = attributedString.boundingRect(with: size, options: .usesLineFragmentOrigin, context: nil)
                label.frame = CGRect(x: 0, y: 0, width: rect.size.width, height: rect.size.height)
            }
        }

        return label
    }

    func getWiFiAddress() -> String? {

        var address: String?
        var ifaddr: UnsafeMutablePointer<ifaddrs>?

        guard getifaddrs(&ifaddr) == 0 else { return nil }
        guard let firstAddr = ifaddr else { return nil }
        for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let interface: ifaddrs = ifptr.pointee
            let addrFamily: sa_family_t = interface.ifa_addr.pointee.sa_family
            if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                let name: String = String(cString: interface.ifa_name)
                if name == "en0" {
                    var hostname: [CChar] = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(interface.ifa_addr,
                                socklen_t(interface.ifa_addr.pointee.sa_len),
                                &hostname,
                                socklen_t(hostname.count),
                                nil,
                                socklen_t(0),
                                NI_NUMERICHOST)
                    address = String(cString: hostname)
                }
            }
        }
        freeifaddrs(ifaddr)

        return address
    }

    func getTemperatureUnit(_ type: String) -> String {

        if type == TemperatureScaleKey.fahrenheit.rawValue {
            return "℉"
        }
        return "℃"
    }

    func getTemperatureValue(_ type: String, value: Float) -> Float {

        if type == TemperatureScaleKey.fahrenheit.rawValue {
            return self.makeFahrenheitTemperatureValue(value)
        }
        return value
    }

    func makeFahrenheitTemperatureValue(_ value: Float) -> Float {

        return value * 1.8 + 32.0
    }

    func makeAccelerationValue(_ value: Float) -> Float {

        let aScale: Float = 2.0 / 32768.0
        return value * aScale
    }

    func makeGyroscopeValue(_ value: Float) -> Float {

        let gScale: Float = 250.0 / 32768.0
        return value * gScale * Float(Double.pi / 180.0)
    }

    func dateToString(date: Date, dateFormat: String) -> String {

        let formatter: DateFormatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = dateFormat
        return formatter.string(from: date)
    }

    func log(_ msg: String) {

        print("\(self.dateToString(date: Date(), dateFormat: "yyyy-MM-dd HH:mm:ss.SSS")) \(msg)")
    }
}

extension String {

    func substring(from: Int, to: Int) -> String {

        let start: Index = index(self.startIndex, offsetBy: from)
        let end: Index = index(start, offsetBy: to - from)
        return String(self[start..<end])
    }

    func substring(range: NSRange) -> String {

        return substring(from: range.lowerBound, to: range.upperBound)
    }
}
