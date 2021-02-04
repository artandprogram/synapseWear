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
                    print("SynapseRecordLocalFileManager setValues error: \(error.localizedDescription)")
                    return false
                }
            }
            do {
                try FileManager.default.createDirectory(atPath: filePath!.path,
                                                        withIntermediateDirectories: true,
                                                        attributes: nil)
            }
            catch {
                print("SynapseRecordLocalFileManager setValues error: \(error.localizedDescription)")
                return false
            }
        }

        let filename: String = self.getFilename(filePath: filePath!, date: date)
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

    func getFilename(filePath: URL, date: Date) -> String {

        let fileNameBase: String = "\(date.timeIntervalSince1970)".replacingOccurrences(of: ".", with: "_")
        let fileName: String = "\(fileNameBase).csv"
        /*
        do {
           let contents = try FileManager.default.contentsOfDirectory(at: filePath,
                                                                      includingPropertiesForKeys: [.contentModificationDateKey],
                                                                      options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants])
            .sorted(by: {
                let date0 = try $0.promisedItemResourceValues(forKeys:[.contentModificationDateKey]).contentModificationDate!
                let date1 = try $1.promisedItemResourceValues(forKeys:[.contentModificationDateKey]).contentModificationDate!
                return date0.compare(date1) == .orderedDescending
            })

            if contents.count > 0 {
                /*if let t = try? contents[0].promisedItemResourceValues(forKeys:[.contentModificationDateKey]).contentModificationDate {
                    print ("\(t), \(contents[0].lastPathComponent)")
                }*/

                var count: Int = 0
                let firstFile: String = contents[0].lastPathComponent
                if fileName != firstFile, let _ = firstFile.range(of: fileNameBase) {
                    fileName = firstFile
                    var parts: [String]? = firstFile.components(separatedBy: ".")
                    if let parts = parts, parts.count > 2, let _count = Int(parts[1]) {
                        count = _count
                    }
                    parts = nil
                }

                var path: String = filePath.appendingPathComponent(fileName).absoluteString
                if let pathRange = path.range(of: "file://") {
                    path.replaceSubrange(pathRange, with: "")
                    //print("setLocalFile: \(path)")
                    let size: UInt64 = try self.findSize(path: path)
                    //print("setLocalFile: \(fileName) -> \(size)")
                    if size > self.limitSize {
                        fileName = "\(fileNameBase).\(count + 1).csv"
                    }
                }
            }
        }
        catch {
            //print(error)
        }
         */
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
