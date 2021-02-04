//
//  SettingFileManager.swift
//  synapsewear
//
//  Copyright © 2017 art and program, Inc. For license and other information refer to https://github.com/artandprogram/synapseWear. All rights reserved.
//

import UIKit

class SettingFileManager: BaseFileManager {

    private let fileName: String = "setting"
    //let synapseIDKey: String = "synapse_id"
    private let oscSendModeKey: String = "osc_send_mode"
    private let oscSendIPAddressKey: String = "osc_send_ip_adress"
    private let oscSendPortKey: String = "osc_send_port"
    private let oscRecvModeKey: String = "osc_recv_mode"
    private let oscRecvPortKey: String = "osc_recv_port"
    private let synapseSendFlagKey: String = "synapse_send_flag"
    private let synapseSendURLKey: String = "synapse_send_url"
    private let synapseTimeIntervalKey: String = "synapse_time_interval"
    private let synapseFirmwareURLKey: String = "synapse_firmware_url"
    private let synapseFirmwareInfoKey: String = "synapse_firmware_info"
    private let synapseSoundInfoKey: String = "synapse_sound_info"
    private let synapseValidSensorsKey: String = "synapse_valid_sensors"
    private let synapseTemperatureScaleKey: String = "synapse_temperature_scale"
    private let synapseSaveLocalFileKey: String = "synapse_save_local_file"
    let synapseTimeIntervals: [String] = [
        "Normal",
        "Live",
        "Low Power",
    ]
    var oscSendMode: String = ""
    var oscSendIPAddress: String = ""
    var oscSendPort: String = ""
    var oscRecvMode: String = ""
    var oscRecvPort: String = ""
    var synapseSendFlag: Bool = false
    var synapseSendURL: String = ""
    var synapseTimeInterval: String = ""
    var synapseFirmwareURL: String = ""
    var synapseFirmwareInfo: [String: Any] = [:]
    var synapseSoundInfo: Bool = true
    var synapseValidSensors: [String: Bool] = [:]
    var synapseTemperatureScale: String = ""
    var synapseSaveLocalFile: Bool = false

    static let shared: SettingFileManager = SettingFileManager()

    override init() {
        super.init()

        self.baseDirType = "application_support"
        self.baseDirName = ""
        self.setBaseDir()

        self.synapseTimeInterval = self.synapseTimeIntervals[0]
        self.synapseTemperatureScale = TemperatureScaleKey.celsius.rawValue
    }

    override func setBaseDir() {
        super.setBaseDir()

        self.checkBaseDir()
    }

    func checkBaseDir() {

        if self.baseDirType == "documents" {
            return
        }

        let documentsDir: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let atFile: String = "\(documentsDir)/\(self.fileName)"
        let toFile: String = "\(self.baseDirPath)/\(self.fileName)"

        var isDir: ObjCBool = false
        var exists: Bool = FileManager.default.fileExists(atPath: atFile, isDirectory: &isDir)
        if exists && !isDir.boolValue {
            //print("SettingFileManager checkBaseDir: \(atFile) -> \(toFile)")
            do {
                exists = FileManager.default.fileExists(atPath: toFile)
                if exists {
                    try FileManager.default.removeItem(atPath: toFile)
                }

                try FileManager.default.moveItem(atPath: atFile, toPath: toFile)
            }
            catch {
                print("SettingFileManager checkBaseDir error: \(error.localizedDescription)")
            }
        }
    }

    func loadData() {

        if let data = self.getSettingData() {
            if let value = data[self.oscSendModeKey] as? String {
                self.oscSendMode = value
            }
            if let value = data[self.oscSendIPAddressKey] as? String {
                self.oscSendIPAddress = value
            }
            if let value = data[self.oscSendPortKey] as? String {
                self.oscSendPort = value
            }
            if let value = data[self.oscRecvModeKey] as? String {
                self.oscRecvMode = value
            }
            if let value = data[self.oscRecvPortKey] as? String {
                self.oscRecvPort = value
            }
            if let value = data[self.synapseSendFlagKey] as? Bool {
                self.synapseSendFlag = value
            }
            if let value = data[self.synapseSendURLKey] as? String {
                self.synapseSendURL = value
            }
            if let value = data[self.synapseTimeIntervalKey] as? String {
                self.synapseTimeInterval = value
            }
            if let value = data[self.synapseFirmwareURLKey] as? String {
                self.synapseFirmwareURL = value
            }
            if let value = data[self.synapseFirmwareInfoKey] as? [String: Any] {
                self.synapseFirmwareInfo = value
            }
            if let value = data[self.synapseSoundInfoKey] as? Bool {
                self.synapseSoundInfo = value
            }
            if let value = data[self.synapseValidSensorsKey] as? [String: Bool] {
                self.synapseValidSensors = value
            }
            if let value = data[self.synapseTemperatureScaleKey] as? String {
                self.synapseTemperatureScale = value
            }
            if let value = data[self.synapseSaveLocalFileKey] as? Bool {
                self.synapseSaveLocalFile = value
            }
            //print("loadData: \(data)")
        }
    }

    func saveData() -> Bool {

        let data: [String: Any] = [
            self.oscSendModeKey: self.oscSendMode,
            self.oscSendIPAddressKey: self.oscSendIPAddress,
            self.oscSendPortKey: self.oscSendPort,
            self.oscRecvModeKey: self.oscRecvMode,
            self.oscRecvPortKey: self.oscRecvPort,
            self.synapseSendFlagKey: self.synapseSendFlag,
            self.synapseSendURLKey: self.synapseSendURL,
            self.synapseTimeIntervalKey: self.synapseTimeInterval,
            self.synapseFirmwareURLKey: self.synapseFirmwareURL,
            self.synapseFirmwareInfoKey: self.synapseFirmwareInfo,
            self.synapseSoundInfoKey: self.synapseSoundInfo,
            self.synapseValidSensorsKey: self.synapseValidSensors,
            self.synapseTemperatureScaleKey: self.synapseTemperatureScale,
            self.synapseSaveLocalFileKey: self.synapseSaveLocalFile,
        ]
        //print("saveData: \(data)")
        return self.setSettingData(data)
    }

    func getSettingData() -> [String: Any]? {

        var res: [String: Any]? = nil
        if let data = self.getData(fileName: self.fileName) {
            if let dic = NSKeyedUnarchiver.unarchiveObject(with: data) as? [String: Any] {
                res = dic
            }
        }
        return res
    }

    func getSettingData(_ key: String) -> Any? {

        var value: Any? = nil
        var data: [String: Any]? = self.getSettingData()
        if let data = data {
            value = data[key]
        }
        data = nil
        return value
    }

    func setSettingData(_ data: [String: Any]) -> Bool {

        return self.setData(fileName: self.fileName, data: NSKeyedArchiver.archivedData(withRootObject: data))
    }

    func setSettingValue(_ key: String, value: Any) -> Bool {

        var settingData: [String: Any] = [:]
        if let data = self.getSettingData() {
            settingData = data
        }
        settingData[key] = value
        return self.setSettingData(settingData)
    }

    func getSynapseTimeInterval(_ mode: String, isBackground: Bool = false, isPlaySound: Bool = true) -> TimeInterval {

        var time: TimeInterval = 0
        if mode == self.synapseTimeIntervals[1] {
            time = 0.1
        }
        else if mode == self.synapseTimeIntervals[2] {
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

    func getSynapseTimeIntervalByteData() -> UInt8 {

        if self.synapseTimeInterval == self.synapseTimeIntervals[1] {
            return 0x01
        }
        else if self.synapseTimeInterval == self.synapseTimeIntervals[2] {
            return 0x02
        }
        else {
            return 0x00
        }
    }

    func checkSynapseTimeIntervalUpdate(_ mode: String, isPlaySound: Bool = true) -> Bool {

        var res: Bool = false
        if mode == self.synapseTimeIntervals[1] {
            res = false
        }
        else if mode == self.synapseTimeIntervals[2] {
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
        if mode == self.synapseTimeIntervals[2] {
            res = false
        }
        return res
    }
}
