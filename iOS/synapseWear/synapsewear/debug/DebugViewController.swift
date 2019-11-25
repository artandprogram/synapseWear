//
//  DebugViewController.swift
//  synapsewear
//
//  Copyright © 2019 art and program, Inc. For license and other information refer to https://github.com/artandprogram/synapseWear. All rights reserved.
//

import UIKit

class DebugViewController: DebugBaseViewController, UsageFunction {

    var uuid: UUID?
    var uuids: [UUID] = []
    var dates: [String] = []

    override func setParam() {
        super.setParam()

        self.setTableViewData()
    }

    func setTableViewData() {

        if let uuid = self.uuid {
            let synapseRecordFileManager: SynapseRecordFileManager = SynapseRecordFileManager()
            synapseRecordFileManager.setSynapseId(uuid.uuidString)
            self.dates = synapseRecordFileManager.getDayDirectories()
        }
        else {
            let accessKeysFileManager: AccessKeysFileManager = AccessKeysFileManager()
            self.uuids = accessKeysFileManager.getUUIDList()
        }
    }

    override func setView() {
        super.setView()

        if let uuid = self.uuid {
            self.topLabel.text = uuid.uuidString
        }
        else {
            self.topLabel.text = self.makeUsageString()
        }
    }

    // MARK: mark - UITableViewDataSource methods

    func numberOfSections(in tableView: UITableView) -> Int {

        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if let _ = self.uuid {
            return self.dates.count
        }
        else {
            return self.uuids.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell: UITableViewCell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        cell.backgroundColor = UIColor.clear
        cell.accessoryType = .disclosureIndicator

        cell.textLabel?.text = self.makeCellString(indexPath.row)
        //cell.textLabel?.font = UIFont(name: "HiraKakuProN-W3", size: 14.0)
        if #available(iOS 8.2, *) {
            cell.textLabel?.font = UIFont.systemFont(ofSize: 14.0, weight: .regular)
        }
        else {
            cell.textLabel?.font = UIFont.systemFont(ofSize: 14.0)
        }
        cell.textLabel?.textColor = #colorLiteral(red: 0.6823529412, green: 0.6823529412, blue: 0.6980392157, alpha: 1)
        cell.textLabel?.numberOfLines = 0

        return cell
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {

        if let _ = self.uuid, indexPath.row < self.dates.count {
            self.removeData(self.dates[indexPath.row])
        }
        else if indexPath.row < self.uuids.count {
            self.removeData(self.uuids[indexPath.row].uuidString)
        }
    }

    // MARK: mark - UITableViewDelegate methods

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        let x: CGFloat = 10.0
        let y: CGFloat = 0
        let w: CGFloat = tableView.frame.width - (x + 40.0)
        var h: CGFloat = 0
        let label: UILabel = UILabel()
        label.text = self.makeCellString(indexPath.row)
        label.frame = CGRect(x: x, y: y, width: w, height: h)
        //label.font = UIFont(name: "HiraKakuProN-W3", size: 14.0)
        if #available(iOS 8.2, *) {
            label.font = UIFont.systemFont(ofSize: 14.0, weight: .regular)
        }
        else {
            label.font = UIFont.systemFont(ofSize: 14.0)
        }
        label.numberOfLines = 0
        label.sizeToFit()

        h = label.frame.size.height + 10.0 * 2
        return h
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: false)

        if let uuid = self.uuid, indexPath.row < self.dates.count {
            let vc: DebugDetailViewController = DebugDetailViewController()
            vc.uuid = uuid
            vc.day = self.dates[indexPath.row]
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if indexPath.row < self.uuids.count {
            let vc: DebugViewController = DebugViewController()
            vc.uuid = self.uuids[indexPath.row]
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    func makeCellString(_ row: Int) -> String {

        var text: String = ""
        if let _ = self.uuid, row < self.dates.count {
            text = self.makeDateString(self.dates[row])
        }
        else if row < self.uuids.count {
            text = self.uuids[row].uuidString
        }
        return text
    }

    func removeData(_ directory: String) {

        self.setHiddenLoadingView(false)

        DispatchQueue.global(qos: .background).async {
            var path: String = ""
            let synapseRecordFileManager: SynapseRecordFileManager = SynapseRecordFileManager()
            if let uuid = self.uuid {
                synapseRecordFileManager.setSynapseId(uuid.uuidString)
                path = "\(synapseRecordFileManager.baseDirPath)/\(directory)"
            }
            else {
                synapseRecordFileManager.setSynapseId(directory)
                path = synapseRecordFileManager.baseDirPath
            }
            print("removeData: \(path)")

            do {
                try FileManager.default.removeItem(atPath: path)
            }
            catch {
                //print("error")
            }

            print("removeData Finish")
            DispatchQueue.main.async {
                self.setHiddenLoadingView(true)
                self.setTableViewData()
                self.tableView.reloadData()
            }
        }
    }

    func makeUsageString() -> String {

        var str: String = ""
        str = "\(str)\(String(format: "CPU : %.01f %%", self.getCPUUsage()))"
        if let mem = self.getMemoryUsed() {
            str = "\(str), "
            str = "\(str)Memory : \(ByteCountFormatter.string(fromByteCount: Int64(mem), countStyle: ByteCountFormatter.CountStyle.binary))"
        }
        str = "\(str), "
        str = "\(str)Space : \(self.getDiskSpace(.free))"
        return str
    }
}
