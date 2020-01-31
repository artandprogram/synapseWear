//
//  DebugDetailSubViewController.swift
//  synapsewear
//
//  Copyright © 2019 art and program, Inc. For license and other information refer to https://github.com/artandprogram/synapseWear. All rights reserved.
//

import UIKit

class DebugDetailSubViewController: DebugBaseViewController {

    var uuid: UUID?
    var day: String?
    var hour: Int?
    var crystalKey: String?
    var crystalName: String?
    var values: [[Double]] = []
    var synapseRecordFileManager: SynapseRecordFileManager?

    override func setParam() {
        super.setParam()

        if let uuid = self.uuid, let day = self.day, let hour = self.hour, let crystalKey = self.crystalKey {
            self.synapseRecordFileManager = SynapseRecordFileManager()
            self.synapseRecordFileManager?.setSynapseId(uuid.uuidString)

            let hourStr: String = String(format:"%02d", hour)
            for i in 0..<60 {
                let minStr: String = String(format:"%02d", i)
                var value: [Double] = self.synapseRecordFileManager?.getSynapseRecordTotal(day: day, hour: hourStr, min: minStr, sec: nil, type: crystalKey) ?? []
                if value.count >= 2 {
                    var min: Double? = nil
                    var max: Double? = nil

                    if let records = self.synapseRecordFileManager?.getSynapseRecordValueType(day: day, hour: hourStr, min: minStr, type: crystalKey, valueType: "min"), records.count > 0 {
                        let separates: [String] = records[0].components(separatedBy: "_")
                        if separates.count > 1, let val = Double(separates[1]) {
                            min = val
                        }
                    }
                    if let records = self.synapseRecordFileManager?.getSynapseRecordValueType(day: day, hour: hourStr, min: minStr, type: crystalKey, valueType: "max"), records.count > 0 {
                        let separates: [String] = records[0].components(separatedBy: "_")
                        if separates.count > 1, let val = Double(separates[1]) {
                            max = val
                        }
                    }
                    if let min = min, let max = max {
                        value += [min, max]
                    }
                }
                self.values.append(value)
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
                if let hour = self.hour {
                    self.topLabel.text = "\(self.topLabel.text!) - \(String(format:"%02d", hour))hour"
                }
            }
        }
    }

    // MARK: mark - UITableViewDataSource methods

    func numberOfSections(in tableView: UITableView) -> Int {

        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return self.values.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.row < self.values.count {
            var cell: DebugSubTableViewCell = DebugSubTableViewCell(style: .default, reuseIdentifier: "DebugCell")
            if let reusableCell = tableView.dequeueReusableCell(withIdentifier: "DebugCell") as? DebugSubTableViewCell {
                cell = reusableCell
            }
            else {
                cell.backgroundColor = UIColor.clear
                cell.selectionStyle = .none
                cell.clipsToBounds = true
                cell.leftLabel.textColor = #colorLiteral(red: 0.6823529412, green: 0.6823529412, blue: 0.6980392157, alpha: 1)
                cell.leftLabel.backgroundColor = #colorLiteral(red: 0.2823529412, green: 0.2823529412, blue: 0.2901960784, alpha: 1)
                cell.rightLabelMain.textColor = #colorLiteral(red: 0.6823529412, green: 0.6823529412, blue: 0.6980392157, alpha: 1)
                cell.rightLabelSub.textColor = #colorLiteral(red: 0.6823529412, green: 0.6823529412, blue: 0.6980392157, alpha: 1)
                cell.rightLabelSub2.textColor = #colorLiteral(red: 0.6823529412, green: 0.6823529412, blue: 0.6980392157, alpha: 1)
                cell.lineView.backgroundColor = #colorLiteral(red: 0.2823529412, green: 0.2823529412, blue: 0.2901960784, alpha: 1)
            }

            cell.leftLabel.text = String(format:"%02d", indexPath.row)
            cell.rightLabelMain.text = "--"
            cell.rightLabelSub.text = "--"
            cell.rightLabelSub2.text = ""
            let value: [Double] = self.values[indexPath.row]
            if value.count >= 2 {
                cell.rightLabelMain.text = "\(String(format:"%.2f", value[1] / value[0])) ( \(String(format: self.makeStringFormat(self.crystalKey!), value[1])) / \(String(format:"%.0f", value[0])) )"

                if value.count >= 4 {
                    cell.rightLabelSub.text = "\(String(format: self.makeStringFormat(self.crystalKey!), value[2])) - \(String(format: self.makeStringFormat(self.crystalKey!), value[3]))"
                }
            }
            return cell
        }

        return super.tableView(tableView, cellForRowAt: indexPath)
    }

    // MARK: mark - UITableViewDelegate methods

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

        return 14.0 + 10.0 * 2
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

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
        if let crystalName = self.crystalName {
            label.text = crystalName
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

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        if indexPath.row < self.values.count {
            let cell: DebugSubTableViewCell = DebugSubTableViewCell()
            return cell.getCellHeight()
        }
        return 0
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: false)
    }
}

class DebugSubTableViewCell: DebugTableViewCell {

    override func resizeView() {

        let cellWidth: CGFloat = self.contentView.frame.size.width
        let cellHeight: CGFloat = self.contentView.frame.size.height

        var x: CGFloat = 0
        var y: CGFloat = 0
        var w: CGFloat = cellHeight
        var h: CGFloat = cellHeight
        self.leftLabel.frame = CGRect(x: x, y: y, width: w, height: h)

        x = self.leftLabel.frame.origin.x + self.leftLabel.frame.size.width + 10.0
        y = 4.0
        w = cellWidth - x
        h = self.fontSR + 2.0
        self.rightLabelMain.frame = CGRect(x: x, y: y, width: w, height: h)

        y = self.rightLabelMain.frame.origin.y + self.rightLabelMain.frame.size.height + 3.0
        self.rightLabelSub.frame = CGRect(x: x, y: y, width: w, height: h)

        y = self.rightLabelSub.frame.origin.y + self.rightLabelSub.frame.size.height
        w = 0
        h = 0
        self.rightLabelSub2.frame = CGRect(x: x, y: y, width: w, height: h)

        w = cellWidth
        h = 1.0
        x = 0
        y = cellHeight - h
        self.lineView.frame = CGRect(x: x, y: y, width: w, height: h)
    }

    override func getCellHeight() -> CGFloat {

        let height: CGFloat = (4.0 + self.fontSR + 2.0) * 2 + 3.0
        return height
    }
}
