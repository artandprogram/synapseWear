//
//  AccessKeysFileManager.swift
//  synapsewear
//
//  Copyright © 2018年 art and program, Inc. For license and other information refer to https://github.com/artandprogram/synapseWear. All rights reserved.
//

import UIKit

class AccessKeysFileManager: BaseFileManager {

    let fileName: String = "access_keys"
    let uuidKey: String = "uuid"
    let accessDataKey: String = "access_key"
    let dateKey: String = "date"

    override init() {
        super.init()

        self.baseDirType = "documents"
        self.baseDirName = ""
        self.setBaseDir()
    }

    func getAccessKeysData() -> [Any]? {

        var res: [Any]? = nil
        if let data = self.getData(fileName: self.fileName) {
            if let arr = NSKeyedUnarchiver.unarchiveObject(with: data) as? [Any] {
                res = arr
            }
        }
        return res
    }

    func getLatestUUID() -> UUID? {

        var uuidNow: UUID? = nil
        if let accessKeys = self.getAccessKeysData() {
            var dateNow: Date? = nil
            for accessKey in accessKeys {
                if let accessKey = accessKey as? [String: Any], let uuid = accessKey[self.uuidKey] as? UUID {
                    var date: Date? = nil
                    if let value = accessKey[self.dateKey] as? Date {
                        date = value
                    }

                    var flag: Bool = false
                    if uuidNow == nil {
                        flag = true
                    }
                    else if date != nil {
                        if dateNow == nil || date! > dateNow! {
                            flag = true
                        }
                    }
                    if flag {
                        uuidNow = uuid
                        dateNow = date
                    }
                }
            }
        }
        return uuidNow
    }

    func getAccessKey(_ uuid: UUID) -> Data? {

        var res: Data? = nil
        if let accessKeys = self.getAccessKeysData() {
            for accessKey in accessKeys {
                if let accessKey = accessKey as? [String: Any], let uuidVal = accessKey[self.uuidKey] as? UUID, uuidVal == uuid {
                    if let accessKeyData = accessKey[self.accessDataKey] as? Data {
                        res = accessKeyData
                    }
                    break
                }
            }
        }
        return res
    }

    func setAccessKey(_ uuid: UUID, accessKey: Data) -> Bool {

        var accessKeys: [Any] = []
        if let data = self.getAccessKeysData() {
            accessKeys = data
        }
        var pt: Int = accessKeys.count
        for (index, element) in accessKeys.enumerated() {
            if let accessKeyData = element as? [String: Any], let uuidVal = accessKeyData[self.uuidKey] as? UUID, uuidVal == uuid {
                pt = index
                break
            }
        }
        if pt < accessKeys.count {
            accessKeys[pt] = [self.uuidKey: uuid, self.accessDataKey: accessKey, self.dateKey: Date()]
        }
        else {
            accessKeys.append([self.uuidKey: uuid, self.accessDataKey: accessKey, self.dateKey: Date()])
        }
        //print("setAccessKey: \(accessKeys)")

        return self.setData(fileName: self.fileName, data: NSKeyedArchiver.archivedData(withRootObject: accessKeys))
    }

    func setConnectedDate(_ uuid: UUID) -> Bool {

        var accessKeys: [Any] = []
        if let arr = self.getAccessKeysData() {
            accessKeys = arr
        }
        var data: [String: Any] = [:]
        var pt: Int = -1
        for (index, element) in accessKeys.enumerated() {
            if let accessKeyData = element as? [String: Any], let uuidVal = accessKeyData[self.uuidKey] as? UUID, uuidVal == uuid {
                data = accessKeyData
                pt = index
                break
            }
        }
        data[self.uuidKey] = uuid
        data[self.dateKey] = Date()

        if pt >= 0 && pt < accessKeys.count {
            accessKeys[pt] = data
        }
        else {
            accessKeys.append(data)
        }

        return self.setData(fileName: self.fileName, data: NSKeyedArchiver.archivedData(withRootObject: accessKeys))
    }
}
