//
//  SettingBaseViewController.swift
//  synapsewear
//
//  Copyright © 2019 art and program, Inc. For license and other information refer to https://github.com/artandprogram/synapseWear. All rights reserved.
//

import UIKit

class SettingBaseViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate, CommonFunctionProtocol {

    var settingTableView: UITableView!

    override func setView() {
        super.setView()

        self.view.backgroundColor = UIColor.dynamicColor(light: UIColor.grayBGColor, dark: UIColor.black)

        self.settingTableView = UITableView()
        self.settingTableView.backgroundColor = UIColor.clear
        self.settingTableView.separatorStyle = .none
        self.settingTableView.delegate = self
        self.settingTableView.dataSource = self
        self.view.addSubview(self.settingTableView)
    }

    override func resizeView() {
        super.resizeView()

        let x: CGFloat = 0
        var y: CGFloat = 0
        let w: CGFloat = self.view.frame.width
        var h: CGFloat = self.view.frame.height
        if let nav = self.navigationController as? NavigationController {
            y = nav.headerView.frame.origin.y + nav.headerView.frame.size.height
            h -= y
        }
        self.settingTableView.frame = CGRect(x: x, y: y, width: w, height: h)
    }

    func getSettingTableViewCell(tableView: UITableView, identifier: String) -> SettingTableViewCell {

        var cell: SettingTableViewCell = SettingTableViewCell(style: .default, reuseIdentifier: identifier)
        if let reusableCell = tableView.dequeueReusableCell(withIdentifier: identifier) as? SettingTableViewCell {
            cell = reusableCell
        }
        return cell
    }

    func getLineCell(tableView: UITableView) -> UITableViewCell {

        let identifier: String = "line_cell"
        if let cell = tableView.dequeueReusableCell(withIdentifier: identifier) {
            return cell
        }
        else {
            let cell: UITableViewCell = UITableViewCell(style: .default, reuseIdentifier: identifier)
            cell.backgroundColor = UIColor.dynamicColor(light: UIColor.black.withAlphaComponent(0.1), dark: UIColor.white.withAlphaComponent(0.2))
            cell.selectionStyle = .none
            return cell
        }
    }

    func getLineCellHeight() -> CGFloat {

        return 1.0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        var cell: UITableViewCell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        if let reusableCell = tableView.dequeueReusableCell(withIdentifier: "Cell") {
            cell = reusableCell
        }
        cell.backgroundColor = UIColor.clear
        cell.selectionStyle = .none
        return cell
    }
}
