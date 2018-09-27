//
//  SettingFileManager.swift
//  synapsewear
//
//  Copyright © 2017年 art and program, Inc. For license and other information refer to https://github.com/artandprogram/synapseWear. All rights reserved.
//

import UIKit

class SettingFileManager: BaseFileManager {

    let fileName: String = "setting"
    let synapseIDKey: String = "synapse_id"
    let oscSendModeKey: String = "osc_send_mode"
    let oscSendIPAddressKey: String = "osc_send_ip_adress"
    let oscSendPortKey: String = "osc_send_port"
    let oscRecvModeKey: String = "osc_recv_mode"
    let oscRecvPortKey: String = "osc_recv_port"
    let synapseSendFlagKey: String = "synapse_send_flag"
    let synapseSendURLKey: String = "synapse_send_url"
    let synapseTimeIntervalKey: String = "synapse_time_interval"
    let synapseFirmwareURLKey: String = "synapse_firmware_url"
    let synapseFirmwareInfoKey: String = "synapse_firmware_info"
    let synapseSoundInfoKey: String = "synapse_sound_info"
    let synapseValidSensorsKey: String = "synapse_valid_sensors"
    let synapseTemperatureScaleKey: String = "synapse_temperature_scale"
    let synapseTimeIntervals: [String] = [
        "Normal",
        "Live",
        "Low Power",
    ]

    override init() {
        super.init()

        self.baseDirType = "documents"
        self.baseDirName = ""
        self.setBaseDir()
    }

    public func getSettingData() -> [String: Any]? {

        var res: [String: Any]? = nil
        if let data = self.getData(fileName: self.fileName) {
            if let dic = NSKeyedUnarchiver.unarchiveObject(with: data) as? [String: Any] {
                res = dic
            }
        }
        return res
    }

    public func getSettingData(_ key: String) -> Any? {

        var value: Any? = nil
        var data: [String: Any]? = self.getSettingData()
        if let data = data {
            value = data[key]
        }
        data = nil
        return value
    }

    public func setSettingData(_ data: [String: Any]) -> Bool {

        return self.setData(fileName: self.fileName, data: NSKeyedArchiver.archivedData(withRootObject: data))
    }

    func getSynapseTimeInterval(_ mode: String, isBackground: Bool = false, isPlaySound: Bool = true) -> TimeInterval {

        var time: TimeInterval = 0
        if mode == "Live" {
            time = 0.1
        }
        else if mode == "Low Power" {
            time = 300.0
        }
        else {
            time = 0.1
            if isBackground && !isPlaySound {
                time = 60.0
            }
        }
        return time
    }

    func checkSynapseTimeIntervalUpdate(_ mode: String, isPlaySound: Bool = true) -> Bool {

        var res: Bool = false
        if mode == "Live" {
            res = false
        }
        else if mode == "Low Power" {
            res = false
        }
        else {
            res = false
            if !isPlaySound {
                res = true
            }
        }
        return res
    }

    func checkPlayableSound(_ mode: String) -> Bool {

        var res: Bool = true
        if mode == "Low Power" {
            res = false
        }
        return res
    }
}
