//
//  BaseFileManager.swift
//  synapsewear
//
//  Copyright © 2017 art and program, Inc. For license and other information refer to https://github.com/artandprogram/synapseWear. All rights reserved.
//

import UIKit

class BaseFileManager: NSObject, CommonFunctionProtocol {

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

            var isDir: ObjCBool = false
            let exists: Bool = FileManager.default.fileExists(atPath: self.baseDirPath, isDirectory: &isDir)
            if !exists || !isDir.boolValue {
                print("setBaseDir : \(self.baseDirPath)")
                do {
                    try FileManager.default.createDirectory(atPath: self.baseDirPath, withIntermediateDirectories: true, attributes: nil)
                }
                catch {
                }
            }
        }
    }

    func getData(fileName: String) -> Data? {

        let filePath: String = "\(self.baseDirPath)/\(fileName)"
        var isDir: ObjCBool = false
        let exists: Bool = FileManager.default.fileExists(atPath: filePath, isDirectory: &isDir)
        if exists, !isDir.boolValue {
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

    func setData(fileName: String, data: Data) -> Bool {

        let filePath: String = "\(self.baseDirPath)/\(fileName)"
        var isDir: ObjCBool = false
        let exists: Bool = FileManager.default.fileExists(atPath: filePath, isDirectory: &isDir)
        if !exists || isDir.boolValue {
            if exists, isDir.boolValue {
                do {
                    try FileManager.default.removeItem(atPath: filePath)
                }
                catch {
                    return false
                }
            }
            return FileManager.default.createFile(atPath: filePath, contents: data, attributes: nil)
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

    func createDirectory(_ filePath: String) -> Bool {

        //log("CreateD: \(filePath)")
        var isDir: ObjCBool = false
        let exists: Bool = FileManager.default.fileExists(atPath: filePath, isDirectory: &isDir)
        if !exists || !isDir.boolValue {
            if exists, !isDir.boolValue {
                do {
                    try FileManager.default.removeItem(atPath: filePath)
                }
                catch {
                    return false
                }
            }

            do {
                try FileManager.default.createDirectory(atPath: filePath,
                                                        withIntermediateDirectories: true,
                                                        attributes: nil)
            }
            catch {
                return false
            }
        }
        return true
    }

    func createFile(_ filePath: String) -> Bool {

        //log("CreateF: \(filePath)")
        var isDir: ObjCBool = false
        let exists: Bool = FileManager.default.fileExists(atPath: filePath, isDirectory: &isDir)
        if !exists || isDir.boolValue {
            if exists, isDir.boolValue {
                do {
                    try FileManager.default.removeItem(atPath: filePath)
                }
                catch {
                    return false
                }
            }
            return FileManager.default.createFile(atPath: filePath, contents: Data(), attributes: nil)
        }
        return true
    }

    func fileExists(_ filePath: String, isDirectory: Bool = false) -> Bool {

        /*if isDirectory {
            log("ExistsC: \(filePath)")
        }
        else {
            log("ExistsF: \(filePath)")
        }*/
        var isDir: ObjCBool = false
        if FileManager.default.fileExists(atPath: filePath, isDirectory: &isDir) {
            if isDirectory {
                if isDir.boolValue {
                    return true
                }
            }
            else {
                if !isDir.boolValue {
                    return true
                }
            }
        }
        return false
    }

    func contentsOfDirectory(_ filePath: String) throws -> [String] {

        //log("ContentsOfD: \(filePath)")
        var files: [String] = []
        var isDir: ObjCBool = false
        let exists: Bool = FileManager.default.fileExists(atPath: filePath, isDirectory: &isDir)
        if exists, isDir.boolValue {
            files = try FileManager.default.contentsOfDirectory(atPath: filePath)
            files.sort { $1 < $0 }
        }
        return files
    }
}
