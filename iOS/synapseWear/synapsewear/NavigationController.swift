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

class NavigationController: UINavigationController, CommonFunctionProtocol {

    // variables
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

        //print("WiFi Address: \(String(describing: self.getWiFiAddress()))")
        if let isDebug = self.getAppinfoValue("is_debug") as? Bool {
            self.isDebug = isDebug
        }
        //self.setMenuList()

        SettingFileManager.shared.loadData()
    }
    /*
    func setMenuList() {

        if let menus = self.getAppinfoValue("menus") as? [Any] {
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
    }
     */

    // MARK: mark - Set Views methods

    func setView() {

        self.presetView()

        self.view.backgroundColor = UIColor.clear

        var x: CGFloat = 0
        var y: CGFloat = 0
        var w: CGFloat = self.view.frame.width
        var h: CGFloat = 20.0 + 44.0
        self.headerView = UIView()
        self.headerView.frame = CGRect(x: x, y: y, width: w, height: h)
        self.headerView.backgroundColor = UIColor.clear
        self.view.addSubview(self.headerView)

        x = 44.0
        y = 20.0
        w = self.headerView.frame.size.width - x * 2
        h = self.headerView.frame.size.height - y
        self.headerTitle = UILabel()
        self.headerTitle.frame = CGRect(x: x, y: y, width: w, height: h)
        self.headerTitle.backgroundColor = UIColor.clear
        self.headerTitle.textColor = UIColor.black
        self.headerTitle.font = UIFont(name: "HelveticaNeue", size: 18.0)
        self.headerTitle.textAlignment = .center
        self.headerTitle.numberOfLines = 1
        self.headerView.addSubview(self.headerTitle)

        x = 0
        w = 44.0
        self.headerMenuBtn = UIButton()
        self.headerMenuBtn.frame = CGRect(x: x, y: y, width: w, height: h)
        self.headerMenuBtn.backgroundColor = UIColor.clear
        self.headerMenuBtn.addTarget(self, action: #selector(NavigationController.menuAction), for: .touchUpInside)
        self.headerView.addSubview(self.headerMenuBtn)

        w = 20.0
        h = 16.0
        x = (self.headerMenuBtn.frame.size.width - w) / 2
        y = (self.headerMenuBtn.frame.size.height - h) / 2
        self.headerMenuIcon = HamburgerMenuView()
        self.headerMenuIcon.frame = CGRect(x: x, y: y, width: w, height: h)
        self.headerMenuIcon.backgroundColor = UIColor.clear
        self.headerMenuIcon.isUserInteractionEnabled = false
        self.headerMenuIcon.lineColor = UIColor.black
        self.headerMenuBtn.addSubview(self.headerMenuIcon)

        x = 0
        y = 20.0
        w = 44.0
        h = self.headerView.frame.size.height - y
        self.headerBackBtn = UIButton()
        self.headerBackBtn.frame = CGRect(x: x, y: y, width: w, height: h)
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
        self.headerBackForTopIcon.backgroundColor = UIColor.clear
        self.headerBackForTopIcon.isUserInteractionEnabled = false
        self.headerBackForTopIcon.lineColor = UIColor.white
        self.headerBackForTopBtn.addSubview(self.headerBackForTopIcon)

        w = 44.0
        x = self.headerView.frame.size.width - w
        y = 20.0
        h = self.headerView.frame.size.height - y
        self.headerSettingBtn = UIButton()
        self.headerSettingBtn.frame = CGRect(x: x, y: y, width: w, height: h)
        self.headerSettingBtn.backgroundColor = UIColor.clear
        self.headerSettingBtn.addTarget(self, action: #selector(NavigationController.settingAction), for: .touchUpInside)
        self.headerView.addSubview(self.headerSettingBtn)

        w = 24.0
        h = 24.0
        x = (self.headerSettingBtn.frame.size.width - w) / 2
        y = (self.headerSettingBtn.frame.size.height - h) / 2
        self.headerSettingIcon = UIImageView()
        self.headerSettingIcon.frame = CGRect(x: x, y: y, width: w, height: h)
        self.headerSettingIcon.image = UIImage.settingSB
        self.headerSettingIcon.backgroundColor = UIColor.clear
        self.headerSettingBtn.addSubview(self.headerSettingIcon)
    }

    func resizeView() {

        var baseY: CGFloat = 20.0
        if #available(iOS 11.0, *) {
            baseY = self.view.safeAreaInsets.top
        }
        var x: CGFloat = self.headerView.frame.origin.x
        var y: CGFloat = self.headerView.frame.origin.y
        var w: CGFloat = self.headerView.frame.size.width
        var h: CGFloat = baseY + 44.0
        self.headerView.frame = CGRect(x: x, y: y, width: w, height: h)

        x = self.headerTitle.frame.origin.x
        y = baseY
        w = self.headerTitle.frame.size.width
        h -= baseY
        self.headerTitle.frame = CGRect(x: x, y: y, width: w, height: h)

        x = self.headerMenuBtn.frame.origin.x
        w = self.headerMenuBtn.frame.size.width
        self.headerMenuBtn.frame = CGRect(x: x, y: y, width: w, height: h)

        x = self.headerBackBtn.frame.origin.x
        w = self.headerBackBtn.frame.size.width
        self.headerBackBtn.frame = CGRect(x: x, y: y, width: w, height: h)
        self.headerBackForTopBtn.frame = self.headerBackBtn.frame

        x = self.headerSettingBtn.frame.origin.x
        w = self.headerSettingBtn.frame.size.width
        self.headerSettingBtn.frame = CGRect(x: x, y: y, width: w, height: h)
    }

    func setHeaderBackIcon(isWhite: Bool = false) {

        if self.headerBackIcon != nil {
            self.headerBackIcon.removeFromSuperview()
            self.headerBackIcon = nil
        }

        let iconW: CGFloat = 11.0
        let iconH: CGFloat = 21.0
        let x: CGFloat = (self.headerBackBtn.frame.size.width - iconW) / 2
        let y: CGFloat = (self.headerBackBtn.frame.size.height - iconH) / 2
        self.headerBackIcon = BackView()
        self.headerBackIcon.frame = CGRect(x: x, y: y, width: iconW, height: iconH)
        self.headerBackIcon.backgroundColor = UIColor.clear
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
        self.headerSettingIcon.image = UIImage.settingSB
        self.headerSettingBtn.setTitleColor(UIColor.black, for: .normal)
        if isWhite {
            UIApplication.shared.statusBarStyle = .lightContent
            self.headerTitle.textColor = UIColor.white
            self.headerSettingIcon.image = UIImage.settingSW
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
            if let debugs = self.getAppinfoValue("debugs") as? [Any] {
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

    // MARK: mark - TopViewController methods

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

    func setOSCClient() {

        self.topVC.setOSCClient()
    }

    func getScanDevices() -> [RFduino] {

        return self.topVC.scanDevices
    }

    func setScanDevicesDelegate(_ delegate: DeviceScanningDelegate?) {

        self.topVC.deviceScanningDelegate = delegate
    }
}
