//
//  SynapseDevicesViewController.swift
//  synapsewear
//
//  Copyright © 2018 art and program, Inc. For license and other information refer to https://github.com/artandprogram/synapseWear. All rights reserved.
//

import UIKit

class SynapseDevicesViewController: SettingBaseViewController, DeviceScanningDelegate {

    // variables
    var deviceUUID: UUID?
    var devices: [RFduino] = []

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

    func scannedDevice() {

        if let nav = self.navigationController as? SettingNavigationViewController {
            self.deviceUUID = nav.getDeviceUUID()
            self.devices = nav.getScanDevices()
            self.settingTableView.reloadData()
        }
    }

    // MARK: mark - UITableViewDataSource methods

    func numberOfSections(in tableView: UITableView) -> Int {

        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        var num: Int = 0
        if section == 0 {
            num = self.devices.count + 2
        }
        return num
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.section == 0 {
            if indexPath.row == 0 || indexPath.row == self.devices.count + 1 {
                return self.getLineCell(tableView: tableView)
            }
            else if indexPath.row <= self.devices.count {
                let cell: SettingTableViewCell = self.getSettingTableViewCell(tableView: tableView, identifier: "interval_cell")
                cell.backgroundColor = UIColor.dynamicColor(light: UIColor.white, dark: UIColor.darkGrayBGColor)
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
        var cell: SettingTableViewCell? = SettingTableViewCell()
        if indexPath.section == 0 {
            if indexPath.row == 0 || indexPath.row == self.devices.count + 1 {
                height = self.getLineCellHeight()
            }
            else if indexPath.row <= self.devices.count {
                height = cell!.cellH
            }
        }
        cell = nil
        return height
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: false)

        if indexPath.row > 0, indexPath.row <= self.devices.count {
            if let nav = self.navigationController as? NavigationController {
                nav.reconnectSynapse(uuid: self.devices[indexPath.row - 1].peripheral.identifier)
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}
