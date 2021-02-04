//
//  SynapseFirmwareViewController.swift
//  synapsewear
//
//  Copyright © 2018 art and program, Inc. For license and other information refer to https://github.com/artandprogram/synapseWear. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class SynapseFirmwareViewController: SettingBaseViewController {

    // variables
    var firmwareURL: String = ""
    var firmwares: [[String: Any]] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.getFirmwareData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let nav = self.navigationController as? NavigationController {
            nav.headerTitle.text = "Firmware Update"
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: mark - FirmwareData methods

    func getFirmwareData() {

        self.setHiddenLoadingView(false)

        let apiFirmware: ApiFirmware = ApiFirmware(url: self.firmwareURL)
        apiFirmware.getFirmwareDataRequest(success: { (json: JSON?) in
            if let res = json, let firmwares = res["firmware"].array {
                self.firmwares = []
                for firmware in firmwares {
                    var data: [String: Any] = [:]
                    if let iosVer = firmware["ios_version"].string {
                        data["ios_version"] = iosVer
                    }
                    else if let iosVer = firmware["ios_version"].number {
                        data["ios_version"] = iosVer
                    }
                    if let devVer = firmware["device_version"].string {
                        data["device_version"] = devVer
                    }
                    else if let devVer = firmware["device_version"].number {
                        data["device_version"] = devVer
                    }
                    if let hexFile = firmware["hex_file"].string {
                        data["hex_file"] = hexFile
                    }
                    if let date = firmware["date"].string {
                        data["date"] = date
                    }
                    //print("data: \(data)")

                    if let devVer = data["device_version"], let checkVer = self.checkAppVersion(String(describing: devVer)) {
                        if checkVer == ComparisonResult.orderedSame || checkVer == ComparisonResult.orderedAscending {
                            self.firmwares.append(data)
                        }
                    }
                }
            }

            self.setHiddenLoadingView(true)
            self.settingTableView.reloadData()
        }, fail: {
            (error: Error?) in
            self.debugLog("getFirmwareData error: \(String(describing: error))")

            self.setHiddenLoadingView(true)
        })
    }

    func checkAppVersion(_ version: String) -> ComparisonResult? {

        if let infoDic = Bundle.main.infoDictionary, let appVersion = infoDic["CFBundleShortVersionString"] as? String {
            let appVersions: [String] = appVersion.components(separatedBy: ".")
            let checkVersions: [String] = version.components(separatedBy: ".")
            var appVersionsInt: [Int] = [0, 0, 0]
            if appVersions.count > 0, let major = Int(appVersions[0]) {
                appVersionsInt[0] = major
            }
            if appVersions.count > 1, let minor = Int(appVersions[1]) {
                appVersionsInt[1] = minor
            }
            if appVersions.count > 2, let revision = Int(appVersions[2]) {
                appVersionsInt[2] = revision
            }
            var checkVersionsInt: [Int] = [0, 0, 0]
            if checkVersions.count > 0, let major = Int(checkVersions[0]) {
                checkVersionsInt[0] = major
            }
            if checkVersions.count > 1, let minor = Int(checkVersions[1]) {
                checkVersionsInt[1] = minor
            }
            if checkVersions.count > 2, let revision = Int(checkVersions[2]) {
                checkVersionsInt[2] = revision
            }

            if appVersionsInt[0] > checkVersionsInt[0] || (appVersionsInt[0] == checkVersionsInt[0] && appVersionsInt[1] > checkVersionsInt[1]) || (appVersionsInt[0] == checkVersionsInt[0] && appVersionsInt[1] == checkVersionsInt[1] && appVersionsInt[2] > checkVersionsInt[2]) {
                return ComparisonResult.orderedAscending
            }
            else if appVersionsInt[0] < checkVersionsInt[0] || (appVersionsInt[0] == checkVersionsInt[0] && appVersionsInt[1] < checkVersionsInt[1]) || (appVersionsInt[0] == checkVersionsInt[0] && appVersionsInt[1] == checkVersionsInt[1] && appVersionsInt[2] < checkVersionsInt[2]) {
                return ComparisonResult.orderedDescending
            }
            else {
                return ComparisonResult.orderedSame
            }
        }
        return nil
    }

    // MARK: mark - UITableViewDataSource methods

    func numberOfSections(in tableView: UITableView) -> Int {

        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        var num: Int = 0
        if section == 0 {
            num = self.firmwares.count + 2
        }
        return num
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.section == 0 {
            if indexPath.row == 0 || indexPath.row == self.firmwares.count + 1 {
                return self.getLineCell(tableView: tableView)
            }
            else if indexPath.row <= self.firmwares.count {
                let cell: SettingTableViewCell = self.getSettingTableViewCell(tableView: tableView, identifier: "interval_cell")
                cell.backgroundColor = UIColor.dynamicColor(light: UIColor.white, dark: UIColor.darkGrayBGColor)
                cell.iconImageView.isHidden = true
                cell.textField.isHidden = true
                cell.swicth.isHidden = true
                cell.arrowView.isHidden = true
                cell.useCheckmark = true
                cell.lineView.isHidden = false
                if indexPath.row == self.firmwares.count {
                    cell.lineView.isHidden = true
                }

                let firmware: [String: Any] = self.firmwares[indexPath.row - 1]
                cell.titleLabel.text = ""
                if let devVer = firmware["device_version"] {
                    cell.titleLabel.text = "Device Version \(String(describing: devVer))"
                    if let date = firmware["date"] {
                        cell.titleLabel.text = "\(cell.titleLabel.text!) \(String(describing: date))"
                    }
                }

                cell.checkmarkView.isHidden = true
                if let nav = self.navigationController as? SettingNavigationViewController, let devVer = firmware["device_version"], let devVerAlt = nav.firmwareInfo["device_version"], String(describing: devVer) == String(describing: devVerAlt), let devDate = firmware["date"], let devDateAlt = nav.firmwareInfo["date"], String(describing: devDate) == String(describing: devDateAlt) {
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
            if indexPath.row == 0 || indexPath.row == self.firmwares.count + 1 {
                height = self.getLineCellHeight()
            }
            else if indexPath.row <= self.firmwares.count {
                height = cell!.cellH
            }
        }
        cell = nil
        return height
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: false)

        if indexPath.row > 0, indexPath.row <= self.firmwares.count {
            let firmware: [String: Any] = self.firmwares[indexPath.row - 1]
            //print("firmware: \(firmware)")
            if let host = self.getAppinfoValue("firmware_domain") as? String, let filename = firmware["hex_file"] as? String, filename.count > 0 {
                self.startDownload("\(host)\(filename)", firmwareInfo: firmware)
                //print("Firmware: \(firmware)")
            }
        }
    }

    // MARK: mark - Firmware File methods

    func startDownload(_ hexUrl: String, firmwareInfo: [String: Any]) -> Void {

        let fileUrl: URL = self.getSaveFileUrl(fileName: hexUrl)
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            return (fileUrl, [.removePreviousFile, .createIntermediateDirectories])
        }
        debugLog("startDownload: \(fileUrl.absoluteString)")

        self.setHiddenLoadingView(false)

        Alamofire.download(hexUrl, to:destination)
            .downloadProgress { (progress) in
            }
            .responseData { (data) in
                self.setHiddenLoadingView(true)

                if let nav = self.navigationController as? SettingNavigationViewController {
                    nav.updateFirmware(fileUrl, firmwareInfo: firmwareInfo)
                }
        }
    }

    func getSaveFileUrl(fileName: String) -> URL {

        let documentsUrl: URL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let nameUrl: URL = URL(string: fileName)!
        let fileUrl: URL = documentsUrl.appendingPathComponent(nameUrl.lastPathComponent)
        //NSLog(fileURL.absoluteString)
        return fileUrl
    }
}
