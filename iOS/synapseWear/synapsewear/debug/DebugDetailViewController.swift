//
//  DebugDetailViewController.swift
//  synapsewear
//
//  Copyright © 2019 art and program, Inc. For license and other information refer to https://github.com/artandprogram/synapseWear. All rights reserved.
//

import UIKit

class DebugDetailViewController: DebugBaseViewController, FileManagerExtension {

    let axDiff: CrystalStruct = CrystalStruct(key: SynapseRecordTotalType.axDiff.rawValue,
                                              name: "Acceleration X Diff",
                                              hasGraph: false,
                                              graphColor: UIColor.graphMove)
    let ayDiff: CrystalStruct = CrystalStruct(key: SynapseRecordTotalType.ayDiff.rawValue,
                                              name: "Acceleration Y Diff",
                                              hasGraph: false,
                                              graphColor: UIColor.graphMove)
    let azDiff: CrystalStruct = CrystalStruct(key: SynapseRecordTotalType.azDiff.rawValue,
                                              name: "Acceleration Z Diff",
                                              hasGraph: false,
                                              graphColor: UIColor.graphMove)
    let gxDiff: CrystalStruct = CrystalStruct(key: SynapseRecordTotalType.gxDiff.rawValue,
                                              name: "Gyro X Diff",
                                              hasGraph: false,
                                              graphColor: UIColor.graphAngl)
    let gyDiff: CrystalStruct = CrystalStruct(key: SynapseRecordTotalType.gyDiff.rawValue,
                                              name: "Gyro Y Diff",
                                              hasGraph: false,
                                              graphColor: UIColor.graphAngl)
    let gzDiff: CrystalStruct = CrystalStruct(key: SynapseRecordTotalType.gzDiff.rawValue,
                                              name: "Gyro Z Diff",
                                              hasGraph: false,
                                              graphColor: UIColor.graphAngl)
    var uuid: UUID?
    var day: String?
    var synapseRecordFileManager: SynapseRecordFileManager?
    var sections: [CrystalStruct] = []
    var connectLogs: [[String: Date]] = []
    var valuesFileSize: String = ""

    override func setParam() {
        super.setParam()

        if let uuid = self.uuid {
            self.synapseRecordFileManager = SynapseRecordFileManager()
            self.synapseRecordFileManager?.setSynapseId(uuid.uuidString)

            self.sections = [
                self.synapseCrystalInfo.co2,
                self.synapseCrystalInfo.temp,
                self.synapseCrystalInfo.hum,
                self.synapseCrystalInfo.ill,
                self.synapseCrystalInfo.press,
                self.synapseCrystalInfo.sound,
                self.axDiff,
                self.ayDiff,
                self.azDiff,
                self.gxDiff,
                self.gyDiff,
                self.gzDiff,
                self.synapseCrystalInfo.volt,
            ]

            self.connectLogs = self.synapseRecordFileManager?.getConnectLogsData(day: self.day) ?? []
            //print("connectLogs: \(self.connectLogs)")

            DispatchQueue.global(qos: .background).async {
                self.setValuesFileSize()
            }
        }
    }

    func setValuesFileSize() {

        self.valuesFileSize = ""
        do {
            if let synapseRecordFileManager = self.synapseRecordFileManager, let day = self.day {
                let path: String = "\(synapseRecordFileManager.baseDirPath)/\(day)/\(synapseRecordFileManager.valuesDir)"
                let size: UInt64 = try self.findSize(path: path)
                self.valuesFileSize = self.sizeToPrettyString(size: size)

                DispatchQueue.main.async {
                    //self.tableView.reloadData()
                    self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
                }
            }
        }
        catch {
        }
    }

    func removeValuesFile() {

        if let synapseRecordFileManager = self.synapseRecordFileManager, let day = self.day {
            self.valuesFileSize = "Removing..."
            self.tableView.reloadData()

            DispatchQueue.global(qos: .background).async {
                let fileManager: FileManager = FileManager.default
                let path: String = "\(synapseRecordFileManager.baseDirPath)/\(day)/\(synapseRecordFileManager.valuesDir)"
                do {
                    let directories: [String] = try fileManager.contentsOfDirectory(atPath: path)
                    for directory in directories {
                        print("remove: \(directory)")
                        try fileManager.removeItem(atPath: "\(path)/\(directory)")
                    }
                }
                catch {
                }

                self.setValuesFileSize()
            }
        }
    }

    override func setView() {
        super.setView()

        self.tableView.separatorStyle = .none

        self.topLabel.text = ""
        if let uuid = self.uuid {
            self.topLabel.text = uuid.uuidString
            if let day = self.day {
                self.topLabel.text = "\(self.topLabel.text!)\n -> \(self.makeDateString(day))"
            }
        }
    }

    // MARK: mark - UITableViewDataSource methods

    func numberOfSections(in tableView: UITableView) -> Int {

        return self.sections.count + 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if section == 0 {
            return 1
        }
        else if section <= self.sections.count {
            return 24
        }
        else if section == self.sections.count + 1 {
            return self.connectLogs.count + 2
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell: UITableViewCell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        cell.backgroundColor = UIColor.clear
        cell.selectionStyle = .none
        cell.clipsToBounds = true
        cell.textLabel?.text = ""
        cell.textLabel?.textColor = #colorLiteral(red: 0.6823529412, green: 0.6823529412, blue: 0.6980392157, alpha: 1)
        cell.textLabel?.font = UIFont(name: "HiraKakuProN-W3", size: 14.0)
        cell.textLabel?.numberOfLines = 1
        cell.isEditing = false

        if indexPath.section == 0 {
            cell.textLabel?.text = self.valuesFileSize
            cell.isEditing = true
        }
        else if indexPath.section <= self.sections.count {
            let cell: DebugTableViewCell = DebugTableViewCell(style: .default, reuseIdentifier: "DebugCell")
            cell.backgroundColor = UIColor.clear
            cell.accessoryType = .disclosureIndicator
            cell.clipsToBounds = true

            cell.leftLabel.text = ""
            cell.leftLabel.textColor = #colorLiteral(red: 0.6823529412, green: 0.6823529412, blue: 0.6980392157, alpha: 1)
            cell.leftLabel.backgroundColor = #colorLiteral(red: 0.2823529412, green: 0.2823529412, blue: 0.2901960784, alpha: 1)
            cell.rightLabelMain.text = ""
            cell.rightLabelMain.textColor = #colorLiteral(red: 0.6823529412, green: 0.6823529412, blue: 0.6980392157, alpha: 1)
            cell.rightLabelSub.text = ""
            cell.rightLabelSub.textColor = #colorLiteral(red: 0.6823529412, green: 0.6823529412, blue: 0.6980392157, alpha: 1)
            cell.rightLabelSub2.text = ""
            cell.rightLabelSub2.textColor = #colorLiteral(red: 0.6823529412, green: 0.6823529412, blue: 0.6980392157, alpha: 1)
            cell.lineView.backgroundColor = #colorLiteral(red: 0.2823529412, green: 0.2823529412, blue: 0.2901960784, alpha: 1)
            if let day = self.day, let synapseRecordFileManager = self.synapseRecordFileManager, self.tableView(tableView, heightForRowAt: indexPath) > 0 {
                let type: String = self.sections[indexPath.section - 1].key
                let hour: String = String(format:"%02d", indexPath.row)
                cell.leftLabel.text = String(format:"%02d", indexPath.row)

                cell.rightLabelMain.text = "--"
                if let val = synapseRecordFileManager.getSynapseRecordTotalInHour(day: day, hour: hour, type: type, isSave: false) {
                    cell.rightLabelMain.text = String(format:"%.2f", val)
                }

                var subStr: String = ""
                var records: [String]? = synapseRecordFileManager.getSynapseRecordValueTypeInHour(day: day, hour: hour, type: type, valueType: "min")
                if records != nil && records!.count > 0 {
                    let record: [String] = records![0].components(separatedBy: "_")
                    if record.count > 1, let val = Double(record[1]) {
                        subStr = String(format: self.makeStringFormat(type), val)
                    }
                }

                subStr = "\(subStr) - "
                records = synapseRecordFileManager.getSynapseRecordValueTypeInHour(day: day, hour: hour, type: type, valueType: "max")
                if records != nil && records!.count > 0 {
                    let record: [String] = records![0].components(separatedBy: "_")
                    if record.count > 1, let val = Double(record[1]) {
                        subStr = "\(subStr)\(String(format: self.makeStringFormat(type), val))"
                    }
                }

                if subStr != " - " {
                    cell.rightLabelMain.text = "\(cell.rightLabelMain.text!) ( \(subStr) )"
                }
            }
            return cell
        }
        else if indexPath.section == self.sections.count + 1, indexPath.row > 0, indexPath.row <= self.connectLogs.count {
            let dateFormatter: DateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm:ss"
            if let date = self.connectLogs[indexPath.row - 1]["S"] {
                cell.textLabel?.text = dateFormatter.string(from: date)
            }
            cell.textLabel?.text = "\(cell.textLabel!.text!) - "
            if let date = self.connectLogs[indexPath.row - 1]["E"] {
                cell.textLabel?.text = "\(cell.textLabel!.text!)\(dateFormatter.string(from: date))"
            }
        }
        return cell
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {

        if indexPath.section == 0 {
            return true
        }
        return false
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {

        if indexPath.section == 0, editingStyle == .delete {
            self.removeValuesFile()
        }
    }

    // MARK: mark - UITableViewDelegate methods

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

        if section <= self.sections.count + 1 {
            return 14.0 + 10.0 * 2
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        if section <= self.sections.count + 1 {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var w: CGFloat = tableView.frame.width
            var h: CGFloat = self.tableView(tableView, heightForHeaderInSection: section)
            let view: UIView = UIView()
            view.frame = CGRect(x: x, y: y, width: w, height: h)
            view.backgroundColor = #colorLiteral(red: 0.1098039216, green: 0.1098039216, blue: 0.1176470588, alpha: 1)

            x = 10.0
            w = tableView.frame.width - x * 2
            let label: UILabel = UILabel()
            label.text = ""
            if section == 0 {
                label.text = "Values File Size"
            }
            else if section <= self.sections.count {
                label.text = self.sections[section - 1].name
            }
            else if section == self.sections.count + 1 {
                label.text = "Connect Log"
            }
            label.frame = CGRect(x: x, y: y, width: w, height: h)
            label.textColor = #colorLiteral(red: 0.6823529412, green: 0.6823529412, blue: 0.6980392157, alpha: 1)
            //label.font = UIFont(name: "HiraKakuProN-W6", size: 14.0)
            if #available(iOS 8.2, *) {
                label.font = UIFont.systemFont(ofSize: 14.0, weight: .bold)
            }
            else {
                label.font = UIFont.systemFont(ofSize: 14.0)
            }
            label.numberOfLines = 1
            view.addSubview(label)

            x = 0
            y = h - 1.0
            w = tableView.frame.width
            h = 1.0
            let line: UIView = UIView()
            line.frame = CGRect(x: x, y: y, width: w, height: h)
            line.backgroundColor = #colorLiteral(red: 0.2823529412, green: 0.2823529412, blue: 0.2901960784, alpha: 1)
            view.addSubview(line)

            return view
        }
        return nil
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        if let day = self.day {
            if indexPath.section == 0 {
                return 14.0 + 10.0 * 2
            }
            else if indexPath.section <= self.sections.count, indexPath.row < 24, let synapseRecordFileManager = self.synapseRecordFileManager, synapseRecordFileManager.existsSynapseRecord(day: day, hour: String(format:"%02d", indexPath.row), min: nil, sec: nil, type: self.sections[indexPath.section - 1].key) {
                let cell: DebugTableViewCell = DebugTableViewCell()
                return cell.getCellHeight()
            }
            else if indexPath.section == self.sections.count + 1 {
                if indexPath.row > 0, indexPath.row <= self.connectLogs.count {
                    return 14.0 + 3.0 * 2
                }
                else {
                    return 7.0
                }
            }
        }
        return 0
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: false)

        if indexPath.section > 0, indexPath.section <= self.sections.count, indexPath.row < 24 {
            let vc: DebugDetailSubViewController = DebugDetailSubViewController()
            vc.uuid = self.uuid
            vc.day = self.day
            vc.hour = indexPath.row
            vc.crystalKey = self.sections[indexPath.section - 1].key
            vc.crystalName = self.sections[indexPath.section - 1].name
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

class DebugTableViewCell: UITableViewCell {

    let labelH: CGFloat = 24.0
    let fontSL: CGFloat = 14.0
    let fontSR: CGFloat = 14.0
    //let fontSR: CGFloat = 12.0
    var leftLabel: UILabel!
    var rightLabelMain: UILabel!
    var rightLabelSub: UILabel!
    var rightLabelSub2: UILabel!
    var lineView: UIView!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.setView()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    required init(coder aDecoder: NSCoder) {

        fatalError("init(coder: ) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.resizeView()
    }

    func setView() {

        self.leftLabel = UILabel()
        //self.leftLabel.font = UIFont(name: "HiraKakuProN-W6", size: self.fontSL)
        if #available(iOS 8.2, *) {
            self.leftLabel.font = UIFont.systemFont(ofSize: self.fontSL, weight: .bold)
        }
        else {
            self.leftLabel.font = UIFont.systemFont(ofSize: self.fontSL)
        }
        self.leftLabel.textAlignment = .center
        self.leftLabel.numberOfLines = 0
        self.contentView.addSubview(self.leftLabel)

        self.rightLabelMain = UILabel()
        self.rightLabelMain.textColor = UIColor.darkGray
        self.rightLabelMain.font = UIFont(name: "HiraKakuProN-W3", size: self.fontSR)
        /*if #available(iOS 8.2, *) {
            self.rightLabelMain.font = UIFont.systemFont(ofSize: self.fontSR, weight: .regular)
        }
        else {
            self.rightLabelMain.font = UIFont.systemFont(ofSize: self.fontSR)
        }*/
        self.rightLabelMain.textAlignment = .left
        self.rightLabelMain.numberOfLines = 1
        self.contentView.addSubview(self.rightLabelMain)

        self.rightLabelSub = UILabel()
        self.rightLabelSub.textColor = UIColor.darkGray
        self.rightLabelSub.font = UIFont(name: "HiraKakuProN-W3", size: self.fontSR)
        /*if #available(iOS 8.2, *) {
            self.rightLabelSub.font = UIFont.systemFont(ofSize: self.fontSR, weight: .regular)
        }
        else {
            self.rightLabelSub.font = UIFont.systemFont(ofSize: self.fontSR)
        }*/
        self.rightLabelSub.textAlignment = .left
        self.rightLabelSub.numberOfLines = 1
        self.contentView.addSubview(self.rightLabelSub)

        self.rightLabelSub2 = UILabel()
        self.rightLabelSub2.textColor = UIColor.darkGray
        self.rightLabelSub2.font = UIFont(name: "HiraKakuProN-W3", size: self.fontSR)
        /*if #available(iOS 8.2, *) {
            self.rightLabelSub2.font = UIFont.systemFont(ofSize: self.fontSR, weight: .regular)
        }
        else {
            self.rightLabelSub2.font = UIFont.systemFont(ofSize: self.fontSR)
        }*/
        self.rightLabelSub2.textAlignment = .left
        self.rightLabelSub2.numberOfLines = 1
        self.contentView.addSubview(self.rightLabelSub2)

        self.lineView = UIView()
        self.lineView.backgroundColor = UIColor.gray.withAlphaComponent(0.3)
        self.contentView.addSubview(self.lineView)
    }

    func resizeView() {

        let cellWidth: CGFloat = self.contentView.frame.size.width
        let cellHeight: CGFloat = self.contentView.frame.size.height

        var x: CGFloat = 0
        var y: CGFloat = 0
        var w: CGFloat = cellHeight
        var h: CGFloat = cellHeight
        self.leftLabel.frame = CGRect(x: x, y: y, width: w, height: h)

        x = self.leftLabel.frame.origin.x + self.leftLabel.frame.size.width + 10.0
        y = 10.0
        w = cellWidth - x
        h = self.fontSR
        self.rightLabelMain.frame = CGRect(x: x, y: y, width: w, height: h)

        y = self.rightLabelMain.frame.origin.y + self.rightLabelMain.frame.size.height
        w = 0
        h = 0
        self.rightLabelSub.frame = CGRect(x: x, y: y, width: w, height: h)

        y = self.rightLabelSub.frame.origin.y + self.rightLabelSub.frame.size.height
        self.rightLabelSub2.frame = CGRect(x: x, y: y, width: w, height: h)

        w = cellWidth + 60.0
        h = 1.0
        x = 0
        y = cellHeight - h
        self.lineView.frame = CGRect(x: x, y: y, width: w, height: h)
    }

    func getCellHeight() -> CGFloat {

        let height: CGFloat = self.fontSR + 10.0 * 2
        return height
    }
    /*
    func resizeView() {

        let cellWidth: CGFloat = self.contentView.frame.size.width
        let cellHeight: CGFloat = self.contentView.frame.size.height

        var x: CGFloat = 0
        var y: CGFloat = 0
        var w: CGFloat = 40.0
        var h: CGFloat = cellHeight
        self.leftLabel.frame = CGRect(x: x, y: y, width: w, height: h)

        x = self.leftLabel.frame.origin.x + self.leftLabel.frame.size.width + 10.0
        y = 5.0
        w = cellWidth - (self.leftLabel.frame.origin.x + self.leftLabel.frame.size.width + 10.0)
        h = self.fontSR
        /*h = 0
        if let _ = self.rightLabelMain.text {
            h = self.labelH
        }*/
        self.rightLabelMain.frame = CGRect(x: x, y: y, width: w, height: h)

        y = self.rightLabelMain.frame.origin.y + self.rightLabelMain.frame.size.height
        //h = (cellHeight - 2.0 * 2 - self.rightLabelMain.frame.size.height) / 2
        self.rightLabelSub.frame = CGRect(x: x, y: y, width: w, height: h)

        y = self.rightLabelSub.frame.origin.y + self.rightLabelSub.frame.size.height
        self.rightLabelSub2.frame = CGRect(x: x, y: y, width: w, height: h)

        w = cellWidth
        h = 1.0
        x = 0
        y = cellHeight - h
        self.lineView.frame = CGRect(x: x, y: y, width: w, height: h)
    }

    func getCellHeight() -> CGFloat {

        let height: CGFloat = self.fontSR * 3 + 5.0 * 2
        return height
    }
     */
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
