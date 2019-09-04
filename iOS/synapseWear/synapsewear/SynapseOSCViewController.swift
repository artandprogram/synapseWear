//
//  SynapseOSCViewController.swift
//  synapsewear
//
//  Copyright © 2017年 art and program, Inc. For license and other information refer to https://github.com/artandprogram/synapseWear. All rights reserved.
//

import UIKit

class SynapseOSCViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, CommonFunctionProtocol {

    // const
    let settingFileManager: SettingFileManager = SettingFileManager()
    // variables
    var oscSendMode: String = "off"
    var oscRecvMode: String = "off"
    var oscSendIP: String = ""
    var oscRecvIP: String = ""
    var oscSendPort: String = ""
    var oscRecvPort: String = ""
    var oscRecvSettingFlag: Bool = false
    // views
    var settingTableView: UITableView!
    var closeKeyboardButton: UIButton!
    var oscSendSwitch: UISwitch?
    var oscSendIPField: UITextField?
    var oscSendPortField: UITextField?
    var oscRecvSwitch: UISwitch?
    var oscRecvPortField: UITextField?
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
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.saveSettingData()
        self.closeKeyboardAction()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func setParam() {
        super.setParam()

        if let str = self.settingFileManager.getSettingData(self.settingFileManager.oscSendModeKey) as? String {
            self.oscSendMode = str
        }
        if let str = self.settingFileManager.getSettingData(self.settingFileManager.oscRecvModeKey) as? String {
            self.oscRecvMode = str
        }
        if let str = self.settingFileManager.getSettingData(self.settingFileManager.oscSendIPAddressKey) as? String {
            self.oscSendIP = str
        }
        if let str = self.settingFileManager.getSettingData(self.settingFileManager.oscSendPortKey) as? String {
            self.oscSendPort = str
        }
        if let str = self.settingFileManager.getSettingData(self.settingFileManager.oscRecvPortKey) as? String {
            self.oscRecvPort = str
        }
        if let str = self.getWiFiAddress() {
            self.oscRecvIP = str
        }

        if let flag = self.getAppinfoValue("use_osc_recv") as? Bool {
            self.oscRecvSettingFlag = flag
        }

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardWillShow(_:)),
                                               name: .UIKeyboardWillShow,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.KeyboardWillHide(_:)),
                                               name: .UIKeyboardWillHide,
                                               object: nil)
    }

    override func setView() {
        super.setView()

        self.view.backgroundColor = UIColor.grayBGColor

        var x:CGFloat = 0
        var y:CGFloat = 0
        var w:CGFloat = self.view.frame.width
        var h:CGFloat = self.view.frame.height
        if let nav = self.navigationController as? NavigationController {
            y = nav.headerView.frame.origin.y + nav.headerView.frame.size.height
            h -= y
        }
        self.settingTableView = UITableView()
        self.settingTableView.frame = CGRect(x: x, y: y, width: w, height: h)
        self.settingTableView.backgroundColor = UIColor.clear
        self.settingTableView.separatorStyle = .none
        self.settingTableView.delegate = self
        self.settingTableView.dataSource = self
        self.view.addSubview(self.settingTableView)

        x = 0
        y = 0
        w = self.view.frame.size.width
        h = self.view.frame.size.height
        self.closeKeyboardButton = UIButton()
        self.closeKeyboardButton.frame = CGRect(x: x, y: y, width: w, height: h)
        self.closeKeyboardButton.backgroundColor = UIColor.black
        self.closeKeyboardButton.alpha = 0.5
        self.closeKeyboardButton.isHidden = true
        self.closeKeyboardButton.addTarget(self, action: #selector(self.closeKeyboardAction), for: .touchUpInside)
        self.view.addSubview(self.closeKeyboardButton)
    }

    // MARK: mark - SettingData methods

    func saveSettingData() {

        if let sw = self.oscSendSwitch {
            self.oscSendMode = "off"
            if sw.isOn {
                self.oscSendMode = "on"
            }
        }
        if let sw = self.oscRecvSwitch {
            self.oscRecvMode = "off"
            if sw.isOn {
                self.oscRecvMode = "on"
            }
        }
        if let text = self.oscSendIPField?.text {
            self.oscSendIP = text
        }
        if let text = self.oscSendPortField?.text {
            self.oscSendPort = text
        }
        if let text = self.oscRecvPortField?.text {
            self.oscRecvPort = text
        }

        var settingData: [String: Any] = [:]
        if let data = self.settingFileManager.getSettingData() {
            settingData = data
        }
        settingData[self.settingFileManager.oscSendModeKey] = self.oscSendMode
        settingData[self.settingFileManager.oscRecvModeKey] = self.oscRecvMode
        settingData[self.settingFileManager.oscSendIPAddressKey] = self.oscSendIP
        settingData[self.settingFileManager.oscSendPortKey] = self.oscSendPort
        settingData[self.settingFileManager.oscRecvPortKey] = self.oscRecvPort

        if self.settingFileManager.setSettingData(settingData) {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                appDelegate.setOSCClient()
            }
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

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        var num: Int = 0
        if section == 0 {
            num = 5
        }
        else if section == 1 {
            num = 5
        }
        return num
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        var cell: UITableViewCell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        cell.backgroundColor = UIColor.clear
        cell.selectionStyle = .none

        if indexPath.section == 0 {
            if indexPath.row == 0 || indexPath.row == 4 {
                cell = UITableViewCell(style: .default, reuseIdentifier: "line_cell")
                cell.backgroundColor = UIColor.black.withAlphaComponent(0.1)
                cell.selectionStyle = .none
            }
            else if indexPath.row == 1 {
                let cell: SettingTableViewCell = SettingTableViewCell(style: .default, reuseIdentifier: "send_mode_cell")
                cell.backgroundColor = UIColor.white
                cell.selectionStyle = .none
                cell.iconImageView.isHidden = true
                cell.titleLabel.text = "Send"
                cell.textField.isHidden = true
                cell.swicth.isOn = false
                if self.oscSendMode == "on" {
                    cell.swicth.isOn = true
                }
                cell.arrowView.isHidden = true
                self.oscSendSwitch = cell.swicth
                return cell
            }
            else if indexPath.row == 2 {
                let cell: SettingTableViewCell = SettingTableViewCell(style: .default, reuseIdentifier: "send_ip_cell")
                cell.backgroundColor = UIColor.white
                cell.selectionStyle = .none
                cell.iconImageView.isHidden = true
                cell.titleLabel.text = "IP Address"
                cell.textField.text = self.oscSendIP
                cell.textField.keyboardType = .decimalPad
                cell.textField.clearButtonMode = .never
                cell.textField.tag = 1
                cell.textField.delegate = self
                cell.swicth.isHidden = true
                cell.arrowView.isHidden = true
                self.oscSendIPField = cell.textField
                return cell
            }
            else if indexPath.row == 3 {
                let cell: SettingTableViewCell = SettingTableViewCell(style: .default, reuseIdentifier: "send_port_cell")
                cell.backgroundColor = UIColor.white
                cell.selectionStyle = .none
                cell.iconImageView.isHidden = true
                cell.titleLabel.text = "Port"
                cell.textField.text = self.oscSendPort
                cell.textField.keyboardType = .decimalPad
                cell.textField.clearButtonMode = .never
                cell.textField.tag = 2
                cell.textField.delegate = self
                cell.swicth.isHidden = true
                cell.arrowView.isHidden = true
                cell.lineView.isHidden = true
                self.oscSendPortField = cell.textField
                return cell
            }
        }
        else if indexPath.section == 1 {
            if indexPath.row == 0 || indexPath.row == 4 {
                cell = UITableViewCell(style: .default, reuseIdentifier: "line_cell")
                cell.backgroundColor = UIColor.black.withAlphaComponent(0.1)
                cell.selectionStyle = .none
            }
            else if indexPath.row == 1 {
                let cell: SettingTableViewCell = SettingTableViewCell(style: .default, reuseIdentifier: "recv_mode_cell")
                cell.backgroundColor = UIColor.white
                cell.selectionStyle = .none
                cell.iconImageView.isHidden = true
                cell.titleLabel.text = "Recv"
                cell.textField.isHidden = true
                cell.swicth.isOn = false
                if self.oscRecvMode == "on" {
                    cell.swicth.isOn = true
                }
                cell.arrowView.isHidden = true
                self.oscRecvSwitch = cell.swicth
                return cell
            }
            else if indexPath.row == 2 {
                let cell: SettingTableViewCell = SettingTableViewCell(style: .default, reuseIdentifier: "recv_ip_cell")
                cell.backgroundColor = UIColor.white
                cell.selectionStyle = .none
                cell.iconImageView.isHidden = true
                cell.titleLabel.text = "IP Address"
                cell.textField.text = self.oscRecvIP
                cell.textField.isEnabled = false
                cell.textField.tag = 3
                cell.textField.delegate = self
                cell.swicth.isHidden = true
                cell.arrowView.isHidden = true
                return cell
            }
            else if indexPath.row == 3 {
                let cell: SettingTableViewCell = SettingTableViewCell(style: .default, reuseIdentifier: "recv_port_cell")
                cell.backgroundColor = UIColor.white
                cell.selectionStyle = .none
                cell.iconImageView.isHidden = true
                cell.titleLabel.text = "Port"
                cell.textField.text = self.oscRecvPort
                cell.textField.keyboardType = .decimalPad
                cell.textField.clearButtonMode = .never
                cell.textField.tag = 4
                cell.textField.delegate = self
                cell.swicth.isHidden = true
                cell.arrowView.isHidden = true
                cell.lineView.isHidden = true
                self.oscRecvPortField = cell.textField
                return cell
            }
        }
        return cell
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
        else if indexPath.section == 1 {
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
        return height
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: false)
    }

    // MARK: mark - UITextFieldDelegate methods

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

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
