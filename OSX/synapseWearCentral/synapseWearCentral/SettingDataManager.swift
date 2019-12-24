//
//  SettingDataManager.swift
//  synapseWearCentral
//
//  Copyright © 2018 art and program, Inc. For license and other information refer to https://github.com/artandprogram/synapseWear. All rights reserved.
//

import Cocoa

class SettingDataManager: NSObject {

    //let settingDataKey: String = "setting"
    let settingSynapsesKey: String = "setting_synapses"
    //let synapseAccessKeyKey: String = "synapse_access_key"
    let synapseDirectoryKey: String = "synapse_directory"
    let synapseTimeIntervalKey: String = "synapse_time_interval"
    let synapseValidSensorsKey: String = "synapse_valid_sensors"
    let synapseOSCIPAddressKey: String = "synapse_osc_ip_address"
    let synapseOSCPortKey: String = "synapse_osc_port"
    let userDefaults: UserDefaults = UserDefaults.standard

    func getSynapseSettingData(_ synapseId: String) -> [String: Any]? {

        var res: [String: Any]? = nil
        if synapseId.count > 0, let baseData = userDefaults.object(forKey: self.settingSynapsesKey) as? [String: Any], let data = baseData[synapseId] as? [String: Any] {
            res = data
        }
        //print("getSynapseSettingData: \(res)")
        return res
    }

    func setSynapseSettingData(_ synapseId: String, data: [String: Any]) {

        if synapseId.count <= 0 {
            return
        }

        var baseData: [String: Any] = [:]
        if let dic = userDefaults.object(forKey: self.settingSynapsesKey) as? [String: Any] {
            baseData = dic
        }
        baseData[synapseId] = data
        userDefaults.set(baseData, forKey: self.settingSynapsesKey)
    }
}
