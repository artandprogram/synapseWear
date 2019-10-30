//
//  DebugBaseViewController.swift
//  synapsewear
//
//  Copyright © 2019 art and program, Inc. For license and other information refer to https://github.com/artandprogram/synapseWear. All rights reserved.
//

import UIKit

class DebugBaseViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {

    let synapseCrystalInfo: SynapseCrystalStruct = SynapseCrystalStruct()
    var tableView: UITableView!
    var topLabelView: UIView!
    var topLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let nav = self.navigationController as? NavigationController {
            nav.headerTitle.text = "Debug"
            nav.headerSettingBtn.isHidden = true
            nav.setHeaderColor(isWhite: true)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        //print("DebugViewController viewWillDisappear")
        if let nav = self.navigationController as? NavigationController {
            nav.setHeaderColor(isWhite: false)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func setView() {
        super.setView()

        self.view.backgroundColor = #colorLiteral(red: 0.2274509804, green: 0.2274509804, blue: 0.2352941176, alpha: 1)

        self.tableView = UITableView()
        self.tableView.backgroundColor = UIColor.clear
        //self.tableView.separatorStyle = .none
        self.tableView.separatorInset = .zero
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.view.addSubview(self.tableView)

        self.topLabelView = UIView()
        self.topLabelView.backgroundColor = #colorLiteral(red: 0.1098039216, green: 0.1098039216, blue: 0.1176470588, alpha: 1)
        self.view.addSubview(self.topLabelView)

        self.topLabel = UILabel()
        self.topLabel.text = ""
        //self.topLabel.font = UIFont(name: "HiraKakuProN-W3", size: 14.0)
        if #available(iOS 8.2, *) {
            self.topLabel.font = UIFont.systemFont(ofSize: 14.0, weight: .regular)
        }
        else {
            self.topLabel.font = UIFont.systemFont(ofSize: 14.0)
        }
        self.topLabel.textColor = #colorLiteral(red: 0.6823529412, green: 0.6823529412, blue: 0.6980392157, alpha: 1)
        self.topLabel.numberOfLines = 0
        self.topLabelView.addSubview(self.topLabel)
    }

    override func resizeView() {
        super.resizeView()

        var x: CGFloat = 10.0
        var y: CGFloat = 10.0
        var w: CGFloat = self.view.frame.width - x * 2
        var h: CGFloat = 0
        self.topLabel.frame = CGRect(x: x, y: y, width: w, height: h)
        self.topLabel.sizeToFit()
        self.topLabel.frame.size.width = w

        var baseY: CGFloat = 20.0
        if #available(iOS 11.0, *) {
            baseY = self.view.safeAreaInsets.top
        }
        y = baseY + 44.0
        w = self.view.frame.width
        h = self.topLabel.frame.size.height + x * 2
        x = 0
        self.topLabelView.frame = CGRect(x: x, y: y, width: w, height: h)

        y = self.topLabelView.frame.origin.y + self.topLabelView.frame.size.height
        h = self.view.frame.height - y
        self.tableView.frame = CGRect(x: x, y: y, width: w, height: h)
    }

    func makeDateString(_ date: String) -> String {

        var text: String = ""
        if date.count >= 4 {
            text = date.substring(from: 0, to: 4)
            if date.count >= 6 {
                text = "\(text)/\(date.substring(from: 4, to: 6))"
                if date.count >= 8 {
                    text = "\(text)/\(date.substring(from: 6, to: 8))"
                }
            }
        }
        return text
    }

    func makeStringFormat(_ key: String) -> String {

        var format: String = "%.2f"
        if key == self.synapseCrystalInfo.co2.key ||
            key == self.synapseCrystalInfo.hum.key ||
            key == self.synapseCrystalInfo.ill.key ||
            key == self.synapseCrystalInfo.sound.key {
            format = "%.0f"
        }
        return format
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell: UITableViewCell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        cell.backgroundColor = UIColor.clear
        cell.selectionStyle = .none
        return cell
    }
}
