//
//  MenuViewController.swift
//  synapsewear
//
//  Copyright © 2017年 art and program, Inc. For license and other information refer to https://github.com/artandprogram/synapseWear. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    // variables
    var appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    var menuList: [Any] = []
    var debugList: [Any] = []
    var isDebug: Bool = false
    // views
    var menusTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setParam()
        self.setView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: mark - Set Variables methods

    func setParam() {
        /*
        if let menus = self.appDelegate.appinfo?["menus"] as? [Any] {
            for (_, element) in menus.enumerated() {
                if let dic = element as? [String: Any] {
                    self.menuList.append(dic)
                }
            }
        }
         */
        if let isDebug = self.appDelegate.appinfo?["is_debug"] as? Bool {
            self.isDebug = isDebug
            if let debugs = self.appDelegate.appinfo?["debugs"] as? [Any] {
                self.debugList = debugs
            }
        }
    }

    // MARK: mark - Set Views methods

    func setView() {

        self.view.backgroundColor = UIColor.clear

        let x:CGFloat = 0
        let y:CGFloat = 20.0
        var w:CGFloat = self.view.frame.width
        let h:CGFloat = self.view.frame.height - y
        if let parentViewController = parent as? MainViewController {
            w = parentViewController.menuW
        }

        self.menusTableView = UITableView()
        self.menusTableView.frame = CGRect(x: x, y: y, width: w, height: h)
        self.menusTableView.backgroundColor = UIColor.clear
        self.menusTableView.separatorStyle = UITableViewCellSeparatorStyle.none
        self.menusTableView.delegate = self
        self.menusTableView.dataSource = self
        self.view.addSubview(self.menusTableView)
    }

    // MARK: mark - UITableViewDataSource methods

    func numberOfSections(in tableView: UITableView) -> Int {

        let sections: Int = 2
        return sections
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if section == 0 {
            return self.menuList.count
        }
        else if section == 1 {
            if self.isDebug {
                return self.debugList.count
            }
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: "Cell")
        cell.backgroundColor = UIColor.clear
        //cell.selectionStyle = UITableViewCellSelectionStyle.none

        cell.textLabel?.textColor = UIColor.black
        cell.textLabel?.font = UIFont(name: "HelveticaNeue", size: 16)
        cell.textLabel?.text = ""
        if indexPath.section == 0 && indexPath.row < self.menuList.count {
            if let dic = self.menuList[indexPath.row] as? [String: Any] {
                if let name = dic["name"] as? String {
                    cell.textLabel?.text = name
                }
            }
        }
        else if indexPath.section == 1 {
            if indexPath.row < self.debugList.count {
                cell.textLabel?.text = "  \(String(describing: self.debugList[indexPath.row]))"
            }
        }
        return cell
    }

    // MARK: mark - UITableViewDelegate methods

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

        if section == 1 {
            if self.isDebug && self.debugList.count > 0 {
                return 40.0
            }
        }
        return 0
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        if section == 1 {
            if self.isDebug && self.debugList.count > 0 {
                let view: UIView = UIView()
                view.frame = CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: self.tableView(tableView, heightForHeaderInSection: section))
                view.backgroundColor = UIColor.clear

                let label: UILabel = UILabel()
                label.text = "Debug"
                label.frame = CGRect(x: 15.0, y: 0, width: view.frame.size.width - 15.0, height: view.frame.size.height)
                label.textColor = UIColor.black
                label.backgroundColor = UIColor.clear
                label.font = UIFont(name: "HelveticaNeue-Bold", size: 16)
                view.addSubview(label)

                return view
            }
        }
        return nil
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        if indexPath.section == 0 {
            return 40.0
        }
        else if indexPath.section == 1 {
            return 34.0
        }
        return 0
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: false)

        if indexPath.section == 0 && indexPath.row < self.menuList.count {
            if let parentViewController = parent as? MainViewController {
                parentViewController.changeMenu(indexPath)
            }
        }
        else if indexPath.section == 1 {
            if self.isDebug && indexPath.row < self.debugList.count {
                if let parentViewController = parent as? MainViewController {
                    parentViewController.changeMenu(indexPath)
                }
            }
        }
    }
}
