//
//  ViewController.swift
//  synapseWearCentral
//
//  Copyright © 2018年 art and program, Inc. For license and other information refer to https://github.com/artandprogram/synapseWear. All rights reserved.
//

import Cocoa
import Alamofire
import SwiftyJSON

struct CrystalStruct {

    var key: String = ""
    var name: String = ""

    init(key: String, name: String) {

        self.key = key
        self.name = name
    }
}

struct SynapseCrystalStruct {

    var co2: CrystalStruct = CrystalStruct(key: "co2", name: "CO2")
    var temp: CrystalStruct = CrystalStruct(key: "temp", name: "temperature")
    var hum: CrystalStruct = CrystalStruct(key: "hum", name: "humidity")
    var ill: CrystalStruct = CrystalStruct(key: "ill", name: "illumination")
    var press: CrystalStruct = CrystalStruct(key: "press", name: "air pressure")
    var sound: CrystalStruct = CrystalStruct(key: "sound", name: "environmental sound")
    var move: CrystalStruct = CrystalStruct(key: "move", name: "movement")
    var angle: CrystalStruct = CrystalStruct(key: "angle", name: "angle")
    var volt: CrystalStruct = CrystalStruct(key: "volt", name: "voltage")
    var led: CrystalStruct = CrystalStruct(key: "led", name: "LED")
}

enum SendMode {

    case I0
    case I1 // データ送信開始：0x02
    case I2 // データ送信停止: 0x03
    case I3 // 送信間隔確認・変更：0x04
    case I4 // センサー調整: 0x05
    case I5 // ファームウェアバージョン確認: 0x06
    case I6 // デバイス紐付け: 0x10
    case I7 // ファームウェアアップデート 0xfe
    case I8 // 強制ファームウェアアップデート: 0x11
    case I9 // 紐づけリセット：0x12

    case I5_3_4
    case I3_4
}

class ViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, NSComboBoxDataSource, NSComboBoxDelegate, RFduinoManagerDelegate, RFduinoDelegate {

    @IBOutlet var scrollView: NSScrollView!
    @IBOutlet var tableView: NSTableView!
    @IBOutlet var detailAreaView: NSScrollView!
    @IBOutlet var uuidLabel: NSTextField!
    @IBOutlet var valueLabel: NSTextField!
    @IBOutlet var valueLabelLower: NSTextField!
    @IBOutlet var firmwareLabel: NSTextField!
    @IBOutlet var firmwareComboBox: NSComboBox!
    @IBOutlet var firmwareUpdateButton: NSButton!
    @IBOutlet var firmwareCancelButton: NSButton!
    @IBOutlet var timeIntervalComboBox: NSComboBox!
    @IBOutlet var co2CheckButton: NSButton!
    @IBOutlet var tempCheckButton: NSButton!
    @IBOutlet var humCheckButton: NSButton!
    @IBOutlet var illCheckButton: NSButton!
    @IBOutlet var pressCheckButton: NSButton!
    @IBOutlet var soundCheckButton: NSButton!
    @IBOutlet var moveCheckButton: NSButton!
    @IBOutlet var angleCheckButton: NSButton!
    @IBOutlet var ledCheckButton: NSButton!
    @IBOutlet var sendButton: NSButton!
    @IBOutlet var oscSendButton: NSButton!
    @IBOutlet var oscIPAddressTextField: NSTextField!
    @IBOutlet var oscPortTextField: NSTextField!

    let synapseDataMax: Int = 10 * 60
    let synapseScanLimitTimeInterval: TimeInterval = 5.0
    let synapseTimeInterval: TimeInterval = 1.0
    let synapseValidSensors: [String: Bool] = [:]
    let synapseTimeIntervals: [TimeInterval] = [
        0.05,
        0.1,
        1.0,
        10.0,
        60.0,
        300.0,
        ]
    let synapseCrystalInfo: SynapseCrystalStruct = SynapseCrystalStruct()
    let synapseFileManager: SynapseFileManager = SynapseFileManager()

    var rfduinoManager: RFduinoManager!
    var rfduinos: [Any] = []
    var synapses: [SynapseObject] = []
    var synapseDeviceName: String = ""
    var firmwares: [[String: Any]] = []
    var checkScanningTimer: Timer?

    var loadingView: LoadingView!
    //var testView: NSView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view..s

        self.viewSetting()

        self.setRFduinoManager()
    }

    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }

    func viewSetting() {

        self.loadingView = LoadingView()
        self.loadingView.frame = NSRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        self.loadingView.isHidden = true
        self.view.addSubview(self.loadingView)
        /*
        self.testView = NSView()
        self.testView.frame = NSRect(x: 0, y: 0, width: 100, height: 100)
        self.testView.wantsLayer = true
        self.testView.layer?.backgroundColor = NSColor(calibratedRed: 255, green: 0, blue: 0, alpha: 1).cgColor
        self.testView.isHidden = true
        scrollView.addSubview(self.testView)*/

        self.tableView.action = #selector(onItemClicked)
        self.tableView.doubleAction = #selector(onItemDoubleClicked)
        self.tableView.delegate = self
        // For Firmware Update
        self.firmwareComboBox.usesDataSource = true
        self.firmwareComboBox.completes = true
        self.firmwareComboBox.isEditable = false
        self.firmwareComboBox.dataSource = self
        self.firmwareComboBox.delegate = self
        self.firmwareComboBox.isHidden = true
        self.firmwareUpdateButton.action = #selector(firmwareUpdateButtonAction)
        self.firmwareUpdateButton.isHidden = true
        self.firmwareCancelButton.action = #selector(firmwareCancelButtonAction)
        self.firmwareCancelButton.isHidden = true

        self.timeIntervalComboBox.usesDataSource = true
        self.timeIntervalComboBox.completes = true
        self.timeIntervalComboBox.isEditable = false
        self.timeIntervalComboBox.dataSource = self
        self.timeIntervalComboBox.delegate = self

        self.sendButton.action = #selector(sendButtonAction)

        self.oscSendButton.action = #selector(oscSendButtonAction)
        NotificationCenter.default.addObserver(self, selector: #selector(type(of: self).textDidChange(notification:)), name: NSControl.textDidChangeNotification, object: nil)

        self.setDetailAreaLabels()

        NotificationCenter.default.addObserver(self, selector: #selector(self.resized), name: NSWindow.didResizeNotification, object: nil)
    }

    // For Firmware Update
    func setSizeFirmwareViews() {

        self.firmwareLabel.frame = NSRect(x: self.firmwareLabel.frame.origin.x,
                                          y: self.firmwareLabel.frame.origin.y,
                                          width: self.detailAreaView.frame.size.width - self.firmwareLabel.frame.origin.x * 2,
                                          height: self.firmwareLabel.frame.size.height)
        if let path = Bundle.main.path(forResource: "appinfo", ofType: "plist"), let dict = NSDictionary(contentsOfFile: path) as? [String: Any], let enableFirmwearUpdate = dict["enable_firmwear_update"] as? Bool, enableFirmwearUpdate {
            self.firmwareLabel.sizeToFit()
            self.firmwareLabel.frame = NSRect(x: self.firmwareLabel.frame.origin.x,
                                              y: self.firmwareLabel.frame.origin.y,
                                              width: self.firmwareLabel.frame.size.width,
                                              height: 20.0)
        }

        self.firmwareComboBox.frame = NSRect(x: self.firmwareLabel.frame.origin.x + self.firmwareLabel.frame.size.width,
                                             y: self.firmwareComboBox.frame.origin.y,
                                             width: self.firmwareComboBox.frame.size.width,
                                             height: self.firmwareComboBox.frame.size.height)
        if self.firmwareComboBox.isHidden {
            self.firmwareUpdateButton.frame = NSRect(x: self.firmwareLabel.frame.origin.x + self.firmwareLabel.frame.size.width,
                                                     y: self.firmwareUpdateButton.frame.origin.y,
                                                     width: self.firmwareUpdateButton.frame.size.width,
                                                     height: self.firmwareUpdateButton.frame.size.height)
        }
        else {
            self.firmwareUpdateButton.frame = NSRect(x: self.firmwareComboBox.frame.origin.x + self.firmwareComboBox.frame.size.width,
                                                     y: self.firmwareUpdateButton.frame.origin.y,
                                                     width: self.firmwareUpdateButton.frame.size.width,
                                                     height: self.firmwareUpdateButton.frame.size.height)
        }
        if self.firmwareUpdateButton.isHidden {
            self.firmwareCancelButton.frame = NSRect(x: self.firmwareUpdateButton.frame.origin.x,
                                                     y: self.firmwareCancelButton.frame.origin.y,
                                                     width: self.firmwareCancelButton.frame.size.width,
                                                     height: self.firmwareCancelButton.frame.size.height)
        }
        else {
            self.firmwareCancelButton.frame = NSRect(x: self.firmwareUpdateButton.frame.origin.x + self.firmwareUpdateButton.frame.size.width - 5.0,
                                                     y: self.firmwareCancelButton.frame.origin.y,
                                                     width: self.firmwareCancelButton.frame.size.width,
                                                     height: self.firmwareCancelButton.frame.size.height)
        }
    }

    @objc func resized() {

        //print("resized: \(NSApp.windows.first!.frame.size.width)")
        self.detailAreaView.frame = NSRect(x: self.detailAreaView.frame.origin.x,
                                           y: 0,
                                           width: NSApp.windows.first!.frame.size.width,
                                           height: self.detailAreaView.frame.size.height)
        self.scrollView.frame = NSRect(x: self.scrollView.frame.origin.x,
                                       y: self.detailAreaView.frame.size.height,
                                       width: NSApp.windows.first!.frame.size.width,
                                       height: NSApp.windows.first!.frame.size.height - self.detailAreaView.frame.size.height - 21.0)
        self.uuidLabel.frame = NSRect(x: self.uuidLabel.frame.origin.x,
                                      y: self.uuidLabel.frame.origin.y,
                                      width: self.detailAreaView.frame.size.width - self.uuidLabel.frame.origin.x * 2,
                                      height: self.uuidLabel.frame.size.height)
        self.valueLabel.frame = NSRect(x: self.valueLabel.frame.origin.x,
                                       y: self.valueLabel.frame.origin.y,
                                       width: self.detailAreaView.frame.size.width - self.valueLabel.frame.origin.x * 2,
                                       height: self.valueLabel.frame.size.height)
        self.valueLabelLower.frame = NSRect(x: self.valueLabelLower.frame.origin.x,
                                            y: self.valueLabelLower.frame.origin.y,
                                            width: self.detailAreaView.frame.size.width - self.valueLabel.frame.origin.x * 2,
                                            height: self.valueLabelLower.frame.size.height)
        self.timeIntervalComboBox.frame = NSRect(x: self.timeIntervalComboBox.frame.origin.x,
                                                 y: self.timeIntervalComboBox.frame.origin.y,
                                                 width: self.timeIntervalComboBox.frame.size.width,
                                                 height: self.timeIntervalComboBox.frame.size.height)
        self.loadingView.frame = NSRect(x: 0,
                                        y: 0,
                                        width: self.view.frame.size.width,
                                        height: self.view.frame.size.height)

        self.setSizeFirmwareViews()
    }

    // MARK: mark - Action methods

    @objc private func onItemClicked() {

        //print("onItemClicked: row \(tableView.clickedRow), col \(tableView.clickedColumn)")
        self.setDetailAreaLabels()

        /*if tableView.clickedRow >= 0 && tableView.clickedColumn >= 0 {
            let rowRect = tableView.rect(ofRow: tableView.clickedRow)
            let columnRect = tableView.rect(ofColumn: tableView.clickedColumn)
            //print("onItemClicked ofRow: \(rowRect) ofColumn: \(columnRect)")
            self.testView.frame = NSRect(x: columnRect.origin.x, y: rowRect.origin.y+23, width: columnRect.size.width, height: rowRect.size.height)
            self.testView.isHidden = false
        }
        if tableView.clickedRow >= 0 && tableView.clickedColumn >= 0 {
            let v = self.tableView.view(atColumn: tableView.clickedColumn, row: tableView.clickedRow, makeIfNecessary: false)
            if let v = v as? FirmwearView {
                print("onItemClicked: \(v)")
            }
        }*/
    }

    @objc private func onItemDoubleClicked() {

        //print("onItemDoubleClicked: row \(tableView.clickedRow), col \(tableView.clickedColumn)")
        if tableView.clickedRow < self.synapses.count, let synapse = self.synapses[tableView.clickedRow].synapse {
            if tableView.clickedColumn == 1 {
                if self.synapses[tableView.clickedRow].synapseValues.isConnected {
                    self.synapses[tableView.clickedRow].synapseScanLatestDate = Date()
                    synapse.disconnect()
                }
                else {
                    if let date = self.synapses[tableView.clickedRow].synapseScanLatestDate, date.timeIntervalSinceNow < -self.synapseScanLimitTimeInterval {
                        return
                    }

                    self.rfduinoManager.connect(synapse)

                    if self.synapses[tableView.clickedRow].synapseDataSaveDir == nil && !self.synapses[tableView.clickedRow].synapseDataSaveDirChecked {
                        self.setSynapseDataSaveDir(tableView.clickedRow)
                    }
                    self.synapses[tableView.clickedRow].synapseDataSaveDirChecked = true
                }
            }
            else if tableView.clickedColumn == 3 {
                self.setSynapseDataSaveDir(tableView.clickedRow)
            }
        }
    }

    @objc private func firmwareUpdateButtonAction() {

        if self.firmwareComboBox.isHidden {
            self.getFirmwareData()
        }
        else {
            self.updateFirmwareData()
        }
    }

    @objc private func firmwareCancelButtonAction() {

        if !self.firmwareComboBox.isHidden {
            self.firmwareComboBox.isHidden = true
            self.setFirmwareSettingArea()
        }
    }

    @objc private func sendButtonAction() {

        //print("sendButtonAction")
        if tableView.selectedRow >= 0 && tableView.selectedRow < self.synapses.count {
            if self.timeIntervalComboBox.indexOfSelectedItem >= 0 && self.timeIntervalComboBox.indexOfSelectedItem < self.synapseTimeIntervals.count {
                self.synapses[tableView.selectedRow].synapseTimeInterval = self.synapseTimeIntervals[self.timeIntervalComboBox.indexOfSelectedItem]
            }

            self.synapses[tableView.selectedRow].synapseValidSensors[synapseCrystalInfo.co2.key] = false
            if self.co2CheckButton.state == .on {
                self.synapses[tableView.selectedRow].synapseValidSensors[synapseCrystalInfo.co2.key] = true
            }
            self.synapses[tableView.selectedRow].synapseValidSensors[synapseCrystalInfo.temp.key] = false
            if self.tempCheckButton.state == .on {
                self.synapses[tableView.selectedRow].synapseValidSensors[synapseCrystalInfo.temp.key] = true
            }
            self.synapses[tableView.selectedRow].synapseValidSensors[synapseCrystalInfo.hum.key] = false
            if self.humCheckButton.state == .on {
                self.synapses[tableView.selectedRow].synapseValidSensors[synapseCrystalInfo.hum.key] = true
            }
            self.synapses[tableView.selectedRow].synapseValidSensors[synapseCrystalInfo.ill.key] = false
            if self.illCheckButton.state == .on {
                self.synapses[tableView.selectedRow].synapseValidSensors[synapseCrystalInfo.ill.key] = true
            }
            self.synapses[tableView.selectedRow].synapseValidSensors[synapseCrystalInfo.press.key] = false
            if self.pressCheckButton.state == .on {
                self.synapses[tableView.selectedRow].synapseValidSensors[synapseCrystalInfo.press.key] = true
            }
            self.synapses[tableView.selectedRow].synapseValidSensors[synapseCrystalInfo.sound.key] = false
            if self.soundCheckButton.state == .on {
                self.synapses[tableView.selectedRow].synapseValidSensors[synapseCrystalInfo.sound.key] = true
            }
            self.synapses[tableView.selectedRow].synapseValidSensors[synapseCrystalInfo.move.key] = false
            if self.moveCheckButton.state == .on {
                self.synapses[tableView.selectedRow].synapseValidSensors[synapseCrystalInfo.move.key] = true
            }
            self.synapses[tableView.selectedRow].synapseValidSensors[synapseCrystalInfo.angle.key] = false
            if self.angleCheckButton.state == .on {
                self.synapses[tableView.selectedRow].synapseValidSensors[synapseCrystalInfo.angle.key] = true
            }
            self.synapses[tableView.selectedRow].synapseValidSensors[synapseCrystalInfo.led.key] = false
            if self.ledCheckButton.state == .on {
                self.synapses[tableView.selectedRow].synapseValidSensors[synapseCrystalInfo.led.key] = true
            }

            self.sendSynapseSettingToDeviceStart(self.synapses[tableView.selectedRow])
            self.synapses[tableView.selectedRow].saveSynapseSettingData(isSaveDir: false, isSaveSendData: true, isSaveOSCData: false)
        }
    }

    @objc private func oscSendButtonAction() {
        
        self.oscSendButton.title = "Send Off"
        self.oscIPAddressTextField.isEnabled = false
        //self.oscIPAddressTextField.isEditable = false
        self.oscIPAddressTextField.stringValue = ""
        self.oscPortTextField.isEnabled = false
        self.oscPortTextField.stringValue = ""
        if self.oscSendButton.isEnabled == true {
            if self.tableView.selectedRow >= 0 && self.tableView.selectedRow < self.synapses.count {
                self.oscIPAddressTextField.stringValue = self.synapses[self.tableView.selectedRow].oscIPAddress
                self.oscPortTextField.stringValue = self.synapses[self.tableView.selectedRow].oscPort
            }

            if self.oscSendButton.state == .on {
                self.oscSendButton.title = "Send On"
                //self.oscIPAddressTextField.currentEditor()?.selectedRange = NSMakeRange(0, 0)

                if self.tableView.selectedRow >= 0 && self.tableView.selectedRow < self.synapses.count {
                    self.synapses[self.tableView.selectedRow].setOnOSC()
                }
            }
            else {
                self.oscIPAddressTextField.isEnabled = true
                self.oscPortTextField.isEnabled = true

                if self.tableView.selectedRow >= 0 && self.tableView.selectedRow < self.synapses.count {
                    self.synapses[self.tableView.selectedRow].setOffOSC()
                }
            }
        }
    }

    @objc private func textDidChange(notification: Notification) {

        if self.tableView.selectedRow >= 0 && self.tableView.selectedRow < self.synapses.count {
            if let textField = notification.object as? NSTextField {
                if textField == self.oscIPAddressTextField {
                    self.synapses[self.tableView.selectedRow].oscIPAddress = textField.stringValue
                }
                else if textField == self.oscPortTextField {
                    self.synapses[self.tableView.selectedRow].oscPort = textField.stringValue
                }

                self.synapses[tableView.selectedRow].saveSynapseSettingData(isSaveDir: false, isSaveSendData: false, isSaveOSCData: true)
            }
        }
    }

    // MARK: mark - OpenPanel methods

    func setSynapseDataSaveDir(_ index: Int) {

        if index < 0 || index >= self.synapses.count {
            return
        }

        let openPanel: NSOpenPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = true
        openPanel.canCreateDirectories = false
        openPanel.canChooseFiles = false
        if let url = self.synapses[index].synapseDataSaveDir {
            openPanel.directoryURL = url
        }
        else if let url = self.synapses[index].synapseDataSaveDirDefault {
            openPanel.directoryURL = url
        }
        openPanel.begin { (result) -> Void in
            if result.rawValue == NSApplication.ModalResponse.OK.rawValue {
                if let url = openPanel.url {
                    //print("openPanel: \(url.absoluteString)")
                    self.synapses[index].synapseDataSaveDir = url
                    if let synapse = self.synapses[index].synapse {
                        if self.synapseFileManager.dirCheck(baseURL: url, uuid: synapse.peripheral.identifier.uuidString) {
                            self.synapses[index].saveSynapseSettingData(isSaveDir: true, isSaveSendData: false, isSaveOSCData: false)
                        }
                    }
                    self.tableView.reloadData(forRowIndexes: IndexSet(integer: index), columnIndexes: IndexSet(integer: 3))
                }
            }
        }
    }

    // MARK: mark - DetailArea methods

    func setDetailAreaLabels() {

        for subview in self.detailAreaView.contentView.subviews {
            subview.isHidden = true
            if tableView.selectedRow >= 0 && tableView.selectedRow < self.synapses.count {
                subview.isHidden = false
            }
        }

        self.setUUIDLabel()
        self.setValueLabel()
        self.setDetailAreaSettings()
        self.setFirmwareSettingArea()
        self.setOSCSettingArea()
    }

    func setUUIDLabel() {

        self.uuidLabel.stringValue = ""
        if tableView.selectedRow >= 0 && tableView.selectedRow < self.synapses.count {
            if let synapse = self.synapses[tableView.selectedRow].synapse {
                self.uuidLabel.stringValue = "UUID : \(self.uuidLabel.stringValue)\(synapse.peripheral.identifier.uuidString)"
            }
        }
    }

    func setValueLabel() {

        self.valueLabel.stringValue = ""
        self.valueLabelLower.stringValue = ""
        if tableView.selectedRow >= 0 && tableView.selectedRow < self.synapses.count {
            self.valueLabel.stringValue = self.synapses[tableView.selectedRow].getSynapseValues()
            self.valueLabelLower.stringValue = self.synapses[tableView.selectedRow].getSynapseValuesLower()
        }
    }

    func setDetailAreaSettings() {

        self.timeIntervalComboBox.isEnabled = false
        self.co2CheckButton.isEnabled = false
        self.tempCheckButton.isEnabled = false
        self.humCheckButton.isEnabled = false
        self.illCheckButton.isEnabled = false
        self.pressCheckButton.isEnabled = false
        self.soundCheckButton.isEnabled = false
        self.moveCheckButton.isEnabled = false
        self.angleCheckButton.isEnabled = false
        self.ledCheckButton.isEnabled = false
        self.sendButton.isEnabled = false
        self.timeIntervalComboBox.stringValue = ""
        self.co2CheckButton.state = .off
        self.tempCheckButton.state = .off
        self.humCheckButton.state = .off
        self.illCheckButton.state = .off
        self.pressCheckButton.state = .off
        self.soundCheckButton.state = .off
        self.moveCheckButton.state = .off
        self.angleCheckButton.state = .off
        self.ledCheckButton.state = .off
        if tableView.selectedRow >= 0 && tableView.selectedRow < self.synapses.count {
            for (index, time) in self.synapseTimeIntervals.enumerated() {
                if self.synapses[tableView.selectedRow].synapseTimeInterval == time {
                    self.timeIntervalComboBox.selectItem(at: index)
                    break
                }
            }

            self.co2CheckButton.state = .on
            if let flag = self.synapses[tableView.selectedRow].synapseValidSensors[synapseCrystalInfo.co2.key], !flag {
                self.co2CheckButton.state = .off
            }
            self.tempCheckButton.state = .on
            if let flag = self.synapses[tableView.selectedRow].synapseValidSensors[synapseCrystalInfo.temp.key], !flag {
                self.tempCheckButton.state = .off
            }
            self.humCheckButton.state = .on
            if let flag = self.synapses[tableView.selectedRow].synapseValidSensors[synapseCrystalInfo.hum.key], !flag {
                self.humCheckButton.state = .off
            }
            self.illCheckButton.state = .on
            if let flag = self.synapses[tableView.selectedRow].synapseValidSensors[synapseCrystalInfo.ill.key], !flag {
                self.illCheckButton.state = .off
            }
            self.pressCheckButton.state = .on
            if let flag = self.synapses[tableView.selectedRow].synapseValidSensors[synapseCrystalInfo.press.key], !flag {
                self.pressCheckButton.state = .off
            }
            self.soundCheckButton.state = .on
            if let flag = self.synapses[tableView.selectedRow].synapseValidSensors[synapseCrystalInfo.sound.key], !flag {
                self.soundCheckButton.state = .off
            }
            self.moveCheckButton.state = .on
            if let flag = self.synapses[tableView.selectedRow].synapseValidSensors[synapseCrystalInfo.move.key], !flag {
                self.moveCheckButton.state = .off
            }
            self.angleCheckButton.state = .on
            if let flag = self.synapses[tableView.selectedRow].synapseValidSensors[synapseCrystalInfo.angle.key], !flag {
                self.angleCheckButton.state = .off
            }
            self.ledCheckButton.state = .on
            if let flag = self.synapses[tableView.selectedRow].synapseValidSensors[synapseCrystalInfo.led.key], !flag {
                self.ledCheckButton.state = .off
            }

            if self.synapses[tableView.selectedRow].synapseValues.isConnected {
                self.timeIntervalComboBox.isEnabled = true
                self.co2CheckButton.isEnabled = true
                self.tempCheckButton.isEnabled = true
                self.humCheckButton.isEnabled = true
                self.illCheckButton.isEnabled = true
                self.pressCheckButton.isEnabled = true
                self.soundCheckButton.isEnabled = true
                self.moveCheckButton.isEnabled = true
                self.angleCheckButton.isEnabled = true
                self.ledCheckButton.isEnabled = true
                self.sendButton.isEnabled = true
            }
        }
    }

    func setFirmwareSettingArea() {

        self.firmwareLabel.stringValue = ""
        self.firmwareUpdateButton.isHidden = true // For Firmware Update
        self.firmwareCancelButton.isHidden = true // For Firmware Update
        self.firmwareLabel.stringValue = "Firmware Version : "
        if tableView.selectedRow >= 0 && tableView.selectedRow < self.synapses.count {
            if self.synapses[tableView.selectedRow].synapseFirmwareIsUpdate {
                self.firmwareComboBox.isHidden = true
                self.firmwareUpdateButton.isHidden = true
                self.firmwareCancelButton.isHidden = false

                if let synapseFirmwareInfo = self.synapses[tableView.selectedRow].synapseUpdateFirmwareInfo, let version = synapseFirmwareInfo["device_version"] as? String {
                    self.firmwareLabel.stringValue = "\(self.firmwareLabel.stringValue)\(version)"
                    if let date = synapseFirmwareInfo["date"] as? String {
                        self.firmwareLabel.stringValue = "\(self.firmwareLabel.stringValue) (\(date)) "
                    }
                }
                self.firmwareLabel.stringValue = "\(self.firmwareLabel.stringValue)\(self.synapses[tableView.selectedRow].synapseFirmwareUpdateMessage)"
            }
            else {
                if self.synapses[tableView.selectedRow].synapseValues.isConnected {
                    self.firmwareUpdateButton.isHidden = true
                    if let path = Bundle.main.path(forResource: "appinfo", ofType: "plist"), let dict = NSDictionary(contentsOfFile: path) as? [String: Any], let enableFirmwearUpdate = dict["enable_firmwear_update"] as? Bool, enableFirmwearUpdate {
                        self.firmwareUpdateButton.isHidden = false
                    }

                    if !self.firmwareComboBox.isHidden {
                        self.firmwareCancelButton.isHidden = false
                    }
                }
                else {
                    self.firmwareComboBox.isHidden = true
                }

                if self.firmwareComboBox.isHidden {
                    if let version = self.synapses[tableView.selectedRow].synapseFirmwareInfo["device_version"] as? String {
                        self.firmwareLabel.stringValue = "\(self.firmwareLabel.stringValue)\(version)"
                        if let date = self.synapses[tableView.selectedRow].synapseFirmwareInfo["date"] as? String {
                            self.firmwareLabel.stringValue = "\(self.firmwareLabel.stringValue) (\(date))"
                        }
                    }
                }
            }
        }
        else {
            self.firmwareComboBox.isHidden = true
        }
        self.setSizeFirmwareViews()   // For Firmware Update
    }

    func setOSCSettingArea() {

        self.oscSendButton.isEnabled = false
        if tableView.selectedRow >= 0 && tableView.selectedRow < self.synapses.count {
            self.oscSendButton.isEnabled = true
            self.oscSendButton.state = .off
            if self.synapses[tableView.selectedRow].oscSending {
                self.oscSendButton.state = .on
            }
        }
        self.oscSendButtonAction()
    }

    func getFirmwareData() {

        self.loadingView.isHidden = false
        self.loadingView.indicator.startAnimation(nil)

        let apiFirmware: ApiFirmware = ApiFirmware(url: nil)
        apiFirmware.getFirmwareDataRequest(success: {
            (json: JSON?) in

            if let res = json, let firmwares = res["firmware"].array {
                self.firmwares = []
                for firmware in firmwares {
                    var data: [String: Any] = [:]
                    if let iosVer = firmware["ios_version"].string {
                        data["ios_version"] = iosVer
                    }
                    else if let iosVer = firmware["ios_version"].number {
                        data["ios_version"] = "\(iosVer)"
                    }
                    if let devVer = firmware["device_version"].string {
                        data["device_version"] = devVer
                    }
                    else if let devVer = firmware["device_version"].number {
                        data["device_version"] = "\(devVer)"
                    }
                    if let hexFile = firmware["hex_file"].string {
                        data["hex_file"] = hexFile
                    }
                    if let date = firmware["date"].string {
                        data["date"] = date
                    }
                    //print("data: \(data)")
                    self.firmwares.append(data)
                }
            }

            self.firmwareComboBox.isHidden = false
            self.firmwareComboBox.reloadData()
            if self.tableView.selectedRow >= 0 && self.tableView.selectedRow < self.synapses.count {
                if let version = self.synapses[self.tableView.selectedRow].synapseFirmwareInfo["device_version"] as? String, let date = self.synapses[self.tableView.selectedRow].synapseFirmwareInfo["date"] as? String {
                    for (index, data) in self.firmwares.enumerated() {
                        if let firmwareVersion = data["device_version"] as? String, let firmwareDate = data["date"] as? String {
                            if firmwareVersion == version && firmwareDate == date {
                                self.firmwareComboBox.selectItem(at: index)
                                break
                            }
                        }
                    }
                }
            }
            self.setFirmwareSettingArea()

            self.loadingView.indicator.stopAnimation(nil)
            self.loadingView.isHidden = true
        }, fail: {
            (error: Error?) in
            print("res -> error: \(String(describing: error))")

            self.loadingView.indicator.stopAnimation(nil)
            self.loadingView.isHidden = true
        })
    }

    func updateFirmwareData() {

        if self.tableView.selectedRow >= 0 && self.tableView.selectedRow < self.synapses.count {
            if self.firmwareComboBox.indexOfSelectedItem >= 0 && self.firmwareComboBox.indexOfSelectedItem < self.firmwares.count {
                if let path = Bundle.main.path(forResource: "appinfo", ofType: "plist"), let dict = NSDictionary(contentsOfFile: path) as? [String: Any], let host = dict["firmware_domain"] as? String, let hexFile = self.firmwares[self.firmwareComboBox.indexOfSelectedItem]["hex_file"] as? String, let url = URL(string: "\(host)\(hexFile)") {
                    self.sendDataToDevice(self.synapses[self.tableView.selectedRow], url: url, firmwareInfo: self.firmwares[self.firmwareComboBox.indexOfSelectedItem])
                }
            }
        }
    }

    // MARK: mark - TableView methods

    func numberOfRows(in tableView: NSTableView) -> Int {

        return synapses.count
    }

    /*func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {

        //print("tableColumn: \(String(describing: tableColumn?.title))")
        var str: String = ""
        if let tableColumn = tableColumn, row < self.synapses.count {
            if tableColumn.identifier.rawValue == "UUID" {
                if let synapse = self.synapses[row].synapse {
                    str = synapse.peripheral.identifier.uuidString
                }
            }
            else if tableColumn.identifier.rawValue == "Connect" {
                if self.synapses[row].synapseValues.isConnected {
                    str = "○"
                }
            }
            else if tableColumn.identifier.rawValue == "Directory" {
                if let url = self.synapses[row].synapseDataSaveDir {
                    str = url.path
                }
            }
        }
        return str
    }*/
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {

        //print("tableView viewFor")
        if let tableColumn = tableColumn {
            /*
            if tableColumn.identifier.rawValue == "Firmwear" {
                let cell: FirmwearView? = tableView.makeView(withIdentifier: tableColumn.identifier, owner: self) as? FirmwearView
                /*if let view = tableView.makeView(withIdentifier: tableColumn.identifier, owner: self) as? FirmwearView {
                    print("viewFor: \(view)")
                    cell = view
                }
                else {
                    cell = FirmwearView()
                }*/
                if self.synapses[row].synapseFirmwareIsUpdate {
                    cell?.nowVersionLabel.isHidden = false
                    cell?.firmwearComboBox.isHidden = false
                    cell?.updateButton.isHidden = false
                }
                else {
                    cell?.nowVersionLabel.isHidden = false
                    cell?.firmwearComboBox.isHidden = true
                    cell?.updateButton.isHidden = true

                    var str: String = ""
                    if let version = self.synapses[row].synapseFirmwareInfo["device_version"] as? String {
                        str = "\(str)\(version)"
                        if let date = self.synapses[row].synapseFirmwareInfo["date"] as? String {
                            str = "\(str) (\(date))"
                        }
                    }
                    cell?.nowVersionLabel.stringValue = str
                }
                return cell
            }*/

            var str: String = ""
            if tableColumn.identifier.rawValue == "UUID" {
                if let synapse = self.synapses[row].synapse {
                    str = synapse.peripheral.identifier.uuidString
                }
            }
            else if tableColumn.identifier.rawValue == "Connect" {
                if self.synapses[row].synapseValues.isConnected {
                    str = "○"
                }
                else if let date = self.synapses[row].synapseScanLatestDate, date.timeIntervalSinceNow < -self.synapseScanLimitTimeInterval {
                    str = "×"
                }
                //print("Connect tableColumn: \(self.synapses[row].synapseScanLatestDate)")
            }
            else if tableColumn.identifier.rawValue == "Received" {
                str = "\(self.synapses[row].synapseReceivedCount)"
            }
            else if tableColumn.identifier.rawValue == "Directory" {
                if let url = self.synapses[row].synapseDataSaveDir {
                    str = url.path
                }
            }
            //print("viewFor: \(str)")
            let cell = tableView.makeView(withIdentifier: tableColumn.identifier, owner: self) as! NSTableCellView
            cell.textField?.stringValue = str
            //print("viewFor: \(cell.subviews.count)")
            return cell
        }
        return nil
    }

    /*func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {

        return 26.0
    }*/

    // MARK: mark - ComboBox methods

    func numberOfItems(in comboBox: NSComboBox) -> Int {

        if comboBox == self.timeIntervalComboBox {
            return self.synapseTimeIntervals.count
        }
        else if comboBox == self.firmwareComboBox {
            return self.firmwares.count
        }
        return 0
    }

    func comboBox(_ comboBox: NSComboBox, objectValueForItemAt index: Int) -> Any? {

        if comboBox == self.timeIntervalComboBox {
            if index >= 0 && index < self.synapseTimeIntervals.count {
                return self.synapseTimeIntervals[index]
            }
        }
        else if comboBox == self.firmwareComboBox {
            if index >= 0 && index < self.firmwares.count {
                if let firmwareVersion = self.firmwares[index]["device_version"] as? String, let firmwareDate = self.firmwares[index]["date"] as? String {
                    return "\(firmwareVersion) (\(firmwareDate))"
                }
            }
        }
        return nil
    }

    // MARK: mark - Synapse Device methods

    func setRFduinoManager() {

        if let path = Bundle.main.path(forResource: "appinfo", ofType: "plist"), let dict = NSDictionary(contentsOfFile: path) as? [String: Any], let name = dict["device_name"] as? String {
            self.synapseDeviceName = name
        }

        self.rfduinoManager = RFduinoManager()
        self.rfduinoManager.delegate = self

        self.checkScanningTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.checkScanning), userInfo: nil, repeats: true)
        self.checkScanningTimer?.fire()
    }

    @objc func checkScanning() {

        for i in 0..<self.synapses.count {
            self.tableView.reloadData(forRowIndexes: IndexSet(integer: i), columnIndexes: IndexSet(integersIn: 1..<3))
        }
    }

    func setRFduinos() {

        self.rfduinos = []
        if let rfduinos = self.rfduinoManager.rfduinos {
            for (_, rfduino) in rfduinos.enumerated() {
                if let rfduino = rfduino as? RFduino {
                    self.checkSynapse(rfduino)
                }
            }
        }
    }
    
    func checkSynapse(_ rfduino: RFduino) {

        //print("rfduino.outOfRange: \(rfduino.outOfRange)")
        //print("checkSynapse: \(String(describing: String(data: rfduino.advertisementData, encoding: String.Encoding.utf8)))")
        if self.synapseDeviceName.count > 0 && rfduino.outOfRange == 0 && rfduino.advertisementData == self.synapseDeviceName.data(using: String.Encoding.utf8) {
            //print("checkSynapse: \(rfduino.peripheral.identifier)")
            self.rfduinos.append(rfduino)

            var synapseIndex: Int = -1
            for (index, synapseObject) in self.synapses.enumerated() {
                if let synapse = synapseObject.synapse, synapse.peripheral.identifier == rfduino.peripheral.identifier {
                    synapseObject.synapseScanLatestDate = Date()
                    synapseIndex = index
                    break
                }
            }
            if synapseIndex >= 0 && synapseIndex < self.synapses.count {
                let synapseObject: SynapseObject = self.synapses[synapseIndex]
                synapseObject.synapse = rfduino
                synapseObject.synapse?.delegate = self
                synapseObject.synapseScanLatestDate = Date()
                self.synapses[synapseIndex] = synapseObject
            }
            else {
                let synapseObject: SynapseObject = SynapseObject(rfduino)
                synapseObject.synapse?.delegate = self
                synapseObject.synapseScanLatestDate = Date()
                synapseObject.vc = self
                self.synapses.append(synapseObject)

                self.tableView.reloadData()
            }
        }
    }

    func startCommunicationSynapse(_ synapseObject: SynapseObject) {

        synapseObject.synapseSendModeNext = SendMode.I5_3_4
        synapseObject.synapseSendModeSuspension = true
        self.sendResetToDevice(synapseObject)
    }
    
    func setSynapseData(synapseObject: SynapseObject) {

        let now: Date = Date()
        let data: [UInt8] = synapseObject.receiveData
        synapseObject.synapseData.insert(["time": now.timeIntervalSince1970, "data": data, "uuid": synapseObject.synapse?.peripheral.identifier.uuidString], at: 0)
        if synapseObject.synapseData.count > self.synapseDataMax {
            synapseObject.synapseData.removeLast()
        }
        //print("setSynapseData: \(time)")
        synapseObject.setSynapseValues()
        synapseObject.synapseReceivedCount += 1

        if let baseURL = synapseObject.synapseDataSaveDir, let synapse = synapseObject.synapse {
            DispatchQueue.global(qos: .background).async {
                _ = self.synapseFileManager.setValues(baseURL: baseURL, uuid: synapse.peripheral.identifier.uuidString, values: Data(bytes: data), date: now)
            }
        }
    }

    // MARK: mark - RFduinoManagerDelegate methods

    func didDiscover(_ rfduino: RFduino!) -> Void {

        //print("didDiscoverRFduino: \(rfduino)")
        self.setRFduinos()
    }

    func didUpdateDiscoveredRFduino(_ rfduino: RFduino!) -> Void {

        //print("didUpdateDiscoveredRFduino: \(rfduino)")
        self.setRFduinos()
    }

    func didConnect(_ rfduino: RFduino!) -> Void {

        //print("didConnectRFduino: \(rfduino)")
        //self.rfduinoManager.stopScan()
    }

    func didLoadServiceRFduino(_ rfduino: RFduino!) -> Void {

        //print("didLoadServiceRFduino: \(rfduino)")
        print("didLoadServiceRFduino UUID: \(rfduino.peripheral.identifier)")
        for synapseObject in self.synapses {
            if let synapse = synapseObject.synapse, synapse.peripheral.identifier == rfduino.peripheral.identifier {
                self.startCommunicationSynapse(synapseObject)
                break
            }
        }
    }

    func didDisconnectRFduino(_ rfduino: RFduino!) -> Void {

        print("didDisconnectRFduino: \(String(describing: rfduino))")
        for (index, synapseObject) in self.synapses.enumerated() {
            if let synapse = synapseObject.synapse, synapse.peripheral.identifier == rfduino.peripheral.identifier {
                synapseObject.disconnectSynapse()

                self.tableView.reloadData(forRowIndexes: IndexSet(integer: index), columnIndexes: IndexSet(integer: 1))
                //self.tableView.reloadData(forRowIndexes: IndexSet(integer: index), columnIndexes: IndexSet(integersIn: 1..<3))
                if index == tableView.selectedRow {
                    self.setDetailAreaLabels()
                }

                break
            }
        }
    }

    func shouldDisplayAlertTitled(_ title: String!, messageBody: String!, peripheral: CBPeripheral?) -> Void {
        
        //print("shouldDisplayAlertTitled: \(title)")
        if title != "Bluetooth LE Support", let peripheral = peripheral {
            for (index, synapseObject) in self.synapses.enumerated() {
                if let synapse = synapseObject.synapse, synapse.peripheral.identifier == peripheral.identifier {
                    synapseObject.disconnectSynapse()

                    self.tableView.reloadData(forRowIndexes: IndexSet(integer: index), columnIndexes: IndexSet(integer: 1))
                    //self.tableView.reloadData(forRowIndexes: IndexSet(integer: index), columnIndexes: IndexSet(integersIn: 1..<3))
                    if index == tableView.selectedRow {
                        self.setDetailAreaLabels()
                    }

                    break
                }
            }
        }
        /*else {
            let alert: UIAlertController = UIAlertController(title: title, message: messageBody, preferredStyle: UIAlertControllerStyle.alert)
            let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {
                (action:UIAlertAction!) -> Void in
            })
            alert.addAction(defaultAction)
            self.present(alert, animated: true, completion: nil)
        }*/
    }

    // MARK: mark - RFduinoDelegate methods
    
    func didReceive(_ data: Data!, peripheralID: UUID, advertisementData: Data, advertisementRSSI: NSNumber) -> Void {
        //print("\(Date()) didReceive byte: \([UInt8](data))\nperipheralID: \(peripheralID)\nadvData: \(String(describing: String(bytes: advertisementData, encoding: .utf8)))\nRSSI: \(Int(advertisementRSSI))")
        /*let val = data.map {
         String(format: "%.2hhx", $0)
         }.joined()
         print("val: \(val)")*/

        for (index, synapseObject) in self.synapses.enumerated() {
            if let synapse = synapseObject.synapse, synapse.peripheral.identifier == peripheralID {
                if synapseObject.synapseSendMode == SendMode.I0 {
                    self.setReceiveData(synapseObject, data: data, index: index)
                }
                else if synapseObject.synapseSendMode == SendMode.I1 {
                    self.receiveAccessKeyToDevice(synapseObject, data: data, index: index)
                }
                else if synapseObject.synapseSendMode == SendMode.I2 {
                    self.receiveStopToDevice(synapseObject, data: data)
                }
                else if synapseObject.synapseSendMode == SendMode.I3 {
                    self.receiveTimeIntervalToDevice(synapseObject, data: data)
                }
                else if synapseObject.synapseSendMode == SendMode.I4 {
                    self.receiveSensorToDevice(synapseObject, data: data)
                }
                else if synapseObject.synapseSendMode == SendMode.I5 {
                    self.receiveFirmwareVersionToDevice(synapseObject, data: data, index: index)
                }
                else if synapseObject.synapseSendMode == SendMode.I6 {
                    self.receiveConnectionRequestToDevice(synapseObject, data: data)
                }
                break
            }
        }
    }

    func setReceiveData(_ synapseObject: SynapseObject, data: Data, index: Int = -1) {

        let minLength: Int = 6
        let bytes: [UInt8] = [UInt8](data)
        var restBytes: [UInt8]? = nil
        var cnt: Int = 0
        if synapseObject.receiveData.count > 2 {
            cnt = Int(synapseObject.receiveData[2])
        }
        else if bytes.count > 2 && Int(bytes[0]) == 0 && Int(bytes[1]) == 255 {
            cnt = Int(bytes[2])
        }
        if cnt >= minLength {
            for i in 0..<bytes.count {
                if synapseObject.receiveData.count < cnt {
                    synapseObject.receiveData.append(bytes[i])
                }
                else {
                    if restBytes == nil {
                        restBytes = []
                    }
                    restBytes?.append(bytes[i])
                }
            }
        }
        if cnt >= minLength && synapseObject.receiveData.count == cnt {
            //print("self.receiveData: \(self.receiveData)")
            if Int(synapseObject.receiveData[0]) == 0 && Int(synapseObject.receiveData[1]) == 255 && Int(synapseObject.receiveData[synapseObject.receiveData.count - 2]) == 0 && Int(synapseObject.receiveData[synapseObject.receiveData.count - 1]) == 255 {
                if Int(synapseObject.receiveData[3]) == 2 {
                    self.setSynapseData(synapseObject: synapseObject)

                    //print("setReceiveData: \(index) - \(tableView.selectedRow)")
                    if index == tableView.selectedRow {
                        //print("setReceiveData: \(index)")
                        self.setValueLabel()
                    }
                    /*if index >= 0 {
                        //print("setReceiveData: \(index)")
                        self.tableView.reloadData(forRowIndexes: IndexSet(integer: index), columnIndexes: IndexSet(integer: 2))
                    }*/
                }
            }

            synapseObject.receiveData = []
            if let bytes = restBytes, bytes.count > 2, Int(bytes[0]) == 0, Int(bytes[1]) == 255, Int(bytes[2]) >= minLength {
                synapseObject.receiveData = bytes
            }
        }
        restBytes = nil
        //print("receiveData: \(self.receiveData)")
    }

    // MARK: mark - Send Data To synapseWear methods

    func sendAccessKeyToDevice(_ synapseObject: SynapseObject) {

        if let synapse = synapseObject.synapse, /*synapseObject.synapseUUID != nil,*/ let accessKey = synapseObject.synapseAccessKey {
            synapseObject.synapseSendMode = SendMode.I1
            var data: Data = Data(bytes: [0x02])
            if accessKey.count > 8 {
                data.append(accessKey.subdata(in: 0..<8))
            }
            else {
                data.append(accessKey)
            }
            print("sendAccessKeyToDevice: \([UInt8](data))")
            synapse.send(data)
        }
    }

    func receiveAccessKeyToDevice(_ synapseObject: SynapseObject, data: Data, index: Int = -1) {

        let length: Int = 1
        let bytes: [UInt8] = [UInt8](data)
        print("receiveAccessKeyToDevice: \(bytes)")
        if bytes.count == length {
            if Int(bytes[0]) == 0 {
                print("receiveAccessKeyToDevice OK")
                synapseObject.synapseValues.isConnected = true
                synapseObject.synapseSendModeSuspension = false
                synapseObject.synapseSendMode = SendMode.I0

                if index >= 0 {
                    self.tableView.reloadData(forRowIndexes: IndexSet(integer: index), columnIndexes: IndexSet(integer: 1))
                    if index == tableView.selectedRow {
                        self.setDetailAreaLabels()
                    }
                }
            }
            else {
                print("receiveAccessKeyToDevice NG")
                if synapseObject.synapseAccessKey != nil {
                    self.sendConnectionRequestToDevice(synapseObject)
                }
            }
        }
    }

    func sendStopToDevice(_ synapseObject: SynapseObject) {

        if let synapse = synapseObject.synapse, /*synapseObject.synapseUUID != nil,*/ let accessKey = synapseObject.synapseAccessKey {
            synapseObject.synapseSendModeSuspension = true
            synapseObject.synapseSendMode = SendMode.I2
            var data: Data = Data(bytes: [0x03])
            if accessKey.count > 8 {
                data.append(accessKey.subdata(in: 0..<8))
            }
            else {
                data.append(accessKey)
            }
            print("sendStopToDevice: \([UInt8](data))")
            synapse.send(data)
        }
        else {
            synapseObject.synapseSendModeNext = nil
        }
    }

    func receiveStopToDevice(_ synapseObject: SynapseObject, data: Data) {

        let length: Int = 1
        let bytes: [UInt8] = [UInt8](data)
        //print("receiveStopToDevice: \(bytes)")
        if bytes.count == length {
            if Int(bytes[0]) == 0 {
                print("receiveStopToDevice OK")
                if synapseObject.synapseSendModeNext == SendMode.I3_4 {
                    self.sendTimeIntervalToDevice(synapseObject)
                    return
                }
                else if synapseObject.synapseSendModeNext == SendMode.I3 {
                    self.sendTimeIntervalToDevice(synapseObject)
                }
                else if synapseObject.synapseSendModeNext == SendMode.I4 {
                    self.sendSensorToDevice(synapseObject)
                }
                else if synapseObject.synapseSendModeNext == SendMode.I9 {
                    self.sendResetToDevice(synapseObject)
                }
                else {
                    synapseObject.synapseSendMode = SendMode.I0
                }
                synapseObject.synapseSendModeNext = nil
            }
            else {
                print("receiveStopToDevice NG")
                synapseObject.synapseSendModeNext = nil
                if synapseObject.synapseAccessKey != nil {
                    self.sendAccessKeyToDevice(synapseObject)
                }
                else {
                    self.sendConnectionRequestToDevice(synapseObject)
                }
            }
        }
    }

    func sendSynapseSettingToDeviceStart(_ synapseObject: SynapseObject) {

        synapseObject.synapseSendModeNext = SendMode.I3_4
        self.sendStopToDevice(synapseObject)
    }

    func sendTimeIntervalToDeviceStart(_ synapseObject: SynapseObject) {

        if synapseObject.synapseSendModeSuspension {
            self.sendTimeIntervalToDevice(synapseObject)
        }
        else {
            synapseObject.synapseSendModeNext = SendMode.I3
            self.sendStopToDevice(synapseObject)
        }
    }

    func sendTimeIntervalToDevice(_ synapseObject: SynapseObject) {

        if let synapse = synapseObject.synapse {
            var timeInt: Int = Int(synapseObject.synapseTimeInterval * 1000)
            let timeData: [UInt8] = [UInt8](Data(buffer: UnsafeBufferPointer(start: &timeInt, count: 1)))

            var data: Data = Data(bytes: [0x04])
            if timeData.count >= 4 {
                data.append(timeData[3])
            }
            else {
                data.append(0)
            }
            if timeData.count >= 3 {
                data.append(timeData[2])
            }
            else {
                data.append(0)
            }
            if timeData.count >= 2 {
                data.append(timeData[1])
            }
            else {
                data.append(0)
            }
            if timeData.count >= 1 {
                data.append(timeData[0])
            }
            else {
                data.append(0)
            }
            data.append(0x01)
            
            synapseObject.synapseSendMode = SendMode.I3
            print("sendTimeIntervalToDevice: \([UInt8](data))")
            synapse.send(data)
        }
    }

    func receiveTimeIntervalToDevice(_ synapseObject: SynapseObject, data: Data) {

        let length: Int = 1
        let bytes: [UInt8] = [UInt8](data)
        print("receiveTimeIntervalToDevice: \(bytes)")
        if bytes.count == length {
            if synapseObject.synapseSendModeNext == SendMode.I5_3_4 {
                self.sendSensorToDevice(synapseObject)
            }
            else if synapseObject.synapseSendModeNext == SendMode.I3_4 {
                self.sendSensorToDevice(synapseObject)
            }
            else {
                synapseObject.synapseSendModeNext = nil
                if synapseObject.synapseAccessKey != nil {
                    self.sendAccessKeyToDevice(synapseObject)
                }
                else {
                    self.sendConnectionRequestToDevice(synapseObject)
                }
            }
        }
    }

    func sendSensorToDeviceStart(_ synapseObject: SynapseObject) {

        if synapseObject.synapseSendModeSuspension {
            self.sendSensorToDevice(synapseObject)
        }
        else {
            synapseObject.synapseSendModeNext = SendMode.I4
            self.sendStopToDevice(synapseObject)
        }
    }

    func sendSensorToDevice(_ synapseObject: SynapseObject) {
        
        if let synapse = synapseObject.synapse {
            var data: Data = Data(bytes: [0x05])
            var byte: UInt8 = 0x01
            if let flag = synapseObject.synapseValidSensors[self.synapseCrystalInfo.co2.key] {
                if !flag {
                    byte = 0x00
                }
            }
            data.append(byte)

            byte = 0x01
            if let flag = synapseObject.synapseValidSensors[self.synapseCrystalInfo.temp.key] {
                if !flag {
                    byte = 0x00
                }
            }
            data.append(byte)

            byte = 0x01
            if let flag = synapseObject.synapseValidSensors[self.synapseCrystalInfo.hum.key] {
                if !flag {
                    byte = 0x00
                }
            }
            data.append(byte)

            byte = 0x01
            if let flag = synapseObject.synapseValidSensors[self.synapseCrystalInfo.ill.key] {
                if !flag {
                    byte = 0x00
                }
            }
            data.append(byte)

            byte = 0x01
            if let flag = synapseObject.synapseValidSensors[self.synapseCrystalInfo.press.key] {
                if !flag {
                    byte = 0x00
                }
            }
            data.append(byte)

            byte = 0x01
            if let flag = synapseObject.synapseValidSensors[self.synapseCrystalInfo.sound.key] {
                if !flag {
                    byte = 0x00
                }
            }
            data.append(byte)

            byte = 0x01
            if let flag = synapseObject.synapseValidSensors[self.synapseCrystalInfo.move.key] {
                if !flag {
                    byte = 0x00
                }
            }
            data.append(byte)

            byte = 0x01
            if let flag = synapseObject.synapseValidSensors[self.synapseCrystalInfo.angle.key] {
                if !flag {
                    byte = 0x00
                }
            }
            data.append(byte)

            byte = 0x01
            if let flag = synapseObject.synapseValidSensors[self.synapseCrystalInfo.led.key] {
                if !flag {
                    byte = 0x00
                }
            }
            data.append(byte)

            synapseObject.synapseSendMode = SendMode.I4
            print("sendSensorToDevice: \([UInt8](data))")
            synapse.send(data)
        }
    }

    func receiveSensorToDevice(_ synapseObject: SynapseObject, data: Data) {

        let length: Int = 1
        let bytes: [UInt8] = [UInt8](data)
        //print("receiveTimeIntervalToDevice: \(bytes)")
        if bytes.count == length {
            if Int(bytes[0]) == 0 {
                print("receiveSensorToDevice OK")
            }
            else {
                print("receiveSensorToDevice NG")
            }

            synapseObject.synapseSendModeNext = nil
            if synapseObject.synapseAccessKey != nil {
                self.sendAccessKeyToDevice(synapseObject)
            }
            else {
                self.sendConnectionRequestToDevice(synapseObject)
            }
        }
    }

    func sendFirmwareVersionToDevice(_ synapseObject: SynapseObject) {

        if let synapse = synapseObject.synapse {
            synapseObject.synapseSendMode = SendMode.I5
            let data: Data = Data(bytes: [0x06])
            print("sendFirmwareVersionToDevice: \([UInt8](data))")
            synapse.send(data)
        }
    }

    func receiveFirmwareVersionToDevice(_ synapseObject: SynapseObject, data: Data, index: Int = -1) {

        let length: Int = 7
        let bytes: [UInt8] = [UInt8](data)
        //print("receiveFirmwareVersionToDevice: \(bytes)")
        if bytes.count == length {
            if Int(bytes[0]) == 0 {
                let versionVal1: Int = Int(bytes[1])
                let versionVal2: Int = Int(bytes[2])
                let dateVal1: Int = Int(bytes[3]) * 256 * 256 * 256
                let dateVal2: Int = Int(bytes[4]) * 256 * 256
                let dateVal3: Int = Int(bytes[5]) * 256
                let dateVal4: Int = Int(bytes[6])
                let firmwareInfo: [String: Any] = [
                    "device_version": "\(versionVal1).\(versionVal2)",
                    "date": "\(dateVal1 + dateVal2 + dateVal3 + dateVal4)",
                ]
                print("receiveFirmwareVersionToDevice OK -> \(firmwareInfo)")
                synapseObject.synapseFirmwareInfo = firmwareInfo
            }
            else {
                print("receiveFirmwareVersionToDevice Error")
            }

            //self.tableView.reloadData(forRowIndexes: IndexSet(integer: index), columnIndexes: IndexSet(integer: 3))

            if synapseObject.synapseSendModeNext == SendMode.I5_3_4 {
                //synapseObject.synapseSendModeNext = SendMode.I4
                self.sendTimeIntervalToDevice(synapseObject)
            }
            else {
                synapseObject.synapseSendModeNext = nil
                if synapseObject.synapseAccessKey != nil {
                    self.sendAccessKeyToDevice(synapseObject)
                }
                else {
                    self.sendConnectionRequestToDevice(synapseObject)
                }
            }
        }
    }

    func sendConnectionRequestToDevice(_ synapseObject: SynapseObject) {

        if let synapse = synapseObject.synapse {
            synapseObject.synapseSendMode = SendMode.I6
            let data: Data = Data(bytes: [0x10])
            print("sendConnectionRequestToDevice: \([UInt8](data))")
            synapse.send(data)
        }
    }

    func receiveConnectionRequestToDevice(_ synapseObject: SynapseObject, data: Data) {

        let bytes: [UInt8] = [UInt8](data)
        print("receiveConnectionRequestToDevice: \(bytes)")
        if bytes.count > 0 && Int(bytes[0]) == 0 {
            if let synapse = synapseObject.synapse {
                let data: Data = Data(bytes: [0x00])
                synapse.send(data)
            }

            let accessKey: Data = data.subdata(in: 1..<data.count)
            print("receiveConnectionRequestToDevice accessKey: \([UInt8](accessKey))")
            synapseObject.synapseAccessKey = accessKey
            self.sendAccessKeyToDevice(synapseObject)
        }
        /*else if bytes.count > 0 && Int(bytes[0]) == 1 {
            var title: String = "Pair with this synapseWear device?"
            if let uuid = synapseObject.synapseUUID {
                title = "Pair with \(uuid.uuidString)?"
            }
            let alert: UIAlertController = UIAlertController(title: title, message: "", preferredStyle: .alert)
            
            let yesAction: UIAlertAction = UIAlertAction(title: "Yes", style: .default, handler: {
                (action: UIAlertAction!) -> Void in
                self.sendResetToDevice(synapseObject)
            })
            let noAction: UIAlertAction = UIAlertAction(title: "No", style: .default, handler: {
                (action: UIAlertAction!) -> Void in
            })
            alert.addAction(yesAction)
            alert.addAction(noAction)
            self.present(alert, animated: true, completion: nil)
        }*/
        else {
            print("receiveConnectionRequestToDevice Error")
        }
    }

    func sendDataToDevice(_ synapseObject: SynapseObject, url: URL, firmwareInfo: [String: Any]) {

        if let synapse = synapseObject.synapse {
            print("sendDataToDevice hex: \(url)")
            let data: Data = Data(bytes: [0xfe])
            synapse.send(data)

            // For Firmware Update
            //self.rfduinoManager.stopScan()
            synapseObject.startDownload(url.absoluteString)
        }
    }

    func sendResetToDevice(_ synapseObject: SynapseObject) {

        if let synapse = synapseObject.synapse {
            let data: Data = Data(bytes: [0x12, 0x01])
            print("sendResetToDevice: \([UInt8](data))")
            synapse.send(data)

            if synapseObject.synapseSendModeNext == SendMode.I5_3_4 {
                self.sendFirmwareVersionToDevice(synapseObject)
            }
            else {
                synapseObject.synapseSendModeNext = nil
                self.sendConnectionRequestToDevice(synapseObject)
            }
        }
    }

    func sendLEDFlashToDevice(_ synapseObject: SynapseObject) {

        if let synapse = synapseObject.synapse {
            let data: Data = Data(bytes: [0x13])
            print("sendLEDFlashToDevice: \([UInt8](data))")
            synapse.send(data)
        }
    }
}

class SynapseObject: NSObject, OTABootloaderControllerDelegate {

    let aScale: Float = 2.0 / 32768.0
    let gScale: Float = 250.0 / 32768.0
    let settingDataManager: SettingDataManager = SettingDataManager()
    //var synapseUUID: UUID?
    var synapse: RFduino?
    var synapseAccessKey: Data?
    var synapseFirmwareInfo: [String: Any] = [:]
    var synapseFirmwareIsUpdate: Bool = false
    var synapseFirmwareUpdateMessage: String = ""
    var synapseFirmwareUpdatePercentage: Int = 0
    var synapseUpdateFirmwareInfo: [String: Any]?
    var synapseSendMode: SendMode!
    var synapseSendModeNext: SendMode?
    var synapseSendModeSuspension: Bool = false
    var receiveData: [UInt8]!
    var synapseData: [[String: Any]]!
    var synapseValues: SynapseValues!
    var synapseNowDate: String!
    var synapseDataSaveDir: URL?
    var synapseDataSaveDirDefault: URL?
    var synapseDataSaveDirChecked: Bool = false
    var synapseTimeInterval: TimeInterval = 1.0
    var synapseValidSensors: [String: Bool] = [:]
    var synapseScanLatestDate: Date?
    var synapseReceivedCount: Int = 0
    var oscSending: Bool = false
    var oscClient: F53OSCClient?
    var oscIPAddress: String = ""
    var oscPort: String = ""
    var ota: OTABootloaderController? // For Firmware Update
    var vc: ViewController?

    override init() {
    }

    init(_ synapse: RFduino, name: String? = nil) {

        self.synapse = synapse
        self.synapseSendMode = SendMode.I0
        self.receiveData = []
        self.synapseData = []
        self.synapseValues = SynapseValues(name)
        self.synapseNowDate = ""

        if let setting = self.settingDataManager.getSynapseSettingData(synapse.peripheral.identifier.uuidString) {
            //print("setting: \(setting)")
            if let synapseDataSaveDir = setting[self.settingDataManager.synapseDirectoryKey] as? String {
                self.synapseDataSaveDirDefault = URL(fileURLWithPath: synapseDataSaveDir)
            }
            if let synapseTimeInterval = setting[self.settingDataManager.synapseTimeIntervalKey] as? TimeInterval {
                self.synapseTimeInterval = synapseTimeInterval
            }
            if let synapseValidSensors = setting[self.settingDataManager.synapseValidSensorsKey] as? [String: Bool] {
                self.synapseValidSensors = synapseValidSensors
            }
            if let oscIPAddress = setting[self.settingDataManager.synapseOSCIPAddressKey] as? String {
                self.oscIPAddress = oscIPAddress
            }
            if let oscPort = setting[self.settingDataManager.synapseOSCPortKey] as? String {
                self.oscPort = oscPort
            }
        }
    }

    func disconnectSynapse() {

        self.synapseData = []
        self.synapseValues.resetValues()
        self.setOffOSC()
    }

    // MARK: mark - Synapse Setting methods

    func saveSynapseSettingData(isSaveDir: Bool, isSaveSendData: Bool, isSaveOSCData: Bool) {

        if let synapse = self.synapse {
            var settingData: [String: Any] = [:]
            if let setting = self.settingDataManager.getSynapseSettingData(synapse.peripheral.identifier.uuidString) {
                settingData = setting
            }
            if isSaveDir {
                if let synapseDataSaveDir = self.synapseDataSaveDir {
                    //print("settingData: \(synapseDataSaveDir)")
                    settingData[self.settingDataManager.synapseDirectoryKey] = synapseDataSaveDir.path
                }
            }
            if isSaveSendData {
                settingData[self.settingDataManager.synapseTimeIntervalKey] = self.synapseTimeInterval
                settingData[self.settingDataManager.synapseValidSensorsKey] = self.synapseValidSensors
            }
            if isSaveOSCData {
                settingData[self.settingDataManager.synapseOSCIPAddressKey] = self.oscIPAddress
                settingData[self.settingDataManager.synapseOSCPortKey] = self.oscPort
            }
            //print("settingData: \(settingData)")
            self.settingDataManager.setSynapseSettingData(synapse.peripheral.identifier.uuidString, data: settingData)
        }
    }

    // MARK: mark - Make SynapseData methods
    
    func setSynapseValues() {

        if self.synapseData.count > 0 {
            let synapse = self.synapseData[0]
            //print("setSynapseValues: \(synapse)")
            if let time = synapse["time"] as? TimeInterval, let data = synapse["data"] as? [UInt8], let uuid = synapse["uuid"] as? String {
                let formatter = DateFormatter()
                formatter.locale = Locale(identifier: "en_US_POSIX")
                formatter.dateFormat = "yyyyMMddHHmmss"
                self.synapseNowDate = formatter.string(from: Date(timeIntervalSince1970: time))
                //print("setSynapseNowDate: \(self.synapseNowDate)")
                self.synapseValues.time = time
                self.synapseValues.timeSec = Int(time)
                self.synapseValues.timeMillis = Int(time.truncatingRemainder(dividingBy: 1)*10000)
                self.synapseValues.uuid = uuid

                let axBak: Int? = self.synapseValues.ax
                let ayBak: Int? = self.synapseValues.ay
                let azBak: Int? = self.synapseValues.az

                self.synapseValues.co2 = nil
                self.synapseValues.ax = nil
                self.synapseValues.ay = nil
                self.synapseValues.az = nil
                self.synapseValues.light = nil
                self.synapseValues.gx = nil
                self.synapseValues.gy = nil
                self.synapseValues.gz = nil
                self.synapseValues.pressure = nil
                self.synapseValues.temp = nil
                self.synapseValues.humidity = nil
                self.synapseValues.sound = nil
                self.synapseValues.tvoc = nil
                self.synapseValues.power = nil
                self.synapseValues.battery = nil
                let values: [String: Any] = self.makeSynapseData(data)
                //print("setSynapseValues: \(self.synapseNowDate)\n\(values)")
                if let co2 = values["co2"] as? Int, co2 >= 400 {
                    self.synapseValues.co2 = co2
                }
                if let ax = values["ax"] as? Int {
                    self.synapseValues.ax = ax
                }
                if let ay = values["ay"] as? Int {
                    self.synapseValues.ay = ay
                }
                if let az = values["az"] as? Int {
                    self.synapseValues.az = az
                }
                if let light = values["light"] as? Int {
                    self.synapseValues.light = light
                }
                if let gx = values["gx"] as? Int {
                    self.synapseValues.gx = gx
                }
                if let gy = values["gy"] as? Int {
                    self.synapseValues.gy = gy
                }
                if let gz = values["gz"] as? Int {
                    self.synapseValues.gz = gz
                }
                if let pressure = values["pressure"] as? Float {
                    self.synapseValues.pressure = pressure
                }
                if let temp = values["temp"] as? Float {
                    self.synapseValues.temp = temp
                }
                if let humidity = values["humidity"] as? Int {
                    self.synapseValues.humidity = humidity
                }
                if let sound = values["sound"] as? Int {
                    self.synapseValues.sound = sound
                }
                if let tvoc = values["tvoc"] as? Int {
                    self.synapseValues.tvoc = tvoc
                }
                if let volt = values["volt"] as? Float {
                    self.synapseValues.power = volt
                }
                if let pow = values["pow"] as? Float {
                    self.synapseValues.battery = pow
                }

                self.sendOSC()
                if self.synapseTimeInterval <= 1.0 {
                    self.checkAccelerateSound(x: self.synapseValues.ax, y: self.synapseValues.ay, z: self.synapseValues.az, xBak: axBak, yBak: ayBak, zBak: azBak)
                }
            }
        }
    }

    func getSynapseValues() -> String {

        var res: String = ""

        res = "\(res)CO2 : "
        if let co2 = self.synapseValues.co2 {
            res = "\(res)\(String(co2))"
        }
        else {
            res = "\(res)-"
        }
        res = "\(res) ppm, "

        res = "\(res)TEMP : "
        if let temp = self.synapseValues.temp {
            res = "\(res)\(String(format:"%.1f", temp))"
        }
        else {
            res = "\(res)-"
        }
        res = "\(res) ℃, "

        res = "\(res)HUM : "
        if let humidity = self.synapseValues.humidity {
            res = "\(res)\(String(humidity))"
        }
        else {
            res = "\(res)-"
        }
        res = "\(res) %, "

        res = "\(res)LIGH : "
        if let light = self.synapseValues.light {
            res = "\(res)\(String(light))"
        }
        else {
            res = "\(res)-"
        }
        res = "\(res) lux, "

        res = "\(res)AIRP : "
        if let pressure = self.synapseValues.pressure {
            res = "\(res)\(String(format:"%.2f", pressure))"
        }
        else {
            res = "\(res)-"
        }
        res = "\(res) hPa, "

        res = "\(res)SND : "
        if let sound = self.synapseValues.sound {
            res = "\(res)\(String(sound))"
        }
        else {
            res = "\(res)-"
        }
        /*
        if self.synapseData.count > 0 {
            let synapse = self.synapseData[0]
            //print("setSynapseValues: \(synapse)")
            if let data = synapse["data"] as? [UInt8] {
                res = data.map {
                    String(format: "%.2hhx", $0)
                    }.joined()
                //print("getSynapseValues: \(res)")
            }
        }*/
        return res
    }

    func getSynapseValuesLower() -> String {

        var res: String = ""

        res = "\(res)ANG : "
        if let ax = self.synapseValues.ax, let ay = self.synapseValues.ay, let az = self.synapseValues.az {
            res = "\(res)\(String(format:"%.3f", Float(ax) * self.aScale))/\(String(format:"%.3f", Float(ay) * self.aScale))/\(String(format:"%.3f", Float(az) * self.aScale))"
        }
        else {
            res = "\(res)-"
        }
        res = "\(res) rad/s, "

        res = "\(res)MOV : "
        if let gx = self.synapseValues.gx, let gy = self.synapseValues.gy, let gz = self.synapseValues.gz {
            res = "\(res)\(String(format:"%.3f", Float(gx) * self.gScale * Float(Double.pi / 180.0)))/\(String(format:"%.3f", Float(gy) * self.gScale * Float(Double.pi / 180.0)))/\(String(format:"%.3f", Float(gz) * self.gScale * Float(Double.pi / 180.0)))"
        }
        else {
            res = "\(res)-"
        }
        res = "\(res) m/s2, "

        res = "\(res)Volt : "
        if let power = self.synapseValues.power {
            res = "\(res)\(String(format:"%.1f", power))"
        }
        else {
            res = "\(res)-"
        }
        res = "\(res) V, "

        res = "\(res)tVOC : "
        if let tvoc = self.synapseValues.tvoc {
            res = "\(res)\(String(tvoc))"
        }
        else {
            res = "\(res)-"
        }
        res = "\(res) , "

        res = "\(res)Pow : "
        if let battery = self.synapseValues.battery {
            res = "\(res)\(String(format:"%.1f", battery))"
        }
        else {
            res = "\(res)-"
        }
        return res
    }

    func makeSynapseData(_ data: [UInt8]) -> [String: Any] {

        //print("makeSynapseData: \(data)")
        var synapseData: [String: Any] = [:]
        if data.count >= 6 {
            if data[4] != 0xff || data[5] != 0xff {
                synapseData["co2"] = self.makeSynapseInt(byte1: data[4], byte2: data[5], unsigned: true)
            }
            //print("co2: \(String(describing: synapseData["co2"]))")
        }
        if data.count >= 8 {
            if data[6] != 0xff || data[7] != 0xff {
                synapseData["ax"] = -self.makeSynapseInt(byte1: data[6], byte2: data[7], unsigned: false)
            }
            //print("ax: \(String(describing: synapseData["ax"]))")
        }
        if data.count >= 10 {
            if data[8] != 0xff || data[9] != 0xff {
                synapseData["ay"] = -self.makeSynapseInt(byte1: data[8], byte2: data[9], unsigned: false)
            }
            //print("ay: \(String(describing: synapseData["ay"]))")
        }
        if data.count >= 12 {
            if data[10] != 0xff || data[11] != 0xff {
                synapseData["az"] = self.makeSynapseInt(byte1: data[10], byte2: data[11], unsigned: false)
            }
            //print("az: \(String(describing: synapseData["az"]))")
        }
        if data.count >= 14 {
            if data[12] != 0xff || data[13] != 0xff {
                synapseData["gx"] = -self.makeSynapseInt(byte1: data[12], byte2: data[13], unsigned: false)
            }
            //print("gx: \(String(describing: synapseData["gx"]))")
        }
        if data.count >= 16 {
            if data[14] != 0xff || data[15] != 0xff {
                synapseData["gy"] = -self.makeSynapseInt(byte1: data[14], byte2: data[15], unsigned: false)
            }
            //print("gy: \(String(describing: synapseData["gy"]))")
        }
        if data.count >= 18 {
            if data[16] != 0xff || data[17] != 0xff {
                synapseData["gz"] = self.makeSynapseInt(byte1: data[16], byte2: data[17], unsigned: false)
            }
            //print("gz: \(String(describing: synapseData["gz"]))")
        }
        if data.count >= 20 {
            if data[18] != 0xff || data[19] != 0xff {
                synapseData["light"] = self.makeSynapseInt(byte1: data[18], byte2: data[19], unsigned: true)
            }
            //print("light: \(String(describing: synapseData["light"]))")
        }
        if data.count >= 22 {
            if data[20] != 0xff {
                synapseData["temp"] = self.makeSynapseFloat8(byte1: data[20], byte2: data[21])
            }
            //print("temp: \(String(describing: synapseData["temp"]))")
        }
        if data.count >= 23 {
            if data[22] != 0xff {
                synapseData["humidity"] = Int(data[22])
            }
            //print("humidity: \(String(describing: synapseData["humidity"]))")
        }
        if data.count >= 26 {
            if data[23] != 0xff || data[24] != 0xff {
                synapseData["pressure"] = self.makeSynapseFloat16(byte1: data[23], byte2: data[24], byte3: data[25])
            }
            //print("pressure: \(String(describing: synapseData["pressure"]))")
        }
        if data.count >= 28 {
            if data[26] != 0xff || data[27] != 0xff {
                synapseData["tvoc"] = self.makeSynapseInt(byte1: data[26], byte2: data[27], unsigned: true)
            }
            //print("tvoc: \(String(describing: synapseData["tvoc"]))")
        }
        if data.count >= 30 {
            if data[28] != 0xff || data[29] != 0xff {
                synapseData["volt"] = self.makeSynapseVoltageValue(byte1: data[28], byte2: data[29])
            }
            //print("volt: \(String(describing: synapseData["volt"]))")
        }
        if data.count >= 32 {
            if data[30] != 0xff || data[31] != 0xff {
                synapseData["pow"] = self.makeSynapsePowerValue(byte1: data[30], byte2: data[31])
            }
            //print("pow: \(String(describing: synapseData["pow"]))")
        }
        if data.count >= 34 {
            if data[32] != 0xff || data[33] != 0xff {
                synapseData["sound"] = self.makeSynapseInt(byte1: data[32], byte2: data[33], unsigned: true)
                //synapseData["sound"] = self.makeSynapseSoundDBValue(byte1: data[32], byte2: data[33])
            }
            //print("sound: \(String(describing: synapseData["sound"]))")
        }
        return synapseData
    }
    
    func makeSynapseInt(byte1: UInt8, byte2: UInt8, unsigned: Bool) -> Int {
        
        if unsigned {
            return Int(UInt16(byte1) << 8 | UInt16(byte2))
        }
        else {
            return Int(Int16(byte1) << 8 | Int16(byte2))
        }
    }
    
    func makeSynapseFloat8(byte1: UInt8, byte2: UInt8) -> Float {
        
        return Float(byte1) + Float(byte2) * 0.01
    }
    
    func makeSynapseFloat16(byte1: UInt8, byte2: UInt8, byte3: UInt8) -> Float {
        
        return Float(byte1) * 256.0 + Float(byte2) + Float(byte3) * 0.01
    }
    /*
     func makeSynapseSoundDBValue(byte1: UInt8, byte2: UInt8) -> Int {
     
     let p: Double = Double(self.makeSynapseInt(byte1: byte1, byte2: byte2, unsigned: true))
     if p >= 20.0 {
     return Int(10.0 * log10(pow(p, 2) / pow(20, 2)))
     }
     return 0
     }*/
    
    func makeSynapseVoltageValue(byte1: UInt8, byte2: UInt8) -> Float {
        
        let hex1: Int = Int(byte1)
        let hex2: Int = Int(byte2)
        let value: Int = hex1 << 4 | hex2 >> 4
        return Float(value) * 0.00125
    }
    
    func makeSynapsePowerValue(byte1: UInt8, byte2: UInt8) -> Float {
        
        let hex1: Int = Int(byte1)
        let hex2: Int = Int(byte2)
        let decimal: Float = Float(hex2) / 256.0
        return Float(hex1) + decimal
    }
    /*
     func makeSynapseValue(_ str: String, unsigned: Bool) -> Int {
     
     let hex1: Int = Int(str.substring(to: str.index(str.startIndex, offsetBy: 2)), radix: 16) ?? 0
     let hex2: Int = Int(str.substring(from: str.index(str.startIndex, offsetBy: 2)), radix: 16) ?? 0
     let bytes: [UInt8] = [UInt8(hex1), UInt8(hex2)]
     if unsigned {
     return Int(UInt16(bytes[0]) << 8 | UInt16(bytes[1]))
     }
     else {
     return Int(Int16(bytes[0]) << 8 | Int16(bytes[1]))
     }
     }
     
     func makeSynapseFloat8(_ str: String, unsigned: Bool) -> Float {
     
     // TODO unsigned handling
     let hex1: Int = Int(str.substring(to: str.index(str.startIndex, offsetBy: 2)), radix: 16) ?? 0
     let hex2: Int = Int(str.substring(from: str.index(str.startIndex, offsetBy: 2)), radix: 16) ?? 0
     return Float(hex1) + Float(hex2) * 0.01
     }
     
     func makeSynapseFloat16(_ str: String, unsigned: Bool) -> Float {
     
     // TODO unsigned handling
     let hex1: Int = Int(str.substring(to: str.index(str.startIndex, offsetBy: 2)), radix: 16) ?? 0
     let hex2: Int = Int(str.substring(with: str.index(str.startIndex, offsetBy: 2)..<str.index(str.startIndex, offsetBy: 4)), radix: 16) ?? 0
     let hex3: Int = Int(str.substring(from: str.index(str.endIndex, offsetBy: -2)), radix: 16) ?? 0
     return Float(hex1 << 8 + hex2) + Float(hex3) * 0.01
     }
     
     func makeSynapseVoltageValue(_ str: String) -> Float {
     
     let hex1: Int = Int(str.substring(to: str.index(str.startIndex, offsetBy: 2)), radix: 16) ?? 0
     let hex2: Int = Int(str.substring(from: str.index(str.startIndex, offsetBy: 2)), radix: 16) ?? 0
     let value: Int = hex1 << 4 | hex2 >> 4
     return Float(value) * 0.00125
     }
     
     func makeSynapsePowerValue(_ str: String) -> Float {
     
     let hex1: Int = Int(str.substring(to: str.index(str.startIndex, offsetBy: 2)), radix: 16) ?? 0
     let hex2: Int = Int(str.substring(from: str.index(str.startIndex, offsetBy: 2)), radix: 16) ?? 0
     let decimal: Float = Float(hex2) / 256.0
     return Float(hex1) + decimal
     }*/

    // MARK: mark - OSC methods

    func setOnOSC() {

        //print("setOnOSC: \(self.oscIPAddress) \(self.oscPort)")
        if self.oscIPAddress.count > 0, self.oscPort.count > 0, let port = UInt16(self.oscPort) {
            //print("setOnOSC")
            self.oscClient = F53OSCClient.init()
            self.oscClient?.host = self.oscIPAddress
            self.oscClient?.port = port
            self.oscSending = true
        }
    }

    func setOffOSC() {

        self.oscSending = false
        self.oscClient = nil
    }

    func sendOSC() {

        if self.oscSending, let oscClient = self.oscClient {
            var arguments: [Any] = [
                0, // time
                0, // co2
                0, // ax
                0, // ay
                0, // az
                0, // light
                0, // gx
                0, // gy
                0, // gz
                0, // pressure
                0, // temp
                0, // humidity
                0, // sound
                0, // tvoc
                0, // volt
                0, // pow
                0, // time seconds
                0, // time millis
                0, // uuid
            ]
            if let time = self.synapseValues.time {
                arguments[0] = time
            }
            if let co2 = self.synapseValues.co2 {
                arguments[1] = co2
            }
            if let ax = self.synapseValues.ax {
                arguments[2] = ax
            }
            if let ay = self.synapseValues.ay {
                arguments[3] = ay
            }
            if let az = self.synapseValues.az {
                arguments[4] = az
            }
            if let light = self.synapseValues.light {
                arguments[5] = light
            }
            if let gx = self.synapseValues.gx {
                arguments[6] = gx
            }
            if let gy = self.synapseValues.gy {
                arguments[7] = gy
            }
            if let gz = self.synapseValues.gz {
                arguments[8] = gz
            }
            if let pressure = self.synapseValues.pressure {
                arguments[9] = pressure
            }
            if let temp = self.synapseValues.temp {
                arguments[10] = temp
            }
            if let humidity = self.synapseValues.humidity {
                arguments[11] = humidity
            }
            if let sound = self.synapseValues.sound {
                arguments[12] = sound
            }
            if let tvoc = self.synapseValues.tvoc {
                arguments[13] = tvoc
            }
            if let volt = self.synapseValues.power {
                arguments[14] = volt
            }
            if let pow = self.synapseValues.battery {
                arguments[15] = pow
            }
            if let timeSec = self.synapseValues.timeSec {
                arguments[16] = timeSec
            }
            if let timeMillis = self.synapseValues.timeMillis {
                arguments[17] = timeMillis
            }
            if let uuid = self.synapseValues.uuid {
                arguments[18] = uuid
            }
            print("sendOSC: \(arguments)")
            self.sendMessage(client: oscClient, addressPattern: "/synapseWear", arguments: arguments)
        }
    }

    func checkAccelerateSound(x: Int?, y: Int?, z: Int?, xBak: Int?, yBak: Int?, zBak: Int?) {

        let axDiffMax: Int = 10000
        if x != nil && y != nil && z != nil && xBak != nil && yBak != nil && zBak != nil {
            let ax: Int = abs(x! - xBak!)
            //let ay: Int = abs(y! - yBak!)
            //let az: Int = abs(z! - zBak!)

            if ax > axDiffMax {
                self.sendKickOSC()
            }
        }
    }

    func sendKickOSC() {

        if self.oscSending, let oscClient = self.oscClient {
            var arguments: [Any] = [
                0, // time
                true, // kick
            ]
            if let time = self.synapseValues.time {
                arguments[0] = time
            }
            //print("sendKickOSC")
            self.sendMessage(client: oscClient, addressPattern: "/synapseWearKick", arguments: arguments)
        }
    }
    
    func sendMessage(client: F53OSCClient, addressPattern: String, arguments: [Any]) {

        let message: F53OSCMessage = F53OSCMessage(addressPattern: addressPattern, arguments: arguments)
        client.send(message)
        //print("Send OSC: '\(String(describing: message))' To: \(client.host):\(client.port)")
    }

    // For Firmware Update
    func startDownload(_ hexUrl: String/*, firmwareInfo: [String: Any]*/) -> Void {

        let fileUrl: URL = self.getSaveFileUrl(fileName: hexUrl)
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            return (fileUrl, [.removePreviousFile, .createIntermediateDirectories])
        }
        print("startDownload: \(fileUrl.absoluteString)")

        Alamofire.download(hexUrl, to:destination)
            .downloadProgress { (progress) in
            }
            .responseData { (data) in
                self.updateFirmwearStart(fileUrl)
        }
    }
    
    func getSaveFileUrl(fileName: String) -> URL {
        
        let documentsUrl: URL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let nameUrl: URL = URL(string: fileName)!
        let fileUrl: URL = documentsUrl.appendingPathComponent(nameUrl.lastPathComponent)
        //NSLog(fileURL.absoluteString)
        return fileUrl
    }

    func updateFirmwearStart(_ url: URL) {

        //print("updateFirmwearStart: \(url)")
        self.synapseFirmwareIsUpdate = true
        self.synapseFirmwareUpdatePercentage = 0
        self.synapseFirmwareUpdateMessage = "Update Firmwear Start"

        self.ota = OTABootloaderController()
        self.ota?.delegate = self
        self.ota?.fileURL = url
        self.ota?.start()

        self.vc?.setFirmwareSettingArea()
    }

    func updateFirmwearEnd() {

        self.synapseFirmwareIsUpdate = false
        self.synapseFirmwareUpdateMessage = ""

        self.ota?.stop()
        self.ota?.delegate = nil
        //self.ota = nil

        self.vc?.setFirmwareSettingArea()
        self.vc?.rfduinoManager.startScan()
    }

    func onConnectDevice() {

        self.synapseFirmwareUpdateMessage = "connecting..."
        self.vc?.setFirmwareSettingArea()
    }

    func onPerformDFUOnFile() {

        self.synapseFirmwareUpdateMessage = "starting..."
        self.vc?.setFirmwareSettingArea()
    }

    func onDeviceConnected() {

        /*self.synapseFirmwareUpdateMessage = "Device Connected"
        self.vc?.setFirmwareSettingArea()*/
    }

    func onDeviceConnectedWithVersion() {

        /*self.synapseFirmwareUpdateMessage = "Device Connected With Version"
        self.vc?.setFirmwareSettingArea()*/
    }

    func onDeviceDisconnected() {

        self.updateFirmwearEnd()

        self.synapseFirmwareUpdateMessage = "disconnected"
        self.vc?.setFirmwareSettingArea()
    }

    func onReadDFUVersion() {

        /*self.synapseFirmwareUpdateMessage = "Read DFU Version"
        self.vc?.setFirmwareSettingArea()*/
    }

    func onDFUStarted(uploadStatusMessage: String) {

        self.synapseFirmwareUpdateMessage = uploadStatusMessage
        self.vc?.setFirmwareSettingArea()
    }

    func onDFUCancelled() {

        self.updateFirmwearEnd()
    }

    func onBootloaderUploadStarted() {

        self.synapseFirmwareUpdateMessage = "uploading bootloader ..."
        self.vc?.setFirmwareSettingArea()
    }

    func onTransferPercentage(percentage: Int) {

        self.synapseFirmwareUpdatePercentage = percentage
        self.synapseFirmwareUpdateMessage = "\(percentage)%"
        self.vc?.setFirmwareSettingArea()
    }

    func onSuccessfulFileTranferred() {
        
        self.updateFirmwearEnd()
    }

    func onError(errorMessage: String) {

        self.updateFirmwearEnd()
    }
}

class SynapseValues {
    
    var name: String?
    var time: TimeInterval?
    var co2: Int?
    var ax: Int?
    var ay: Int?
    var az: Int?
    var gx: Int?
    var gy: Int?
    var gz: Int?
    var light: Int?
    var pressure: Float?
    var temp: Float?
    var humidity: Int?
    var sound: Int?
    var tvoc: Int?
    var power: Float?
    var battery: Float?
    var isConnected: Bool = false
    var timeSec: Int?
    var timeMillis: Int?
    var uuid: String?

    init(_ name: String? = nil) {

        self.name = name
    }

    func resetValues() {

        self.time = nil
        self.co2 = nil
        self.ax = nil
        self.ay = nil
        self.az = nil
        self.gx = nil
        self.gy = nil
        self.gz = nil
        self.light = nil
        self.pressure = nil
        self.temp = nil
        self.humidity = nil
        self.sound = nil
        self.tvoc = nil
        self.power = nil
        self.battery = nil
        self.isConnected = false
    }
}
