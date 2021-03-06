//
//  CommonFunction.swift
//  synapseWearCentral
//
//  Copyright © 2017 art and program, Inc. For license and other information refer to https://github.com/artandprogram/synapseWear. All rights reserved.
//

class CommonFunction {

    static func getAppinfoValue(_ key: String) -> Any? {

        if let path = Bundle.main.path(forResource: "appinfo", ofType: "plist"), let dic = NSDictionary(contentsOfFile: path) as? [String: Any], let value = dic[key] {
            //print("getAppinfoValue: \(key) -> \(value)")
            return value
        }
        return nil
    }

    static func makeAccelerationValue(_ value: Float) -> Float {

        let aScale: Float = 2.0 / 32768.0
        return value * aScale
    }

    static func makeGyroscopeValue(_ value: Float) -> Float {

        let gScale: Float = 250.0 / 32768.0
        return value * gScale * Float(Double.pi / 180.0)
    }

    static func log(_ msg: String) {

        let formatter: DateFormatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        print("\(formatter.string(from: Date())) \(msg)")
    }
}
