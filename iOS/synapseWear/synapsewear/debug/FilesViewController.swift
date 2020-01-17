//
//  FilesViewController.swift
//  synapsewear
//
//  Copyright © 2017 art and program, Inc. For license and other information refer to https://github.com/artandprogram/synapseWear. All rights reserved.
//

import UIKit

class FilesViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate, FileManagerExtension {

    var filepath: String = ""
    var files: [String] = []
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
                try self.files = FileManager.default.contentsOfDirectory(atPath: self.filepath)
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

        self.view.backgroundColor = UIColor.white

        self.filesView = UITableView()
        self.filesView.backgroundColor = UIColor.clear
        //self.tableView.contentInset = UIEdgeInsets(top: -20, left: 0, bottom: 0, right: 0)
        self.filesView.delegate = self
        self.filesView.dataSource = self
        self.view.addSubview(self.filesView)
    }

    override func resizeView() {
        super.resizeView()

        var baseY: CGFloat = 20.0
        if #available(iOS 11.0, *) {
            baseY = self.view.safeAreaInsets.top
        }
        let x: CGFloat = 0
        let y: CGFloat = baseY + 60.0
        let w: CGFloat = self.view.frame.width
        let h: CGFloat = self.view.frame.height - y
        self.filesView.frame = CGRect(x: x, y: y, width: w, height: h)
    }

    func isDirectory(_ directory: String) -> Bool {

        var isDir: ObjCBool = false
        if self.filepath.count > 0 {
            if directory.count > 0 {
                let path: String = "\(self.filepath)/\(directory)"
                let exists: Bool = FileManager.default.fileExists(atPath: path, isDirectory: &isDir)
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

    func getFileSize(_ directory: String) -> String {

        do {
            let path: String = "\(self.filepath)/\(directory)"
            let size: UInt64 = try self.findSize(path: path)
            return self.sizeToPrettyString(size: size)
            /*
            let attr: NSDictionary = try FileManager.default.attributesOfItem(atPath: path) as NSDictionary
            //print("fileSize: \(attr.fileSize())")

            let formatter: NumberFormatter = NumberFormatter()
            formatter.numberStyle = .decimal
            if let value: String = formatter.string(from: attr.fileSize() as NSNumber) {
                return "\(value) byte"
            }
             */
        }
        catch {
        }
        return ""
    }

    // MARK: mark - UITableViewDataSource methods

    func numberOfSections(in tableView: UITableView) -> Int {

        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return self.files.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell: UITableViewCell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        cell.backgroundColor = UIColor.clear

        cell.textLabel?.text = ""
        cell.textLabel?.font = UIFont(name: "HelveticaNeue", size: 14.0)
        cell.textLabel?.numberOfLines = 0
        if indexPath.row < self.files.count {
            cell.textLabel?.text = self.files[indexPath.row]
        }
        /*
        cell.detailTextLabel?.text = ""
        cell.detailTextLabel?.font = UIFont(name: "HelveticaNeue", size: 12.0)
        cell.detailTextLabel?.numberOfLines = 1
        if let text = cell.textLabel?.text, self.filepath.count > 0 {
            cell.detailTextLabel?.text = self.getFileSize(text)
        }
         */
        cell.accessoryType = .none
        if let text = cell.textLabel?.text, self.isDirectory(text) {
            cell.accessoryType = .disclosureIndicator
        }
        return cell
    }

    // MARK: mark - UITableViewDelegate methods

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

        let x: CGFloat = 10.0
        let y: CGFloat = 0
        let w: CGFloat = tableView.frame.width - x * 2
        var h: CGFloat = 0
        let label: UILabel = UILabel()
        label.frame = CGRect(x: x, y: y, width: w, height: h)
        label.text = self.filepath
        label.font = UIFont(name: "HelveticaNeue", size: 14.0)
        label.numberOfLines = 0
        label.sizeToFit()

        h = label.frame.size.height + 10.0 * 2
        if h > 44.0 {
            return h
        }
        return 44.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        var x: CGFloat = 0
        var y: CGFloat = 0
        var w: CGFloat = tableView.frame.width
        var h: CGFloat = self.tableView(tableView, heightForHeaderInSection: section)
        let view: UIView = UIView()
        view.frame = CGRect(x: x, y: y, width: w, height: h)
        view.backgroundColor = #colorLiteral(red: 0.8196078431, green: 0.8196078431, blue: 0.8392156863, alpha: 1)

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

        let x: CGFloat = 10.0
        let y: CGFloat = 0
        let w: CGFloat = tableView.frame.width - (x + 40.0)
        var h: CGFloat = 0
        let subH: CGFloat = 0
        //let subH: CGFloat = 12.0
        let label: UILabel = UILabel()
        label.frame = CGRect(x: x, y: y, width: w, height: h)
        label.font = UIFont(name: "HelveticaNeue", size: 14.0)
        label.numberOfLines = 0
        label.text = ""
        if indexPath.row < self.files.count {
            label.text = self.files[indexPath.row]
        }
        label.sizeToFit()

        h = label.frame.size.height + 5.0 * 2 + subH
        return h
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

enum FileErrors: Error {

    case BadEnumeration
    case BadResource
}

protocol FileManagerExtension {
}
extension FileManagerExtension {

    func findSize(path: String) throws -> UInt64 {

        let fullPath: String = (path as NSString).expandingTildeInPath
        let fileAttributes: NSDictionary = try FileManager.default.attributesOfItem(atPath: fullPath) as NSDictionary

        if fileAttributes.fileType() == "NSFileTypeRegular" {
            return fileAttributes.fileSize()
        }

        let url: URL = URL(fileURLWithPath: fullPath)
        guard let directoryEnumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: [URLResourceKey.fileSizeKey], options: [.skipsHiddenFiles], errorHandler: nil) else { throw FileErrors.BadEnumeration }

        var total: UInt64 = 0
        for (index, object) in directoryEnumerator.enumerated() {
            guard let fileURL = object as? NSURL else { throw FileErrors.BadResource }
            var fileSizeResource: AnyObject?
            try fileURL.getResourceValue(&fileSizeResource, forKey: URLResourceKey.fileSizeKey)
            guard let fileSize = fileSizeResource as? NSNumber else { continue }
            total += fileSize.uint64Value
            if index % 1000 == 0 {
                print(".", terminator: "")
            }
        }

        /*if total < 1048576 {
            total = 1
        }
        else {
            total = UInt64(total / 1048576)
        }*/

        return total
    }

    func sizeToPrettyString(size: UInt64) -> String {

        let byteCountFormatter: ByteCountFormatter = ByteCountFormatter()
        byteCountFormatter.allowedUnits = .useBytes
        byteCountFormatter.countStyle = .file
        return byteCountFormatter.string(fromByteCount: Int64(size))
    }
}
