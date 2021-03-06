//
//  ViewController.swift
//  synapseWearCentral
//
//  Copyright © 2018 art and program, Inc. For license and other information refer to https://github.com/artandprogram/synapseWear. All rights reserved.
//

import Cocoa
import Alamofire
import SwiftyJSON
import Foundation

struct CrystalStruct {

    var key: String = ""
    var name: String = ""

    init(key: String, name: String) {

        self.key = key
        self.name = name
    }
}

struct SynapseCrystalStruct {

    var co2: CrystalStruct   = CrystalStruct(key: "co2",   name: "CO2")
    var temp: CrystalStruct  = CrystalStruct(key: "temp",  name: "temperature")
    var hum: CrystalStruct   = CrystalStruct(key: "hum",   name: "humidity")
    var ill: CrystalStruct   = CrystalStruct(key: "ill",   name: "illumination")
    var press: CrystalStruct = CrystalStruct(key: "press", name: "air pressure")
    var sound: CrystalStruct = CrystalStruct(key: "sound", name: "environmental sound")
    var move: CrystalStruct  = CrystalStruct(key: "move",  name: "movement")
    var ax: CrystalStruct    = CrystalStruct(key: "ax",    name: "ax")
    var ay: CrystalStruct    = CrystalStruct(key: "ay",    name: "ay")
    var az: CrystalStruct    = CrystalStruct(key: "az",    name: "az")
    var angle: CrystalStruct = CrystalStruct(key: "angle", name: "angle")
    var volt: CrystalStruct  = CrystalStruct(key: "volt",  name: "voltage")
    var led: CrystalStruct   = CrystalStruct(key: "led",   name: "LED")
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

enum SynapseValueTableColumn: Int {

    case uuid         = 0
    case connect      = 1
    case battery      = 2
    case count        = 3
    case co2          = 4
    case temperature  = 5
    case humidity     = 6
    case illumination = 7
    case airpressure  = 8
    case sound        = 9
    case ax           = 10
    case ay           = 11
    case az           = 12
    case gx           = 13
    case gy           = 14
    case gz           = 15
    case firmware     = 16
    case total        = 17
}

enum FirmwareUpdateStatus {

    case off
    case on
    case standby
    case running
}

class ViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, NSComboBoxDataSource, NSComboBoxDelegate, RFduinoManagerDelegate, RFduinoDelegate/*, FirmwearUpdateDelegate*/ {

    @IBOutlet var scrollView: NSScrollView!
    @IBOutlet var tableView: NSTableView!
    @IBOutlet var detailAreaView: NSScrollView!
    @IBOutlet var uuidLabel: NSTextField!
    @IBOutlet var resetButton: NSButton!
    @IBOutlet var directoryLabel: NSTextField!
    @IBOutlet var directoryButton: NSButton!
    @IBOutlet var directoryEnableButton: NSButton!
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
    var loadingView: LoadingView!

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
    let countResetValue: Int = 10000
    let synapseCrystalInfo: SynapseCrystalStruct = SynapseCrystalStruct()
    let synapseFileManager: SynapseFileManager = SynapseFileManager()
    var rfduinoManager: RFduinoManager!
    var rfduinos: [Any] = []
    var synapses: [SynapseObject] = []
    var synapseDeviceName: String = ""
    var firmwares: [[String: Any]] = []
    var firmwareSelectIndex: Int = -1
    var firmwareUpdateLocked: Bool = false
    //var checkScanningTimer: Timer?
    var synapseSaveTimeInterval: TimeInterval = 1.0
    var windowControllers: [String: NSWindowController] = [:]
    //var firmwearUpdateViewController: FirmwearUpdateViewController?

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

        self.resetButton.action = #selector(resetButtonAction)
        self.directoryButton.action = #selector(directoryButtonAction)

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
        self.directoryEnableButton.action = #selector(directoryEnableButtonAction)
        self.oscSendButton.action = #selector(oscSendButtonAction)

        self.setDetailAreaLabels()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(type(of: self).textDidChange(notification:)),
                                               name: NSControl.textDidChangeNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.resized),
                                               name: NSWindow.didResizeNotification,
                                               object: nil)
    }

    func setSizeUUIDViews() {

        var x: CGFloat = self.uuidLabel.frame.origin.x
        var y: CGFloat = self.uuidLabel.frame.origin.y
        var w: CGFloat = self.uuidLabel.frame.size.width
        var h: CGFloat = self.uuidLabel.frame.size.height
        self.uuidLabel.sizeToFit()
        w = self.uuidLabel.frame.size.width
        if let window = self.view.window, self.uuidLabel.frame.origin.x + w + self.resetButton.frame.size.width > window.frame.size.width {
            w = window.frame.size.width - (self.uuidLabel.frame.origin.x + self.resetButton.frame.size.width)
        }
        self.uuidLabel.frame = NSRect(x: x, y: y, width: w, height: h)

        x = self.uuidLabel.frame.origin.x + self.uuidLabel.frame.size.width
        y = self.resetButton.frame.origin.y
        w = self.resetButton.frame.size.width
        h = self.resetButton.frame.size.height
        self.resetButton.frame = NSRect(x: x, y: y, width: w, height: h)
    }

    func setSizeDirectoryViews() {

        self.directoryLabel.sizeToFit()
        var x: CGFloat = self.directoryLabel.frame.origin.x
        var y: CGFloat = self.directoryLabel.frame.origin.y
        var w: CGFloat = self.directoryLabel.frame.size.width
        var h: CGFloat = 20.0
        if let window = self.view.window, self.directoryLabel.frame.origin.x + self.directoryLabel.frame.size.width + self.directoryButton.frame.size.width > window.frame.size.width {
            w = window.frame.size.width - (self.directoryLabel.frame.origin.x + self.directoryButton.frame.size.width)
        }
        self.directoryLabel.frame = NSRect(x: x, y: y, width: w, height: h)

        x = self.directoryLabel.frame.origin.x + self.directoryLabel.frame.size.width
        y = self.directoryButton.frame.origin.y
        w = self.directoryButton.frame.size.width
        h = self.directoryButton.frame.size.height
        self.directoryButton.frame = NSRect(x: x, y: y, width: w, height: h)

        x = self.directoryButton.frame.origin.x + self.directoryButton.frame.size.width - 7.0
        y = self.directoryEnableButton.frame.origin.y
        w = self.directoryEnableButton.frame.size.width
        h = self.directoryEnableButton.frame.size.height
        self.directoryEnableButton.frame = NSRect(x: x, y: y, width: w, height: h)
    }

    func setSizeFirmwareViews() {

        var x: CGFloat = self.firmwareLabel.frame.origin.x
        var y: CGFloat = self.firmwareLabel.frame.origin.y
        var w: CGFloat = self.detailAreaView.frame.size.width - x * 2
        var h: CGFloat = self.firmwareLabel.frame.size.height
        self.firmwareLabel.sizeToFit()
        w = self.firmwareLabel.frame.size.width
        h = 20.0
        self.firmwareLabel.frame = NSRect(x: x, y: y, width: w, height: h)

        x = self.firmwareLabel.frame.origin.x + self.firmwareLabel.frame.size.width
        y = self.firmwareComboBox.frame.origin.y
        w = self.firmwareComboBox.frame.size.width
        h = self.firmwareComboBox.frame.size.height
        self.firmwareComboBox.frame = NSRect(x: x, y: y, width: w, height: h)

        x = self.firmwareComboBox.frame.origin.x + self.firmwareComboBox.frame.size.width
        y = self.firmwareUpdateButton.frame.origin.y
        w = self.firmwareUpdateButton.frame.size.width
        h = self.firmwareUpdateButton.frame.size.height
        if self.firmwareComboBox.isHidden {
            x = self.firmwareLabel.frame.origin.x + self.firmwareLabel.frame.size.width
        }
        self.firmwareUpdateButton.frame = NSRect(x: x, y: y, width: w, height: h)

        x = self.firmwareUpdateButton.frame.origin.x + self.firmwareUpdateButton.frame.size.width - 5.0
        y = self.firmwareCancelButton.frame.origin.y
        w = self.firmwareCancelButton.frame.size.width
        h = self.firmwareCancelButton.frame.size.height
        if self.firmwareUpdateButton.isHidden {
            x = self.firmwareUpdateButton.frame.origin.x
        }
        self.firmwareCancelButton.frame = NSRect(x: x, y: y, width: w, height: h)
    }

    @objc func resized() {

        //print("resized: \(NSApp.windows.first!.frame.size.width)")
        var x: CGFloat = 0
        var y: CGFloat = 0
        var w: CGFloat = 0
        var h: CGFloat = 0
        if let window = self.view.window {
            x = self.detailAreaView.frame.origin.x
            y = 0
            w = window.frame.size.width
            h = self.detailAreaView.frame.size.height
            self.detailAreaView.frame = NSRect(x: x, y: y, width: w, height: h)

            x = self.scrollView.frame.origin.x
            y = self.detailAreaView.frame.size.height
            w = window.frame.size.width
            h = window.frame.size.height - self.detailAreaView.frame.size.height - 21.0
            self.scrollView.frame = NSRect(x: x, y: y, width: w, height: h)
        }

        x = self.uuidLabel.frame.origin.x
        y = self.uuidLabel.frame.origin.y
        w = self.detailAreaView.frame.size.width - x * 2
        h = self.uuidLabel.frame.size.height
        self.uuidLabel.frame = NSRect(x: x, y: y, width: w, height: h)

        x = self.timeIntervalComboBox.frame.origin.x
        y = self.timeIntervalComboBox.frame.origin.y
        w = self.timeIntervalComboBox.frame.size.width
        h = self.timeIntervalComboBox.frame.size.height
        self.timeIntervalComboBox.frame = NSRect(x: x, y: y, width: w, height: h)

        x = 0
        y = 0
        w = self.view.frame.size.width
        h = self.view.frame.size.height
        self.loadingView.frame = NSRect(x: x, y: y, width: w, height: h)

        self.setSizeUUIDViews()
        self.setSizeDirectoryViews()
        self.setSizeFirmwareViews()
    }

    func showSynapseDataWindow(_ synapseObject: SynapseObject) {

        if let synapse = synapseObject.synapse {
            let uuid: String = synapse.peripheral.identifier.uuidString
            if self.windowControllers[uuid] == nil {
                let dataViewController: DataViewController? = storyboard?.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "DataViewController")) as? DataViewController
                dataViewController?.synapseUUID = uuid
                dataViewController?.synapseGraphKeys = synapseObject.synapseGraphKeys
                dataViewController?.synapseValues = synapseObject.synapseValues
                dataViewController?.synapseGraphLabels = synapseObject.synapseGraphLabels
                dataViewController?.synapseGraphValues = synapseObject.synapseGraphValues
                dataViewController?.synapseGraphColors = synapseObject.synapseGraphColors
                dataViewController?.synapseGraphScales = synapseObject.getSynapseGraphScales()
                dataViewController?.mainViewController = self

                var x: CGFloat = 0
                var y: CGFloat = 0
                let w: CGFloat = 450.0
                let h: CGFloat = 200.0
                if let window = self.view.window {
                    //print("showSynapseDataWindow: \(window.frame.origin.y), \(window.frame.size.height)")
                    x = window.frame.origin.x
                    y = window.frame.origin.y - (h + 20.0)
                }
                let dataWindow: NSWindow = NSWindow(contentRect: NSMakeRect(x, y, w, h),
                                                    styleMask: [.titled, .resizable, .miniaturizable, .closable],
                                                    backing: .buffered,
                                                    defer: false)
                dataWindow.center()
                dataWindow.title = uuid
                dataWindow.isOpaque = false
                dataWindow.isMovableByWindowBackground = true
                dataWindow.backgroundColor = NSColor.white
                dataWindow.makeKeyAndOrderFront(nil)
                dataWindow.contentViewController = dataViewController
                self.windowControllers[uuid] = NSWindowController(window: dataWindow)
            }
        }
    }

    func updateSynapseDataWindow(_ synapseObject: SynapseObject) {

        if let synapse = synapseObject.synapse {
            let uuid: String = synapse.peripheral.identifier.uuidString
            if let windowController = self.windowControllers[uuid], let window = windowController.window, let dataViewController = window.contentViewController as? DataViewController, dataViewController.isViewSetting {
                dataViewController.synapseValues = synapseObject.synapseValues
                dataViewController.tableView.reloadData()

                dataViewController.synapseGraphLabels = synapseObject.synapseGraphLabels
                dataViewController.synapseGraphValues = synapseObject.synapseGraphValues
                dataViewController.synapseGraphColors = synapseObject.synapseGraphColors
                dataViewController.synapseGraphScales = synapseObject.getSynapseGraphScales()
                //print("synapseGraphValues: \(synapseObject.synapseGraphValues)")
                dataViewController.checkGraph()
            }
        }
    }

    func closeSynapseDataWindow(_ uuid: String) {

        self.windowControllers[uuid] = nil
    }

    // MARK: mark - Action methods

    @objc private func onItemClicked() {

        //print("onItemClicked: row \(tableView.clickedRow), col \(tableView.clickedColumn)")
        self.setDetailAreaLabels()
        self.setSizeDirectoryViews()
    }

    @objc private func onItemDoubleClicked() {

        //print("onItemDoubleClicked: row \(tableView.clickedRow), col \(tableView.clickedColumn)")
        if tableView.clickedRow >= 0, tableView.clickedRow < self.synapses.count, let synapse = self.synapses[tableView.clickedRow].synapse {
            if tableView.clickedColumn == 0 {
                self.showSynapseDataWindow(self.synapses[tableView.clickedRow])
            }
            else if tableView.clickedColumn == 1 {
                if self.synapses[tableView.clickedRow].synapseValues.isConnected {
                    self.saveSynapseData(synapseObject: self.synapses[tableView.clickedRow])

                    self.synapses[tableView.clickedRow].synapseScanLatestDate = Date()
                    self.synapses[tableView.clickedRow].synapseValues.isDisconnected = true
                    synapse.disconnect()

                    self.countConnectedSynapse()
                }
                else {
                    /*if let date = self.synapses[tableView.clickedRow].synapseScanLatestDate, date.timeIntervalSinceNow < -self.synapseScanLimitTimeInterval {
                        print("onItemDoubleClicked not connect: \(date.timeIntervalSinceNow)")
                        return
                    }*/

                    self.rfduinoManager.connect(synapse)

                    /*if self.synapses[tableView.clickedRow].synapseDataSaveDir == nil && !self.synapses[tableView.clickedRow].synapseDataSaveDirChecked {
                        self.setSynapseDataSaveDir(tableView.clickedRow)
                    }*/
                    self.synapses[tableView.clickedRow].synapseDataSaveDirChecked = true
                }
            }
        }
    }

    @objc private func resetButtonAction() {

        if tableView.selectedRow >= 0 && tableView.selectedRow < self.synapses.count {
            self.sendRebootToDevice(self.synapses[tableView.selectedRow])
        }
    }

    @objc private func directoryButtonAction() {

        self.setSynapseDataSaveDir(tableView.selectedRow)
    }
    
    @objc private func directoryEnableButtonAction() {

        if self.tableView.selectedRow >= 0 && self.tableView.selectedRow < self.synapses.count {
            if self.synapses[self.tableView.selectedRow].synapseDataSaveEnable {
                self.saveSynapseData(synapseObject: self.synapses[self.tableView.selectedRow])
            }

            self.synapses[self.tableView.selectedRow].synapseDataSaveEnable = !self.synapses[self.tableView.selectedRow].synapseDataSaveEnable
            self.synapses[tableView.selectedRow].saveSynapseSettingData(isSaveDir: true, isSaveSendData: false, isSaveOSCData: false)

            self.setDataSaveEnableButton()
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

        self.firmwareSelectIndex = -1
        if !self.firmwareComboBox.isHidden {
            self.firmwareComboBox.isHidden = true
            self.setFirmwareSettingArea()
        }
        else {
            self.updateFirmwareCancel()
        }
    }

    @objc private func sendButtonAction() {

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
        
        self.oscSendButton.title = "Off"
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
                self.oscSendButton.title = "On"
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
                    if let url = self.synapses[index].synapseDataSaveDir {
                        self.directoryLabel.stringValue = "Directory : \(url.path)"
                        self.setSizeDirectoryViews()
                    }
                    //self.tableView.reloadData(forRowIndexes: IndexSet(integer: index), columnIndexes: IndexSet(integer: 3))
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
        //self.setDataCountLabel()
        //self.setValueLabel()
        self.setDetailAreaSettings()
        self.setDataSaveEnableButton()
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
        self.setSizeUUIDViews()
    }

    func setDataCountLabel() {

        self.uuidLabel.stringValue = ""
        if tableView.selectedRow >= 0 && tableView.selectedRow < self.synapses.count {
            let formatter: NumberFormatter = NumberFormatter()
            formatter.numberStyle = .decimal
            if let str = formatter.string(from: self.synapses[tableView.selectedRow].synapseReceivedCount as NSNumber) {
                self.uuidLabel.stringValue = str

                if let _ = self.synapses[tableView.selectedRow].synapseValues.connectedDate {
                    self.uuidLabel.stringValue = "Data Count : \(self.uuidLabel.stringValue)\(self.makeConnectedDateString(tableView.selectedRow))"
                }
            }
        }
    }

    func makeConnectedDateString(_ index: Int) -> String {

        var h: Int = 0
        var m: Int = 0
        var s: Int = 0
        if index < self.synapses.count, let date = self.synapses[index].synapseValues.connectedDate {
            var time: TimeInterval = Date().timeIntervalSince(date)
            if time >= 3600 {
                h = Int(floor(time / 3600.0))
                time -= Double(h) * 3600
            }
            if time >= 60 {
                m = Int(floor(time / 60.0))
                time -= Double(m) * 60
            }
            s = Int(floor(time))
        }
        return "\(String(format:"%d", h)):\(String(format:"%02d", m)):\(String(format:"%02d", s))"
    }
    /*
    func setValueLabel() {

        self.valueLabel.stringValue = ""
        self.valueLabelLower.stringValue = ""
        if tableView.selectedRow >= 0 && tableView.selectedRow < self.synapses.count {
            self.valueLabel.stringValue = self.synapses[tableView.selectedRow].getSynapseValues()
            self.valueLabelLower.stringValue = self.synapses[tableView.selectedRow].getSynapseValuesLower()
        }
    }*/

    func setDetailAreaSettings() {

        self.resetButton.isEnabled = false
        self.directoryButton.isEnabled = false
        self.directoryLabel.stringValue = "Directory : "
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
            if let url = self.synapses[tableView.selectedRow].synapseDataSaveDir {
                self.directoryLabel.stringValue = "Directory : \(url.path)"
            }

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
                self.resetButton.isEnabled = true
                self.directoryButton.isEnabled = true
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

    func setDataSaveEnableButton() {

        self.directoryEnableButton.isEnabled = false
        if tableView.selectedRow >= 0 && tableView.selectedRow < self.synapses.count {
            self.directoryEnableButton.isEnabled = true

            self.directoryEnableButton.title = "Off"
            self.directoryEnableButton.state = .off
            if self.synapses[tableView.selectedRow].synapseDataSaveEnable {
                self.directoryEnableButton.title = "On"
                self.directoryEnableButton.state = .on
            }
        }
    }

    func setFirmwareSettingArea() {

        self.firmwareLabel.stringValue = ""
        self.firmwareUpdateButton.isHidden = true
        self.firmwareCancelButton.isHidden = true
        self.firmwareLabel.stringValue = "Firmware Version : "
        if tableView.selectedRow >= 0 && tableView.selectedRow < self.synapses.count {
            if self.synapses[tableView.selectedRow].synapseFirmwareUpdateStatus != .off {
                self.firmwareComboBox.isHidden = true
                self.firmwareUpdateButton.isHidden = true
                self.firmwareCancelButton.isHidden = false
                self.firmwareLabel.stringValue = self.synapses[tableView.selectedRow].synapseFirmwareUpdateMessage
            }
            else {
                if self.synapses[tableView.selectedRow].synapseValues.isConnected {
                    self.firmwareUpdateButton.isHidden = false
                    self.firmwareUpdateButton.isEnabled = true
                    if self.firmwareUpdateLocked {
                        self.firmwareUpdateButton.isEnabled = false
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
                else {
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
            }
        }
        else {
            self.firmwareComboBox.isHidden = true
        }
        self.setSizeFirmwareViews()
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
            //print("updateFirmwareData: \(self.firmwareSelectIndex)")
            if self.firmwareSelectIndex >= 0 && self.firmwareSelectIndex < self.firmwares.count {
                if let hexFile = self.firmwares[self.firmwareSelectIndex]["hex_file"] as? String {
                    self.synapses[self.tableView.selectedRow].startFirmwareUpdate(hexFile: hexFile)
                    /*if let vc = storyboard?.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "FirmwearUpdateViewController")) as? FirmwearUpdateViewController {
                        self.firmwearUpdateViewController = vc
                        self.firmwearUpdateViewController?.synapseObject = self.synapses[self.tableView.selectedRow]
                        self.firmwearUpdateViewController?.hexFileName = hexFile
                        self.firmwearUpdateViewController?.delegate = self
                        self.presentViewControllerAsModalWindow(self.firmwearUpdateViewController!)
                    }*/
                }
            }
        }
    }

    func updateFirmwareCancel() {

        if self.tableView.selectedRow >= 0 && self.tableView.selectedRow < self.synapses.count {
            if self.synapses[self.tableView.selectedRow].synapseFirmwareUpdateStatus != .off {
                self.synapses[self.tableView.selectedRow].cancelFirmwareUpdate()
            }
        }
    }

    func updateFirmwearPreStart(_ synapseObject: SynapseObject) {

        self.sendDataToDevice(synapseObject)
    }

    func updateFirmwareCheck(_ uuid: UUID) {

        for synapseObject in synapses {
            if let synapse = synapseObject.synapse, synapse.peripheral.identifier == uuid {
                if synapseObject.synapseFirmwareUpdateStatus == .on {
                    synapseObject.readyFirmwareUpdate()
                }
                break
            }
        }
        /*if let _ = self.firmwearUpdateViewController {
            if let synapseObject = self.firmwearUpdateViewController!.synapseObject, let synapse = synapseObject.synapse, synapse.peripheral.identifier == uuid {
                self.firmwearUpdateViewController?.updateFirmwearStart()
            }
        }*/
    }

    func checkFirmwareSettingArea(uuid: UUID, isForced: Bool = false) {

        var pt: Int = -1
        for (index, synapseObject) in synapses.enumerated() {
            if let synapse = synapseObject.synapse, synapse.peripheral.identifier == uuid {
                pt = index
                break
            }
        }
        if pt >= 0 {
            self.tableView.reloadData(forRowIndexes: IndexSet(integer: pt),
                                      columnIndexes: IndexSet(integer: SynapseValueTableColumn.firmware.rawValue))
            if isForced || pt == self.tableView.selectedRow {
                self.setFirmwareSettingArea()
            }
        }
    }

    // MARK: mark - TableView methods

    func numberOfRows(in tableView: NSTableView) -> Int {

        return synapses.count
    }
    /*
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {

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

        if let tableColumn = tableColumn {
            var str: String = ""
            if tableColumn.identifier.rawValue == "UUID" {
                if let synapse = self.synapses[row].synapse {
                    str = synapse.peripheral.identifier.uuidString
                }
            }
            else if tableColumn.identifier.rawValue == "Connect" {
                if self.synapses[row].synapseValues.isConnected {
                    str = self.makeConnectedDateString(row)
                }
                else if self.synapses[row].synapseValues.isDisconnected {
                    str = "Disconnected"
                }
                /*else if let date = self.synapses[row].synapseScanLatestDate, date.timeIntervalSinceNow < -self.synapseScanLimitTimeInterval {
                    str = "×"
                }*/
                else {
                    str = "Lost"
                }
                //print("Connect tableColumn: \(self.synapses[row].synapseScanLatestDate)")
            }
            else if tableColumn.identifier.rawValue == "Count" {
                str = String(format:"%d", self.synapses[row].synapseReceivedCount % self.countResetValue)
            }
            else if tableColumn.identifier.rawValue == "CO2" {
                str = "-"
                if let co2 = self.synapses[row].synapseValues.co2 {
                    str = String(co2)
                }
            }
            else if tableColumn.identifier.rawValue == "TEMP" {
                str = "-"
                if let temp = self.synapses[row].synapseValues.temp {
                    str = String(format:"%.1f", temp)
                }
            }
            else if tableColumn.identifier.rawValue == "HUM" {
                str = "-"
                if let humidity = self.synapses[row].synapseValues.humidity {
                    str = String(humidity)
                }
            }
            else if tableColumn.identifier.rawValue == "LIT" {
                str = "-"
                if let light = self.synapses[row].synapseValues.light {
                    str = String(light)
                }
            }
            else if tableColumn.identifier.rawValue == "AIR" {
                str = "-"
                if let pressure = self.synapses[row].synapseValues.pressure {
                    str = String(format:"%.2f", pressure)
                }
            }
            else if tableColumn.identifier.rawValue == "SND" {
                str = "-"
                if let sound = self.synapses[row].synapseValues.sound {
                    str = String(sound)
                }
            }
            else if tableColumn.identifier.rawValue == "AX" {
                str = "-"
                if let ax = self.synapses[row].synapseValues.ax {
                    str = String(format:"%.3f", CommonFunction.makeAccelerationValue(Float(ax)))
                }
            }
            else if tableColumn.identifier.rawValue == "AY" {
                str = "-"
                if let ay = self.synapses[row].synapseValues.ay {
                    str = String(format:"%.3f", CommonFunction.makeAccelerationValue(Float(ay)))
                }
            }
            else if tableColumn.identifier.rawValue == "AZ" {
                str = "-"
                if let az = self.synapses[row].synapseValues.az {
                    str = String(format:"%.3f", CommonFunction.makeAccelerationValue(Float(az)))
                }
            }
            else if tableColumn.identifier.rawValue == "GX" {
                str = "-"
                if let gx = self.synapses[row].synapseValues.gx {
                    str = String(format:"%.3f", CommonFunction.makeGyroscopeValue(Float(gx)))
                }
            }
            else if tableColumn.identifier.rawValue == "GY" {
                str = "-"
                if let gy = self.synapses[row].synapseValues.gy {
                    str = String(format:"%.3f", CommonFunction.makeGyroscopeValue(Float(gy)))
                }
            }
            else if tableColumn.identifier.rawValue == "GZ" {
                str = "-"
                if let gz = self.synapses[row].synapseValues.gz {
                    str = String(format:"%.3f", CommonFunction.makeGyroscopeValue(Float(gz)))
                }
            }
            else if tableColumn.identifier.rawValue == "Firmware" {
                if self.synapses[row].synapseFirmwareUpdateStatus == .off {
                    //print("str: \(self.synapses[row].synapseFirmwareInfo)")
                    if let version = self.synapses[row].synapseFirmwareInfo["device_version"] as? String {
                        str = version
                        if let date = self.synapses[row].synapseFirmwareInfo["date"] as? String {
                            str = "\(str) (\(date))"
                        }
                    }
                }
                else {
                    str = self.synapses[row].synapseFirmwareUpdateStatusText
                }
            }
            /*else if tableColumn.identifier.rawValue == "Received" {
                str = "\(self.synapses[row].synapseReceivedCount)"
            }
            else if tableColumn.identifier.rawValue == "Directory" {
                if let url = self.synapses[row].synapseDataSaveDir {
                    str = url.path
                }
            }*/

            //print("viewFor: \(str)")
            let cell: NSTableCellView = tableView.makeView(withIdentifier: tableColumn.identifier, owner: self) as! NSTableCellView
            if tableColumn.identifier.rawValue == "Battery" {
                for subview in cell.subviews {
                    if let levelIndicator = subview as? NSLevelIndicator {
                        levelIndicator.doubleValue = 0
                        if let battery = self.synapses[row].synapseValues.battery {
                            levelIndicator.doubleValue = Double(ceil(battery / 20.0))
                        }
                        break
                    }
                }
            }
            else if tableColumn.identifier.rawValue == "Firmware" {
                for subview in cell.subviews {
                    if let progressIndicator = subview as? NSProgressIndicator {
                        progressIndicator.isHidden = true
                        if str.count <= 0, self.synapses[row].synapseFirmwareUpdateStatus == .running {
                            progressIndicator.isHidden = false
                            progressIndicator.doubleValue = self.synapses[row].synapseFirmwareUpdatePercentage
                            progressIndicator.controlTint = .graphiteControlTint
                        }
                        break
                    }
                }
                cell.textField?.stringValue = str
            }
            else {
                cell.textField?.stringValue = str
            }
            //print("viewFor: \(cell.subviews.count)")
            return cell
        }
        return nil
    }
    /*
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {

        return 26.0
    }*/

    func tableView(_ tableView: NSTableView, didAdd rowView: NSTableRowView, forRow row: Int) {

        rowView.backgroundColor = NSColor.white
        if row % 2 == 1 {
            rowView.backgroundColor = NSColor.lightGray.withAlphaComponent(0.1)
        }
    }

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

    func comboBoxSelectionDidChange(_ notification: Notification) {

        //print("comboBoxSelectionDidChange")
        if !self.firmwareComboBox.isHidden, let comboBox = notification.object as? NSComboBox, comboBox == self.firmwareComboBox {
            //print("firmwareComboBox: \(comboBox.indexOfSelectedItem)")
            self.firmwareSelectIndex = comboBox.indexOfSelectedItem
        }
    }

    // MARK: mark - Synapse Device methods

    func setRFduinoManager() {

        if let name = CommonFunction.getAppinfoValue("device_name") as? String {
            self.synapseDeviceName = name
        }

        self.rfduinoManager = RFduinoManager()
        self.rfduinoManager.delegate = self

        /*self.checkScanningTimer = Timer.scheduledTimer(timeInterval: 1.0,
                                                       target: self,
                                                       selector: #selector(self.checkScanning),
                                                       userInfo: nil,
                                                       repeats: true)
        self.checkScanningTimer?.fire()*/
    }

    /*@objc func checkScanning() {

        for i in 0..<self.synapses.count {
            self.tableView.reloadData(forRowIndexes: IndexSet(integer: i),
                                      columnIndexes: IndexSet(integersIn: SynapseValueTableColumn.connect.rawValue..<SynapseValueTableColumn.total.rawValue))
        }
    }*/

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
                synapseObject.resetSynapseSaveValues()
                self.synapses[synapseIndex] = synapseObject
            }
            else {
                let synapseObject: SynapseObject = SynapseObject(rfduino)
                synapseObject.synapse?.delegate = self
                synapseObject.synapseScanLatestDate = Date()
                synapseObject.vc = self
                self.synapses.append(synapseObject)
                //print("add: \(synapseObject)")
                synapseIndex = self.synapses.count - 1

                self.tableView.reloadData()
            }

            if synapseIndex >= 0 && synapseIndex < self.synapses.count {
                if !self.synapses[synapseIndex].synapseValues.isDisconnected {
                    self.rfduinoManager.connect(self.synapses[synapseIndex].synapse)
                }
            }
        }
    }

    func startCommunicationSynapse(_ synapseObject: SynapseObject) {

        synapseObject.synapseSendModeNext = SendMode.I5_3_4
        synapseObject.synapseSendModeSuspension = true
        self.sendResetToDevice(synapseObject)
    }
    
    func setSynapseData(synapseObject: SynapseObject) {

        if let synapse = synapseObject.synapse {
            var now: Date? = Date()
            var data: [UInt8]? = synapseObject.receiveData
            synapseObject.synapseData.insert([
                "time": now!.timeIntervalSince1970,
                "data": data!,
                "uuid": synapse.peripheral.identifier.uuidString
            ], at: 0)
            if synapseObject.synapseData.count > self.synapseDataMax {
                synapseObject.synapseData.removeLast()
            }
            //print("setSynapseData: \(time)")
            synapseObject.setSynapseValues()
            synapseObject.synapseReceivedCount += 1

            now = nil
            data = nil

            //self.setDataCountLabel()

            self.saveCheckSynapseData(synapseObject: synapseObject)
        }
    }

    func saveCheckSynapseData(synapseObject: SynapseObject) {

        if synapseObject.synapseDataSaveEnable, synapseObject.synapseDataSaveDir != nil {
            if let time = synapseObject.synapseValues.time {
                let fileRecord: String = synapseObject.synapseValues.makeSynapseFileRecord()
                if synapseObject.synapseDataSaveRunning {
                    if let synapseDataSaveValueAlt = synapseObject.synapseDataSaveValueAlt {
                        synapseObject.synapseDataSaveValueAlt = "\(synapseDataSaveValueAlt)\(fileRecord)"
                    }
                    else {
                        synapseObject.synapseDataSaveValueAlt = fileRecord
                        synapseObject.synapseDataSaveDateAlt = time
                    }
                }
                else {
                    if let synapseDataSaveValue = synapseObject.synapseDataSaveValue {
                        synapseObject.synapseDataSaveValue = "\(synapseDataSaveValue)\(fileRecord)"
                    }
                    else {
                        synapseObject.synapseDataSaveValue = fileRecord
                        synapseObject.synapseDataSaveDate = time
                    }
                }

                var flag: Bool = false
                if !synapseObject.synapseDataSaveRunning {
                    if synapseObject.synapseTimeInterval >= self.synapseSaveTimeInterval {
                        flag = true
                    }
                    else if let synapseDataSaveDate = synapseObject.synapseDataSaveDate, Date().timeIntervalSince1970 - synapseDataSaveDate >= self.synapseSaveTimeInterval {
                        flag = true
                    }
                }
                if flag {
                    self.saveSynapseData(synapseObject: synapseObject)
                }
            }
            /*let data: Data? = synapseObject.synapseValues.makeSynapseFileRecord().data(using: .utf8)
            if let data = data {
                DispatchQueue.global(qos: .background).async {
                    _ = self.synapseFileManager.setValues(baseURL: baseURL,
                                                          uuid: synapse.peripheral.identifier.uuidString,
                                                          data: data,
                                                          date: connectedDate)
                }
            }*/
        }
    }

    func saveSynapseData(synapseObject: SynapseObject) {

        if synapseObject.synapseDataSaveEnable, let baseURL = synapseObject.synapseDataSaveDir, let connectedDate = synapseObject.synapseValues.connectedDate, let synapse = synapseObject.synapse {
            synapseObject.synapseDataSaveRunning = true

            if let synapseDataSaveValue = synapseObject.synapseDataSaveValue {
                DispatchQueue.global(qos: .background).async {
                    var data: Data? = synapseDataSaveValue.data(using: .utf8)
                    if data != nil {
                        _ = self.synapseFileManager.setValues(baseURL: baseURL,
                                                              uuid: synapse.peripheral.identifier.uuidString,
                                                              data: data!,
                                                              date: connectedDate)
                    }
                    data = nil
                }
            }

            synapseObject.synapseDataSaveValue = synapseObject.synapseDataSaveValueAlt
            synapseObject.synapseDataSaveDate = synapseObject.synapseDataSaveDateAlt
            synapseObject.synapseDataSaveValueAlt = nil
            synapseObject.synapseDataSaveDateAlt = nil
            synapseObject.synapseDataSaveRunning = false
        }
    }

    func connectSynapseObjectAction(_ uuid: UUID) {

        for synapseObject in self.synapses {
            if let synapse = synapseObject.synapse, synapse.peripheral.identifier == uuid {
                synapseObject.initFirmwareUpdateValue()

                if let url = synapseObject.synapseDataSaveDir, let synapse = synapseObject.synapse {
                    let _ = self.synapseFileManager.dirCheck(baseURL: url, uuid: synapse.peripheral.identifier.uuidString)
                }

                break
            }
        }
    }

    func disconnectSynapseObjectAction(_ uuid: UUID) {

        for (index, synapseObject) in self.synapses.enumerated() {
            if let synapse = synapseObject.synapse, synapse.peripheral.identifier == uuid {
                self.saveSynapseData(synapseObject: synapseObject)

                synapseObject.disconnectSynapse()

                self.tableView.reloadData(forRowIndexes: IndexSet(integer: index),
                                          columnIndexes: IndexSet(integersIn: SynapseValueTableColumn.connect.rawValue..<SynapseValueTableColumn.count.rawValue))
                if index == tableView.selectedRow {
                    self.setDetailAreaLabels()
                }

                self.updateFirmwareCheck(uuid)

                break
            }
        }

        self.countConnectedSynapse()
    }

    func countConnectedSynapse() {

        var count: Int = 0
        for synapseObject in self.synapses {
            if synapseObject.synapseValues.isConnected {
                count += 1
            }
        }

        self.synapseSaveTimeInterval = 10.0
        if count > 1 {
            self.synapseSaveTimeInterval = self.synapseSaveTimeInterval * Double(count)
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
        self.connectSynapseObjectAction(rfduino.peripheral.identifier)
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
        self.disconnectSynapseObjectAction(rfduino.peripheral.identifier)
    }

    func shouldDisplayAlertTitled(_ title: String!, messageBody: String!, peripheral: CBPeripheral?) -> Void {

        print("shouldDisplayAlertTitled")
        if let title = title {
            print("Title: \(title)")
        }

        if title != "Bluetooth LE Support", let peripheral = peripheral {
            self.disconnectSynapseObjectAction(peripheral.identifier)
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
        /*let val = data.map { String(format: "%.2hhx", $0) }.joined()
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
        var bytes: [UInt8]? = [UInt8](data)
        var restBytes: [UInt8]? = nil
        var cnt: Int = 0
        if synapseObject.receiveData.count > 2 {
            cnt = Int(synapseObject.receiveData[2])
        }
        else if bytes!.count > 2 && Int(bytes![0]) == 0 && Int(bytes![1]) == 255 {
            cnt = Int(bytes![2])
        }
        if cnt >= minLength {
            for i in 0..<bytes!.count {
                if synapseObject.receiveData.count < cnt {
                    synapseObject.receiveData.append(bytes![i])
                }
                else {
                    if restBytes == nil {
                        restBytes = []
                    }
                    restBytes?.append(bytes![i])
                }
            }
        }
        if cnt >= minLength && synapseObject.receiveData.count == cnt {
            //print("self.receiveData: \(self.receiveData)")
            if Int(synapseObject.receiveData[0]) == 0 && Int(synapseObject.receiveData[1]) == 255 && Int(synapseObject.receiveData[synapseObject.receiveData.count - 2]) == 0 && Int(synapseObject.receiveData[synapseObject.receiveData.count - 1]) == 255 {
                if Int(synapseObject.receiveData[3]) == 2 {
                    self.setSynapseData(synapseObject: synapseObject)

                    self.tableView.reloadData(forRowIndexes: IndexSet(integer: index),
                                              columnIndexes: IndexSet(integersIn: SynapseValueTableColumn.connect.rawValue..<SynapseValueTableColumn.firmware.rawValue))
                    //print("setReceiveData: \(index) - \(tableView.selectedRow)")
                    /*if index == tableView.selectedRow {
                        //print("setReceiveData: \(index)")
                        self.setValueLabel()
                    }*/

                    self.updateSynapseDataWindow(synapseObject)
                }
            }

            synapseObject.receiveData = []
            if let bytes = restBytes, bytes.count > 2, Int(bytes[0]) == 0, Int(bytes[1]) == 255, Int(bytes[2]) >= minLength {
                synapseObject.receiveData = bytes
            }
        }
        bytes = nil
        restBytes = nil
        //print("receiveData: \(self.receiveData)")
    }

    // MARK: mark - Send Data To synapseWear methods

    func sendAccessKeyToDevice(_ synapseObject: SynapseObject) {

        if let synapse = synapseObject.synapse, let accessKey = synapseObject.synapseAccessKey {
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
                synapseObject.synapseValues.isDisconnected = false
                synapseObject.synapseValues.connectedDate = Date()
                synapseObject.synapseSendModeSuspension = false
                synapseObject.synapseSendMode = SendMode.I0

                synapseObject.initSynapseGraphData()

                self.countConnectedSynapse()

                if index >= 0 {
                    self.tableView.reloadData(forRowIndexes: IndexSet(integer: index),
                                              columnIndexes: IndexSet(integer: SynapseValueTableColumn.connect.rawValue))
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

        if let synapse = synapseObject.synapse, let accessKey = synapseObject.synapseAccessKey {
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

            self.tableView.reloadData(forRowIndexes: IndexSet(integer: index),
                                      columnIndexes: IndexSet(integer: SynapseValueTableColumn.firmware.rawValue))

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

    func sendDataToDevice(_ synapseObject: SynapseObject) {

        if let synapse = synapseObject.synapse {
            let data: Data = Data(bytes: [0xfe])
            print("sendDataToDevice: \([UInt8](data))")
            synapse.send(data)
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

    func sendRebootToDevice(_ synapseObject: SynapseObject) {

        if let synapse = synapseObject.synapse {
            let data: Data = Data(bytes: [0x14])
            print("sendRebootToDevice: \([UInt8](data))")
            synapse.send(data)
        }
    }
}

class SynapseObject: NSObject, OTABootloaderControllerDelegate {

    let aScale: Float = 2.0 / 32768.0
    let gScale: Float = 250.0 / 32768.0
    let settingDataManager: SettingDataManager = SettingDataManager()
    var synapse: RFduino?
    var synapseAccessKey: Data?
    var synapseSendMode: SendMode!
    var synapseSendModeNext: SendMode?
    var synapseSendModeSuspension: Bool = false
    var receiveData: [UInt8]!
    var synapseData: [[String: Any]]!
    var synapseValues: SynapseValues!
    var synapseNowDate: String!
    var synapseDataSaveEnable: Bool = false
    var synapseDataSaveDir: URL?
    var synapseDataSaveDirDefault: URL?
    var synapseDataSaveDirChecked: Bool = false
    var synapseDataSaveRunning: Bool = false
    var synapseDataSaveValue: String?
    var synapseDataSaveDate: TimeInterval?
    var synapseDataSaveValueAlt: String?
    var synapseDataSaveDateAlt: TimeInterval?
    var synapseTimeInterval: TimeInterval = 1.0
    var synapseValidSensors: [String: Bool] = [:]
    var synapseScanLatestDate: Date?
    var synapseReceivedCount: Int = 0
    var oscSending: Bool = false
    var oscClient: F53OSCClient?
    var oscIPAddress: String = ""
    var oscPort: String = ""
    var vc: ViewController?
    // For Firmware Update
    var synapseFirmwareInfo: [String: Any] = [:]
    var synapseFirmwareUpdateStatus: FirmwareUpdateStatus = .off
    var synapseFirmwareUpdateStatusText: String = ""
    var synapseFirmwareUpdateMessage: String = ""
    var synapseFirmwareUpdatePercentage: Double = 0
    var synapseFirmwareUpdateHexFileName: String?
    var synapseFirmwareUpdateFileUrl: URL?
    var synapseFirmwareUpdateDownloadRequest: DownloadRequest?
    var otaBootloaderController: OTABootloaderController?
    // For Graph Data
    let synapseCrystalInfo: SynapseCrystalStruct = SynapseCrystalStruct()
    let synapseGraphDataLimit: TimeInterval = 1 * 60.0 + 1.0
    var synapseGraphKeys: [String] = []
    var synapseGraphData: [String: Any] = [:]
    var synapseGraphTimes: [TimeInterval] = []
    var synapseGraphLabels: [String] = []
    var synapseGraphValues: [[[String: Any]]] = []
    var synapseGraphMaxAndMinValues: [String: [String: Double]] = [:]
    var synapseGraphColors: [String] = []

    init(_ synapse: RFduino, name: String? = nil) {

        self.synapse = synapse
        self.synapseSendMode = SendMode.I0
        self.receiveData = []
        self.synapseData = []
        self.synapseValues = SynapseValues(name)
        self.synapseNowDate = ""

        if let setting = self.settingDataManager.getSynapseSettingData(synapse.peripheral.identifier.uuidString) {
            //print("setting: \(setting)")
            if let synapseDataSaveEnable = setting[self.settingDataManager.synapseDirectoryEnableKey] as? Bool {
                self.synapseDataSaveEnable = synapseDataSaveEnable
            }
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

            self.synapseDataSaveDir = self.synapseDataSaveDirDefault
        }
    }

    func disconnectSynapse() {

        //print("disconnectSynapse")
        self.synapseData = []
        self.synapseValues.resetValues()
        self.setOffOSC()
    }

    func resetSynapseSaveValues() {

        self.synapseDataSaveRunning = false
        self.synapseDataSaveValue = nil
        self.synapseDataSaveDate = nil
        self.synapseDataSaveValueAlt = nil
        self.synapseDataSaveDateAlt = nil
    }

    // MARK: mark - Synapse Setting methods

    func saveSynapseSettingData(isSaveDir: Bool, isSaveSendData: Bool, isSaveOSCData: Bool) {

        if let synapse = self.synapse {
            var settingData: [String: Any] = [:]
            if let setting = self.settingDataManager.getSynapseSettingData(synapse.peripheral.identifier.uuidString) {
                settingData = setting
            }
            if isSaveDir {
                settingData[self.settingDataManager.synapseDirectoryEnableKey] = self.synapseDataSaveEnable
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
            print("saveSynapseSettingData: \(settingData)")
            self.settingDataManager.setSynapseSettingData(synapse.peripheral.identifier.uuidString, data: settingData)
        }
    }

    // MARK: mark - Make SynapseData methods
    
    func setSynapseValues() {

        if self.synapseData.count > 0 {
            var synapse: [String: Any]? = self.synapseData[0]
            //print("setSynapseValues: \(synapse)")
            if let time = synapse!["time"] as? TimeInterval, let data = synapse!["data"] as? [UInt8], let uuid = synapse!["uuid"] as? String {
                let formatter: DateFormatter = DateFormatter()
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
                var values: [String: Any]? = self.makeSynapseData(data)
                //print("setSynapseValues: \(self.synapseNowDate)\n\(values)")
                if let co2 = values!["co2"] as? Int, co2 >= 400 {
                    self.synapseValues.co2 = co2
                }
                if let ax = values!["ax"] as? Int {
                    self.synapseValues.ax = ax
                }
                if let ay = values!["ay"] as? Int {
                    self.synapseValues.ay = ay
                }
                if let az = values!["az"] as? Int {
                    self.synapseValues.az = az
                }
                if let light = values!["light"] as? Int {
                    self.synapseValues.light = light
                }
                if let gx = values!["gx"] as? Int {
                    self.synapseValues.gx = gx
                }
                if let gy = values!["gy"] as? Int {
                    self.synapseValues.gy = gy
                }
                if let gz = values!["gz"] as? Int {
                    self.synapseValues.gz = gz
                }
                if let pressure = values!["pressure"] as? Float {
                    self.synapseValues.pressure = pressure
                }
                if let temp = values!["temp"] as? Float {
                    self.synapseValues.temp = temp
                }
                if let humidity = values!["humidity"] as? Int {
                    self.synapseValues.humidity = humidity
                }
                if let sound = values!["sound"] as? Int {
                    self.synapseValues.sound = sound
                }
                if let tvoc = values!["tvoc"] as? Int {
                    self.synapseValues.tvoc = tvoc
                }
                if let volt = values!["volt"] as? Float {
                    self.synapseValues.power = volt
                }
                if let pow = values!["pow"] as? Float {
                    self.synapseValues.battery = pow
                }
                values = nil

                self.setSynapseGraphData()

                self.sendOSC()
                if self.synapseTimeInterval <= 1.0 {
                    self.checkAccelerateSound(x: self.synapseValues.ax,
                                              y: self.synapseValues.ay,
                                              z: self.synapseValues.az,
                                              xBak: axBak,
                                              yBak: ayBak,
                                              zBak: azBak)
                }
            }
            synapse = nil
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

    // MARK: mark - Synapse Graph methods

    func initSynapseGraphData() {

        self.synapseGraphKeys = [
            self.synapseCrystalInfo.co2.key,
            self.synapseCrystalInfo.temp.key,
            self.synapseCrystalInfo.hum.key,
            self.synapseCrystalInfo.ill.key,
            self.synapseCrystalInfo.press.key,
            self.synapseCrystalInfo.sound.key,
            self.synapseCrystalInfo.ax.key,
            self.synapseCrystalInfo.ay.key,
            self.synapseCrystalInfo.az.key,
        ]
        self.synapseGraphColors = [
            "white",
            "red",
            "green",
            "yellow",
            "purple",
            "blue",
            "orange",
            "brown",
            "pink",
        ]

        self.resetSynapseGraphData()
        self.setSynapseGraphTimes()
    }

    func resetSynapseGraphData() {

        self.synapseGraphValues = []
        self.synapseGraphMaxAndMinValues = [:]
        for _ in self.synapseGraphKeys {
            self.synapseGraphValues.append([])
            //self.synapseGraphMaxAndMinValues[key] = [:]
        }
        self.synapseGraphTimes = []
        self.synapseGraphLabels = []
        self.synapseGraphData = [:]
    }

    func setSynapseGraphTimes() {

        if let synapseValues = self.synapseValues, let connectedDate = synapseValues.connectedDate {
            var graphCount: TimeInterval? = self.synapseGraphDataLimit * self.synapseTimeInterval
            var now: Date? = Date()
            //let now: Date = Date(timeIntervalSince1970: floor(Date().timeIntervalSince1970))
            var start: Date? = connectedDate
            //var start: Date = Date(timeIntervalSince1970: floor(connectedDate.timeIntervalSince1970))
            if now!.timeIntervalSince(start!) > graphCount! {
                start = Date(timeInterval: -graphCount!, since: now!)
            }
            now = nil
            var end: Date? = Date(timeInterval: graphCount!, since: start!)

            if self.synapseGraphTimes.count > 0 {
                if self.synapseGraphTimes[self.synapseGraphTimes.count - 1] <= start!.timeIntervalSince1970 {
                    self.resetSynapseGraphData()
                }
                else {
                    var count: Int? = self.synapseGraphTimes.count
                    for _ in 0..<count! {
                        if self.synapseGraphTimes.count <= 0 {
                            break
                        }

                        let time: TimeInterval = self.synapseGraphTimes[0]
                        if time < start!.timeIntervalSince1970 {
                            //print("remove label: \(self.makeSynapseGraphLabel(time, connectedDate: connectedDate))")
                            if let labelIndex = self.synapseGraphLabels.index(of: self.makeSynapseGraphLabel(time, connectedDate: connectedDate)) {
                                self.synapseGraphLabels.remove(at: labelIndex)
                            }
                            self.removeSynapseGraphData(time)
                            self.synapseGraphTimes.removeFirst()
                        }
                        else {
                           break
                        }
                    }
                    count = nil

                    if self.synapseGraphTimes.count > 0 && self.synapseGraphTimes[self.synapseGraphTimes.count - 1] >= start!.timeIntervalSince1970 {
                        start = Date(timeIntervalSince1970: self.synapseGraphTimes[self.synapseGraphTimes.count - 1] + self.synapseTimeInterval)
                    }
                }
            }

            var count: TimeInterval? = start!.timeIntervalSince1970
            while end!.timeIntervalSince1970 - count! > -self.synapseTimeInterval {
                var label: String? = self.makeSynapseGraphLabel(count!, connectedDate: connectedDate)
                self.synapseGraphTimes.append(count!)
                self.synapseGraphLabels.append(label!)
                count! += self.synapseTimeInterval
                label = nil
            }
            count = nil
            //print("setSynapseGraphTimes: \(self.synapseGraphLabels)")
            //print("setSynapseGraphData Last: \(count.timeIntervalSince1970 - self.synapseTimeInterval), \(self.synapseGraphLabels.last)")

            graphCount = nil
            start = nil
            end = nil
        }
    }

    func makeSynapseGraphLabel(_ time: TimeInterval, connectedDate: Date) -> String {

        var diff: TimeInterval? = round((time - connectedDate.timeIntervalSince1970) / self.synapseTimeInterval) * self.synapseTimeInterval
        var format: String? = "\(self.getSynapseGraphLabelFormat()) sec"
        //print("makeSynapseGraphLabel: \(String(format: format, diff)), \(diff)")

        let label: String = String(format: format!, diff!)
        diff = nil
        format = nil
        return label
    }

    func getSynapseGraphLabelFormat() -> String {

        var format: String = "%.0f"
        if self.synapseTimeInterval < 0.01 {
            format = "%.3f"
        }
        else if self.synapseTimeInterval < 0.1 {
            format = "%.2f"
        }
        else if self.synapseTimeInterval < 1.0 {
            format = "%.1f"
        }
        return format
    }

    func setSynapseGraphData() {

        if let time = self.synapseValues.time {
            var graphTime: TimeInterval? = floor(time / self.synapseTimeInterval) * self.synapseTimeInterval
            //let graphTime: TimeInterval = floor(time)
            var key: String? = String(format: self.getSynapseGraphLabelFormat(), graphTime!)
            var label: String? = ""
            if let connectedDate = self.synapseValues.connectedDate {
                label = self.makeSynapseGraphLabel(time, connectedDate: connectedDate)
            }
            //print("setSynapseGraphData: \(time), \(label)")

            var value: Double? = nil
            if let co2 = self.synapseValues.co2 {
                value = Double(co2)
            }
            self.setSynapseGraphValue(synapseValue: value,
                                      synapseKey: synapseCrystalInfo.co2.key,
                                      graphTime: graphTime!,
                                      key: key!,
                                      label: label!)

            value = nil
            if let temp = self.synapseValues.temp {
                value = Double(temp)
            }
            self.setSynapseGraphValue(synapseValue: value,
                                      synapseKey: synapseCrystalInfo.temp.key,
                                      graphTime: graphTime!,
                                      key: key!,
                                      label: label!)

            value = nil
            if let humidity = self.synapseValues.humidity {
                value = Double(humidity)
            }
            self.setSynapseGraphValue(synapseValue: value,
                                      synapseKey: synapseCrystalInfo.hum.key,
                                      graphTime: graphTime!,
                                      key: key!,
                                      label: label!)

            value = nil
            if let light = self.synapseValues.light {
                value = Double(light)
            }
            self.setSynapseGraphValue(synapseValue: value,
                                      synapseKey: synapseCrystalInfo.ill.key,
                                      graphTime: graphTime!,
                                      key: key!,
                                      label: label!)

            value = nil
            if let pressure = self.synapseValues.pressure {
                value = Double(pressure)
            }
            self.setSynapseGraphValue(synapseValue: value,
                                      synapseKey: synapseCrystalInfo.press.key,
                                      graphTime: graphTime!,
                                      key: key!,
                                      label: label!)

            value = nil
            if let sound = self.synapseValues.sound {
                value = Double(sound)
            }
            self.setSynapseGraphValue(synapseValue: value,
                                      synapseKey: synapseCrystalInfo.sound.key,
                                      graphTime: graphTime!,
                                      key: key!,
                                      label: label!)

            value = nil
            if let ax = self.synapseValues.ax {
                var axValue: Float? = CommonFunction.makeAccelerationValue(Float(ax))
                value = Double(axValue!)
                axValue = nil
            }
            self.setSynapseGraphValue(synapseValue: value,
                                      synapseKey: synapseCrystalInfo.ax.key,
                                      graphTime: graphTime!,
                                      key: key!,
                                      label: label!)

            value = nil
            if let ay = self.synapseValues.ay {
                var ayValue: Float? = CommonFunction.makeAccelerationValue(Float(ay))
                value = Double(ayValue!)
                ayValue = nil
            }
            self.setSynapseGraphValue(synapseValue: value,
                                      synapseKey: synapseCrystalInfo.ay.key,
                                      graphTime: graphTime!,
                                      key: key!,
                                      label: label!)

            value = nil
            if let ay = self.synapseValues.ay {
                var ayValue: Float? = CommonFunction.makeAccelerationValue(Float(ay))
                value = Double(ayValue!)
                ayValue = nil
            }
            self.setSynapseGraphValue(synapseValue: value,
                                      synapseKey: synapseCrystalInfo.ay.key,
                                      graphTime: graphTime!,
                                      key: key!,
                                      label: label!)

            value = nil
            if let az = self.synapseValues.az {
                var azValue: Float? = CommonFunction.makeAccelerationValue(Float(az))
                value = Double(azValue!)
                azValue = nil
            }
            self.setSynapseGraphValue(synapseValue: value,
                                      synapseKey: synapseCrystalInfo.az.key,
                                      graphTime: graphTime!,
                                      key: key!,
                                      label: label!)

            //print("setSynapseGraphData: \(self.synapseGraphData)")

            value = nil
            graphTime = nil
            key = nil
            label = nil
        }

        self.setSynapseGraphTimes()
    }

    func setSynapseGraphValue(synapseValue: Double?, synapseKey: String, graphTime: TimeInterval, key: String, label: String) {

        if let synapseValue = synapseValue {
            var graphData: [String: Any]? = [:]
            if let data = self.synapseGraphData[synapseKey] as? [String: Any] {
                graphData = data
            }

            if let values = graphData![key] as? [String: Any], let count = values["count"] as? Int, let value = values["value"] as? Double {
                //print("setSynapseGraphData: \(values)")
                graphData![key] = [
                    "count": count + Int(1),
                    "value": (value * Double(count) + synapseValue) / Double(count + 1),
                ]
            }
            else {
                graphData![key] = [
                    "count": Int(1),
                    "value": synapseValue,
                ]
            }

            var removeKey: String? = self.setSynapseGraphData(synapseKey, time: graphTime, label: label, data: graphData![key] as! [String : Any])
            if let removeKey = removeKey {
                var graphDataKeys: [String]? = [String](graphData!.keys)
                graphDataKeys!.sort { $1 > $0 }
                for graphDataKey in graphDataKeys! {
                    if graphDataKey > removeKey {
                        //print("break key: \(graphDataKey)")
                        break
                    }
                    graphData!.removeValue(forKey: graphDataKey)
                }
                graphDataKeys = nil
            }
            self.synapseGraphData[synapseKey] = graphData
            //print("synapseGraphData count: \(synapseKey), \(String(describing: removeKey)), \(graphData!.keys.count)")
            //print("synapseGraphData key: \(key)")

            removeKey = nil
            graphData = nil
        }
        else {
            _ = self.setSynapseGraphData(synapseKey, time: graphTime, label: "", data: [:])
        }
    }

    func setSynapseGraphData(_ key: String, time: TimeInterval, label: String, data: [String: Any]) -> String? {

        var removeKey: String? = nil
        if let index = self.synapseGraphKeys.index(of: key), index < self.synapseGraphValues.count {
            var values: [[String: Any]]? = self.synapseGraphValues[index]
            //print("setSynapseGraphData: \(key), \(values)")

            if self.synapseGraphTimes.count > 0 {
                var startTime: TimeInterval? = self.synapseGraphTimes.first
                var count: Int? = values!.count
                for _ in 0..<count! {
                    if values!.count <= 0 {
                        break
                    }

                    var data: [String: Any]? = values!.first
                    if let dataTime = data!["time"] as? Double {
                        if dataTime < startTime! {
                            values!.removeFirst()
                            removeKey = String(format: self.getSynapseGraphLabelFormat(), dataTime)
                            //print("removeKey: \(removeKey!)")
                        }
                        else {
                            break
                        }
                    }
                    else {
                        values!.removeFirst()
                    }
                    data = nil
                }
                startTime = nil
                count = nil
            }

            if label.count > 0, let value = data["value"] {
                var addData: [String: Any]? = ["time": time, "x": label, "y": value]
                if values!.count > 0 {
                    if let lastTime = values![values!.count - 1]["time"] as? Double, lastTime != time {
                        values!.append(addData!)
                    }
                    else {
                        values![values!.count - 1] = addData!
                    }
                }
                else {
                    values!.append(addData!)
                }
                addData = nil

                if let value = value as? Double {
                    //print("key: \(key), value: \(value)")
                    if key == self.synapseCrystalInfo.ax.key || key == self.synapseCrystalInfo.ay.key || key == self.synapseCrystalInfo.az.key {
                        self.setSynapseGraphMaxAndMinValue(self.synapseCrystalInfo.ax.key, value: value)
                        self.setSynapseGraphMaxAndMinValue(self.synapseCrystalInfo.ay.key, value: value)
                        self.setSynapseGraphMaxAndMinValue(self.synapseCrystalInfo.az.key, value: value)
                    }
                    else {
                        self.setSynapseGraphMaxAndMinValue(key, value: value)
                    }
                }
                //print("synapseGraphMaxAndMinValues: \(self.synapseGraphMaxAndMinValues)")
            }
            self.synapseGraphValues[index] = values!

            values = nil
        }
        return removeKey
    }

    func setSynapseGraphMaxAndMinValue(_ key: String, value: Double) {

        var graphMaxAndMinValue: [String: Double]? = [:]
        if let data = self.synapseGraphMaxAndMinValues[key] {
            graphMaxAndMinValue = data
        }
        else {
            if key == self.synapseCrystalInfo.co2.key {
                graphMaxAndMinValue = [
                    "max": 400.0,
                    "min": 400.0,
                ]
            }
            else if key == self.synapseCrystalInfo.ax.key || key == self.synapseCrystalInfo.ay.key || key == self.synapseCrystalInfo.az.key {
                graphMaxAndMinValue = [
                    "max": 1.0,
                    "min": -1.0,
                ]
            }
            else {
                graphMaxAndMinValue = [
                    "max": value + 1.0,
                    "min": value - 1.0,
                ]
            }
            /*if key == self.synapseCrystalInfo.co2.key {
                if graphMaxAndMinValue["max"]! < 400.0 {
                    graphMaxAndMinValue["max"] = 400.0
                }
                if graphMaxAndMinValue["min"]! < 400.0 {
                    graphMaxAndMinValue["min"] = 400.0
                }
            }*/
        }
        if let max = graphMaxAndMinValue!["max"], max < value {
            graphMaxAndMinValue!["max"] = value
        }
        if let min = graphMaxAndMinValue!["min"], min > value {
            graphMaxAndMinValue!["min"] = value
        }
        self.synapseGraphMaxAndMinValues[key] = graphMaxAndMinValue!

        graphMaxAndMinValue = nil
    }

    func getSynapseGraphScales() -> [[String: Double]] {

        var scales: [[String: Double]] = []
        for key in self.synapseGraphKeys {
            if let data = self.synapseGraphMaxAndMinValues[key] {
                scales.append(data)
            }
            else {
                scales.append([:])
            }
        }
        return scales
    }

    func removeSynapseGraphData(_ time: TimeInterval) {

        var removeKey: String? = String(format: self.getSynapseGraphLabelFormat(), time)
        //let removeKey: String = String(format: self.getSynapseGraphLabelFormat(), floor(time))

        for key in self.synapseGraphKeys {
            if var data = self.synapseGraphData[key] as? [String: Any], let _ = data.keys.index(of: removeKey!) {
                data[removeKey!] = nil
                self.synapseGraphData[key] = data
            }
        }

        removeKey = nil
    }
    
    // MARK: mark - DFU methods

    func startFirmwareUpdate(hexFile: String) {

        if self.synapseFirmwareUpdateStatus == .off, let host = CommonFunction.getAppinfoValue("firmware_domain") as? String, let url = URL(string: "\(host)\(hexFile)") {
            self.vc?.firmwareUpdateLocked = true

            self.synapseFirmwareUpdateStatus = .on
            self.synapseFirmwareUpdateHexFileName = hexFile
            self.startFirmwareFileDownload(hexUrl: url.absoluteString)
        }
    }

    func startFirmwareFileDownload(hexUrl: String) {

        self.synapseFirmwareUpdateFileUrl = self.getFirmwareFileTemporaryUrl(fileName: hexUrl)
        if self.synapseFirmwareUpdateFileUrl == nil {
            self.resetFirmwareUpdate()
            return
        }
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            return (self.synapseFirmwareUpdateFileUrl!, [.removePreviousFile, .createIntermediateDirectories])
        }
        print("startFirmwareFileDownload: \(self.synapseFirmwareUpdateFileUrl!.absoluteString)")

        self.setFirmwareSettingArea(statusText: "Download...",
                                    message: "Firmwear File Download...")

        self.synapseFirmwareUpdateDownloadRequest = Alamofire.download(hexUrl, to: destination)
            .downloadProgress { (progress) in
            }
            .responseData { (data) in
                self.synapseFirmwareUpdateDownloadRequest = nil
                if self.vc != nil {
                    self.setFirmwareSettingArea(statusText: "Ready",
                                                message: "Device Will Enter OTA Mode")
                    self.vc?.updateFirmwearPreStart(self)
                }
                else {
                    self.resetFirmwareUpdate()
                }
        }
    }

    func getFirmwareFileTemporaryUrl(fileName: String) -> URL? {

        guard let nameUrl = URL(string: fileName) else { return nil }
        var fileName: String = nameUrl.lastPathComponent
        if let synapse = self.synapse {
            fileName = "\(synapse.peripheral.identifier.uuidString)-\(fileName)"
        }
        //print("getSaveFileUrl fileName: \(fileName)")
        let documentsUrl: URL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let fileUrl: URL = documentsUrl.appendingPathComponent(fileName)
        //print("getSaveFileUrl fileUrl: \(fileUrl.absoluteString)")
        return fileUrl
    }

    func readyFirmwareUpdate() {

        if let url = self.synapseFirmwareUpdateFileUrl {
            self.setFirmwareSettingArea(statusText: "Ready",
                                        message: "OTA Bootloader Start")

            self.otaBootloaderController = OTABootloaderController()
            self.otaBootloaderController?.delegate = self
            self.otaBootloaderController?.fileURL = url
            self.otaBootloaderController?.start()
        }
        else {
            self.resetFirmwareUpdate()
        }
    }

    func cancelFirmwareUpdate() {

        if self.synapseFirmwareUpdateStatus == .running {
            self.otaBootloaderController?.cancel()
        }
        else {
            self.resetFirmwareUpdate()
        }
    }

    func initFirmwareUpdateValue() {

        self.synapseFirmwareUpdateStatus = .off
        self.synapseFirmwareUpdateStatusText = ""
        self.synapseFirmwareUpdateMessage = ""
        self.synapseFirmwareUpdatePercentage = 0
        self.synapseFirmwareUpdateHexFileName = nil
        self.synapseFirmwareUpdateFileUrl = nil
        self.synapseFirmwareUpdateDownloadRequest = nil
        self.otaBootloaderController?.delegate = nil
        self.otaBootloaderController = nil
    }

    func resetFirmwareUpdate() {

        self.synapseFirmwareUpdateDownloadRequest?.cancel()
        self.synapseFirmwareUpdateDownloadRequest = nil

        self.otaBootloaderController?.stop()

        self.synapseFirmwareUpdateStatus = .off
        self.synapseFirmwareInfo = [:]

        //var isForced: Bool = false
        if let vc = self.vc, vc.firmwareUpdateLocked {
            //isForced = true
            self.vc?.firmwareUpdateLocked = false
        }
        /*if let synapse = self.synapse {
            self.vc?.checkFirmwareSettingArea(uuid: synapse.peripheral.identifier, isForced: isForced)
        }*/
    }

    func setFirmwareSettingArea(statusText: String, message: String, isForced: Bool = false) {

        self.synapseFirmwareUpdateStatusText = statusText
        if let fileName = self.synapseFirmwareUpdateHexFileName {
            self.synapseFirmwareUpdateMessage = "Firmware Update -> \(fileName) : \(message)"
        }
        if let synapse = self.synapse {
            self.vc?.checkFirmwareSettingArea(uuid: synapse.peripheral.identifier, isForced: isForced)
        }
    }

    func onConnectDevice() {

        self.setFirmwareSettingArea(statusText: "Connecting...",
                                    message: "Device Connecting...")
    }

    func onPerformDFUOnFile() {

        self.setFirmwareSettingArea(statusText: "Starting...",
                                    message: "DFU Starting...")
    }

    func onDeviceConnected() {

        self.setFirmwareSettingArea(statusText: "Connected",
                                    message: "Device Connected")
    }

    func onDeviceConnectedWithVersion() {

        self.setFirmwareSettingArea(statusText: "Connected",
                                    message: "Device Connected With Version")
    }

    func onDeviceDisconnected() {

        self.setFirmwareSettingArea(statusText: "Disconnected",
                                    message: "Device Disconnected")
        self.resetFirmwareUpdate()
    }

    func onReadDFUVersion() {

        self.vc?.firmwareUpdateLocked = false

        self.synapseFirmwareUpdateStatus = .standby
        self.setFirmwareSettingArea(statusText: "Standby",
                                    message: "DFU Version Reading...",
                                    isForced: true)
    }

    func onDFUStarted(_ uploadStatusMessage: String!) {

        self.synapseFirmwareUpdateStatus = .running
        self.synapseFirmwareUpdatePercentage = 0
        self.setFirmwareSettingArea(statusText: "",
                                    message: uploadStatusMessage)
    }

    func onDFUCancelled() {

        self.setFirmwareSettingArea(statusText: "Cancelled",
                                    message: "DFU Cancelled")
    }

    func onDFUCancelFinish() {

        self.vc?.firmwareCancelButton.isHidden = true
        self.resetFirmwareUpdate()
    }

    func onBootloaderUploadStarted() {

        self.setFirmwareSettingArea(statusText: "",
                                    message: "Bootloader Uploading...")
    }

    func onTransferPercentage(_ percentage: Int32) {

        self.synapseFirmwareUpdatePercentage = Double(percentage)
        self.setFirmwareSettingArea(statusText: "",
                                    message: "File Transferring \(Int(percentage)) %")
    }

    func onSuccessfulFileTransferred(_ message: String!) {

        self.synapseFirmwareUpdatePercentage = 100
        self.setFirmwareSettingArea(statusText: "",
                                    message: message)
    }

    func onDFUEnded() {

        self.setFirmwareSettingArea(statusText: "Finish",
                                    message: "DFU Ended")
        self.resetFirmwareUpdate()
    }

    func onError(_ errorMessage: String!) {

        var message: String = "DFU Error"
        if let errorMessage = errorMessage {
            message = "\(message) : \(errorMessage)"
        }
        self.setFirmwareSettingArea(statusText: "Error",
                                    message: message)
        self.resetFirmwareUpdate()
    }

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
            var arguments: [Any]? = [
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
                arguments![0] = time
            }
            if let co2 = self.synapseValues.co2 {
                arguments![1] = co2
            }
            if let ax = self.synapseValues.ax {
                arguments![2] = ax
            }
            if let ay = self.synapseValues.ay {
                arguments![3] = ay
            }
            if let az = self.synapseValues.az {
                arguments![4] = az
            }
            if let light = self.synapseValues.light {
                arguments![5] = light
            }
            if let gx = self.synapseValues.gx {
                arguments![6] = gx
            }
            if let gy = self.synapseValues.gy {
                arguments![7] = gy
            }
            if let gz = self.synapseValues.gz {
                arguments![8] = gz
            }
            if let pressure = self.synapseValues.pressure {
                arguments![9] = pressure
            }
            if let temp = self.synapseValues.temp {
                arguments![10] = temp
            }
            if let humidity = self.synapseValues.humidity {
                arguments![11] = humidity
            }
            if let sound = self.synapseValues.sound {
                arguments![12] = sound
            }
            if let tvoc = self.synapseValues.tvoc {
                arguments![13] = tvoc
            }
            if let volt = self.synapseValues.power {
                arguments![14] = volt
            }
            if let pow = self.synapseValues.battery {
                arguments![15] = pow
            }
            if let timeSec = self.synapseValues.timeSec {
                arguments![16] = timeSec
            }
            if let timeMillis = self.synapseValues.timeMillis {
                arguments![17] = timeMillis
            }
            if let uuid = self.synapseValues.uuid {
                arguments![18] = uuid
            }
            //print("sendOSC: \(arguments!)")
            self.sendMessage(client: oscClient,
                             addressPattern: "/synapseWear",
                             arguments: arguments!)

            arguments = nil
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
            var arguments: [Any]? = [
                0, // time
                true, // kick
            ]
            if let time = self.synapseValues.time {
                arguments![0] = time
            }
            //print("sendKickOSC")
            self.sendMessage(client: oscClient,
                             addressPattern: "/synapseWearKick",
                             arguments: arguments!)

            arguments = nil
        }
    }

    func sendMessage(client: F53OSCClient, addressPattern: String, arguments: [Any]) {

        var message: F53OSCMessage? = F53OSCMessage(addressPattern: addressPattern, arguments: arguments)
        client.send(message)
        //print("Send OSC: '\(String(describing: message))' To: \(client.host):\(client.port)")

        message = nil
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
    var isDisconnected: Bool = false
    var connectedDate: Date?
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
        //self.isDisconnected = false
        self.connectedDate = nil
    }

    func makeSynapseFileRecord() -> String {

        var str: String = ""
        if let time = self.time {
            str = "\(str)\(time)"
        }
        str = "\(str),"
        if let co2 = self.co2 {
            str = "\(str)\(co2)"
        }
        str = "\(str),"
        if let ax = self.ax {
            str = "\(str)\(ax)"
        }
        str = "\(str),"
        if let ay = self.ay {
            str = "\(str)\(ay)"
        }
        str = "\(str),"
        if let az = self.az {
            str = "\(str)\(az)"
        }
        str = "\(str),"
        if let gx = self.gx {
            str = "\(str)\(gx)"
        }
        str = "\(str),"
        if let gy = self.gy {
            str = "\(str)\(gy)"
        }
        str = "\(str),"
        if let gz = self.gz {
            str = "\(str)\(gz)"
        }
        str = "\(str),"
        if let light = self.light {
            str = "\(str)\(light)"
        }
        str = "\(str),"
        if let temp = self.temp {
            str = "\(str)\(temp)"
        }
        str = "\(str),"
        if let humidity = self.humidity {
            str = "\(str)\(humidity)"
        }
        str = "\(str),"
        if let pressure = self.pressure {
            str = "\(str)\(pressure)"
        }
        str = "\(str),"
        if let tvoc = self.tvoc {
            str = "\(str)\(tvoc)"
        }
        str = "\(str),"
        if let power = self.power {
            str = "\(str)\(power)"
        }
        str = "\(str),"
        if let battery = self.battery {
            str = "\(str)\(battery)"
        }
        str = "\(str),"
        if let sound = self.sound {
            str = "\(str)\(sound)"
        }
        str = "\(str)\n"
        return str
    }
}

class MyCustomSwiftAnimator: NSObject, NSViewControllerPresentationAnimator {

    func animatePresentation(of viewController: NSViewController, from fromViewController: NSViewController) {

        let bottomVC: NSViewController = fromViewController
        let topVC: NSViewController = viewController
        topVC.view.wantsLayer = true
        topVC.view.layerContentsRedrawPolicy = .onSetNeedsDisplay
        topVC.view.alphaValue = 0
        bottomVC.view.addSubview(topVC.view)

        var frame: CGRect = NSRectToCGRect(bottomVC.view.frame)
        frame = frame.insetBy(dx: 40, dy: 40)
        topVC.view.frame = NSRectFromCGRect(frame)

        let color: CGColor = NSColor.gray.cgColor
        topVC.view.layer?.backgroundColor = color

        NSAnimationContext.runAnimationGroup({ (context) -> Void in
            context.duration = 0.5
            topVC.view.animator().alphaValue = 0.8
        }, completionHandler: nil)
    }

    func animateDismissal(of viewController: NSViewController, from fromViewController: NSViewController) {

        let topVC: NSViewController = viewController
        topVC.view.wantsLayer = true
        topVC.view.layerContentsRedrawPolicy = .onSetNeedsDisplay
        NSAnimationContext.runAnimationGroup({ (context) -> Void in
            context.duration = 0.5
            topVC.view.animator().alphaValue = 0
        }, completionHandler: {
            topVC.view.removeFromSuperview()
        })
    }
}
