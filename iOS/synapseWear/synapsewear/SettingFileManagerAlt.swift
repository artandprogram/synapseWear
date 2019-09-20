//
//  SettingFileManagerAlt.swift
//  synapsewear
//
//  Created by nakaguchi on 2019/09/11.
//  Copyright © 2019 art and program, Inc. For license and other information refer to https://github.com/artandprogram/synapseWear. All rights reserved.
//

import UIKit

class SettingFileManagerAlt: BaseFileManager {
    
    let fileName: String = "setting"
    //let synapseIDKey: String = "synapse_id"
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
    
    func getSettingOSCSendMode() -> String {
        
        return self.getSettingData(self.oscSendModeKey) as? String ?? ""
    }
    
    func getSettingOSCSendIPAddress() -> String {
        
        return self.getSettingData(self.oscSendIPAddressKey) as? String ?? ""
    }
    
    func getSettingOSCSendPort() -> String {
        
        return self.getSettingData(self.oscSendPortKey) as? String ?? ""
    }
    
    func getSettingOSCRecvMode() -> String {
        
        return self.getSettingData(self.oscRecvModeKey) as? String ?? ""
    }
    
    func getSettingOSCRecvPort() -> String {
        
        return self.getSettingData(self.oscRecvPortKey) as? String ?? ""
    }
    
    func getSettingSynapseSendFlag() -> Bool {
        
        return self.getSettingData(self.synapseSendFlagKey) as? Bool ?? false
    }
    
    func getSettingSynapseSendURL() -> String {
        
        return self.getSettingData(self.synapseSendURLKey) as? String ?? ""
    }
    
    func getSettingSynapseTimeInterval() -> String {
        
        return self.getSettingData(self.synapseTimeIntervalKey) as? String ?? self.synapseTimeIntervals[0]
    }
    
    func getSettingSynapseFirmwareURL() -> String {
        
        return self.getSettingData(self.synapseFirmwareURLKey) as? String ?? ""
    }
    
    func getSettingSynapseFirmwareInfo() -> [String: Any] {
        
        return self.getSettingData(self.synapseFirmwareInfoKey) as? [String: Any] ?? [:]
    }
    
    func getSettingSynapseSoundInfo() -> Bool {
        
        return self.getSettingData(self.synapseSoundInfoKey) as? Bool ?? true
    }
    
    func getSettingSynapseValidSensors() -> [String: Bool] {
        
        return self.getSettingData(self.synapseValidSensorsKey) as? [String: Bool] ?? [:]
    }
    
    func getSettingSynapseTemperatureScale() -> String {
        
        return self.getSettingData(self.synapseTemperatureScaleKey) as? String ?? ""
    }
    
    func setSettingOSCValues(oscSendMode: String, oscRecvMode: String, oscSendIP: String, oscSendPort: String, oscRecvPort: String) -> Bool {
        
        var settingData: [String: Any] = [:]
        if let data = self.getSettingData() {
            settingData = data
        }
        settingData[self.oscSendModeKey] = oscSendMode
        settingData[self.oscRecvModeKey] = oscRecvMode
        settingData[self.oscSendIPAddressKey] = oscSendIP
        settingData[self.oscSendPortKey] = oscSendPort
        settingData[self.oscRecvPortKey] = oscRecvPort
        return self.setSettingData(settingData)
    }
    
    func setSettingSynapseSendValues(flag: Bool, url: String) -> Bool {
        
        var settingData: [String: Any] = [:]
        if let data = self.getSettingData() {
            settingData = data
        }
        settingData[self.synapseSendFlagKey] = flag
        settingData[self.synapseSendURLKey] = url
        return self.setSettingData(settingData)
    }
    
    func setSettingSynapseTimeIntervalValue(_ synapseTimeInterval: String) -> Bool {
        
        return self.setSettingValue(self.synapseTimeIntervalKey, value: synapseTimeInterval)
    }
    
    func setSettingSynapseFirmwareURLValue(_ synapseFirmwareURL: String) -> Bool {
        
        return self.setSettingValue(self.synapseFirmwareURLKey, value: synapseFirmwareURL)
    }
    
    func setSettingSynapseFirmwareInfoValue(_ synapseFirmwareInfo: [String: Any]) -> Bool {
        
        return self.setSettingValue(self.synapseFirmwareInfoKey, value: synapseFirmwareInfo)
    }
    
    func setSettingSynapseSoundInfoValue(_ synapseSoundInfo: Bool) -> Bool {
        
        return self.setSettingValue(self.synapseSoundInfoKey, value: synapseSoundInfo)
    }
    
    func setSettingSynapseValidSensorsValue(_ synapseValidSensors: [String: Bool]) -> Bool {
        
        return self.setSettingValue(self.synapseValidSensorsKey, value: synapseValidSensors)
    }
    
    func setSettingSynapseTemperatureScaleValue(_ synapseTemperatureScale: String) -> Bool {
        
        return self.setSettingValue(self.synapseTemperatureScaleKey, value: synapseTemperatureScale)
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
