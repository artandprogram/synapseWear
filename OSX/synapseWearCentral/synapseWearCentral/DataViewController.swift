//
//  DataViewController.swift
//  synapseWearCentral
//
//  Created by nakaguchi on 2019/06/04.
//  Copyright © 2019 art and program, Inc. For license and other information refer to https://github.com/artandprogram/synapseWear. All rights reserved.
//

import Cocoa

class DataViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {

    @IBOutlet var scrollView: NSScrollView!
    @IBOutlet var tableView: NSTableView!

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

    override func viewDidLoad() {
        super.viewDidLoad()

        self.viewSetting()
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

        NotificationCenter.default.addObserver(self, selector: #selector(self.resized), name: NSWindow.didResizeNotification, object: nil)
    }

    @objc func resized() {

        self.scrollView.frame = NSRect(x: 0,
                                       y: 0,
                                       width: NSApp.windows.last!.frame.size.width,
                                       height: NSApp.windows.last!.frame.size.height - 21.0)
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
}
