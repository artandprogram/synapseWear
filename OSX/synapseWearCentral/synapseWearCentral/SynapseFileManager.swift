//
//  SynapseFileManager.swift
//  synapseWearCentral
//
//  Copyright © 2018年 art and program, Inc. For license and other information refer to https://github.com/artandprogram/synapseWear. All rights reserved.
//

import Cocoa

class SynapseFileManager: NSObject {

    let fileManager: FileManager = FileManager()

    func dirCheck(baseURL: URL, uuid: String) -> Bool {

        var res: Bool = false
        var filePath: URL = baseURL
        var isDir: ObjCBool = false
        var exists: Bool = self.fileManager.fileExists(atPath: filePath.path, isDirectory: &isDir)
        if exists && isDir.boolValue {
            filePath = filePath.appendingPathComponent(uuid)
            exists = self.fileManager.fileExists(atPath: filePath.path, isDirectory: &isDir)
            if !exists {
                do {
                    try self.fileManager.createDirectory(atPath: filePath.path, withIntermediateDirectories: true, attributes: nil)
                    print("createDirectory: \(filePath.path)")
                    res = true
                }
                catch let error as NSError {
                    print(error.localizedDescription)
                    print("failed createDirectory: \(filePath.path)")
                    res = false
                }
            }
            else {
                if isDir.boolValue {
                    res = true
                }
                else {
                    res = false
                }
            }
        }
        return res
    }

    func setValues(baseURL: URL, uuid: String, values: Data, date: Date) -> Bool {

        let dayFormatter: DateFormatter = DateFormatter()
        dayFormatter.locale = Locale(identifier: "en_US_POSIX")
        dayFormatter.dateFormat = "yyyyMMdd"
        let day: String = dayFormatter.string(from: date)

        var filePath: URL = baseURL.appendingPathComponent(uuid)
        var isDir: ObjCBool = false
        var exists: Bool = self.fileManager.fileExists(atPath: filePath.path, isDirectory: &isDir)
        if !exists || !isDir.boolValue {
            return false
        }

        filePath = filePath.appendingPathComponent(day)
        exists = self.fileManager.fileExists(atPath: filePath.path, isDirectory: &isDir)
        if !exists || !isDir.boolValue {
            if exists && !isDir.boolValue {
                do {
                    try fileManager.removeItem(atPath: filePath.path)
                }
                catch {
                    return false
                }
            }
            do {
                try fileManager.createDirectory(atPath: filePath.path, withIntermediateDirectories: true, attributes: nil)
            }
            catch {
                return false
            }
        }

        let filename: String = "\(date.timeIntervalSince1970)"
        filePath = filePath.appendingPathComponent(filename)
        //print("setValues: \(date) \(filename)" )
        //print("setValues: \([UInt8](values))" )
        let fileURL = URL(fileURLWithPath: filePath.path)
        do {
            try values.write(to: fileURL)
        }
        catch {
            return false
        }
        return true
    }
}
