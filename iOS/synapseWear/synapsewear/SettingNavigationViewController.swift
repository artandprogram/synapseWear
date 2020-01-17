//
//  SettingViewController.swift
//  synapsewear
//
//  Copyright © 2018 art and program, Inc. For license and other information refer to https://github.com/artandprogram/synapseWear. All rights reserved.
//

import UIKit

class SettingNavigationViewController: NavigationController, DeviceAssociatedDelegate {

    // const
    let synapseCrystalInfo: SynapseCrystalStruct = SynapseCrystalStruct()
    // variables
    weak var nav: NavigationController?
    //var synapseId: String = ""
    //var synapseIdNew: String = ""
    var synapseInterval: String = ""
    //var synapseInterval: TimeInterval = 0.1
    var firmwareURL: String = ""
    var firmwareInfo: [String: Any] = [:]
    var soundInfo: Bool = true
    var sensorFlags: [String: Bool] = [:]
    var temperatureScale: String = ""
    // views
    var headerCloseBtn: UIButton!
    var headerCloseIcon: CrossView!
    //var headerCloseIcon: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.saveSynapseSetting()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func setParam() {

        /*if let str = self.settingFileManager.getSettingData(self.settingFileManager.synapseIDKey) as? String {
            self.synapseId = str
            self.synapseIdNew = str
        }*/
        self.synapseInterval = SettingFileManager.shared.synapseTimeInterval
        self.firmwareURL = SettingFileManager.shared.synapseFirmwareURL
        self.firmwareInfo = SettingFileManager.shared.synapseFirmwareInfo
        self.soundInfo = SettingFileManager.shared.synapseSoundInfo
        self.sensorFlags = SettingFileManager.shared.synapseValidSensors
        self.temperatureScale = SettingFileManager.shared.synapseTemperatureScale

        self.nav?.daDelegate = self
    }

    override func setView() {
        super.setView()

        self.headerMenuBtn.alpha = 0
        self.headerMenuBtn.isEnabled = false
        //self.headerMenuBtn.isHidden = true
        self.headerBackForTopBtn.alpha = 0
        self.headerBackForTopBtn.isEnabled = false
        //self.headerBackForTopBtn.isHidden = true
        self.headerSettingBtn.alpha = 0
        self.headerSettingBtn.isEnabled = false
        //self.headerSettingBtn.isHidden = true

        self.headerTitle.textColor = UIColor.dynamicColor(light: UIColor.black, dark: UIColor.white)
        self.headerBackIcon.lineColor = UIColor.dynamicColor(light: UIColor.black, dark: UIColor.white)

        self.headerCloseBtn = UIButton()
        self.headerCloseBtn.frame = CGRect(x: self.headerView.frame.size.width - 44.0,
                                           y: 20.0,
                                           width: 44.0,
                                           height: self.headerView.frame.size.height - 20.0)
        self.headerCloseBtn.backgroundColor = UIColor.clear
        self.headerCloseBtn.addTarget(self, action: #selector(SettingNavigationViewController.closeAction), for: .touchUpInside)
        self.headerView.addSubview(self.headerCloseBtn)

        self.headerCloseIcon = CrossView()
        self.headerCloseIcon.frame = CGRect(x: (self.headerCloseBtn.frame.size.width - 18.0) / 2,
                                            y: (self.headerCloseBtn.frame.size.height - 18.0) / 2,
                                            width: 18.0,
                                            height: 18.0)
        self.headerCloseIcon.backgroundColor = .clear
        self.headerCloseIcon.isUserInteractionEnabled = false
        self.headerCloseIcon.lineColor = UIColor.dynamicColor(light: UIColor.black, dark: UIColor.white)
        self.headerCloseBtn.addSubview(self.headerCloseIcon)
    }

    override func resizeView() {
        super.resizeView()

        var y: CGFloat = 20.0
        if #available(iOS 11.0, *) {
            y = self.view.safeAreaInsets.top
        }
        self.headerCloseBtn.frame = CGRect(x: self.headerCloseBtn.frame.origin.x,
                                           y: y,
                                           width: self.headerCloseBtn.frame.size.width,
                                           height: self.headerCloseBtn.frame.size.height)

        if self.viewControllers.count > 0, let vc = self.viewControllers[0] as? BaseViewController {
            vc.resizeView()
        }
    }

    override func setMainViewController() {

        let vc: SettingViewController = SettingViewController()
        self.viewControllers = [vc]
    }

    override func checkHeaderButtons() {

        self.headerCloseBtn.isHidden = false
        self.headerBackBtn.isHidden = true
        if self.viewControllers.count > 1 {
            self.headerCloseBtn.isHidden = true
            self.headerBackBtn.isHidden = false
        }
    }

    override func getDeviceUUID() -> UUID? {

        return self.nav?.getDeviceUUID()
    }

    override func startDeviceScan() {

        self.nav?.startDeviceScan()
    }

    override func stopDeviceScan() {

        self.nav?.stopDeviceScan()
    }

    override func reconnectSynapse(uuid: UUID) {

        self.nav?.reconnectSynapse(uuid: uuid)
    }

    override func sendTimeIntervalToDevice() {

        if self.synapseInterval != SettingFileManager.shared.synapseTimeInterval {
            SettingFileManager.shared.synapseTimeInterval = self.synapseInterval
            if SettingFileManager.shared.saveData() {
                self.nav?.sendTimeIntervalToDevice()

                var play: Bool = self.soundInfo
                if play {
                    play = SettingFileManager.shared.checkPlayableSound(self.synapseInterval)
                }
                if play != self.soundInfo {
                    SettingFileManager.shared.synapseSoundInfo = play
                    if SettingFileManager.shared.saveData() {
                        self.soundInfo = play
                        self.changeAudioSetting(play: play)
                    }
                    else {
                        SettingFileManager.shared.loadData()
                    }
                }
            }
            else {
                SettingFileManager.shared.loadData()
            }
        }
    }

    override func changeAudioSetting(play: Bool) {

        self.nav?.changeAudioSetting(play: play)
    }

    override func changeSynapseSendData() {

        self.nav?.changeSynapseSendData()
    }

    override func sendLEDFlashToDevice() {

        self.nav?.sendLEDFlashToDevice()
    }

    override func setOSCClient() {

        self.nav?.setOSCClient()
    }

    override func getScanDevices() -> [RFduino] {

        return self.nav?.getScanDevices() ?? []
    }

    override func setScanDevicesDelegate(_ delegate: DeviceScanningDelegate?) {

        self.nav?.setScanDevicesDelegate(delegate)
    }

    // MARK: mark - SettingNavigationViewController methods

    @objc func closeAction() {

        self.nav?.isSetting = false
        self.dismiss(animated: true, completion: nil)
    }

    func saveSynapseSetting() {

        //print("saveSynapseSetting")
        var updatedSensorFlags: Bool = false
        if let flag = self.sensorFlags[self.synapseCrystalInfo.co2.key] {
            if let flagBak = SettingFileManager.shared.synapseValidSensors[self.synapseCrystalInfo.co2.key] {
                if flag != flagBak {
                    updatedSensorFlags = true
                }
            }
            else {
                updatedSensorFlags = true
            }
        }
        if let flag = self.sensorFlags[self.synapseCrystalInfo.temp.key] {
            if let flagBak = SettingFileManager.shared.synapseValidSensors[self.synapseCrystalInfo.temp.key] {
                if flag != flagBak {
                    updatedSensorFlags = true
                }
            }
            else {
                updatedSensorFlags = true
            }
        }
        if let flag = self.sensorFlags[self.synapseCrystalInfo.hum.key] {
            if let flagBak = SettingFileManager.shared.synapseValidSensors[self.synapseCrystalInfo.hum.key] {
                if flag != flagBak {
                    updatedSensorFlags = true
                }
            }
            else {
                updatedSensorFlags = true
            }
        }
        if let flag = self.sensorFlags[self.synapseCrystalInfo.ill.key] {
            if let flagBak = SettingFileManager.shared.synapseValidSensors[self.synapseCrystalInfo.ill.key] {
                if flag != flagBak {
                    updatedSensorFlags = true
                }
            }
            else {
                updatedSensorFlags = true
            }
        }
        if let flag = self.sensorFlags[self.synapseCrystalInfo.press.key] {
            if let flagBak = SettingFileManager.shared.synapseValidSensors[self.synapseCrystalInfo.press.key] {
                if flag != flagBak {
                    updatedSensorFlags = true
                }
            }
            else {
                updatedSensorFlags = true
            }
        }
        if let flag = self.sensorFlags[self.synapseCrystalInfo.sound.key] {
            if let flagBak = SettingFileManager.shared.synapseValidSensors[self.synapseCrystalInfo.sound.key] {
                if flag != flagBak {
                    updatedSensorFlags = true
                }
            }
            else {
                updatedSensorFlags = true
            }
        }
        if let flag = self.sensorFlags[self.synapseCrystalInfo.move.key] {
            if let flagBak = SettingFileManager.shared.synapseValidSensors[self.synapseCrystalInfo.move.key] {
                if flag != flagBak {
                    updatedSensorFlags = true
                }
            }
            else {
                updatedSensorFlags = true
            }
        }
        if let flag = self.sensorFlags[self.synapseCrystalInfo.angle.key] {
            if let flagBak = SettingFileManager.shared.synapseValidSensors[self.synapseCrystalInfo.angle.key] {
                if flag != flagBak {
                    updatedSensorFlags = true
                }
            }
            else {
                updatedSensorFlags = true
            }
        }
        if let flag = self.sensorFlags[self.synapseCrystalInfo.led.key] {
            if let flagBak = SettingFileManager.shared.synapseValidSensors[self.synapseCrystalInfo.led.key] {
                if flag != flagBak {
                    updatedSensorFlags = true
                }
            }
            else {
                updatedSensorFlags = true
            }
        }

        var updatedTemperatureScale: Bool = false
        if self.temperatureScale != SettingFileManager.shared.synapseTemperatureScale {
            updatedTemperatureScale = true
        }

        SettingFileManager.shared.synapseValidSensors = self.sensorFlags
        SettingFileManager.shared.synapseTemperatureScale = self.temperatureScale
        SettingFileManager.shared.synapseFirmwareURL = self.firmwareURL
        if SettingFileManager.shared.saveData() {
            if updatedSensorFlags {
                self.nav?.sendSensorToDevice()
            }
            if updatedTemperatureScale {
                self.nav?.topVC.updateSynapseValuesViewFromSetting()
            }
        }
        else {
            SettingFileManager.shared.loadData()
        }
    }

    func changeAudioSettingStart(play: Bool) -> Bool {

        SettingFileManager.shared.synapseSoundInfo = play
        if SettingFileManager.shared.saveData() {
            self.soundInfo = play
            self.changeAudioSetting(play: play)
            return true
        }
        else {
            SettingFileManager.shared.loadData()
        }
        return false
    }

    func updateFirmware(_ url: URL, firmwareInfo: [String: Any]) {

        //print("updateFirmware: \(firmwareInfo)")
        self.dismiss(animated: true, completion: {
            //print("updateFirmware: \(firmwareInfo)")
            if let nav = self.nav {
                nav.topVC.sendDataToDevice(nav.topVC.mainSynapseObject, url: url, firmwareInfo: firmwareInfo)
            }
            })
    }

    // MARK: mark - DeviceAssociatedDelegate methods

    func changeDeviceAssociated(_ text: String) {

        if self.viewControllers.count > 0, let vc = self.viewControllers[0] as? SettingViewController {
            vc.setAssociatedText(text)
        }
    }
}
