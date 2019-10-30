//
//  SynapseRecordFileManager.swift
//  synapsewear
//
//  Copyright © 2017年 art and program, Inc. For license and other information refer to https://github.com/artandprogram/synapseWear. All rights reserved.
//

import UIKit

class SynapseRecordFileManager: BaseFileManager {

    // const variables
    let connectLogDir: String = "connect_log"
    let valuesDir: String = "values"
    let sendDir: String = "send"

    override init() {
        super.init()

        self.baseDirType = "documents"
        self.baseDirName = "synapse_record"
        self.setBaseDir()
    }

    func setSynapseId(_ synapseId: String) {

        self.setBaseDir()

        if synapseId.count > 0 {
            self.baseDirPath = "\(self.baseDirPath)/\(synapseId)"

            let fileManager: FileManager = FileManager.default
            var isDir: ObjCBool = false
            let exists: Bool = fileManager.fileExists(atPath: self.baseDirPath, isDirectory: &isDir)
            if !exists || !isDir.boolValue {
                do {
                    try fileManager.createDirectory(atPath: self.baseDirPath ,withIntermediateDirectories: true, attributes: nil)
                }
                catch {
                }
            }
        }
        //print("SynapseRecordFileManager setSynapseId: \(self.baseDirPath)")
    }

    func getSynapseRecords(day: String? = nil, type: String? = nil) -> [String] {

        var res: [String] = []
        var filePath: String = self.baseDirPath
        if let dirName = day {
            if dirName.count > 0 {
                filePath = "\(filePath)/\(dirName)"

                if let dirName = type {
                    if dirName.count > 0 {
                        filePath = "\(filePath)/\(dirName)"
                    }
                }
            }
        }
        let fileManager: FileManager = FileManager.default
        do {
            try res = fileManager.contentsOfDirectory(atPath: filePath)
        }
        catch {
        }
        return res.sorted { $1 < $0 }
    }

    func setSynapseRecord(day: String, time: String, fileName: String) -> Bool {

        if day.count <= 0 || time.count <= 0 || fileName.count <= 0 {
            return false
        }

        var filePath: String = "\(self.baseDirPath)/\(day)"
        //print("save synapse -> \(filePath)" )
        let fileManager: FileManager = FileManager.default
        var isDir: ObjCBool = false
        var exists: Bool = fileManager.fileExists(atPath: filePath, isDirectory: &isDir)
        if !exists || !isDir.boolValue {
            //print("save synapse -> no exist \(exists) \(isDir)" )
            if exists && !isDir.boolValue {
                do {
                    try fileManager.removeItem(atPath: filePath)
                }
                catch {
                    //print("save synapse -> removeItem error" )
                    return false
                }
            }
            //print("save synapse -> make dir" )
            do {
                try fileManager.createDirectory(atPath: filePath, withIntermediateDirectories: true, attributes: nil)
            }
            catch {
                //print("save synapse -> make dir error" )
                return false
            }
        }

        filePath = "\(filePath)/\(time)"
        //print("save synapse -> \(filePath)" )
        exists = fileManager.fileExists(atPath: filePath, isDirectory: &isDir)
        if !exists || !isDir.boolValue {
            //print("save synapse -> no exist \(exists) \(isDir)" )
            if exists && !isDir.boolValue {
                do {
                    try fileManager.removeItem(atPath: filePath)
                }
                catch {
                    //print("save synapse -> removeItem error" )
                    return false
                }
            }
            //print("save synapse -> make dir" )
            do {
                try fileManager.createDirectory(atPath: filePath, withIntermediateDirectories: true, attributes: nil)
            }
            catch {
                //print("save synapse -> make dir error" )
                return false
            }
        }

        filePath = "\(filePath)/\(fileName)"
        //print("save synapse -> \(filePath)" )
        exists = fileManager.fileExists(atPath: filePath, isDirectory: &isDir)
        if !exists || isDir.boolValue {
            if exists && isDir.boolValue {
                do {
                    try fileManager.removeItem(atPath: filePath)
                }
                catch {
                    return false
                }
            }
            return fileManager.createFile(atPath: filePath, contents: Data(), attributes: nil)
        }
        return true
    }

    func existsSynapseRecord(day: String?, hour: String?, min: String?, sec: String?, type: String?) -> Bool {

        var res: Bool = false
        var filePath: String = ""
        if day != nil && day!.count > 0 {
            filePath = "\(self.baseDirPath)/\(day!)"
            if type != nil && type!.count > 0 {
                filePath = "\(filePath)/\(type!)"
                if hour != nil && hour!.count > 0 {
                    filePath = "\(filePath)/\(hour!)"
                    if min != nil && min!.count > 0 {
                        filePath = "\(filePath)/\(min!)"
                        if sec != nil {
                            if let secVal = Int(sec!) {
                                filePath = "\(filePath)/00_\(String(Int(secVal / 10)))"
                            }
                        }
                    }
                }
            }
        }

        if filePath.count > 0 {
            let fileManager: FileManager = FileManager.default
            var isDir: ObjCBool = false
            let exists: Bool = fileManager.fileExists(atPath: filePath, isDirectory: &isDir)
            if exists && isDir.boolValue {
                res = true
            }
        }
        return res
    }

    func getSynapseRecordTotal(day: String, hour: String, min: String, sec: String?, type: String) -> [Double] {

        let res: [Double] = []
        if day.count <= 0 || hour.count <= 0 || min.count <= 0 || type.count <= 0 {
            return res
        }

        var filePath: String = "\(self.baseDirPath)/\(day)/\(type)/\(hour)/\(min)"
        if sec != nil {
            if let secVal = Int(sec!) {
                filePath = "\(self.baseDirPath)/\(day)/\(type)/\(hour)/\(min)/00_\(String(Int(secVal / 10)))"
            }
            else {
                filePath = ""
            }
        }

        if filePath.count > 0 {
            let fileManager: FileManager = FileManager.default
            var isDir: ObjCBool = false
            let exists: Bool = fileManager.fileExists(atPath: filePath, isDirectory: &isDir)
            if exists && isDir.boolValue {
                var files: [String] = []
                do {
                    try files = fileManager.contentsOfDirectory(atPath: filePath)
                }
                catch {
                    return res
                }
                files.sort { $1 < $0 }

                if files.count > 0 {
                    let file: String = files[0]
                    let arr: [String] = file.components(separatedBy: "_")
                    if arr.count > 1 {
                        if let cnt = Double(arr[0]), let total = Double(arr[1]) {
                            return [cnt, total]
                        }
                    }
                }
            }
        }
        return res
    }

    func setSynapseRecordTotal(_ value: Double, day: String, hour: String, min: String, sec: String, type: String) -> Bool {

        if day.count <= 0 || hour.count <= 0 || min.count <= 0 || sec.count <= 0 || type.count <= 0 {
            return false
        }

        var filePath: String = "\(self.baseDirPath)/\(day)"
        let fileManager: FileManager = FileManager.default
        var isDir: ObjCBool = false
        var exists: Bool = fileManager.fileExists(atPath: filePath, isDirectory: &isDir)
        if !exists || !isDir.boolValue {
            //print("save synapse -> no exist \(exists) \(isDir)" )
            if exists && !isDir.boolValue {
                do {
                    try fileManager.removeItem(atPath: filePath)
                }
                catch {
                    //print("save synapse -> removeItem error" )
                    return false
                }
            }
            //print("save synapse -> make dir" )
            do {
                try fileManager.createDirectory(atPath: filePath, withIntermediateDirectories: true, attributes: nil)
            }
            catch {
                //print("save synapse -> make dir error" )
                return false
            }
        }

        filePath = "\(filePath)/\(type)"
        exists = fileManager.fileExists(atPath: filePath, isDirectory: &isDir)
        if !exists || !isDir.boolValue {
            if exists && !isDir.boolValue {
                do {
                    try fileManager.removeItem(atPath: filePath)
                }
                catch {
                    return false
                }
            }
            do {
                try fileManager.createDirectory(atPath: filePath, withIntermediateDirectories: true, attributes: nil)
            }
            catch {
                return false
            }
        }

        filePath = "\(filePath)/\(hour)"
        exists = fileManager.fileExists(atPath: filePath, isDirectory: &isDir)
        if !exists || !isDir.boolValue {
            if exists && !isDir.boolValue {
                do {
                    try fileManager.removeItem(atPath: filePath)
                }
                catch {
                    return false
                }
            }
            do {
                try fileManager.createDirectory(atPath: filePath, withIntermediateDirectories: true, attributes: nil)
            }
            catch {
                return false
            }
        }

        var cnt: Int = 0
        var total: Double = 0
        filePath = "\(filePath)/\(min)"
        exists = fileManager.fileExists(atPath: filePath, isDirectory: &isDir)
        if !exists || !isDir.boolValue {
            if exists && !isDir.boolValue {
                do {
                    try fileManager.removeItem(atPath: filePath)
                }
                catch {
                    return false
                }
            }
            do {
                try fileManager.createDirectory(atPath: filePath, withIntermediateDirectories: true, attributes: nil)
            }
            catch {
                return false
            }
        }
        else {
            var files: [String] = []
            do {
                try files = fileManager.contentsOfDirectory(atPath: filePath)
            }
            catch {
                return false
            }
            files.sort { $1 < $0 }

            if files.count > 0 {
                let file: String = files[0]
                let arr: [String] = file.components(separatedBy: "_")
                if arr.count > 1 {
                    if let cntVal = Int(arr[0]), let totalVal = Double(arr[1]) {
                        cnt = cntVal
                        total = totalVal
                    }
                }
            }
        }
        cnt += 1
        total += value

        var totalFileName: String = "\(String(format:"%02d", cnt))_\(String(total))"
        if !fileManager.createFile(atPath: "\(filePath)/\(totalFileName)", contents: Data(), attributes: nil) {
            return false
        }

        cnt = 0
        total = 0
        filePath = "\(filePath)/00_\(sec)"
        exists = fileManager.fileExists(atPath: filePath, isDirectory: &isDir)
        if !exists || !isDir.boolValue {
            if exists && !isDir.boolValue {
                do {
                    try fileManager.removeItem(atPath: filePath)
                }
                catch {
                    return false
                }
            }
            do {
                try fileManager.createDirectory(atPath: filePath, withIntermediateDirectories: true, attributes: nil)
            }
            catch {
                return false
            }
        }
        else {
            var files: [String] = []
            do {
                try files = fileManager.contentsOfDirectory(atPath: filePath)
            }
            catch {
                return false
            }
            if files.count > 0 {
                files.sort { $1 < $0 }

                let file: String = files[0]
                let arr: [String] = file.components(separatedBy: "_")
                if arr.count > 1 {
                    if let cntVal = Int(arr[0]), let totalVal = Double(arr[1]) {
                        cnt = cntVal
                        total = totalVal
                    }
                }
            }
        }
        cnt += 1
        total += value

        totalFileName = "\(String(format:"%02d", cnt))_\(String(total))"
        if !fileManager.createFile(atPath: "\(filePath)/\(totalFileName)", contents: Data(), attributes: nil) {
            return false
        }
        return true
    }

    func getSynapseRecordTotalIn10min(day: String, hour: String, min: Int, type: String, isSave: Bool) -> Double? {

        var res: Double? = nil
        //var res: Double = 0
        if day.count <= 0 || hour.count <= 0 || type.count <= 0 {
            return res
        }

        var filePath: String = "\(self.baseDirPath)/\(day)"
        let fileManager: FileManager = FileManager.default
        var isDir: ObjCBool = false
        var exists: Bool = fileManager.fileExists(atPath: filePath, isDirectory: &isDir)
        if !exists || !isDir.boolValue {
            return res
        }

        filePath = "\(filePath)/\(type)"
        exists = fileManager.fileExists(atPath: filePath, isDirectory: &isDir)
        if !exists || !isDir.boolValue {
            return res
        }

        filePath = "\(filePath)/\(hour)"
        exists = fileManager.fileExists(atPath: filePath, isDirectory: &isDir)
        if !exists || !isDir.boolValue {
            return res
        }

        var filePath10min: String = "\(filePath)/10min"
        exists = fileManager.fileExists(atPath: filePath10min, isDirectory: &isDir)
        if !exists || !isDir.boolValue {
            if exists && !isDir.boolValue {
                do {
                    try fileManager.removeItem(atPath: filePath10min)
                }
                catch {
                    return res
                }
            }
            if isSave {
                do {
                    try fileManager.createDirectory(atPath: filePath10min, withIntermediateDirectories: true, attributes: nil)
                }
                catch {
                    return res
                }
            }
        }

        filePath10min = "\(filePath10min)/\(min)"
        exists = fileManager.fileExists(atPath: filePath10min, isDirectory: &isDir)
        if !exists || !isDir.boolValue {
            if exists && !isDir.boolValue {
                do {
                    try fileManager.removeItem(atPath: filePath10min)
                }
                catch {
                    return res
                }
            }
            if isSave {
                do {
                    try fileManager.createDirectory(atPath: filePath10min, withIntermediateDirectories: true, attributes: nil)
                }
                catch {
                    return res
                }
            }
        }
        else {
            var files: [String] = []
            do {
                try files = fileManager.contentsOfDirectory(atPath: filePath10min)
                //files.sort { $1 < $0 }
            }
            catch {
                files = []
            }
            if files.count > 0 {
                if let value = Double(files[0]) {
                    return value
                }
            }
        }

        var cnt: Int = 0
        var total: Double = 0
        for i in min * 10..<(min + 1) * 10 {
            let minStr: String = String(format:"%02d", i)
            let minPath: String = "\(filePath)/\(minStr)"
            var files: [String] = []
            do {
                try files = fileManager.contentsOfDirectory(atPath: minPath)
                files.sort { $1 < $0 }
            }
            catch {
                files = []
            }

            if files.count > 0 {
                let file: String = files[0]
                let arr: [String] = file.components(separatedBy: "_")
                if arr.count > 1 {
                    if let cntVal = Int(arr[0]), let totalVal = Double(arr[1]) {
                        cnt += cntVal
                        total += totalVal
                    }
                }
            }
        }
        if cnt > 0 {
            res = total / Double(cnt)
        }

        if isSave && res != nil {
            let totalFileName: String = String(res!)
            if fileManager.createFile(atPath: "\(filePath10min)/\(totalFileName)", contents: Data(), attributes: nil) {
                //print("make SynapseRecordTotalIn10min: \(filePath10min)/\(totalFileName)")
                //return res
            }
        }
        return res
    }

    func getSynapseRecordTotalInHour(day: String, hour: String, type: String, isSave: Bool) -> Double? {

        var res: Double? = nil
        if day.count <= 0 || hour.count <= 0 || type.count <= 0 {
            return res
        }

        var filePath: String = "\(self.baseDirPath)/\(day)"
        let fileManager: FileManager = FileManager.default
        var isDir: ObjCBool = false
        var exists: Bool = fileManager.fileExists(atPath: filePath, isDirectory: &isDir)
        if !exists || !isDir.boolValue {
            return res
        }

        filePath = "\(filePath)/\(type)"
        exists = fileManager.fileExists(atPath: filePath, isDirectory: &isDir)
        if !exists || !isDir.boolValue {
            return res
        }

        filePath = "\(filePath)/\(hour)"
        exists = fileManager.fileExists(atPath: filePath, isDirectory: &isDir)
        if !exists || !isDir.boolValue {
            return res
        }

        filePath = "\(filePath)/1hour"
        exists = fileManager.fileExists(atPath: filePath, isDirectory: &isDir)
        if !exists || !isDir.boolValue {
            if exists && !isDir.boolValue {
                do {
                    try fileManager.removeItem(atPath: filePath)
                }
                catch {
                    return res
                }
            }
            if isSave {
                do {
                    try fileManager.createDirectory(atPath: filePath, withIntermediateDirectories: true, attributes: nil)
                }
                catch {
                    return res
                }
            }
        }
        else {
            var files: [String] = []
            do {
                try files = fileManager.contentsOfDirectory(atPath: filePath)
                //files.sort { $1 < $0 }
            }
            catch {
                files = []
            }
            if files.count > 0 {
                if let value = Double(files[0]) {
                    return value
                }
            }
        }
        
        var cnt: Int = 0
        var total: Double = 0
        for i in 0..<6 {
            let value: Double? = self.getSynapseRecordTotalIn10min(day: day, hour: hour, min: i, type: type, isSave: isSave)
            if let val = value, val > 0 {
                cnt += 1
                total += val
            }
        }
        if cnt > 0 {
            res = total / Double(cnt)
        }

        if isSave && res != nil {
            let totalFileName: String = String(res!)
            if fileManager.createFile(atPath: "\(filePath)/\(totalFileName)", contents: Data(), attributes: nil) {
                //print("make SynapseRecordTotalInHour: \(filePath)/\(totalFileName)")
            }
        }
        return res
    }

    func setSynapseRecordTotalInHour(type: String, start: Date? = nil) {

        let dayFormatter: DateFormatter = DateFormatter()
        dayFormatter.locale = Locale(identifier: "en_US_POSIX")
        dayFormatter.dateFormat = "yyyyMMdd"
        let hourFormatter: DateFormatter = DateFormatter()
        hourFormatter.locale = Locale(identifier: "en_US_POSIX")
        hourFormatter.dateFormat = "HH"
        let minFormatter: DateFormatter = DateFormatter()
        minFormatter.locale = Locale(identifier: "en_US_POSIX")
        minFormatter.dateFormat = "mm"

        let date: Date = Date()
        let dateD: String = dayFormatter.string(from: date)
        let dateH: String = hourFormatter.string(from: date)
        let dateM: String = minFormatter.string(from: date)
        var startD: String?
        var startH: String?
        var startM: String?
        if let start = start {
            startD = dayFormatter.string(from: start)
            startH = hourFormatter.string(from: start)
            startM = minFormatter.string(from: start)
        }

        let fileManager: FileManager = FileManager.default
        var files: [String] = []
        do {
            try files = fileManager.contentsOfDirectory(atPath: self.baseDirPath)
            files.sort { $1 > $0 }
        }
        catch {
            files = []
        }
        //print("setSynapseRecordTotalInHour: \(type) -> \(startD):\(startH):\(startM) - \(dateD):\(dateH):\(dateM)")
        for (_, element) in files.enumerated() {
            if (startD == nil || element >= startD!) && element <= dateD {
                for i in 0..<24 {
                    if (startH == nil || element > startD! || i >= Int(startH!)!) && (element < dateD || i <= Int(dateH)!) {
                        for j in 0..<6 {
                            if (startM == nil || element > startD! || i > Int(startH!)! || (j + 1) * 10 >= Int(startM!)!) {
                                if element < dateD || (element == dateD && i < Int(dateH)!) {
                                    _ = self.getSynapseRecordTotalInHour(day: element, hour: String(format:"%02d", i), type: type, isSave: true)
                                }
                                else if element == dateD && i == Int(dateH)! && (j + 1) * 10 < Int(dateM)! {
                                    _ = self.getSynapseRecordTotalIn10min(day: element, hour: String(format:"%02d", i), min: j, type: type, isSave: true)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    func getSynapseRecordValueType(day: String, hour: String, min: String, type: String, valueType: String) -> [String] {

        let res: [String] = []
        if day.count <= 0 || hour.count <= 0 || min.count <= 0 || type.count <= 0 || valueType.count <= 0 {
            return res
        }

        let filePath: String = "\(self.baseDirPath)/\(day)/\(type)/\(valueType)/\(hour)/\(min)"
        if filePath.count > 0 {
            let fileManager: FileManager = FileManager.default
            var isDir: ObjCBool = false
            let exists: Bool = fileManager.fileExists(atPath: filePath, isDirectory: &isDir)
            if exists && isDir.boolValue {
                var files: [String] = []
                do {
                    try files = fileManager.contentsOfDirectory(atPath: filePath)
                }
                catch {
                    return res
                }
                files.sort { $1 < $0 }
                return files
            }
        }
        return res
    }

    func getSynapseRecordValueTypeIn10min(day: String, hour: String, min: Int, type: String, valueType: String) -> [String]? {

        if day.count <= 0 || hour.count <= 0 || type.count <= 0 || valueType.count <= 0 {
            return nil
        }

        let filePath: String = "\(self.baseDirPath)/\(day)/\(type)/\(valueType)/\(hour)/10min/\(min)"
        if filePath.count > 0 {
            let fileManager: FileManager = FileManager.default
            var isDir: ObjCBool = false
            let exists: Bool = fileManager.fileExists(atPath: filePath, isDirectory: &isDir)
            if exists && isDir.boolValue {
                var files: [String] = []
                do {
                    try files = fileManager.contentsOfDirectory(atPath: filePath)
                }
                catch {
                    return nil
                }
                files.sort { $1 < $0 }
                return files
            }
        }
        return nil
    }

    func getSynapseRecordValueTypeInHour(day: String, hour: String, type: String, valueType: String) -> [String]? {

        if day.count <= 0 || hour.count <= 0 || type.count <= 0 || valueType.count <= 0 {
            return nil
        }

        let filePath: String = "\(self.baseDirPath)/\(day)/\(type)/\(valueType)/\(hour)/1hour"
        if filePath.count > 0 {
            let fileManager: FileManager = FileManager.default
            var isDir: ObjCBool = false
            let exists: Bool = fileManager.fileExists(atPath: filePath, isDirectory: &isDir)
            if exists && isDir.boolValue {
                var files: [String] = []
                do {
                    try files = fileManager.contentsOfDirectory(atPath: filePath)
                }
                catch {
                    return nil
                }
                files.sort { $1 < $0 }
                return files
            }
        }
        return nil
    }

    func setSynapseRecordValueType(_ value: String, day: String, hour: String, min: String, type: String, valueType: String) -> Bool {

        if day.count <= 0 || hour.count <= 0 || min.count <= 0 || type.count <= 0 || valueType.count <= 0 {
            return false
        }

        var filePath: String = "\(self.baseDirPath)/\(day)"
        let fileManager: FileManager = FileManager.default
        var isDir: ObjCBool = false
        var exists: Bool = fileManager.fileExists(atPath: filePath, isDirectory: &isDir)
        if !exists || !isDir.boolValue {
            //print("save synapse -> no exist \(exists) \(isDir)" )
            if exists && !isDir.boolValue {
                do {
                    try fileManager.removeItem(atPath: filePath)
                }
                catch {
                    //print("save synapse -> removeItem error" )
                    return false
                }
            }
            //print("save synapse -> make dir" )
            do {
                try fileManager.createDirectory(atPath: filePath, withIntermediateDirectories: true, attributes: nil)
            }
            catch {
                //print("save synapse -> make dir error" )
                return false
            }
        }

        filePath = "\(filePath)/\(type)"
        exists = fileManager.fileExists(atPath: filePath, isDirectory: &isDir)
        if !exists || !isDir.boolValue {
            if exists && !isDir.boolValue {
                do {
                    try fileManager.removeItem(atPath: filePath)
                }
                catch {
                    return false
                }
            }
            do {
                try fileManager.createDirectory(atPath: filePath, withIntermediateDirectories: true, attributes: nil)
            }
            catch {
                return false
            }
        }

        filePath = "\(filePath)/\(valueType)"
        exists = fileManager.fileExists(atPath: filePath, isDirectory: &isDir)
        if !exists || !isDir.boolValue {
            if exists && !isDir.boolValue {
                do {
                    try fileManager.removeItem(atPath: filePath)
                }
                catch {
                    return false
                }
            }
            do {
                try fileManager.createDirectory(atPath: filePath, withIntermediateDirectories: true, attributes: nil)
            }
            catch {
                return false
            }
        }

        filePath = "\(filePath)/\(hour)"
        exists = fileManager.fileExists(atPath: filePath, isDirectory: &isDir)
        if !exists || !isDir.boolValue {
            if exists && !isDir.boolValue {
                do {
                    try fileManager.removeItem(atPath: filePath)
                }
                catch {
                    return false
                }
            }
            do {
                try fileManager.createDirectory(atPath: filePath, withIntermediateDirectories: true, attributes: nil)
            }
            catch {
                return false
            }
        }

        filePath = "\(filePath)/\(min)"
        exists = fileManager.fileExists(atPath: filePath, isDirectory: &isDir)
        if !exists || !isDir.boolValue {
            if exists && !isDir.boolValue {
                do {
                    try fileManager.removeItem(atPath: filePath)
                }
                catch {
                    return false
                }
            }
            do {
                try fileManager.createDirectory(atPath: filePath, withIntermediateDirectories: true, attributes: nil)
            }
            catch {
                return false
            }
        }

        filePath = "\(filePath)/\(value)"
        //print("save synapse -> \(filePath)" )
        exists = fileManager.fileExists(atPath: filePath, isDirectory: &isDir)
        if !exists || isDir.boolValue {
            if exists && isDir.boolValue {
                do {
                    try fileManager.removeItem(atPath: filePath)
                }
                catch {
                    return false
                }
            }
            return fileManager.createFile(atPath: filePath, contents: Data(), attributes: nil)
        }
        return true
    }

    func setSynapseRecordValueTypeIn10min(_ value: String, day: String, hour: String, min: Int, type: String, valueType: String) -> Bool {

        if day.count <= 0 || hour.count <= 0 || type.count <= 0 || valueType.count <= 0 {
            return false
        }

        var filePath: String = "\(self.baseDirPath)/\(day)"
        let fileManager: FileManager = FileManager.default
        var isDir: ObjCBool = false
        var exists: Bool = fileManager.fileExists(atPath: filePath, isDirectory: &isDir)
        if !exists || !isDir.boolValue {
            //print("save synapse -> no exist \(exists) \(isDir)" )
            if exists && !isDir.boolValue {
                do {
                    try fileManager.removeItem(atPath: filePath)
                }
                catch {
                    //print("save synapse -> removeItem error" )
                    return false
                }
            }
            //print("save synapse -> make dir" )
            do {
                try fileManager.createDirectory(atPath: filePath, withIntermediateDirectories: true, attributes: nil)
            }
            catch {
                //print("save synapse -> make dir error" )
                return false
            }
        }

        filePath = "\(filePath)/\(type)"
        exists = fileManager.fileExists(atPath: filePath, isDirectory: &isDir)
        if !exists || !isDir.boolValue {
            if exists && !isDir.boolValue {
                do {
                    try fileManager.removeItem(atPath: filePath)
                }
                catch {
                    return false
                }
            }
            do {
                try fileManager.createDirectory(atPath: filePath, withIntermediateDirectories: true, attributes: nil)
            }
            catch {
                return false
            }
        }

        filePath = "\(filePath)/\(valueType)"
        exists = fileManager.fileExists(atPath: filePath, isDirectory: &isDir)
        if !exists || !isDir.boolValue {
            if exists && !isDir.boolValue {
                do {
                    try fileManager.removeItem(atPath: filePath)
                }
                catch {
                    return false
                }
            }
            do {
                try fileManager.createDirectory(atPath: filePath, withIntermediateDirectories: true, attributes: nil)
            }
            catch {
                return false
            }
        }

        filePath = "\(filePath)/\(hour)"
        exists = fileManager.fileExists(atPath: filePath, isDirectory: &isDir)
        if !exists || !isDir.boolValue {
            if exists && !isDir.boolValue {
                do {
                    try fileManager.removeItem(atPath: filePath)
                }
                catch {
                    return false
                }
            }
            do {
                try fileManager.createDirectory(atPath: filePath, withIntermediateDirectories: true, attributes: nil)
            }
            catch {
                return false
            }
        }

        filePath = "\(filePath)/10min"
        exists = fileManager.fileExists(atPath: filePath, isDirectory: &isDir)
        if !exists || !isDir.boolValue {
            if exists && !isDir.boolValue {
                do {
                    try fileManager.removeItem(atPath: filePath)
                }
                catch {
                    return false
                }
            }
            do {
                try fileManager.createDirectory(atPath: filePath, withIntermediateDirectories: true, attributes: nil)
            }
            catch {
                return false
            }
        }

        filePath = "\(filePath)/\(min)"
        exists = fileManager.fileExists(atPath: filePath, isDirectory: &isDir)
        if !exists || !isDir.boolValue {
            if exists && !isDir.boolValue {
                do {
                    try fileManager.removeItem(atPath: filePath)
                }
                catch {
                    return false
                }
            }
            do {
                try fileManager.createDirectory(atPath: filePath, withIntermediateDirectories: true, attributes: nil)
            }
            catch {
                return false
            }
        }

        filePath = "\(filePath)/\(value)"
        //print("save synapse -> \(filePath)" )
        exists = fileManager.fileExists(atPath: filePath, isDirectory: &isDir)
        if !exists || isDir.boolValue {
            if exists && isDir.boolValue {
                do {
                    try fileManager.removeItem(atPath: filePath)
                }
                catch {
                    return false
                }
            }
            return fileManager.createFile(atPath: filePath, contents: Data(), attributes: nil)
        }
        return true
    }

    func setSynapseRecordValueTypeInHour(_ value: String, day: String, hour: String, type: String, valueType: String) -> Bool {

        if day.count <= 0 || hour.count <= 0 || type.count <= 0 || valueType.count <= 0 {
            return false
        }

        var filePath: String = "\(self.baseDirPath)/\(day)"
        let fileManager: FileManager = FileManager.default
        var isDir: ObjCBool = false
        var exists: Bool = fileManager.fileExists(atPath: filePath, isDirectory: &isDir)
        if !exists || !isDir.boolValue {
            //print("save synapse -> no exist \(exists) \(isDir)" )
            if exists && !isDir.boolValue {
                do {
                    try fileManager.removeItem(atPath: filePath)
                }
                catch {
                    //print("save synapse -> removeItem error" )
                    return false
                }
            }
            //print("save synapse -> make dir" )
            do {
                try fileManager.createDirectory(atPath: filePath, withIntermediateDirectories: true, attributes: nil)
            }
            catch {
                //print("save synapse -> make dir error" )
                return false
            }
        }

        filePath = "\(filePath)/\(type)"
        exists = fileManager.fileExists(atPath: filePath, isDirectory: &isDir)
        if !exists || !isDir.boolValue {
            if exists && !isDir.boolValue {
                do {
                    try fileManager.removeItem(atPath: filePath)
                }
                catch {
                    return false
                }
            }
            do {
                try fileManager.createDirectory(atPath: filePath, withIntermediateDirectories: true, attributes: nil)
            }
            catch {
                return false
            }
        }

        filePath = "\(filePath)/\(valueType)"
        exists = fileManager.fileExists(atPath: filePath, isDirectory: &isDir)
        if !exists || !isDir.boolValue {
            if exists && !isDir.boolValue {
                do {
                    try fileManager.removeItem(atPath: filePath)
                }
                catch {
                    return false
                }
            }
            do {
                try fileManager.createDirectory(atPath: filePath, withIntermediateDirectories: true, attributes: nil)
            }
            catch {
                return false
            }
        }

        filePath = "\(filePath)/\(hour)"
        exists = fileManager.fileExists(atPath: filePath, isDirectory: &isDir)
        if !exists || !isDir.boolValue {
            if exists && !isDir.boolValue {
                do {
                    try fileManager.removeItem(atPath: filePath)
                }
                catch {
                    return false
                }
            }
            do {
                try fileManager.createDirectory(atPath: filePath, withIntermediateDirectories: true, attributes: nil)
            }
            catch {
                return false
            }
        }

        filePath = "\(filePath)/1hour"
        exists = fileManager.fileExists(atPath: filePath, isDirectory: &isDir)
        if !exists || !isDir.boolValue {
            if exists && !isDir.boolValue {
                do {
                    try fileManager.removeItem(atPath: filePath)
                }
                catch {
                    return false
                }
            }
            do {
                try fileManager.createDirectory(atPath: filePath, withIntermediateDirectories: true, attributes: nil)
            }
            catch {
                return false
            }
        }

        filePath = "\(filePath)/\(value)"
        //print("save synapse -> \(filePath)" )
        exists = fileManager.fileExists(atPath: filePath, isDirectory: &isDir)
        if !exists || isDir.boolValue {
            if exists && isDir.boolValue {
                do {
                    try fileManager.removeItem(atPath: filePath)
                }
                catch {
                    return false
                }
            }
            return fileManager.createFile(atPath: filePath, contents: Data(), attributes: nil)
        }
        return true
    }

    func getDayDirectories() -> [String] {

        var res: [String] = []
        let fileManager: FileManager = FileManager.default
        do {
            try res = fileManager.contentsOfDirectory(atPath: self.baseDirPath)
        }
        catch {
        }
        return res.sorted { $1 < $0 }
    }

    func getConnectLogs(day: String?) -> [String] {

        var res: [String] = []
        if let day = day, day.count > 0 {
            let filePath: String = "\(self.baseDirPath)/\(day)/\(self.connectLogDir)"
            let fileManager: FileManager = FileManager.default
            do {
                try res = fileManager.contentsOfDirectory(atPath: filePath)
            }
            catch {
            }
       }
        return res.sorted { $1 < $0 }
    }

    func getConnectLastDate(_ type: String? = nil) -> Date? {

        var connectDate: Date? = nil
        let logDays: [String] = self.getDayDirectories()
        for day in logDays {
            let logs: [String] = self.getConnectLogs(day: day)
            if logs.count > 0 {
                let arr: [String] = logs[0].components(separatedBy: "_")
                if arr.count > 1, let time = Double(arr[0]) {
                    connectDate = Date(timeIntervalSince1970: time)
                    if let type = type, type != arr[1] {
                        connectDate = nil
                    }
                    break
                }
            }
        }
        return connectDate
    }

    func getConnectLogsData(day: String?) -> [[String: Date]] {

        var res: [[String: Date]] = []
        var value: [String: Date]? = nil
        for log in self.getConnectLogs(day: day) {
            let parts: [String] = log.components(separatedBy: "_")
            if parts.count >= 2, let time = Double(parts[0]) {
                let date: Date = Date(timeIntervalSince1970: time)
                if value == nil {
                    value = [:]
                }
                if parts[1] == "0S" {
                    value?["S"] = date
                    if let value = value {
                        res.append(value)
                    }
                    value = nil
                }
                else if parts[1] == "1E" {
                    value?["E"] = date
                }
            }
        }
        return res
    }

    func setConnectLog(_ type: String, date: Date = Date()) -> Bool {

        if type.count <= 0 {
            return false
        }

        let formatter: DateFormatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyyMMdd"
        let day: String = formatter.string(from: date)

        var filePath: String = "\(self.baseDirPath)/\(day)"
        let fileManager: FileManager = FileManager.default
        var isDir: ObjCBool = false
        var exists: Bool = fileManager.fileExists(atPath: filePath, isDirectory: &isDir)
        if !exists || !isDir.boolValue {
            //print("save synapse -> no exist \(exists) \(isDir)" )
            if exists && !isDir.boolValue {
                do {
                    try fileManager.removeItem(atPath: filePath)
                }
                catch {
                    //print("save synapse -> removeItem error" )
                    return false
                }
            }
            //print("save synapse -> make dir" )
            do {
                try fileManager.createDirectory(atPath: filePath, withIntermediateDirectories: true, attributes: nil)
            }
            catch {
                //print("save synapse -> make dir error" )
                return false
            }
        }

        filePath = "\(filePath)/\(self.connectLogDir)"
        exists = fileManager.fileExists(atPath: filePath, isDirectory: &isDir)
        if !exists || !isDir.boolValue {
            if exists && !isDir.boolValue {
                do {
                    try fileManager.removeItem(atPath: filePath)
                }
                catch {
                    return false
                }
            }
            do {
                try fileManager.createDirectory(atPath: filePath, withIntermediateDirectories: true, attributes: nil)
            }
            catch {
                return false
            }
        }

        let filename: String = "\(floor(date.timeIntervalSince1970))_\(type)"
        filePath = "\(filePath)/\(filename)"
        //print("setConnectLog: \(filePath)" )
        exists = fileManager.fileExists(atPath: filePath, isDirectory: &isDir)
        if !exists || isDir.boolValue {
            if exists && isDir.boolValue {
                do {
                    try fileManager.removeItem(atPath: filePath)
                }
                catch {
                    return false
                }
            }
            return fileManager.createFile(atPath: filePath, contents: Data(), attributes: nil)
        }
        return true
    }

    func setStartConnectLog() -> Bool {

        return self.setConnectLog("0S")
    }

    func setEndConnectLog() -> Bool {

        return self.setConnectLog("1E")
    }

    func checkEndConnectLog(_ time: TimeInterval) {

        if self.getConnectLastDate("1E") == nil {
            let _ = self.setConnectLog("1E", date: Date(timeIntervalSince1970: time))
        }
    }

    func setValues(_ values: Data, date: Date, timeInterval: TimeInterval) -> Bool {

        let dayFormatter: DateFormatter = DateFormatter()
        dayFormatter.locale = Locale(identifier: "en_US_POSIX")
        dayFormatter.dateFormat = "yyyyMMdd"
        let hourFormatter: DateFormatter = DateFormatter()
        hourFormatter.locale = Locale(identifier: "en_US_POSIX")
        hourFormatter.dateFormat = "HH"
        let minFormatter: DateFormatter = DateFormatter()
        minFormatter.locale = Locale(identifier: "en_US_POSIX")
        minFormatter.dateFormat = "mm"
        let secFormatter: DateFormatter = DateFormatter()
        secFormatter.locale = Locale(identifier: "en_US_POSIX")
        secFormatter.dateFormat = "ss"
        let day: String = dayFormatter.string(from: date)
        let hour: String = hourFormatter.string(from: date)
        let min: String = minFormatter.string(from: date)
        let sec: String = secFormatter.string(from: date)

        var filePath: String = "\(self.baseDirPath)/\(day)"
        let fileManager: FileManager = FileManager.default
        var isDir: ObjCBool = false
        var exists: Bool = fileManager.fileExists(atPath: filePath, isDirectory: &isDir)
        if !exists || !isDir.boolValue {
            //print("save synapse -> no exist \(exists) \(isDir)" )
            if exists && !isDir.boolValue {
                do {
                    try fileManager.removeItem(atPath: filePath)
                }
                catch {
                    //print("save synapse -> removeItem error" )
                    return false
                }
            }
            //print("save synapse -> make dir" )
            do {
                try fileManager.createDirectory(atPath: filePath, withIntermediateDirectories: true, attributes: nil)
            }
            catch {
                //print("save synapse -> make dir error" )
                return false
            }
        }

        filePath = "\(filePath)/\(self.valuesDir)"
        exists = fileManager.fileExists(atPath: filePath, isDirectory: &isDir)
        if !exists || !isDir.boolValue {
            if exists && !isDir.boolValue {
                do {
                    try fileManager.removeItem(atPath: filePath)
                }
                catch {
                    return false
                }
            }
            do {
                try fileManager.createDirectory(atPath: filePath, withIntermediateDirectories: true, attributes: nil)
            }
            catch {
                return false
            }
        }

        filePath = "\(filePath)/\(hour)"
        exists = fileManager.fileExists(atPath: filePath, isDirectory: &isDir)
        if !exists || !isDir.boolValue {
            if exists && !isDir.boolValue {
                do {
                    try fileManager.removeItem(atPath: filePath)
                }
                catch {
                    return false
                }
            }
            do {
                try fileManager.createDirectory(atPath: filePath, withIntermediateDirectories: true, attributes: nil)
            }
            catch {
                return false
            }
        }

        filePath = "\(filePath)/\(min)"
        exists = fileManager.fileExists(atPath: filePath, isDirectory: &isDir)
        if !exists || !isDir.boolValue {
            if exists && !isDir.boolValue {
                do {
                    try fileManager.removeItem(atPath: filePath)
                }
                catch {
                    return false
                }
            }
            do {
                try fileManager.createDirectory(atPath: filePath, withIntermediateDirectories: true, attributes: nil)
            }
            catch {
                return false
            }
        }

        filePath = "\(filePath)/\(sec)"
        exists = fileManager.fileExists(atPath: filePath, isDirectory: &isDir)
        if !exists || !isDir.boolValue {
            if exists && !isDir.boolValue {
                do {
                    try fileManager.removeItem(atPath: filePath)
                }
                catch {
                    return false
                }
            }
            do {
                try fileManager.createDirectory(atPath: filePath, withIntermediateDirectories: true, attributes: nil)
            }
            catch {
                return false
            }
        }

        let filename: String = "\(date.timeIntervalSince1970)_\(timeInterval)"
        filePath = "\(filePath)/\(filename)"
        //print("setValues: \(date) \(filename)" )
        //print("setValues: \([UInt8](values))" )
        let fileURL = URL(fileURLWithPath: filePath)
        do {
            try values.write(to: fileURL)
        }
        catch {
            return false
        }
        return true
    }

    func getSynapseSendHistory(day: String, hour: String) -> Bool {

        if day.count <= 0 || hour.count <= 0 {
            return false
        }

        let filePath: String = "\(self.baseDirPath)/\(day)/\(self.sendDir)/\(hour)"
        let fileManager: FileManager = FileManager.default
        return fileManager.fileExists(atPath: filePath)
        /*var isDir: ObjCBool = false
        var exists: Bool = fileManager.fileExists(atPath: filePath, isDirectory: &isDir)
        if !exists {
            do {
                try fileManager.createDirectory(atPath: filePath, withIntermediateDirectories: true, attributes: nil)
            }
            catch {
                return false
            }
        }
        return true*/
    }

    func setSynapseSendHistory(day: String, hour: String) -> Bool {

        if day.count <= 0 || hour.count <= 0 {
            return false
        }

        var filePath: String = "\(self.baseDirPath)/\(day)"
        let fileManager: FileManager = FileManager.default
        var isDir: ObjCBool = false
        var exists: Bool = fileManager.fileExists(atPath: filePath, isDirectory: &isDir)
        if !exists || !isDir.boolValue {
            //print("save synapse -> no exist \(exists) \(isDir)" )
            if exists && !isDir.boolValue {
                do {
                    try fileManager.removeItem(atPath: filePath)
                }
                catch {
                    //print("save synapse -> removeItem error" )
                    return false
                }
            }
            //print("save synapse -> make dir" )
            do {
                try fileManager.createDirectory(atPath: filePath, withIntermediateDirectories: true, attributes: nil)
            }
            catch {
                //print("save synapse -> make dir error" )
                return false
            }
        }

        filePath = "\(filePath)/\(self.sendDir)"
        exists = fileManager.fileExists(atPath: filePath, isDirectory: &isDir)
        if !exists || !isDir.boolValue {
            if exists && !isDir.boolValue {
                do {
                    try fileManager.removeItem(atPath: filePath)
                }
                catch {
                    return false
                }
            }
            do {
                try fileManager.createDirectory(atPath: filePath, withIntermediateDirectories: true, attributes: nil)
            }
            catch {
                return false
            }
        }

        filePath = "\(filePath)/\(hour)"
        exists = fileManager.fileExists(atPath: filePath, isDirectory: &isDir)
        if !exists {
            do {
                try fileManager.createDirectory(atPath: filePath, withIntermediateDirectories: true, attributes: nil)
            }
            catch {
                return false
            }
        }
        return true
    }

    func removeSynapseRecords(_ time: TimeInterval) {

        self.setBaseDir()
        var synapseIds: [String] = []
        let fileManager: FileManager = FileManager.default
        do {
            try synapseIds = fileManager.contentsOfDirectory(atPath: self.baseDirPath)
        }
        catch {
        }
        for synapseId in synapseIds {
            let dir: String = "\(self.baseDirPath)/\(synapseId)"
            //print("removeSynapseRecords: \(dir)")
            var days: [String] = []
            do {
                try days = fileManager.contentsOfDirectory(atPath: dir)
            }
            catch {
            }
            //print("removeSynapseRecords days: \(days)")

            let date: Date = Date(timeInterval: -time, since: Date())
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.dateFormat = "yyyyMMdd"
            let dateStr: String = formatter.string(from: date)
            for day in days {
                if dateStr >= day {
                    let filePath: String = "\(dir)/\(day)"
                    //print("removeSynapseRecords filePath: \(filePath)")
                    do {
                        try fileManager.removeItem(atPath: filePath)
                        //print("removeSynapseRecords: \(dir) \(dateStr) -> \(day)")
                    }
                    catch {
                        //print("removeSynapseRecords error")
                    }
                }
            }
        }
    }
}
