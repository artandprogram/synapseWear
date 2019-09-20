//
//  SynapseUploadSettingsViewController.swift
//  synapsewear
//
//  Copyright © 2018年 art and program, Inc. For license and other information refer to https://github.com/artandprogram/synapseWear. All rights reserved.
//

import UIKit

class SynapseUploadSettingsViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {

    // variables
    var synapseSendFlag: Bool = false
    var synapseSendURL: String = ""
    // views
    var settingTableView: UITableView!
    var closeKeyboardButton: UIButton!
    var synapseSendFlagSwitch: UISwitch?
    var synapseSendURLField: UITextField?
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
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.saveSettingData()
        self.view.endEditing(true)
        //self.closeKeyboardAction()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func setParam() {
        super.setParam()

        self.synapseSendFlag = SettingFileManager.shared.synapseSendFlag
        self.synapseSendURL = SettingFileManager.shared.synapseSendURL
        /*
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.KeyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
         */
    }

    override func setView() {
        super.setView()

        self.view.backgroundColor = UIColor.grayBGColor

        let x:CGFloat = 0
        var y:CGFloat = 0
        let w:CGFloat = self.view.frame.width
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
        /*
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
         */
    }

    // MARK: mark - SettingData methods

    func saveSettingData() {

        if let sw = self.synapseSendFlagSwitch {
            self.synapseSendFlag = sw.isOn
        }
        if let text = self.synapseSendURLField?.text {
            self.synapseSendURL = text
        }
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

        let sections: Int = 1
        return sections
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        var num: Int = 0
        if section == 0 {
            num = 5
        }
        return num
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        var cell: UITableViewCell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        cell.backgroundColor = UIColor.clear
        cell.selectionStyle = .none

        if indexPath.section == 0 {
            if indexPath.row == 0 || indexPath.row == 3 {
                cell = UITableViewCell(style: .default, reuseIdentifier: "line_cell")
                cell.backgroundColor = UIColor.black.withAlphaComponent(0.1)
                cell.selectionStyle = .none
            }
            else if indexPath.row == 1 {
                let cell: SettingTableViewCell = SettingTableViewCell(style: .default, reuseIdentifier: "send_flag_cell")
                cell.backgroundColor = UIColor.white
                cell.selectionStyle = .none
                cell.iconImageView.isHidden = true
                cell.titleLabel.text = "Send"
                cell.textField.isHidden = true
                cell.swicth.isOn = self.synapseSendFlag
                cell.arrowView.isHidden = true
                self.self.synapseSendFlagSwitch = cell.swicth
                return cell
            }
            else if indexPath.row == 2 {
                let cell: SettingTableViewCell = SettingTableViewCell(style: .default, reuseIdentifier: "send_url_cell")
                cell.backgroundColor = UIColor.white
                cell.selectionStyle = .none
                cell.iconImageView.isHidden = true
                cell.titleLabel.isHidden = true
                cell.textField.text = self.synapseSendURL
                cell.textField.placeholder = "Upload URL"
                cell.textField.textColor = UIColor.darkGray
                cell.textField.textAlignment = .left
                cell.textField.tag = 1
                cell.textField.delegate = self
                cell.swicth.isHidden = true
                cell.arrowView.isHidden = true
                cell.lineView.isHidden = true
                self.synapseSendURLField = cell.textField
                return cell
            }
            else if indexPath.row == 4 {
                cell = UITableViewCell(style: .default, reuseIdentifier: "note_cell")
                cell.backgroundColor = UIColor.clear
                cell.selectionStyle = .none

                cell.textLabel?.text = "URL must be https. Data will be uploaded every hour on the hour."
                cell.textLabel?.textColor = UIColor.darkGray
                cell.textLabel?.font = UIFont(name: "HelveticaNeue", size: 14.0)
                cell.textLabel?.numberOfLines = 0
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
                height = 1.0
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

    // MARK: mark - UITextFieldDelegate methods

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        textField.resignFirstResponder()
        return true
    }

    // MARK: mark - Keyboard Action methods
    /*
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
