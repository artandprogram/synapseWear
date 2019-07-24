//
//  NavigationController.swift
//  synapsewear
//
//  Copyright © 2017年 art and program, Inc. For license and other information refer to https://github.com/artandprogram/synapseWear. All rights reserved.
//

import UIKit

protocol DeviceAssociatedDelegate: class {

    func changeDeviceAssociated(_ text: String)
}

class NavigationController: UINavigationController {

    // variables
    var appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    var nowMenu: IndexPath?
    var menuList: [Any] = []
    var topVC: TopViewController!
    var isDebug: Bool = false
    weak var daDelegate: DeviceAssociatedDelegate?
    // views
    var headerView: UIView!
    var headerTitle: UILabel!
    var headerMenuBtn: UIButton!
    var headerMenuIcon: HamburgerMenuView!
    var headerBackBtn: UIButton!
    var headerBackIcon: BackView!
    //var headerBackIcon: UIImageView!
    var headerBackForTopBtn: UIButton!
    var headerBackForTopIcon: BackView!
    //var headerBackForTopIcon: UIImageView!
    var headerSettingBtn: UIButton!
    var headerSettingIcon: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setParam()
        self.setView()

        self.setMainViewController()
        //self.changePage(IndexPath(row: 0, section: 0))
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.resizeView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: mark - Set Variables methods

    func setParam() {

        if let isDebug = self.appDelegate.appinfo?["is_debug"] as? Bool {
            self.isDebug = isDebug
        }
        //self.setMenuList()
    }
    /*
    func setMenuList() {

        if let menus = self.appDelegate.appinfo?["menus"] as? [Any] {
            for (_, element) in menus.enumerated() {
                if var dic = element as? [String: Any] {
                    var vcName: String = ""
                    if let className = dic["class"] as? String {
                        vcName = className
                    }
                    dic["vc"] = ViewControllersManager.makeViewController(vcName)
                    self.menuList.append(dic)
                }
            }
        }
        //print("menuList : \(self.menuList)")
    } */

    // MARK: mark - Set Views methods

    func setView() {

        self.presetView()

        self.view.backgroundColor = UIColor.clear

        let x: CGFloat = 0
        let y: CGFloat = 0
        let w: CGFloat = self.view.frame.width
        let h: CGFloat = 20.0 + 44.0

        self.headerView = UIView()
        self.headerView.frame = CGRect(x: x, y: y, width: w, height: h)
        self.headerView.backgroundColor = UIColor.clear
        self.view.addSubview(self.headerView)

        self.headerTitle = UILabel()
        self.headerTitle.frame = CGRect(x: 44.0, y: 20.0, width: self.headerView.frame.size.width - 44.0 * 2, height: self.headerView.frame.size.height - 20.0)
        self.headerTitle.backgroundColor = UIColor.clear
        self.headerTitle.textColor = UIColor.black
        self.headerTitle.font = UIFont(name: "HelveticaNeue", size: 18)
        self.headerTitle.textAlignment = NSTextAlignment.center
        self.headerTitle.numberOfLines = 1
        self.headerView.addSubview(self.headerTitle)

        self.headerMenuBtn = UIButton()
        self.headerMenuBtn.frame = CGRect(x: 0, y: 20.0, width: 44.0, height: self.headerView.frame.size.height - 20.0)
        self.headerMenuBtn.backgroundColor = UIColor.clear
        self.headerMenuBtn.addTarget(self, action: #selector(NavigationController.menuAction), for: .touchUpInside)
        self.headerView.addSubview(self.headerMenuBtn)

        self.headerMenuIcon = HamburgerMenuView()
        self.headerMenuIcon.frame = CGRect(x: (self.headerMenuBtn.frame.size.width - 20.0) / 2, y: (self.headerMenuBtn.frame.size.height - 16.0) / 2, width: 20.0, height: 16.0)
        self.headerMenuIcon.backgroundColor = .clear
        self.headerMenuIcon.isUserInteractionEnabled = false
        self.headerMenuIcon.lineColor = UIColor.black
        self.headerMenuBtn.addSubview(self.headerMenuIcon)

        self.headerBackBtn = UIButton()
        self.headerBackBtn.frame = CGRect(x: 0, y: 20.0, width: 44.0, height: self.headerView.frame.size.height - 20.0)
        self.headerBackBtn.backgroundColor = UIColor.clear
        self.headerBackBtn.addTarget(self, action: #selector(NavigationController.backViewController), for: .touchUpInside)
        self.headerView.addSubview(self.headerBackBtn)

        self.setHeaderBackIcon()

        self.headerBackForTopBtn = UIButton()
        self.headerBackForTopBtn.frame = self.headerBackBtn.frame
        self.headerBackForTopBtn.backgroundColor = UIColor.clear
        self.headerBackForTopBtn.addTarget(self, action: #selector(NavigationController.backForTopAction), for: .touchUpInside)
        self.headerView.addSubview(self.headerBackForTopBtn)

        self.headerBackForTopIcon = BackView()
        self.headerBackForTopIcon.frame = self.headerBackIcon.frame
        self.headerBackForTopIcon.backgroundColor = .clear
        self.headerBackForTopIcon.isUserInteractionEnabled = false
        self.headerBackForTopIcon.lineColor = UIColor.white
        self.headerBackForTopBtn.addSubview(self.headerBackForTopIcon)

        self.headerSettingBtn = UIButton()
        self.headerSettingBtn.frame = CGRect(x: self.headerView.frame.size.width - 44.0, y: 20.0, width: 44.0, height: self.headerView.frame.size.height - 20.0)
        self.headerSettingBtn.backgroundColor = UIColor.clear
        self.headerSettingBtn.addTarget(self, action: #selector(NavigationController.settingAction), for: .touchUpInside)
        self.headerView.addSubview(self.headerSettingBtn)

        self.headerSettingIcon = UIImageView()
        self.headerSettingIcon.frame = CGRect(x: (self.headerSettingBtn.frame.size.width - 24.0) / 2, y: (self.headerSettingBtn.frame.size.height - 24.0) / 2, width: 24.0, height: 24.0)
        self.headerSettingIcon.image = UIImage(named: "setting_b.png")
        self.headerSettingIcon.backgroundColor = UIColor.clear
        self.headerSettingBtn.addSubview(self.headerSettingIcon)
    }

    func resizeView() {

        var y: CGFloat = 20.0
        if #available(iOS 11.0, *) {
            y = self.view.safeAreaInsets.top
        }
        var h: CGFloat = y + 44.0
        self.headerView.frame = CGRect(x: self.headerView.frame.origin.x, y: self.headerView.frame.origin.y, width: self.headerView.frame.size.width, height: h)

        h -= y
        self.headerTitle.frame = CGRect(x: self.headerTitle.frame.origin.x, y: y, width: self.headerTitle.frame.size.width, height: h)
        self.headerMenuBtn.frame = CGRect(x: self.headerMenuBtn.frame.origin.x, y: y, width: self.headerMenuBtn.frame.size.width, height: h)
        self.headerBackBtn.frame = CGRect(x: self.headerBackBtn.frame.origin.x, y: y, width: self.headerBackBtn.frame.size.width, height: h)
        self.headerBackForTopBtn.frame = self.headerBackBtn.frame
        self.headerSettingBtn.frame = CGRect(x: self.headerSettingBtn.frame.origin.x, y: y, width: self.headerSettingBtn.frame.size.width, height: h)
    }

    func setHeaderBackIcon(isWhite: Bool = false) {

        if self.headerBackIcon != nil {
            self.headerBackIcon.removeFromSuperview()
            self.headerBackIcon = nil
        }

        let iconW: CGFloat = 11.0
        let iconH: CGFloat = 21.0
        self.headerBackIcon = BackView()
        self.headerBackIcon.frame = CGRect(x: (self.headerBackBtn.frame.size.width - iconW) / 2, y: (self.headerBackBtn.frame.size.height - iconH) / 2, width: iconW, height: iconH)
        self.headerBackIcon.backgroundColor = .clear
        self.headerBackIcon.isUserInteractionEnabled = false
        self.headerBackIcon.lineColor = UIColor.black
        if isWhite {
            self.headerBackIcon.lineColor = UIColor.white
        }
        self.headerBackBtn.addSubview(self.headerBackIcon)
    }

    func presetView() {

        UIApplication.shared.statusBarStyle = .default
        self.setNeedsStatusBarAppearanceUpdate()
        self.setNavigationBarHidden(true, animated: false)
    }

    func setHeaderColor(isWhite: Bool) {

        UIApplication.shared.statusBarStyle = .default
        self.headerTitle.textColor = UIColor.black
        self.headerSettingIcon.image = UIImage(named: "setting_b.png")
        self.headerSettingBtn.setTitleColor(UIColor.black, for: .normal)
        if isWhite {
            UIApplication.shared.statusBarStyle = .lightContent
            self.headerTitle.textColor = UIColor.white
            self.headerSettingIcon.image = UIImage(named: "setting.png")
            self.headerSettingBtn.setTitleColor(UIColor.white, for: .normal)
        }
        self.setHeaderBackIcon(isWhite: isWhite)
    }

    func checkHeaderButtons() {

        self.headerMenuBtn.isHidden = !self.isDebug
        //self.headerMenuBtn.isHidden = false
        self.headerBackBtn.isHidden = true
        if self.viewControllers.count > 1 {
            self.headerMenuBtn.isHidden = true
            self.headerBackBtn.isHidden = false
        }
        self.headerBackForTopBtn.isHidden = true
    }

    // MARK: mark - ViewControllers methods

    func setMainViewController() {

        self.topVC = TopViewController()
        self.viewControllers = [self.topVC]
    }

    func updateSynapseSetting() {

        self.topVC.sendSynapseSettingToDeviceStart(self.topVC.mainSynapseObject)
    }
    /*
    func updateSynapseId() {

        self.topVC.reconnectSynapse()
    }
     */
    func changePage(_ indexPath: IndexPath) {

        if let nowMenu = self.nowMenu {
            if indexPath == nowMenu && self.viewControllers.count == 1 {
                return
            }
        }

        if indexPath.section == 0 && indexPath.row < self.menuList.count {
            if var dic = self.menuList[indexPath.row] as? [String: Any] {
                if let vc = dic["vc"] as? BaseViewController {
                    self.nowMenu = indexPath
                    self.viewControllers = [vc]
                }
            }
        }
        else if indexPath.section == 1 {
            var debug: String = ""
            if let debugs = self.appDelegate.appinfo?["debugs"] as? [Any] {
                if indexPath.row < debugs.count {
                    debug = String(describing: debugs[indexPath.row])
                }
            }

            if debug == "Files" {
                let vc: FilesViewController = FilesViewController()
                self.pushViewController(vc, animated: true)
            }
        }
    }

    @objc func menuAction() {

        if let parentViewController = parent as? MainViewController {
            parentViewController.menuAction()
        }
    }

    @objc func backViewController() {

        if self.viewControllers.count > 1 {
            self.popViewController(animated: true)
        }
    }

    @objc func backForTopAction() {

        if self.viewControllers.count > 0 {
            if let vc = self.viewControllers[self.viewControllers.count - 1] as? TopViewController {
                vc.closeSynapseValuesViewAction()
            }
        }
    }

    @objc func settingAction() {

        let vc: SettingNavigationViewController = SettingNavigationViewController()
        vc.nav = self
        self.present(vc, animated: true, completion: nil)
    }

    // MARK: mark - Device Associated methods

    func checkDeviceAssociated() -> String {

        return self.topVC.mainSynapseObject.getDeviceStatus()
    }

    func changeDeviceAssociated() {

        self.daDelegate?.changeDeviceAssociated(self.checkDeviceAssociated())
    }
    /*
    func getDeviceList() -> [Any] {

        return self.topVC.rfduinos
    }*/

    func getDeviceUUID() -> UUID? {

        return self.topVC.mainSynapseObject.synapseUUID
    }

    func startDeviceScan() {

        self.topVC.isSynapseScanning = true
        self.topVC.startScan()
    }

    func stopDeviceScan() {

        self.topVC.isSynapseScanning = false
        self.topVC.stopScan()
    }

    func reconnectSynapse(uuid: UUID) {

        self.topVC.reconnectSynapse(self.topVC.mainSynapseObject, uuid: uuid)
    }

    func sendTimeIntervalToDevice() {

        self.topVC.sendTimeIntervalToDeviceStart(self.topVC.mainSynapseObject)
    }

    func sendSensorToDevice() {

        self.topVC.sendSensorToDeviceStart(self.topVC.mainSynapseObject)
    }

    func changeAudioSetting(play: Bool) {

        self.topVC.changeAudioSetting(synapseObject: self.topVC.mainSynapseObject, play: play)
    }

    func changeSynapseSendData() {

        self.topVC.mainSynapseObject.changeSynapseSendData()
    }

    func sendLEDFlashToDevice() {

        self.topVC.sendLEDFlashToDevice(self.topVC.mainSynapseObject)
    }
}
