//
//  SettingViewController.swift
//  synapsewear
//
//  Copyright © 2018 art and program, Inc. For license and other information refer to https://github.com/artandprogram/synapseWear. All rights reserved.
//

import UIKit

class SettingViewController: SettingBaseViewController, UITextFieldDelegate {

    // const
    let settings: [String] = [
        "synapse_wear_id",
        "interval_time",
        "firmware_version",
        "sensors",
        "temperature_scale",
        "flash_led",
        "reboot_device",
        "bottom",
        ]
    let synapseCrystalInfo: SynapseCrystalStruct = SynapseCrystalStruct()
    // variables
    var isFirst: Bool = true
    var sensors: [CrystalStruct] = []
    var sensorIcons: [String: [String: UIImage?]] = [:]
    var synapseInterval: String = ""
    //var synapseInterval: TimeInterval = 0
    var firmwareURL: String = ""
    var firmwareInfo: [String: Any] = [:]
    var soundInfo: Bool = true
    var sensorFlags: [String: Bool] = [:]
    var temperatureScale: String = ""
    // views
    var textField: UITextField?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let nav = self.navigationController as? NavigationController {
            nav.headerTitle.text = "Settings"
        }
        if let nav = self.navigationController as? SettingNavigationViewController {
            if self.synapseInterval != nav.synapseInterval {
                self.synapseInterval = nav.synapseInterval
            }
            self.soundInfo = nav.soundInfo
            self.firmwareURL = nav.firmwareURL
            self.firmwareInfo = nav.firmwareInfo
            self.temperatureScale = nav.temperatureScale
        }

        if self.isFirst {
            if let nav = self.navigationController as? SettingNavigationViewController {
                nav.headerTitle.isHidden = true
                nav.headerCloseBtn.isHidden = true
            }
        }
        if !self.isFirst {
            self.settingTableView.reloadData()
        }
        self.isFirst = false

        self.setNotificationCenter()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let nav = self.navigationController as? SettingNavigationViewController {
            nav.headerTitle.isHidden = false
            nav.headerCloseBtn.isHidden = false
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.view.endEditing(true)
        if let nav = self.navigationController as? SettingNavigationViewController {
            /*if let textField = self.textField, let text = textField.text {
                nav.synapseIdNew = text
                //print("SettingViewController viewWillDisappear: \(text)")
            }*/
            nav.soundInfo = self.soundInfo
            nav.firmwareURL = self.firmwareURL
            nav.sensorFlags = self.sensorFlags
            nav.temperatureScale = self.temperatureScale
        }

        NotificationCenter.default.removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func setParam() {
        super.setParam()

        self.sensors = [
            self.synapseCrystalInfo.co2,
            self.synapseCrystalInfo.temp,
            self.synapseCrystalInfo.hum,
            self.synapseCrystalInfo.ill,
            self.synapseCrystalInfo.press,
            self.synapseCrystalInfo.sound,
            self.synapseCrystalInfo.move,
            self.synapseCrystalInfo.angle,
            self.synapseCrystalInfo.led,
            //self.synapseCrystalInfo.mag,
        ]
        self.sensorIcons = [
            self.synapseCrystalInfo.co2.key: [
                "light": UIImage.co2SB,
                "dark": UIImage.co2SW
            ],
            self.synapseCrystalInfo.temp.key: [
                "light": UIImage.temperatureSB,
                "dark": UIImage.temperatureSW
            ],
            self.synapseCrystalInfo.hum.key: [
                "light": UIImage.humiditySB,
                "dark": UIImage.humiditySW
            ],
            self.synapseCrystalInfo.ill.key: [
                "light": UIImage.illuminationSB,
                "dark": UIImage.illuminationSW
            ],
            self.synapseCrystalInfo.press.key: [
                "light": UIImage.airpressureSB,
                "dark": UIImage.airpressureSW
            ],
            self.synapseCrystalInfo.sound.key: [
                "light": UIImage.environmentalsoundSB,
                "dark": UIImage.environmentalsoundSW
            ],
            self.synapseCrystalInfo.move.key: [
                "light": UIImage.movementSB,
                "dark": UIImage.movementSW
            ],
            self.synapseCrystalInfo.angle.key: [
                "light": UIImage.angleSB,
                "dark": UIImage.angleSW
            ],
            //self.synapseCrystalInfo.mag.key: [],
            self.synapseCrystalInfo.led.key: [
                "light": UIImage.LEDSB,
                "dark": UIImage.LEDSW
            ],
        ]

        if let nav = self.navigationController as? SettingNavigationViewController {
            self.synapseInterval = nav.synapseInterval
            self.firmwareURL = nav.firmwareURL
            self.firmwareInfo = nav.firmwareInfo
            self.sensorFlags = nav.sensorFlags
            self.soundInfo = nav.soundInfo
        }
    }

    // MARK: mark - NotificationCenter methods

    func setNotificationCenter() {

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardWillShow(notification:)),
                                               name: .UIKeyboardWillShow,
                                               object: nil)
    }

    // MARK: mark - UITableViewDataSource methods

    func numberOfSections(in tableView: UITableView) -> Int {

        return self.settings.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        var num: Int = 0
        if section < self.settings.count {
            if self.settings[section] == "synapse_wear_id" {
                num = 5
            }
            else if self.settings[section] == "interval_time" {
                num = 4
            }
            else if self.settings[section] == "firmware_version" {
                num = 4
            }
            else if self.settings[section] == "sensors" {
                num = self.sensors.count + 2
            }
            else if self.settings[section] == "temperature_scale" {
                num = 3
            }
            else if self.settings[section] == "flash_led" {
                num = 3
            }
            else if self.settings[section] == "reboot_device" {
                num = 3
            }
            else if self.settings[section] == "bottom" {
                num = 0
            }
        }
        return num
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.section < self.settings.count {
            if self.settings[indexPath.section] == "synapse_wear_id" {
                if indexPath.row == 0 || indexPath.row == 4 {
                    return self.getLineCell(tableView: tableView)
                }
                else if indexPath.row == 1 {
                    let cell: SettingTableViewCell = self.getSettingTableViewCell(tableView: tableView, identifier: "id_cell")
                    cell.backgroundColor = UIColor.dynamicColor(light: UIColor.white, dark: UIColor.darkGrayBGColor)
                    cell.iconImageView.isHidden = true
                    cell.titleLabel.text = "synapseWear"
                    /*
                    cell.selectionStyle = .none
                    cell.titleLabel.text = "synapse Wear ID"
                    if let nav = self.navigationController as? SettingNavigationViewController {
                        cell.textField.text = nav.synapseIdNew
                    }
                     */
                    cell.textField.tag = 1
                    cell.textField.isEnabled = false
                    cell.textField.delegate = self
                    cell.swicth.isHidden = true

                    self.textField = cell.textField
                    if let nav = self.navigationController as? SettingNavigationViewController, let navBase = nav.nav {
                        self.setAssociatedText(navBase.checkDeviceAssociated())
                    }
                    return cell
                }
                else if indexPath.row == 2 {
                    let cell: SettingTableViewCell = self.getSettingTableViewCell(tableView: tableView, identifier: "osc_cell")
                    cell.backgroundColor = UIColor.dynamicColor(light: UIColor.white, dark: UIColor.darkGrayBGColor)
                    cell.iconImageView.isHidden = true
                    cell.titleLabel.text = "OSC Settings"
                    cell.textField.isEnabled = false
                    cell.swicth.isHidden = true

                    cell.textField.textColor = UIColor.lightGray
                    if SettingFileManager.shared.oscSendMode == "on" {
                        cell.textField.textColor = UIColor.fluorescentPink
                    }
                    var str: String = SettingFileManager.shared.oscSendIPAddress
                    if str.count > 0 {
                        str = "\(str):\(SettingFileManager.shared.oscSendPort)"
                    }
                    cell.textField.text = str
                    return cell
                }
                else if indexPath.row == 3 {
                    let cell: SettingTableViewCell = self.getSettingTableViewCell(tableView: tableView, identifier: "send_data_cell")
                    cell.backgroundColor = UIColor.dynamicColor(light: UIColor.white, dark: UIColor.darkGrayBGColor)
                    cell.iconImageView.isHidden = true
                    cell.titleLabel.text = "Upload Settings"
                    cell.textField.isEnabled = false
                    cell.swicth.isHidden = true
                    cell.lineView.isHidden = true

                    cell.textField.textColor = UIColor.lightGray
                    if SettingFileManager.shared.synapseSendFlag {
                        cell.textField.textColor = UIColor.fluorescentPink
                    }
                    cell.textField.text = SettingFileManager.shared.synapseSendURL
                    return cell
                }
            }
            else if self.settings[indexPath.section] == "interval_time" {
                if indexPath.row == 0 || indexPath.row == 3 {
                    return self.getLineCell(tableView: tableView)
                }
                else if indexPath.row == 1 {
                    let cell: SettingTableViewCell = self.getSettingTableViewCell(tableView: tableView, identifier: "interval_cell")
                    cell.backgroundColor = UIColor.dynamicColor(light: UIColor.white, dark: UIColor.darkGrayBGColor)
                    cell.iconImageView.isHidden = true
                    cell.titleLabel.text = "Interval Time"
                    cell.textField.textColor = UIColor.lightGray
                    cell.textField.isEnabled = false
                    cell.swicth.isHidden = true

                    cell.textField.text = self.synapseInterval
                    return cell
                }
                else if indexPath.row == 2 {
                    let cell: SettingTableViewCell = self.getSettingTableViewCell(tableView: tableView, identifier: "sound_cell")
                    cell.backgroundColor = UIColor.dynamicColor(light: UIColor.white, dark: UIColor.darkGrayBGColor)
                    cell.iconImageView.isHidden = true
                    cell.titleLabel.text = "Sound"
                    cell.textField.isEnabled = false
                    cell.swicth.isHidden = true
                    cell.arrowView.isHidden = true
                    cell.lineView.isHidden = true

                    cell.textField.textColor = UIColor.lightGray
                    cell.textField.text = "OFF"
                    if self.soundInfo {
                        cell.textField.textColor = UIColor.fluorescentPink
                        cell.textField.text = "ON"
                    }
                    return cell
                }
            }
            else if self.settings[indexPath.section] == "firmware_version" {
                if indexPath.row == 0 || indexPath.row == 3 {
                    return self.getLineCell(tableView: tableView)
                }
                else if indexPath.row == 1 {
                    let cell: SettingTableViewCell = self.getSettingTableViewCell(tableView: tableView, identifier: "firmware_url_cell")
                    cell.backgroundColor = UIColor.dynamicColor(light: UIColor.white, dark: UIColor.darkGrayBGColor)
                    cell.selectionStyle = .none
                    cell.iconImageView.isHidden = true
                    cell.titleLabel.isHidden = true
                    cell.textField.text = self.firmwareURL
                    cell.textField.placeholder = "Firmware URL"
                    //cell.textField.attributedPlaceholder = NSAttributedString(string: "Firmware URL", attributes: [NSForegroundColorAttributeName: UIColor.darkGray])
                    cell.textField.textColor = UIColor.dynamicColor(light: UIColor.darkGray, dark: UIColor.white)
                    cell.textField.textAlignment = .left
                    //cell.textField.tag = 1
                    cell.textField.isEnabled = true
                    cell.textField.delegate = self
                    cell.textField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
                    cell.arrowView.isHidden = true
                    cell.swicth.isHidden = true
                    return cell
                }
                else if indexPath.row == 2 {
                    let cell: SettingTableViewCell = self.getSettingTableViewCell(tableView: tableView, identifier: "firmware_version_cell")
                    cell.backgroundColor = UIColor.dynamicColor(light: UIColor.white, dark: UIColor.darkGrayBGColor)
                    cell.iconImageView.isHidden = true
                    cell.titleLabel.text = "Firmware Version"
                    cell.textField.textColor = UIColor.lightGray
                    cell.textField.isEnabled = false
                    cell.swicth.isHidden = true
                    cell.lineView.isHidden = true

                    cell.textField.text = ""
                    if let devVer = self.firmwareInfo["device_version"] {
                        cell.textField.text = String(describing: devVer)
                    }
                    return cell
                }
            }
            else if self.settings[indexPath.section] == "sensors" {
                if indexPath.row == 0 || indexPath.row == self.sensors.count + 1 {
                    return self.getLineCell(tableView: tableView)
                }
                else if indexPath.row <= self.sensors.count {
                    let crystal: CrystalStruct = self.sensors[indexPath.row - 1]
                    let cell: SettingTableViewCell = self.getSettingTableViewCell(tableView: tableView, identifier: "sensor_cell")
                    cell.selectionStyle = .none
                    cell.backgroundColor = UIColor.dynamicColor(light: UIColor.white, dark: UIColor.darkGrayBGColor)
                    self.setSensorIcon(cell, key: crystal.key)
                    cell.iconImageView.backgroundColor = UIColor.clear
                    cell.titleLabel.text = crystal.name
                    cell.textField.isHidden = true
                    cell.arrowView.isHidden = true
                    cell.swicth.tag = indexPath.row
                    cell.swicth.isOn = true
                    if let flag = self.sensorFlags[crystal.key] {
                        cell.swicth.isOn = flag
                    }
                    cell.swicth.addTarget(self, action: #selector(self.changeSensorSwicth(_:)), for: .valueChanged)
                    cell.lineView.isHidden = false
                    if indexPath.row == self.sensors.count {
                        cell.lineView.isHidden = true
                    }
                    return cell
                }
            }
            else if self.settings[indexPath.section] == "temperature_scale" {
                if indexPath.row == 0 || indexPath.row == 2 {
                    return self.getLineCell(tableView: tableView)
                }
                else if indexPath.row == 1 {
                    let cell: SettingTableViewCell = self.getSettingTableViewCell(tableView: tableView, identifier: "temperature_scale_cell")
                    cell.backgroundColor = UIColor.dynamicColor(light: UIColor.white, dark: UIColor.darkGrayBGColor)
                    cell.iconImageView.isHidden = true
                    cell.titleLabel.text = "Temperature Scale"
                    cell.textField.isEnabled = false
                    cell.swicth.isHidden = true
                    cell.arrowView.isHidden = true
                    cell.lineView.isHidden = true

                    cell.textField.textColor = UIColor.lightGray
                    cell.textField.text = self.getTemperatureUnit(self.temperatureScale)
                    return cell
                }
            }
            else if self.settings[indexPath.section] == "flash_led" {
                if indexPath.row == 0 || indexPath.row == 2 {
                    return self.getLineCell(tableView: tableView)
                }
                else if indexPath.row == 1 {
                    let cell: SettingTableViewCell = self.getSettingTableViewCell(tableView: tableView, identifier: "flash_led_cell")
                    cell.backgroundColor = UIColor.dynamicColor(light: UIColor.white, dark: UIColor.darkGrayBGColor)
                    cell.iconImageView.isHidden = true
                    cell.titleLabel.text = "Flash LED"
                    cell.textField.isEnabled = false
                    cell.textField.text = ""
                    cell.swicth.isHidden = true
                    cell.arrowView.isHidden = true
                    cell.lineView.isHidden = true
                    return cell
                }
            }
            else if self.settings[indexPath.section] == "reboot_device" {
                if indexPath.row == 0 || indexPath.row == 2 {
                    return self.getLineCell(tableView: tableView)
                }
                else if indexPath.row == 1 {
                    let cell: SettingTableViewCell = self.getSettingTableViewCell(tableView: tableView, identifier: "reboot_device_cell")
                    cell.backgroundColor = UIColor.dynamicColor(light: UIColor.white, dark: UIColor.darkGrayBGColor)
                    cell.iconImageView.isHidden = true
                    cell.titleLabel.text = "Reboot Device"
                    cell.textField.isEnabled = false
                    cell.textField.text = ""
                    cell.swicth.isHidden = true
                    cell.arrowView.isHidden = true
                    cell.lineView.isHidden = true
                    return cell
                }
            }
        }
        return super.tableView(tableView, cellForRowAt: indexPath)
    }

    func setSensorIcon(_ cell: SettingTableViewCell, key: String) {

        cell.iconImageView.image = nil
        if let data = self.sensorIcons[key] {
            if let image = data["light"] {
                cell.iconImageView.image = image
            }
            if #available(iOS 13, *) {
                if traitCollection.userInterfaceStyle == .dark {
                    if let image = data["dark"] {
                        cell.iconImageView.image = image
                    }
                }
            }
        }
    }

    // MARK: mark - UITableViewDelegate methods

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

        var height: CGFloat = 0
        if section < self.settings.count {
            if self.settings[section] == "synapse_wear_id" {
                height = 44.0
            }
            else if self.settings[section] == "interval_time" {
                height = 44.0
            }
            else if self.settings[section] == "firmware_version" {
                height = 44.0
            }
            else if self.settings[section] == "sensors" {
                height = 44.0
            }
            else if self.settings[section] == "temperature_scale" {
                height = 44.0
            }
            else if self.settings[section] == "flash_led" {
                height = 44.0
            }
            else if self.settings[section] == "reboot_device" {
                height = 44.0
            }
            else if self.settings[section] == "bottom" {
                height = 44.0
            }
        }
        return height
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        if self.tableView(tableView, heightForHeaderInSection: section) > 0 {
            let view: UIView = UIView()
            view.frame = CGRect(x: 0,
                                y: 0,
                                width: tableView.frame.size.width,
                                height: self.tableView(tableView, heightForHeaderInSection: section))
            view.backgroundColor = UIColor.clear
            view.isUserInteractionEnabled = false
            return view
        }
        return nil
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        var height: CGFloat = 0
        if indexPath.section < self.settings.count {
            var cell: SettingTableViewCell? = SettingTableViewCell()
            if self.settings[indexPath.section] == "synapse_wear_id" {
                if indexPath.row == 0 || indexPath.row == 4 {
                    height = self.getLineCellHeight()
                }
                else if indexPath.row == 1 {
                    height = cell!.cellH
                }
                else if indexPath.row == 2 {
                    height = cell!.cellH
                }
                else if indexPath.row == 3 {
                    height = cell!.cellH
                }
            }
            else if self.settings[indexPath.section] == "interval_time" {
                if indexPath.row == 0 || indexPath.row == 3 {
                    height = self.getLineCellHeight()
                }
                else if indexPath.row == 1 || indexPath.row == 2 {
                    height = cell!.cellH
                }
            }
            else if self.settings[indexPath.section] == "firmware_version" {
                if indexPath.row == 0 || indexPath.row == 3 {
                    height = self.getLineCellHeight()
                }
                else if indexPath.row == 1 || indexPath.row == 2 {
                    height = cell!.cellH
                }
            }
            else if self.settings[indexPath.section] == "sensors" {
                if indexPath.row == 0 || indexPath.row == self.sensors.count + 1 {
                    height = self.getLineCellHeight()
                }
                else if indexPath.row <= self.sensors.count {
                    height = cell!.cellH
                }
            }
            else if self.settings[indexPath.section] == "temperature_scale" {
                if indexPath.row == 0 || indexPath.row == 2 {
                    height = self.getLineCellHeight()
                }
                else if indexPath.row == 1 {
                    height = cell!.cellH
                }
            }
            else if self.settings[indexPath.section] == "flash_led" {
                if indexPath.row == 0 || indexPath.row == 2 {
                    height = self.getLineCellHeight()
                }
                else if indexPath.row == 1 {
                    height = cell!.cellH
                }
            }
            else if self.settings[indexPath.section] == "reboot_device" {
                if indexPath.row == 0 || indexPath.row == 2 {
                    height = self.getLineCellHeight()
                }
                else if indexPath.row == 1 {
                    height = cell!.cellH
                }
            }
            cell = nil
        }
        return height
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: false)

        if indexPath.section < self.settings.count {
            if self.settings[indexPath.section] == "synapse_wear_id" {
                if indexPath.row == 1 {
                    let vc: SynapseDevicesViewController = SynapseDevicesViewController()
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                else if indexPath.row == 2 {
                    let vc: SynapseOSCViewController = SynapseOSCViewController()
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                else if indexPath.row == 3 {
                    let vc: SynapseUploadSettingsViewController = SynapseUploadSettingsViewController()
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            else if self.settings[indexPath.section] == "interval_time" {
                if indexPath.row == 1 {
                    let vc: SynapseIntervalViewController = SynapseIntervalViewController()
                    vc.synapseInterval = self.synapseInterval
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                else if indexPath.row == 2 {
                    if SettingFileManager.shared.checkPlayableSound(self.synapseInterval) {
                        if let nav = self.navigationController as? SettingNavigationViewController {
                            let play: Bool = !self.soundInfo
                            if nav.changeAudioSettingStart(play: play) {
                                self.soundInfo = play
                                tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
                            }
                        }
                    }
                }
            }
            else if self.settings[indexPath.section] == "firmware_version" {
                if indexPath.row == 2 {
                    let vc: SynapseFirmwareViewController = SynapseFirmwareViewController()
                    vc.firmwareURL = self.firmwareURL
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            else if self.settings[indexPath.section] == "temperature_scale" {
                if indexPath.row == 1 {
                    if self.temperatureScale == TemperatureScaleKey.fahrenheit.rawValue {
                        self.temperatureScale = TemperatureScaleKey.celsius.rawValue
                    }
                    else {
                        self.temperatureScale = TemperatureScaleKey.fahrenheit.rawValue
                    }
                    tableView.reloadData()
                    //tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
                }
            }
            else if self.settings[indexPath.section] == "flash_led" {
                if let nav = self.navigationController as? SettingNavigationViewController {
                    nav.sendLEDFlashToDevice()
                }
            }
            else if self.settings[indexPath.section] == "reboot_device" {
                if let nav = self.navigationController as? SettingNavigationViewController {
                    nav.sendRebootToDevice()
                }
            }
        }
    }

    // MARK: mark - Change Swicth Action methods

    @objc func changeSensorSwicth(_ sender: UISwitch) {

        if sender.tag > 0, sender.tag <= self.sensors.count {
            let crystal: CrystalStruct = self.sensors[sender.tag - 1]
            self.sensorFlags[crystal.key] = sender.isOn
        }
    }

    // MARK: mark - Device Associated methods

    func setAssociatedText(_ text: String) {

        self.textField?.text = text
    }

    // MARK: mark - UITextField methods

    @objc func textFieldDidChange(_ sender: UITextField) {

        if let text = sender.text {
            self.firmwareURL = text
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        textField.resignFirstResponder()
        return true
    }

    // MARK: mark - Keyboard Action methods

    @objc func keyboardWillShow(notification: NSNotification) {

        if let userInfo = notification.userInfo as? [String: Any], let keyboardInfo = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            if let index = self.settings.index(of: "firmware_version") {
                let indexPath: IndexPath = IndexPath(row: 1, section: index)
                let cellRect: CGRect = self.settingTableView.rectForRow(at: indexPath)
                let pt: CGFloat = cellRect.origin.y + cellRect.size.height - self.settingTableView.contentOffset.y + self.settingTableView.frame.origin.y
                //print("keyboardWillShow: \(keyboardInfo.cgRectValue.origin.y)")
                //print("keyboardWillShow: \(cellRect.origin.y) \(cellRect.size.height) \(self.settingTableView.contentOffset.y)")
                if pt > keyboardInfo.cgRectValue.origin.y {
                    let offset: CGPoint = CGPoint(x: 0, y: self.settingTableView.contentOffset.y + (pt - keyboardInfo.cgRectValue.origin.y))
                    self.settingTableView.setContentOffset(offset, animated: true)
                }
            }
        }
    }

    // MARK: mark - UITraitEnvironment methods

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if #available(iOS 13, *) {
            if let section = settings.index(of: "sensors") {
                self.settingTableView.reloadSections(IndexSet(integer: section), with: .none)
            }
        }
    }
}
