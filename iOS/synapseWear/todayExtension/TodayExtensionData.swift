//
//  TodayExtensionData.swift
//  synapsewear
//
//  Copyright © 2019 art and program, Inc. For license and other information refer to https://github.com/artandprogram/synapseWear. All rights reserved.
//

import UIKit

class TodayExtensionData: NSObject {

    static let keyForTodayExtension: String = "group.com.artandprogram.sW"
    static let graphDataCount: Int = 35

    static func read() -> UserDefaults? {

        return UserDefaults(suiteName: self.keyForTodayExtension)
    }

    static func save(co2: Int?, battery: Float?, temp: Float?, humidity: Int?, pressure: Float?, graphData: [Any]) {

        if let userDefaults = UserDefaults(suiteName: self.keyForTodayExtension) {
            let co2Value: Int = co2 ?? -1
            let batteryValue: Float = battery ?? -1.0
            let tempValue: Float = temp ?? -1.0
            let humidityValue: Int = humidity ?? -1
            let pressureValue: Float = pressure ?? -1.0
            let now: Date = Date()

            userDefaults.set(now.timeIntervalSince1970, forKey: "updatedAt")
            userDefaults.set(co2Value, forKey: "co2")
            userDefaults.set(batteryValue, forKey: "battery")
            userDefaults.set(tempValue, forKey: "temp")
            userDefaults.set(humidityValue, forKey: "humidity")
            userDefaults.set(pressureValue, forKey: "pressure")
            userDefaults.set(graphData, forKey: "graphData")
        }
    }
    /*static func saveForTodayExtension(co2: Int?, battery: Float?, temp: Float?, humidity: Int?, pressure: Float?) {
        
        if let userDefaults = UserDefaults(suiteName: self.keyForTodayExtension) {
            let co2Value: Int = co2 ?? -1
            let batteryValue: Float = battery ?? -1.0
            let tempValue: Float = temp ?? -1.0
            let humidityValue: Int = humidity ?? -1
            let pressureValue: Float = pressure ?? -1.0

            var graphData: [Any] = userDefaults.array(forKey: "graphData") ?? Array<Int>(repeating: -1, count: 35)
            let lastUpdatedAt: TimeInterval = userDefaults.double(forKey: "updatedAt")
            let lastDate: Date = Date(timeIntervalSince1970: lastUpdatedAt)
            let now: Date = Date()
            if lastDate.timeIntervalSinceNow < -2100 {
                graphData = Array<Int>(repeating: -1, count: 35)
                graphData.insert(co2Value, at: 0)
            }
            else {
                let calendar: Calendar = Calendar(identifier: .gregorian)
                var dc: DateComponents = calendar.dateComponents([.minute], from: lastDate, to: now)
                let mins: Int = dc.minute ?? 0
                if mins > 0 {
                    graphData.insert(co2Value, at: 0)
                    let nullArray: [Any] = Array<Int>(repeating: -1, count: mins - 1)
                    graphData.insert(contentsOf: nullArray, at: 1)
                    //print(graphData)
                }
                else {
                    var newVal: Int = co2Value
                    if let lastVal = graphData[0] as? Int {
                        if lastVal > 0 {
                            newVal = (lastVal + co2Value) / 2
                        }
                    }
                    graphData[0] = newVal
                }
            }
            print("saveForTodayExtension: \(graphData)")
            graphData = graphData.prefix(35).map{ $0 }

            userDefaults.set(now.timeIntervalSince1970, forKey: "updatedAt")
            userDefaults.set(co2Value, forKey: "co2")
            userDefaults.set(batteryValue, forKey: "battery")
            userDefaults.set(tempValue, forKey: "temp")
            userDefaults.set(humidityValue, forKey: "humidity")
            userDefaults.set(pressureValue, forKey: "pressure")
            userDefaults.set(graphData, forKey: "graphData")
        }
    }*/
}
