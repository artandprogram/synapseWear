//
//  DataViewController.swift
//  synapseWearCentral
//
//  Copyright © 2019 art and program, Inc. For license and other information refer to https://github.com/artandprogram/synapseWear. All rights reserved.
//

import Cocoa
import WebKit

class DataViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, WKNavigationDelegate {

    @IBOutlet var scrollView: NSScrollView!
    @IBOutlet var tableView: NSTableView!
    @IBOutlet var webView: WKWebView!

    let webViewBaseH: CGFloat = 200.0
    let tableViewRowH: CGFloat = 22.0
    let tableRows: [String] = [
        "time",
        "co2",
        "temperature",
        "humidity",
        "light",
        "airpressure",
        "sound",
        "accelx",
        "accely",
        "accelz",
        "gyrox",
        "gyroy",
        "gyroz",
        "volt",
        "tvoc",
        "battery",
    ]
    let synapseCrystalInfo: SynapseCrystalStruct = SynapseCrystalStruct()
    var synapseUUID: String?
    var synapseValues: SynapseValues?
    var mainViewController: ViewController?
    // For Graph Data
    let synapseGraphUpdateInterval: TimeInterval = 1.0
    var synapseGraphFlag: Bool = false
    var synapseGraphFirstFlag: Bool = false
    var synapseGraphLastUpdate: Date?
    var synapseGraphKeys: [String] = []
    var synapseGraphLabels: [String] = []
    var synapseGraphValues: [[[String: Any]]] = []
    var synapseGraphColors: [String] = []
    var synapseGraphScales: [[String: Double]] = []
    var synapseGraphHiddens: [String: Bool] = [:]
    var graphLabels: String?
    var graphValues: String?
    var graphColor: String?
    var graphScales: String?
    var graphHiddens: String?
    var synapseGraphUpdateDate: Date?
    var isViewSetting: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        self.viewSetting()
        self.checkGraph()
        self.isViewSetting = true
    }

    override func viewWillDisappear() {
        super.viewWillDisappear()

        if let uuid = self.synapseUUID {
            self.mainViewController?.closeSynapseDataWindow(uuid)
        }
        self.mainViewController = nil
        //print("DataViewController viewWillDisappear")
    }

    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }

    func viewSetting() {

        self.tableView.delegate = self
        self.tableView.allowsTypeSelect = false
        self.tableView.action = #selector(onItemClicked)
        //self.webView.uiDelegate = self
        self.webView.navigationDelegate = self

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.resized),
                                               name: NSWindow.didResizeNotification,
                                               object: nil)
    }

    @objc func resized() {

        if let window = self.view.window/*NSApp.windows.last*/ {
            let headerH: CGFloat = 21.0
            let spaceH: CGFloat = 20.0
            let tableBaseH: CGFloat = CGFloat(self.tableRows.count) * self.tableViewRowH
            var webViewH: CGFloat = self.webViewBaseH
            if window.frame.size.height > headerH + tableBaseH + self.webViewBaseH + spaceH {
                webViewH = window.frame.size.height - (headerH + tableBaseH + spaceH)
            }
            self.scrollView.frame = NSRect(x: 0,
                                           y: 0,
                                           width: window.frame.size.width,
                                           height: window.frame.size.height - (webViewH + headerH))
            self.webView.frame = NSRect(x: 0,
                                        y: self.scrollView.frame.size.height,
                                        width: window.frame.size.width,
                                        height: webViewH)
        }
        self.webView.reload()
    }

    // MARK: mark - TableView methods

    func numberOfRows(in tableView: NSTableView) -> Int {

        return self.tableRows.count
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {

        if let tableColumn = tableColumn, row < self.tableRows.count {
            //print("row: \(row), tableColumn: \(tableColumn.identifier.rawValue)")
            var str: String = ""
            var color: NSColor = NSColor.white
            var alpha: CGFloat = 1.0
            if self.tableRows[row] == "time" {
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
            else if self.tableRows[row] == "co2" {
                if tableColumn.identifier.rawValue == "title" {
                    str = "CO2"
                }
                else if tableColumn.identifier.rawValue == "value" {
                    if let synapseValues = self.synapseValues, let co2 = synapseValues.co2 {
                        str = "\(String(co2)) ppm"
                    }
                }
                else if tableColumn.identifier.rawValue == "graph" {
                    str = "●"
                    color = NSColor.graphWhite
                    if let flag = self.synapseGraphHiddens[self.synapseCrystalInfo.co2.key], flag {
                        alpha = 0.2
                    }
                }
            }
            else if self.tableRows[row] == "temperature" {
                if tableColumn.identifier.rawValue == "title" {
                    str = "Temperature"
                }
                else if tableColumn.identifier.rawValue == "value" {
                    if let synapseValues = self.synapseValues, let temp = synapseValues.temp {
                        str = "\(String(format:"%.1f", temp)) ℃"
                    }
                }
                else if tableColumn.identifier.rawValue == "graph" {
                    str = "●"
                    color = NSColor.graphRed
                    if let flag = self.synapseGraphHiddens[self.synapseCrystalInfo.temp.key], flag {
                        alpha = 0.2
                    }
                }
            }
            else if self.tableRows[row] == "humidity" {
                if tableColumn.identifier.rawValue == "title" {
                    str = "Humidity"
                }
                else if tableColumn.identifier.rawValue == "value" {
                    if let synapseValues = self.synapseValues, let humidity = synapseValues.humidity {
                        str = "\(String(humidity)) %"
                    }
                }
                else if tableColumn.identifier.rawValue == "graph" {
                    str = "●"
                    color = NSColor.graphGreen
                    if let flag = self.synapseGraphHiddens[self.synapseCrystalInfo.hum.key], flag {
                        alpha = 0.2
                    }
                }
            }
            else if self.tableRows[row] == "light" {
                if tableColumn.identifier.rawValue == "title" {
                    str = "Light"
                }
                else if tableColumn.identifier.rawValue == "value" {
                    if let synapseValues = self.synapseValues, let light = synapseValues.light {
                        str = "\(String(light)) lux"
                    }
                }
                else if tableColumn.identifier.rawValue == "graph" {
                    str = "●"
                    color = NSColor.graphYellow
                    if let flag = self.synapseGraphHiddens[self.synapseCrystalInfo.ill.key], flag {
                        alpha = 0.2
                    }
                }
            }
            else if self.tableRows[row] == "airpressure" {
                if tableColumn.identifier.rawValue == "title" {
                    str = "Air Pressure"
                }
                else if tableColumn.identifier.rawValue == "value" {
                    if let synapseValues = self.synapseValues, let pressure = synapseValues.pressure {
                        str = "\(String(format:"%.2f", pressure)) hPa"
                    }
                }
                else if tableColumn.identifier.rawValue == "graph" {
                    str = "●"
                    color = NSColor.graphPurple
                    if let flag = self.synapseGraphHiddens[self.synapseCrystalInfo.press.key], flag {
                        alpha = 0.2
                    }
                }
            }
            else if self.tableRows[row] == "sound" {
                if tableColumn.identifier.rawValue == "title" {
                    str = "Sound"
                }
                else if tableColumn.identifier.rawValue == "value" {
                    if let synapseValues = self.synapseValues, let sound = synapseValues.sound {
                        str = "\(String(sound))"
                    }
                }
                else if tableColumn.identifier.rawValue == "graph" {
                    str = "●"
                    color = NSColor.graphBlue
                    if let flag = self.synapseGraphHiddens[self.synapseCrystalInfo.sound.key], flag {
                        alpha = 0.2
                    }
                }
            }
            else if self.tableRows[row] == "accelx" {
                if tableColumn.identifier.rawValue == "title" {
                    str = "Accel x"
                }
                else if tableColumn.identifier.rawValue == "value" {
                    if let synapseValues = self.synapseValues, let ax = synapseValues.ax {
                        str = String(format:"%.3f", CommonFunction.makeAccelerationValue(Float(ax)))
                    }
                }
                else if tableColumn.identifier.rawValue == "graph" {
                    str = "●"
                    color = NSColor.graphOrange
                    if let flag = self.synapseGraphHiddens[self.synapseCrystalInfo.ax.key], flag {
                        alpha = 0.2
                    }
                }
            }
            else if self.tableRows[row] == "accely" {
                if tableColumn.identifier.rawValue == "title" {
                    str = "Accel y"
                }
                else if tableColumn.identifier.rawValue == "value" {
                    if let synapseValues = self.synapseValues, let ay = synapseValues.ay {
                        str = String(format:"%.3f", CommonFunction.makeAccelerationValue(Float(ay)))
                    }
                }
                else if tableColumn.identifier.rawValue == "graph" {
                    str = "●"
                    color = NSColor.graphBrown
                    if let flag = self.synapseGraphHiddens[self.synapseCrystalInfo.ay.key], flag {
                        alpha = 0.2
                    }
                }
            }
            else if self.tableRows[row] == "accelz" {
                if tableColumn.identifier.rawValue == "title" {
                    str = "Accel z"
                }
                else if tableColumn.identifier.rawValue == "value" {
                    if let synapseValues = self.synapseValues, let az = synapseValues.az {
                        str = String(format:"%.3f", CommonFunction.makeAccelerationValue(Float(az)))
                    }
                }
                else if tableColumn.identifier.rawValue == "graph" {
                    str = "●"
                    color = NSColor.graphPink
                    if let flag = self.synapseGraphHiddens[self.synapseCrystalInfo.az.key], flag {
                        alpha = 0.2
                    }
                }
            }
            else if self.tableRows[row] == "gyrox" {
                if tableColumn.identifier.rawValue == "title" {
                    str = "Gyro x"
                }
                else if tableColumn.identifier.rawValue == "value" {
                    if let synapseValues = self.synapseValues, let gx = synapseValues.gx {
                        str = String(format:"%.3f", CommonFunction.makeGyroscopeValue(Float(gx)))
                    }
                }
            }
            else if self.tableRows[row] == "gyroy" {
                if tableColumn.identifier.rawValue == "title" {
                    str = "Gyro y"
                }
                else if tableColumn.identifier.rawValue == "value" {
                    if let synapseValues = self.synapseValues, let gy = synapseValues.gy {
                        str = String(format:"%.3f", CommonFunction.makeGyroscopeValue(Float(gy)))
                    }
                }
            }
            else if self.tableRows[row] == "gyroz" {
                if tableColumn.identifier.rawValue == "title" {
                    str = "Gyro z"
                }
                else if tableColumn.identifier.rawValue == "value" {
                    if let synapseValues = self.synapseValues, let gz = synapseValues.gz {
                        str = String(format:"%.3f", CommonFunction.makeGyroscopeValue(Float(gz)))
                    }
                }
            }
            else if self.tableRows[row] == "volt" {
                if tableColumn.identifier.rawValue == "title" {
                    str = "Volt"
                }
                else if tableColumn.identifier.rawValue == "value" {
                    if let synapseValues = self.synapseValues, let power = synapseValues.power {
                        str = "\(String(format:"%.1f", power)) V"
                    }
                }
            }
            else if self.tableRows[row] == "tvoc" {
                if tableColumn.identifier.rawValue == "title" {
                    str = "tVOC"
                }
                else if tableColumn.identifier.rawValue == "value" {
                    if let synapseValues = self.synapseValues, let tvoc = synapseValues.tvoc {
                        str = "\(String(tvoc))"
                    }
                }
            }
            else if self.tableRows[row] == "battery" {
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
            cell.textField?.textColor = color.withAlphaComponent(alpha)
            return cell
        }
        return nil
    }

    // MARK: mark - Action methods

    @objc private func onItemClicked() {

        //print("onItemClicked: row \(tableView.clickedRow), col \(tableView.clickedColumn)")
        if self.tableView.clickedColumn == 0, self.tableView.clickedRow >= 0, self.tableView.clickedRow < self.tableRows.count {
            let tableRow: String = self.tableRows[self.tableView.clickedRow]
            var key: String = ""
            if tableRow == "co2" {
                key = self.synapseCrystalInfo.co2.key
            }
            else if tableRow == "temperature" {
                key = self.synapseCrystalInfo.temp.key
            }
            else if tableRow == "humidity" {
                key = self.synapseCrystalInfo.hum.key
            }
            else if tableRow == "light" {
                key = self.synapseCrystalInfo.ill.key
            }
            else if tableRow == "airpressure" {
                key = self.synapseCrystalInfo.press.key
            }
            else if tableRow == "sound" {
                key = self.synapseCrystalInfo.sound.key
            }
            else if tableRow == "accelx" {
                key = self.synapseCrystalInfo.ax.key
            }
            else if tableRow == "accely" {
                key = self.synapseCrystalInfo.ay.key
            }
            else if tableRow == "accelz" {
                key = self.synapseCrystalInfo.az.key
            }
            if key.count > 0 {
                if let flag = self.synapseGraphHiddens[key] {
                    self.synapseGraphHiddens[key] = !flag
                }
                else {
                    self.synapseGraphHiddens[key] = true
                }
                self.tableView.reloadData(forRowIndexes: IndexSet(integer: self.tableView.clickedRow),
                                          columnIndexes: IndexSet(integer: self.tableView.clickedColumn))
                self.setGraphHiddensScript()
            }
        }
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

        self.updateGraphScript()
        /*let now: Date = Date()
        var canUpdate: Bool = true
        if let synapseGraphLastUpdate = self.synapseGraphLastUpdate, now.timeIntervalSince(synapseGraphLastUpdate) < self.synapseGraphUpdateInterval {
            canUpdate = false
        }
        if canUpdate {
            self.synapseGraphLastUpdate = now
            self.updateGraphScript()
        }*/
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
            let scalesData: Data = try JSONSerialization.data(withJSONObject: self.synapseGraphScales, options: [])
            self.graphScales = String(data: scalesData, encoding: .utf8)
            let hiddensData: Data = try JSONSerialization.data(withJSONObject: self.makeGraphHidddens(), options: [])
            self.graphHiddens = String(data: hiddensData, encoding: .utf8)
        }
        catch {
            print("JSON Encode Error: \(error.localizedDescription)")
            res = false
        }
        return res
    }

    func makeGraphHidddens() -> [Bool] {

        var hiddens: [Bool] = []
        for key in self.synapseGraphKeys {
            if let flag = self.synapseGraphHiddens[key] {
                hiddens.append(flag)
            }
            else {
                hiddens.append(false)
            }
        }
        return hiddens
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

        if let labels = self.graphLabels, let values = self.graphValues, let color = self.graphColor, let scales = self.graphScales, let hiddens = self.graphHiddens {
            let type: String = "line"
            let execJsFunc: String = "graph(\"\(type)\", \(labels), \(values), \(hiddens), \(color), \(scales));"
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

        if self.makeGraphParameter(), let labels = self.graphLabels, let values = self.graphValues, let scales = self.graphScales {
            let execJsFunc: String = "updateGraph(\(labels), \(values), \(scales));"
            //print("execJsFunc: \(execJsFunc)")
            self.webView.evaluateJavaScript(execJsFunc, completionHandler: { (object, error) -> Void in
                if let error = error {
                    print("JS Error: \(error.localizedDescription)")
                }
            })
        }
    }

    func setGraphHiddensScript() {

        if !self.synapseGraphFirstFlag {
            return
        }

        if self.makeGraphParameter(), let hiddens = self.graphHiddens {
            let execJsFunc: String = "setGraphHiddens(\(hiddens));"
            //print("execJsFunc: \(execJsFunc)")
            self.webView.evaluateJavaScript(execJsFunc, completionHandler: { (object, error) -> Void in
                if let error = error {
                    print("JS Error: \(error.localizedDescription)")
                }
            })
        }
    }
}
