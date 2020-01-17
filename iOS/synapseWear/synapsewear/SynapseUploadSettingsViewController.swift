//
//  SynapseUploadSettingsViewController.swift
//  synapsewear
//
//  Copyright © 2018 art and program, Inc. For license and other information refer to https://github.com/artandprogram/synapseWear. All rights reserved.
//

import UIKit

class SynapseUploadSettingsViewController: SettingBaseViewController, UITextFieldDelegate {

    // variables
    var synapseSendFlag: Bool = false
    var synapseSendURL: String = ""
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
            nav.headerTitle.text = "Upload Settings"
        }

        self.setNotificationCenter()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.saveSettingData()
        self.view.endEditing(true)
        //self.closeKeyboardAction()

        NotificationCenter.default.removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func setParam() {
        super.setParam()

        self.synapseSendFlag = SettingFileManager.shared.synapseSendFlag
        self.synapseSendURL = SettingFileManager.shared.synapseSendURL
    }

    /*override func setView() {
        super.setView()

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
    }*/

    // MARK: mark - NotificationCenter methods

    func setNotificationCenter() {

        /*NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardWillShow(_:)),
                                               name: .UIKeyboardWillShow,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.KeyboardWillHide(_:)),
                                               name: .UIKeyboardWillHide,
                                               object: nil)*/
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(type(of: self).textFieldDidChange(notification:)),
                                               name: .UITextFieldTextDidChange,
                                               object: nil)
    }

    // MARK: mark - SettingData methods

    func setSendFlag(_ sw: UISwitch) {

        if sw.tag == 1 {
            self.synapseSendFlag = sw.isOn
        }
    }

    func setSendURL(_ textField: UITextField) {

        if let text = textField.text {
            if textField.tag == 1 {
                self.synapseSendURL = text
            }
        }
    }

    func saveSettingData() {

        if self.synapseSendFlag != SettingFileManager.shared.synapseSendFlag || self.synapseSendURL != SettingFileManager.shared.synapseSendURL {
            SettingFileManager.shared.synapseSendFlag = self.synapseSendFlag
            SettingFileManager.shared.synapseSendURL = self.synapseSendURL
            if SettingFileManager.shared.saveData() {
                if let nav = self.navigationController as? SettingNavigationViewController {
                    nav.changeSynapseSendData()
                }
            }
            else {
                SettingFileManager.shared.loadData()
            }
        }
    }

    // MARK: mark - UITableViewDataSource methods

    func numberOfSections(in tableView: UITableView) -> Int {

        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        var num: Int = 0
        if section == 0 {
            num = 5
        }
        return num
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.section == 0 {
            if indexPath.row == 0 || indexPath.row == 3 {
                return self.getLineCell()
            }
            else if indexPath.row == 1 {
                let cell: SettingTableViewCell = SettingTableViewCell(style: .default, reuseIdentifier: "send_flag_cell")
                cell.backgroundColor = UIColor.dynamicColor(light: UIColor.white, dark: UIColor.darkGrayBGColor)
                cell.selectionStyle = .none
                cell.iconImageView.isHidden = true
                cell.titleLabel.text = "Send"
                cell.textField.isHidden = true
                cell.arrowView.isHidden = true

                cell.swicth.isOn = self.synapseSendFlag
                cell.swicth.tag = 1
                cell.swicth.addTarget(self, action: #selector(self.switchValueChangedAction(_:)), for: .valueChanged)
                return cell
            }
            else if indexPath.row == 2 {
                let cell: SettingTableViewCell = SettingTableViewCell(style: .default, reuseIdentifier: "send_url_cell")
                cell.backgroundColor = UIColor.dynamicColor(light: UIColor.white, dark: UIColor.darkGrayBGColor)
                cell.selectionStyle = .none
                cell.iconImageView.isHidden = true
                cell.titleLabel.isHidden = true
                cell.textField.placeholder = "Upload URL"
                cell.textField.textColor = UIColor.dynamicColor(light: UIColor.darkGray, dark: UIColor.white)
                cell.textField.textAlignment = .left
                cell.textField.tag = 1
                cell.textField.delegate = self
                cell.swicth.isHidden = true
                cell.arrowView.isHidden = true
                cell.lineView.isHidden = true

                cell.textField.text = self.synapseSendURL
                cell.textField.tag = 1
                return cell
            }
            else if indexPath.row == 4 {
                let cell: UITableViewCell = UITableViewCell(style: .default, reuseIdentifier: "note_cell")
                cell.backgroundColor = UIColor.clear
                cell.selectionStyle = .none

                cell.textLabel?.text = "URL must be https. Data will be uploaded every hour on the hour."
                cell.textLabel?.textColor = UIColor.dynamicColor(light: UIColor.darkGray, dark: UIColor.gray)
                cell.textLabel?.font = UIFont(name: "HelveticaNeue", size: 14.0)
                cell.textLabel?.numberOfLines = 0
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
            if indexPath.row == 0 || indexPath.row == 3 {
                height = self.getLineCellHeight()
            }
            else if indexPath.row == 1 {
                height = cell.cellH
            }
            else if indexPath.row == 2 {
                height = cell.cellH
            }
            else if indexPath.row == 4 {
                height = 50.0
            }
        }
        return height
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: false)
    }

    // MARK: mark - Change Swicth Action methods

    @objc func switchValueChangedAction(_ sw: UISwitch) {

        self.setSendFlag(sw)
    }

    // MARK: mark - UITextField methods

    @objc func textFieldDidChange(notification: NSNotification) {

        if let textField: UITextField = notification.object as? UITextField {
            self.setSendURL(textField)
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        self.setSendURL(textField)

        textField.resignFirstResponder()
        return true
    }

    /*// MARK: mark - Keyboard Action methods

    func keyboardWillShow(_ notification: NSNotification?) {

        self.closeKeyboardButton.isHidden = false

        if let userInfo = notification?.userInfo, let keyboard = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue, let textFieldRect = self.textFieldRect {
            let keyBoardRect: CGRect = keyboard.cgRectValue
            if textFieldRect.origin.y + textFieldRect.size.height > self.settingTableView.frame.size.height - keyBoardRect.size.height {
                let y: CGFloat = textFieldRect.origin.y + textFieldRect.size.height - (self.settingTableView.frame.size.height - keyBoardRect.size.height)
                self.settingTableView.contentOffset = CGPoint(x: 0, y: y)
            }
        }
    }

    func KeyboardWillHide(_ notification: NSNotification?) {

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
        if let indexPath = indexPath, let cell = self.settingTableView.cellForRow(at: indexPath) {
            self.textFieldRect = cell.frame
        }
        return true
    }

    func closeKeyboardAction() {

        self.view.endEditing(true)
        self.closeKeyboardButton.isHidden = true
    }
     */
}
