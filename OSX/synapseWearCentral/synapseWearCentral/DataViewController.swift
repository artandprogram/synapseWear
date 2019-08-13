//
//  DataViewController.swift
//  synapseWearCentral
//
//  Created by nakaguchi on 2019/06/04.
//  Copyright © 2019 art and program, Inc. For license and other information refer to https://github.com/artandprogram/synapseWear. All rights reserved.
//

import Cocoa
import WebKit

class DataViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, WKNavigationDelegate {

    @IBOutlet var scrollView: NSScrollView!
    @IBOutlet var tableView: NSTableView!
    @IBOutlet var webView: WKWebView!

    let aScale: Float = 2.0 / 32768.0
    let gScale: Float = 250.0 / 32768.0
    let tableRows: Int = 12
    //let uuidRowNo: Int = 0
    let timeRowNo: Int = 0
    let co2RowNo: Int = 1
    let temperatureRowNo: Int = 2
    let humidityRowNo: Int = 3
    let lightRowNo: Int = 4
    let airpressureRowNo: Int = 5
    let soundRowNo: Int = 6
    let angleRowNo: Int = 7
    let gyroRowNo: Int = 8
    let voltRowNo: Int = 9
    let tvocRowNo: Int = 10
    let batteryRowNo: Int = 11
    var synapseNo: Int?
    var synapseValues: SynapseValues?
    var mainViewController: ViewController?
    // For Graph Data
    let synapseGraphUpdateInterval: TimeInterval = 1.0
    var synapseGraphFlag: Bool = false
    var synapseGraphFirstFlag: Bool = false
    var synapseGraphLastUpdate: Date?
    var synapseGraphLabels: [String] = []
    var synapseGraphValues: [[[String: Any]]] = []
    var synapseGraphColors: [String] = []
    var graphLabels: String?
    var graphValues: String?
    var graphColor: String?
    var synapseGraphUpdateDate: Date?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.viewSetting()

        self.checkGraph()
    }

    override func viewWillDisappear() {
        super.viewWillDisappear()

        self.mainViewController?.dataViewController = nil
        //print("DataViewController viewWillDisappear: \(self.parentViewController)")
    }

    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }

    func viewSetting() {

        self.title = ""
        if let synapseValues = self.synapseValues, let uuid = synapseValues.uuid {
            self.title = uuid
        }

        self.tableView.delegate = self
        //self.webView.uiDelegate = self
        self.webView.navigationDelegate = self

        NotificationCenter.default.addObserver(self, selector: #selector(self.resized), name: NSWindow.didResizeNotification, object: nil)
    }

    @objc func resized() {

        self.scrollView.frame = NSRect(x: 0,
                                       y: 0,
                                       width: NSApp.windows.last!.frame.size.width,
                                       height: NSApp.windows.last!.frame.size.height - (self.webView.frame.size.height + 21.0))
        self.webView.frame = NSRect(x: 0,
                                    y: self.scrollView.frame.size.height,
                                    width: NSApp.windows.last!.frame.size.width,
                                    height: self.webView.frame.size.height)
        self.webView.reload()
    }

    // MARK: mark - TableView methods

    func numberOfRows(in tableView: NSTableView) -> Int {

        return self.tableRows
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {

        if let tableColumn = tableColumn {
            //print("row: \(row), tableColumn: \(tableColumn.identifier.rawValue)")
            var str: String = ""
            if row == self.timeRowNo {
                if tableColumn.identifier.rawValue == "title" {
                    str = "Time"
                }
                else if tableColumn.identifier.rawValue == "value" {
                    if let synapseValues = self.synapseValues, let time = synapseValues.time {
                        let formatter: DateFormatter = DateFormatter()
                        formatter.locale = Locale(identifier: "en_US_POSIX")
                        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss.SSS"
                        str = formatter.string(from: Date(timeIntervalSince1970: time))
                    }
                }
            }
            else if row == self.co2RowNo {
                if tableColumn.identifier.rawValue == "title" {
                    str = "CO2"
                }
                else if tableColumn.identifier.rawValue == "value" {
                    if let synapseValues = self.synapseValues, let co2 = synapseValues.co2 {
                        str = "\(String(co2)) ppm"
                    }
                }
            }
            else if row == self.temperatureRowNo {
                if tableColumn.identifier.rawValue == "title" {
                    str = "Temperature"
                }
                else if tableColumn.identifier.rawValue == "value" {
                    if let synapseValues = self.synapseValues, let temp = synapseValues.temp {
                        str = "\(String(format:"%.1f", temp)) ℃"
                    }
                }
            }
            else if row == self.humidityRowNo {
                if tableColumn.identifier.rawValue == "title" {
                    str = "Humidity"
                }
                else if tableColumn.identifier.rawValue == "value" {
                    if let synapseValues = self.synapseValues, let humidity = synapseValues.humidity {
                        str = "\(String(humidity)) %"
                    }
                }
            }
            else if row == self.lightRowNo {
                if tableColumn.identifier.rawValue == "title" {
                    str = "Light"
                }
                else if tableColumn.identifier.rawValue == "value" {
                    if let synapseValues = self.synapseValues, let light = synapseValues.light {
                        str = "\(String(light)) lux"
                    }
                }
            }
            else if row == self.airpressureRowNo {
                if tableColumn.identifier.rawValue == "title" {
                    str = "Air Pressure"
                }
                else if tableColumn.identifier.rawValue == "value" {
                    if let synapseValues = self.synapseValues, let pressure = synapseValues.pressure {
                        str = "\(String(format:"%.2f", pressure)) hPa"
                    }
                }
            }
            else if row == self.soundRowNo {
                if tableColumn.identifier.rawValue == "title" {
                    str = "Sound"
                }
                else if tableColumn.identifier.rawValue == "value" {
                    if let synapseValues = self.synapseValues, let sound = synapseValues.sound {
                        str = "\(String(sound))"
                    }
                }
            }
            else if row == self.angleRowNo {
                if tableColumn.identifier.rawValue == "title" {
                    str = "Angle"
                }
                else if tableColumn.identifier.rawValue == "value" {
                    if let synapseValues = self.synapseValues, let ax = synapseValues.ax, let ay = synapseValues.ay, let az = synapseValues.az {
                        str = "\(String(format:"%.3f", Float(ax) * self.aScale))/\(String(format:"%.3f", Float(ay) * self.aScale))/\(String(format:"%.3f", Float(az) * self.aScale)) rad/s"
                    }
                }
            }
            else if row == self.gyroRowNo {
                if tableColumn.identifier.rawValue == "title" {
                    str = "Gyro"
                }
                else if tableColumn.identifier.rawValue == "value" {
                    if let synapseValues = self.synapseValues, let gx = synapseValues.gx, let gy = synapseValues.gy, let gz = synapseValues.gz {
                        str = "\(String(format:"%.3f", Float(gx) * self.gScale * Float(Double.pi / 180.0)))/\(String(format:"%.3f", Float(gy) * self.gScale * Float(Double.pi / 180.0)))/\(String(format:"%.3f", Float(gz) * self.gScale * Float(Double.pi / 180.0))) m/s2"
                    }
                }
            }
            else if row == self.voltRowNo {
                if tableColumn.identifier.rawValue == "title" {
                    str = "Volt"
                }
                else if tableColumn.identifier.rawValue == "value" {
                    if let synapseValues = self.synapseValues, let power = synapseValues.power {
                        str = "\(String(format:"%.1f", power)) V"
                    }
                }
            }
            else if row == self.tvocRowNo {
                if tableColumn.identifier.rawValue == "title" {
                    str = "tVOC"
                }
                else if tableColumn.identifier.rawValue == "value" {
                    if let synapseValues = self.synapseValues, let tvoc = synapseValues.tvoc {
                        str = "\(String(tvoc))"
                    }
                }
            }
            else if row == self.batteryRowNo {
                if tableColumn.identifier.rawValue == "title" {
                    str = "Battery"
                }
                else if tableColumn.identifier.rawValue == "value" {
                    if let synapseValues = self.synapseValues, let battery = synapseValues.battery {
                        str = "\(String(format:"%.1f", battery)) %"
                    }
                }
            }

            let cell = tableView.makeView(withIdentifier: tableColumn.identifier, owner: self) as! NSTableCellView
            cell.textField?.stringValue = str
            return cell
        }
        return nil
    }

    // MARK: mark - Graph methods

    @objc func checkGraph() {

        //print("checkGraph")
        if let synapseValues = self.synapseValues {
            if synapseValues.isConnected {
                if self.synapseGraphFlag {
                    self.updateGraph()
                }
                else {
                    self.initGraph()
                }
            }
            else {
                self.synapseGraphFlag = false
            }
        }
    }

    func initGraph() {

        self.synapseGraphFlag = true
        self.synapseGraphLastUpdate = Date()
        self.setGraph()
    }

    func updateGraph() {

        let now: Date = Date()
        var canUpdate: Bool = true
        if let synapseGraphLastUpdate = self.synapseGraphLastUpdate, now.timeIntervalSince(synapseGraphLastUpdate) < self.synapseGraphUpdateInterval {
            canUpdate = false
        }
        if canUpdate {
            self.synapseGraphLastUpdate = now
            self.updateGraphScript()
        }
    }

    func makeGraphParameter() -> Bool {

        var res: Bool = true
        do {
            let colorsData: Data = try JSONSerialization.data(withJSONObject: self.synapseGraphColors, options: [])
            self.graphColor = String(data: colorsData, encoding: .utf8)
            let labelsData: Data = try JSONSerialization.data(withJSONObject: self.synapseGraphLabels, options: [])
            self.graphLabels = String(data: labelsData, encoding: .utf8)
            let valuesData: Data = try JSONSerialization.data(withJSONObject: self.synapseGraphValues, options: [])
            self.graphValues = String(data: valuesData, encoding: .utf8)
        }
        catch {
            print("JSON Encode Error: \(error.localizedDescription)")
            res = false
        }
        return res
    }

    func setGraph() {

        //print("setGraph: \(self.synapseGraphLastDate)")
        if self.makeGraphParameter() {
            if let path: String = Bundle.main.path(forResource: "graph", ofType: "html") {
                let localHtmlUrl: URL = URL(fileURLWithPath: path, isDirectory: false)
                self.webView.loadFileURL(localHtmlUrl, allowingReadAccessTo: localHtmlUrl)
            }
        }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {

        if let labels = self.graphLabels, let values = self.graphValues, let color = self.graphColor {
            let type: String = "line"
            let execJsFunc: String = "graph(\"\(type)\", \(labels), \(values), \(color));"
            //print("execJsFunc: \(execJsFunc)")
            self.webView.evaluateJavaScript(execJsFunc, completionHandler: { (object, error) -> Void in
                if let error = error {
                    print("JS Error: \(error.localizedDescription)")
                }
                self.synapseGraphFirstFlag = true
            })
        }
    }

    func updateGraphScript() {

        if !self.synapseGraphFirstFlag {
            return
        }

        if self.makeGraphParameter(), let labels = self.graphLabels, let values = self.graphValues {
            let execJsFunc: String = "updateGraph(\(labels), \(values));"
            //print("execJsFunc: \(execJsFunc)")
            self.webView.evaluateJavaScript(execJsFunc, completionHandler: { (object, error) -> Void in
                if let error = error {
                    print("JS Error: \(error.localizedDescription)")
                }
            })
        }
    }
}
