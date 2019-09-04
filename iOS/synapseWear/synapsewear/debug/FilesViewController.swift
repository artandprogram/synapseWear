//
//  FilesViewController.swift
//  synapsewear
//
//  Copyright © 2017年 art and program, Inc. For license and other information refer to https://github.com/artandprogram/synapseWear. All rights reserved.
//

import UIKit

class FilesViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {

    public var filepath: String = ""
    var files: [String] = []
    let fileManager: FileManager = FileManager()
    var filesView: UITableView!


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let nav = self.navigationController as? NavigationController {
            nav.headerTitle.text = ""
            nav.headerSettingBtn.isHidden = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    override func setParam() {
        super.setParam()

        if self.filepath.count > 0 {
            do {
                try self.files = fileManager.contentsOfDirectory(atPath: self.filepath)
                self.files.sort { $1 < $0 }
            }
            catch {
                self.files = []
            }
        }
        else {
            self.files = ["caches", "documents", "tmp"]
        }
    }

    override func setView() {
        super.setView()

        self.view.backgroundColor = UIColor.lightGray

        let x:CGFloat = 0
        let y:CGFloat = 20.0 + 60.0
        let w:CGFloat = self.view.frame.width
        let h:CGFloat = self.view.frame.height - y
        self.filesView = UITableView()
        self.filesView.frame = CGRect(x: x, y: y, width: w, height: h)
        self.filesView.backgroundColor = UIColor.clear
        //self.tableView.contentInset = UIEdgeInsets(top: -20, left: 0, bottom: 0, right: 0)
        self.filesView.delegate = self
        self.filesView.dataSource = self
        self.view.addSubview(self.filesView)
    }

    func isDirectory(_ directory: String) -> Bool {

        var isDir: ObjCBool = false
        if self.filepath.count > 0 {
            if directory.count > 0 {
                let exists: Bool = fileManager.fileExists(atPath: "\(self.filepath)/\(directory)", isDirectory: &isDir)
                if !exists {
                    isDir = false
                }
            }
        }
        else {
            isDir = true
        }
        return isDir.boolValue
    }

    // MARK: mark - UITableViewDataSource methods

    func numberOfSections(in tableView: UITableView) -> Int {

        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return self.files.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell: UITableViewCell = UITableViewCell(style: .value1, reuseIdentifier: "Cell")
        cell.backgroundColor = UIColor.clear
        //cell.selectionStyle = UITableViewCellSelectionStyle.none

        cell.textLabel?.text = ""
        cell.textLabel?.font = UIFont(name: "HelveticaNeue", size: 14)
        cell.textLabel?.numberOfLines = 0
        if indexPath.row < self.files.count {
            cell.textLabel?.text = self.files[indexPath.row]
        }
        cell.accessoryType = .none
        if let text = cell.textLabel?.text {
            if self.isDirectory(text) {
                cell.accessoryType = .disclosureIndicator
            }
        }
        return cell
    }

    // MARK: mark - UITableViewDelegate methods

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

        let x:CGFloat = 10.0
        let y:CGFloat = 0
        let w:CGFloat = tableView.frame.width - x * 2
        let h:CGFloat = 0
        let label: UILabel = UILabel()
        label.frame = CGRect(x: x, y: y, width: w, height: h)
        label.text = self.filepath
        label.font = UIFont(name: "HelveticaNeue", size: 14.0)
        label.numberOfLines = 0
        label.sizeToFit()

        if label.frame.size.height + 10.0 * 2 > 44.0 {
            return label.frame.size.height + 10.0 * 2
        }
        return 44.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        var x:CGFloat = 0
        var y:CGFloat = 0
        var w:CGFloat = tableView.frame.width
        var h:CGFloat = self.tableView(tableView, heightForHeaderInSection: section)
        let view: UIView = UIView()
        view.frame = CGRect(x: x, y: y, width: w, height: h)
        view.backgroundColor = UIColor.white

        x = 10.0
        w = tableView.frame.width - x * 2
        let label: UILabel = UILabel()
        label.frame = CGRect(x: x, y: y, width: w, height: h)
        label.text = self.filepath
        label.font = UIFont(name: "HelveticaNeue", size: 14.0)
        label.numberOfLines = 0
        view.addSubview(label)

        x = 0
        y = h - 1.0
        w = tableView.frame.width
        h = 1.0
        let line: UIView = UIView()
        line.frame = CGRect(x: x, y: y, width: w, height: h)
        line.backgroundColor = UIColor.lightGray
        line.alpha = 0.3
        view.addSubview(line)

        return view
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        let x:CGFloat = 10.0
        let y:CGFloat = 0
        let w:CGFloat = tableView.frame.width - x * 2
        let h:CGFloat = 0
        let label: UILabel = UILabel()
        label.frame = CGRect(x: x, y: y, width: w, height: h)
        label.font = UIFont(name: "HelveticaNeue", size: 14.0)
        label.numberOfLines = 0
        label.text = ""
        if indexPath.row < self.files.count {
            label.text = self.files[indexPath.row]
        }
        label.sizeToFit()

        return label.frame.size.height + 10.0 * 2
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: false)

        var filepathNext: String = ""
        if indexPath.row < self.files.count {
            let filename: String = self.files[indexPath.row]
            if self.filepath.count <= 0 {
                if filename == "caches" {
                    filepathNext = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
                }
                else if filename == "documents" {
                    filepathNext = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                }
                else if filename == "tmp" {
                    filepathNext = NSTemporaryDirectory()
                }
            }
            else if self.isDirectory(filename) {
                filepathNext = "\(self.filepath)/\(filename)"
            }
            
        }

        if filepathNext.count > 0 {
            let vc: FilesViewController = FilesViewController()
            vc.filepath = filepathNext
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
