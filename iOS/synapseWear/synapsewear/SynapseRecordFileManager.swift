//
//  SynapseRecordFileManager.swift
//  synapsewear
//
//  Copyright © 2017 art and program, Inc. For license and other information refer to https://github.com/artandprogram/synapseWear. All rights reserved.
//

import UIKit

class SynapseRecordFileManager: BaseFileManager, UsageFunction {

    // const variables
    let connectLogDir: String = "connect_log"
    let valuesDir: String = "values"
    let sendDir: String = "send"
    let limitSpace: Int64 = 2 * 1024 * 1024 * 1024

    override init() {
        super.init()

        self.baseDirType = "application_support"
        self.baseDirName = "synapse_record"
        self.setBaseDir()
    }

    override func setBaseDir() {
        super.setBaseDir()

        self.checkBaseDir()
    }

    func checkBaseDir() {

        if self.baseDirType == "documents" {
            return
        }

        var documentsDir: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        documentsDir = "\(documentsDir)/\(self.baseDirName)"

        var isDir: ObjCBool = false
        var exists: Bool = FileManager.default.fileExists(atPath: documentsDir, isDirectory: &isDir)
        if exists && isDir.boolValue {
            //print("SynapseRecordFileManager checkBaseDir: \(documentsDir) -> \(self.baseDirPath)")
            do {
                exists = FileManager.default.fileExists(atPath: self.baseDirPath)
                if exists {
                    try FileManager.default.removeItem(atPath: self.baseDirPath)
                }

                try FileManager.default.moveItem(atPath: documentsDir, toPath: self.baseDirPath)
            }
            catch {
                print("SynapseRecordFileManager checkBaseDir error: \(error.localizedDescription)")
            }
        }
    }

    func setSynapseId(_ synapseId: String) {

        self.setBaseDir()

        if synapseId.count > 0 {
            self.baseDirPath = "\(self.baseDirPath)/\(synapseId)"
            _ = self.self.createDirectory(self.baseDirPath)
        }
        //print("SynapseRecordFileManager setSynapseId: \(self.baseDirPath)")
    }

    func getSynapseRecords(day: String? = nil, type: String? = nil) -> [String] {

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
        do {
            return try self.contentsOfDirectory(filePath)
        }
        catch {
            print("SynapseRecordFileManager getSynapseRecords error: \(error.localizedDescription)")
            return []
        }
    }

    func setSynapseRecord(day: String, time: String, fileName: String) -> Bool {

        if day.count <= 0 || time.count <= 0 || fileName.count <= 0 {
            return false
        }

        var filePath: String = "\(self.baseDirPath)/\(day)"
        if !self.createDirectory(filePath) {
            return false
        }
        filePath = "\(filePath)/\(time)"
        if !self.createDirectory(filePath) {
            return false
        }
        filePath = "\(filePath)/\(fileName)"
        if !self.createFile(filePath) {
            return false
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
            res = self.fileExists(filePath, isDirectory: true)
        }
        return res
    }

    func getTotalData(_ filePath: String) -> [String]? {

        if filePath.count > 0 {
            do {
                let files: [String] = try self.contentsOfDirectory(filePath)
                if let file = files.first {
                    let arr: [String] = file.components(separatedBy: "_")
                    if arr.count > 1 {
                        return arr
                    }
                }
            }
            catch {
                print("SynapseRecordFileManager getTotalData error: \(error.localizedDescription)")
            }
        }
        return nil
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
        if let arr = self.getTotalData(filePath) {
            if let cnt = Double(arr[0]), let total = Double(arr[1]) {
                return [cnt, total]
            }
        }
        return res
    }

    func setSynapseRecordTotal(_ value: Double, day: String, hour: String, min: String, sec: String, type: String) -> Bool {

        if day.count <= 0 || hour.count <= 0 || min.count <= 0 || sec.count <= 0 || type.count <= 0 {
            return false
        }

        var filePath: String = "\(self.baseDirPath)/\(day)"
        if !self.createDirectory(filePath) {
            return false
        }
        filePath = "\(filePath)/\(type)"
        if !self.createDirectory(filePath) {
            return false
        }
        filePath = "\(filePath)/\(hour)"
        if !self.createDirectory(filePath) {
            return false
        }

        var cnt: Int = 0
        var total: Double = 0
        filePath = "\(filePath)/\(min)"
        if !self.createDirectory(filePath) {
            return false
        }
        if let arr = self.getTotalData(filePath) {
            if let cntVal = Int(arr[0]), let totalVal = Double(arr[1]) {
                cnt = cntVal
                total = totalVal
            }
        }
        cnt += 1
        total += value

        var totalFileName: String = "\(String(format:"%02d", cnt))_\(String(total))"
        if !self.createFile("\(filePath)/\(totalFileName)") {
            return false
        }

        cnt = 0
        total = 0
        filePath = "\(filePath)/00_\(sec)"
        if !self.createDirectory(filePath) {
            return false
        }
        if let arr = self.getTotalData(filePath) {
            if let cntVal = Int(arr[0]), let totalVal = Double(arr[1]) {
                cnt = cntVal
                total = totalVal
            }
        }
        cnt += 1
        total += value

        totalFileName = "\(String(format:"%02d", cnt))_\(String(total))"
        if !self.createFile("\(filePath)/\(totalFileName)") {
            return false
        }

        return true
    }

    func getSynapseRecordTotalIn10min(day: String, hour: String, min: Int, type: String, isSave: Bool) -> Double? {

        var res: Double? = nil
        if day.count <= 0 || hour.count <= 0 || type.count <= 0 {
            return res
        }

        var filePath: String = "\(self.baseDirPath)/\(day)"
        if !self.fileExists(filePath, isDirectory: true) {
            return res
        }
        filePath = "\(filePath)/\(type)"
        if !self.fileExists(filePath, isDirectory: true) {
            return res
        }
        filePath = "\(filePath)/\(hour)"
        if !self.fileExists(filePath, isDirectory: true) {
            return res
        }

        var filePath10min: String = "\(filePath)/10min"
        if !self.createDirectory(filePath10min) {
            return res
        }
        filePath10min = "\(filePath10min)/\(min)"
        if self.fileExists(filePath10min, isDirectory: true) {
            do {
                let files: [String] = try self.contentsOfDirectory(filePath10min)
                if let file = files.first {
                    if let value = Double(file) {
                        return value
                    }
                }
            }
            catch {
                print("SynapseRecordFileManager getSynapseRecordTotalIn10min error: \(error.localizedDescription)")
            }
        }
        else {
            if isSave, !self.createDirectory(filePath10min) {
                return res
            }
        }

        var cnt: Int = 0
        var total: Double = 0
        for i in min * 10..<(min + 1) * 10 {
            let minStr: String = String(format:"%02d", i)
            let minPath: String = "\(filePath)/\(minStr)"
            if let arr = self.getTotalData(minPath) {
                if let cntVal = Int(arr[0]), let totalVal = Double(arr[1]) {
                    cnt += cntVal
                    total += totalVal
                }
            }
        }
        if cnt > 0 {
            res = total / Double(cnt)
        }

        if isSave, res != nil {
            let totalFileName: String = String(res!)
            if self.createFile("\(filePath10min)/\(totalFileName)") {
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
        if !self.fileExists(filePath, isDirectory: true) {
            return res
        }
        filePath = "\(filePath)/\(type)"
        if !self.fileExists(filePath, isDirectory: true) {
            return res
        }
        filePath = "\(filePath)/\(hour)"
        if !self.fileExists(filePath, isDirectory: true) {
            return res
        }

        filePath = "\(filePath)/1hour"
        if self.fileExists(filePath, isDirectory: true) {
            do {
                let files: [String] = try self.contentsOfDirectory(filePath)
                if let file = files.first {
                    if let value = Double(file) {
                        return value
                    }
                }
            }
            catch {
                print("SynapseRecordFileManager getSynapseRecordTotalInHour error: \(error.localizedDescription)")
            }
        }
        else {
            if isSave, !self.createDirectory(filePath) {
                return res
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

        if isSave, res != nil {
            let totalFileName: String = String(res!)
            if self.createFile("\(filePath)/\(totalFileName)") {
                //print("make SynapseRecordTotalInHour: \(filePath)/\(totalFileName)")
            }
        }
        return res
    }

    func setSynapseRecordTotalInHour(type: String, start: Date? = nil) {

        let date: Date = Date()
        let dateD: String = self.dateToString(date: date, dateFormat: "yyyyMMdd")
        let dateH: String = self.dateToString(date: date, dateFormat: "HH")
        let dateM: String = self.dateToString(date: date, dateFormat: "mm")
        var startD: String?
        var startH: String?
        var startM: String?
        if let start = start {
            startD = self.dateToString(date: start, dateFormat: "yyyyMMdd")
            startH = self.dateToString(date: start, dateFormat: "HH")
            startM = self.dateToString(date: start, dateFormat: "mm")
        }

        do {
            let files: [String] = try self.contentsOfDirectory(self.baseDirPath)
            //print("setSynapseRecordTotalInHour: \(type) -> \(startD):\(startH):\(startM) - \(dateD):\(dateH):\(dateM)")
            for (_, element) in files.enumerated() {
                if (startD == nil || element >= startD!) && element <= dateD {
                    for i in 0..<24 {
                        if (startH == nil || element > startD! || i >= Int(startH!)!) && (element < dateD || i <= Int(dateH)!) {
                            for j in 0..<6 {
                                if (startM == nil || element > startD! || i > Int(startH!)! || (j + 1) * 10 >= Int(startM!)!) {
                                    if element < dateD || (element == dateD && i < Int(dateH)!) {
                                        _ = self.getSynapseRecordTotalInHour(day: element,
                                                                             hour: String(format:"%02d", i),
                                                                             type: type,
                                                                             isSave: true)
                                    }
                                    else if element == dateD && i == Int(dateH)! && (j + 1) * 10 < Int(dateM)! {
                                        _ = self.getSynapseRecordTotalIn10min(day: element,
                                                                              hour: String(format:"%02d", i),
                                                                              min: j,
                                                                              type: type,
                                                                              isSave: true)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        catch {
            print("SynapseRecordFileManager setSynapseRecordTotalInHour error: \(error.localizedDescription)")
        }
    }

    func getSynapseRecordValueType(day: String, hour: String, min: String, type: String, valueType: String) -> [String] {

        if day.count <= 0 || hour.count <= 0 || min.count <= 0 || type.count <= 0 || valueType.count <= 0 {
            return []
        }

        let filePath: String = "\(self.baseDirPath)/\(day)/\(type)/\(valueType)/\(hour)/\(min)"
        if filePath.count > 0 {
            if self.fileExists(filePath, isDirectory: true) {
                do {
                    return try self.contentsOfDirectory(filePath)
                }
                catch {
                    print("SynapseRecordFileManager getSynapseRecordValueType error: \(error.localizedDescription)")
                }
            }
        }
        return []
    }

    func getSynapseRecordValueTypeIn10min(day: String, hour: String, min: Int, type: String, valueType: String) -> [String]? {

        if day.count <= 0 || hour.count <= 0 || type.count <= 0 || valueType.count <= 0 {
            return nil
        }

        let filePath: String = "\(self.baseDirPath)/\(day)/\(type)/\(valueType)/\(hour)/10min/\(min)"
        if filePath.count > 0 {
            if self.fileExists(filePath, isDirectory: true) {
                do {
                    return try self.contentsOfDirectory(filePath)
                }
                catch {
                    print("SynapseRecordFileManager getSynapseRecordValueTypeIn10min error: \(error.localizedDescription)")
                }
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
            if self.fileExists(filePath, isDirectory: true) {
                do {
                    return try self.contentsOfDirectory(filePath)
                }
                catch {
                    print("SynapseRecordFileManager getSynapseRecordValueTypeInHour error: \(error.localizedDescription)")
                }
            }
        }
        return nil
    }

    func setSynapseRecordValueType(_ value: String, day: String, hour: String, min: String, type: String, valueType: String) -> Bool {

        if day.count <= 0 || hour.count <= 0 || min.count <= 0 || type.count <= 0 || valueType.count <= 0 {
            return false
        }

        var filePath: String = "\(self.baseDirPath)/\(day)"
        if !self.createDirectory(filePath) {
            return false
        }
        filePath = "\(filePath)/\(type)"
        if !self.createDirectory(filePath) {
            return false
        }
        filePath = "\(filePath)/\(valueType)"
        if !self.createDirectory(filePath) {
            return false
        }
        filePath = "\(filePath)/\(hour)"
        if !self.createDirectory(filePath) {
            return false
        }
        filePath = "\(filePath)/\(min)"
        if !self.createDirectory(filePath) {
            return false
        }
        filePath = "\(filePath)/\(value)"
        //print("save synapse -> \(filePath)" )
        return self.createFile(filePath)
    }

    func setSynapseRecordValueTypeIn10min(_ value: String, day: String, hour: String, min: Int, type: String, valueType: String) -> Bool {

        if day.count <= 0 || hour.count <= 0 || type.count <= 0 || valueType.count <= 0 {
            return false
        }

        var filePath: String = "\(self.baseDirPath)/\(day)"
        if !self.createDirectory(filePath) {
            return false
        }
        filePath = "\(filePath)/\(type)"
        if !self.createDirectory(filePath) {
            return false
        }
        filePath = "\(filePath)/\(valueType)"
        if !self.createDirectory(filePath) {
            return false
        }
        filePath = "\(filePath)/\(hour)"
        if !self.createDirectory(filePath) {
            return false
        }
        filePath = "\(filePath)/10min"
        if !self.createDirectory(filePath) {
            return false
        }
        filePath = "\(filePath)/\(min)"
        if !self.createDirectory(filePath) {
            return false
        }
        filePath = "\(filePath)/\(value)"
        //print("save synapse -> \(filePath)" )
        return self.createFile(filePath)
    }

    func setSynapseRecordValueTypeInHour(_ value: String, day: String, hour: String, type: String, valueType: String) -> Bool {

        if day.count <= 0 || hour.count <= 0 || type.count <= 0 || valueType.count <= 0 {
            return false
        }

        var filePath: String = "\(self.baseDirPath)/\(day)"
        if !self.createDirectory(filePath) {
            return false
        }
        filePath = "\(filePath)/\(type)"
        if !self.createDirectory(filePath) {
            return false
        }
        filePath = "\(filePath)/\(valueType)"
        if !self.createDirectory(filePath) {
            return false
        }
        filePath = "\(filePath)/\(hour)"
        if !self.createDirectory(filePath) {
            return false
        }
        filePath = "\(filePath)/1hour"
        if !self.createDirectory(filePath) {
            return false
        }
        filePath = "\(filePath)/\(value)"
        //print("save synapse -> \(filePath)" )
        return self.createFile(filePath)
    }

    func getDayDirectories() -> [String] {

        do {
            return try self.contentsOfDirectory(self.baseDirPath)
        }
        catch {
            print("SynapseRecordFileManager getDayDirectories error: \(error.localizedDescription)")
        }
        return []
    }

    func getConnectLogs(day: String?) -> [String] {

        if let day = day, day.count > 0 {
            let filePath: String = "\(self.baseDirPath)/\(day)/\(self.connectLogDir)"
            do {
                return try self.contentsOfDirectory(filePath)
            }
            catch {
                print("SynapseRecordFileManager getConnectLogs error: \(error.localizedDescription)")
            }
        }
        return []
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
        if let value = value {
            res.append(value)
        }
        return res
    }

    func setConnectLog(_ type: String, date: Date = Date()) -> Bool {

        if type.count <= 0 {
            return false
        }

        let day: String = self.dateToString(date: date, dateFormat: "yyyyMMdd")
        var filePath: String = "\(self.baseDirPath)/\(day)"
        if !self.createDirectory(filePath) {
            return false
        }
        filePath = "\(filePath)/\(self.connectLogDir)"
        if !self.createDirectory(filePath) {
            return false
        }

        let filename: String = "\(floor(date.timeIntervalSince1970))_\(type)"
        filePath = "\(filePath)/\(filename)"
        //print("setConnectLog: \(filePath)" )
        return self.createFile(filePath)
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

        let day: String = self.dateToString(date: date, dateFormat: "yyyyMMdd")
        let hour: String = self.dateToString(date: date, dateFormat: "HH")
        let min: String = self.dateToString(date: date, dateFormat: "mm")
        let sec: String = self.dateToString(date: date, dateFormat: "ss")
        var filePath: String = "\(self.baseDirPath)/\(day)"
        if !self.createDirectory(filePath) {
            return false
        }
        filePath = "\(filePath)/\(self.valuesDir)"
        if !self.createDirectory(filePath) {
            return false
        }
        filePath = "\(filePath)/\(hour)"
        if !self.createDirectory(filePath) {
            return false
        }
        filePath = "\(filePath)/\(min)"
        if !self.createDirectory(filePath) {
            return false
        }
        filePath = "\(filePath)/\(sec)"
        if !self.createDirectory(filePath) {
            return false
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
            print("SynapseRecordFileManager setValues error: \(error.localizedDescription)")
            return false
        }
        return true
    }

    func getSynapseSendHistory(day: String, hour: String) -> Bool {

        if day.count <= 0 || hour.count <= 0 {
            return false
        }

        let filePath: String = "\(self.baseDirPath)/\(day)/\(self.sendDir)/\(hour)"
        return FileManager.default.fileExists(atPath: filePath)
    }

    func setSynapseSendHistory(day: String, hour: String) -> Bool {

        if day.count <= 0 || hour.count <= 0 {
            return false
        }

        var filePath: String = "\(self.baseDirPath)/\(day)"
        if !self.createDirectory(filePath) {
            return false
        }
        filePath = "\(filePath)/\(self.sendDir)"
        if !self.createDirectory(filePath) {
            return false
        }
        filePath = "\(filePath)/\(hour)"
        return self.createDirectory(filePath)
    }

    func removeSynapseRecords(_ time: TimeInterval) {

        self.setBaseDir()

        var synapseIds: [String] = []
        var dayList: [String] = []
        do {
            try synapseIds = FileManager.default.contentsOfDirectory(atPath: self.baseDirPath)
        }
        catch {
            print("SynapseRecordFileManager removeSynapseRecords error: \(error.localizedDescription)")
            return
        }

        let date: Date = Date(timeInterval: -time, since: Date())
        let dateStr: String = self.dateToString(date: date, dateFormat: "yyyyMMdd")
        for synapseId in synapseIds {
            let dir: String = "\(self.baseDirPath)/\(synapseId)"
            //print("removeSynapseRecords: \(dir)")
            var days: [String] = []
            do {
                try days = FileManager.default.contentsOfDirectory(atPath: dir)
            }
            catch {
                print("SynapseRecordFileManager removeSynapseRecords error: \(error.localizedDescription)")
                days = []
            }
            //print("removeSynapseRecords days: \(days)")

            for day in days {
                if dateStr >= day {
                    let filePath: String = "\(dir)/\(day)"
                    //print("removeSynapseRecords filePath: \(filePath)")
                    do {
                        try FileManager.default.removeItem(atPath: filePath)
                        //print("removeSynapseRecords: \(dir) \(dateStr) -> \(day)")
                    }
                    catch {
                        print("SynapseRecordFileManager removeSynapseRecords error: \(error.localizedDescription)")
                    }
                }

                if dayList.index(of: day) == nil {
                    dayList.append(day)
                }
            }
        }

        if dayList.count > 0 {
            var res: Bool = false
            dayList.sort { $1 > $0 }
            for day in dayList {
                if res {
                    break
                }

                for synapseId in synapseIds {
                    if self.freeSpace >= self.limitSpace {
                        res = true
                        break
                    }

                    let filePath: String = "\(self.baseDirPath)/\(synapseId)/\(day)/\(self.valuesDir)"
                    if FileManager.default.fileExists(atPath: filePath) {
                        do {
                            try FileManager.default.removeItem(atPath: filePath)
                            //print("removeSynapseRecords: \(filePath)")
                        }
                        catch {
                            print("SynapseRecordFileManager removeSynapseRecords error: \(error.localizedDescription)")
                        }
                    }
                }
            }
        }
    }
}
