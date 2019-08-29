//
//  SettingViewController.swift
//  synapsewear
//
//  Copyright © 2018年 art and program, Inc. For license and other information refer to https://github.com/artandprogram/synapseWear. All rights reserved.
//

import UIKit

class SettingViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {

    // const
    let settings: [String] = [
        "synapse_wear_id",
        "interval_time",
        "firmware_version",
        "sensors",
        "temperature_scale",
        "flash_led",
        "bottom",
        ]
    let synapseCrystalInfo: SynapseCrystalStruct = SynapseCrystalStruct()
    // variables
    var isFirst: Bool = true
    var sensors: [CrystalStruct] = []
    var synapseInterval: String = ""
    //var synapseInterval: TimeInterval = 0
    var firmwareURL: String = ""
    var firmwareInfo: [String: Any] = [:]
    var soundInfo: Bool = true
    var sensorFlags: [String: Bool] = [:]
    var temperatureScale: String = ""
    // views
    var settingTableView: UITableView!
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
 
        if let nav = self.navigationController as? SettingNavigationViewController {
            self.synapseInterval = nav.synapseInterval
            self.firmwareURL = nav.firmwareURL
            self.firmwareInfo = nav.firmwareInfo
            self.sensorFlags = nav.sensorFlags
            self.soundInfo = nav.soundInfo
        }
 
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }

    override func setView() {
        super.setView()

        self.view.backgroundColor = UIColor.grayBGColor

        self.settingTableView = UITableView()
        self.settingTableView.backgroundColor = UIColor.clear
        self.settingTableView.separatorStyle = .none
        self.settingTableView.delegate = self
        self.settingTableView.dataSource = self
        self.view.addSubview(self.settingTableView)
    }

    override func resizeView() {
        super.resizeView()

        let x:CGFloat = 0
        var y:CGFloat = 0
        let w:CGFloat = self.view.frame.width
        var h:CGFloat = self.view.frame.height
        if let nav = self.navigationController as? NavigationController {
            y = nav.headerView.frame.origin.y + nav.headerView.frame.size.height
            h -= y
        }
        self.settingTableView.frame = CGRect(x: x, y: y, width: w, height: h)
    }

    // MARK: mark - UITableViewDataSource methods

    func numberOfSections(in tableView: UITableView) -> Int {

        let sections: Int = self.settings.count
        return sections
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

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
            else if self.settings[section] == "bottom" {
                num = 0
            }
        }
        return num
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        var cell: UITableViewCell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        cell.backgroundColor = UIColor.clear
        cell.selectionStyle = .none

        if indexPath.section < self.settings.count {
            if self.settings[indexPath.section] == "synapse_wear_id" {
                if indexPath.row == 0 || indexPath.row == 4 {
                    cell = UITableViewCell(style: .default, reuseIdentifier: "line_cell")
                    cell.backgroundColor = UIColor.black.withAlphaComponent(0.1)
                    cell.selectionStyle = .none
                }
                else if indexPath.row == 1 {
                    let cell: SettingTableViewCell = SettingTableViewCell(style: .default, reuseIdentifier: "id_cell")
                    cell.backgroundColor = UIColor.white
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
                    let cell: SettingTableViewCell = SettingTableViewCell(style: .default, reuseIdentifier: "osc_cell")
                    cell.backgroundColor = UIColor.white
                    cell.iconImageView.isHidden = true
                    cell.titleLabel.text = "OSC Settings"
                    cell.textField.isEnabled = false
                    cell.swicth.isHidden = true

                    cell.textField.textColor = UIColor.lightGray
                    cell.textField.text = ""
                    if let nav = self.navigationController as? SettingNavigationViewController {
                        if let str = nav.settingFileManager.getSettingData(nav.settingFileManager.oscSendModeKey) as? String, str == "on" {
                            cell.textField.textColor = UIColor.fluorescentPink
                        }
                        if let str1 = nav.settingFileManager.getSettingData(nav.settingFileManager.oscSendIPAddressKey) as? String {
                            cell.textField.text = str1
                            if str1.count > 0, let str2 = nav.settingFileManager.getSettingData(nav.settingFileManager.oscSendPortKey) as? String {
                                cell.textField.text = "\(str1):\(str2)"
                            }
                        }
                    }
                    return cell
                }
                else if indexPath.row == 3 {
                    let cell: SettingTableViewCell = SettingTableViewCell(style: .default, reuseIdentifier: "send_data_cell")
                    cell.backgroundColor = UIColor.white
                    cell.iconImageView.isHidden = true
                    cell.titleLabel.text = "Upload Settings"
                    cell.textField.isEnabled = false
                    cell.swicth.isHidden = true
                    cell.lineView.isHidden = true

                    cell.textField.textColor = UIColor.lightGray
                    cell.textField.text = ""
                    if let nav = self.navigationController as? SettingNavigationViewController {
                        if let flag = nav.settingFileManager.getSettingData(nav.settingFileManager.synapseSendFlagKey) as? Bool, flag {
                            cell.textField.textColor = UIColor.fluorescentPink
                        }
                        if let str = nav.settingFileManager.getSettingData(nav.settingFileManager.synapseSendURLKey) as? String {
                            cell.textField.text = str
                        }
                    }
                    return cell
                }
            }
            else if self.settings[indexPath.section] == "interval_time" {
                if indexPath.row == 0 || indexPath.row == 3 {
                    cell = UITableViewCell(style: .default, reuseIdentifier: "line_cell")
                    cell.backgroundColor = UIColor.black.withAlphaComponent(0.1)
                    cell.selectionStyle = .none
                }
                else if indexPath.row == 1 {
                    let cell: SettingTableViewCell = SettingTableViewCell(style: .default, reuseIdentifier: "interval_cell")
                    cell.backgroundColor = UIColor.white
                    cell.iconImageView.isHidden = true
                    cell.titleLabel.text = "Interval Time"
                    cell.textField.textColor = UIColor.lightGray
                    cell.textField.isEnabled = false
                    cell.swicth.isHidden = true

                    cell.textField.text = self.synapseInterval
                    return cell
                }
                else if indexPath.row == 2 {
                    let cell: SettingTableViewCell = SettingTableViewCell(style: .default, reuseIdentifier: "sound_cell")
                    cell.backgroundColor = UIColor.white
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
                    cell = UITableViewCell(style: .default, reuseIdentifier: "line_cell")
                    cell.backgroundColor = UIColor.black.withAlphaComponent(0.1)
                    cell.selectionStyle = .none
                }
                else if indexPath.row == 1 {
                    let cell: SettingTableViewCell = SettingTableViewCell(style: .default, reuseIdentifier: "firmware_url_cell")
                    cell.backgroundColor = UIColor.white
                    cell.selectionStyle = .none
                    cell.iconImageView.isHidden = true
                    cell.titleLabel.isHidden = true
                    cell.textField.text = self.firmwareURL
                    cell.textField.placeholder = "Firmware URL"
                    //cell.textField.attributedPlaceholder = NSAttributedString(string: "Firmware URL", attributes: [NSForegroundColorAttributeName: UIColor.darkGray])
                    cell.textField.textColor = UIColor.darkGray
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
                    let cell: SettingTableViewCell = SettingTableViewCell(style: .default, reuseIdentifier: "firmware_version_cell")
                    cell.backgroundColor = UIColor.white
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
                    cell = UITableViewCell(style: .default, reuseIdentifier: "line_cell")
                    cell.backgroundColor = UIColor.black.withAlphaComponent(0.1)
                    cell.selectionStyle = .none
                }
                else if indexPath.row <= self.sensors.count {
                    let crystal: CrystalStruct = self.sensors[indexPath.row - 1]
                    let cell: SettingTableViewCell = SettingTableViewCell(style: .default, reuseIdentifier: "sensor_cell")
                    cell.selectionStyle = .none
                    cell.backgroundColor = UIColor.white
                    cell.iconImageView.image = nil
                    if crystal.key == self.synapseCrystalInfo.co2.key {
                        cell.iconImageView.image = UIImage(named: "co2_b.png")
                    }
                    else if crystal.key == self.synapseCrystalInfo.temp.key {
                        cell.iconImageView.image = UIImage(named: "temp_b.png")
                    }
                    else if crystal.key == self.synapseCrystalInfo.hum.key {
                        cell.iconImageView.image = UIImage(named: "hum_b.png")
                    }
                    else if crystal.key == self.synapseCrystalInfo.ill.key {
                        cell.iconImageView.image = UIImage(named: "ill_b.png")
                    }
                    else if crystal.key == self.synapseCrystalInfo.press.key {
                        cell.iconImageView.image = UIImage(named: "press_b.png")
                    }
                    else if crystal.key == self.synapseCrystalInfo.sound.key {
                        cell.iconImageView.image = UIImage(named: "sound_b.png")
                    }
                    else if crystal.key == self.synapseCrystalInfo.move.key {
                        cell.iconImageView.image = UIImage(named: "move_b.png")
                    }
                    else if crystal.key == self.synapseCrystalInfo.angle.key {
                        cell.iconImageView.image = UIImage(named: "angle_b.png")
                    }
                    /*else if crystal.key == self.synapseCrystalInfo.mag.key {
                        cell.iconImageView.image = UIImage(named: "mag_b.png")
                    }*/
                    cell.iconImageView.backgroundColor = UIColor.clear
                    /*if cell.iconImageView.image != nil {
                        cell.iconImageView.backgroundColor = UIColor.darkGray
                    }
                    //cell.iconImageView.backgroundColor = UIColor.grayBGColor*/
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
                    cell = UITableViewCell(style: .default, reuseIdentifier: "line_cell")
                    cell.backgroundColor = UIColor.black.withAlphaComponent(0.1)
                    cell.selectionStyle = .none
                }
                else if indexPath.row == 1 {
                    let cell: SettingTableViewCell = SettingTableViewCell(style: .default, reuseIdentifier: "temperature_scale_cell")
                    cell.backgroundColor = UIColor.white
                    cell.iconImageView.isHidden = true
                    cell.titleLabel.text = "Temperature Scale"
                    cell.textField.isEnabled = false
                    cell.swicth.isHidden = true
                    cell.arrowView.isHidden = true
                    cell.lineView.isHidden = true

                    cell.textField.textColor = UIColor.lightGray
                    cell.textField.text = "℃"
                    if self.temperatureScale == "F" {
                        //cell.textField.textColor = UIColor.fluorescentPink
                        cell.textField.text = "℉"
                    }
                    return cell
                }
            }
            else if self.settings[indexPath.section] == "flash_led" {
                if indexPath.row == 0 || indexPath.row == 2 {
                    cell = UITableViewCell(style: .default, reuseIdentifier: "line_cell")
                    cell.backgroundColor = UIColor.black.withAlphaComponent(0.1)
                    cell.selectionStyle = .none
                }
                else if indexPath.row == 1 {
                    let cell: SettingTableViewCell = SettingTableViewCell(style: .default, reuseIdentifier: "temperature_scale_cell")
                    cell.backgroundColor = UIColor.white
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
        }
        return cell
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
            else if self.settings[section] == "bottom" {
                height = 44.0
            }
        }
        return height
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        if self.tableView(tableView, heightForHeaderInSection: section) > 0 {
            let view: UIView = UIView()
            view.frame = CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: self.tableView(tableView, heightForHeaderInSection: section))
            view.backgroundColor = UIColor.clear
            return view
        }
        return nil
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        var height: CGFloat = 0
        if indexPath.section < self.settings.count {
            let cell: SettingTableViewCell = SettingTableViewCell()
            if self.settings[indexPath.section] == "synapse_wear_id" {
                if indexPath.row == 0 || indexPath.row == 4 {
                    height = 1.0
                }
                else if indexPath.row == 1 {
                    height = cell.cellH
                }
                else if indexPath.row == 2 {
                    height = cell.cellH
                }
                else if indexPath.row == 3 {
                    height = cell.cellH
                }
            }
            else if self.settings[indexPath.section] == "interval_time" {
                if indexPath.row == 0 || indexPath.row == 3 {
                    height = 1.0
                }
                else if indexPath.row == 1 || indexPath.row == 2 {
                    height = cell.cellH
                }
            }
            else if self.settings[indexPath.section] == "firmware_version" {
                if indexPath.row == 0 || indexPath.row == 3 {
                    height = 1.0
                }
                else if indexPath.row == 1 || indexPath.row == 2 {
                    height = cell.cellH
                }
            }
            else if self.settings[indexPath.section] == "sensors" {
                if indexPath.row == 0 || indexPath.row == self.sensors.count + 1 {
                    height = 1.0
                }
                else if indexPath.row <= self.sensors.count {
                    height = cell.cellH
                }
            }
            else if self.settings[indexPath.section] == "temperature_scale" {
                if indexPath.row == 0 || indexPath.row == 2 {
                    height = 1.0
                }
                else if indexPath.row == 1 {
                    height = cell.cellH
                }
            }
            else if self.settings[indexPath.section] == "flash_led" {
                if indexPath.row == 0 || indexPath.row == 2 {
                    height = 1.0
                }
                else if indexPath.row == 1 {
                    height = cell.cellH
                }
            }
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
                    var flag: Bool = true
                    if let nav = self.navigationController as? SettingNavigationViewController {
                        flag = nav.settingFileManager.checkPlayableSound(self.synapseInterval)
                    }
                    if flag {
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
                    if self.temperatureScale == "F" {
                        self.temperatureScale = "C"
                    }
                    else {
                        self.temperatureScale = "F"
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
        }
    }

    // MARK: mark - Change Swicth Action methods

    @objc func changeSensorSwicth(_ sender: UISwitch) {

        if sender.tag > 0 && sender.tag <= self.sensors.count {
            let crystal: CrystalStruct = self.sensors[sender.tag - 1]
            self.sensorFlags[crystal.key] = sender.isOn
        }
    }

    // MARK: mark - Device Associated methods

    func setAssociatedText(_ text: String) {

        self.textField?.text = text
    }

    // MARK: mark - UITextFieldDelegate methods

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        textField.resignFirstResponder()
        return true
    }

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
        /*guard let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? Double else {
         return
         }*/
    }

    @objc func textFieldDidChange(_ sender: UITextField) {

        if let text = sender.text {
            self.firmwareURL = text
        }
    }
}
