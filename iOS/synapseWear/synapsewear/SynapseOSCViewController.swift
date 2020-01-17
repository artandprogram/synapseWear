//
//  SynapseOSCViewController.swift
//  synapsewear
//
//  Copyright © 2017 art and program, Inc. For license and other information refer to https://github.com/artandprogram/synapseWear. All rights reserved.
//

import UIKit

class SynapseOSCViewController: SettingBaseViewController, UITextFieldDelegate {

    // variables
    var oscSendMode: String = "off"
    var oscRecvMode: String = "off"
    var oscSendIP: String = ""
    var oscRecvIP: String = ""
    var oscSendPort: String = ""
    var oscRecvPort: String = ""
    var oscRecvSettingFlag: Bool = false
    // views
    var closeKeyboardButton: UIButton!
    var textFieldRect: CGRect?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let nav = self.navigationController as? NavigationController {
            nav.headerTitle.text = "OSC Settings"
        }

        self.setNotificationCenter()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.saveSettingData()
        self.closeKeyboardAction()

        NotificationCenter.default.removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func setParam() {
        super.setParam()

        self.oscSendMode = SettingFileManager.shared.oscSendMode
        self.oscRecvMode = SettingFileManager.shared.oscRecvMode
        self.oscSendIP = SettingFileManager.shared.oscSendIPAddress
        self.oscSendPort = SettingFileManager.shared.oscSendPort
        self.oscRecvPort = SettingFileManager.shared.oscRecvPort
        if let str = self.getWiFiAddress() {
            self.oscRecvIP = str
        }
        if let flag = self.getAppinfoValue("use_osc_recv") as? Bool {
            self.oscRecvSettingFlag = flag
        }
    }

    override func setView() {
        super.setView()

        self.closeKeyboardButton = UIButton()
        self.closeKeyboardButton.backgroundColor = UIColor.black
        self.closeKeyboardButton.alpha = 0.5
        self.closeKeyboardButton.isHidden = true
        self.closeKeyboardButton.addTarget(self, action: #selector(self.closeKeyboardAction), for: .touchUpInside)
        self.view.addSubview(self.closeKeyboardButton)
    }

    override func resizeView() {
        super.resizeView()

        let x: CGFloat = 0
        let y: CGFloat = 0
        let w: CGFloat = self.view.frame.size.width
        let h: CGFloat = self.view.frame.size.height
        self.closeKeyboardButton.frame = CGRect(x: x, y: y, width: w, height: h)
    }

    // MARK: mark - NotificationCenter methods

    func setNotificationCenter() {

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardWillShow(_:)),
                                               name: .UIKeyboardWillShow,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.KeyboardWillHide(_:)),
                                               name: .UIKeyboardWillHide,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(type(of: self).textFieldDidChange(notification:)),
                                               name: .UITextFieldTextDidChange,
                                               object: nil)
    }

    // MARK: mark - SettingData methods

    func setOSCMode(_ sw: UISwitch) {

        if sw.tag == 1 {
            self.oscSendMode = "off"
            if sw.isOn {
                self.oscSendMode = "on"
            }
        }
        else if sw.tag == 2 {
            self.oscRecvMode = "off"
            if sw.isOn {
                self.oscRecvMode = "on"
            }
        }
    }

    func setOSCValue(_ textField: UITextField) {

        if let text = textField.text {
            if textField.tag == 1 {
                self.oscSendIP = text
            }
            else if textField.tag == 2 {
                self.oscSendPort = text
            }
            else if textField.tag == 4 {
                self.oscRecvPort = text
            }
        }
    }

    func saveSettingData() {

        SettingFileManager.shared.oscSendMode = self.oscSendMode
        SettingFileManager.shared.oscRecvMode = self.oscRecvMode
        SettingFileManager.shared.oscSendIPAddress = self.oscSendIP
        SettingFileManager.shared.oscSendPort = self.oscSendPort
        SettingFileManager.shared.oscRecvPort = self.oscRecvPort
        if SettingFileManager.shared.saveData() {
            if let nav = self.navigationController as? SettingNavigationViewController {
                nav.setOSCClient()
            }
        }
        else {
            SettingFileManager.shared.loadData()
        }
    }

    // MARK: mark - UITableViewDataSource methods

    func numberOfSections(in tableView: UITableView) -> Int {

        var sections: Int = 1
        if self.oscRecvSettingFlag {
            sections = 2
        }
        return sections
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        var num: Int = 0
        if section == 0 {
            num = 5
        }
        else if section == 1 {
            num = 5
        }
        return num
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.section == 0 {
            if indexPath.row == 0 || indexPath.row == 4 {
                return self.getLineCell()
            }
            else if indexPath.row == 1 {
                let cell: SettingTableViewCell = SettingTableViewCell(style: .default, reuseIdentifier: "send_mode_cell")
                cell.backgroundColor = UIColor.dynamicColor(light: UIColor.white, dark: UIColor.darkGrayBGColor)
                cell.selectionStyle = .none
                cell.iconImageView.isHidden = true
                cell.titleLabel.text = "Send"
                cell.textField.isHidden = true
                cell.arrowView.isHidden = true

                cell.swicth.isOn = false
                if self.oscSendMode == "on" {
                    cell.swicth.isOn = true
                }
                cell.swicth.tag = 1
                cell.swicth.addTarget(self, action: #selector(self.switchValueChangedAction(_:)), for: .valueChanged)
                return cell
            }
            else if indexPath.row == 2 {
                let cell: SettingTableViewCell = SettingTableViewCell(style: .default, reuseIdentifier: "send_ip_cell")
                cell.backgroundColor = UIColor.dynamicColor(light: UIColor.white, dark: UIColor.darkGrayBGColor)
                cell.selectionStyle = .none
                cell.iconImageView.isHidden = true
                cell.titleLabel.text = "IP Address"
                cell.textField.keyboardType = .decimalPad
                cell.textField.clearButtonMode = .never
                cell.textField.delegate = self
                cell.swicth.isHidden = true
                cell.arrowView.isHidden = true

                cell.textField.text = self.oscSendIP
                cell.textField.tag = 1
                return cell
            }
            else if indexPath.row == 3 {
                let cell: SettingTableViewCell = SettingTableViewCell(style: .default, reuseIdentifier: "send_port_cell")
                cell.backgroundColor = UIColor.dynamicColor(light: UIColor.white, dark: UIColor.darkGrayBGColor)
                cell.selectionStyle = .none
                cell.iconImageView.isHidden = true
                cell.titleLabel.text = "Port"
                cell.textField.keyboardType = .decimalPad
                cell.textField.clearButtonMode = .never
                cell.textField.delegate = self
                cell.swicth.isHidden = true
                cell.arrowView.isHidden = true
                cell.lineView.isHidden = true

                cell.textField.text = self.oscSendPort
                cell.textField.tag = 2
                return cell
            }
        }
        else if indexPath.section == 1 {
            if indexPath.row == 0 || indexPath.row == 4 {
                return self.getLineCell()
            }
            else if indexPath.row == 1 {
                let cell: SettingTableViewCell = SettingTableViewCell(style: .default, reuseIdentifier: "recv_mode_cell")
                cell.backgroundColor = UIColor.dynamicColor(light: UIColor.white, dark: UIColor.darkGrayBGColor)
                cell.selectionStyle = .none
                cell.iconImageView.isHidden = true
                cell.titleLabel.text = "Recv"
                cell.textField.isHidden = true
                cell.arrowView.isHidden = true

                cell.swicth.isOn = false
                if self.oscRecvMode == "on" {
                    cell.swicth.isOn = true
                }
                cell.swicth.tag = 2
                cell.swicth.addTarget(self, action: #selector(self.switchValueChangedAction(_:)), for: .valueChanged)
                return cell
            }
            else if indexPath.row == 2 {
                let cell: SettingTableViewCell = SettingTableViewCell(style: .default, reuseIdentifier: "recv_ip_cell")
                cell.backgroundColor = UIColor.dynamicColor(light: UIColor.white, dark: UIColor.darkGrayBGColor)
                cell.selectionStyle = .none
                cell.iconImageView.isHidden = true
                cell.titleLabel.text = "IP Address"
                cell.textField.isEnabled = false
                cell.textField.delegate = self
                cell.swicth.isHidden = true
                cell.arrowView.isHidden = true

                cell.textField.text = self.oscRecvIP
                cell.textField.tag = 3
                return cell
            }
            else if indexPath.row == 3 {
                let cell: SettingTableViewCell = SettingTableViewCell(style: .default, reuseIdentifier: "recv_port_cell")
                cell.backgroundColor = UIColor.dynamicColor(light: UIColor.white, dark: UIColor.darkGrayBGColor)
                cell.selectionStyle = .none
                cell.iconImageView.isHidden = true
                cell.titleLabel.text = "Port"
                cell.textField.keyboardType = .decimalPad
                cell.textField.clearButtonMode = .never
                cell.textField.delegate = self
                cell.swicth.isHidden = true
                cell.arrowView.isHidden = true
                cell.lineView.isHidden = true

                cell.textField.text = self.oscRecvPort
                cell.textField.tag = 4
                return cell
            }
        }
        return super.tableView(tableView, cellForRowAt: indexPath)
    }

    // MARK: mark - UITableViewDelegate methods

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

        var height: CGFloat = 0
        if section == 0 {
            height = 44.0
        }
        else if section == 1 {
            height = 44.0
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
            return view
        }
        return nil
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        var height: CGFloat = 0
        let cell: SettingTableViewCell = SettingTableViewCell()
        if indexPath.section == 0 {
            if indexPath.row == 0 || indexPath.row == 4 {
                height = self.getLineCellHeight()
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
        else if indexPath.section == 1 {
            if indexPath.row == 0 || indexPath.row == 4 {
                height = self.getLineCellHeight()
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
        return height
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: false)
    }

    // MARK: mark - Change Swicth Action methods

    @objc func switchValueChangedAction(_ sw: UISwitch) {

        self.setOSCMode(sw)
    }

    // MARK: mark - UITextField methods

    @objc func textFieldDidChange(notification: NSNotification) {

        if let textField: UITextField = notification.object as? UITextField {
            self.setOSCValue(textField)
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        self.setOSCValue(textField)

        textField.resignFirstResponder()
        return true
    }

    // MARK: mark - Keyboard Action methods

    @objc func keyboardWillShow(_ notification: NSNotification?) {

        self.closeKeyboardButton.isHidden = false

        if let userInfo = notification?.userInfo, let keyboard = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue, let textFieldRect = self.textFieldRect {
            let keyBoardRect: CGRect = keyboard.cgRectValue
            if textFieldRect.origin.y + textFieldRect.size.height > self.settingTableView.frame.size.height - keyBoardRect.size.height {
                let y: CGFloat = textFieldRect.origin.y + textFieldRect.size.height - (self.settingTableView.frame.size.height - keyBoardRect.size.height)
                self.settingTableView.contentOffset = CGPoint(x: 0, y: y)
            }
        }
    }

    @objc func KeyboardWillHide(_ notification: NSNotification?) {

        self.closeKeyboardButton.isHidden = true

        self.textFieldRect = nil
        self.settingTableView.contentOffset = CGPoint(x: 0, y: 0)
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {

        self.textFieldRect = nil
        var indexPath: IndexPath? = nil
        if textField.tag == 1 {
            indexPath = IndexPath(row: 2, section: 0)
        }
        else if textField.tag == 2 {
            indexPath = IndexPath(row: 3, section: 0)
        }
        else if textField.tag == 3 {
            indexPath = IndexPath(row: 2, section: 1)
        }
        else if textField.tag == 4 {
            indexPath = IndexPath(row: 3, section: 1)
        }
        if let indexPath = indexPath, let cell = self.settingTableView.cellForRow(at: indexPath) {
            self.textFieldRect = cell.frame
        }
        return true
    }

    @objc func closeKeyboardAction() {

        self.view.endEditing(true)
        self.closeKeyboardButton.isHidden = true
    }
}
