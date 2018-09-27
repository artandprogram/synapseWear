//
//  SettingViewController.swift
//  synapsewear
//
//  Copyright © 2018年 art and program, Inc. For license and other information refer to https://github.com/artandprogram/synapseWear. All rights reserved.
//

import UIKit

class SettingNavigationViewController: NavigationController, DeviceAssociatedDelegate {

    // const
    let synapseCrystalInfo: SynapseCrystalStruct = SynapseCrystalStruct()
    let settingFileManager: SettingFileManager = SettingFileManager()
    // variables
    var nav: NavigationController?
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

        //print("SettingNavigationViewController viewWillDisappear")
        self.saveSynapseSetting()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func setParam() {
        /*
        if let str = self.settingFileManager.getSettingData(self.settingFileManager.synapseIDKey) as? String {
            self.synapseId = str
            self.synapseIdNew = str
        }
         */
        if let timeInterval = self.settingFileManager.getSettingData(self.settingFileManager.synapseTimeIntervalKey) as? String {
            self.synapseInterval = timeInterval
        }
        else {
            self.synapseInterval = self.settingFileManager.synapseTimeIntervals[0]
        }
        if let firmwareURL = self.settingFileManager.getSettingData(self.settingFileManager.synapseFirmwareURLKey) as? String {
            self.firmwareURL = firmwareURL
        }
        if let dic = self.settingFileManager.getSettingData(self.settingFileManager.synapseFirmwareInfoKey) as? [String: Any] {
            self.firmwareInfo = dic
        }
        if let flag = self.settingFileManager.getSettingData(self.settingFileManager.synapseSoundInfoKey) as? Bool {
            self.soundInfo = flag
        }
        if let dic = self.settingFileManager.getSettingData(self.settingFileManager.synapseValidSensorsKey) as? [String: Bool] {
            self.sensorFlags = dic
        }
        if let temperatureScale = self.settingFileManager.getSettingData(self.settingFileManager.synapseTemperatureScaleKey) as? String {
            self.temperatureScale = temperatureScale
        }

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

        self.headerCloseBtn = UIButton()
        self.headerCloseBtn.frame = CGRect(x: self.headerView.frame.size.width - 44.0, y: 20.0, width: 44.0, height: self.headerView.frame.size.height - 20.0)
        self.headerCloseBtn.backgroundColor = UIColor.clear
        self.headerCloseBtn.addTarget(self, action: #selector(SettingNavigationViewController.closeAction), for: .touchUpInside)
        self.headerView.addSubview(self.headerCloseBtn)

        self.headerCloseIcon = CrossView()
        self.headerCloseIcon.frame = CGRect(x: (self.headerCloseBtn.frame.size.width - 18.0) / 2, y: (self.headerCloseBtn.frame.size.height - 18.0) / 2, width: 18.0, height: 18.0)
        self.headerCloseIcon.backgroundColor = .clear
        self.headerCloseIcon.isUserInteractionEnabled = false
        self.headerCloseIcon.lineColor = UIColor.black
        self.headerCloseBtn.addSubview(self.headerCloseIcon)
    }

    override func resizeView() {
        super.resizeView()

        var y: CGFloat = 20.0
        if #available(iOS 11.0, *) {
            y = self.view.safeAreaInsets.top
        }
        self.headerCloseBtn.frame = CGRect(x: self.headerCloseBtn.frame.origin.x, y: y, width: self.headerCloseBtn.frame.size.width, height: self.headerCloseBtn.frame.size.height)

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
    /*
    override func getDeviceList() -> [Any] {

        var rfduinos: [Any] = []
        if let nav = self.nav {
            rfduinos = nav.getDeviceList()
        }
        return rfduinos
    }*/

    override func getDeviceUUID() -> UUID? {

        var uuid: UUID? = nil
        if let nav = self.nav {
            uuid = nav.getDeviceUUID()
        }
        return uuid
    }

    override func startDeviceScan() {

        if let nav = self.nav {
            nav.startDeviceScan()
        }
    }

    override func stopDeviceScan() {

        if let nav = self.nav {
            nav.stopDeviceScan()
        }

    }

    override func reconnectSynapse(uuid: UUID) {

        if let nav = self.nav {
            nav.reconnectSynapse(uuid: uuid)
        }
    }

    override func sendTimeIntervalToDevice() {

        var settingData: [String: Any] = [:]
        if let data = self.settingFileManager.getSettingData() {
            settingData = data
        }
        var updatedTimeInterval: Bool = true
        if let timeInterval = self.settingFileManager.getSettingData(self.settingFileManager.synapseTimeIntervalKey) as? String {
            if self.synapseInterval == timeInterval {
                updatedTimeInterval = false
            }
        }
        if updatedTimeInterval {
            settingData[self.settingFileManager.synapseTimeIntervalKey] = self.synapseInterval
            if self.settingFileManager.setSettingData(settingData) {
                self.nav?.sendTimeIntervalToDevice()

                var play: Bool = self.soundInfo
                if play {
                    play = self.settingFileManager.checkPlayableSound(self.synapseInterval)
                }
                if play != self.soundInfo {
                    settingData[self.settingFileManager.synapseSoundInfoKey] = play
                    if self.settingFileManager.setSettingData(settingData) {
                        self.soundInfo = play
                        self.changeAudioSetting(play: play)
                    }
                }
            }
        }
    }

    override func changeAudioSetting(play: Bool) {

        self.nav?.changeAudioSetting(play: play)
    }

    override func changeSynapseSendData() {

        self.nav?.changeSynapseSendData()
    }

    // MARK: mark - SettingNavigationViewController methods

    @objc func closeAction() {

        self.dismiss(animated: true, completion: nil)
    }

    func saveSynapseSetting() {

        //print("saveSynapseSetting")
        var settingData: [String: Any] = [:]
        if let data = self.settingFileManager.getSettingData() {
            settingData = data
        }

        var updatedSensorFlags: Bool = true
        if let dic = self.settingFileManager.getSettingData(self.settingFileManager.synapseValidSensorsKey) as? [String: Bool] {
            updatedSensorFlags = false
            if let flag = self.sensorFlags[self.synapseCrystalInfo.co2.key] {
                if let flagBak = dic[self.synapseCrystalInfo.co2.key] {
                    if flag != flagBak {
                        updatedSensorFlags = true
                    }
                }
                else {
                    updatedSensorFlags = true
                }
            }
            if let flag = self.sensorFlags[self.synapseCrystalInfo.temp.key] {
                if let flagBak = dic[self.synapseCrystalInfo.temp.key] {
                    if flag != flagBak {
                        updatedSensorFlags = true
                    }
                }
                else {
                    updatedSensorFlags = true
                }
            }
            if let flag = self.sensorFlags[self.synapseCrystalInfo.hum.key] {
                if let flagBak = dic[self.synapseCrystalInfo.hum.key] {
                    if flag != flagBak {
                        updatedSensorFlags = true
                    }
                }
                else {
                    updatedSensorFlags = true
                }
            }
            if let flag = self.sensorFlags[self.synapseCrystalInfo.ill.key] {
                if let flagBak = dic[self.synapseCrystalInfo.ill.key] {
                    if flag != flagBak {
                        updatedSensorFlags = true
                    }
                }
                else {
                    updatedSensorFlags = true
                }
            }
            if let flag = self.sensorFlags[self.synapseCrystalInfo.press.key] {
                if let flagBak = dic[self.synapseCrystalInfo.press.key] {
                    if flag != flagBak {
                        updatedSensorFlags = true
                    }
                }
                else {
                    updatedSensorFlags = true
                }
            }
            if let flag = self.sensorFlags[self.synapseCrystalInfo.sound.key] {
                if let flagBak = dic[self.synapseCrystalInfo.sound.key] {
                    if flag != flagBak {
                        updatedSensorFlags = true
                    }
                }
                else {
                    updatedSensorFlags = true
                }
            }
            if let flag = self.sensorFlags[self.synapseCrystalInfo.move.key] {
                if let flagBak = dic[self.synapseCrystalInfo.move.key] {
                    if flag != flagBak {
                        updatedSensorFlags = true
                    }
                }
                else {
                    updatedSensorFlags = true
                }
            }
            if let flag = self.sensorFlags[self.synapseCrystalInfo.angle.key] {
                if let flagBak = dic[self.synapseCrystalInfo.angle.key] {
                    if flag != flagBak {
                        updatedSensorFlags = true
                    }
                }
                else {
                    updatedSensorFlags = true
                }
            }
            if let flag = self.sensorFlags[self.synapseCrystalInfo.led.key] {
                if let flagBak = dic[self.synapseCrystalInfo.led.key] {
                    if flag != flagBak {
                        updatedSensorFlags = true
                    }
                }
                else {
                    updatedSensorFlags = true
                }
            }
        }
        settingData[self.settingFileManager.synapseValidSensorsKey] = self.sensorFlags

        var updatedTemperatureScale: Bool = false
        if let temperatureScale = self.settingFileManager.getSettingData(self.settingFileManager.synapseTemperatureScaleKey) as? String {
            if self.temperatureScale != temperatureScale {
                updatedTemperatureScale = true
            }
        }
        settingData[self.settingFileManager.synapseTemperatureScaleKey] = self.temperatureScale

        settingData[self.settingFileManager.synapseFirmwareURLKey] = self.firmwareURL

        if self.settingFileManager.setSettingData(settingData) {
            if updatedSensorFlags {
                self.nav?.sendSensorToDevice()
            }
            self.appDelegate.temperatureScale = self.temperatureScale
            if updatedTemperatureScale {
                self.nav?.topVC.updateSynapseValuesViewFromSetting()
            }
        }
    }

    func changeAudioSettingStart(play: Bool) -> Bool {

        var settingData: [String: Any] = [:]
        if let data = self.settingFileManager.getSettingData() {
            settingData = data
        }
        settingData[self.settingFileManager.synapseSoundInfoKey] = play
        if self.settingFileManager.setSettingData(settingData) {
            self.soundInfo = play
            self.changeAudioSetting(play: play)
            return true
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
