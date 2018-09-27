//
//  BaseFileManager.swift
//  synapsewear
//
//  Copyright © 2017年 art and program, Inc. For license and other information refer to https://github.com/artandprogram/synapseWear. All rights reserved.
//

import UIKit

class BaseFileManager: NSObject {

    var baseDirType: String = "caches"
    var baseDirName: String = ""
    var baseDirPath: String = ""

    func setBaseDir() {

        if self.baseDirType == "caches" {
            self.baseDirPath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
        }
        else if self.baseDirType == "documents" {
            self.baseDirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        }
        else if self.baseDirType == "tmp" {
            self.baseDirPath = NSTemporaryDirectory()
        }

        if self.baseDirPath.count > 0 && self.baseDirName.count > 0 {
            self.baseDirPath = "\(self.baseDirPath)/\(self.baseDirName)"

            let fileManager: FileManager = FileManager()
            var isDir: ObjCBool = false
            let exists: Bool = fileManager.fileExists(atPath: self.baseDirPath, isDirectory: &isDir)
            if !exists || !isDir.boolValue {
                print("setBaseDir : \(self.baseDirPath)")
                do {
                    try fileManager.createDirectory(atPath: self.baseDirPath ,withIntermediateDirectories: true, attributes: nil)
                }
                catch {
                }
            }
        }
    }

    public func getData(fileName: String) -> Data? {

        let filePath: String = "\(self.baseDirPath)/\(fileName)"
        let fileManager: FileManager = FileManager()
        var isDir: ObjCBool = false
        let exists: Bool = fileManager.fileExists(atPath: filePath, isDirectory: &isDir)
        if exists && !isDir.boolValue {
            let dataURL = URL(fileURLWithPath: filePath)
            do {
                return try Data(contentsOf: dataURL, options: [])
            }
            catch {
                return nil
            }
        }
        return nil
    }

    public func setData(fileName: String, data: Data) -> Bool {

        let filePath: String = "\(self.baseDirPath)/\(fileName)"
        let fileManager: FileManager = FileManager()
        var isDir: ObjCBool = false
        let exists: Bool = fileManager.fileExists(atPath: filePath, isDirectory: &isDir)
        if !exists || isDir.boolValue {
            if exists && isDir.boolValue {
                do {
                    try fileManager.removeItem(atPath: filePath)
                }
                catch {
                    return false
                }
            }
            return fileManager.createFile(atPath: filePath, contents: data, attributes: nil)
        }
        else {
            let dataURL = URL(fileURLWithPath: filePath)
            do {
                try data.write(to: dataURL)
            }
            catch {
                return false
            }
            return true
        }
    }

}
