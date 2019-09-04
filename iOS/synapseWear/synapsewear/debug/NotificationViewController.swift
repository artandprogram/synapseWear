//
//  NotificationViewController.swift
//  synapsewear
//
//  Copyright © 2017年 art and program, Inc. For license and other information refer to https://github.com/artandprogram/synapseWear. All rights reserved.
//

import UIKit

class NotificationViewController: BaseViewController, UITextFieldDelegate {

    let settingFileManager: SettingFileManager = SettingFileManager()
    var notificationInfo: [String: Any] = [:]
    var settingAreaView: UIView!
    var co2ValueField: UITextField!
    var co2FlagSwitch: UISwitch!
    var closeKeyboardButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setNotificationValues()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardWillShow(_:)),
                                               name: .UIKeyboardWillShow,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.KeyboardWillHide(_:)),
                                               name: .UIKeyboardWillHide,
                                               object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func setParam() {
        super.setParam()

        if let settingData = self.settingFileManager.getSettingData(), let info = settingData["notification_info"] as? [String: Any] {
            self.notificationInfo = info
        }

        if let nav = self.navigationController as? NavigationController {
            nav.headerTitle.text = "Notification"
        }
    }

    override func setView() {
        super.setView()

        self.view.backgroundColor = UIColor.lightGray

        var x: CGFloat = 20.0
        var y: CGFloat = 20.0 + 60.0 + 20.0
        var w: CGFloat = self.view.frame.size.width - x * 2
        var h: CGFloat = 30.0
        let label1: UILabel = UILabel()
        label1.text = "CO2"
        label1.backgroundColor = UIColor.clear
        label1.textColor = UIColor.black
        label1.font = UIFont(name: "HelveticaNeue", size: 16.0)
        label1.textAlignment = .left
        label1.numberOfLines = 1
        label1.sizeToFit()
        label1.frame = CGRect(x: x, y: y, width: label1.frame.size.width, height: h)
        self.view.addSubview(label1)

        x = label1.frame.origin.x + label1.frame.size.width + 10.0
        y = label1.frame.origin.y + label1.frame.size.height - 30.0
        w = 50.0
        h = 30.0
        self.co2FlagSwitch = UISwitch()
        self.co2FlagSwitch.frame = CGRect(x: x, y: y, width: label1.frame.size.width, height: h)
        self.co2FlagSwitch.isOn = false
        self.view.addSubview(self.co2FlagSwitch)

        x = 20.0
        y = label1.frame.origin.y + label1.frame.size.height + 10.0
        w = self.view.frame.size.width - x * 2
        h = 40.0
        let textfieldView1: UIView = UIView()
        textfieldView1.frame = CGRect(x: x, y: y, width: w, height: h)
        textfieldView1.backgroundColor = UIColor.white
        textfieldView1.layer.borderWidth = 1
        textfieldView1.layer.borderColor = UIColor.darkGray.cgColor
        self.view.addSubview(textfieldView1)

        x = 10.0
        y = 0
        w = textfieldView1.frame.size.width - x
        h = textfieldView1.frame.size.height
        self.co2ValueField = UITextField()
        self.co2ValueField.delegate = self
        self.co2ValueField.frame = CGRect(x: x, y: y, width: w, height: h)
        self.co2ValueField.backgroundColor = UIColor.clear
        self.co2ValueField.textColor = UIColor.darkGray
        self.co2ValueField.font = UIFont(name: "HelveticaNeue", size: 14)
        self.co2ValueField.borderStyle = .none
        self.co2ValueField.textAlignment = .left
        self.co2ValueField.clearButtonMode = .whileEditing
        self.co2ValueField.keyboardType = .decimalPad
        textfieldView1.addSubview(self.co2ValueField)

        x = textfieldView1.frame.origin.x
        y = textfieldView1.frame.origin.y + textfieldView1.frame.size.height + 20.0
        w = (textfieldView1.frame.size.width - x) / 2
        h = 44.0
        let okButton: UIButton = UIButton()
        okButton.frame = CGRect(x: x, y: y, width: w, height: h)
        okButton.setTitle("OK", for: .normal)
        okButton.setTitleColor(UIColor.darkGray, for: .normal)
        okButton.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 14.0)
        okButton.backgroundColor = UIColor.white
        okButton.layer.borderWidth = 1
        okButton.layer.borderColor = UIColor.darkGray.cgColor
        okButton.addTarget(self, action: #selector(self.saveSettingData), for: .touchUpInside)
        self.view.addSubview(okButton)

        x = okButton.frame.origin.x + okButton.frame.size.width + x
        let cancelButton: UIButton = UIButton()
        cancelButton.frame = CGRect(x: x, y: y, width: w, height: h)
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.setTitleColor(UIColor.darkGray, for: .normal)
        cancelButton.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 14.0)
        cancelButton.backgroundColor = UIColor.white
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor.darkGray.cgColor
        cancelButton.addTarget(self, action: #selector(self.cancelAction), for: .touchUpInside)
        self.view.addSubview(cancelButton)

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

    func setNotificationValues() {

        self.co2FlagSwitch.isOn = false
        self.co2ValueField.text = ""
        if let co2Info = self.notificationInfo["co2"] as? [String: Any] {
            if let flag = co2Info["flag"] as? Bool {
                self.co2FlagSwitch.isOn = flag
            }
            if let value = co2Info["value"] as? Int {
                self.co2ValueField.text = String(value)
            }
        }
    }
    
    @objc func cancelAction() {

        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @objc func saveSettingData() {

        var co2Info:[String: Any] = [:]
        co2Info["flag"] = self.co2FlagSwitch.isOn
        co2Info["value"] = ""
        if let text = self.co2ValueField.text, let value = Int(text) {
            co2Info["value"] = value
        }
        self.notificationInfo["co2"] = co2Info
        var settingData: [String: Any] = [:]
        if let data = self.settingFileManager.getSettingData() {
            settingData = data
        }
        settingData["notification_info"] = self.notificationInfo
        _ = self.settingFileManager.setSettingData(settingData)
        /*
        if self.settingFileManager.setSettingData(settingData) {
            if let nav = self.navigationController as? NavigationController {
                nav.updateSynapseId()
            }
        }
         */
        self.cancelAction()
    }

    // MARK: mark - UITextFieldDelegate methods

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        textField.resignFirstResponder()
        return true
    }

    @objc func keyboardWillShow(_ notification: NSNotification?) {

        self.closeKeyboardButton.isHidden = false
    }

    @objc func KeyboardWillHide(_ notification: NSNotification?) {

        self.closeKeyboardButton.isHidden = true
    }

    @objc func closeKeyboardAction() {

        self.view.endEditing(true)
        self.closeKeyboardButton.isHidden = true
    }
}
