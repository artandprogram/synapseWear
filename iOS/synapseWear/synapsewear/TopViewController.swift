//
//  TopViewController.swift
//  synapsewear
//
//  Copyright © 2017 art and program, Inc. For license and other information refer to https://github.com/artandprogram/synapseWear. All rights reserved.
//

import UIKit
import SceneKit
import UserNotifications
import Alamofire
import SwiftyJSON

// MARK: structs

struct CrystalStruct {

    var key: String = ""
    var name: String = ""
    var hasGraph: Bool = false
    var graphColor: UIColor = UIColor.clear

    init(key: String, name: String, hasGraph: Bool, graphColor: UIColor) {

        self.key = key
        self.name = name
        self.hasGraph = hasGraph
        self.graphColor = graphColor
    }
}

struct SynapseCrystalStruct {

    var co2: CrystalStruct = CrystalStruct(key: "co2",
                                           name: "CO2",
                                           hasGraph: true,
                                           graphColor: UIColor.graphCO2)
    var temp: CrystalStruct = CrystalStruct(key: "temp",
                                            name: "temperature",
                                            hasGraph: true,
                                            graphColor: UIColor.graphTemp)
    var hum: CrystalStruct = CrystalStruct(key: "hum",
                                           name: "humidity",
                                           hasGraph: true,
                                           graphColor: UIColor.graphHumi)
    var ill: CrystalStruct = CrystalStruct(key: "ill",
                                           name: "illumination",
                                           hasGraph: true,
                                           graphColor: UIColor.graphIllu)
    var press: CrystalStruct = CrystalStruct(key: "press",
                                             name: "air pressure",
                                             hasGraph: true,
                                             graphColor: UIColor.graphAirP)
    var sound: CrystalStruct = CrystalStruct(key: "sound",
                                             name: "environmental sound",
                                             hasGraph: true,
                                             graphColor: UIColor.graphEnvS)
    var move: CrystalStruct = CrystalStruct(key: "move",
                                            name: "movement",
                                            hasGraph: false,
                                            graphColor: UIColor.graphMove)
    var ax: CrystalStruct = CrystalStruct(key: "ax",
                                          name: "ax",
                                          hasGraph: false,
                                          graphColor: UIColor.graphMove)
    var ay: CrystalStruct = CrystalStruct(key: "ay",
                                          name: "ay",
                                          hasGraph: false,
                                          graphColor: UIColor.graphMove)
    var az: CrystalStruct = CrystalStruct(key: "az",
                                          name: "az",
                                          hasGraph: false,
                                          graphColor: UIColor.graphMove)
    var angle: CrystalStruct = CrystalStruct(key: "angle",
                                             name: "angle",
                                             hasGraph: false,
                                             graphColor: UIColor.graphAngl)
    var gx: CrystalStruct = CrystalStruct(key: "gx",
                                          name: "gx",
                                          hasGraph: false,
                                          graphColor: UIColor.graphAngl)
    var gy: CrystalStruct = CrystalStruct(key: "gy",
                                          name: "gy",
                                          hasGraph: false,
                                          graphColor: UIColor.graphAngl)
    var gz: CrystalStruct = CrystalStruct(key: "gz",
                                          name: "gz",
                                          hasGraph: false,
                                          graphColor: UIColor.graphAngl)
    var volt: CrystalStruct = CrystalStruct(key: "volt",
                                            name: "voltage",
                                            hasGraph: true,
                                            graphColor: UIColor.graphVolt)
    var led: CrystalStruct = CrystalStruct(key: "led",
                                           name: "LED",
                                           hasGraph: false,
                                           graphColor: UIColor.clear)
    //var mag: CrystalStruct = CrystalStruct(key: "mag", name: "magnetic field", hasGraph: true, graphColor: UIColor.graphMagF)
}

// MARK: enums

enum SendMode {

    case I0
    case I1 // データ送信開始：0x02
    case I2 // データ送信停止: 0x03
    case I3 // 送信間隔確認・変更：0x04
    case I4 // センサー調整: 0x05
    case I5 // ファームウェアバージョン確認: 0x06
    case I6 // デバイス紐付け: 0x10
    case I7 // ファームウェアアップデート 0xfe
    case I8 // 強制ファームウェアアップデート: 0x11
    case I9 // 紐づけリセット：0x12

    case I5_3_4
}

enum TemperatureScaleKey: String {

    case celsius = "C"
    case fahrenheit = "F"
}

enum SynapseRecordTotalType: String {

    case axDiff = "ax_diff"
    case ayDiff = "ay_diff"
    case azDiff = "az_diff"
    case gxDiff = "gx_diff"
    case gyDiff = "gy_diff"
    case gzDiff = "gz_diff"
}

// MARK: protocol - DeviceScanningDelegate

protocol DeviceScanningDelegate: class {

    func scannedDevice()
}

// MARK: class - TopViewController

class TopViewController: BaseViewController, RFduinoManagerDelegate, RFduinoDelegate, F53OSCClientDelegate, F53OSCPacketDestination, SynapseSoundDelegate, CommonFunctionProtocol {

    // const variables
    let checkSynapseTime: TimeInterval = 0.1
    let updateSynapseViewTime: TimeInterval = 0.4
    let updateSynapseValuesViewTime: TimeInterval = 1.0
    let synapseDataMax: Int = 1 * 60 * 60
    let synapseDataKeepTime: TimeInterval = TimeInterval(30 * 24 * 60 * 60)
    let synapseOffColorTime: TimeInterval = TimeInterval(12 * 60 * 60)
    let scnPixelScale: Float = 0.002
    let pinchZoomDef: Float = 5.0
    let synapseGraphMaxCnt: Int = 5 * 2
    let synapseCrystalInfo: SynapseCrystalStruct = SynapseCrystalStruct()
    let accessKeysFileManager: AccessKeysFileManager = AccessKeysFileManager()
    //let synapseNotifications: AllSynapseNotifications = AllSynapseNotifications()
    // synapse data variables
    var synapseTimeInterval: TimeInterval = 0
    var synapseTimeIntervalBak: TimeInterval = 0
    var synapseDeviceName: String = ""
    var rfduinoManager: RFduinoManager!
    var scanDevices: [RFduino] = [] {
        didSet {
            if oldValue.count != scanDevices.count {
                self.deviceScanningDelegate?.scannedDevice()
            }
        }
    }
    weak var deviceScanningDelegate: DeviceScanningDelegate?
    var synapseValues: [String]!
    var mainSynapseObject: SynapseObject!
    var isSynapseScanning: Bool = false
    // synapse graph variables
    var synapseGraphs: [String]!
    var synapseGraphData: [String: [[Double]]] = [:]
    var synapseGraphNowDate: Date = Date()
    // synapse crystal variables
    var isSynapseAppActive: Bool = true
    var isUpdateViewActive: Bool = true
    var canUpdateCrystalView: Bool = true
    var canUpdateValuesView: Bool = true
    var updateSynapseViewTimeLast: TimeInterval?
    var updateSynapseValuesViewTimeLast: TimeInterval?
    var pinchZoomZ: Float = 0
    //var rotationValue: Float = 0.5
    var focusSynapseValue: String = ""
    var focusSynapsePt: Int = 0
    var canSwipeSynapseValuesView: Bool = true
    var swipeMode: Int = 0
    var touchesCount: Int = 0
    var firstTouch: UITouch?
    // audio variables
    var synapseSound: SynapseSound?
    var synapseSoundTimer: Timer?
    // scn views
    var scnView: SCNView!
    var cameraNode: SCNNode!
    var swipeModeButton: UIButton?
    var swipeModeLabel: UILabel?
    var cameraResetButton: UIButton?
    // values views
    var synapseValueLabels: AllSynapseValueLabels = AllSynapseValueLabels()
    var synapseValuesView: UIView!
    var synapseTabView: UIView!
    var synapseTabLabels: [String: UIView] = [:]
    var synapseDataView: UIView!
    var synapseDataLabels: [String: UIView] = [:]
    var nowValuesView: UIView!
    var graphAreaView: UIView!
    var graphImageView: UIImageView!
    var graphImageUnderView: UIView!
    //var graphImageSideView: UIView!
    var nowValueLabelY: CGFloat = 0
    var nowValueLabel: UILabel!
    var maxValueLabel: UILabel!
    var minValueLabel: UILabel!
    var graphScaleAreaView: UIView!
    var min0Label: UILabel!
    var min1Label: UILabel!
    var min2Label: UILabel!
    var min3Label: UILabel!
    var min4Label: UILabel!
    var synapseValuesAnalyzeButton: UIButton!
    var synapseValuesBackButton: UIButton!
    // status views
    var statusItems: [String] = []
    var statusValues: [String] = []
    var statusAreaBtn: UIButton!
    var statusView: UIView?
    var statusLabels: [UILabel] = []
    // OSC variables
    var oscSynapseObject: SynapseObject?
    var updateOSCSynapseViewTimeLast: TimeInterval?
    var updateOSCSynapseValuesViewTimeLast: TimeInterval?
    var oscServer: F53OSCServer?
    var oscClient: F53OSCClient?
    var oscSendMode: String = ""
    // TodayExtension variables
    var todayExtensionUpdating: Bool = false
    var todayExtensionGraphData: [Int] = []
    var todayExtensionLastTime: TimeInterval?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setRFduinoManager()
        self.setAudio()
        self.removeOldRecords()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.appearNavigationArea()

        if !self.isUpdateViewActive {
            self.updateSynapseViews()
        }
        self.isUpdateViewActive = true

        self.setOSCClient()
        self.setOSCRecvMode()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.disappearNavigationArea()

        self.isUpdateViewActive = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func setParam() {
        super.setParam()

        self.setNotificationCenter()

        if let flag = self.getAppinfoValue("use_osc_recv") as? Bool, flag {
            self.oscServer = F53OSCServer.init()
        }

        self.setSynapseValidKeys()
        self.setSynapseObject()
    }

    func setSynapseValidKeys() {

        self.synapseValues = [
            self.synapseCrystalInfo.co2.key,
            self.synapseCrystalInfo.temp.key,
            self.synapseCrystalInfo.press.key,
            self.synapseCrystalInfo.move.key,
            self.synapseCrystalInfo.angle.key,
            self.synapseCrystalInfo.ill.key,
            self.synapseCrystalInfo.hum.key,
            self.synapseCrystalInfo.sound.key,
            //self.synapseCrystalInfo.mag.key,
        ]

        self.synapseGraphs = []
        if self.synapseCrystalInfo.co2.hasGraph {
            self.synapseGraphs.append(self.synapseCrystalInfo.co2.key)
        }
        if self.synapseCrystalInfo.temp.hasGraph {
            self.synapseGraphs.append(self.synapseCrystalInfo.temp.key)
        }
        if self.synapseCrystalInfo.press.hasGraph {
            self.synapseGraphs.append(self.synapseCrystalInfo.press.key)
        }
        if self.synapseCrystalInfo.move.hasGraph {
            self.synapseGraphs.append(self.synapseCrystalInfo.ax.key)
            self.synapseGraphs.append(self.synapseCrystalInfo.ay.key)
            self.synapseGraphs.append(self.synapseCrystalInfo.az.key)
        }
        if self.synapseCrystalInfo.angle.hasGraph {
            self.synapseGraphs.append(self.synapseCrystalInfo.gx.key)
            self.synapseGraphs.append(self.synapseCrystalInfo.gy.key)
            self.synapseGraphs.append(self.synapseCrystalInfo.gz.key)
        }
        if self.synapseCrystalInfo.ill.hasGraph {
            self.synapseGraphs.append(self.synapseCrystalInfo.ill.key)
        }
        if self.synapseCrystalInfo.hum.hasGraph {
            self.synapseGraphs.append(self.synapseCrystalInfo.hum.key)
        }
        if self.synapseCrystalInfo.sound.hasGraph {
            self.synapseGraphs.append(self.synapseCrystalInfo.sound.key)
        }
        if self.synapseCrystalInfo.volt.hasGraph {
            //self.synapseGraphs.append(self.synapseCrystalInfo.volt.key)
        }
        /*if self.synapseCrystalInfo.mag.hasGraph {
            self.synapseGraphs.append("mx")
            self.synapseGraphs.append("my")
            self.synapseGraphs.append("mz")
        }*/
    }

    func setSynapseObject() {

        self.synapseDeviceName = ""
        if let name = self.getAppinfoValue("device_name") as? String {
            self.synapseDeviceName = name
        }

        self.mainSynapseObject = SynapseObject("main")
        self.mainSynapseObject.synapseCrystalNode.rotateSynapseNodeDuration = self.updateSynapseViewTime
        self.mainSynapseObject.synapseCrystalNode.rotateCrystalNodeDuration = self.updateSynapseViewTime
        self.mainSynapseObject.synapseCrystalNode.scaleSynapseNodeDuration = self.updateSynapseViewTime
        self.mainSynapseObject.offColorTime = self.synapseOffColorTime
        if let uuid = self.accessKeysFileManager.getLatestUUID() {
            //print("getLatestUUID: \(uuid)")
            self.mainSynapseObject.setSynapseUUID(uuid)
            self.mainSynapseObject.changeSynapseSendData()
        }
    }

    override func setView() {
        super.setView()

        let colorS: UIColor = UIColor(red: 139/255.0, green: 139/255.0, blue: 139/255.0, alpha: 1)
        let colorE: UIColor = UIColor(red: 200/255.0, green: 200/255.0, blue: 200/255.0, alpha: 1)
        let bgLayer: CAGradientLayer = CAGradientLayer()
        bgLayer.colors = [colorS.cgColor, colorE.cgColor]
        bgLayer.startPoint = CGPoint(x: 0.5, y: 0)
        bgLayer.endPoint = CGPoint(x: 0.5, y: 1)
        bgLayer.frame = self.view.frame
        self.view.layer.addSublayer(bgLayer)
        self.view.backgroundColor = UIColor.clear

        self.setNavigationArea()
        self.setSceneView()
        self.setSynapseValuesView()
        self.initStatusView()
    }

    override func resizeView() {
        super.resizeView()
    }

    func setNavigationArea() {

        if let nav = self.navigationController as? NavigationController {
            self.cameraResetButton = UIButton()
            self.cameraResetButton?.frame = CGRect(x: nav.headerTitle.frame.origin.x,
                                                   y: nav.headerTitle.frame.origin.y,
                                                   width: nav.headerTitle.frame.size.width,
                                                   height: nav.headerTitle.frame.size.height)
            self.cameraResetButton?.backgroundColor = UIColor.clear
            self.cameraResetButton?.addTarget(self,
                                              action: #selector(self.resetCameraNodePosition),
                                              for: .touchUpInside)
            nav.headerView.addSubview(self.cameraResetButton!)
        }
    }

    func appearNavigationArea() {

        if let nav = self.navigationController as? NavigationController {
            nav.headerTitle.text = "Home"

            if self.synapseValuesView.isHidden {
                nav.setHeaderColor(isWhite: false)
            }
            else {
                nav.setHeaderColor(isWhite: true)
            }

            if !self.synapseValuesView.isHidden {
                nav.headerMenuBtn.isHidden = true
                nav.headerBackForTopBtn.isHidden = false
            }
        }
        self.cameraResetButton?.isHidden = false
    }

    func disappearNavigationArea() {

        self.cameraResetButton?.isHidden = true
    }

    func setNavigatioHeaderColor(isWhite: Bool) {

        if let nav = self.navigationController as? NavigationController {
            nav.setHeaderColor(isWhite: isWhite)
        }
    }

    func setNavigatioHeaderMenuBtn() {

        if let nav = self.navigationController as? NavigationController {
            if let isDebug = self.getAppinfoValue("is_debug") as? Bool, isDebug {
                nav.headerMenuBtn.isHidden = false
            }
            nav.headerBackForTopBtn.isHidden = true
        }
    }

    func darkmodeCheck() {

        if let nav = self.navigationController as? NavigationController, nav.viewControllers.count == 1, !nav.isSetting {
            if !self.synapseValuesView.isHidden {
                nav.setHeaderColor(isWhite: true)
            }
            else {
                nav.setHeaderColor(isWhite: false)
            }
        }
    }

    // MARK: mark - NotificationCenter methods

    func setNotificationCenter() {

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(type(of: self).applicationDidBecomeActiveNotified(notification:)),
                                               name: .UIApplicationDidBecomeActive,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(type(of: self).applicationWillResignActiveNotified(notification:)),
                                               name: .UIApplicationWillResignActive,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(type(of: self).applicationWillTerminateNotified(notification:)),
                                               name: .UIApplicationWillTerminate,
                                               object: nil)
    }

    @objc func applicationDidBecomeActiveNotified(notification: Notification) {

        //print("TopViewController applicationDidBecomeActiveNotified")
        self.isSynapseAppActive = true

        if self.mainSynapseObject.synapseValues.isConnected {
            self.resendSynapseSettingToDeviceStart(self.mainSynapseObject)
        }

        if self.canUpdateValuesView {
            if self.mainSynapseObject.synapseValues.isConnected {
                self.setSynapseGraphData(synapseObject: self.mainSynapseObject)
                /*self.resetSynapseGraphImage()
                self.setSynapseGraphImage(synapseObject: self.mainSynapseObject)*/
            }
        }
    }

    @objc func applicationWillResignActiveNotified(notification: Notification) {

        //print("TopViewController applicationWillResignActiveNotified")
        self.isSynapseAppActive = false

        if self.mainSynapseObject.synapseValues.isConnected {
            self.resendSynapseSettingToDeviceStart(self.mainSynapseObject)
        }
    }

    @objc func applicationWillTerminateNotified(notification: Notification) {

        if self.mainSynapseObject.synapseValues.isConnected {
            self.mainSynapseObject.disconnectSynapse()
        }
    }

    // MARK: mark - SceneView methods

    func setSceneView() {

        var x: CGFloat = 0
        var y: CGFloat = 0
        var w: CGFloat = self.view.frame.size.width
        var h: CGFloat = self.view.frame.size.height - y
        self.scnView = SCNView()
        self.scnView.frame = CGRect(x: x, y: y, width: w, height: h)
        self.scnView.backgroundColor = UIColor.clear
        self.scnView.autoenablesDefaultLighting = true
        self.scnView.scene = SCNScene()
        self.view.addSubview(scnView)

        self.cameraNode = SCNNode()
        self.cameraNode.name = "cameraNode"
        self.cameraNode.camera = SCNCamera()
        self.cameraNode.position = SCNVector3(x: 0, y: 0, z: self.pinchZoomDef)
        self.scnView.scene?.rootNode.addChildNode(self.cameraNode)

        self.mainSynapseObject.synapseCrystalNode.setSynapseNodes(scnView: self.scnView, position: nil)
        self.mainSynapseObject.resetSynapseNode()

        w = 80.0
        h = 40.0
        x = 0
        y = self.view.frame.size.height - (h + 20.0)
        self.swipeModeButton = UIButton()
        self.swipeModeButton?.frame = CGRect(x: x, y: y, width: w, height: h)
        self.swipeModeButton?.setTitle("Mode1", for: .normal)
        self.swipeModeButton?.setTitleColor(UIColor.black, for: .normal)
        self.swipeModeButton?.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 16.0)
        self.swipeModeButton?.backgroundColor = UIColor.clear
        self.swipeModeButton?.addTarget(self,
                                        action: #selector(self.changeSwipeMode),
                                        for: .touchUpInside)
        self.view.addSubview(self.swipeModeButton!)

        w = 80.0
        h = 20.0
        x = 0
        y = self.view.frame.size.height - (h + 10.0)
        self.swipeModeLabel = UILabel()
        self.swipeModeLabel?.frame = CGRect(x: x, y: y, width: w, height: h)
        self.swipeModeLabel?.text = ""
        self.swipeModeLabel?.textColor = UIColor.black
        self.swipeModeLabel?.backgroundColor = UIColor.clear
        self.swipeModeLabel?.font = UIFont(name: "HelveticaNeue", size: 16.0)
        self.swipeModeLabel?.textAlignment = NSTextAlignment.center
        self.swipeModeLabel?.numberOfLines = 1
        self.swipeModeLabel?.isHidden = true
        self.view.addSubview(self.swipeModeLabel!)
        // close swipe mode
        self.swipeModeButton?.isHidden = true
        self.swipeModeLabel?.isHidden = true

        self.scnView.addGestureRecognizer(UIPinchGestureRecognizer(target: self,
                                                                   action: #selector(self.sceneViewPinchAction(_:))))

        //self.lineNodeViewForSceneViewDebug()
    }

    func checkDisplaySynapseNodes() {

        //print("checkDisplaySynapseNodes")
        if self.mainSynapseObject.synapseCrystalNode.mainNodeRoll != nil {
            self.checkDisplaySynapseNode(self.mainSynapseObject.synapseCrystalNode)
        }
        if let oscSynapseObject = self.oscSynapseObject, oscSynapseObject.synapseCrystalNode.mainNodeRoll != nil {
            self.checkDisplaySynapseNode(oscSynapseObject.synapseCrystalNode)
        }
    }

    func checkDisplaySynapseNode(_ synapseCrystalNode: SynapseCrystalNodes) {

        let disX: Float = fabs(self.cameraNode.position.x - synapseCrystalNode.position.x)
        let disY: Float = fabs(self.cameraNode.position.y - synapseCrystalNode.position.y)
        let lenX: Float = self.scnPixelScale * self.cameraNode.position.z * Float(self.scnView.frame.size.width / 2)
        let lenY: Float = self.scnPixelScale * self.cameraNode.position.z * Float(self.scnView.frame.size.height / 2)

        synapseCrystalNode.isDisplay = false
        if disX < lenX && disY < lenY {
            synapseCrystalNode.isDisplay = true
        }
    }

    func lineNodeViewForSceneViewDebug() {

        let line0Pyramid: SCNBox = SCNBox(width: 0.01, height: 20.0, length: 0.01, chamferRadius: 0.0)
        let line0Node: SCNNode = SCNNode(geometry: line0Pyramid)
        line0Node.position = SCNVector3(x: 0, y: 0, z: 0)
        self.scnView.scene?.rootNode.addChildNode(line0Node)

        let cnt: Int = 5
        let scale: Float = 1.0
        for i in 1..<cnt {
            let linePPyramid: SCNBox = SCNBox(width: 0.01, height: 20.0, length: 0.01, chamferRadius: 0.0)
            let linePNode: SCNNode = SCNNode(geometry: linePPyramid)
            linePNode.position = SCNVector3(x: scale * Float(i), y: 0, z: 0)
            self.scnView.scene?.rootNode.addChildNode(linePNode)

            let lineMPyramid: SCNBox = SCNBox(width: 0.01, height: 20.0, length: 0.01, chamferRadius: 0.0)
            let lineMNode: SCNNode = SCNNode(geometry: lineMPyramid)
            lineMNode.position = SCNVector3(x: -scale * Float(i), y: 0, z: 0)
            self.scnView.scene?.rootNode.addChildNode(lineMNode)
        }
    }

    // MARK: mark - Touche Action methods

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        //print("touches: \(String(describing: event?.allTouches?.count))")
        self.touchesCount = 0
        self.firstTouch = nil
        if let touches = event?.allTouches {
            self.touchesCount = touches.count
            if self.touchesCount == 1 {
                self.canUpdateCrystalView = false
                if let touch = touches.first {
                    self.firstTouch = touch
                }
            }
        }
        /*
        let touchEvent = touches.first!
        print("touchesBegan x:\(touchEvent.location(in: self.scnView).x) y:\(touchEvent.location(in: self.scnView).y)")
         */
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {

        self.firstTouch = nil
        if !self.synapseValuesView.isHidden {
            return
        }

        let touchEvent: UITouch = touches.first!
        //print("touchesMoved x:\(touchEvent.previousLocation(in: self.view).x) y:\(touchEvent.previousLocation(in: self.view).y) -> x:\(touchEvent.location(in: self.view).x) y:\(touchEvent.location(in: self.view).y)")
        if (self.swipeMode == 0 && self.touchesCount == 1) || self.swipeMode == 1 {
            if self.mainSynapseObject.synapseCrystalNode.isDisplay {
                self.touchesSingleAction(touchEvent, synapseCrystalNode: self.mainSynapseObject.synapseCrystalNode)
            }
            else if let oscSynapseObject = self.oscSynapseObject, oscSynapseObject.synapseCrystalNode.isDisplay {
                self.touchesSingleAction(touchEvent, synapseCrystalNode: oscSynapseObject.synapseCrystalNode)
            }
        }
        /*
        // close swipe mode
        else if (self.swipeMode == 0 && self.touchesCount > 1) || self.swipeMode == 2 {
            self.touchesMultiAction(touchEvent)
            self.checkDisplaySynapseNodes()
        }*/
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {

        self.touchesCount = 0
        self.canUpdateCrystalView = true
        /*
        let touchEvent = touches.first!
        print("touchesEnded x:\(touchEvent.location(in: self.scnView).x) y:\(touchEvent.location(in: self.scnView).y)")*/

        if let firstTouch = self.firstTouch, let endTouch = touches.first {
            let locationF: CGPoint = firstTouch.location(in: self.scnView)
            let locationE: CGPoint = endTouch.location(in: self.scnView)
            if locationF == locationE {
                let hits: [SCNHitTestResult] = self.scnView.hitTest(locationF, options: nil)
                if let name = hits.first?.node.name {
                    //print("hitNode: \(name)")
                    self.redirectCameraNodePosition(name: name)
                    /*
                    let names: [String] = name.components(separatedBy: "_")
                    let key: String = names[0]
                    if key == self.mainSynapseObject.synapseCrystalNode.name {
                        self.sendLEDFlashToDevice(self.mainSynapseObject)
                    }*/
                }
            }
        }
        self.firstTouch = nil
    }

    func touchesSingleAction(_ touchEvent: UITouch, synapseCrystalNode: SynapseCrystalNodes) {

        let preDx: CGFloat = touchEvent.previousLocation(in: self.view).x
        let preDy: CGFloat = touchEvent.previousLocation(in: self.view).y
        let newDx: CGFloat = touchEvent.location(in: self.view).x
        let newDy: CGFloat = touchEvent.location(in: self.view).y
        let dx: CGFloat = (newDx - preDx) * 0.5
        let dy: CGFloat = (newDy - preDy) * 0.5
        //print("touchesMoved x:\(dx) y:\(dy)")
        self.mainSynapseObject.synapseCrystalNode.rotateSynapseNodes(dx: dx, dy: dy)
    }

    func touchesMultiAction(_ touchEvent: UITouch) {

        let preDx: CGFloat = touchEvent.previousLocation(in: self.view).x
        let preDy: CGFloat = touchEvent.previousLocation(in: self.view).y
        let newDx: CGFloat = touchEvent.location(in: self.view).x
        let newDy: CGFloat = touchEvent.location(in: self.view).y
        let dx: CGFloat = (newDx - preDx) / self.view.frame.size.width * CGFloat(self.cameraNode.position.z)
        let dy: CGFloat = (newDy - preDy) / self.view.frame.size.height * CGFloat(self.cameraNode.position.z)
        //print("touchesMultiAction x:\(dx) y:\(dy) preDx:\(preDx) preDy:\(preDy)")
        let x: Float = self.cameraNode.position.x - Float(dx)
        let y: Float = self.cameraNode.position.y + Float(dy)
        let z: Float = self.cameraNode.position.z
        self.cameraNode.position = SCNVector3(x: x, y: y, z: z)
        //print("cameraNode.position x:\(self.cameraNode.position.x) y:\(self.cameraNode.position.y) z:\(self.cameraNode.position.z)")
    }

    // MARK: mark - Pinch Action methods

    @objc func sceneViewPinchAction(_ sender: UIPinchGestureRecognizer) {

        if sender.state == .began {
            //print("pinch: \(sender.scale) -> began")
            self.pinchZoomZ = self.cameraNode.position.z
        }
        else if sender.state == .changed {
            //print("pinch: \(sender.scale) -> changed")
            if self.synapseValuesView.isHidden {
                let x: Float = self.cameraNode.position.x
                let y: Float = self.cameraNode.position.y
                let z: Float = self.pinchZoomZ / Float(sender.scale)
                self.cameraNode.position = SCNVector3(x: x, y: y, z: z)
                self.checkDisplaySynapseNodes()

                if self.swipeMode != 0 {
                    self.checkCameraZoom()
                }

                let crystalNames: [String]? = self.checkSynapseCrystalFocus()
                if let names = crystalNames {
                    var synapseValues: SynapseValues? = nil
                    if names[0] == self.mainSynapseObject.synapseValues.name {
                        synapseValues = self.mainSynapseObject.synapseValues
                    }
                    else if let oscSynapseObject = self.oscSynapseObject, names[0] == oscSynapseObject.synapseValues.name {
                        synapseValues = oscSynapseObject.synapseValues
                    }
                    if let synapseValues = synapseValues {
                        self.canUpdateCrystalView = false

                        self.synapseValueLabels.name = synapseValues.name
                        self.focusSynapseValue = names[1]

                        self.resetSynapseGraphImage()
                        if synapseValues.name == self.mainSynapseObject.synapseValues.name {
                            self.displaySynapseValuesView(synapseObject: self.mainSynapseObject)
                            self.updateSynapseValuesViewTimeLast = Date().timeIntervalSince1970
                        }
                        else {
                            self.displaySynapseValuesView(synapseObject: nil)
                            self.updateOSCSynapseValuesViewTimeLast = Date().timeIntervalSince1970
                        }
                        self.updateSynapseValuesView(synapseValues: synapseValues)

                        self.synapseValuesView.alpha = 0
                        self.synapseValuesView.isHidden = false
                        self.canUpdateValuesView = !self.synapseValuesView.isHidden
                        self.synapseValuesAnalyzeButton.isHidden = true
                        if synapseValues.name == self.mainSynapseObject.synapseValues.name {
                            self.synapseValuesAnalyzeButton.isHidden = false
                        }

                        if let nav = self.navigationController as? NavigationController {
                            nav.headerMenuBtn.isHidden = true
                            nav.headerBackForTopBtn.isHidden = false
                        }

                        self.statusAreaBtn.isHidden = true

                        UIView.animate(withDuration: 0.1,
                                       delay: 0,
                                       options: .curveEaseIn,
                                       animations: { () -> Void in
                            self.synapseValuesView.alpha = 1
                        }, completion: { _ in
                            self.setNavigatioHeaderColor(isWhite: true)
                        })
                    }
                }
            }
        }
        else if sender.state == .ended {
            //print("pinch: \(sender.scale) -> ended")
            if self.synapseValuesView.isHidden {
                self.canUpdateCrystalView = true
            }
        }
    }

    func checkSynapseCrystalFocus() -> [String]? {

        let zPos: Float = -1.5
        let hitFrom: SCNVector3 = SCNVector3(x: self.cameraNode.position.x,
                                             y: self.cameraNode.position.y,
                                             z: self.cameraNode.position.z)
        let hitTo: SCNVector3 = SCNVector3(x: self.cameraNode.position.x,
                                           y: self.cameraNode.position.y,
                                           z: self.cameraNode.position.z + zPos)
        let hitResults: [SCNHitTestResult]? = self.scnView.scene?.rootNode.hitTestWithSegment(from: hitFrom, to: hitTo, options: nil)

        var crystalNames: [String]? = nil
        if let hitResult = hitResults?.first {
            //print("hitNode: \(String(describing: hitResult))")
            if let name = hitResult.node.name {
                let names: [String] = name.components(separatedBy: "_")
                if names.count > 1 {
                    crystalNames = names
                }
            }
        }
        return crystalNames
    }

    func redirectCameraNodePosition(name: String) {

        let names: [String] = name.components(separatedBy: "_")
        let key: String = names[0]
        var vector3: SCNVector3? = nil
        if key == self.mainSynapseObject.synapseCrystalNode.name {
            vector3 = self.mainSynapseObject.synapseCrystalNode.position
        }
        else if let oscSynapseObject = self.oscSynapseObject, key == oscSynapseObject.synapseCrystalNode.name {
            vector3 = oscSynapseObject.synapseCrystalNode.position
        }
        if var position = vector3 {
            position.z = self.pinchZoomDef
            let action: SCNAction = SCNAction.move(to: position, duration: 0.1)
            self.cameraNode.runAction(action, completionHandler: {
                self.canUpdateCrystalView = true
                DispatchQueue.main.async {
                    self.checkDisplaySynapseNodes()
                }
            })

            if self.swipeMode != 0 {
                self.swipeMode = 1
                self.swipeModeLabel?.text = "rotate"
                //self.checkCameraZoom()
            }
        }
    }

    @objc func changeSwipeMode() {

        if self.swipeMode == 0 {
            self.swipeModeButton?.setTitle("Mode2", for: .normal)
            self.checkCameraZoom()
            self.swipeModeLabel?.isHidden = false
        }
        else {
            self.swipeModeButton?.setTitle("Mode1", for: .normal)
            self.swipeMode = 0
            self.swipeModeLabel?.text = ""
            self.swipeModeLabel?.isHidden = true
        }
    }

    func checkCameraZoom() {

        if self.cameraNode.position.z >= 7.0 {
            self.swipeMode = 2
            self.swipeModeLabel?.text = "move"
        }
        else {
            self.swipeMode = 1
            self.swipeModeLabel?.text = "rotate"
        }
    }

    @objc func resetCameraNodePosition() {

        self.redirectCameraNodePosition(name: self.mainSynapseObject.synapseCrystalNode.name!)
    }

    // MARK: mark - ValuesView methods

    func setSynapseValuesView() {

        let colorS: UIColor = UIColor(red:  93/255.0, green: 23/255.0, blue: 135/255.0, alpha: 1)
        let colorE: UIColor = UIColor(red: 228/255.0, green:  9/255.0, blue: 102/255.0, alpha: 1)
        var x: CGFloat = 0
        var y: CGFloat = 0
        var w: CGFloat = self.view.frame.width
        var h: CGFloat = self.view.frame.height
        self.synapseValuesView = UIView()
        self.synapseValuesView.frame = CGRect(x: x, y: y, width: w, height: h)
        self.synapseValuesView.backgroundColor = UIColor.clear
        self.synapseValuesView.isHidden = true
        self.view.addSubview(self.synapseValuesView)
        self.canUpdateValuesView = !self.synapseValuesView.isHidden

        let bgLayer: CAGradientLayer = CAGradientLayer()
        bgLayer.colors = [colorS.cgColor, colorE.cgColor]
        bgLayer.startPoint = CGPoint(x: 0, y: 0)
        bgLayer.endPoint = CGPoint(x: 1, y: 1)
        bgLayer.frame = self.synapseValuesView.frame
        self.synapseValuesView.layer.addSublayer(bgLayer)

        let tabW: CGFloat = 150.0
        let tabH: CGFloat = 80.0
        let dataW: CGFloat = self.synapseValuesView.frame.width
        let dataH: CGFloat = 40.0 * 3 + 10.0 * 2
        var count: Int = self.synapseValues.count
        if count % 2 == 0 {
            count += 1
        }
        w = dataW * CGFloat(count)
        h = dataH
        x = (self.synapseValuesView.frame.width - w) / 2
        y = (self.synapseValuesView.frame.height - h) / 2 - 20.0
        self.synapseDataView = UIView()
        self.synapseDataView.frame = CGRect(x: x, y: y, width: w, height: h)
        self.synapseDataView.backgroundColor = UIColor.clear
        self.synapseValuesView.addSubview(self.synapseDataView)

        w = tabW * CGFloat(count)
        h = tabH
        x = (self.synapseValuesView.frame.width - w) / 2
        y = self.synapseDataView.frame.origin.y - (h + 30.0)
        self.synapseTabView = UIView()
        self.synapseTabView.frame = CGRect(x: x, y: y, width: w, height: h)
        self.synapseTabView.backgroundColor = UIColor.clear
        self.synapseValuesView.addSubview(self.synapseTabView)

        for (index, element) in self.synapseValues.enumerated() {
            let tabView: UIView = UIView()
            tabView.tag = index
            tabView.frame = CGRect(x: 0,
                                   y: 0,
                                   width: tabW,
                                   height: self.synapseTabView.frame.size.height)
            tabView.backgroundColor = UIColor.clear
            tabView.alpha = 0.3
            self.synapseTabView.addSubview(tabView)
            self.synapseTabLabels[element] = tabView

            let imageView: UIImageView = UIImageView()
            imageView.frame = CGRect(x: (tabView.frame.size.width - 60.0) / 2,
                                     y: 0,
                                     width: 60.0,
                                     height: 60.0)
            tabView.addSubview(imageView)
            if element == self.synapseCrystalInfo.co2.key {
                imageView.image = UIImage.co2LW
            }
            else if element == self.synapseCrystalInfo.temp.key {
                imageView.image = UIImage.temperatureLW
            }
            else if element == self.synapseCrystalInfo.hum.key {
                imageView.image = UIImage.humidityLW
            }
            else if element == self.synapseCrystalInfo.ill.key {
                imageView.image = UIImage.illuminationLW
            }
            else if element == self.synapseCrystalInfo.press.key {
                imageView.image = UIImage.airpressureLW
            }
            else if element == self.synapseCrystalInfo.sound.key {
                imageView.image = UIImage.environmentalsoundLW
            }
            /*else if element == self.synapseCrystalInfo.mag.key {
                imageView.image = UIImage(named: "mag.png")
            }*/
            else if element == self.synapseCrystalInfo.move.key {
                imageView.image = UIImage.movementLW
            }
            else if element == self.synapseCrystalInfo.angle.key {
                imageView.image = UIImage.angleLW
            }

            let tabLabel: UILabel = UILabel()
            tabLabel.frame = CGRect(x: 0,
                                    y: tabView.frame.size.height - 20.0,
                                    width: tabView.frame.size.width,
                                    height: 20.0)
            tabLabel.textColor = UIColor.white
            tabLabel.backgroundColor = UIColor.clear
            tabLabel.font = UIFont(name: "HelveticaNeue", size: 16.0)
            tabLabel.textAlignment = .center
            tabLabel.numberOfLines = 1
            tabView.addSubview(tabLabel)
            tabLabel.text = ""
            if element == self.synapseCrystalInfo.co2.key {
                tabLabel.text = self.synapseCrystalInfo.co2.name
            }
            else if element == self.synapseCrystalInfo.temp.key {
                tabLabel.text = self.synapseCrystalInfo.temp.name
            }
            else if element == self.synapseCrystalInfo.hum.key {
                tabLabel.text = self.synapseCrystalInfo.hum.name
            }
            else if element == self.synapseCrystalInfo.ill.key {
                tabLabel.text = self.synapseCrystalInfo.ill.name
            }
            else if element == self.synapseCrystalInfo.press.key {
                tabLabel.text = self.synapseCrystalInfo.press.name
            }
            else if element == self.synapseCrystalInfo.sound.key {
                tabLabel.text = self.synapseCrystalInfo.sound.name
            }
            /*else if element == self.synapseCrystalInfo.mag.key {
                tabLabel.text = self.synapseCrystalInfo.mag.name
            }*/
            else if element == self.synapseCrystalInfo.move.key {
                tabLabel.text = self.synapseCrystalInfo.move.name
            }
            else if element == self.synapseCrystalInfo.angle.key {
                tabLabel.text = self.synapseCrystalInfo.angle.name
            }

            var valueView: UIView = UIView()
            valueView.tag = index
            valueView.frame = CGRect(x: 0,
                                     y: 0,
                                     width: dataW,
                                     height: self.synapseDataView.frame.size.height)
            valueView.backgroundColor = UIColor.clear
            self.synapseDataView.addSubview(valueView)
            self.synapseDataLabels[element] = valueView

            if element == self.synapseCrystalInfo.co2.key {
                valueView = self.synapseValueLabels.co2Labels.setSynapseValueLabels(valueView, unitLabelText: "ppm")
            }
            else if element == self.synapseCrystalInfo.temp.key {
                valueView = self.synapseValueLabels.tempLabels.setSynapseValueLabels(valueView, unitLabelText: self.getTemperatureUnit(SettingFileManager.shared.synapseTemperatureScale))
            }
            else if element == self.synapseCrystalInfo.press.key {
                valueView = self.synapseValueLabels.pressLabels.setSynapseValueLabels(valueView, unitLabelText: "hPa")
            }
            else if element == self.synapseCrystalInfo.sound.key {
                valueView = self.synapseValueLabels.soundLabels.setSynapseValueLabels(valueView, unitLabelText: "")
            }
            /*else if element == self.synapseCrystalInfo.mag.key {
                valueView = self.synapseValueLabels.magxLabels.setSynapseValueLabels(valueView, unitLabelText: "μT", fontSmall: true)
                valueView = self.synapseValueLabels.magyLabels.setSynapseValueLabels(valueView, unitLabelText: "μT", fontSmall: true)
                valueView = self.synapseValueLabels.magzLabels.setSynapseValueLabels(valueView, unitLabelText: "μT", fontSmall: true)
            }*/
            else if element == self.synapseCrystalInfo.move.key {
                valueView = self.synapseValueLabels.movexLabels.setSynapseValueLabels(valueView, unitLabelText: "m/s2", fontSmall: true)
                valueView = self.synapseValueLabels.moveyLabels.setSynapseValueLabels(valueView, unitLabelText: "m/s2", fontSmall: true)
                valueView = self.synapseValueLabels.movezLabels.setSynapseValueLabels(valueView, unitLabelText: "m/s2", fontSmall: true)
            }
            else if element == self.synapseCrystalInfo.angle.key {
                valueView = self.synapseValueLabels.anglexLabels.setSynapseValueLabels(valueView, unitLabelText: "rad/s", fontSmall: true)
                valueView = self.synapseValueLabels.angleyLabels.setSynapseValueLabels(valueView, unitLabelText: "rad/s", fontSmall: true)
                valueView = self.synapseValueLabels.anglezLabels.setSynapseValueLabels(valueView, unitLabelText: "rad/s", fontSmall: true)
            }
            else if element == self.synapseCrystalInfo.ill.key {
                valueView = self.synapseValueLabels.illLabels.setSynapseValueLabels(valueView, unitLabelText: "lux")
            }
            else if element == self.synapseCrystalInfo.hum.key {
                valueView = self.synapseValueLabels.humLabels.setSynapseValueLabels(valueView, unitLabelText: "%")
            }
        }

        x = 0
        //x = 20.0
        y = self.synapseDataView.frame.origin.y + self.synapseDataView.frame.size.height + 20.0
        w = self.synapseValuesView.frame.width - x
        h = 100.0
        self.graphAreaView = UIView()
        self.graphAreaView.frame = CGRect(x: x, y: y, width: w, height: h)
        self.graphAreaView.backgroundColor = UIColor.clear
        self.graphAreaView.clipsToBounds = true
        self.synapseValuesView.addSubview(self.graphAreaView)

        x = 0
        y = 0
        w = 0
        h = self.graphAreaView.frame.height
        self.graphImageView = UIImageView()
        self.graphImageView.image = nil
        self.graphImageView.frame = CGRect(x: x, y: y, width: w, height: h)
        self.graphImageView.backgroundColor = UIColor.clear
        self.graphAreaView.addSubview(self.graphImageView)

        x = self.graphAreaView.frame.origin.x
        y = self.graphAreaView.frame.origin.y + self.graphAreaView.frame.size.height
        w = 0
        h = 20.0
        self.graphImageUnderView = UIView()
        self.graphImageUnderView.frame = CGRect(x: x, y: y, width: w, height: h)
        self.graphImageUnderView.backgroundColor = UIColor.clear
        self.graphImageUnderView.isHidden = true
        self.synapseValuesView.addSubview(self.graphImageUnderView)

        w = self.graphAreaView.frame.width
        h = 16.0
        x = self.graphAreaView.frame.origin.x + 12.0
        y = self.graphAreaView.frame.origin.y - h * 2
        self.maxValueLabel = UILabel()
        self.maxValueLabel.frame = CGRect(x: x, y: y, width: w, height: h)
        self.maxValueLabel.text = ""
        self.maxValueLabel.textColor = UIColor.black
        self.maxValueLabel.backgroundColor = UIColor.clear
        self.maxValueLabel.font = UIFont(name: "Migu 2M", size: 12.0)
        self.maxValueLabel.textAlignment = .left
        self.maxValueLabel.numberOfLines = 1
        self.maxValueLabel.isHidden = true
        self.synapseValuesView.addSubview(self.maxValueLabel)

        y = self.graphAreaView.frame.origin.y - h
        self.minValueLabel = UILabel()
        self.minValueLabel.frame = CGRect(x: x, y: y, width: w, height: h)
        self.minValueLabel.text = ""
        self.minValueLabel.textColor = UIColor.black
        self.minValueLabel.backgroundColor = UIColor.clear
        self.minValueLabel.font = UIFont(name: "Migu 2M", size: 12.0)
        self.minValueLabel.textAlignment = .left
        self.minValueLabel.numberOfLines = 1
        self.minValueLabel.isHidden = true
        self.synapseValuesView.addSubview(self.minValueLabel)

        x = 0
        y = 0
        w = 0
        h = 0
        self.nowValueLabel = UILabel()
        self.nowValueLabel.frame = CGRect(x: x, y: y, width: w, height: h)
        self.nowValueLabel.text = ""
        self.nowValueLabel.textColor = UIColor.white
        self.nowValueLabel.backgroundColor = UIColor.clear
        self.nowValueLabel.font = UIFont(name: "Migu 2M", size: 12.0)
        self.nowValueLabel.textAlignment = .left
        self.nowValueLabel.numberOfLines = 1
        self.nowValueLabel.isHidden = true
        self.synapseValuesView.addSubview(self.nowValueLabel)

        x = 0
        y = self.graphImageUnderView.frame.origin.y
        w = self.synapseValuesView.frame.width
        h = 20.0
        self.graphScaleAreaView = UIView()
        self.graphScaleAreaView.frame = CGRect(x: x, y: y, width: w, height: h)
        self.graphScaleAreaView.backgroundColor = UIColor.clear
        self.graphScaleAreaView.isHidden = true
        self.synapseValuesView.addSubview(self.graphScaleAreaView)

        x = 0
        y = 0
        h = self.graphScaleAreaView.frame.size.height
        self.min0Label = UILabel()
        self.min0Label.text = "0 min"
        self.min0Label.textColor = UIColor.black
        self.min0Label.backgroundColor = UIColor.clear
        self.min0Label.font = UIFont(name: "Migu 2M", size: 12.0)
        self.min0Label.textAlignment = .center
        self.min0Label.numberOfLines = 1
        self.graphScaleAreaView.addSubview(self.min0Label)
        self.min0Label.sizeToFit()
        w = self.min0Label.frame.size.width
        self.min0Label.frame = CGRect(x: x, y: y, width: w, height: h)

        self.min1Label = UILabel()
        self.min1Label.text = "1 min"
        self.min1Label.textColor = UIColor.black
        self.min1Label.backgroundColor = UIColor.clear
        self.min1Label.font = UIFont(name: "Migu 2M", size: 12)
        self.min1Label.textAlignment = NSTextAlignment.center
        self.min1Label.numberOfLines = 1
        self.graphScaleAreaView.addSubview(self.min1Label)
        self.min1Label.sizeToFit()
        w = self.min1Label.frame.size.width
        self.min1Label.frame = CGRect(x: x, y: y, width: w, height: h)

        self.min2Label = UILabel()
        self.min2Label.text = "2 min"
        self.min2Label.textColor = UIColor.black
        self.min2Label.backgroundColor = UIColor.clear
        self.min2Label.font = UIFont(name: "Migu 2M", size: 12)
        self.min2Label.textAlignment = NSTextAlignment.center
        self.min2Label.numberOfLines = 1
        self.graphScaleAreaView.addSubview(self.min2Label)
        self.min2Label.sizeToFit()
        w = self.min2Label.frame.size.width
        self.min2Label.frame = CGRect(x: x, y: y, width: w, height: h)

        self.min3Label = UILabel()
        self.min3Label.text = "3 min"
        self.min3Label.textColor = UIColor.black
        self.min3Label.backgroundColor = UIColor.clear
        self.min3Label.font = UIFont(name: "Migu 2M", size: 12)
        self.min3Label.textAlignment = NSTextAlignment.center
        self.min3Label.numberOfLines = 1
        self.graphScaleAreaView.addSubview(self.min3Label)
        self.min3Label.sizeToFit()
        w = self.min3Label.frame.size.width
        self.min3Label.frame = CGRect(x: x, y: y, width: w, height: h)

        self.min4Label = UILabel()
        self.min4Label.text = "4 min"
        self.min4Label.textColor = UIColor.black
        self.min4Label.backgroundColor = UIColor.clear
        self.min4Label.font = UIFont(name: "Migu 2M", size: 12)
        self.min4Label.textAlignment = NSTextAlignment.center
        self.min4Label.numberOfLines = 1
        self.graphScaleAreaView.addSubview(self.min4Label)
        self.min4Label.sizeToFit()
        w = self.min4Label.frame.size.width
        self.min4Label.frame = CGRect(x: x, y: y, width: w, height: h)

        let swipeGesture: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self,
                                                                              action: #selector(self.swipeSynapseValuesViewGestureAction(_:)))
        self.synapseValuesView.addGestureRecognizer(swipeGesture)
        let swipeGestureLeft: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self,
                                                                                  action: #selector(self.swipeSynapseValuesViewGestureAction(_:)))
        swipeGestureLeft.direction = .left
        self.synapseValuesView.addGestureRecognizer(swipeGestureLeft)

        w = 200.0
        h = 44.0
        x = (self.synapseValuesView.frame.size.width - w) / 2
        y = self.graphScaleAreaView.frame.origin.y + self.graphScaleAreaView.frame.size.height
        y += (self.synapseValuesView.frame.size.height - (y + h)) / 2
        self.synapseValuesAnalyzeButton = UIButton()
        self.synapseValuesAnalyzeButton.frame = CGRect(x: x, y: y, width: w, height: h)
        self.synapseValuesAnalyzeButton.setTitle("Analyze", for: .normal)
        self.synapseValuesAnalyzeButton.setTitleColor(UIColor.white, for: .normal)
        self.synapseValuesAnalyzeButton.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 16.0)
        self.synapseValuesAnalyzeButton.backgroundColor = UIColor.clear
        self.synapseValuesAnalyzeButton.layer.cornerRadius = h / 2
        self.synapseValuesAnalyzeButton.clipsToBounds = true
        self.synapseValuesAnalyzeButton.layer.borderColor = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 0.3).cgColor
        self.synapseValuesAnalyzeButton.layer.borderWidth = 1.0
        self.synapseValuesAnalyzeButton.addTarget(self,
                                                  action: #selector(self.pushAnalyzeViewAction(_:)),
                                                  for: .touchUpInside)
        self.synapseValuesView.addSubview(self.synapseValuesAnalyzeButton)
        let bgView: UIView = UIView()
        bgView.frame = CGRect(x: 0, y: 0, width: w, height: h)
        bgView.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        self.synapseValuesAnalyzeButton.setBackgroundImage(self.getImageFromView(bgView), for: .highlighted)
    }

    @objc func pushAnalyzeViewAction(_ sender: UIButton) {

        var isPush: Bool = true
        if sender == self.synapseValuesAnalyzeButton {
            if self.synapseValueLabels.name != self.mainSynapseObject.synapseValues.name {
                isPush = false
            }
        }
        if isPush {
            self.removeStatusView()

            let vc: AnalyzeViewController = AnalyzeViewController()
            vc.synapseUUID = self.mainSynapseObject.synapseUUID
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    func closeSynapseValuesViewAction() {

        self.synapseValueLabels.name = nil
        self.synapseValuesView.isHidden = true
        self.canUpdateValuesView = !self.synapseValuesView.isHidden

        self.setNavigatioHeaderColor(isWhite: false)
        self.setNavigatioHeaderMenuBtn()
        self.statusAreaBtn.isHidden = false

        let vector: SCNVector3 = SCNVector3(x: self.cameraNode.position.x,
                                            y: self.cameraNode.position.y,
                                            z: self.pinchZoomDef)
        let action: SCNAction = SCNAction.move(to: vector, duration: 0.1)
        self.cameraNode.runAction(action, completionHandler: {
            /*self.canUpdateCrystalView = true
            self.updateSynapseViews()*/
        })
        self.canUpdateCrystalView = true
        self.updateSynapseViews()
    }

    func setSynapseTabAndValueView() {

        let key: String = self.synapseValues[self.focusSynapsePt]
        if let tabView = self.synapseTabLabels[key] {
            tabView.alpha = 1.0
        }

        var start: Int = self.focusSynapsePt - Int(self.synapseValues.count / 2)
        if start < 0 {
            start = self.synapseValues.count + start
        }
        var tabX: CGFloat = 0
        var dataX: CGFloat = 0
        for i in 0..<self.synapseValues.count {
            var index: Int = i + start
            if index >= self.synapseValues.count {
                index = index - self.synapseValues.count
            }

            let key: String = self.synapseValues[index]
            if let view = self.synapseTabLabels[key] {
                view.frame = CGRect(x: tabX,
                                    y: view.frame.origin.y,
                                    width: view.frame.size.width,
                                    height: view.frame.size.height)
                tabX += view.frame.size.width
            }
            if let view = self.synapseDataLabels[key] {
                view.frame = CGRect(x: dataX,
                                    y: view.frame.origin.y,
                                    width: view.frame.size.width,
                                    height: view.frame.size.height)
                dataX += view.frame.size.width
            }
        }

        self.synapseTabView.frame = CGRect(x: (self.synapseValuesView.frame.width - self.synapseTabView.frame.size.width) / 2,
                                           y: self.synapseTabView.frame.origin.y,
                                           width: self.synapseTabView.frame.size.width,
                                           height: self.synapseTabView.frame.size.height)
        self.synapseDataView.frame = CGRect(x: (self.synapseValuesView.frame.width - self.synapseDataView.frame.size.width) / 2,
                                            y: self.synapseDataView.frame.origin.y,
                                            width: self.synapseDataView.frame.size.width,
                                            height: self.synapseDataView.frame.size.height)
    }

    func displaySynapseValuesView(synapseObject: SynapseObject?) {

        self.focusSynapsePt = 0
        for (index, element) in self.synapseValues.enumerated() {
            if self.focusSynapseValue == element {
                self.focusSynapsePt = index
                break
            }
        }
        self.setSynapseTabAndValueView()

        if let synapseObject = synapseObject {
            self.setSynapseGraphData(synapseObject: synapseObject)
        }
    }

    @objc func swipeSynapseValuesViewGestureAction(_ sender: UISwipeGestureRecognizer) {

        if !self.canSwipeSynapseValuesView {
            return
        }

        var x: CGFloat = 0
        if sender.direction == .left {
            x = -1
        }
        else if sender.direction == .right {
            x = 1
        }
        if x != 0 {
            self.canSwipeSynapseValuesView = false

            self.resetSynapseGraphImage()

            let key: String = self.synapseValues[self.focusSynapsePt]
            if let tabView = self.synapseTabLabels[key] {
                tabView.alpha = 0.3
            }

            self.focusSynapsePt -= Int(x)
            if self.focusSynapsePt < 0 {
                self.focusSynapsePt = self.synapseValues.count + self.focusSynapsePt
            }
            else if self.focusSynapsePt >= self.synapseValues.count {
                self.focusSynapsePt = self.synapseValues.count - self.focusSynapsePt
            }

            let tabW: CGFloat = 150.0
            let dataW: CGFloat = self.synapseValuesView.frame.width
            UIView.animate(withDuration: 0.2,
                           delay: 0,
                           options: UIViewAnimationOptions.curveEaseIn,
                           animations: { () -> Void in
                self.synapseTabView.frame = CGRect(x: self.synapseTabView.frame.origin.x + tabW * x,
                                                   y: self.synapseTabView.frame.origin.y,
                                                   width: self.synapseTabView.frame.size.width,
                                                   height: self.synapseTabView.frame.size.height)
                self.synapseDataView.frame = CGRect(x: self.synapseDataView.frame.origin.x + dataW * x,
                                                    y: self.synapseDataView.frame.origin.y,
                                                    width: self.synapseDataView.frame.size.width,
                                                    height: self.synapseDataView.frame.size.height)
            }, completion: { _ in
                self.setSynapseTabAndValueView()
                if self.synapseValueLabels.name == self.mainSynapseObject.synapseValues.name && self.mainSynapseObject.synapseValues.isConnected {
                    self.setSynapseGraphImage(synapseObject: self.mainSynapseObject)
                }
                self.canSwipeSynapseValuesView = true
            })
        }
    }

    // MARK: mark - Graph methods

    func setSynapseGraphData(synapseObject: SynapseObject) {

        self.synapseGraphNowDate = Date()
        let formatter: DateFormatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyyMMddHHmmss"
        let graphDateStr: String = formatter.string(from: self.synapseGraphNowDate)
        let sec: String = String(graphDateStr[graphDateStr.index(graphDateStr.startIndex, offsetBy: 12)..<graphDateStr.index(graphDateStr.startIndex, offsetBy: 14)])
        //print("setSynapseGraphData dateStr: \(sec)")
        var secBase: Int = 0
        if let secVal = Int(sec) {
            secBase = secVal
            if secVal >= 30 {
                secBase -= 30
            }
        }
        self.synapseGraphNowDate = Date(timeInterval: TimeInterval(-secBase), since: self.synapseGraphNowDate)
        //print("setSynapseGraphData synapseGraphNowDate: \(self.synapseGraphNowDate)")

        for (_, element) in self.synapseGraphs.enumerated() {
            var graphData: [[Double]] = []
            for i in 0..<self.synapseGraphMaxCnt {
                let graphDate: Date = Date(timeInterval: TimeInterval(-30 * i - 1), since: self.synapseGraphNowDate)
                graphData.append(self.makeSynapseGraphData(key: element, graphDate: graphDate, synapseValues: synapseObject.synapseValues, synapseRecordFileManager: synapseObject.synapseRecordFileManager))
            }
            self.synapseGraphData[element] = graphData
        }
        //print("setSynapseGraphData: \(self.synapseGraphData)")
    }

    func checkSynapseGraphData(synapseObject: SynapseObject) {

        //print("checkSynapseGraphData synapseGraphNowDate: \(self.synapseGraphNowDate)")
        if Date().timeIntervalSince(self.synapseGraphNowDate) >= 30.0 {
            self.synapseGraphNowDate = Date(timeInterval: TimeInterval(30), since: self.synapseGraphNowDate)
            //print("checkSynapseGraphData synapseGraphNowDate: \(self.synapseGraphNowDate)")
            let graphDate: Date = Date(timeInterval: TimeInterval(-1), since: self.synapseGraphNowDate)
            for (_, element) in self.synapseGraphs.enumerated() {
                let newValues: [Double] = self.makeSynapseGraphData(key: element, graphDate: graphDate, synapseValues: synapseObject.synapseValues, synapseRecordFileManager: synapseObject.synapseRecordFileManager)
                var newGraphData: [[Double]] = []
                if let graphData = self.synapseGraphData[element] {
                    newGraphData = graphData
                    newGraphData.insert(newValues, at: 0)
                    if newGraphData.count > self.synapseGraphMaxCnt {
                        newGraphData.removeLast()
                    }
                }
                else {
                    newGraphData.append(newValues)
                }
                self.synapseGraphData[element] = newGraphData
            }
            //print("checkSynapseGraphData: \(self.synapseGraphData)")
        }
    }

    func makeSynapseGraphData(key: String, graphDate: Date, synapseValues: SynapseValues, synapseRecordFileManager: SynapseRecordFileManager?) -> [Double] {

        var values: [Double] = [0, 0]
        if let time = synapseValues.time, Date(timeIntervalSince1970: time) <= graphDate {
            if key == self.synapseCrystalInfo.co2.key, let val = synapseValues.co2 {
                values = [1, Double(val)]
            }
            else if key == self.synapseCrystalInfo.temp.key, let val = synapseValues.temp {
                values = [1, Double(val)]
            }
            else if key == self.synapseCrystalInfo.press.key, let val = synapseValues.pressure {
                values = [1, Double(val)]
            }
            else if key == self.synapseCrystalInfo.ax.key, let val = synapseValues.ax {
                values = [1, Double(val)]
            }
            else if key == self.synapseCrystalInfo.ay.key, let val = synapseValues.ay {
                values = [1, Double(val)]
            }
            else if key == self.synapseCrystalInfo.az.key, let val = synapseValues.az {
                values = [1, Double(val)]
            }
            else if key == self.synapseCrystalInfo.gx.key, let val = synapseValues.gx {
                values = [1, Double(val)]
            }
            else if key == self.synapseCrystalInfo.gy.key, let val = synapseValues.gy {
                values = [1, Double(val)]
            }
            else if key == self.synapseCrystalInfo.gz.key, let val = synapseValues.gz {
                values = [1, Double(val)]
            }
            else if key == self.synapseCrystalInfo.ill.key, let val = synapseValues.light {
                values = [1, Double(val)]
            }
            else if key == self.synapseCrystalInfo.hum.key, let val = synapseValues.humidity {
                values = [1, Double(val)]
            }
            else if key == self.synapseCrystalInfo.sound.key, let val = synapseValues.sound {
                values = [1, Double(val)]
            }
            else if key == self.synapseCrystalInfo.volt.key, let val = synapseValues.power {
                values = [1, Double(val)]
            }
        }
        else if let synapseRecordFileManager = synapseRecordFileManager {
            let formatter: DateFormatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.dateFormat = "yyyyMMddHHmmss"
            let graphDateStr: String = formatter.string(from: graphDate)
            //print("setSynapseGraphData: \(graphDateStr)")
            let day: String = String(graphDateStr[graphDateStr.startIndex..<graphDateStr.index(graphDateStr.startIndex, offsetBy: 8)])
            let hour: String = String(graphDateStr[graphDateStr.index(graphDateStr.startIndex, offsetBy: 8)..<graphDateStr.index(graphDateStr.startIndex, offsetBy: 10)])
            let min: String = String(graphDateStr[graphDateStr.index(graphDateStr.startIndex, offsetBy: 10)..<graphDateStr.index(graphDateStr.startIndex, offsetBy: 12)])
            let sec: String = String(graphDateStr[graphDateStr.index(graphDateStr.startIndex, offsetBy: 12)..<graphDateStr.index(graphDateStr.startIndex, offsetBy: 14)])
            //print("makeSynapseGraphData dateStr: \(day) \(hour) \(min) \(sec)")

            if sec == "59" {
                let totalData: [Double] = synapseRecordFileManager.getSynapseRecordTotal(day: day, hour: hour, min: min, sec: nil, type: key)
                if totalData.count > 1 {
                    values = totalData
                }
                //print("setSynapseGraphData 59: \(values)")
            }
            else if sec == "29" {
                var val0: Double = 0
                var val1: Double = 0
                let totalData0: [Double] = synapseRecordFileManager.getSynapseRecordTotal(day: day, hour: hour, min: min, sec: "0", type: key)
                if totalData0.count > 1 {
                    val0 += totalData0[0]
                    val1 += totalData0[1]
                }
                let totalData10: [Double] = synapseRecordFileManager.getSynapseRecordTotal(day: day, hour: hour, min: min, sec: "10", type: key)
                if totalData10.count > 1 {
                    val0 += totalData10[0]
                    val1 += totalData10[1]
                }
                let totalData20: [Double] = synapseRecordFileManager.getSynapseRecordTotal(day: day, hour: hour, min: min, sec: "20", type: key)
                if totalData20.count > 1 {
                    val0 += totalData20[0]
                    val1 += totalData20[1]
                }
                values = [val0, val1]
                //print("setSynapseGraphData 29: \(values)")
            }
        }
        return values
    }

    func setSynapseGraphImage(synapseObject: SynapseObject) {

        let key: String = self.synapseValues[self.focusSynapsePt]
        let now: Date = Date()
        let secVal: Double = now.timeIntervalSince(self.synapseGraphNowDate)
        let space: CGFloat = 6.0
        let imageW: CGFloat = self.graphAreaView.frame.origin.x + self.graphAreaView.frame.size.width - 60.0 - space / 2
        let imageH: CGFloat = self.graphAreaView.frame.size.height - space
        let blockW: CGFloat = imageW / CGFloat(self.synapseGraphMaxCnt - 1)
        let lastW: CGFloat = blockW * CGFloat(secVal / 30.0)

        var graphData: [[[Double]]] = []
        var lastVals: [Double] = []
        if key == self.synapseCrystalInfo.co2.key && self.synapseCrystalInfo.co2.hasGraph {
            if let co2 = synapseObject.synapseValues.co2 {
                if let data = self.synapseGraphData[key] {
                    graphData.append(data)
                }
                lastVals.append(Double(co2))
            }
        }
        else if key == self.synapseCrystalInfo.temp.key && self.synapseCrystalInfo.temp.hasGraph {
            if let temp = synapseObject.synapseValues.temp {
                if let data = self.synapseGraphData[key] {
                    graphData.append(data)
                }
                lastVals.append(Double(temp))
            }
        }
        else if key == self.synapseCrystalInfo.press.key && self.synapseCrystalInfo.press.hasGraph {
            if let press = synapseObject.synapseValues.pressure {
                if let data = self.synapseGraphData[key] {
                    graphData.append(data)
                }
                lastVals.append(Double(press))
            }
        }
        /*else if key == self.synapseCrystalInfo.mag.key && self.synapseCrystalInfo.mag.hasGraph {
            if let data = self.synapseGraphData["mx"] {
                graphData.append(data)
                if let mx = synapseValues.mx {
                    lastVals.append(Double(mx))
                }
                else {
                    lastVals.append(0)
                }
            }
            if let data = self.synapseGraphData["my"] {
                graphData.append(data)
                if let my = synapseValues.my {
                    lastVals.append(Double(my))
                }
                else {
                    lastVals.append(0)
                }
            }
            if let data = self.synapseGraphData["mz"] {
                graphData.append(data)
                if let mz = synapseValues.mz {
                    lastVals.append(Double(mz))
                }
                else {
                    lastVals.append(0)
                }
            }
        }*/
        else if key == self.synapseCrystalInfo.move.key && self.synapseCrystalInfo.move.hasGraph {
            if let data = self.synapseGraphData[self.synapseCrystalInfo.ax.key] {
                graphData.append(data)
                if let ax = synapseObject.synapseValues.ax {
                    lastVals.append(Double(ax))
                }
                else {
                    lastVals.append(0)
                }
            }
            if let data = self.synapseGraphData[self.synapseCrystalInfo.ay.key] {
                graphData.append(data)
                if let ay = synapseObject.synapseValues.ay {
                    lastVals.append(Double(ay))
                }
                else {
                    lastVals.append(0)
                }
            }
            if let data = self.synapseGraphData[self.synapseCrystalInfo.az.key] {
                graphData.append(data)
                if let az = synapseObject.synapseValues.az {
                    lastVals.append(Double(az))
                }
                else {
                    lastVals.append(0)
                }
            }
        }
        else if key == self.synapseCrystalInfo.angle.key && self.synapseCrystalInfo.angle.hasGraph {
            if let data = self.synapseGraphData[self.synapseCrystalInfo.gx.key] {
                graphData.append(data)
                if let gx = synapseObject.synapseValues.gx {
                    lastVals.append(Double(gx))
                }
                else {
                    lastVals.append(0)
                }
            }
            if let data = self.synapseGraphData[self.synapseCrystalInfo.gy.key] {
                graphData.append(data)
                if let gy = synapseObject.synapseValues.gy {
                    lastVals.append(Double(gy))
                }
                else {
                    lastVals.append(0)
                }
            }
            if let data = self.synapseGraphData[self.synapseCrystalInfo.gz.key] {
                graphData.append(data)
                if let gz = synapseObject.synapseValues.gz {
                    lastVals.append(Double(gz))
                }
                else {
                    lastVals.append(0)
                }
            }
        }
        else if key == self.synapseCrystalInfo.ill.key && self.synapseCrystalInfo.ill.hasGraph {
            if let light = synapseObject.synapseValues.light {
                if let data = self.synapseGraphData[key] {
                    graphData.append(data)
                }
                lastVals.append(Double(light))
            }
        }
        else if key == self.synapseCrystalInfo.hum.key && self.synapseCrystalInfo.hum.hasGraph {
            if let hum = synapseObject.synapseValues.humidity {
                if let data = self.synapseGraphData[key] {
                    graphData.append(data)
                }
                lastVals.append(Double(hum))
            }
        }
        else if key == self.synapseCrystalInfo.sound.key && self.synapseCrystalInfo.sound.hasGraph {
            if let sound = synapseObject.synapseValues.sound {
                if let data = self.synapseGraphData[key] {
                    graphData.append(data)
                }
                lastVals.append(Double(sound))
            }
        }
        let positions: [[[CGFloat]]] = self.makeGraphPositions(graphData: graphData, lastVals: lastVals, w: blockW, h: imageH, lastW: lastW, space: space)

        let x: CGFloat = -lastW - self.graphAreaView.frame.origin.x
        let y: CGFloat = 0
        let w: CGFloat = imageW + lastW + space
        let h: CGFloat = self.graphAreaView.frame.size.height
        self.graphImageView.image = self.makeGraphImage(positions, color: UIColor.white, imageW: w, imageH: h)
        self.graphImageView.frame = CGRect(x: x, y: y, width: w, height: h)

        if self.min0Label.frame.origin.x == 0 {
            var baseX: CGFloat = imageW
            self.min0Label.frame = CGRect(x: baseX - self.min0Label.frame.size.width / 2,
                                          y: self.min0Label.frame.origin.y,
                                          width: self.min0Label.frame.size.width,
                                          height: self.min0Label.frame.size.height)
            baseX -= blockW * 2
            self.min1Label.frame = CGRect(x: baseX - self.min1Label.frame.size.width / 2,
                                          y: self.min1Label.frame.origin.y,
                                          width: self.min1Label.frame.size.width,
                                          height: self.min1Label.frame.size.height)
            baseX -= blockW * 2
            self.min2Label.frame = CGRect(x: baseX - self.min2Label.frame.size.width / 2,
                                          y: self.min2Label.frame.origin.y,
                                          width: self.min2Label.frame.size.width,
                                          height: self.min2Label.frame.size.height)
            baseX -= blockW * 2
            self.min3Label.frame = CGRect(x: baseX - self.min3Label.frame.size.width / 2,
                                          y: self.min3Label.frame.origin.y,
                                          width: self.min3Label.frame.size.width,
                                          height: self.min3Label.frame.size.height)
            baseX -= blockW * 2
            self.min4Label.frame = CGRect(x: baseX - self.min4Label.frame.size.width / 2,
                                          y: self.min4Label.frame.origin.y,
                                          width: self.min4Label.frame.size.width,
                                          height: self.min4Label.frame.size.height)
        }
        if self.graphImageUnderView.frame.size.width == 0 {
            self.graphImageUnderView.frame = CGRect(x: self.graphImageUnderView.frame.origin.x,
                                                    y: self.graphImageUnderView.frame.origin.y,
                                                    width: imageW - self.graphAreaView.frame.origin.x,
                                                    height: self.graphImageUnderView.frame.size.height)

            let layer: CAGradientLayer = CAGradientLayer()
            layer.frame = self.graphImageUnderView.bounds
            layer.colors = [
                UIColor(red: 230/255.0, green: 19/255.0, blue: 100/255.0, alpha: 0.3).cgColor,
                UIColor(red: 230/255.0, green: 19/255.0, blue: 100/255.0, alpha: 0).cgColor
            ]
            self.graphImageUnderView.layer.addSublayer(layer)
        }
        if graphData.count > 0 {
            self.graphImageUnderView.isHidden = false
            //self.graphImageSideView.isHidden = false
            self.graphScaleAreaView.isHidden = false
            self.nowValueLabel.isHidden = false
            self.maxValueLabel.isHidden = false
            self.minValueLabel.isHidden = false
            self.setSynapseMaxAndMinLabel(synapseObject.synapseDataMaxAndMins, synapseValuesMain: synapseObject.synapseValues)
        }
    }

    func resetSynapseGraphImage() {

        self.graphImageView.image = nil
        self.nowValueLabel.isHidden = true
        self.maxValueLabel.isHidden = true
        self.minValueLabel.isHidden = true
        self.graphImageUnderView.isHidden = true
        //self.graphImageSideView.isHidden = true
        self.graphScaleAreaView.isHidden = true
    }

    func makeGraphPositions(graphData: [[[Double]]], lastVals: [Double], w: CGFloat, h: CGFloat, lastW: CGFloat, space: CGFloat) -> [[[CGFloat]]] {

        var positions: [[[CGFloat]]] = []
        var valuesAll: [[Double]] = []
        var min: Double = 0
        var max: Double = 0
        for (index, data) in graphData.enumerated() {
            var values: [Double] = []
            for (_, element) in data.enumerated() {
                var value: Double = 0
                if element.count > 1 {
                    let cnt: Double = element[0]
                    let total: Double = element[1]
                    if cnt > 0.0 {
                        value = total / cnt
                    }
                }
                values.insert(value, at: 0)
                if value < min {
                    min = value
                }
                if value > max {
                    max = value
                }
            }
            valuesAll.append(values)

            var lastVal: Double = 0
            if index < lastVals.count {
                lastVal = lastVals[index]
            }
            if lastVal < min {
                min = lastVal
            }
            if lastVal > max {
                max = lastVal
            }
        }
        for (index, values) in valuesAll.enumerated() {
            var posData: [[CGFloat]] = []
            var posW: CGFloat = 0
            for (_, element) in values.enumerated() {
                var posH: CGFloat = space / 2
                if element - min >= 0.0 && max - min > 0.0 {
                    posH = h * CGFloat((element - min) / (max - min)) + space / 2
                }
                posData.append([posW, self.graphAreaView.frame.size.height - posH])
                posW += w
            }

            var lastVal: Double = 0
            if index < lastVals.count {
                lastVal = lastVals[index]
            }
            var lastH: CGFloat = space / 2
            if lastVal - min >= 0.0 && max - min > 0.0 {
                lastH = h * CGFloat((lastVal - min) / (max - min)) + space / 2
            }
            posData.append([posW - w + lastW, self.graphAreaView.frame.size.height - lastH])

            positions.append(posData)
        }
        return positions
    }

    func makeGraphImage(_ positions: [[[CGFloat]]], color: UIColor, imageW: CGFloat, imageH: CGFloat) -> UIImage? {

        var image: UIImage? = nil
        UIGraphicsBeginImageContextWithOptions(CGSize(width: imageW, height: imageH), false, 0)
        for (_, data) in positions.enumerated() {
            var sx: CGFloat = -1
            var sy: CGFloat = -1
            for (index, element) in data.enumerated() {
                let ex: CGFloat = element[0]
                let ey: CGFloat = element[1]

                if index > 0 {
                    let fillColor: UIColor = UIColor(red: 230/255.0, green: 19/255.0, blue: 100/255.0, alpha: 0.3)
                    let fillPath: UIBezierPath = UIBezierPath()
                    fillPath.move(to: CGPoint(x: sx, y: sy))
                    fillPath.addLine(to: CGPoint(x: ex, y: ey))
                    fillPath.addLine(to: CGPoint(x: ex, y: imageH))
                    fillPath.addLine(to: CGPoint(x: sx, y: imageH))
                    fillColor.setFill()
                    fillPath.fill()

                    let linePath: UIBezierPath = UIBezierPath()
                    linePath.move(to: CGPoint(x: sx, y: sy))
                    linePath.addLine(to: CGPoint(x: ex, y: ey))
                    linePath.lineWidth = 1.0
                    color.setStroke()
                    linePath.stroke()
                }
                sx = ex
                sy = ey
            }
            //print("\(imageW), \(sx)")

            let lineColor: UIColor = UIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 0.3)
            let linePath: UIBezierPath = UIBezierPath()
            linePath.move(to: CGPoint(x: sx, y: sy))
            linePath.addLine(to: CGPoint(x: 0, y: sy))
            linePath.lineWidth = 1.0
            lineColor.setStroke()
            linePath.stroke()

            let circlePath: UIBezierPath = UIBezierPath(ovalIn: CGRect(x: sx - 3.0, y: sy - 3.0, width: 6.0, height: 6.0))
            color.setFill()
            circlePath.fill()

            self.nowValueLabelY = sy
            //print("nowValueLabelY: \(self.nowValueLabelY)")
        }

        image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image
    }

    // MARK: mark - Update SynapseViews methods

    func updateSynapseViews() {

        let now: TimeInterval = Date().timeIntervalSince1970
        //print("\(Date()) updateSynapseViews: \(now)")
        if self.canUpdateCrystalView {
            if self.updateSynapseViewTimeLast == nil || now - self.updateSynapseViewTimeLast! >= self.updateSynapseViewTime {
                if self.mainSynapseObject.synapseValues.isConnected {
                    self.updateSynapseViewTimeLast = now
                }
                self.mainSynapseObject.updateSynapseNode()
                /*self.updateSynapseCrystalViewRealtime()
                self.updateSynapseCrystalViewConstant()*/
            }
        }

        if self.canUpdateValuesView {
            if self.updateSynapseValuesViewTimeLast == nil || now - self.updateSynapseValuesViewTimeLast! >= self.updateSynapseValuesViewTime {
                self.updateSynapseValuesViewTimeLast = now
                if self.synapseValueLabels.name == self.mainSynapseObject.synapseValues.name {
                    self.updateSynapseValuesView(synapseValues: self.mainSynapseObject.synapseValues)
                }
            }
        }

        self.updateStatusView(synapseObject: self.mainSynapseObject)
    }
    /*
    func updateSynapseCrystalViewRealtime() {

        //print("updateSynapseCrystalViewRealtime")
        if self.mainSynapseObject.synapseValues.isConnected {
            self.mainSynapseObject.rotateSynapseNode()
            //self.rotateCrystalNode(self.synapseNodeMain)
        }
    }

    func updateSynapseCrystalViewConstant() {

        //print("\(Date()) updateSynapseCrystalViewConstant")
        if self.mainSynapseObject.synapseValues.isConnected {
            self.mainSynapseObject.scaleSynapseNode()
            self.mainSynapseObject.setColorSynapseNodeFromBatteryLevel()
        }
    }
     */
    func updateSynapseValuesViewFromSetting() {

        if self.canUpdateValuesView {
            if self.synapseValueLabels.name == self.mainSynapseObject.synapseValues.name {
                self.updateSynapseValuesView(synapseValues: self.mainSynapseObject.synapseValues)
            }
        }
    }

    func updateSynapseValuesView(synapseValues: SynapseValues) {

        //print("\(Date()) updateSynapseValuesView")
        if !synapseValues.isConnected {
            return
        }

        //self.resetSynapseValuesView()

        let baseW: CGFloat = self.synapseValuesView.frame.width
        let baseH: CGFloat = self.synapseDataView.frame.height

        if let co2 = synapseValues.co2 {
            self.synapseValueLabels.co2Labels.updateSynapseValueLabels(co2, baseW: baseW, baseH: baseH)
        }
        else {
            self.synapseValueLabels.co2Labels.resetSynapseValueLabels()
        }

        if let temp = synapseValues.temp {
            self.synapseValueLabels.tempLabels.unitLabel?.text = self.getTemperatureUnit(SettingFileManager.shared.synapseTemperatureScale)
            self.synapseValueLabels.tempLabels.updateSynapseValueLabels(temp, baseW: baseW, baseH: baseH, option: [self.synapseCrystalInfo.temp.key: ["scale": SettingFileManager.shared.synapseTemperatureScale]])
        }
        else {
            self.synapseValueLabels.tempLabels.resetSynapseValueLabels()
        }

        if let pressure = synapseValues.pressure {
            self.synapseValueLabels.pressLabels.updateSynapseValueLabels(pressure, baseW: baseW, baseH: baseH)
        }
        else {
            self.synapseValueLabels.pressLabels.resetSynapseValueLabels()
        }

        /*if let mx = synapseValues.mx, let my = synapseValues.my, let mz = synapseValues.mz {
            self.synapseValueLabels.magxLabels.updateSynapseValueLabels(mx, baseW: baseW, baseH: baseH)
            self.synapseValueLabels.magyLabels.updateSynapseValueLabels(my, baseW: baseW, baseH: baseH)
            self.synapseValueLabels.magzLabels.updateSynapseValueLabels(mz, baseW: baseW, baseH: baseH)
            self.updateMultiSynapseValuesLabels([self.synapseValueLabels.magxLabels, self.synapseValueLabels.magyLabels, self.synapseValueLabels.magzLabels])
        }
        else {
            self.synapseValueLabels.magxLabels.resetSynapseValueLabels()
            self.synapseValueLabels.magyLabels.resetSynapseValueLabels()
            self.synapseValueLabels.magzLabels.resetSynapseValueLabels()
        }*/

        if let ax = synapseValues.ax, let ay = synapseValues.ay, let az = synapseValues.az {
            let axF: Float = self.makeAccelerationValue(Float(ax))
            let ayF: Float = self.makeAccelerationValue(Float(ay))
            let azF: Float = self.makeAccelerationValue(Float(az))
            self.synapseValueLabels.movexLabels.updateSynapseValueLabels(axF, baseW: baseW, baseH: baseH, floatFormat: "%.4f")
            self.synapseValueLabels.moveyLabels.updateSynapseValueLabels(ayF, baseW: baseW, baseH: baseH, floatFormat: "%.4f")
            self.synapseValueLabels.movezLabels.updateSynapseValueLabels(azF, baseW: baseW, baseH: baseH, floatFormat: "%.4f")
            self.updateMultiSynapseValuesLabels([self.synapseValueLabels.movexLabels, self.synapseValueLabels.moveyLabels, self.synapseValueLabels.movezLabels])
        }
        else {
            self.synapseValueLabels.movexLabels.resetSynapseValueLabels()
            self.synapseValueLabels.moveyLabels.resetSynapseValueLabels()
            self.synapseValueLabels.movezLabels.resetSynapseValueLabels()
        }

        if let gx = synapseValues.gx, let gy = synapseValues.gy, let gz = synapseValues.gz {
            let gxF: Float = self.makeGyroscopeValue(Float(gx))
            let gyF: Float = self.makeGyroscopeValue(Float(gy))
            let gzF: Float = self.makeGyroscopeValue(Float(gz))
            self.synapseValueLabels.anglexLabels.updateSynapseValueLabels(gxF, baseW: baseW, baseH: baseH, floatFormat: "%.4f")
            self.synapseValueLabels.angleyLabels.updateSynapseValueLabels(gyF, baseW: baseW, baseH: baseH, floatFormat: "%.4f")
            self.synapseValueLabels.anglezLabels.updateSynapseValueLabels(gzF, baseW: baseW, baseH: baseH, floatFormat: "%.4f")
            self.updateMultiSynapseValuesLabels([self.synapseValueLabels.anglexLabels, self.synapseValueLabels.angleyLabels, self.synapseValueLabels.anglezLabels])
        }
        else {
            self.synapseValueLabels.anglexLabels.resetSynapseValueLabels()
            self.synapseValueLabels.angleyLabels.resetSynapseValueLabels()
            self.synapseValueLabels.anglezLabels.resetSynapseValueLabels()
        }

        if let light = synapseValues.light {
            self.synapseValueLabels.illLabels.updateSynapseValueLabels(light, baseW: baseW, baseH: baseH)
        }
        else {
            self.synapseValueLabels.illLabels.resetSynapseValueLabels()
        }

        if let humidity = synapseValues.humidity {
            self.synapseValueLabels.humLabels.updateSynapseValueLabels(humidity, baseW: baseW, baseH: baseH)
        }
        else {
            self.synapseValueLabels.humLabels.resetSynapseValueLabels()
        }

        if let sound = synapseValues.sound {
            self.synapseValueLabels.soundLabels.updateSynapseValueLabels(sound, baseW: baseW, baseH: baseH)
        }
        else {
            self.synapseValueLabels.soundLabels.resetSynapseValueLabels()
        }

        if synapseValues.name == self.mainSynapseObject.synapseValues.name {
            self.resetSynapseGraphImage()
            self.checkSynapseGraphData(synapseObject: self.mainSynapseObject)
            self.setSynapseGraphImage(synapseObject: self.mainSynapseObject)
            self.setSynapseMaxAndMinLabel(self.mainSynapseObject.synapseDataMaxAndMins, synapseValuesMain: self.mainSynapseObject.synapseValues)
        }
    }

    func updateMultiSynapseValuesLabels(_ multiSynapseValueLabels: [SynapseValueLabels]) {

        let spaceH: CGFloat = 10.0
        var baseW: CGFloat = 0
        var baseH: CGFloat = 0
        for labels in multiSynapseValueLabels {
            if labels.valueLabel == nil || labels.unitLabel == nil || labels.diffLabel == nil {
                baseW = 0
                baseH = 0
                break
            }

            if baseW < labels.valueLabel!.frame.size.width {
                baseW = labels.valueLabel!.frame.size.width
            }
            baseH += labels.valueLabel!.frame.size.height + spaceH
        }
        if baseW == 0 || baseH == 0 {
            return
        }
        let baseX: CGFloat = (self.synapseValuesView.frame.width - baseW) / 2
        let baseY: CGFloat = (self.synapseDataView.frame.height - (baseH - spaceH)) / 2

        var x: CGFloat = 0
        var y: CGFloat = baseY
        for labels in multiSynapseValueLabels {
            let w: CGFloat = labels.valueLabel!.frame.size.width
            let h: CGFloat = labels.valueLabel!.frame.size.height
            x = baseX + (baseW - w)
            labels.valueLabel!.frame = CGRect(x: x, y: y, width: w, height: h)

            var altX: CGFloat = labels.valueLabel!.frame.origin.x + labels.valueLabel!.frame.size.width + 10.0
            var altY: CGFloat = labels.valueLabel!.frame.origin.y + labels.valueLabel!.frame.size.height - (labels.unitLabel!.frame.size.height + 5.0)
            var altW: CGFloat = labels.unitLabel!.frame.size.width
            var altH: CGFloat = labels.unitLabel!.frame.size.height
            labels.unitLabel?.frame = CGRect(x: altX, y: altY, width: altW, height: altH)

            altW = labels.diffLabel!.frame.size.width
            altH = labels.diffLabel!.frame.size.height
            altX = baseX - (altW + 5.0)
            altY = labels.valueLabel!.frame.origin.y
            if altX < 0.0 {
                altX = 0
                altY -= altH
            }
            labels.diffLabel?.frame = CGRect(x: altX, y: altY, width: altW, height: altH)

            y += h + spaceH
        }
    }

    func resetSynapseValuesView() {

        self.synapseValueLabels.co2Labels.resetSynapseValueLabels()
        self.synapseValueLabels.tempLabels.resetSynapseValueLabels()
        self.synapseValueLabels.pressLabels.resetSynapseValueLabels()
        self.synapseValueLabels.movexLabels.resetSynapseValueLabels()
        self.synapseValueLabels.moveyLabels.resetSynapseValueLabels()
        self.synapseValueLabels.movezLabels.resetSynapseValueLabels()
        self.synapseValueLabels.anglexLabels.resetSynapseValueLabels()
        self.synapseValueLabels.angleyLabels.resetSynapseValueLabels()
        self.synapseValueLabels.anglezLabels.resetSynapseValueLabels()
        self.synapseValueLabels.illLabels.resetSynapseValueLabels()
        self.synapseValueLabels.humLabels.resetSynapseValueLabels()
        self.synapseValueLabels.soundLabels.resetSynapseValueLabels()
        /*self.synapseValueLabels.magxLabels.resetSynapseValueLabels()
        self.synapseValueLabels.magyLabels.resetSynapseValueLabels()
        self.synapseValueLabels.magzLabels.resetSynapseValueLabels()*/
    }

    // MARK: mark - Synapse Device methods

    func setRFduinoManager() {

        self.rfduinoManager = RFduinoManager()
        //self.rfduinoManager.setCustomUUID("fe84")
        self.rfduinoManager.delegate = self
    }

    func startScan() {

        if self.isSynapseScanning || self.mainSynapseObject.synapse == nil {
            print("startScan")
            self.rfduinoManager.startScan()
        }
    }

    func stopScan() {

        if !self.isSynapseScanning && self.mainSynapseObject.synapse != nil {
            print("stopScan")
            self.rfduinoManager.stopScan()
        }
    }

    func setRFduinos() {

        //print("setRFduinos: \(self.rfduinoManager.rfduinos.count)")
        if let rfduinos = self.rfduinoManager.rfduinos {
            for (_, rfduino) in rfduinos.enumerated() {
                if let rfduino = rfduino as? RFduino {
                    //print("rfduinos.append: \(rfduino)")
                    self.checkSynapse(rfduino)
                }
            }
        }
    }

    func checkSynapse(_ rfduino: RFduino) {

        //print("rfduino.outOfRange: \(rfduino.outOfRange)")
        //print("checkSynapse: \(String(describing: String(data: rfduino.advertisementData, encoding: String.Encoding.utf8)))")
        if self.synapseDeviceName.count > 0 && rfduino.outOfRange == 0 && rfduino.advertisementData == self.synapseDeviceName.data(using: String.Encoding.utf8) {
            print("checkSynapse: \(rfduino.peripheral.identifier) lastAdvertisement: \(String(describing: rfduino.lastAdvertisement))")
            var synapseIndex: Int = -1
            for (index, synapse) in self.scanDevices.enumerated() {
                if synapse.peripheral.identifier == rfduino.peripheral.identifier {
                    synapseIndex = index
                    break
                }
            }
            if synapseIndex >= 0 && synapseIndex < self.scanDevices.count {
                self.scanDevices[synapseIndex] = rfduino
            }
            else {
                self.scanDevices.append(rfduino)
            }

            self.connectSynapse(rfduino)
        }
    }

    func connectSynapse(_ rfduino: RFduino) {

        if self.mainSynapseObject.synapse == nil {
            if self.mainSynapseObject.synapseUUID == nil || self.mainSynapseObject.synapseUUID == rfduino.peripheral.identifier {
                self.mainSynapseObject.connectSynapse(rfduino)

                rfduino.delegate = self
                self.rfduinoManager.connect(rfduino)

                if let nav = self.navigationController as? NavigationController {
                    nav.changeDeviceAssociated()
                }

                if self.canUpdateValuesView {
                    self.setSynapseGraphData(synapseObject: self.mainSynapseObject)
                    /*self.updateSynapseValuesViewTimeLast = Date().timeIntervalSince1970
                     self.updateSynapseValuesView(synapseValues: self.mainSynapseObject.synapseValues)*/
                }
            }
        }
        else {
            self.stopScan()
        }
    }

    func disconnectSynapse(_ rfduino: RFduino) {

        //print("disconnectSynapse")
        if rfduino == self.mainSynapseObject.synapse {
            self.mainSynapseObject.disconnectSynapse()
            self.updateStatusView(synapseObject: self.mainSynapseObject)
        }
        self.synapseGraphData = [:]
        self.resetSynapseValuesView()
        self.resetSynapseGraphImage()
        self.stopAudio()
        if let nav = self.navigationController as? NavigationController {
            nav.changeDeviceAssociated()
        }

        self.startScan()
    }

    func startCommunicationSynapse(_ synapseObject: SynapseObject) {

        synapseObject.synapseSendModeNext = SendMode.I5_3_4
        synapseObject.synapseSendModeSuspension = true
        self.sendFirmwareVersionToDevice(synapseObject)
    }

    func setSynapseData(synapseObject: SynapseObject) {

        let now: Date = Date()
        synapseObject.synapseData.insert(["time": now.timeIntervalSince1970, "data": synapseObject.receiveData], at: 0)
        if synapseObject.synapseData.count > self.synapseDataMax {
            synapseObject.synapseData.removeLast()
        }
        synapseObject.setSynapseValues()

        /*do {
            var data: Data? = try JSONSerialization.data(withJSONObject: synapseObject.synapseData,
                                                        options: .prettyPrinted)
            if let data = data {
                log("setSynapseData: \([UInt8](data).count)")
            }
            data = nil
        }
        catch {}*/

        if let flag = self.getAppinfoValue("is_save_data") as? Bool, flag {
            self.setSynapseValueFile(synapseObject: synapseObject, values: Data(bytes: synapseObject.receiveData), date: now, timeInterval: self.synapseTimeInterval)
        }

        if synapseObject.synapseValues.isConnected {
            synapseObject.setSynapseMaxAndMinValues()

            if self.isSynapseAppActive && self.isUpdateViewActive {
                self.updateSynapseViews()
            }

            //self.synapseNotifications.checkSynapseNotifications(synapseObject.synapseValues)
            self.setAudioValues(synapseObject.synapseValues)

            let timeInterval: TimeInterval = self.synapseTimeInterval
            DispatchQueue.global(qos: .background).async {
                synapseObject.checkSynapseDataSave(timeInterval: timeInterval)
            }

            DispatchQueue.global(qos: .background).async {
                self.setSynapseDataForTodayExtension(synapseObject)
            }
        }

        DispatchQueue.global(qos: .background).async {
            self.sendOSC(synapseValues: synapseObject.synapseValues)
        }
    }

    func setSynapseValueFile(synapseObject: SynapseObject, values: Data, date: Date, timeInterval: TimeInterval) {

        DispatchQueue.global(qos: .background).async {
            _ = synapseObject.synapseRecordFileManager?.setValues(values, date: date, timeInterval: timeInterval)
        }
    }

    func setSynapseDataForTodayExtension(_ synapseObject: SynapseObject) {

        let co2: Int? = synapseObject.synapseValues.co2
        let battery: Float? = synapseObject.synapseValues.battery
        let temp: Float? = synapseObject.synapseValues.temp
        let humidity: Int? = synapseObject.synapseValues.humidity
        let pressure: Float? = synapseObject.synapseValues.pressure

        var flag: Bool = false
        let time: TimeInterval = floor(Date().timeIntervalSince1970 / 60) * 60
        if self.todayExtensionGraphData.count != TodayExtensionData.graphDataCount {
            flag = true
        }
        else {
            if let todayExtensionLastTime = self.todayExtensionLastTime {
                if time - todayExtensionLastTime >= 60.0 {
                    flag = true
                }
            }
            else {
                flag = true
            }
        }

        if !self.todayExtensionUpdating {
            self.todayExtensionUpdating = true

            if flag {
                self.todayExtensionGraphData = []
                var graphTime: TimeInterval = time
                for _ in 0..<TodayExtensionData.graphDataCount {
                    var totalData: [Double] = []
                    if let synapseRecordFileManager = synapseObject.synapseRecordFileManager {
                        let date: Date = Date(timeIntervalSince1970: graphTime)
                        let formatter: DateFormatter = DateFormatter()
                        formatter.locale = Locale(identifier: "en_US_POSIX")
                        formatter.dateFormat = "yyyyMMddHHmmss"
                        let graphDateStr: String = formatter.string(from: date)
                        let day: String = String(graphDateStr[graphDateStr.startIndex..<graphDateStr.index(graphDateStr.startIndex, offsetBy: 8)])
                        let hour: String = String(graphDateStr[graphDateStr.index(graphDateStr.startIndex, offsetBy: 8)..<graphDateStr.index(graphDateStr.startIndex, offsetBy: 10)])
                        let min: String = String(graphDateStr[graphDateStr.index(graphDateStr.startIndex, offsetBy: 10)..<graphDateStr.index(graphDateStr.startIndex, offsetBy: 12)])
                        totalData = synapseRecordFileManager.getSynapseRecordTotal(day: day, hour: hour, min: min, sec: nil, type: self.synapseCrystalInfo.co2.key)
                    }
                    if totalData.count > 1 {
                        self.todayExtensionGraphData.append(Int(totalData[1] / totalData[0]))
                    }
                    else {
                        self.todayExtensionGraphData.append(-1)
                    }
                    graphTime -= 60
                }
                self.todayExtensionLastTime = time
            }
            if let co2 = co2 {
                self.todayExtensionGraphData[0] = co2
            }
            else {
                self.todayExtensionGraphData[0] = -1
            }
            //print("todayExtensionGraphData: \(self.todayExtensionGraphData)")

            self.todayExtensionUpdating = false
        }

        TodayExtensionData.save(co2: co2, battery: battery, temp: temp, humidity: humidity, pressure: pressure, graphData: self.todayExtensionGraphData)
    }

    func reconnectSynapse(_ synapseObject: SynapseObject, uuid: UUID) {

        print("reconnectSynapse: \(uuid.uuidString)")
        //print("reconnectSynapse delegate: \(synapseObject.synapse?.delegate)")
        if uuid == synapseObject.synapseUUID {
            self.sendResetToDevice(synapseObject)
        }
        else {
            synapseObject.synapseUUID = uuid
            synapseObject.synapse?.disconnect()
            if let synapse = synapseObject.synapse {
                self.disconnectSynapse(synapse)
            }
        }
    }

    func removeOldRecords() {

        DispatchQueue.global(qos: .background).async {
            let synapseRecordFileManager: SynapseRecordFileManager = SynapseRecordFileManager()
            synapseRecordFileManager.removeSynapseRecords(self.synapseDataKeepTime)
        }
    }

    // MARK: mark - SynapseData MaxAndMin methods

    func setSynapseMaxAndMinLabel(_ synapseDataMaxAndMins: AllSynapseDataMaxAndMins, synapseValuesMain: SynapseValues) {

        var unitValue: String = ""
        var nowValue: String = ""
        var maxValue: String = ""
        var minValue: String = ""
        let key: String = self.synapseValues[self.focusSynapsePt]
        if key == self.synapseCrystalInfo.co2.key && self.synapseCrystalInfo.co2.hasGraph {
            unitValue = "ppm"
            if let value = synapseValuesMain.co2 {
                nowValue = String(value)
            }
            if let value = synapseDataMaxAndMins.co2.maxNow {
                maxValue = String(format:"%.0f", value)
            }
            if let value = synapseDataMaxAndMins.co2.minNow {
                minValue = String(format:"%.0f", value)
            }
        }
        else if key == self.synapseCrystalInfo.temp.key && self.synapseCrystalInfo.temp.hasGraph {
            unitValue = self.getTemperatureUnit(SettingFileManager.shared.synapseTemperatureScale)
            if let value = synapseValuesMain.temp {
                nowValue = String(format:"%.1f", self.getTemperatureValue(SettingFileManager.shared.synapseTemperatureScale, value: value))
            }
            if let value = synapseDataMaxAndMins.temp.maxNow {
                maxValue = String(format:"%.1f", self.getTemperatureValue(SettingFileManager.shared.synapseTemperatureScale, value: Float(value)))
            }
            if let value = synapseDataMaxAndMins.temp.minNow {
                minValue = String(format:"%.1f", self.getTemperatureValue(SettingFileManager.shared.synapseTemperatureScale, value: Float(value)))
            }
        }
        else if key == self.synapseCrystalInfo.press.key && self.synapseCrystalInfo.press.hasGraph {
            unitValue = "hPa"
            if let value = synapseValuesMain.pressure {
                nowValue = String(format:"%.1f", value)
            }
            if let value = synapseDataMaxAndMins.press.maxNow {
                maxValue = String(format:"%.1f", value)
            }
            if let value = synapseDataMaxAndMins.press.minNow {
                minValue = String(format:"%.1f", value)
            }
        }
        else if key == self.synapseCrystalInfo.ill.key && self.synapseCrystalInfo.ill.hasGraph {
            unitValue = "lux"
            if let value = synapseValuesMain.light {
                nowValue = String(value)
            }
            if let value = synapseDataMaxAndMins.light.maxNow {
                maxValue = String(format:"%.0f", value)
            }
            if let value = synapseDataMaxAndMins.light.minNow {
                minValue = String(format:"%.0f", value)
            }
        }
        else if key == self.synapseCrystalInfo.hum.key && self.synapseCrystalInfo.hum.hasGraph {
            unitValue = "%"
            if let value = synapseValuesMain.humidity {
                nowValue = String(format:"%.1f", Float(value))
            }
            if let value = synapseDataMaxAndMins.hum.maxNow {
                maxValue = String(format:"%.1f", value)
            }
            if let value = synapseDataMaxAndMins.hum.minNow {
                minValue = String(format:"%.1f", value)
            }
        }
        else if key == self.synapseCrystalInfo.sound.key && self.synapseCrystalInfo.sound.hasGraph {
            unitValue = ""
            //unitValue = "dB"
            if let value = synapseValuesMain.sound {
                nowValue = String(value)
            }
            if let value = synapseDataMaxAndMins.sound.maxNow {
                maxValue = String(format:"%.0f", value)
            }
            if let value = synapseDataMaxAndMins.sound.minNow {
                minValue = String(format:"%.0f", value)
            }
        }
        if unitValue.count > 0 {
            unitValue = " \(unitValue)"
        }
        if nowValue.count > 0 {
            nowValue = "\(nowValue)\(unitValue)"
        }
        if maxValue.count > 0 {
            maxValue = "max:\(maxValue)\(unitValue)"
        }
        if minValue.count > 0 {
            minValue = "min:\(minValue)\(unitValue)"
        }

        self.nowValueLabel.text = nowValue
        self.maxValueLabel.text = maxValue
        self.minValueLabel.text = minValue
        self.nowValueLabel.sizeToFit()
        let x: CGFloat = self.min0Label.frame.origin.x + self.min0Label.frame.size.width / 2 - self.nowValueLabel.frame.size.width / 2
        let y: CGFloat = self.graphAreaView.frame.origin.y + self.nowValueLabelY - (self.nowValueLabel.frame.size.height + 8.0)
        let w: CGFloat = self.nowValueLabel.frame.size.width
        let h: CGFloat = self.nowValueLabel.frame.size.height
        self.nowValueLabel.frame = CGRect(x: x, y: y, width: w, height: h)
    }

    // MARK: mark - RFduinoManagerDelegate methods

    func didDiscover(_ rfduino: RFduino!) -> Void {

        //print("didDiscoverRFduino: \(rfduino)")
        self.setRFduinos()
    }

    func didUpdateDiscoveredRFduino(_ rfduino: RFduino!) -> Void {

        //print("didUpdateDiscoveredRFduino: \(rfduino)")
        self.setRFduinos()
    }

    func didConnect(_ rfduino: RFduino!) -> Void {

        //print("didConnectRFduino: \(rfduino)")
        self.stopScan()
    }

    func didLoadServiceRFduino(_ rfduino: RFduino!) -> Void {

        //print("didLoadServiceRFduino: \(rfduino)")
        print("didLoadServiceRFduino UUID: \(rfduino.peripheral.identifier)")
        if self.mainSynapseObject.synapseUUID == rfduino.peripheral.identifier {
            self.startCommunicationSynapse(self.mainSynapseObject)
        }
    }

    func didDisconnectRFduino(_ rfduino: RFduino!) -> Void {

        //print("didDisconnectRFduino: \(rfduino)")
        self.disconnectSynapse(rfduino)
    }

    func shouldDisplayAlertTitled(_ title: String!, messageBody: String!) -> Void {

        //print("shouldDisplayAlertTitled: \(title)")
        if title != "Bluetooth LE Support" {
            if let synapse = self.mainSynapseObject.synapse {
                self.disconnectSynapse(synapse)
            }
        }
        else {
            let alert: UIAlertController = UIAlertController(title: title,
                                                             message: messageBody,
                                                             preferredStyle: UIAlertControllerStyle.alert)
            let defaultAction: UIAlertAction = UIAlertAction(title: "OK",
                                                             style: .default,
                                                             handler: {
                (action:UIAlertAction!) -> Void in
            })
            alert.addAction(defaultAction)
            self.present(alert, animated: true, completion: nil)
        }
    }

    // MARK: mark - RFduinoDelegate methods

    func didReceive(_ data: Data!, peripheralID: UUID, advertisementData: Data, advertisementRSSI: NSNumber) -> Void {
        //print("\(Date()) didReceive byte: \([UInt8](data))\nperipheralID: \(peripheralID)\nadvData: \(String(describing: String(bytes: advertisementData, encoding: .utf8)))\nRSSI: \(Int(advertisementRSSI))")
        /*let val = data.map {
         String(format: "%.2hhx", $0)
         }.joined()
         print("val: \(val)")*/

        if self.mainSynapseObject.synapseUUID == peripheralID {
            if self.mainSynapseObject.synapseSendMode == SendMode.I0 {
                self.setReceiveData(self.mainSynapseObject, data: data)
            }
            else if self.mainSynapseObject.synapseSendMode == SendMode.I1 {
                self.receiveAccessKeyToDevice(self.mainSynapseObject, data: data)
            }
            else if self.mainSynapseObject.synapseSendMode == SendMode.I2 {
                self.receiveStopToDevice(self.mainSynapseObject, data: data)
            }
            else if self.mainSynapseObject.synapseSendMode == SendMode.I3 {
                self.receiveTimeIntervalToDevice(self.mainSynapseObject, data: data)
            }
            else if self.mainSynapseObject.synapseSendMode == SendMode.I4 {
                self.receiveSensorToDevice(self.mainSynapseObject, data: data)
            }
            else if self.mainSynapseObject.synapseSendMode == SendMode.I5 {
                self.receiveFirmwareVersionToDevice(self.mainSynapseObject, data: data)
            }
            else if self.mainSynapseObject.synapseSendMode == SendMode.I6 {
                self.receiveConnectionRequestToDevice(self.mainSynapseObject, data: data)
            }
        }
    }

    func setReceiveData(_ synapseObject: SynapseObject, data: Data) {

        let minLength: Int = 6
        var bytes: [UInt8]? = [UInt8](data)
        var restBytes: [UInt8]? = nil
        var cnt: Int = 0
        if synapseObject.receiveData.count > 2 {
            cnt = Int(synapseObject.receiveData[2])
        }
        else if bytes!.count > 2 && Int(bytes![0]) == 0 && Int(bytes![1]) == 255 {
            cnt = Int(bytes![2])
        }
        if cnt >= minLength {
            for i in 0..<bytes!.count {
                if synapseObject.receiveData.count < cnt {
                    synapseObject.receiveData.append(bytes![i])
                }
                else {
                    if restBytes == nil {
                        restBytes = []
                    }
                    restBytes?.append(bytes![i])
                }
            }
        }
        if cnt >= minLength && synapseObject.receiveData.count == cnt {
            //print("self.receiveData: \(self.receiveData)")
            if Int(synapseObject.receiveData[0]) == 0 && Int(synapseObject.receiveData[1]) == 255 && Int(synapseObject.receiveData[synapseObject.receiveData.count - 2]) == 0 && Int(synapseObject.receiveData[synapseObject.receiveData.count - 1]) == 255 {
                if Int(synapseObject.receiveData[3]) == 2 {
                    self.setSynapseData(synapseObject: synapseObject)
                }
            }

            synapseObject.receiveData = []
            if let bytes = restBytes, bytes.count > 2, Int(bytes[0]) == 0, Int(bytes[1]) == 255, Int(bytes[2]) >= minLength {
                synapseObject.receiveData = bytes
            }
        }
        //print("receiveData: \(self.receiveData)")

        bytes = nil
        restBytes = nil
    }

    // MARK: mark - Send Data To synapseWear methods

    func sendAccessKeyToDevice(_ synapseObject: SynapseObject) {

        if let synapse = synapseObject.synapse, synapseObject.synapseUUID != nil, let accessKey = self.accessKeysFileManager.getAccessKey(synapseObject.synapseUUID!) {
            synapseObject.synapseSendMode = SendMode.I1
            var data: Data = Data(bytes: [0x02])
            if accessKey.count > 8 {
                data.append(accessKey.subdata(in: 0..<8))
            }
            else {
                data.append(accessKey)
            }
            print("sendAccessKeyToDevice: \([UInt8](data))")
            synapse.send(data)
        }
    }

    func receiveAccessKeyToDevice(_ synapseObject: SynapseObject, data: Data) {

        let length: Int = 1
        let bytes: [UInt8] = [UInt8](data)
        //print("receiveAccessKeyToDevice: \(bytes)")
        if bytes.count == length {
            if Int(bytes[0]) == 0 {
                print("receiveAccessKeyToDevice OK")
                synapseObject.synapseValues.isConnected = true
                if let nav = self.navigationController as? NavigationController {
                    nav.changeDeviceAssociated()
                }

                synapseObject.synapseSendModeSuspension = false
                synapseObject.synapseSendMode = SendMode.I0

                _ = self.accessKeysFileManager.setConnectedDate(synapseObject.synapseUUID!)

                self.playAudioStart(synapseObject: self.mainSynapseObject)
            }
            else {
                print("receiveAccessKeyToDevice NG")
                if self.accessKeysFileManager.getAccessKey(synapseObject.synapseUUID!) != nil {
                    self.sendConnectionRequestToDevice(synapseObject)
                }
            }
        }
    }

    func sendStopToDevice(_ synapseObject: SynapseObject) {

        if let synapse = synapseObject.synapse, synapseObject.synapseUUID != nil, let accessKey = self.accessKeysFileManager.getAccessKey(synapseObject.synapseUUID!) {
            synapseObject.synapseSendModeSuspension = true
            synapseObject.synapseSendMode = SendMode.I2
            var data: Data = Data(bytes: [0x03])
            if accessKey.count > 8 {
                data.append(accessKey.subdata(in: 0..<8))
            }
            else {
                data.append(accessKey)
            }
            print("sendStopToDevice: \([UInt8](data))")
            synapse.send(data)
        }
        else {
            synapseObject.synapseSendModeNext = nil
        }
    }

    func receiveStopToDevice(_ synapseObject: SynapseObject, data: Data) {

        let length: Int = 1
        let bytes: [UInt8] = [UInt8](data)
        //print("receiveStopToDevice: \(bytes)")
        if bytes.count == length {
            if Int(bytes[0]) == 0 {
                print("receiveStopToDevice OK")
                if synapseObject.synapseSendModeNext == SendMode.I3 {
                    self.sendTimeIntervalToDevice(synapseObject)
                }
                else if synapseObject.synapseSendModeNext == SendMode.I4 {
                    self.sendSensorToDevice(synapseObject)
                }
                else if synapseObject.synapseSendModeNext == SendMode.I9 {
                    self.sendResetToDevice(synapseObject)
                }
                else {
                    synapseObject.synapseSendMode = SendMode.I0
                }
                synapseObject.synapseSendModeNext = nil
            }
            else {
                print("receiveStopToDevice NG")
                synapseObject.synapseSendModeNext = nil
                if self.accessKeysFileManager.getAccessKey(synapseObject.synapseUUID!) != nil {
                    self.sendAccessKeyToDevice(synapseObject)
                }
                else {
                    self.sendConnectionRequestToDevice(synapseObject)
                }
            }
        }
    }

    func sendSynapseSettingToDeviceStart(_ synapseObject: SynapseObject) {

        synapseObject.synapseSendModeNext = SendMode.I3
        self.sendStopToDevice(synapseObject)
    }

    func resendSynapseSettingToDeviceStart(_ synapseObject: SynapseObject) {

        let mode: String = SettingFileManager.shared.synapseTimeInterval
        let isPlaySound: Bool = SettingFileManager.shared.synapseSoundInfo
        if SettingFileManager.shared.checkSynapseTimeIntervalUpdate(mode, isPlaySound: isPlaySound) {
            self.sendSynapseSettingToDeviceStart(synapseObject)
        }
    }

    func sendTimeIntervalToDeviceStart(_ synapseObject: SynapseObject) {

        if synapseObject.synapseSendModeSuspension {
            self.sendTimeIntervalToDevice(synapseObject)
        }
        else {
            synapseObject.synapseSendModeNext = SendMode.I3
            self.sendStopToDevice(synapseObject)
        }
    }

    func sendTimeIntervalToDevice(_ synapseObject: SynapseObject) {

        if let synapse = synapseObject.synapse {
            self.synapseTimeInterval = self.getSynapseTimeInterval()
            var timeInt: Int = Int(self.synapseTimeInterval * 1000)
            let timeData: [UInt8] = [UInt8](Data(buffer: UnsafeBufferPointer(start: &timeInt, count: 1)))

            var data: Data = Data(bytes: [0x04])
            if timeData.count >= 4 {
                data.append(timeData[3])
            }
            else {
                data.append(0)
            }
            if timeData.count >= 3 {
                data.append(timeData[2])
            }
            else {
                data.append(0)
            }
            if timeData.count >= 2 {
                data.append(timeData[1])
            }
            else {
                data.append(0)
            }
            if timeData.count >= 1 {
                data.append(timeData[0])
            }
            else {
                data.append(0)
            }
            data.append(SettingFileManager.shared.getSynapseTimeIntervalByteData())

            synapseObject.synapseSendMode = SendMode.I3
            print("sendTimeIntervalToDevice: \([UInt8](data))")
            synapse.send(data)
        }
    }

    func receiveTimeIntervalToDevice(_ synapseObject: SynapseObject, data: Data) {

        let length: Int = 1
        let bytes: [UInt8] = [UInt8](data)
        //print("receiveTimeIntervalToDevice: \(bytes)")
        if bytes.count == length {
            if Int(bytes[0]) == 0 {
                self.synapseTimeIntervalBak = self.synapseTimeInterval
                print("receiveTimeIntervalToDevice OK: \(self.synapseTimeInterval)")
            }
            else {
                self.synapseTimeInterval = self.synapseTimeIntervalBak
                print("receiveTimeIntervalToDevice NG")
            }

            if synapseObject.synapseSendModeNext == SendMode.I5_3_4 {
                self.sendSensorToDevice(synapseObject)
            }
            else {
                synapseObject.synapseSendModeNext = nil
                if self.accessKeysFileManager.getAccessKey(synapseObject.synapseUUID!) != nil {
                    self.sendAccessKeyToDevice(synapseObject)
                }
                else {
                    self.sendConnectionRequestToDevice(synapseObject)
                }
            }
        }
    }

    func getSynapseTimeInterval() -> TimeInterval {

        let mode: String = SettingFileManager.shared.synapseTimeInterval
        let isPlaySound: Bool = SettingFileManager.shared.synapseSoundInfo
        return SettingFileManager.shared.getSynapseTimeInterval(mode, isBackground: !self.isSynapseAppActive, isPlaySound: isPlaySound)
    }

    func sendSensorToDeviceStart(_ synapseObject: SynapseObject) {

        if synapseObject.synapseSendModeSuspension {
            self.sendSensorToDevice(synapseObject)
        }
        else {
            synapseObject.synapseSendModeNext = SendMode.I4
            self.sendStopToDevice(synapseObject)
        }
    }

    func sendSensorToDevice(_ synapseObject: SynapseObject) {

        if let synapse = synapseObject.synapse {
            var data: Data = Data(bytes: [0x05])
            var byte: UInt8 = 0x01
            if let flag = SettingFileManager.shared.synapseValidSensors[self.synapseCrystalInfo.co2.key] {
                if !flag {
                    byte = 0x00
                }
            }
            data.append(byte)

            byte = 0x01
            if let flag = SettingFileManager.shared.synapseValidSensors[self.synapseCrystalInfo.temp.key] {
                if !flag {
                    byte = 0x00
                }
            }
            data.append(byte)

            byte = 0x01
            if let flag = SettingFileManager.shared.synapseValidSensors[self.synapseCrystalInfo.hum.key] {
                if !flag {
                    byte = 0x00
                }
            }
            data.append(byte)

            byte = 0x01
            if let flag = SettingFileManager.shared.synapseValidSensors[self.synapseCrystalInfo.ill.key] {
                if !flag {
                    byte = 0x00
                }
            }
            data.append(byte)

            byte = 0x01
            if let flag = SettingFileManager.shared.synapseValidSensors[self.synapseCrystalInfo.press.key] {
                if !flag {
                    byte = 0x00
                }
            }
            data.append(byte)

            byte = 0x01
            if let flag = SettingFileManager.shared.synapseValidSensors[self.synapseCrystalInfo.sound.key] {
                if !flag {
                    byte = 0x00
                }
            }
            data.append(byte)

            byte = 0x01
            if let flag = SettingFileManager.shared.synapseValidSensors[self.synapseCrystalInfo.move.key] {
                if !flag {
                    byte = 0x00
                }
            }
            data.append(byte)

            byte = 0x01
            if let flag = SettingFileManager.shared.synapseValidSensors[self.synapseCrystalInfo.angle.key] {
                if !flag {
                    byte = 0x00
                }
            }
            data.append(byte)

            byte = 0x01
            if let flag = SettingFileManager.shared.synapseValidSensors[self.synapseCrystalInfo.led.key] {
                if !flag {
                    byte = 0x00
                }
            }
            data.append(byte)

            synapseObject.synapseSendMode = SendMode.I4
            print("sendSensorToDevice: \([UInt8](data))")
            synapse.send(data)
        }
    }

    func receiveSensorToDevice(_ synapseObject: SynapseObject, data: Data) {

        let length: Int = 1
        let bytes: [UInt8] = [UInt8](data)
        //print("receiveTimeIntervalToDevice: \(bytes)")
        if bytes.count == length {
            if Int(bytes[0]) == 0 {
                print("receiveSensorToDevice OK")
            }
            else {
                print("receiveSensorToDevice NG")
            }

            synapseObject.synapseSendModeNext = nil
            if self.accessKeysFileManager.getAccessKey(synapseObject.synapseUUID!) != nil {
                self.sendAccessKeyToDevice(synapseObject)
            }
            else {
                self.sendConnectionRequestToDevice(synapseObject)
            }
        }
    }

    func sendFirmwareVersionToDevice(_ synapseObject: SynapseObject) {

        if let synapse = synapseObject.synapse {
            synapseObject.synapseSendMode = SendMode.I5
            let data: Data = Data(bytes: [0x06])
            print("sendFirmwareVersionToDevice: \([UInt8](data))")
            synapse.send(data)
        }
    }

    func receiveFirmwareVersionToDevice(_ synapseObject: SynapseObject, data: Data) {

        let length: Int = 7
        let bytes: [UInt8] = [UInt8](data)
        //print("receiveFirmwareVersionToDevice: \(bytes)")
        if bytes.count == length {
            if Int(bytes[0]) == 0 {
                let versionVal1: Int = Int(bytes[1])
                let versionVal2: Int = Int(bytes[2])
                let dateVal1: Int = Int(bytes[3]) * 256 * 256 * 256
                let dateVal2: Int = Int(bytes[4]) * 256 * 256
                let dateVal3: Int = Int(bytes[5]) * 256
                let dateVal4: Int = Int(bytes[6])
                SettingFileManager.shared.synapseFirmwareInfo = [
                    "device_version": "\(versionVal1).\(versionVal2)",
                    "date": "\(dateVal1 + dateVal2 + dateVal3 + dateVal4)",
                ]
                print("receiveFirmwareVersionToDevice OK -> \(SettingFileManager.shared.synapseFirmwareInfo)")
                _ = SettingFileManager.shared.saveData()
            }
            else {
                print("receiveFirmwareVersionToDevice Error")
            }

            if synapseObject.synapseSendModeNext == SendMode.I5_3_4 {
                //synapseObject.synapseSendModeNext = SendMode.I4
                self.sendTimeIntervalToDevice(synapseObject)
            }
            else {
                synapseObject.synapseSendModeNext = nil
                if self.accessKeysFileManager.getAccessKey(synapseObject.synapseUUID!) != nil {
                    self.sendAccessKeyToDevice(synapseObject)
                }
                else {
                    self.sendConnectionRequestToDevice(synapseObject)
                }
            }
        }
    }

    func sendConnectionRequestToDevice(_ synapseObject: SynapseObject) {

        if let synapse = synapseObject.synapse {
            synapseObject.synapseSendMode = SendMode.I6
            let data: Data = Data(bytes: [0x10])
            print("sendConnectionRequestToDevice: \([UInt8](data))")
            synapse.send(data)
        }
    }

    func receiveConnectionRequestToDevice(_ synapseObject: SynapseObject, data: Data) {

        let bytes: [UInt8] = [UInt8](data)
        print("receiveConnectionRequestToDevice: \(bytes)")
        if bytes.count > 0 && Int(bytes[0]) == 0 {
            if let synapse = synapseObject.synapse {
                let data: Data = Data(bytes: [0x00])
                synapse.send(data)
            }

            let accessKey: Data = data.subdata(in: 1..<data.count)
            print("receiveConnectionRequestToDevice accessKey: \([UInt8](accessKey))")
            if self.accessKeysFileManager.setAccessKey(synapseObject.synapseUUID!, accessKey: accessKey) {
                self.sendAccessKeyToDevice(synapseObject)
            }
        }
        else if bytes.count > 0 && Int(bytes[0]) == 1 {
            var title: String = "Pair with this synapseWear device?"
            if let uuid = synapseObject.synapseUUID {
                title = "Pair with \(uuid.uuidString)?"
            }
            let alert: UIAlertController = UIAlertController(title: title, message: "", preferredStyle: .alert)

            let yesAction: UIAlertAction = UIAlertAction(title: "Yes", style: .default, handler: {
                (action: UIAlertAction!) -> Void in
                self.sendResetToDevice(synapseObject)
            })
            let noAction: UIAlertAction = UIAlertAction(title: "No", style: .default, handler: {
                (action: UIAlertAction!) -> Void in
            })
            alert.addAction(yesAction)
            alert.addAction(noAction)
            self.present(alert, animated: true, completion: nil)
        }
        else {
            print("receiveConnectionRequestToDevice Error")
        }
    }

    func sendDataToDevice(_ synapseObject: SynapseObject, url: URL, firmwareInfo: [String: Any]) {

        if let synapse = synapseObject.synapse {
            print("sendDataToDevice hex: \(url)")
            let data: Data = Data(bytes: [0xfe])
            synapse.send(data)
            //self.disconnectSynapse()

            let vc: OTABootloaderViewController = OTABootloaderViewController()
            vc.fileURL = url
            self.navigationController?.present(vc, animated: true, completion: nil)
        }
    }

    /*func sendResetToDeviceStart(_ synapseObject: SynapseObject) {

        synapseObject.synapseSendModeNext = SendMode.I9
        self.sendStopToDevice(synapseObject)
    }*/

    func sendResetToDevice(_ synapseObject: SynapseObject) {

        synapseObject.synapseSendModeNext = nil
        if let synapse = synapseObject.synapse {
            let data: Data = Data(bytes: [0x12, 0x01])
            print("sendResetToDevice: \([UInt8](data))")
            synapse.send(data)

            self.sendConnectionRequestToDevice(synapseObject)
            //synapse.disconnect()
        }
    }

    func sendLEDFlashToDevice(_ synapseObject: SynapseObject) {

        if let synapse = synapseObject.synapse {
            let data: Data = Data(bytes: [0x13])
            print("sendLEDFlashToDevice: \([UInt8](data))")
            synapse.send(data)
        }
    }

    // MARK: mark - OSC methods

    func setOSCClient() {

        self.oscClient = nil
        self.oscSendMode = SettingFileManager.shared.oscSendMode
        if self.oscSendMode == "on" {
            let oscIPAddress: String = SettingFileManager.shared.oscSendIPAddress
            let oscPort: String = SettingFileManager.shared.oscSendPort
            if oscIPAddress.count > 0, let oscPortNum = UInt16(oscPort) {
                self.oscClient = F53OSCClient.init()
                self.oscClient?.host = oscIPAddress
                self.oscClient?.port = oscPortNum
            }
        }
        /*if let settingData = SettingFileManager().getSettingData(), let oscRecvMode = settingData["osc_recv_mode"] as? String {
            self.oscRecvMode = oscRecvMode
        }*/
    }

    func sendOSC(synapseValues: SynapseValues) {

        if let oscClient = self.oscClient, self.oscSendMode == "on" {
            var arguments: [Any] = [
                0, // time
                0, // co2
                0, // ax
                0, // ay
                0, // az
                0, // light
                0, // gx
                0, // gy
                0, // gz
                0, // pressure
                0, // temp
                0, // humidity
                0, // sound
                0, // tvoc
                0, // volt
                0, // pow
            ]
            if let time = synapseValues.time {
                arguments[0] = time
            }
            if let co2 = synapseValues.co2 {
                arguments[1] = co2
                //self.sendMessage(client: oscClient, addressPattern: "/gas/co2", arguments: [co2])
            }
            if let ax = synapseValues.ax {
                arguments[2] = ax
                //self.sendMessage(client: oscClient, addressPattern: "/acceleromter/x", arguments: [ax])
            }
            if let ay = synapseValues.ay {
                arguments[3] = ay
                //self.sendMessage(client: oscClient, addressPattern: "/acceleromter/y", arguments: [ay])
            }
            if let az = synapseValues.az {
                arguments[4] = az
                //self.sendMessage(client: oscClient, addressPattern: "/acceleromter/z", arguments: [az])
            }
            if let light = synapseValues.light {
                arguments[5] = light
                //self.sendMessage(client: oscClient, addressPattern: "/illumination", arguments: [light])
            }
            if let gx = synapseValues.gx {
                arguments[6] = gx
                //self.sendMessage(client: oscClient, addressPattern: "/movement/x", arguments: [gx])
            }
            if let gy = synapseValues.gy {
                arguments[7] = gy
                //self.sendMessage(client: oscClient, addressPattern: "/movement/y", arguments: [gy])
            }
            if let gz = synapseValues.gz {
                arguments[8] = gz
                //self.sendMessage(client: oscClient, addressPattern: "/movement/z", arguments: [gz])
            }
            if let pressure = synapseValues.pressure {
                arguments[9] = pressure
                //self.sendMessage(client: oscClient, addressPattern: "/pressure", arguments: [pressure])
            }
            if let temp = synapseValues.temp {
                arguments[10] = temp
                //self.sendMessage(client: oscClient, addressPattern: "/temperature", arguments: [temp])
            }
            if let humidity = synapseValues.humidity {
                arguments[11] = humidity
                //self.sendMessage(client: oscClient, addressPattern: "/humidity", arguments: [humidity])
            }
            if let sound = synapseValues.sound {
                arguments[12] = sound
                //self.sendMessage(client: oscClient, addressPattern: "/sound", arguments: [sound])
            }
            if let tvoc = synapseValues.tvoc {
                arguments[13] = tvoc
                //self.sendMessage(client: oscClient, addressPattern: "/tvoc", arguments: [tvoc])
            }
            if let volt = synapseValues.power {
                arguments[14] = volt
                //self.sendMessage(client: oscClient, addressPattern: "/volt", arguments: [volt])
            }
            if let pow = synapseValues.battery {
                arguments[15] = pow
                //self.sendMessage(client: oscClient, addressPattern: "/pow", arguments: [pow])
            }
            /*if let mx = synapseValues.mx {
                arguments[9] = mx
                //self.sendMessage(client: oscClient, addressPattern: "/magnetic/x", arguments: [mx])
            }
            if let my = synapseValues.my {
                arguments[10] = my
                //self.sendMessage(client: oscClient, addressPattern: "/magnetic/y", arguments: [my])
            }
            if let mz = synapseValues.mz {
                arguments[11] = mz
                //self.sendMessage(client: oscClient, addressPattern: "/magnetic/z", arguments: [mz])
            }*/
            self.sendMessage(client: oscClient, addressPattern: "/synapseWear", arguments: arguments)
        }
    }

    func accelerateSoundKick() {

        DispatchQueue.global(qos: .background).async {
            self.sendKickOSC(name: self.synapseSound?.name)
        }
    }

    func sendKickOSC(name: String?) {

        //print("sendKickOSC name: \(name)")
        if let oscClient = self.oscClient, self.oscSendMode == "on", name == self.mainSynapseObject.synapseValues.name {
            let synapseValues: SynapseValues = self.mainSynapseObject.synapseValues
            var arguments: [Any] = [
                0, // time
                true, // kick
            ]
            if let time = synapseValues.time {
                arguments[0] = time
            }
            //print("sendKickOSC")
            self.sendMessage(client: oscClient, addressPattern: "/synapseWearKick", arguments: arguments)
        }
    }

    func sendMessage(client: F53OSCClient, addressPattern: String, arguments: [Any]) {

        let message: F53OSCMessage? = F53OSCMessage(addressPattern: addressPattern, arguments: arguments)
        client.send(message)
        //print("Send OSC: '\(String(describing: message))' To: \(client.host):\(client.port)")
    }

    func setOSCRecvMode() {

        if self.oscServer != nil {
            let oscRecvMode: String = SettingFileManager.shared.oscRecvMode
            var oscRecvPort: UInt16?
            if let port = UInt16(SettingFileManager.shared.oscRecvPort) {
                oscRecvPort = port
            }

            if oscRecvMode != "on" {
                if let oscSynapseObject = self.oscSynapseObject, oscSynapseObject.synapseValues.isConnected {
                    oscSynapseObject.synapseValues.isConnected = false
                    oscSynapseObject.synapseCrystalNode.removeSynapseNodes()

                    self.oscServer?.stopListening()
                    self.oscServer?.delegate = nil

                    self.resetCameraNodePosition()
                }
                self.oscSynapseObject = nil
            }
            else if oscRecvMode == "on" {
                if self.oscSynapseObject == nil {
                    self.oscSynapseObject = SynapseObject("osc")
                    self.oscSynapseObject?.synapseCrystalNode.rotateSynapseNodeDuration = self.updateSynapseViewTime
                    self.oscSynapseObject?.synapseCrystalNode.rotateCrystalNodeDuration = self.updateSynapseViewTime
                    self.oscSynapseObject?.synapseCrystalNode.scaleSynapseNodeDuration = self.updateSynapseViewTime
                    self.oscSynapseObject?.offColorTime = self.synapseOffColorTime
                    self.oscSynapseObject?.synapseValues.isConnected = false
                }
                if let oscSynapseObject = self.oscSynapseObject, !oscSynapseObject.synapseValues.isConnected {
                    print("Start OSCRecvMode")
                    self.oscSynapseObject?.synapseValues.isConnected = true
                    self.oscSynapseObject?.synapseCrystalNode.setSynapseNodes(scnView: self.scnView, position: SCNVector3(x: 3.5, y: 0, z: 0))
                    self.oscSynapseObject?.synapseCrystalNode.setColorSynapseNodes(colorLevel: 0)
                    self.redirectCameraNodePosition(name: self.oscSynapseObject!.synapseCrystalNode.name!)

                    if let oscPort = oscRecvPort {
                        self.oscServer?.port = oscPort
                        self.oscServer?.delegate = self
                        if self.oscServer!.startListening() {
                            print("Listening for messages on port: \(self.oscServer!.port)")
                        }
                        else {
                            print("Error: Server was unable to start listening on port: \(self.oscServer!.port)")
                        }
                    }
                }
            }
        }
    }

    func take(_ message: F53OSCMessage!) {

        //print("take: \(String(describing: message))")
        if message.addressPattern == "/synapseWear" {
            //print("take: \(message)")

            if self.oscSynapseObject != nil {
                if let time = message.arguments[0] as? TimeInterval {
                    self.oscSynapseObject?.synapseValues.time = time
                }
                if let co2 = message.arguments[1] as? Int {
                    self.oscSynapseObject?.synapseValues.co2 = co2
                }
                if let ax = message.arguments[2] as? Int {
                    self.oscSynapseObject?.synapseValues.ax = ax
                }
                if let ay = message.arguments[3] as? Int {
                    self.oscSynapseObject?.synapseValues.ay = ay
                }
                if let az = message.arguments[4] as? Int {
                    self.oscSynapseObject?.synapseValues.az = az
                }
                if let light = message.arguments[5] as? Int {
                    self.oscSynapseObject?.synapseValues.light = light
                }
                if let gx = message.arguments[6] as? Int {
                    self.oscSynapseObject?.synapseValues.gx = gx
                }
                if let gy = message.arguments[7] as? Int {
                    self.oscSynapseObject?.synapseValues.gy = gy
                }
                if let gz = message.arguments[8] as? Int {
                    self.oscSynapseObject?.synapseValues.gz = gz
                }
                if let pressure = message.arguments[9] as? Float {
                    self.oscSynapseObject?.synapseValues.pressure = pressure
                }
                if let temp = message.arguments[10] as? Float {
                    self.oscSynapseObject?.synapseValues.temp = temp
                }
                if let humidity = message.arguments[11] as? Int {
                    self.oscSynapseObject?.synapseValues.humidity = humidity
                }
                if let sound = message.arguments[12] as? Int {
                    self.oscSynapseObject?.synapseValues.sound = sound
                }
                if let tvoc = message.arguments[13] as? Int {
                    self.oscSynapseObject?.synapseValues.tvoc = tvoc
                }
                if let volt = message.arguments[14] as? Float {
                    self.oscSynapseObject?.synapseValues.power = volt
                }
                if let pow = message.arguments[15] as? Float {
                    self.oscSynapseObject?.synapseValues.battery = pow
                }
                /*if let mx = message.arguments[9] as? Int {
                    self.synapseValuesOSC.mx = mx
                }
                if let my = message.arguments[10] as? Int {
                    self.synapseValuesOSC.my = my
                }
                if let mz = message.arguments[11] as? Int {
                    self.synapseValuesOSC.mz = mz
                }*/

                self.updateOSCSynapseViews()
            }
            /*DispatchQueue.global(qos: .background).async {
                self.sendOSC()
            }*/
        }
        else if message.addressPattern == "/synapseWearKick" {
            //print("take: \(message)")
        }
    }

    func updateOSCSynapseViews() {

        let now: TimeInterval = Date().timeIntervalSince1970
        //print("\(Date()) updateSynapseViews: \(now)")
        if self.canUpdateCrystalView {
            if self.updateOSCSynapseViewTimeLast == nil || now - self.updateOSCSynapseViewTimeLast! >= self.updateSynapseViewTime {
                if let oscSynapseObject = self.oscSynapseObject, oscSynapseObject.synapseValues.isConnected {
                    self.updateOSCSynapseViewTimeLast = now
                    oscSynapseObject.updateSynapseNode()
                }
            }
        }

        if self.canUpdateValuesView {
            if self.updateOSCSynapseValuesViewTimeLast == nil || now - self.updateOSCSynapseValuesViewTimeLast! >= self.updateSynapseValuesViewTime {
                self.updateOSCSynapseValuesViewTimeLast = now
                if let oscSynapseObject = self.oscSynapseObject, self.synapseValueLabels.name == oscSynapseObject.synapseValues.name {
                    self.updateSynapseValuesView(synapseValues: oscSynapseObject.synapseValues)
                }
            }
        }
    }

    // MARK: mark - StatusView methods

    func initStatusView() {

        self.statusItems = [
            "UUID",
            "Status",
            "Time",
            "CO2",
            "Accelerometer",
            "Light",
            "Gyro",
            "Pressure",
            "Temperature",
            "Humidity",
            "Environmental sound",
            "tVOC",
            "Volt",
            "Pow",
            "OSC Send Mode",
            "Address/Port"
        ]
        if self.oscServer != nil {
            self.statusItems += [
                "OSC Recv Mode",
                "Port"
            ]
        }
        self.statusValues = []
        for _ in self.statusItems {
            self.statusValues.append("")
        }

        self.setStatusButton()
        //self.setStatusView()
    }

    func setStatusButton() {

        var w: CGFloat = 44.0
        var h: CGFloat = 44.0
        var x: CGFloat = self.view.frame.size.width - (w + 10.0)
        var y: CGFloat = self.view.frame.size.height - (h + 10.0)
        self.statusAreaBtn = UIButton()
        self.statusAreaBtn.frame = CGRect(x: x, y: y, width: w, height: h)
        self.statusAreaBtn.backgroundColor = UIColor.clear
        self.statusAreaBtn.addTarget(self, action: #selector(self.setStatusViewHiddenAction), for: .touchUpInside)
        self.view.addSubview(self.statusAreaBtn)

        w = 24.0
        h = 24.0
        x = (self.statusAreaBtn.frame.size.width - w) / 2
        y = (self.statusAreaBtn.frame.size.height - h) / 2
        let icon: UIImageView = UIImageView()
        icon.frame = CGRect(x: x, y: y, width: w, height: h)
        icon.image = UIImage.statusSB
        icon.backgroundColor = UIColor.clear
        self.statusAreaBtn.addSubview(icon)
    }

    func setStatusView() {

        if let nav = self.navigationController as? NavigationController {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var w: CGFloat = nav.view.frame.width
            var h: CGFloat = nav.view.frame.height
            self.statusView = UIView()
            self.statusView?.frame = CGRect(x: x, y: y, width: w, height: h)
            self.statusView?.backgroundColor = UIColor.black.withAlphaComponent(0.8)
            nav.view.addSubview(self.statusView!)

            w = 44.0
            h = 44.0
            x = self.statusView!.frame.size.width - w
            y = 20.0
            if #available(iOS 11.0, *) {
                if y < self.view.safeAreaInsets.top {
                    y = self.view.safeAreaInsets.top
                }
            }
            let closeButton: UIButton = UIButton()
            closeButton.tag = 2
            closeButton.frame = CGRect(x: x, y: y, width: w, height: h)
            closeButton.backgroundColor = UIColor.clear
            closeButton.addTarget(self, action: #selector(self.setStatusViewHiddenAction), for: .touchUpInside)
            self.statusView?.addSubview(closeButton)

            w = 18.0
            h = 18.0
            x = (closeButton.frame.size.width - w) / 2
            y = (closeButton.frame.size.height - h) / 2
            let closeIcon: CrossView = CrossView()
            closeIcon.frame = CGRect(x: x, y: y, width: w, height: h)
            closeIcon.backgroundColor = UIColor.clear
            closeIcon.isUserInteractionEnabled = false
            closeIcon.lineColor = UIColor.white
            closeButton.addSubview(closeIcon)

            x = 10.0
            y = closeButton.frame.origin.y + 44.0
            w = self.statusView!.frame.size.width - x
            h = 50.0
            let titleLabel: UILabel = UILabel()
            titleLabel.frame = CGRect(x: x, y: y, width: w, height: h)
            titleLabel.text = "Status"
            titleLabel.textColor = UIColor.white
            titleLabel.backgroundColor = UIColor.clear
            titleLabel.font = UIFont(name: "HelveticaNeue", size: 24.0)
            titleLabel.textAlignment = .left
            titleLabel.numberOfLines = 1
            self.statusView?.addSubview(titleLabel)

            w = 200.0
            h = 44.0
            x = (self.statusView!.frame.size.width - w) / 2
            y = self.statusView!.frame.size.height - (h + 20.0)
            let analyzeButton: UIButton = UIButton()
            analyzeButton.frame = CGRect(x: x, y: y, width: w, height: h)
            analyzeButton.setTitle("Analyze", for: .normal)
            analyzeButton.setTitleColor(UIColor.white, for: .normal)
            analyzeButton.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 16.0)
            analyzeButton.backgroundColor = UIColor.clear
            analyzeButton.layer.cornerRadius = h / 2
            analyzeButton.clipsToBounds = true
            analyzeButton.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
            analyzeButton.layer.borderWidth = 1.0
            analyzeButton.addTarget(self, action: #selector(self.pushAnalyzeViewAction(_:)), for: .touchUpInside)
            self.statusView?.addSubview(analyzeButton)
            let bgView: UIView = UIView()
            bgView.frame = CGRect(x: 0, y: 0, width: w, height: h)
            bgView.backgroundColor = UIColor.white.withAlphaComponent(0.3)
            analyzeButton.setBackgroundImage(self.getImageFromView(bgView), for: .highlighted)

            x = 0
            y = titleLabel.frame.origin.y + titleLabel.frame.size.height + 10.0
            w = self.statusView!.frame.size.width
            h = (analyzeButton.frame.origin.y - 20.0) - y
            let mainScrollView: UIScrollView = UIScrollView()
            mainScrollView.frame = CGRect(x: x, y: y, width: w, height: h)
            mainScrollView.backgroundColor = UIColor.clear
            self.statusView?.addSubview(mainScrollView)

            self.statusLabels = []
            y = 0
            h = 24.0
            for item in self.statusItems {
                let itemLabel: UILabel = UILabel()
                itemLabel.text = "\(item):"
                itemLabel.textColor = UIColor.white
                itemLabel.backgroundColor = UIColor.clear
                itemLabel.font = UIFont(name: "Migu 2M", size: 14.0)
                itemLabel.textAlignment = .left
                itemLabel.numberOfLines = 1
                itemLabel.sizeToFit()
                x = 10.0
                w = itemLabel.frame.size.width
                itemLabel.frame = CGRect(x: x, y: y, width: w, height: h)
                mainScrollView.addSubview(itemLabel)

                x = itemLabel.frame.origin.x + itemLabel.frame.size.width + 10.0
                w = mainScrollView.frame.size.width - x
                let valueLabel: UILabel = UILabel()
                valueLabel.text = ""
                valueLabel.frame = CGRect(x: x, y: y, width: w, height: h)
                valueLabel.textColor = UIColor.fluorescentPink
                valueLabel.backgroundColor = UIColor.clear
                valueLabel.font = UIFont(name: "Migu 2M", size: 14.0)
                valueLabel.textAlignment = .left
                valueLabel.numberOfLines = 1
                mainScrollView.addSubview(valueLabel)
                self.statusLabels.append(valueLabel)

                y += h
            }
            //y += h + 10.0
            mainScrollView.contentSize = CGSize(width: mainScrollView.frame.width, height: y)
        }
    }

    func removeStatusView() {

        self.statusView?.removeFromSuperview()
        self.statusView = nil
    }

    @objc func setStatusViewHiddenAction() {

        if self.statusView == nil {
            self.setStatusView()
            self.updateStatusView(synapseObject: self.mainSynapseObject)
        }
        else {
            self.removeStatusView()
        }
    }

    func updateStatusView(synapseObject: SynapseObject) {

        if self.statusView != nil {
            var value: String = ""
            if let uuid = synapseObject.synapseUUID {
                value = uuid.uuidString
            }
            self.updateStatusValueLabel(0, value: value)

            value = synapseObject.getDeviceStatus()
            self.updateStatusValueLabel(1, value: value)

            value = ""
            if let time = synapseObject.synapseValues.time {
                let formatter: DateFormatter = DateFormatter()
                formatter.locale = Locale(identifier: "en_US_POSIX")
                formatter.dateFormat = "yyyy/MM/dd HH:mm:ss.SSS"
                value = formatter.string(from: Date(timeIntervalSince1970: time))
            }
            self.updateStatusValueLabel(2, value: value)

            value = ""
            if let co2 = synapseObject.synapseValues.co2 {
                value = "\(String(co2))"
            }
            self.updateStatusValueLabel(3, value: value)

            value = ""
            if let ax = synapseObject.synapseValues.ax, let ay = synapseObject.synapseValues.ay, let az = synapseObject.synapseValues.az {
                value = "\(String(format:"%.4f", self.makeAccelerationValue(Float(ax))))/\(String(format:"%.4f", self.makeAccelerationValue(Float(ay))))/\(String(format:"%.4f", self.makeAccelerationValue(Float(az))))"
            }
            /*if let ax = synapseValues.ax, let ay = synapseValues.ay, let az = synapseValues.az {
                let radx: Double = atan(Double(ax) / sqrt(pow(Double(ay), 2) + pow(Double(az), 2)))
                let rady: Double = atan(Double(ay) / sqrt(pow(Double(ax), 2) + pow(Double(az), 2)))
                let radz: Double = atan(Double(az) / sqrt(pow(Double(ay), 2) + pow(Double(ax), 2)))
                value = "\(String(format:"%.2f", radx * 180.0 / Double.pi))/\(String(format:"%.2f", rady * 180.0 / Double.pi))/\(String(format:"%.2f", radz * 180.0 / Double.pi))"
                //value = "\(String(ax)) | \(String(ay)) | \(String(az))"
            }*/
            self.updateStatusValueLabel(4, value: value)

            value = ""
            if let light = synapseObject.synapseValues.light {
                value = "\(String(light))"
            }
            self.updateStatusValueLabel(5, value: value)

            value = ""
            if let gx = synapseObject.synapseValues.gx, let gy = synapseObject.synapseValues.gy, let gz = synapseObject.synapseValues.gz {
                value = "\(String(format:"%.4f", self.makeGyroscopeValue(Float(gx))))/\(String(format:"%.4f", self.makeGyroscopeValue(Float(gy))))/\(String(format:"%.4f", self.makeGyroscopeValue(Float(gz))))"
            }
            self.updateStatusValueLabel(6, value: value)

            value = ""
            if let pressure = synapseObject.synapseValues.pressure {
                value = "\(String(pressure))"
            }
            self.updateStatusValueLabel(7, value: value)

            value = ""
            if let temp = synapseObject.synapseValues.temp {
                value = "\(String(self.getTemperatureValue(SettingFileManager.shared.synapseTemperatureScale, value: temp)))"
            }
            self.updateStatusValueLabel(8, value: value)

            value = ""
            if let humidity = synapseObject.synapseValues.humidity {
                value = "\(String(humidity))"
            }
            self.updateStatusValueLabel(9, value: value)

            value = ""
            if let sound = synapseObject.synapseValues.sound {
                value = "\(String(sound))"
            }
            self.updateStatusValueLabel(10, value: value)

            value = ""
            if let tvoc = synapseObject.synapseValues.tvoc {
                value = "\(String(tvoc))"
            }
            self.updateStatusValueLabel(11, value: value)

            value = ""
            if let power = synapseObject.synapseValues.power {
                value = "\(String(power))"
            }
            self.updateStatusValueLabel(12, value: value)

            value = ""
            if let battery = synapseObject.synapseValues.battery {
                value = "\(String(battery))"
            }
            self.updateStatusValueLabel(13, value: value)

            value = "\(self.oscSendMode)"
            self.updateStatusValueLabel(14, value: value)

            value = ""
            let oscIPAddress: String = SettingFileManager.shared.oscSendIPAddress
            if oscIPAddress.count > 0 {
                value += oscIPAddress
            }
            let oscPort: String = SettingFileManager.shared.oscSendPort
            if oscPort.count > 0 {
                value += "/\(oscPort)"
            }
            self.updateStatusValueLabel(15, value: value)

            if self.oscServer != nil {
                self.updateStatusValueLabel(16, value: SettingFileManager.shared.oscRecvMode)
                self.updateStatusValueLabel(17, value: SettingFileManager.shared.oscRecvPort)
            }
            else {
                self.updateStatusValueLabel(16, value: "")
                self.updateStatusValueLabel(17, value: "")
            }
        }
    }

    func updateStatusValueLabel(_ pt: Int, value: String) {

        if pt < self.statusLabels.count {
            self.statusLabels[pt].text = value
        }
    }

    // MARK: mark - Audio methods

    func setAudio() {

        self.synapseSound = SynapseSound()
        self.synapseSound?.delegate = self
    }

    func setAudioValues(_ synapseValues: SynapseValues) {

        DispatchQueue.global(qos: .background).async {
            self.synapseSound?.setSynapseValues(synapseValues)
        }
    }

    func changeAudioSetting(synapseObject: SynapseObject, play: Bool) {

        if synapseObject.synapseValues.isConnected, let synapseSound = self.synapseSound {
            if play && !synapseSound.isPlaying {
                self.playAudio()
            }
            else if !play && synapseSound.isPlaying {
                self.stopAudio()
            }
        }
    }

    func checkEnableAudio() -> Bool {

        var flag: Bool = SettingFileManager.shared.synapseSoundInfo
        if flag {
            flag = SettingFileManager.shared.checkPlayableSound(SettingFileManager.shared.synapseTimeInterval)
        }
        return flag
    }

    func playAudioStart(synapseObject: SynapseObject) {

        if self.checkEnableAudio() {
            self.changeAudioSetting(synapseObject: synapseObject, play: true)
        }
    }

    func playAudio() {

        if let synapseSound = self.synapseSound {
            synapseSound.play()

            self.synapseSoundTimer = Timer.scheduledTimer(timeInterval: synapseSound.getRoopTime(),
                                                          target: self,
                                                          selector: #selector(self.checkAudio),
                                                          userInfo: nil,
                                                          repeats: true)
            self.synapseSoundTimer?.fire()
        }
    }

    func stopAudio() {

        self.synapseSoundTimer?.invalidate()
        self.synapseSoundTimer = nil

        self.synapseSound?.stop()
    }

    @objc func checkAudio() {

        let date: Date = Date()
        DispatchQueue.global(qos: .background).async {
            //print("\(Date()) checkSoundTimer")
            self.synapseSound?.checkSound(date: date)
        }
    }

    // MARK: mark - UITraitEnvironment methods

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if #available(iOS 13, *) {
            self.darkmodeCheck()
        }
    }
}

// MARK: class - SynapseObject

class SynapseObject {

    // const
    let synapseConnectLastDateKey: String = "synapseConnectLastDate"
    let synapseCrystalInfo: SynapseCrystalStruct = SynapseCrystalStruct()
    // variables
    var synapseUUID: UUID?
    var synapse: RFduino?
    var synapseSendMode: SendMode!
    var synapseSendModeNext: SendMode?
    var synapseSendModeSuspension: Bool = false
    var receiveData: [UInt8]!
    var synapseData: [[String: Any]]!
    var synapseValues: SynapseValues!
    var synapseValuesBak: SynapseValues?
    var synapseDataMaxAndMins: AllSynapseDataMaxAndMins!
    var synapseNowDate: String!
    var synapseTotalInHourStartDate: Date?
    var synapseCrystalNode: SynapseCrystalNodes!
    var labelNode: LabelNode!
    var synapseRecordFileManager: SynapseRecordFileManager?
    var offColorTime: TimeInterval = 0
    var canSaveSynapseValues: Bool = true
    // send data variables
    var apiPostdata: ApiPostdata?
    var sendDataDateFormatter: DateFormatter = DateFormatter()
    var sendDataLastTime: String = ""
    var sendDataRestTimes: [String] = []
    var sendDataCrystals: [CrystalStruct] = []

    init(_ name: String) {

        self.synapseSendMode = SendMode.I0
        self.receiveData = []
        self.synapseData = []
        self.synapseValues = SynapseValues(name)
        self.synapseDataMaxAndMins = AllSynapseDataMaxAndMins()
        self.synapseNowDate = ""
        self.synapseCrystalNode = SynapseCrystalNodes(name, position: SCNVector3(x: 0, y: 0, z: 0), isDisplay: true)

        self.setSynapseSendDataInfo()
    }

    func setSynapseUUID(_ uuid: UUID) {

        self.synapseUUID = uuid
        self.synapseRecordFileManager = SynapseRecordFileManager()
        self.synapseRecordFileManager?.setSynapseId(self.synapseUUID!.uuidString)
    }

    func connectSynapse(_ rfduino: RFduino) {

        self.synapse = rfduino
        self.setSynapseUUID(rfduino.peripheral.identifier)
        //print("connectSynapse synapseUUID: \(String(describing: self.synapseUUID?.uuidString))")

        self.synapseCrystalNode.setColorSynapseNodes(colorLevel: 0)

        if let synapseRecordFileManager = self.synapseRecordFileManager {
            if UserDefaults.standard.object(forKey: self.synapseConnectLastDateKey) != nil, let dic = UserDefaults.standard.dictionary(forKey: self.synapseConnectLastDateKey), let uuid = self.synapseUUID, let time = dic[uuid.uuidString] as? TimeInterval {
                synapseRecordFileManager.checkEndConnectLog(time)
            }
            let _ = synapseRecordFileManager.setStartConnectLog()
            self.setSynapseConnectLastDate(Date().timeIntervalSince1970)
        }
    }

    func disconnectSynapse() {

        //print("disconnectSynapse")
        if self.synapseValues.isConnected {
            if let synapseRecordFileManager = self.synapseRecordFileManager {
                let _ = synapseRecordFileManager.setEndConnectLog()
            }
            self.removeSynapseConnectLastDate()
        }

        self.synapse = nil
        self.synapseValues.resetValues()
        self.synapseValuesBak = nil
        self.synapseData = []
        self.synapseValues.isConnected = false
        self.resetSynapseNode()

        self.synapseRecordFileManager = nil
        if let uuid = self.synapseUUID {
            self.setSynapseUUID(uuid)
        }
    }

    func setSynapseConnectLastDate(_ time: TimeInterval) {

        if let uuid = self.synapseUUID {
            var synapseConnectLastDateValues: [String: Any] = [:]
            if UserDefaults.standard.object(forKey: self.synapseConnectLastDateKey) != nil, let dic = UserDefaults.standard.dictionary(forKey: self.synapseConnectLastDateKey) {
                synapseConnectLastDateValues = dic
            }
            synapseConnectLastDateValues[uuid.uuidString] = time
            UserDefaults.standard.set(synapseConnectLastDateValues, forKey: self.synapseConnectLastDateKey)
        }
    }

    func removeSynapseConnectLastDate() {

        if let uuid = self.synapseUUID {
            if UserDefaults.standard.object(forKey: self.synapseConnectLastDateKey) != nil, let dic = UserDefaults.standard.dictionary(forKey: self.synapseConnectLastDateKey) {
                var synapseConnectLastDateValues: [String: Any] = dic
                synapseConnectLastDateValues[uuid.uuidString] = nil
                UserDefaults.standard.set(synapseConnectLastDateValues, forKey: self.synapseConnectLastDateKey)
            }
        }
    }

    func getDeviceStatus() -> String {

        var res: String = ""
        if self.synapse != nil {
            if self.synapseValues.isConnected {
                res = "Associated"
            }
            else {
                res = "Not Associated"
            }
        }
        /*else {
            res = "Device Not Found"
        }*/
        return res
    }

    // MARK: mark - CrystalNode methods

    func updateSynapseNode() {

        self.synapseCrystalNode.rotateSynapseNodes(synapseValues: self.synapseValues)
        self.synapseCrystalNode.scaleSynapseNodes(synapseValues: self.synapseValues)
        self.synapseCrystalNode.setColorSynapseNodeFromBatteryLevel(synapseValues: self.synapseValues)
    }

    func resetSynapseNode() {

        self.synapseCrystalNode.scaleSynapseNodes(synapseValues: self.synapseValues)

        var isOff: Bool = true
        if let synapseRecordFileManager = self.synapseRecordFileManager {
            let connectDate: Date? = synapseRecordFileManager.getConnectLastDate()
            //print("getConnectLastDate: \(connectDate)")
            if let date = connectDate {
                let time: TimeInterval = date.timeIntervalSinceNow
                if -time < self.offColorTime {
                    isOff = false
                }
            }
        }
        self.synapseCrystalNode.setColorOffSynapseNodes(isOff)
    }

    // MARK: mark - Make SynapseData methods

    func setSynapseValues() {

        if self.synapseData.count > 0 {
            var synapse: [String: Any]? = self.synapseData[0]
            //print("setSynapseValues: \(synapse)")
            if let time = synapse!["time"] as? TimeInterval, let data = synapse!["data"] as? [UInt8] {
                let formatter: DateFormatter = DateFormatter()
                formatter.locale = Locale(identifier: "en_US_POSIX")
                formatter.dateFormat = "yyyyMMddHHmmss"
                self.synapseNowDate = formatter.string(from: Date(timeIntervalSince1970: time))
                //print("setSynapseNowDate: \(self.synapseNowDate)")

                var values: SynapseValues? = self.makeSynapseData(data)
                self.synapseValues.time = time
                self.synapseValues.axBak = self.synapseValues.ax
                self.synapseValues.ayBak = self.synapseValues.ay
                self.synapseValues.azBak = self.synapseValues.az
                self.synapseValues.gxBak = self.synapseValues.gx
                self.synapseValues.gyBak = self.synapseValues.gy
                self.synapseValues.gzBak = self.synapseValues.gz
                self.synapseValues.co2 = values!.co2
                self.synapseValues.ax = values!.ax
                self.synapseValues.ay = values!.ay
                self.synapseValues.az = values!.az
                self.synapseValues.light = values!.light
                self.synapseValues.gx = values!.gx
                self.synapseValues.gy = values!.gy
                self.synapseValues.gz = values!.gz
                self.synapseValues.pressure = values!.pressure
                self.synapseValues.temp = values!.temp
                self.synapseValues.humidity = values!.humidity
                self.synapseValues.sound = values!.sound
                self.synapseValues.tvoc = values!.tvoc
                self.synapseValues.power = values!.power
                self.synapseValues.battery = values!.battery
                /*self.synapseValues.mx = values.mx
                self.synapseValues.my = values.my
                self.synapseValues.mz = values.mz*/
                //self.synapseValues.debug()
                values = nil

                self.setSynapseConnectLastDate(time)
            }
            synapse = nil
        }
    }

    func makeSynapseData(_ data: [UInt8]) -> SynapseValues {

        //print("makeSynapseData: \(data)")
        let synapseValues: SynapseValues = SynapseValues()
        if data.count >= 6 {
            if data[4] != 0xff || data[5] != 0xff {
                synapseValues.co2 = self.makeSynapseInt(byte1: data[4], byte2: data[5], unsigned: true)
                if let co2 = synapseValues.co2, co2 < 400 {
                    synapseValues.co2 = nil
                }
            }
        }
        if data.count >= 8 {
            if data[6] != 0xff || data[7] != 0xff {
                synapseValues.ax = -self.makeSynapseInt(byte1: data[6], byte2: data[7], unsigned: false)
            }
        }
        if data.count >= 10 {
            if data[8] != 0xff || data[9] != 0xff {
                synapseValues.ay = -self.makeSynapseInt(byte1: data[8], byte2: data[9], unsigned: false)
            }
        }
        if data.count >= 12 {
            if data[10] != 0xff || data[11] != 0xff {
                synapseValues.az = self.makeSynapseInt(byte1: data[10], byte2: data[11], unsigned: false)
            }
        }
        if data.count >= 14 {
            if data[12] != 0xff || data[13] != 0xff {
                synapseValues.gx = -self.makeSynapseInt(byte1: data[12], byte2: data[13], unsigned: false)
            }
        }
        if data.count >= 16 {
            if data[14] != 0xff || data[15] != 0xff {
                synapseValues.gy = -self.makeSynapseInt(byte1: data[14], byte2: data[15], unsigned: false)
            }
        }
        if data.count >= 18 {
            if data[16] != 0xff || data[17] != 0xff {
                synapseValues.gz = self.makeSynapseInt(byte1: data[16], byte2: data[17], unsigned: false)
            }
        }
        if data.count >= 20 {
            if data[18] != 0xff || data[19] != 0xff {
                synapseValues.light = self.makeSynapseInt(byte1: data[18], byte2: data[19], unsigned: true)
            }
        }
        if data.count >= 22 {
            if data[20] != 0xff {
                synapseValues.temp = self.makeSynapseFloat8(byte1: data[20], byte2: data[21])
            }
        }
        if data.count >= 23 {
            if data[22] != 0xff {
                synapseValues.humidity = Int(data[22])
            }
        }
        if data.count >= 26 {
            if data[23] != 0xff || data[24] != 0xff {
                synapseValues.pressure = self.makeSynapseFloat16(byte1: data[23], byte2: data[24], byte3: data[25])
            }
        }
        if data.count >= 28 {
            if data[26] != 0xff || data[27] != 0xff {
                synapseValues.tvoc = self.makeSynapseInt(byte1: data[26], byte2: data[27], unsigned: true)
            }
        }
        if data.count >= 30 {
            if data[28] != 0xff || data[29] != 0xff {
                synapseValues.power = self.makeSynapseVoltageValue(byte1: data[28], byte2: data[29])
            }
        }
        if data.count >= 32 {
            if data[30] != 0xff || data[31] != 0xff {
                synapseValues.battery = self.makeSynapsePowerValue(byte1: data[30], byte2: data[31])
            }
        }
        if data.count >= 34 {
            if data[32] != 0xff || data[33] != 0xff {
                synapseValues.sound = self.makeSynapseInt(byte1: data[32], byte2: data[33], unsigned: true)
                //synapseValues.sound = self.makeSynapseSoundDBValue(byte1: data[32], byte2: data[33])
            }
        }
        /*if synapseValues.count >= 20 {
            synapseValues.my = -self.makeSynapseValue(synapseValues[19] + synapseValues[18], unsigned: false)
        }
        if synapseValues.count >= 22 {
            synapseValues.mx = -self.makeSynapseValue(synapseValues[21] + synapseValues[20], unsigned: false)
        }
        if synapseValues.count >= 24 {
            synapseValues.mz = -self.makeSynapseValue(synapseValues[23] + synapseValues[22], unsigned: false)
        }*/
        return synapseValues
    }

    func makeSynapseInt(byte1: UInt8, byte2: UInt8, unsigned: Bool) -> Int {

        if unsigned {
            return Int(UInt16(byte1) << 8 | UInt16(byte2))
        }
        else {
            return Int(Int16(byte1) << 8 | Int16(byte2))
        }
    }

    func makeSynapseFloat8(byte1: UInt8, byte2: UInt8) -> Float {

        return Float(byte1) + Float(byte2) * 0.01
    }

    func makeSynapseFloat16(byte1: UInt8, byte2: UInt8, byte3: UInt8) -> Float {

        return Float(byte1) * 256.0 + Float(byte2) + Float(byte3) * 0.01
    }
    /*
    func makeSynapseSoundDBValue(byte1: UInt8, byte2: UInt8) -> Int {
        
        let p: Double = Double(self.makeSynapseInt(byte1: byte1, byte2: byte2, unsigned: true))
        if p >= 20.0 {
            return Int(10.0 * log10(pow(p, 2) / pow(20, 2)))
        }
        return 0
    }
     */
    func makeSynapseVoltageValue(byte1: UInt8, byte2: UInt8) -> Float {

        let hex1: Int = Int(byte1)
        let hex2: Int = Int(byte2)
        let value: Int = hex1 << 4 | hex2 >> 4
        return Float(value) * 0.00125
    }

    func makeSynapsePowerValue(byte1: UInt8, byte2: UInt8) -> Float {

        let hex1: Int = Int(byte1)
        let hex2: Int = Int(byte2)
        let decimal: Float = Float(hex2) / 256.0
        return Float(hex1) + decimal
    }
    /*
    func makeSynapseValue(_ str: String, unsigned: Bool) -> Int {

        let hex1: Int = Int(str.substring(to: str.index(str.startIndex, offsetBy: 2)), radix: 16) ?? 0
        let hex2: Int = Int(str.substring(from: str.index(str.startIndex, offsetBy: 2)), radix: 16) ?? 0
        let bytes: [UInt8] = [UInt8(hex1), UInt8(hex2)]
        if unsigned {
            return Int(UInt16(bytes[0]) << 8 | UInt16(bytes[1]))
        }
        else {
            return Int(Int16(bytes[0]) << 8 | Int16(bytes[1]))
        }
    }

    func makeSynapseFloat8(_ str: String, unsigned: Bool) -> Float {

        // TODO unsigned handling
        let hex1: Int = Int(str.substring(to: str.index(str.startIndex, offsetBy: 2)), radix: 16) ?? 0
        let hex2: Int = Int(str.substring(from: str.index(str.startIndex, offsetBy: 2)), radix: 16) ?? 0
        return Float(hex1) + Float(hex2) * 0.01
    }

    func makeSynapseFloat16(_ str: String, unsigned: Bool) -> Float {

        // TODO unsigned handling
        let hex1: Int = Int(str.substring(to: str.index(str.startIndex, offsetBy: 2)), radix: 16) ?? 0
        let hex2: Int = Int(str.substring(with: str.index(str.startIndex, offsetBy: 2)..<str.index(str.startIndex, offsetBy: 4)), radix: 16) ?? 0
        let hex3: Int = Int(str.substring(from: str.index(str.endIndex, offsetBy: -2)), radix: 16) ?? 0
        return Float(hex1 << 8 + hex2) + Float(hex3) * 0.01
    }

    func makeSynapseVoltageValue(_ str: String) -> Float {

        let hex1: Int = Int(str.substring(to: str.index(str.startIndex, offsetBy: 2)), radix: 16) ?? 0
        let hex2: Int = Int(str.substring(from: str.index(str.startIndex, offsetBy: 2)), radix: 16) ?? 0
        let value: Int = hex1 << 4 | hex2 >> 4
        return Float(value) * 0.00125
    }

    func makeSynapsePowerValue(_ str: String) -> Float {

        let hex1: Int = Int(str.substring(to: str.index(str.startIndex, offsetBy: 2)), radix: 16) ?? 0
        let hex2: Int = Int(str.substring(from: str.index(str.startIndex, offsetBy: 2)), radix: 16) ?? 0
        let decimal: Float = Float(hex2) / 256.0
        return Float(hex1) + decimal
    }
     */

    // MARK: mark - Save SynapseData methods

    func checkSynapseDataSave(timeInterval: TimeInterval) {

        //print("check SynapseDataSave start: \(self.canSaveSynapseValues)")
        if self.canSaveSynapseValues, let time = self.synapseValues.time {
            self.canSaveSynapseValues = false
            let timeFloor: TimeInterval = floor(time)
            var timeFloorBak: TimeInterval? = nil
            if let synapseValuesBak = self.synapseValuesBak, let timeBak = synapseValuesBak.time {
                timeFloorBak = floor(timeBak)
            }
            //print("check SynapseDataSave: \(timeFloor) - \(String(describing: timeFloorBak))")

            var isSave: Bool = false
            if timeFloorBak == nil {
                isSave = true
            }
            else if let timeFloorBak = timeFloorBak, timeFloor - timeFloorBak >= 1.0 {
                isSave = true
            }
            if isSave {
                if let synapseValuesBak = self.synapseValuesBak, let timeFloorBak = timeFloorBak, timeFloor - timeFloorBak >= 2.0 {
                    let cnt: Int = Int(timeFloor - timeFloorBak)
                    for i in 1..<cnt {
                        var synapseValuesCopy: SynapseValues? = self.copySynapseValues(synapseValuesBak)
                        synapseValuesCopy!.time = timeFloorBak + 1.0 * TimeInterval(i)
                        DispatchQueue.global(qos: .background).async {
                            _ = self.saveSynapseTotal(synapseValuesCopy!)
                            //print("check saveSynapseTotal: \(String(describing: synapseValuesCopy!.time))")
                            synapseValuesCopy = nil
                        }
                    }
                }
                _ = self.saveSynapseTotal(self.synapseValues)
                //print("check saveSynapseTotal Now: \(String(describing: self.synapseValues.time))")

                self.synapseValuesBak = self.copySynapseValues(self.synapseValues)
            }
            self.canSaveSynapseValues = true
            //print("checkSynapseDataSave end: \(self.canSaveSynapseValues)")
        }
        self.checkSynapseValuesSend(timeInterval: timeInterval)

        DispatchQueue.global(qos: .background).async {
            self.saveSynapseMaxAndMinValues()
        }
        DispatchQueue.global(qos: .background).async {
            self.checkSynapseTotalInHour()
        }
    }

    func copySynapseValues(_ synapseValues: SynapseValues) -> SynapseValues {

        let synapseValuesCopy: SynapseValues = SynapseValues()
        synapseValuesCopy.time = synapseValues.time
        synapseValuesCopy.co2 = synapseValues.co2
        synapseValuesCopy.ax = synapseValues.ax
        synapseValuesCopy.ay = synapseValues.ay
        synapseValuesCopy.az = synapseValues.az
        synapseValuesCopy.gx = synapseValues.gx
        synapseValuesCopy.gy = synapseValues.gy
        synapseValuesCopy.gz = synapseValues.gz
        synapseValuesCopy.light = synapseValues.light
        synapseValuesCopy.pressure = synapseValues.pressure
        synapseValuesCopy.temp = synapseValues.temp
        synapseValuesCopy.humidity = synapseValues.humidity
        synapseValuesCopy.sound = synapseValues.sound
        synapseValuesCopy.tvoc = synapseValues.tvoc
        synapseValuesCopy.power = synapseValues.power
        synapseValuesCopy.battery = synapseValues.battery
        synapseValuesCopy.axBak = synapseValues.axBak
        synapseValuesCopy.ayBak = synapseValues.ayBak
        synapseValuesCopy.azBak = synapseValues.azBak
        synapseValuesCopy.gxBak = synapseValues.gxBak
        synapseValuesCopy.gyBak = synapseValues.gyBak
        synapseValuesCopy.gzBak = synapseValues.gzBak
        return synapseValuesCopy
    }
    /*
    func getSynapseRecordDateStr(_ recordName: String) -> [String] {

        var res: [String] = []
        let arr: [String] = recordName.components(separatedBy: "_")
        if arr.count > 1 {
            if let time = Double(arr[0]) {
                let formatter = DateFormatter()
                formatter.locale = Locale(identifier: "en_US_POSIX")
                formatter.dateFormat = "yyyyMMddHHmmss"
                res.append(formatter.string(from: Date(timeIntervalSince1970: time)))
                res.append(arr[1])
            }
        }
        return res
    }

    func saveSynapseRecord(recordName: String, recordDate: String) -> Bool {

        if let synapseRecordFileManager = self.synapseRecordFileManager {
            let day: String = recordDate.substring(to: recordDate.index(recordDate.startIndex, offsetBy: 8))
            let time: String = recordDate.substring(from: recordDate.index(recordDate.startIndex, offsetBy: 8))
            return synapseRecordFileManager.setSynapseRecord(day: day, time: time, fileName: recordName)
        }
        return false
    }
     */
    func saveSynapseTotal(_ synapseValues: SynapseValues) -> Bool {

        var res: Bool = false
        var dateStr: String = ""
        if let time = synapseValues.time {
            let formatter: DateFormatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.dateFormat = "yyyyMMddHHmmss"
            dateStr = formatter.string(from: Date(timeIntervalSince1970: time))
        }

        if dateStr.count >= 14, let synapseRecordFileManager = self.synapseRecordFileManager {
            //print("saveSynapseTotal: \(dateStr)")
            let day: String = String(dateStr[dateStr.startIndex..<dateStr.index(dateStr.startIndex, offsetBy: 8)])
            let hour: String = String(dateStr[dateStr.index(dateStr.startIndex, offsetBy: 8)..<dateStr.index(dateStr.startIndex, offsetBy: 10)])
            let min: String = String(dateStr[dateStr.index(dateStr.startIndex, offsetBy: 10)..<dateStr.index(dateStr.startIndex, offsetBy: 12)])
            var sec: String = String(dateStr[dateStr.index(dateStr.startIndex, offsetBy: 12)..<dateStr.index(dateStr.startIndex, offsetBy: 14)])
            //print("saveSynapseTotal dateStr: \(day) \(hour) \(min) \(sec)")
            if let secVal = Int(sec) {
                sec = String(Int(secVal / 10))

                if self.synapseCrystalInfo.co2.hasGraph {
                    if let co2 = synapseValues.co2 {
                        res = synapseRecordFileManager.setSynapseRecordTotal(Double(co2), day: day, hour: hour, min: min, sec: sec, type: self.synapseCrystalInfo.co2.key)
                    }
                }
                if self.synapseCrystalInfo.move.hasGraph {
                    if let ax = synapseValues.ax, let ay = synapseValues.ay, let az = synapseValues.az {
                        res = synapseRecordFileManager.setSynapseRecordTotal(Double(ax), day: day, hour: hour, min: min, sec: sec, type: self.synapseCrystalInfo.ax.key)
                        res = synapseRecordFileManager.setSynapseRecordTotal(Double(ay), day: day, hour: hour, min: min, sec: sec, type: self.synapseCrystalInfo.ay.key)
                        res = synapseRecordFileManager.setSynapseRecordTotal(Double(az), day: day, hour: hour, min: min, sec: sec, type: self.synapseCrystalInfo.az.key)
                    }
                }
                if self.synapseCrystalInfo.ill.hasGraph {
                    if let light = synapseValues.light {
                        res = synapseRecordFileManager.setSynapseRecordTotal(Double(light), day: day, hour: hour, min: min, sec: sec, type: self.synapseCrystalInfo.ill.key)
                    }
                }
                if self.synapseCrystalInfo.angle.hasGraph {
                    if let gx = synapseValues.gx, let gy = synapseValues.gy, let gz = synapseValues.gz {
                        res = synapseRecordFileManager.setSynapseRecordTotal(Double(gx), day: day, hour: hour, min: min, sec: sec, type: self.synapseCrystalInfo.gx.key)
                        res = synapseRecordFileManager.setSynapseRecordTotal(Double(gy), day: day, hour: hour, min: min, sec: sec, type: self.synapseCrystalInfo.gy.key)
                        res = synapseRecordFileManager.setSynapseRecordTotal(Double(gz), day: day, hour: hour, min: min, sec: sec, type: self.synapseCrystalInfo.gz.key)
                    }
                }
                if self.synapseCrystalInfo.temp.hasGraph {
                    if let temp = synapseValues.temp {
                        res = synapseRecordFileManager.setSynapseRecordTotal(Double(temp), day: day, hour: hour, min: min, sec: sec, type: self.synapseCrystalInfo.temp.key)
                    }
                }
                if self.synapseCrystalInfo.hum.hasGraph {
                    if let humidity = synapseValues.humidity {
                        res = synapseRecordFileManager.setSynapseRecordTotal(Double(humidity), day: day, hour: hour, min: min, sec: sec, type: self.synapseCrystalInfo.hum.key)
                    }
                }
                if self.synapseCrystalInfo.press.hasGraph {
                    if let pressure = synapseValues.pressure {
                        res = synapseRecordFileManager.setSynapseRecordTotal(Double(pressure), day: day, hour: hour, min: min, sec: sec, type: self.synapseCrystalInfo.press.key)
                    }
                }
                if self.synapseCrystalInfo.sound.hasGraph {
                    if let sound = synapseValues.sound {
                        res = synapseRecordFileManager.setSynapseRecordTotal(Double(sound), day: day, hour: hour, min: min, sec: sec, type: self.synapseCrystalInfo.sound.key)
                    }
                }
                if self.synapseCrystalInfo.volt.hasGraph {
                    if let volt = synapseValues.power {
                        res = synapseRecordFileManager.setSynapseRecordTotal(Double(volt), day: day, hour: hour, min: min, sec: sec, type: self.synapseCrystalInfo.volt.key)
                    }
                }
                /*if self.synapseCrystalInfo.mag.hasGraph {
                    if let mx = synapseValues.mx, let my = synapseValues.my, let mz = synapseValues.mz {
                        res = self.synapseRecordFileManager.setSynapseRecordTotal(Double(mx), day: day, hour: hour, min: min, sec: sec, type: "mx")
                        res = self.synapseRecordFileManager.setSynapseRecordTotal(Double(my), day: day, hour: hour, min: min, sec: sec, type: "my")
                        res = self.synapseRecordFileManager.setSynapseRecordTotal(Double(mz), day: day, hour: hour, min: min, sec: sec, type: "mz")
                        
                        let val: Double = sqrt(pow(Double(mx), 2) + pow(Double(my), 2) + pow(Double(mz), 2))
                        res = self.synapseRecordFileManager.setSynapseRecordTotal(val, day: day, hour: hour, min: min, sec: sec, type: self.synapseCrystalInfo.mag.key)
                    }
                }*/

                if let ax = synapseValues.ax, let ay = synapseValues.ay, let az = synapseValues.az {
                    var axDiff: Int = 0
                    if let axBak = synapseValues.axBak {
                        axDiff = abs(ax - axBak)
                    }
                    var ayDiff: Int = 0
                    if let ayBak = synapseValues.ayBak {
                        ayDiff = abs(ay - ayBak)
                    }
                    var azDiff: Int = 0
                    if let azBak = synapseValues.azBak {
                        azDiff = abs(az - azBak)
                    }
                    //print("saveSynapseTotal aDiff: \(axDiff) \(ayDiff) \(azDiff)")
                    res = synapseRecordFileManager.setSynapseRecordTotal(Double(axDiff), day: day, hour: hour, min: min, sec: sec, type: SynapseRecordTotalType.axDiff.rawValue)
                    res = synapseRecordFileManager.setSynapseRecordTotal(Double(ayDiff), day: day, hour: hour, min: min, sec: sec, type: SynapseRecordTotalType.ayDiff.rawValue)
                    res = synapseRecordFileManager.setSynapseRecordTotal(Double(azDiff), day: day, hour: hour, min: min, sec: sec, type: SynapseRecordTotalType.azDiff.rawValue)
                }
                if let gx = synapseValues.gx, let gy = synapseValues.gy, let gz = synapseValues.gz {
                    var gxDiff: Int = 0
                    if let gxBak = synapseValues.gxBak {
                        gxDiff = abs(gx - gxBak)
                    }
                    var gyDiff: Int = 0
                    if let gyBak = synapseValues.gyBak {
                        gyDiff = abs(gy - gyBak)
                    }
                    var gzDiff: Int = 0
                    if let gzBak = synapseValues.gzBak {
                        gzDiff = abs(gz - gzBak)
                    }
                    //print("saveSynapseTotal gDiff: \(gxDiff) \(gyDiff) \(gzDiff)")
                    res = synapseRecordFileManager.setSynapseRecordTotal(Double(gxDiff), day: day, hour: hour, min: min, sec: sec, type: SynapseRecordTotalType.gxDiff.rawValue)
                    res = synapseRecordFileManager.setSynapseRecordTotal(Double(gyDiff), day: day, hour: hour, min: min, sec: sec, type: SynapseRecordTotalType.gyDiff.rawValue)
                    res = synapseRecordFileManager.setSynapseRecordTotal(Double(gzDiff), day: day, hour: hour, min: min, sec: sec, type: SynapseRecordTotalType.gzDiff.rawValue)
                }
            }
        }
        return res
    }

    func checkSynapseTotalInHour() {

        let nowDate: Date = Date()
        if self.synapseTotalInHourStartDate == nil ||  nowDate.timeIntervalSince(self.synapseTotalInHourStartDate!) >= 10 * 60.0 {
            //print("checkSynapseTotalInHour: \(String(describing: self.synapseTotalInHourStartDate)) - \(nowDate)")
            let date: Date? = self.synapseTotalInHourStartDate
            self.synapseTotalInHourStartDate = nowDate
            self.setSynapseTotalInHour(startDate: date)
        }
    }

    func setSynapseTotalInHour(startDate: Date?) {

        if self.synapseCrystalInfo.co2.hasGraph {
            self.synapseRecordFileManager?.setSynapseRecordTotalInHour(type: self.synapseCrystalInfo.co2.key, start: startDate)
        }
        if self.synapseCrystalInfo.move.hasGraph {
            self.synapseRecordFileManager?.setSynapseRecordTotalInHour(type: self.synapseCrystalInfo.ax.key, start: startDate)
            self.synapseRecordFileManager?.setSynapseRecordTotalInHour(type: self.synapseCrystalInfo.ay.key, start: startDate)
            self.synapseRecordFileManager?.setSynapseRecordTotalInHour(type: self.synapseCrystalInfo.az.key, start: startDate)
        }
        if self.synapseCrystalInfo.ill.hasGraph {
            self.synapseRecordFileManager?.setSynapseRecordTotalInHour(type: self.synapseCrystalInfo.ill.key, start: startDate)
        }
        if self.synapseCrystalInfo.angle.hasGraph {
            self.synapseRecordFileManager?.setSynapseRecordTotalInHour(type: self.synapseCrystalInfo.gx.key, start: startDate)
            self.synapseRecordFileManager?.setSynapseRecordTotalInHour(type: self.synapseCrystalInfo.gy.key, start: startDate)
            self.synapseRecordFileManager?.setSynapseRecordTotalInHour(type: self.synapseCrystalInfo.gz.key, start: startDate)
        }
        if self.synapseCrystalInfo.temp.hasGraph {
            self.synapseRecordFileManager?.setSynapseRecordTotalInHour(type: self.synapseCrystalInfo.temp.key, start: startDate)
        }
        if self.synapseCrystalInfo.hum.hasGraph {
            self.synapseRecordFileManager?.setSynapseRecordTotalInHour(type: self.synapseCrystalInfo.hum.key, start: startDate)
        }
        if self.synapseCrystalInfo.press.hasGraph {
            self.synapseRecordFileManager?.setSynapseRecordTotalInHour(type: self.synapseCrystalInfo.press.key, start: startDate)
        }
        if self.synapseCrystalInfo.sound.hasGraph {
            self.synapseRecordFileManager?.setSynapseRecordTotalInHour(type: self.synapseCrystalInfo.sound.key, start: startDate)
        }
        if self.synapseCrystalInfo.volt.hasGraph {
            self.synapseRecordFileManager?.setSynapseRecordTotalInHour(type: self.synapseCrystalInfo.volt.key, start: startDate)
        }
        /*if self.synapseCrystalInfo.mag.hasGraph {
            self.synapseRecordFileManager.setSynapseRecordTotalInHour(type: "mx")
            self.synapseRecordFileManager.setSynapseRecordTotalInHour(type: "my")
            self.synapseRecordFileManager.setSynapseRecordTotalInHour(type: "mz")
            self.synapseRecordFileManager.setSynapseRecordTotalInHour(type: self.synapseCrystalInfo.mag.key)
        }*/

        self.synapseRecordFileManager?.setSynapseRecordTotalInHour(type: SynapseRecordTotalType.axDiff.rawValue, start: startDate)
        self.synapseRecordFileManager?.setSynapseRecordTotalInHour(type: SynapseRecordTotalType.ayDiff.rawValue, start: startDate)
        self.synapseRecordFileManager?.setSynapseRecordTotalInHour(type: SynapseRecordTotalType.azDiff.rawValue, start: startDate)
        self.synapseRecordFileManager?.setSynapseRecordTotalInHour(type: SynapseRecordTotalType.gxDiff.rawValue, start: startDate)
        self.synapseRecordFileManager?.setSynapseRecordTotalInHour(type: SynapseRecordTotalType.gyDiff.rawValue, start: startDate)
        self.synapseRecordFileManager?.setSynapseRecordTotalInHour(type: SynapseRecordTotalType.gzDiff.rawValue, start: startDate)
    }

    // MARK: mark - SynapseData MaxAndMin methods

    func setSynapseMaxAndMinValues() {

        self.synapseDataMaxAndMins.setValues(synapseValues: self.synapseValues, nowStr: self.synapseNowDate)
    }

    func saveSynapseMaxAndMinValues() {

        if let synapseRecordFileManager = self.synapseRecordFileManager {
            self.synapseDataMaxAndMins.saveValues(synapseRecordFileManager: synapseRecordFileManager)
        }
    }

    // MARK: mark - SynapseData SendToServer methods

    func setSynapseSendDataInfo() {

        self.sendDataDateFormatter.locale = Locale(identifier: "en_US_POSIX")
        self.sendDataDateFormatter.dateFormat = "yyyyMMddHH"
        self.sendDataCrystals = [
            self.synapseCrystalInfo.co2,
            self.synapseCrystalInfo.temp,
            self.synapseCrystalInfo.press,
            self.synapseCrystalInfo.ill,
            self.synapseCrystalInfo.hum,
            self.synapseCrystalInfo.sound,
            self.synapseCrystalInfo.volt,
        ]
    }

    func changeSynapseSendData() {

        self.stopSynapseSendData()

        if SettingFileManager.shared.synapseSendFlag && SettingFileManager.shared.synapseSendURL.count > 0 {
            self.startSynapseSendData(url: SettingFileManager.shared.synapseSendURL)
        }
    }

    func startSynapseSendData(url: String) {

        print("startSynapseSendData: \(url)")
        self.apiPostdata = ApiPostdata(url: url)
        self.checkSynapseValuesSendBackward()
    }

    func stopSynapseSendData() {

        self.sendDataLastTime = ""
        self.sendDataRestTimes = []
        self.apiPostdata = nil
    }

    func checkSynapseValuesSendBackward() {

        if let synapseRecordFileManager = self.synapseRecordFileManager {
            let now: String = self.sendDataDateFormatter.string(from: Date())
            let days: [String] = synapseRecordFileManager.getSynapseRecords()
            for day in days {
                let hours: [String] = synapseRecordFileManager.getSynapseRecords(day: day, type: synapseRecordFileManager.valuesDir)
                for hour in hours {
                    if "\(day)\(hour)" < now {
                        //print("checkSynapseValuesSendBackward: \(day)\(hour)")
                        DispatchQueue.global(qos: .background).async {
                            self.sendSynapseValues(day: day, hour: hour, crystals: self.sendDataCrystals)
                        }
                    }
                }
            }
            self.sendDataLastTime = now
        }
    }

    func checkSynapseValuesSend(timeInterval: TimeInterval) {

        if self.apiPostdata == nil {
            return
        }

        let nowDate: Date = Date()
        let dateStr: String = self.sendDataDateFormatter.string(from: nowDate)
        //print("checkSynapseValuesSend: \(dateStr) - \(self.sendDataLastTime)")
        if self.sendDataLastTime.count >= 10 && dateStr != self.sendDataLastTime {
            if nowDate.timeIntervalSince1970 - floor(nowDate.timeIntervalSince1970 / 3600) * 3600 >= timeInterval {
                if self.sendDataLastTime.count >= 10 {
                    let day: String = String(self.sendDataLastTime[self.sendDataLastTime.startIndex..<self.sendDataLastTime.index(self.sendDataLastTime.startIndex, offsetBy: 8)])
                    let hour: String = String(self.sendDataLastTime[self.sendDataLastTime.index(self.sendDataLastTime.startIndex, offsetBy: 8)..<self.sendDataLastTime.index(self.sendDataLastTime.startIndex, offsetBy: 10)])
                    //print("checkSynapseValuesSend: \(day)\(hour)")

                    DispatchQueue.global(qos: .background).async {
                        self.sendSynapseValues(day: day, hour: hour, crystals: self.sendDataCrystals)
                    }
                }
                self.sendDataLastTime = dateStr
            }
        }
    }

    func sendSynapseValues(day: String, hour: String, crystals: [CrystalStruct]) {

        if day.count < 8 || hour.count < 2 {
            return
        }

        if let apiPostdata = self.apiPostdata, let uuid = self.synapseUUID, let synapseRecordFileManager = self.synapseRecordFileManager {
            if synapseRecordFileManager.getSynapseSendHistory(day: day, hour: hour) {
                return
            }

            var data: [[String: Any]] = []
            let dateFormater: DateFormatter = DateFormatter()
            //dateFormater.locale = Locale.current
            dateFormater.dateFormat = "yyyyMMddHHmmss"
            let strDateFormater: DateFormatter = DateFormatter()
            strDateFormater.locale = Locale(identifier: "en_US_POSIX")
            strDateFormater.dateFormat = "yyyy/MM/dd HH:mm:ss Z"
            for i in 0..<60 {
                let min: String = String(format:"%02d", i)
                if let date = dateFormater.date(from: "\(day)\(hour)\(min)00") {
                    var minData: [String: Any] = [:]
                    for crystal in crystals {
                        let values: [Double] = synapseRecordFileManager.getSynapseRecordTotal(day: day, hour: hour, min: min, sec: nil, type: crystal.key)
                        if values.count > 1 {
                            var key: String = crystal.name
                            if crystal.key == self.synapseCrystalInfo.press.key {
                                key = "airpressure"
                            }
                            else if crystal.key == self.synapseCrystalInfo.volt.key {
                                key = "voltage"
                            }
                            else if crystal.key == self.synapseCrystalInfo.sound.key {
                                key = "envsound"
                            }
                            if crystal.key == self.synapseCrystalInfo.co2.key || crystal.key == self.synapseCrystalInfo.ill.key || crystal.key == self.synapseCrystalInfo.hum.key || crystal.key == self.synapseCrystalInfo.sound.key {
                                minData[key] = Int(values[1] / values[0])
                            }
                            else if crystal.key == self.synapseCrystalInfo.temp.key || crystal.key == self.synapseCrystalInfo.press.key || crystal.key == self.synapseCrystalInfo.volt.key {
                                minData[key] = Float(values[1] / values[0])
                            }
                            else {
                                minData[key] = values[1] / values[0]
                            }
                        }
                    }
                    if minData.keys.count > 0 {
                        minData["date"] = strDateFormater.string(from: date)
                        minData["dateunix"] = Int(date.timeIntervalSince1970)
                        data.append(minData)
                    }
                }
            }

            var sendData: String = ""
            if data.count > 0 {
                let dic: [String: Any] = [
                    "deviceuuid": uuid.uuidString,
                    "data": data,
                    ]
                //print("sendSynapseValues: \(dic)")
                do {
                    let jsonData: Data = try JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
                    if let jsonStr: String = String(bytes: jsonData, encoding: .utf8) {
                        //print("sendSynapseValues: \(jsonStr)")
                        sendData = jsonStr
                    }
                }
                catch {
                    sendData = ""
                }
            }
            print("sendSynapseValues: \(day)\(hour)")
            //print("sendSynapseValues: \(sendData)")

            if sendData.count > 0 {
                apiPostdata.postDataRequest(data: sendData, success: {
                    (response: HTTPURLResponse?) in
                    print("res -> ok: \(String(describing: response?.statusCode))")
                    if let response = response, response.statusCode == 200 {
                        _ = synapseRecordFileManager.setSynapseSendHistory(day: day, hour: hour)

                        if self.sendDataRestTimes.count > 0 {
                            for time in self.sendDataRestTimes {
                                if time.count >= 10 {
                                    let day: String = String(time[time.startIndex..<time.index(time.startIndex, offsetBy: 8)])
                                    let hour: String = String(time[time.index(time.startIndex, offsetBy: 8)..<time.index(time.startIndex, offsetBy: 10)])
                                    print("sendDataRestTime: \(day)\(hour)")
                                    DispatchQueue.global(qos: .background).async {
                                        self.sendSynapseValues(day: day, hour: hour, crystals: self.sendDataCrystals)
                                    }
                                }
                            }
                            self.sendDataRestTimes = []
                        }
                    }
                    else {
                        self.sendDataRestTimes.append("\(day)\(hour)")
                    }
                }, fail: {
                    (error: Error?) in
                    print("res -> error: \(String(describing: error))")
                    self.sendDataRestTimes.append("\(day)\(hour)")
                })
            }
            else {
                _ = synapseRecordFileManager.setSynapseSendHistory(day: day, hour: hour)
            }
        }
    }
}

// MARK: class - SynapseValues

class SynapseValues {

    var name: String?
    var time: TimeInterval?
    var co2: Int?
    var ax: Int?
    var ay: Int?
    var az: Int?
    var gx: Int?
    var gy: Int?
    var gz: Int?
    var light: Int?
    var pressure: Float?
    var temp: Float?
    var humidity: Int?
    var sound: Int?
    var tvoc: Int?
    var power: Float?
    var battery: Float?
    /*var mx: Int?
    var my: Int?
    var mz: Int?*/
    var axBak: Int?
    var ayBak: Int?
    var azBak: Int?
    var gxBak: Int?
    var gyBak: Int?
    var gzBak: Int?
    var isConnected: Bool = false

    init(_ name: String? = nil) {

        self.name = name
    }

    func resetValues() {

        self.time = nil
        self.co2 = nil
        self.ax = nil
        self.ay = nil
        self.az = nil
        self.gx = nil
        self.gy = nil
        self.gz = nil
        self.light = nil
        self.pressure = nil
        self.temp = nil
        self.humidity = nil
        self.sound = nil
        self.tvoc = nil
        self.power = nil
        self.battery = nil
        /*self.mx = nil
        self.my = nil
        self.mz = nil*/
        self.axBak = nil
        self.ayBak = nil
        self.azBak = nil
        self.gxBak = nil
        self.gyBak = nil
        self.gzBak = nil
        self.isConnected = false
    }

    func debug() {

        var str: String = ""
        if let time = self.time {
            str = "\(str)time: \(time)"
        }
        else {
            str = "\(str)time: nil"
        }
        str = "\(str), "
        if let co2 = self.co2 {
            str = "\(str)co2: \(co2)"
        }
        else {
            str = "\(str)co2: nil"
        }
        str = "\(str), "
        if let temp = self.temp {
            str = "\(str)temp: \(temp)"
        }
        else {
            str = "\(str)temp: nil"
        }
        str = "\(str), "
        if let humidity = self.humidity {
            str = "\(str)humidity: \(humidity)"
        }
        else {
            str = "\(str)humidity: nil"
        }
        str = "\(str), "
        if let pressure = self.pressure {
            str = "\(str)pressure: \(pressure)"
        }
        else {
            str = "\(str)pressure: nil"
        }
        str = "\(str), "
        if let light = self.light {
            str = "\(str)light: \(light)"
        }
        else {
            str = "\(str)light: nil"
        }
        str = "\(str), "
        if let sound = self.sound {
            str = "\(str)sound: \(sound)"
        }
        else {
            str = "\(str)sound: nil"
        }
        str = "\(str), "
        if let tvoc = self.tvoc {
            str = "\(str)tvoc: \(tvoc)"
        }
        else {
            str = "\(str)tvoc: nil"
        }
        str = "\(str), "
        if let power = self.power {
            str = "\(str)power: \(power)"
        }
        else {
            str = "\(str)power: nil"
        }
        str = "\(str), "
        if let battery = self.battery {
            str = "\(str)battery: \(battery)"
        }
        else {
            str = "\(str)battery: nil"
        }
        str = "\(str), "
        if let ax = self.ax {
            str = "\(str)ax: \(ax)"
        }
        else {
            str = "\(str)ax: nil"
        }
        str = "\(str), "
        if let ay = self.ay {
            str = "\(str)ay: \(ay)"
        }
        else {
            str = "\(str)ay: nil"
        }
        str = "\(str), "
        if let az = self.az {
            str = "\(str)az: \(az)"
        }
        else {
            str = "\(str)az: nil"
        }
        str = "\(str), "
        if let gx = self.gx {
            str = "\(str)gx: \(gx)"
        }
        else {
            str = "\(str)gx: nil"
        }
        str = "\(str), "
        if let gy = self.gy {
            str = "\(str)gy: \(gy)"
        }
        else {
            str = "\(str)gy: nil"
        }
        str = "\(str), "
        if let gz = self.gz {
            str = "\(str)gz: \(gz)"
        }
        else {
            str = "\(str)gz: nil"
        }
        str = "\(str), "
        if let axBak = self.axBak {
            str = "\(str)axBak: \(axBak)"
        }
        else {
            str = "\(str)axBak: nil"
        }
        str = "\(str), "
        if let ayBak = self.ayBak {
            str = "\(str)ayBak: \(ayBak)"
        }
        else {
            str = "\(str)ayBak: nil"
        }
        str = "\(str), "
        if let azBak = self.azBak {
            str = "\(str)azBak: \(azBak)"
        }
        else {
            str = "\(str)azBak: nil"
        }
        str = "\(str), "
        if let gxBak = self.gxBak {
            str = "\(str)gxBak: \(gxBak)"
        }
        else {
            str = "\(str)gxBak: nil"
        }
        str = "\(str), "
        if let gyBak = self.gyBak {
            str = "\(str)gyBak: \(gyBak)"
        }
        else {
            str = "\(str)gyBak: nil"
        }
        str = "\(str), "
        if let gzBak = self.gzBak {
            str = "\(str)gzBak: \(gzBak)"
        }
        else {
            str = "\(str)gzBak: nil"
        }
        str = "\(str), "
        str = "\(str)isConnected: \(self.isConnected)"
        print(str)
    }
}

// MARK: class - SynapseCrystalNodes

class SynapseCrystalNodes {

    let synapseCrystalInfo: SynapseCrystalStruct = SynapseCrystalStruct()
    let crystalGeometries: CrystalGeometries = CrystalGeometries()
    var name: String?
    var mainNodeRoll: SCNNode?
    var mainNode: SCNNode?
    var mainXNode: SCNNode?
    var mainYNode: SCNNode?
    var mainZNode: SCNNode?
    var co2Node: SCNNode?
    var tempNode: SCNNode?
    var pressureNode: SCNNode?
    var light1Node: SCNNode?
    var light2Node: SCNNode?
    var light3Node: SCNNode?
    var humidityNode: SCNNode?
    var lightingNode: SCNNode?
    var lightingNode2: SCNNode?
    var soundNode: SCNNode?
    /*var magneticXNode: SCNNode?
    var magneticYNode: SCNNode?
    var magneticZNode: SCNNode?*/
    var position: SCNVector3 = SCNVector3(x: 0, y: 0, z: 0)
    var isDisplay: Bool = false
    var rotateX: Double = 0
    var rotateY: Double = 0
    var rotateZ: Double = 0
    var radxBak: Double?
    var radyBak: Double?
    var radzBak: Double?
    var colorLevel: Double?
    var rotateSynapseNodeDuration: TimeInterval = 0
    var rotateCrystalNodeDuration: TimeInterval = 0
    var scaleSynapseNodeDuration: TimeInterval = 0

    init(_ name: String, position: SCNVector3, isDisplay: Bool) {

        self.name = name
        self.position = position
        self.isDisplay = isDisplay
    }

    func setSynapseNodes(scnView: SCNView, position: SCNVector3?) {

        if let position = position {
            self.position = position
        }

        self.mainNodeRoll = SCNNode()
        self.mainNodeRoll?.position = self.position
        scnView.scene?.rootNode.addChildNode(self.mainNodeRoll!)

        self.mainNode = SCNNode()
        self.mainNode?.position = SCNVector3(x: 0, y: 0, z: 0)
        self.mainNodeRoll?.addChildNode(self.mainNode!)

        self.mainXNode = SCNNode()
        self.mainXNode?.position = SCNVector3(x: 0, y: 0, z: 0)
        self.mainNode?.addChildNode(self.mainXNode!)

        self.mainYNode = SCNNode()
        self.mainYNode?.position = SCNVector3(x: 0, y: 0, z: 0)
        self.mainXNode?.addChildNode(self.mainYNode!)

        self.mainZNode = SCNNode()
        self.mainZNode?.position = SCNVector3(x: 0, y: 0, z: 0)
        self.mainYNode?.addChildNode(self.mainZNode!)

        self.co2Node = SCNNode()
        self.co2Node?.geometry = self.crystalGeometries.makeCO2CrystalGeometry(1.0)
        self.co2Node?.position = SCNVector3(x: -0.4, y: 0.6, z: 0.7)
        self.co2Node?.rotation = SCNVector4(x: 0, y: 1.0, z: 0.8, w: Float(Double.pi / 180.0) * 70.0)
        self.co2Node?.geometry?.materials = self.crystalGeometries.setCrystalGeometryColor(0.5)
        self.mainZNode?.addChildNode(self.co2Node!)
        self.co2Node?.name = self.synapseCrystalInfo.co2.key
        if let name = self.name {
            self.co2Node?.name = "\(name)_\(self.synapseCrystalInfo.co2.key)"
        }
        /*self.co2BaseNode = SCNNode()
        self.co2BaseNode.position = SCNVector3(x: 0, y: 0, z: 0.7)
        self.mainNode.addChildNode(self.co2BaseNode)
        self.co2BaseXNode = SCNNode()
        self.co2BaseXNode.position = SCNVector3(x: 0, y: 0, z: 0)
        self.co2BaseNode.addChildNode(self.co2BaseXNode)
        self.co2BaseZNode = SCNNode()
        self.co2BaseZNode.position = SCNVector3(x: 0, y: 0, z: 0)
        self.co2BaseXNode.addChildNode(self.co2BaseZNode)

        self.co2CrystalNode = CrystalNode()
        self.co2CrystalNode.setCrystalNodeScale(1, ratio: 0.7)
        self.co2CrystalNode.setCrystalNodeRotation(x: 0, y: 0, z: 0)
        self.co2CrystalNode.position = SCNVector3(x: 0, y: 0, z: 0)
        self.co2BaseZNode.addChildNode(self.co2CrystalNode)
        self.co2CrystalNode.topNode.name = self.synapseCrystalInfo.co2.key
        self.co2CrystalNode.bottomNode.name = self.synapseCrystalInfo.co2.key*/

        self.tempNode = SCNNode()
        self.tempNode?.geometry = self.crystalGeometries.makeTemperatureCrystalGeometry(1.0)
        self.tempNode?.position = SCNVector3(x: 0.4, y: 0, z: 0.7)
        self.tempNode?.rotation = SCNVector4(x: -0.3, y: -0.5, z: -1.0, w: Float(Double.pi / 180.0) * 120.0)
        self.tempNode?.geometry?.materials = self.crystalGeometries.setCrystalGeometryColor(0.5)
        self.mainZNode?.addChildNode(self.tempNode!)
        self.tempNode?.name = self.synapseCrystalInfo.temp.key
        if let name = self.name {
            self.tempNode?.name = "\(name)_\(self.synapseCrystalInfo.temp.key)"
        }

        self.humidityNode = SCNNode()
        self.humidityNode?.geometry = self.crystalGeometries.makeHumidityCrystalGeometry(1.0)
        self.humidityNode?.position = SCNVector3(x: -0.4, y: -0.45, z: 0.7)
        self.humidityNode?.rotation = SCNVector4(x: -0.5, y: 0, z: 1.0, w: Float(Double.pi / 180.0) * 150.0)
        self.humidityNode?.geometry?.materials = self.crystalGeometries.setCrystalGeometryColor(0.5)
        self.mainZNode?.addChildNode(self.humidityNode!)
        self.humidityNode?.name = self.synapseCrystalInfo.hum.key
        if let name = self.name {
            self.humidityNode?.name = "\(name)_\(self.synapseCrystalInfo.hum.key)"
        }
        
        self.pressureNode = SCNNode()
        self.pressureNode?.geometry = self.crystalGeometries.makePressureCrystalGeometry(3.0)
        self.pressureNode?.position = SCNVector3(x: 0, y: 0, z: -0.45)
        self.pressureNode?.rotation = SCNVector4(x: -0.4, y: -0.8, z: -1.0, w: Float(Double.pi / 180.0) * 90.0)
        self.pressureNode?.geometry?.materials = self.crystalGeometries.setCrystalGeometryColor(0.5)
        self.mainZNode?.addChildNode(self.pressureNode!)
        self.pressureNode?.name = self.synapseCrystalInfo.press.key
        if let name = self.name {
            self.pressureNode?.name = "\(name)_\(self.synapseCrystalInfo.press.key)"
        }

        self.light1Node = SCNNode()
        self.light1Node?.geometry = self.crystalGeometries.makeIlluminationCrystalGeometry(3.0)
        self.light1Node?.position = SCNVector3(x: 0, y: 0, z: 0.2)
        self.light1Node?.rotation = SCNVector4(x: 0, y: 0, z: 1.0, w: Float(Double.pi / 180.0) * 20.0)
        self.light1Node?.geometry?.materials = self.crystalGeometries.setCrystalGeometryColor(0.5)
        self.mainZNode?.addChildNode(self.light1Node!)
        self.light1Node?.name = self.synapseCrystalInfo.ill.key
        if let name = self.name {
            self.light1Node?.name = "\(name)_\(self.synapseCrystalInfo.ill.key)"
        }

        self.light2Node = SCNNode()
        self.light2Node?.geometry = self.crystalGeometries.makeIlluminationCrystalGeometry(3.0)
        self.light2Node?.position = SCNVector3(x: 0, y: 0, z: 0)
        self.light2Node?.rotation = SCNVector4(x: 0, y: 0, z: 1.0, w: Float(Double.pi / 180.0) * 46.0)
        self.light2Node?.geometry?.materials = self.crystalGeometries.setCrystalGeometryColor(0.5)
        self.mainZNode?.addChildNode(self.light2Node!)
        self.light2Node?.name = self.synapseCrystalInfo.ill.key
        if let name = self.name {
            self.light2Node?.name = "\(name)_\(self.synapseCrystalInfo.ill.key)"
        }

        self.light3Node = SCNNode()
        self.light3Node?.geometry = self.crystalGeometries.makeIlluminationCrystalGeometry(3.0)
        self.light3Node?.position = SCNVector3(x: 0, y: 0, z: 0.4)
        self.light3Node?.rotation = SCNVector4(x: 0, y: 0, z: 1.0, w: Float(Double.pi / 180.0) * 150.0)
        self.light3Node?.geometry?.materials = self.crystalGeometries.setCrystalGeometryColor(0.5)
        self.mainZNode?.addChildNode(self.light3Node!)
        self.light3Node?.name = self.synapseCrystalInfo.ill.key
        if let name = self.name {
            self.light3Node?.name = "\(name)_\(self.synapseCrystalInfo.ill.key)"
        }

        self.soundNode = SCNNode()
        self.soundNode?.geometry = self.crystalGeometries.makeMagneticCrystalGeometry(w: 3.0, h: 2.0)
        self.soundNode?.position = SCNVector3(x: 0.1, y: -0.1, z: -0.8)
        self.soundNode?.rotation = SCNVector4(x: 0, y: 0, z: -1.0, w: Float(Double.pi / 180.0) * 90.0)
        self.soundNode?.geometry?.materials = self.crystalGeometries.setCrystalGeometryColor(0.5)
        self.mainZNode?.addChildNode(self.soundNode!)
        self.soundNode?.name = self.synapseCrystalInfo.sound.key
        if let name = self.name {
            self.soundNode?.name = "\(name)_\(self.synapseCrystalInfo.sound.key)"
        }

        /*synapseCrystalNode.magneticXNode = SCNNode()
        synapseCrystalNode.magneticXNode?.geometry = self.crystalGeometries.makeMagneticCrystalGeometry(w: 3.0, h: 1.8)
        synapseCrystalNode.magneticXNode?.position = SCNVector3(x: -0.1, y: 0.3, z: -0.8)
        synapseCrystalNode.magneticXNode?.rotation = SCNVector4(x: 0, y: 0, z: -1.0, w: Float(Double.pi / 180.0) * 90.0)
        synapseCrystalNode.magneticXNode?.geometry?.materials = self.crystalGeometries.setCrystalGeometryColor(0.5)
        synapseCrystalNode.mainZNode?.addChildNode(synapseCrystalNode.magneticXNode!)
        synapseCrystalNode.magneticXNode?.name = self.synapseCrystalInfo.mag.key
        if let name = synapseCrystalNode.name {
            synapseCrystalNode.magneticXNode?.name = "\(name)_\(self.synapseCrystalInfo.mag.key)"
        }

        synapseCrystalNode.magneticYNode = SCNNode()
        synapseCrystalNode.magneticYNode?.geometry = self.crystalGeometries.makeMagneticCrystalGeometry(w: 0.8, h: 1.2)
        synapseCrystalNode.magneticYNode?.position = SCNVector3(x: 0.9, y: -0.5, z: -0.6)
        synapseCrystalNode.magneticYNode?.rotation = SCNVector4(x: 0, y: 0, z: -1.0, w: Float(Double.pi / 180.0) * 110.0)
        synapseCrystalNode.magneticYNode?.geometry?.materials = self.crystalGeometries.setCrystalGeometryColor(0.5)
        synapseCrystalNode.mainZNode?.addChildNode(synapseCrystalNode.magneticYNode!)
        synapseCrystalNode.magneticYNode?.name = self.synapseCrystalInfo.mag.key
        if let name = synapseCrystalNode.name {
            synapseCrystalNode.magneticYNode?.name = "\(name)_\(self.synapseCrystalInfo.mag.key)"
        }

        synapseCrystalNode.magneticZNode = SCNNode()
        synapseCrystalNode.magneticZNode?.geometry = self.crystalGeometries.makeMagneticCrystalGeometry(w: 0.9, h: 1.6)
        synapseCrystalNode.magneticZNode?.position = SCNVector3(x: -0.1, y: -1.1, z: -0.7)
        synapseCrystalNode.magneticZNode?.rotation = SCNVector4(x: 0, y: 0, z: 1.0, w: Float(Double.pi / 180.0) * 160.0)
        synapseCrystalNode.magneticZNode?.geometry?.materials = self.crystalGeometries.setCrystalGeometryColor(0.5)
        synapseCrystalNode.mainZNode?.addChildNode(synapseCrystalNode.magneticZNode!)
        synapseCrystalNode.magneticZNode?.name = self.synapseCrystalInfo.mag.key
        if let name = synapseCrystalNode.name {
            synapseCrystalNode.magneticZNode?.name = "\(name)_\(self.synapseCrystalInfo.mag.key)"
        }*/
        /*
        var width: CGFloat = 0
        var name: String = ""
        if let str = self.synapseCrystalNode.name {
            name = str
            width = 0.1 * CGFloat(str.count)
        }
        self.labelNode = LabelNode(text: name, width: width, textColor: UIColor.white, panelColor: UIColor.clear, textThickness: 0, panelThickness: 0)
        self.labelNode.position = SCNVector3(x: self.synapseCrystalNode.position.x, y: self.synapseCrystalNode.position.y - 2.0, z: self.synapseCrystalNode.position.z)
        self.labelNode.light = SCNLight()
        self.labelNode.light?.type = .spot
        self.labelNode.light?.color = UIColor.white
        scnView.scene?.rootNode.addChildNode(self.labelNode)
         */
        self.lightingNode = SCNNode()
        self.lightingNode?.light = SCNLight()
        self.lightingNode?.light?.type = .omni
        self.lightingNode?.light?.color = UIColor.white
        self.lightingNode?.position = SCNVector3(x: -2.0 + self.position.x, y: 0 + self.position.y, z: 7.0 + self.position.z)
        self.lightingNode?.rotation = SCNVector4(x: 0, y: 1.0, z: 0, w: Float(Double.pi / 180.0) * -20.0)
        scnView.scene?.rootNode.addChildNode(self.lightingNode!)

        self.lightingNode2 = SCNNode()
        self.lightingNode2?.light = SCNLight()
        self.lightingNode2?.light?.type = .spot
        self.lightingNode2?.light?.color = UIColor.white
        self.lightingNode2?.position = SCNVector3(x: 0 + self.position.x, y: 10.0 + self.position.y, z: 0 + self.position.z)
        self.lightingNode2?.rotation = SCNVector4(x: 1.0, y: 0, z: 0, w: Float(Double.pi / 180.0) * -90.0)
        scnView.scene?.rootNode.addChildNode(self.lightingNode2!)
        /*
        let diffuseLightNode: SCNNode = SCNNode()
        diffuseLightNode.light = SCNLight()
        diffuseLightNode.light!.type = .omni
        diffuseLightNode.light!.color = UIColor.white
        diffuseLightNode.position = SCNVector3(x: 2, y: 2, z: 1)
        scene.rootNode.addChildNode(diffuseLightNode)

        let spotNode: SCNNode = SCNNode()
        spotNode.light = SCNLight()
        spotNode.light!.type = .spot
        spotNode.light!.color = UIColor.white
        spotNode.position = SCNVector3(x: -0.5, y: -1.0, z: 2)
        scene.rootNode.addChildNode(spotNode)
         */
    }

    func removeSynapseNodes() {

        self.mainNodeRoll?.removeFromParentNode()
        self.mainNodeRoll = nil
        self.mainNode?.removeFromParentNode()
        self.mainNode = nil
        self.mainXNode?.removeFromParentNode()
        self.mainXNode = nil
        self.mainYNode?.removeFromParentNode()
        self.mainYNode = nil
        self.mainZNode?.removeFromParentNode()
        self.mainZNode = nil
        self.co2Node?.removeFromParentNode()
        self.co2Node = nil
        self.tempNode?.removeFromParentNode()
        self.tempNode = nil
        self.humidityNode?.removeFromParentNode()
        self.humidityNode = nil
        self.pressureNode?.removeFromParentNode()
        self.pressureNode = nil
        self.light1Node?.removeFromParentNode()
        self.light1Node = nil
        self.light2Node?.removeFromParentNode()
        self.light2Node = nil
        self.light3Node?.removeFromParentNode()
        self.light3Node = nil
        self.soundNode?.removeFromParentNode()
        self.soundNode = nil
        /*synapseCrystalNode.magneticXNode?.removeFromParentNode()
        synapseCrystalNode.magneticXNode = nil
        synapseCrystalNode.magneticYNode?.removeFromParentNode()
        synapseCrystalNode.magneticYNode = nil
        synapseCrystalNode.magneticZNode?.removeFromParentNode()
        synapseCrystalNode.magneticZNode = nil*/
        self.lightingNode?.removeFromParentNode()
        self.lightingNode = nil
        self.lightingNode2?.removeFromParentNode()
        self.lightingNode2 = nil
    }

    func rotateSynapseNodes(dx: CGFloat, dy: CGFloat) {

        if let mainNodeRoll = self.mainNodeRoll {
            let aroundSide: SCNVector3 = SCNVector3(x: 0, y: 1, z: 0)
            let actionSide: SCNAction = SCNAction.rotate(by: CGFloat(Double.pi / 180.0) * dx,
                                                         around: aroundSide,
                                                         duration: 0)
            actionSide.timingMode = .easeOut
            mainNodeRoll.runAction(actionSide, completionHandler: {
                //print("mainNodeRoll: \(self.mainNodeRoll.rotation) mainNode: \(self.mainNode.rotation)")
                //self.mainNodeRoll.removeAllActions()
            })

            if let mainNode = self.mainNode {
                let aroundLong: SCNVector3 = SCNVector3(x: Float(cos(mainNodeRoll.rotation.y * mainNodeRoll.rotation.w)),
                                                        y: 0,
                                                        z: Float(sin(mainNodeRoll.rotation.y * mainNodeRoll.rotation.w)))
                let actionLong: SCNAction = SCNAction.rotate(by: CGFloat(Double.pi / 180.0) * dy,
                                                             around: aroundLong,
                                                             duration: 0)
                actionLong.timingMode = .easeOut
                mainNode.runAction(actionLong, completionHandler: {
                    //self.mainNode.removeAllActions()
                })
            }
        }
    }

    func rotateSynapseNodes(synapseValues: SynapseValues) {

        if let mainZNode = self.mainZNode, let ax = synapseValues.ax, let ay = synapseValues.ay, let az = synapseValues.az {
            let radx: Double = atan(Double(ax) / sqrt(pow(Double(ay), 2) + pow(Double(az), 2)))
            let rady: Double = atan(Double(ay) / sqrt(pow(Double(ax), 2) + pow(Double(az), 2)))
            let radz: Double = atan(Double(az) / sqrt(pow(Double(ay), 2) + pow(Double(ax), 2)))

            if let radxBak = self.radxBak, let radyBak = self.radyBak {
                var deltaX: Double = radx - radxBak
                var deltaY: Double = rady - radyBak
                if radz < 0.0 {
                    deltaX = -deltaX
                    deltaY = -deltaY
                }
                self.rotateX += deltaX
                self.rotateY += deltaY
            }
            self.radxBak = radx
            self.radyBak = rady

            let action: SCNAction = SCNAction.rotateTo(x: CGFloat(-self.rotateY),
                                                       y: 0,
                                                       z: CGFloat(-self.rotateX),
                                                       duration: self.rotateSynapseNodeDuration)
            action.timingMode = .easeOut
            mainZNode.runAction(action, completionHandler: {
                //self.mainZNode.removeAllActions()
            })
        }
        /*
        let action: SCNAction = SCNAction.rotateBy(x: 0, y: CGFloat(Float(Double.pi / 180.0) * self.rotationValue), z: 0, duration: self.checkSynapseTime)
        self.co2CrystalNode.runAction(action)
        self.tempCrystalNode.runAction(action)
        self.pressureCrystalNode.runAction(action)
        self.magneticCrystalNode.runAction(action)
        self.lightCrystalNode.runAction(action)
        self.humidityCrystalNode.runAction(action)
         */
    }

    func rotateCrystalNodes() {

        let rotationValue: CGFloat = 1.0
        let action: SCNAction = SCNAction.rotateBy(x: 0,
                                                   y: CGFloat(Double.pi / 180.0) * rotationValue,
                                                   z: 0,
                                                   duration: self.rotateCrystalNodeDuration)
        self.co2Node?.runAction(action, completionHandler: {
            //synapseCrystalNode.co2Node?.removeAllActions()
        })
        self.tempNode?.runAction(action, completionHandler: {
            //synapseCrystalNode.tempNode?.removeAllActions()
        })
        self.humidityNode?.runAction(action, completionHandler: {
            //synapseCrystalNode.humidityNode?.removeAllActions()
        })

        let rotationValue2: CGFloat = 0.5
        let action2: SCNAction = SCNAction.rotateBy(x: 0,
                                                    y: 0,
                                                    z: CGFloat(Double.pi / 180.0) * rotationValue2,
                                                    duration: self.rotateCrystalNodeDuration)
        self.light1Node?.runAction(action2, completionHandler: {
            //synapseCrystalNode.light1Node?.removeAllActions()
        })
        self.light2Node?.runAction(action2, completionHandler: {
            //synapseCrystalNode.light2Node?.removeAllActions()
        })
        self.light3Node?.runAction(action2, completionHandler: {
            //synapseCrystalNode.light3Node?.removeAllActions()
        })

        let rotationValue3: CGFloat = 0.5
        let action3: SCNAction = SCNAction.rotateBy(x: 0,
                                                    y: 0,
                                                    z: CGFloat(Double.pi / 180.0) * -rotationValue3,
                                                    duration: self.rotateCrystalNodeDuration)
        self.pressureNode?.runAction(action3, completionHandler: {
            //synapseCrystalNode.pressureNode?.removeAllActions()
        })
    }

    func scaleSynapseNodes(synapseValues: SynapseValues) {

        let co2Base: Double = 400.0
        let co2BaseScale: CGFloat = 0.8
        let tempBase: Double = 25.0
        let tempBaseScale: CGFloat = 1.0
        let pressBase: Double = 1000.0
        let pressBaseScale: CGFloat = 1.0
        let lightBase: Double = 10000.0
        let lightBaseScale: CGFloat = 1.0
        let humBase: Double = 100.0
        let humBaseScale: CGFloat = 2.0
        let soundBase: Double = 1023.0
        let soundBaseScale: CGFloat = 1.5

        var co2Scale: CGFloat = 1.0
        if synapseValues.isConnected {
            co2Scale = 0
            if let co2 = synapseValues.co2 {
                co2Scale = CGFloat(sqrt(Double(co2)) / sqrt(co2Base)) * co2BaseScale
            }
        }
        let co2Action: SCNAction = SCNAction.scale(to: co2Scale, duration: self.scaleSynapseNodeDuration)
        co2Action.timingMode = .easeOut
        self.co2Node?.runAction(co2Action, completionHandler: {
            //synapseCrystalNode.co2Node?.removeAllActions()
        })

        var tempScale: CGFloat = 1.0
        if synapseValues.isConnected {
            tempScale = 0
            if let temp = synapseValues.temp {
                if temp > 0.0 {
                    tempScale = CGFloat(sqrt(Double(temp)) / sqrt(tempBase)) * tempBaseScale
                }
                else {
                    tempScale = 0
                }
            }
        }
        let tempAction: SCNAction = SCNAction.scale(to: tempScale, duration: self.scaleSynapseNodeDuration)
        tempAction.timingMode = .easeOut
        self.tempNode?.runAction(tempAction, completionHandler: {
            //synapseCrystalNode.tempNode?.removeAllActions()
        })

        var pressScale: CGFloat = 1.0
        if synapseValues.isConnected {
            pressScale = 0
            if let press = synapseValues.pressure {
                pressScale = CGFloat(sqrt(Double(press)) / sqrt(pressBase)) * pressBaseScale
            }
        }
        let pressAction: SCNAction = SCNAction.scale(to: pressScale, duration: self.scaleSynapseNodeDuration)
        pressAction.timingMode = .easeOut
        self.pressureNode?.runAction(pressAction, completionHandler: {
            //synapseCrystalNode.pressureNode?.removeAllActions()
        })

        var lightScale: CGFloat = 1.0
        if synapseValues.isConnected {
            lightScale = 0
            if let light = synapseValues.light {
                lightScale = CGFloat(sqrt(Double(light)) / sqrt(lightBase)) * lightBaseScale
            }
        }
        let lightAction: SCNAction = SCNAction.scale(to: lightScale, duration: self.scaleSynapseNodeDuration)
        lightAction.timingMode = .easeOut
        self.light1Node?.runAction(lightAction, completionHandler: {
            //synapseCrystalNode.light1Node?.removeAllActions()
        })
        self.light2Node?.runAction(lightAction, completionHandler: {
            //synapseCrystalNode.light2Node?.removeAllActions()
        })
        self.light3Node?.runAction(lightAction, completionHandler: {
            //synapseCrystalNode.light3Node?.removeAllActions()
        })

        var humScale: CGFloat = 1.0
        if synapseValues.isConnected {
            humScale = 0
            if let hum = synapseValues.humidity {
                humScale = CGFloat(Double(hum) / humBase) * humBaseScale
            }
        }
        let humAction: SCNAction = SCNAction.scale(to: humScale, duration: self.scaleSynapseNodeDuration)
        humAction.timingMode = .easeOut
        self.humidityNode?.runAction(humAction, completionHandler: {
            //synapseCrystalNode.humidityNode?.removeAllActions()
        })

        var soundScale: CGFloat = 1.0
        if synapseValues.isConnected {
            soundScale = 0
            if let sound = synapseValues.sound {
                soundScale = CGFloat(sqrt(Double(sound)) / sqrt(soundBase)) * soundBaseScale
            }
        }
        let soundAction: SCNAction = SCNAction.scale(to: soundScale, duration: self.scaleSynapseNodeDuration)
        soundAction.timingMode = .easeOut
        self.soundNode?.runAction(soundAction, completionHandler: {
            //synapseCrystalNode.humidityNode?.removeAllActions()
        })

        /*var magxScale: CGFloat = 1.0
        if let mx = synapseValues.mx {
            let val: CGFloat = CGFloat(abs(mx))
            if val <= 200.0 {
                magxScale = val / 200.0
            }
            else {
                magxScale = 1.0 + (val - 200.0) / 5000.0
            }
        }
        if magxScale > 2.0 {
            magxScale = 2.0
        }
        else if magxScale < 0.2 {
            magxScale = 0.2
        }
        let magxAction: SCNAction = SCNAction.scale(to: magxScale, duration: self.updateSynapseViewTime)
        magxAction.timingMode = .easeOut
        synapseCrystalNode.magneticXNode?.runAction(magxAction, completionHandler: {
            //synapseCrystalNode.magneticXNode?.removeAllActions()
        })
        var magyScale: CGFloat = 1.0
        if let my = synapseValues.my {
            let val: CGFloat = CGFloat(abs(my))
            if val <= 200.0 {
                magyScale = val / 200.0
            }
            else {
                magyScale = 1.0 + (val - 200.0) / 5000.0
            }
        }
        if magyScale > 2.0 {
            magyScale = 2.0
        }
        else if magyScale < 0.2 {
            magyScale = 0.2
        }
        let magyAction: SCNAction = SCNAction.scale(to: magyScale, duration: self.updateSynapseViewTime)
        magyAction.timingMode = .easeOut
        synapseCrystalNode.magneticYNode?.runAction(magyAction, completionHandler: {
            //synapseCrystalNode.magneticYNode?.removeAllActions()
        })
        var magzScale: CGFloat = 1.0
        if let mz = synapseValues.mz {
            let val: CGFloat = CGFloat(abs(mz))
            if val <= 200.0 {
                magzScale = val / 200.0
            }
            else {
                magzScale = 1.0 + (val - 200.0) / 5000.0
            }
        }
        if magzScale > 2.0 {
            magzScale = 2.0
        }
        else if magzScale < 0.2 {
            magzScale = 0.2
        }
        let magzAction: SCNAction = SCNAction.scale(to: magzScale, duration: self.updateSynapseViewTime)
        magzAction.timingMode = .easeOut
        synapseCrystalNode.magneticZNode?.runAction(magzAction, completionHandler: {
            //synapseCrystalNode.magneticZNode?.removeAllActions()
            })*/
    }

    func setColorSynapseNodes(colorLevel: Double) {

        self.co2Node?.geometry?.materials = self.crystalGeometries.setCrystalGeometryColor(colorLevel)
        self.tempNode?.geometry?.materials = self.crystalGeometries.setCrystalGeometryColor(colorLevel)
        self.humidityNode?.geometry?.materials = self.crystalGeometries.setCrystalGeometryColor(colorLevel)
        self.pressureNode?.geometry?.materials = self.crystalGeometries.setCrystalGeometryColor(colorLevel)
        self.light1Node?.geometry?.materials = self.crystalGeometries.setCrystalGeometryColor(colorLevel)
        self.light2Node?.geometry?.materials = self.crystalGeometries.setCrystalGeometryColor(colorLevel)
        self.light3Node?.geometry?.materials = self.crystalGeometries.setCrystalGeometryColor(colorLevel)
        self.soundNode?.geometry?.materials = self.crystalGeometries.setCrystalGeometryColor(colorLevel)
        /*synapseCrystalNode.magneticXNode?.geometry?.materials = self.crystalGeometries.setCrystalGeometryColor(colorLevel)
        synapseCrystalNode.magneticYNode?.geometry?.materials = self.crystalGeometries.setCrystalGeometryColor(colorLevel)
        synapseCrystalNode.magneticZNode?.geometry?.materials = self.crystalGeometries.setCrystalGeometryColor(colorLevel)*/
        self.colorLevel = colorLevel
    }

    func setColorSynapseNodeFromBatteryLevel(synapseValues: SynapseValues) {

        if let battery = synapseValues.battery {
            var level: Double = 0
            if battery > 0.0 && battery <= 10.0 {
                level = 0.1
            }
            else if battery > 10.0 && battery <= 30.0 {
                level = 0.2
            }
            else if battery > 30.0 && battery <= 50.0 {
                level = 0.3
            }
            else if battery > 50.0 && battery <= 70.0 {
                level = 0.4
            }
            else if battery > 70.0 {
                level = 0.5
            }
            if level != self.colorLevel {
                self.setColorSynapseNodes(colorLevel: level)
                //print("batteryLevel: \(self.batteryLevel)")
            }
        }
    }

    func setColorOffSynapseNodes(_ isOff: Bool) {

        self.co2Node?.geometry?.materials = self.crystalGeometries.setCrystalGeometryColorOff(isOff)
        self.tempNode?.geometry?.materials = self.crystalGeometries.setCrystalGeometryColorOff(isOff)
        self.humidityNode?.geometry?.materials = self.crystalGeometries.setCrystalGeometryColorOff(isOff)
        self.pressureNode?.geometry?.materials = self.crystalGeometries.setCrystalGeometryColorOff(isOff)
        self.light1Node?.geometry?.materials = self.crystalGeometries.setCrystalGeometryColorOff(isOff)
        self.light2Node?.geometry?.materials = self.crystalGeometries.setCrystalGeometryColorOff(isOff)
        self.light3Node?.geometry?.materials = self.crystalGeometries.setCrystalGeometryColorOff(isOff)
        self.soundNode?.geometry?.materials = self.crystalGeometries.setCrystalGeometryColorOff(isOff)
        /*synapseCrystalNode.magneticXNode?.geometry?.materials = self.crystalGeometries.setCrystalGeometryColorOff(isOff)
        synapseCrystalNode.magneticYNode?.geometry?.materials = self.crystalGeometries.setCrystalGeometryColorOff(isOff)
        synapseCrystalNode.magneticZNode?.geometry?.materials = self.crystalGeometries.setCrystalGeometryColorOff(isOff)*/
        self.colorLevel = nil
    }
}

// MARK: class - SynapseValueLabels

class SynapseValueLabels: CommonFunctionProtocol {

    var valueLabel: UILabel?
    var unitLabel: UILabel?
    var diffLabel: UILabel?

    func setSynapseValueLabels(_ view: UIView, unitLabelText: String, fontSmall: Bool = false) -> UIView {

        let fontS: CGFloat = 60.0
        let fontS2: CGFloat = 40.0
        let fontU: CGFloat = 16.0

        self.valueLabel = UILabel()
        self.valueLabel?.text = ""
        self.valueLabel?.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height)
        self.valueLabel?.textColor = UIColor.white
        self.valueLabel?.backgroundColor = UIColor.clear
        self.valueLabel?.font = UIFont(name: "HelveticaNeue", size: fontS)
        if fontSmall {
            self.valueLabel?.font = UIFont(name: "HelveticaNeue", size: fontS2)
        }
        self.valueLabel?.textAlignment = .center
        self.valueLabel?.numberOfLines = 1
        view.addSubview(self.valueLabel!)

        self.diffLabel = UILabel()
        self.diffLabel?.text = ""
        self.diffLabel?.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        self.diffLabel?.textColor = UIColor.white
        self.diffLabel?.backgroundColor = UIColor.clear
        self.diffLabel?.font = UIFont(name: "HelveticaNeue", size: fontU)
        self.diffLabel?.textAlignment = .center
        self.diffLabel?.numberOfLines = 1
        view.addSubview(self.diffLabel!)

        self.unitLabel = UILabel()
        self.unitLabel?.text = unitLabelText
        self.unitLabel?.textColor = UIColor.white
        self.unitLabel?.backgroundColor = UIColor.clear
        self.unitLabel?.font = UIFont(name: "HelveticaNeue", size: fontU)
        self.unitLabel?.textAlignment = .center
        self.unitLabel?.numberOfLines = 1
        view.addSubview(self.unitLabel!)

        return view
    }

    func updateSynapseValueLabels(_ value: Any, baseW: CGFloat, baseH: CGFloat, floatFormat: String? = nil, option: [String: Any] = [:]) {

        if self.valueLabel != nil, self.unitLabel != nil, self.diffLabel != nil {
            self.diffLabel?.text = ""

            var format: String = "%.1f"
            if let floatFormat = floatFormat {
                format = floatFormat
            }
            var valueStr: String = ""
            if let intVal = value as? Int {
                valueStr = String(format: "%d", intVal)
            }
            else if let floatVal = value as? Float {
                valueStr = String(format: format, self.extendSynapseFloatValue(value: floatVal, option: option))
            }
            if self.valueLabel!.text != valueStr {
                if let text = self.valueLabel!.text {
                    if text.count > 0 {
                        var diffText: String = ""
                        if let intVal = value as? Int {
                            let diffVal: Int = Int(text)!
                            if intVal > diffVal {
                                diffText = "⬆︎ \(String(intVal - diffVal))"
                            }
                            else if intVal < diffVal {
                                diffText = "⬇︎ \(String(diffVal - intVal))"
                            }
                        }
                        else if var floatVal = value as? Float {
                            floatVal = self.extendSynapseFloatValue(value: floatVal, option: option)
                            let diffVal: Float = Float(atof(text))
                            if floatVal > diffVal {
                                diffText = "⬆︎ \(String(format: format, floatVal - diffVal))"
                            }
                            else if floatVal < diffVal {
                                diffText = "⬇︎ \(String(format: format, diffVal - floatVal))"
                            }
                        }
                        self.diffLabel?.text = diffText
                    }
                }

                self.valueLabel?.text = valueStr
                self.valueLabel?.sizeToFit()
                var w: CGFloat = self.valueLabel!.frame.size.width
                var h: CGFloat = self.valueLabel!.frame.size.height
                var x: CGFloat = (baseW - w) / 2
                var y: CGFloat = (baseH - h) / 2
                self.valueLabel?.frame = CGRect(x: x, y: y, width: w, height: h)

                self.unitLabel?.sizeToFit()
                x = x + w + 10.0
                y = y + h - self.unitLabel!.frame.size.height - 5.0
                w = self.unitLabel!.frame.size.width
                h = self.unitLabel!.frame.size.height
                self.unitLabel?.frame = CGRect(x: x, y: y, width: w, height: h)

                self.diffLabel?.sizeToFit()
                w = self.diffLabel!.frame.size.width
                h = self.diffLabel!.frame.size.height
                x = self.valueLabel!.frame.origin.x - (w + 5.0)
                y = self.valueLabel!.frame.origin.y
                if x < 0.0 {
                    x = 0
                    y -= h
                }
                self.diffLabel?.frame = CGRect(x: x, y: y, width: w, height: h)
            }
        }
        else {
            self.resetSynapseValueLabels()
        }
    }

    func resetSynapseValueLabels() {

        self.valueLabel?.text = ""
        self.diffLabel?.text = ""
        self.unitLabel?.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
    }

    func extendSynapseFloatValue(value: Float, option: [String: Any]) -> Float {

        if let tempOption = option["temp"] as? [String: Any], let temperatureScale = tempOption["scale"] as? String {
            return self.getTemperatureValue(temperatureScale, value: value)
        }
        return value
    }
}

// MARK: class - AllSynapseValueLabels

class AllSynapseValueLabels {

    var name: String?
    var co2Labels: SynapseValueLabels = SynapseValueLabels()
    var illLabels: SynapseValueLabels = SynapseValueLabels()
    var movexLabels: SynapseValueLabels = SynapseValueLabels()
    var moveyLabels: SynapseValueLabels = SynapseValueLabels()
    var movezLabels: SynapseValueLabels = SynapseValueLabels()
    var anglexLabels: SynapseValueLabels = SynapseValueLabels()
    var angleyLabels: SynapseValueLabels = SynapseValueLabels()
    var anglezLabels: SynapseValueLabels = SynapseValueLabels()
    var pressLabels: SynapseValueLabels = SynapseValueLabels()
    var tempLabels: SynapseValueLabels = SynapseValueLabels()
    var humLabels: SynapseValueLabels = SynapseValueLabels()
    var soundLabels: SynapseValueLabels = SynapseValueLabels()
    /*var magxLabels: SynapseValueLabels = SynapseValueLabels()
    var magyLabels: SynapseValueLabels = SynapseValueLabels()
    var magzLabels: SynapseValueLabels = SynapseValueLabels()*/
}

// MARK: class - SynapseDataMaxAndMin

class SynapseDataMaxAndMin {

    var maxNow: Double?
    var minNow: Double?
    var max: Double?
    var min: Double?
    var updatedMax: Bool?
    var updatedMin: Bool?
    var dateStr: String?

    func setValues(_ value: Double, nowStr: String) {

        if let dateStr = self.dateStr, let max = self.max, let maxNow = self.maxNow, let min = self.min, let minNow = self.minNow {
            let dateNow: String = String(nowStr[nowStr.startIndex..<nowStr.index(nowStr.startIndex, offsetBy: 12)])
            let dateCheck: String = String(dateStr[dateStr.startIndex..<dateStr.index(dateStr.startIndex, offsetBy: 12)])
            //print("SynapseDataMaxAndMin dateStr: \(dateNow) - \(dateCheck)")
            if maxNow < value {
                self.maxNow = value
                self.updatedMax = true
            }
            if max < value || dateNow != dateCheck {
                self.max = value
                self.updatedMax = true
            }
            if minNow > value {
                self.minNow = value
                self.updatedMin = true
            }
            if min > value || dateNow != dateCheck {
                self.min = value
                self.updatedMin = true
            }
        }
        else {
            self.maxNow = value
            self.max = value
            self.minNow = value
            self.min = value
            self.updatedMax = true
            self.updatedMin = true
        }
        self.dateStr = nowStr
    }

    func saveValuesCheck(_ key: String, synapseRecordFileManager: SynapseRecordFileManager) {

        if let dateStr = self.dateStr {
            if let max = self.max, let updated = self.updatedMax, updated {
                if self.saveValue(max, date: dateStr, type: key, valueType: "max", synapseRecordFileManager: synapseRecordFileManager) {
                    self.updatedMax = false
                }
            }
            if let min = self.min, let updated = self.updatedMin, updated {
                if self.saveValue(min, date: dateStr, type: key, valueType: "min", synapseRecordFileManager: synapseRecordFileManager) {
                    self.updatedMin = false
                }
            }
        }
    }

    func saveValue(_ value: Double, date: String, type: String, valueType: String, synapseRecordFileManager: SynapseRecordFileManager) -> Bool {

        //print("saveSynapseMaxAndMinValue type: \(type), value: \(value), date: \(date), valueType: \(valueType)")
        var res: Bool = false
        if date.count >= 14 {
            let day: String = String(date[date.startIndex..<date.index(date.startIndex, offsetBy: 8)])
            let hour: String = String(date[date.index(date.startIndex, offsetBy: 8)..<date.index(date.startIndex, offsetBy: 10)])
            let min: String = String(date[date.index(date.startIndex, offsetBy: 10)..<date.index(date.startIndex, offsetBy: 12)])
            //print("saveSynapseMaxAndMinValue dateStr: \(day) \(hour) \(min)")
            let valueStr = "\(date)_\(value)"

            res = synapseRecordFileManager.setSynapseRecordValueType(valueStr, day: day, hour: hour, min: min, type: type, valueType: valueType)
            if res {
                var flag: Bool = false
                var records: [String]? = synapseRecordFileManager.getSynapseRecordValueTypeIn10min(day: day, hour: hour, min: Int(min)! / 10, type: type, valueType: valueType)
                if records != nil && records!.count > 0 {
                    let record: [String] = records![0].components(separatedBy: "_")
                    if record.count > 1, let value10min = Double(record[1]) {
                        if (valueType == "max" && value > value10min) || (valueType == "min" && value < value10min) {
                            flag = true
                        }
                    }
                }
                else {
                    flag = true
                }
                if flag {
                    res = synapseRecordFileManager.setSynapseRecordValueTypeIn10min(valueStr, day: day, hour: hour, min: Int(min)! / 10, type: type, valueType: valueType)
                    if res {
                        flag = false
                        records = synapseRecordFileManager.getSynapseRecordValueTypeInHour(day: day, hour: hour, type: type, valueType: valueType)
                        if records != nil && records!.count > 0 {
                            let record: [String] = records![0].components(separatedBy: "_")
                            if record.count > 1, let valueHour = Double(record[1]) {
                                if (valueType == "max" && value > valueHour) || (valueType == "min" && value < valueHour) {
                                    flag = true
                                }
                            }
                        }
                        else {
                            flag = true
                        }
                        if flag {
                            res = synapseRecordFileManager.setSynapseRecordValueTypeInHour(valueStr, day: day, hour: hour, type: type, valueType: valueType)
                        }
                    }
                }
                records = nil
            }
        }
        return res
    }

    func debug() {

        var str: String = ""
        if let maxNow = self.maxNow {
            str = "\(str)maxNow: \(maxNow)"
        }
        else {
            str = "\(str)maxNow: nil"
        }
        str = "\(str), "
        if let max = self.max {
            str = "\(str)max: \(max)"
        }
        else {
            str = "\(str)max: nil"
        }
        str = "\(str), "
        if let updatedMax = self.updatedMax {
            str = "\(str)updatedMax: \(updatedMax)"
        }
        else {
            str = "\(str)updatedMax: nil"
        }
        str = "\(str), "
        if let minNow = self.minNow {
            str = "\(str)minNow: \(minNow)"
        }
        else {
            str = "\(str)minNow: nil"
        }
        str = "\(str), "
        if let min = self.min {
            str = "\(str)min: \(min)"
        }
        else {
            str = "\(str)min: nil"
        }
        str = "\(str), "
        if let updatedMin = self.updatedMin {
            str = "\(str)updatedMin: \(updatedMin)"
        }
        else {
            str = "\(str)updatedMin: nil"
        }
        str = "\(str), "
        if let dateStr = self.dateStr {
            str = "\(str)dateStr: \(dateStr)"
        }
        else {
            str = "\(str)dateStr: nil"
        }
        print(str)
    }
}

// MARK: class - AllSynapseDataMaxAndMins

class AllSynapseDataMaxAndMins {

    let synapseCrystalInfo: SynapseCrystalStruct = SynapseCrystalStruct()
    var co2: SynapseDataMaxAndMin = SynapseDataMaxAndMin()
    var ax: SynapseDataMaxAndMin = SynapseDataMaxAndMin()
    var ay: SynapseDataMaxAndMin = SynapseDataMaxAndMin()
    var az: SynapseDataMaxAndMin = SynapseDataMaxAndMin()
    var light: SynapseDataMaxAndMin = SynapseDataMaxAndMin()
    var gx: SynapseDataMaxAndMin = SynapseDataMaxAndMin()
    var gy: SynapseDataMaxAndMin = SynapseDataMaxAndMin()
    var gz: SynapseDataMaxAndMin = SynapseDataMaxAndMin()
    var press: SynapseDataMaxAndMin = SynapseDataMaxAndMin()
    var temp: SynapseDataMaxAndMin = SynapseDataMaxAndMin()
    var hum: SynapseDataMaxAndMin = SynapseDataMaxAndMin()
    var sound: SynapseDataMaxAndMin = SynapseDataMaxAndMin()
    var volt: SynapseDataMaxAndMin = SynapseDataMaxAndMin()
    /*var mx: SynapseDataMaxAndMin = SynapseDataMaxAndMin()
    var my: SynapseDataMaxAndMin = SynapseDataMaxAndMin()
    var mz: SynapseDataMaxAndMin = SynapseDataMaxAndMin()*/

    func setValues(synapseValues: SynapseValues, nowStr: String) {

        if let co2 = synapseValues.co2 {
            self.co2.setValues(Double(co2), nowStr: nowStr)
        }
        if let ax = synapseValues.ax {
            self.ax.setValues(Double(ax), nowStr: nowStr)
        }
        if let ay = synapseValues.ay {
            self.ay.setValues(Double(ay), nowStr: nowStr)
        }
        if let az = synapseValues.az {
            self.az.setValues(Double(az), nowStr: nowStr)
        }
        if let light = synapseValues.light {
            self.light.setValues(Double(light), nowStr: nowStr)
        }
        if let gx = synapseValues.gx {
            self.gx.setValues(Double(gx), nowStr: nowStr)
        }
        if let gy = synapseValues.gy {
            self.gy.setValues(Double(gy), nowStr: nowStr)
        }
        if let gz = synapseValues.gz {
            self.gz.setValues(Double(gz), nowStr: nowStr)
        }
        if let press = synapseValues.pressure {
            self.press.setValues(Double(press), nowStr: nowStr)
        }
        if let temp = synapseValues.temp {
            self.temp.setValues(Double(temp), nowStr: nowStr)
        }
        if let hum = synapseValues.humidity {
            self.hum.setValues(Double(hum), nowStr: nowStr)
        }
        if let sound = synapseValues.sound {
            self.sound.setValues(Double(sound), nowStr: nowStr)
        }
        if let volt = synapseValues.power {
            self.volt.setValues(Double(volt), nowStr: nowStr)
        }
        /*if let mx = synapseValues.mx {
            self.mx.setValues(Double(mx), nowStr: nowStr)
        }
        if let my = synapseValues.my {
            self.my.setValues(Double(my), nowStr: nowStr)
        }
        if let mz = synapseValues.mz {
            self.mz.setValues(Double(mz), nowStr: nowStr)
        }*/
    }

    func saveValues(synapseRecordFileManager: SynapseRecordFileManager) {

        if self.synapseCrystalInfo.co2.hasGraph {
            self.co2.saveValuesCheck(self.synapseCrystalInfo.co2.key, synapseRecordFileManager: synapseRecordFileManager)
        }
        if self.synapseCrystalInfo.move.hasGraph {
            self.ax.saveValuesCheck(self.synapseCrystalInfo.ax.key, synapseRecordFileManager: synapseRecordFileManager)
            self.ay.saveValuesCheck(self.synapseCrystalInfo.ay.key, synapseRecordFileManager: synapseRecordFileManager)
            self.az.saveValuesCheck(self.synapseCrystalInfo.az.key, synapseRecordFileManager: synapseRecordFileManager)
        }
        if self.synapseCrystalInfo.ill.hasGraph {
            self.light.saveValuesCheck(self.synapseCrystalInfo.ill.key, synapseRecordFileManager: synapseRecordFileManager)
        }
        if self.synapseCrystalInfo.angle.hasGraph {
            self.gx.saveValuesCheck(self.synapseCrystalInfo.gx.key, synapseRecordFileManager: synapseRecordFileManager)
            self.gy.saveValuesCheck(self.synapseCrystalInfo.gy.key, synapseRecordFileManager: synapseRecordFileManager)
            self.gz.saveValuesCheck(self.synapseCrystalInfo.gz.key, synapseRecordFileManager: synapseRecordFileManager)
        }
        if self.synapseCrystalInfo.temp.hasGraph {
            self.temp.saveValuesCheck(self.synapseCrystalInfo.temp.key, synapseRecordFileManager: synapseRecordFileManager)
        }
        if self.synapseCrystalInfo.hum.hasGraph {
            self.hum.saveValuesCheck(self.synapseCrystalInfo.hum.key, synapseRecordFileManager: synapseRecordFileManager)
        }
        if self.synapseCrystalInfo.press.hasGraph {
            self.press.saveValuesCheck(self.synapseCrystalInfo.press.key, synapseRecordFileManager: synapseRecordFileManager)
        }
        if self.synapseCrystalInfo.sound.hasGraph {
            self.sound.saveValuesCheck(self.synapseCrystalInfo.sound.key, synapseRecordFileManager: synapseRecordFileManager)
        }
        if self.synapseCrystalInfo.volt.hasGraph {
            self.volt.saveValuesCheck(self.synapseCrystalInfo.volt.key, synapseRecordFileManager: synapseRecordFileManager)
        }
        /*if self.synapseCrystalInfo.mag.hasGraph {
            self.mx.saveValuesCheck(self.synapseCrystalInfo.mx.key, synapseRecordFileManager: synapseRecordFileManager)
            self.my.saveValuesCheck(self.synapseCrystalInfo.my.key, synapseRecordFileManager: synapseRecordFileManager)
            self.mz.saveValuesCheck(self.synapseCrystalInfo.mz.key, synapseRecordFileManager: synapseRecordFileManager)
        }*/
    }
}

// MARK: class - SynapseNotification

class SynapseNotification {

    var notificationId: String?
    var body: String?
    var value: Double?
    var isSend: Bool?

    init(notificationId: String, body: String) {

        self.notificationId = notificationId
        self.body = body
    }

    func checkSynapseNotifications(_ nowValue: Any) {

        if let notificationId = self.notificationId, let body = self.body, let value = self.value {
            var res: Bool = false
            var bodyStr: String = body
            if let nowValue = nowValue as? Double, nowValue >= value {
                res = true
                bodyStr = String(format: body, value)
            }
            else if let nowValue = nowValue as? Int, nowValue >= Int(value) {
                res = true
                bodyStr = String(format: body, Int(value))
            }
            else if let nowValue = nowValue as? Float, nowValue >= Float(value) {
                res = true
                bodyStr = String(format: body, Float(value))
            }

            if res {
                if let isSend = self.isSend, !isSend {
                    self.sendSynapseNotification(notificationId: notificationId, body: bodyStr)
                }
                self.isSend = true
            }
            else {
                /*if let isSend = self.isSend, isSend {
                    print("Send Notification Reset")
                }*/
                self.isSend = false
            }
        }
    }

    func sendSynapseNotification(notificationId: String, body: String) {

        if #available(iOS 10.0, *) {
            let content: UNMutableNotificationContent = UNMutableNotificationContent()
            //content.title = NSString.localizedUserNotificationString(forKey: "Test", arguments: nil)
            content.body = NSString.localizedUserNotificationString(forKey: body, arguments: nil)
            //content.sound = UNNotificationSound.default()
            //let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
            /*
            var dateInfo = DateComponents()
            dateInfo.hour = 7
            dateInfo.minute = 0
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateInfo, repeats: false)
             */
            let request: UNNotificationRequest = UNNotificationRequest(identifier: notificationId, content: content, trigger: nil)
            let center: UNUserNotificationCenter = UNUserNotificationCenter.current()
            center.add(request) { (error: Error?) in
                if let error = error {
                    print("UserNotificationCenter error : \(error.localizedDescription)")
                }
                else {
                    print("UserNotificationCenter success")
                }
            }
        }
        else {
            let notification: UILocalNotification = UILocalNotification()
            notification.alertBody = body
            notification.timeZone = NSTimeZone.default
            //notification.fireDate = Date(timeInterval: 10, since: Date())
            //notification.soundName = UILocalNotificationDefaultSoundName
            //notification.applicationIconBadgeNumber = 1
            notification.userInfo = ["notifyID": notificationId]
            UIApplication.shared.scheduleLocalNotification(notification)
        }
    }
}

// MARK: class - AllSynapseNotifications

class AllSynapseNotifications {

    var co2: SynapseNotification = SynapseNotification(notificationId: "notification_co2",
                                                       body: "CO2 value exceeded %d")

    private let info: [String: Any] = SettingFileManager.shared.getSettingData("notification_info") as? [String : Any] ?? [:]

    init() {

        self.co2.value = self.getSynapseNotificationValue("co2")
    }

    func getSynapseNotificationValue(_ key: String) -> Double? {

        if let data = self.info[key] as? [String: Any] {
            if let flag = data["flag"] as? Bool {
                if flag {
                    if let value = data["value"] {
                        if let doubleValue = value as? Double {
                            return doubleValue
                        }
                        else if let intValue = value as? Int {
                            return Double(intValue)
                        }
                        else if let floatValue = value as? Float {
                            return Double(floatValue)
                        }
                    }
                }
            }
        }
        return nil
    }

    func checkSynapseNotifications(_ synapseValues: SynapseValues) {

        if let co2 = synapseValues.co2 {
            self.co2.checkSynapseNotifications(co2)
        }
    }
}
