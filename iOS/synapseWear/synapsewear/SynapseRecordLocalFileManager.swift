//
//  SynapseRecordLocalFileManager.swift
//  synapsewear
//
//  Copyright © 2021 art and program, Inc. For license and other information refer to https://github.com/artandprogram/synapseWear. All rights reserved.
//

import UIKit

class SynapseRecordLocalFileManager: BaseFileManager {

    let limitSize: UInt64 = 1024 * 1024
    var connectDate: Date?

    override init() {
        super.init()

        self.baseDirType = "documents"
        self.baseDirName = "synapse_datafiles"
        self.setBaseDir()
    }

    func setSynapseId(_ synapseId: String) {

        self.setBaseDir()

        if synapseId.count > 0 {
            self.baseDirPath = "\(self.baseDirPath)/\(synapseId)"
            _ = self.self.createDirectory(self.baseDirPath)
        }
    }

    func setValues(_ data: Data) -> Bool {

        var filePath: URL? = URL(fileURLWithPath: self.baseDirPath)
        var isDir: ObjCBool = false
        var exists: Bool = FileManager.default.fileExists(atPath: filePath!.path, isDirectory: &isDir)
        if !exists || !isDir.boolValue {
            return false
        }

        guard let date = self.connectDate else {
            return false
        }
        let dayFormatter: DateFormatter = DateFormatter()
        dayFormatter.locale = Locale(identifier: "en_US_POSIX")
        dayFormatter.dateFormat = "yyyyMMdd"
        let day: String = dayFormatter.string(from: date)
        filePath = filePath!.appendingPathComponent(day)
        exists = FileManager.default.fileExists(atPath: filePath!.path, isDirectory: &isDir)
        if !exists || !isDir.boolValue {
            if exists && !isDir.boolValue {
                do {
                    try FileManager.default.removeItem(atPath: filePath!.path)
                }
                catch {
                    return false
                }
            }
            do {
                try FileManager.default.createDirectory(atPath: filePath!.path,
                                                        withIntermediateDirectories: true,
                                                        attributes: nil)
            }
            catch {
                return false
            }
        }

        let filename: String = self.getFilename(date: date)
        filePath = filePath!.appendingPathComponent(filename)
        var output: OutputStream? = OutputStream(toFileAtPath: filePath!.path, append: true)
        output?.open()
        let _ = data.withUnsafeBytes { output?.write($0, maxLength: data.count) }
        output?.close()
        output = nil
        filePath = nil
        /*
        if let str = String(data: data, encoding: .utf8) {
            print("setLocalFile: \(filename) -> \(str)")
        }*/

        return true
    }

    func getFilename(date: Date) -> String {

        let fileNameBase: String = "\(date.timeIntervalSince1970)"
        var fileName: String = fileNameBase
        var count: Int = 0

        var files: [String]? = nil
        do {
            files = try FileManager.default.contentsOfDirectory(atPath: self.baseDirPath)
            files!.sort { $1 < $0 }
        }
        catch {
        }

        if let files = files, files.count > 0, let firstFile = files.first {
            if fileName != firstFile, let _ = firstFile.range(of: fileName) {
                fileName = firstFile
                var parts: [String]? = firstFile.components(separatedBy: ".")
                if let part = parts?.last, let value = Int(part) {
                    count = value
                }
                parts = nil
            }
        }
        files = nil

        do {
            let size: UInt64 = try self.findSize(path: "\(self.baseDirPath)/\(fileName)")
            if size > self.limitSize {
                fileName = "\(fileNameBase).\(count + 1)"
            }
        }
        catch {
        }

        return fileName
    }

    func findSize(path: String) throws -> UInt64 {

        let fullPath: String = (path as NSString).expandingTildeInPath
        let fileAttributes: NSDictionary = try FileManager.default.attributesOfItem(atPath: fullPath) as NSDictionary

        if fileAttributes.fileType() == "NSFileTypeRegular" {
            return fileAttributes.fileSize()
        }

        let url: URL = URL(fileURLWithPath: fullPath)
        guard let directoryEnumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: [URLResourceKey.fileSizeKey], options: [.skipsHiddenFiles], errorHandler: nil) else { throw FileErrors.BadEnumeration }

        var total: UInt64 = 0
        for (index, object) in directoryEnumerator.enumerated() {
            guard let fileURL = object as? NSURL else { throw FileErrors.BadResource }
            var fileSizeResource: AnyObject?
            try fileURL.getResourceValue(&fileSizeResource, forKey: URLResourceKey.fileSizeKey)
            guard let fileSize = fileSizeResource as? NSNumber else { continue }
            total += fileSize.uint64Value
            if index % 1000 == 0 {
                print(".", terminator: "")
            }
        }

        /*if total < 1048576 {
            total = 1
        }
        else {
            total = UInt64(total / 1048576)
        }*/

        return total
    }
}
