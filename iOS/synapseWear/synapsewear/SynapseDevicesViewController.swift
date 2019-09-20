//
//  SynapseDevicesViewController.swift
//  synapsewear
//
//  Copyright © 2018年 art and program, Inc. For license and other information refer to https://github.com/artandprogram/synapseWear. All rights reserved.
//

import UIKit

class SynapseDevicesViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate, DeviceScanningDelegate {

    // variables
    var deviceUUID: UUID?
    var devices: [RFduino] = []
    // views
    var settingTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let nav = self.navigationController as? NavigationController {
            nav.headerTitle.text = "synapseWear Devices"
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if let nav = self.navigationController as? SettingNavigationViewController {
            nav.stopDeviceScan()
            nav.setScanDevicesDelegate(nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func setParam() {
        super.setParam()

        if let nav = self.navigationController as? SettingNavigationViewController {
            nav.startDeviceScan()
            self.deviceUUID = nav.getDeviceUUID()
            self.devices = nav.getScanDevices()
            nav.setScanDevicesDelegate(self)
        }
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
    }

    func scannedDevice() {

        if let nav = self.navigationController as? SettingNavigationViewController {
            self.deviceUUID = nav.getDeviceUUID()
            self.devices = nav.getScanDevices()
            self.settingTableView.reloadData()
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
            num = self.devices.count + 2
        }
        return num
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        var cell: UITableViewCell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        cell.backgroundColor = UIColor.clear
        cell.selectionStyle = .none

        if indexPath.section == 0 {
            if indexPath.row == 0 || indexPath.row == self.devices.count + 1 {
                cell = UITableViewCell(style: .default, reuseIdentifier: "line_cell")
                cell.backgroundColor = UIColor.black.withAlphaComponent(0.1)
                cell.selectionStyle = .none
            }
            else if indexPath.row <= self.devices.count {
                let cell: SettingTableViewCell = SettingTableViewCell(style: .default, reuseIdentifier: "interval_cell")
                cell.backgroundColor = UIColor.white
                cell.iconImageView.isHidden = true
                cell.textField.isHidden = true
                cell.swicth.isHidden = true
                cell.arrowView.isHidden = true
                cell.useCheckmark = true
                cell.lineView.isHidden = false
                if indexPath.row == self.devices.count {
                    cell.lineView.isHidden = true
                }

                let device: RFduino = self.devices[indexPath.row - 1]
                cell.titleLabel.text = device.peripheral.identifier.uuidString
                if let uuid = self.deviceUUID, device.peripheral.identifier == uuid {
                    cell.checkmarkView.isHidden = false
                }
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
            if indexPath.row == 0 || indexPath.row == self.devices.count + 1 {
                height = 1.0
            }
            else if indexPath.row <= self.devices.count {
                height = cell.cellH
            }
        }
        return height
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: false)

        if indexPath.row > 0 && indexPath.row <= self.devices.count {
            if let nav = self.navigationController as? NavigationController {
                nav.reconnectSynapse(uuid: self.devices[indexPath.row - 1].peripheral.identifier)
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}
