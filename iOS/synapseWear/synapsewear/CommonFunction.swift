//
//  CommonFunction.swift
//  synapsewear
//
//  Copyright © 2017年 art and program, Inc. For license and other information refer to https://github.com/artandprogram/synapseWear. All rights reserved.
//

import UIKit

class CommonFunction {

    static func getImageFromView(_ view: UIView) -> UIImage? {

        var image: UIImage? = nil

        UIGraphicsBeginImageContextWithOptions(view.frame.size, false, 0);
        if let context = UIGraphicsGetCurrentContext() {
            context.translateBy(x: -view.frame.origin.x, y: -view.frame.origin.y)
            view.layer.render(in: context)

            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
        return image
    }

    static func makeAttributedLabel(_ str: String?, width: CGFloat, color: UIColor? = nil, font: UIFont? = nil, lineHeight: CGFloat, alignment: NSTextAlignment = NSTextAlignment.left) -> UILabel {

        let label: UILabel = UILabel()
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.numberOfLines = 0

        if let str = str {
            var attributes: [NSAttributedStringKey: Any] = [:]
            if let color = color {
                attributes[NSAttributedStringKey.foregroundColor] = color
            }
            if let font = font {
                attributes[NSAttributedStringKey.font] = font
            }
            let paragrahStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
            paragrahStyle.minimumLineHeight = lineHeight
            paragrahStyle.maximumLineHeight = lineHeight
            paragrahStyle.alignment = alignment
            attributes[NSAttributedStringKey.paragraphStyle] = paragrahStyle

            let attributedString: NSAttributedString? = NSAttributedString(string: str, attributes: attributes)
            if let attributedString = attributedString {
                label.attributedText = attributedString
                let size: CGSize = CGSize(width: width, height: width * 1000)
                let rect: CGRect = attributedString.boundingRect(with: size, options: NSStringDrawingOptions.usesLineFragmentOrigin, context: nil)
                label.frame = CGRect(x: 0, y: 0, width: rect.size.width, height: rect.size.height)
            }
        }

        return label
    }

    static func getWiFiAddress() -> String? {

        var address: String?
        // Get list of all interfaces on the local machine:
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return nil }
        guard let firstAddr = ifaddr else { return nil }
        // For each interface ...
        for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let interface: ifaddrs = ifptr.pointee
            // Check for IPv4 or IPv6 interface:
            let addrFamily: sa_family_t = interface.ifa_addr.pointee.sa_family
            if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                // Check interface name:
                let name: String = String(cString: interface.ifa_name)
                if name == "en0" {
                    // Convert interface address to a human readable string:
                    var hostname: [CChar] = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len), &hostname, socklen_t(hostname.count), nil, socklen_t(0), NI_NUMERICHOST)
                    address = String(cString: hostname)
                }
            }
        }
        freeifaddrs(ifaddr)

        return address
    }

    static func log(_ msg: String) {

        let formatter: DateFormatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        print("\(formatter.string(from: Date())) \(msg)")
    }

    static func makeFahrenheitTemperatureValue(_ value: Float) -> Float {

        return value * 1.8 + 32.0
    }
    
    static func saveForTodayExtension(co2:Int?, battery:Float, temp:Float, humidity:Int, pressure:Float) {
        //print(Date().timeIntervalSince1970)
        let co2Value = co2 ?? -1
        
        if let userDefaults = UserDefaults(suiteName: "group.com.artandprogram.sW"){
            var graphData = userDefaults.array(forKey: "graphData") ?? Array<Int>(repeating: -1, count: 35)
            
            let lastUpdatedAt:TimeInterval = userDefaults.double(forKey: "updatedAt")
            let lastDate = Date(timeIntervalSince1970: lastUpdatedAt)
            let now = Date()
            
            if lastDate.timeIntervalSinceNow < -2100{
                graphData = Array<Int>(repeating: -1, count: 35)
                graphData.insert(co2Value, at: 0)
            }else{
                let calendar = Calendar(identifier: .gregorian)
                var dc = calendar.dateComponents([.minute], from: lastDate, to: now)
                let mins = dc.minute ?? 0
                if mins > 0 {
                    graphData.insert(co2Value, at: 0)
                    let nullArray = Array<Int>(repeating: -1, count: mins - 1)
                    graphData.insert(contentsOf: nullArray, at: 1)
                    print(graphData)
                }else{
                    var newVal = co2Value
                    if let lastVal = graphData[0] as? Int{
                        if lastVal > 0 {
                            newVal = (lastVal + co2Value ) / 2
                        }
                    }
                    graphData[0] = newVal
                }
            }
            graphData = graphData.prefix(35).map{ $0 }
            
            userDefaults.set(co2Value, forKey: "co2")
            userDefaults.set(battery, forKey: "battery")
            userDefaults.set(temp, forKey: "temp")
            userDefaults.set(humidity, forKey: "humidity")
            userDefaults.set(pressure, forKey: "pressure")
            userDefaults.set(now.timeIntervalSince1970, forKey: "updatedAt")
            userDefaults.set(graphData, forKey: "graphData")
        }
    }
}
