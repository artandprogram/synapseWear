//
//  TopViewController.swift
//  synapsewear
//
//  Copyright © 2017年 art and program, Inc. For license and other information refer to https://github.com/artandprogram/synapseWear. All rights reserved.
//

import UIKit
import SceneKit
import UserNotifications
import Alamofire
import SwiftyJSON

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

    var co2: CrystalStruct = CrystalStruct(key: "co2", name: "CO2", hasGraph: true, graphColor: UIColor.graphCO2)
    var temp: CrystalStruct = CrystalStruct(key: "temp", name: "temperature", hasGraph: true, graphColor: UIColor.graphTemp)
    var hum: CrystalStruct = CrystalStruct(key: "hum", name: "humidity", hasGraph: true, graphColor: UIColor.graphHumi)
    var ill: CrystalStruct = CrystalStruct(key: "ill", name: "illumination", hasGraph: true, graphColor: UIColor.graphIllu)
    var press: CrystalStruct = CrystalStruct(key: "press", name: "air pressure", hasGraph: true, graphColor: UIColor.graphAirP)
    var sound: CrystalStruct = CrystalStruct(key: "sound", name: "environmental sound", hasGraph: true, graphColor: UIColor.graphEnvS)
    var move: CrystalStruct = CrystalStruct(key: "move", name: "movement", hasGraph: false, graphColor: UIColor.graphMove)
    var angle: CrystalStruct = CrystalStruct(key: "angle", name: "angle", hasGraph: false, graphColor: UIColor.graphAngl)
    var volt: CrystalStruct = CrystalStruct(key: "volt", name: "voltage", hasGraph: true, graphColor: UIColor.graphVolt)
    //var mag: CrystalStruct = CrystalStruct(key: "mag", name: "magnetic field", hasGraph: true, graphColor: UIColor.graphMagF)
    var led: CrystalStruct = CrystalStruct(key: "led", name: "LED", hasGraph: false, graphColor: UIColor.clear)
}

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

class TopViewController: BaseViewController, RFduinoManagerDelegate, RFduinoDelegate, F53OSCClientDelegate, F53OSCPacketDestination, SynapseSoundDelegate {

    // const variables
    let aScale: Float = 2.0 / 32768.0
    let gScale: Float = 250.0 / 32768.0
    let checkSynapseTime: TimeInterval = 0.1
    let updateSynapseViewTime: TimeInterval = 0.4
    let updateSynapseValuesViewTime: TimeInterval = 1.0
    let synapseDataMax: Int = 1 * 60 * 60 * 10
    let synapseDataKeepTime: TimeInterval = TimeInterval(30 * 24 * 60 * 60)
    let synapseOffColorTime: TimeInterval = TimeInterval(12 * 60 * 60)
    let scnPixelScale: Float = 0.002
    let pinchZoomDef: Float = 5.0
    let synapseGraphMaxCnt: Int = 5 * 2
    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    let synapseCrystalInfo: SynapseCrystalStruct = SynapseCrystalStruct()
    let crystalGeometries: CrystalGeometries = CrystalGeometries()
    let settingFileManager: SettingFileManager = SettingFileManager()
    let accessKeysFileManager: AccessKeysFileManager = AccessKeysFileManager()
    // synapse data variables
    var synapseDeviceName: String = ""
    var rfduinoManager: RFduinoManager!
    //var rfduinos: [Any] = []
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
    // debug views
    var debugAreaBtn: UIButton!
    var debugView: DebugView!
    // OSC variables
    var oscSynapseObject: SynapseObject?
    var updateOSCSynapseViewTimeLast: TimeInterval?
    var updateOSCSynapseValuesViewTimeLast: TimeInterval?
    var oscServer: F53OSCServer?
    /*
    // Notifications variables
    var synapseNotifications: AllSynapseNotifications = AllSynapseNotifications() */

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setRFduinoManager()
        self.setAudio()
        self.removeOldRecords()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //print("TopViewController viewWillAppear")

        self.appearNavigationArea()

        if !self.isUpdateViewActive {
            self.updateSynapseViews()
        }
        self.isUpdateViewActive = true

        self.setOSCRecvMode()
        //self.setSynapseNotifications()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //print("TopViewController viewWillDisappear")

        self.disappearNavigationArea()

        self.isUpdateViewActive = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func setParam() {
        super.setParam()

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
            self.synapseGraphs.append("ax")
            self.synapseGraphs.append("ay")
            self.synapseGraphs.append("az")
        }
        if self.synapseCrystalInfo.angle.hasGraph {
            self.synapseGraphs.append("gx")
            self.synapseGraphs.append("gy")
            self.synapseGraphs.append("gz")
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

        if let temperatureScale = self.settingFileManager.getSettingData(self.settingFileManager.synapseTemperatureScaleKey) as? String {
            self.appDelegate.temperatureScale = temperatureScale
        }

        if let path = Bundle.main.path(forResource: "appinfo", ofType: "plist"), let dict = NSDictionary(contentsOfFile: path) as? [String: Any], let flag = dict["use_osc_recv"] as? Bool, flag {
            self.oscServer = F53OSCServer.init()
        }

        self.setSynapseObject()
        self.setNotificationCenter()
    }

    func setSynapseObject() {

        self.synapseDeviceName = ""
        if let name = self.appDelegate.appinfo?["device_name"] as? String {
            self.synapseDeviceName = name
        }

        self.mainSynapseObject = SynapseObject("main")
        self.mainSynapseObject.rotateSynapseNodeDuration = self.updateSynapseViewTime
        self.mainSynapseObject.rotateCrystalNodeDuration = self.updateSynapseViewTime
        self.mainSynapseObject.scaleSynapseNodeDuration = self.updateSynapseViewTime
        self.mainSynapseObject.offColorTime = self.synapseOffColorTime
        if let accessKeys = self.accessKeysFileManager.getAccessKeysData() {
            var uuidNow: UUID? = nil
            var dateNow: Date? = nil
            for accessKey in accessKeys {
                if let accessKey = accessKey as? [String: Any], let uuid = accessKey[self.accessKeysFileManager.uuidKey] as? UUID {
                    //print("setSynapseId: \(accessKey)")
                    var date: Date? = nil
                    if let value = accessKey[self.accessKeysFileManager.dateKey] as? Date {
                        date = value
                    }

                    var flag: Bool = false
                    if uuidNow == nil {
                        flag = true
                    }
                    else if date != nil {
                        if dateNow == nil || date! > dateNow! {
                            flag = true
                        }
                    }
                    if flag {
                        uuidNow = uuid
                        dateNow = date
                    }
                }
            }

            if uuidNow != nil {
                self.mainSynapseObject.setSynapseUUID(uuidNow!)
                self.mainSynapseObject.changeSynapseSendData()
            }
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
        self.setDebugButton()
    }

    override func resizeView() {
        super.resizeView()
    }

    func setNavigationArea() {

        if let nav = self.navigationController as? NavigationController {
            self.cameraResetButton = UIButton()
            self.cameraResetButton?.frame = CGRect(x: nav.headerTitle.frame.origin.x, y: nav.headerTitle.frame.origin.y, width: nav.headerTitle.frame.size.width, height: nav.headerTitle.frame.size.height)
            self.cameraResetButton?.backgroundColor = UIColor.clear
            self.cameraResetButton?.addTarget(self, action: #selector(self.resetCameraNodePosition), for: .touchUpInside)
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
            if let isDebug = self.appDelegate.appinfo?["is_debug"] as? Bool {
                if isDebug {
                    nav.headerMenuBtn.isHidden = false
                }
            }
            nav.headerBackForTopBtn.isHidden = true
        }
    }

    // MARK: mark - NotificationCenter methods

    func setNotificationCenter() {

        let notificationCenter: NotificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(type(of: self).applicationDidBecomeActiveNotified(notification:)), name: .UIApplicationDidBecomeActive, object: nil)
        notificationCenter.addObserver(self, selector: #selector(type(of: self).applicationWillResignActiveNotified(notification:)), name: .UIApplicationWillResignActive, object: nil)
        notificationCenter.addObserver(self, selector: #selector(type(of: self).applicationWillTerminateNotified(notification:)), name: .UIApplicationWillTerminate, object: nil)
    }

    @objc func applicationDidBecomeActiveNotified(notification: Notification) {

        //print("TopViewController applicationDidBecomeActiveNotified")
        self.isSynapseAppActive = true

        self.resendSynapseSettingToDeviceStart(self.mainSynapseObject)

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

        self.resendSynapseSettingToDeviceStart(self.mainSynapseObject)
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

        self.mainSynapseObject.setSynapseNode(scnView: self.scnView, position: nil)
        self.mainSynapseObject.setColorOffSynapseNode()

        w = 80.0
        h = 40.0
        x = 0
        y = self.view.frame.size.height - (h + 20.0)
        self.swipeModeButton = UIButton()
        self.swipeModeButton?.frame = CGRect(x: x, y: y, width: w, height: h)
        self.swipeModeButton?.setTitle("Mode1", for: .normal)
        self.swipeModeButton?.setTitleColor(UIColor.black, for: .normal)
        self.swipeModeButton?.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 16)
        self.swipeModeButton?.backgroundColor = UIColor.clear
        self.swipeModeButton?.addTarget(self, action: #selector(self.changeSwipeMode), for: .touchUpInside)
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

        self.scnView.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(self.sceneViewPinchAction(_:))))

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
        print("touchesBegan x:\(touchEvent.location(in: self.scnView).x) y:\(touchEvent.location(in: self.scnView).y)")*/
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
        self.mainSynapseObject.rotateSynapseNode(dx: dx, dy: dy)
    }

    func touchesMultiAction(_ touchEvent: UITouch) {

        let preDx: CGFloat = touchEvent.previousLocation(in: self.view).x
        let preDy: CGFloat = touchEvent.previousLocation(in: self.view).y
        let newDx: CGFloat = touchEvent.location(in: self.view).x
        let newDy: CGFloat = touchEvent.location(in: self.view).y

        let dx: CGFloat = (newDx - preDx) / self.view.frame.size.width * CGFloat(self.cameraNode.position.z)
        let dy: CGFloat = (newDy - preDy) / self.view.frame.size.height * CGFloat(self.cameraNode.position.z)
        //print("touchesMultiAction x:\(dx) y:\(dy) preDx:\(preDx) preDy:\(preDy)")
        self.cameraNode.position = SCNVector3(x: self.cameraNode.position.x - Float(dx), y: self.cameraNode.position.y + Float(dy), z: self.cameraNode.position.z)
        //print("cameraNode.position x:\(self.cameraNode.position.x) y:\(self.cameraNode.position.y) z:\(self.cameraNode.position.z)")
    }

    // MARK: mark - Pinch Action methods

    @objc func sceneViewPinchAction(_ sender: UIPinchGestureRecognizer) {

        if sender.state == UIGestureRecognizerState.began {
            //print("pinch: \(sender.scale) -> began")
            self.pinchZoomZ = self.cameraNode.position.z
        }
        else if sender.state == UIGestureRecognizerState.changed {
            //print("pinch: \(sender.scale) -> changed")
            if self.synapseValuesView.isHidden {
                let z: Float = self.pinchZoomZ / Float(sender.scale)
                self.cameraNode.position = SCNVector3(x: self.cameraNode.position.x, y: self.cameraNode.position.y, z: z)
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

                        self.debugAreaBtn.isHidden = true

                        UIView.animate(withDuration: 0.1, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: { () -> Void in

                            self.synapseValuesView.alpha = 1
                        }, completion: { _ in
                            self.setNavigatioHeaderColor(isWhite: true)
                        })
                    }
                }
            }
        }
        else if sender.state == UIGestureRecognizerState.ended {
            //print("pinch: \(sender.scale) -> ended")
            if self.synapseValuesView.isHidden {
                self.canUpdateCrystalView = true
            }
        }
    }

    func checkSynapseCrystalFocus() -> [String]? {

        let zPos: Float = -1.5
        let hitFrom: SCNVector3 = SCNVector3(x: self.cameraNode.position.x, y: self.cameraNode.position.y, z: self.cameraNode.position.z)
        let hitTo: SCNVector3 = SCNVector3(x: self.cameraNode.position.x, y: self.cameraNode.position.y, z: self.cameraNode.position.z + zPos)
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
            let action = SCNAction.move(to: position, duration: 0.1)
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

        let fontS: CGFloat = 60.0
        let fontS2: CGFloat = 40.0
        let fontU: CGFloat = 16.0
        for (index, element) in self.synapseValues.enumerated() {
            let tabView: UIView = UIView()
            tabView.tag = index
            tabView.frame = CGRect(x: 0, y: 0, width: tabW, height: self.synapseTabView.frame.size.height)
            tabView.backgroundColor = UIColor.clear
            tabView.alpha = 0.3
            self.synapseTabView.addSubview(tabView)
            self.synapseTabLabels[element] = tabView

            let imageView: UIImageView = UIImageView()
            imageView.frame = CGRect(x: (tabView.frame.size.width - 60.0) / 2, y: 0, width: 60.0, height: 60.0)
            tabView.addSubview(imageView)
            if element == self.synapseCrystalInfo.co2.key {
                imageView.image = UIImage(named: "co2.png")
            }
            else if element == self.synapseCrystalInfo.temp.key {
                imageView.image = UIImage(named: "temp.png")
            }
            else if element == self.synapseCrystalInfo.hum.key {
                imageView.image = UIImage(named: "hum.png")
            }
            else if element == self.synapseCrystalInfo.ill.key {
                imageView.image = UIImage(named: "ill.png")
            }
            else if element == self.synapseCrystalInfo.press.key {
                imageView.image = UIImage(named: "press.png")
            }
            else if element == self.synapseCrystalInfo.sound.key {
                imageView.image = UIImage(named: "sound.png")
            }
            /*else if element == self.synapseCrystalInfo.mag.key {
                imageView.image = UIImage(named: "mag.png")
            }*/
            else if element == self.synapseCrystalInfo.move.key {
                imageView.image = UIImage(named: "move.png")
            }
            else if element == self.synapseCrystalInfo.angle.key {
                imageView.image = UIImage(named: "angle.png")
            }

            let tabLabel: UILabel = UILabel()
            tabLabel.frame = CGRect(x: 0, y: tabView.frame.size.height - 20.0, width: tabView.frame.size.width, height: 20.0)
            tabLabel.textColor = UIColor.white
            tabLabel.backgroundColor = UIColor.clear
            tabLabel.font = UIFont(name: "HelveticaNeue", size: 16.0)
            tabLabel.textAlignment = NSTextAlignment.center
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

            let valueView: UIView = UIView()
            valueView.tag = index
            valueView.frame = CGRect(x: 0, y: 0, width: dataW, height: self.synapseDataView.frame.size.height)
            valueView.backgroundColor = UIColor.clear
            self.synapseDataView.addSubview(valueView)
            self.synapseDataLabels[element] = valueView

            if element == self.synapseCrystalInfo.co2.key {
                self.synapseValueLabels.co2Labels.valueLabel = UILabel()
                self.synapseValueLabels.co2Labels.valueLabel?.text = ""
                self.synapseValueLabels.co2Labels.valueLabel?.frame = CGRect(x: 0, y: 0, width: valueView.frame.size.width, height: valueView.frame.size.height)
                self.synapseValueLabels.co2Labels.valueLabel?.textColor = UIColor.white
                self.synapseValueLabels.co2Labels.valueLabel?.backgroundColor = UIColor.clear
                self.synapseValueLabels.co2Labels.valueLabel?.font = UIFont(name: "HelveticaNeue", size: fontS)
                self.synapseValueLabels.co2Labels.valueLabel?.textAlignment = NSTextAlignment.center
                self.synapseValueLabels.co2Labels.valueLabel?.numberOfLines = 1
                valueView.addSubview(self.synapseValueLabels.co2Labels.valueLabel!)

                self.synapseValueLabels.co2Labels.diffLabel = UILabel()
                self.synapseValueLabels.co2Labels.diffLabel?.text = ""
                self.synapseValueLabels.co2Labels.diffLabel?.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
                self.synapseValueLabels.co2Labels.diffLabel?.textColor = UIColor.white
                self.synapseValueLabels.co2Labels.diffLabel?.backgroundColor = UIColor.clear
                self.synapseValueLabels.co2Labels.diffLabel?.font = UIFont(name: "HelveticaNeue", size: fontU)
                self.synapseValueLabels.co2Labels.diffLabel?.textAlignment = NSTextAlignment.center
                self.synapseValueLabels.co2Labels.diffLabel?.numberOfLines = 1
                valueView.addSubview(self.synapseValueLabels.co2Labels.diffLabel!)

                self.synapseValueLabels.co2Labels.unitLabel = UILabel()
                self.synapseValueLabels.co2Labels.unitLabel?.text = "ppm"
                self.synapseValueLabels.co2Labels.unitLabel?.textColor = UIColor.white
                self.synapseValueLabels.co2Labels.unitLabel?.backgroundColor = UIColor.clear
                self.synapseValueLabels.co2Labels.unitLabel?.font = UIFont(name: "HelveticaNeue", size: fontU)
                self.synapseValueLabels.co2Labels.unitLabel?.textAlignment = NSTextAlignment.center
                self.synapseValueLabels.co2Labels.unitLabel?.numberOfLines = 1
                valueView.addSubview(self.synapseValueLabels.co2Labels.unitLabel!)
            }
            else if element == self.synapseCrystalInfo.temp.key {
                self.synapseValueLabels.tempLabels.valueLabel = UILabel()
                self.synapseValueLabels.tempLabels.valueLabel?.text = ""
                self.synapseValueLabels.tempLabels.valueLabel?.frame = CGRect(x: 0, y: 0, width: valueView.frame.size.width, height: valueView.frame.size.height)
                self.synapseValueLabels.tempLabels.valueLabel?.textColor = UIColor.white
                self.synapseValueLabels.tempLabels.valueLabel?.backgroundColor = UIColor.clear
                self.synapseValueLabels.tempLabels.valueLabel?.font = UIFont(name: "HelveticaNeue", size: fontS)
                self.synapseValueLabels.tempLabels.valueLabel?.textAlignment = NSTextAlignment.center
                self.synapseValueLabels.tempLabels.valueLabel?.numberOfLines = 1
                valueView.addSubview(self.synapseValueLabels.tempLabels.valueLabel!)

                self.synapseValueLabels.tempLabels.diffLabel = UILabel()
                self.synapseValueLabels.tempLabels.diffLabel?.text = ""
                self.synapseValueLabels.tempLabels.diffLabel?.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
                self.synapseValueLabels.tempLabels.diffLabel?.textColor = UIColor.white
                self.synapseValueLabels.tempLabels.diffLabel?.backgroundColor = UIColor.clear
                self.synapseValueLabels.tempLabels.diffLabel?.font = UIFont(name: "HelveticaNeue", size: fontU)
                self.synapseValueLabels.tempLabels.diffLabel?.textAlignment = NSTextAlignment.center
                self.synapseValueLabels.tempLabels.diffLabel?.numberOfLines = 1
                valueView.addSubview(self.synapseValueLabels.tempLabels.diffLabel!)

                self.synapseValueLabels.tempLabels.unitLabel = UILabel()
                self.synapseValueLabels.tempLabels.unitLabel?.text = "℃"
                self.synapseValueLabels.tempLabels.unitLabel?.textColor = UIColor.white
                self.synapseValueLabels.tempLabels.unitLabel?.backgroundColor = UIColor.clear
                self.synapseValueLabels.tempLabels.unitLabel?.font = UIFont(name: "HelveticaNeue", size: fontU)
                self.synapseValueLabels.tempLabels.unitLabel?.textAlignment = NSTextAlignment.center
                self.synapseValueLabels.tempLabels.unitLabel?.numberOfLines = 1
                valueView.addSubview(self.synapseValueLabels.tempLabels.unitLabel!)
            }
            else if element == self.synapseCrystalInfo.press.key {
                self.synapseValueLabels.pressLabels.valueLabel = UILabel()
                self.synapseValueLabels.pressLabels.valueLabel?.text = ""
                self.synapseValueLabels.pressLabels.valueLabel?.frame = CGRect(x: 0, y: 0, width: valueView.frame.size.width, height: valueView.frame.size.height)
                self.synapseValueLabels.pressLabels.valueLabel?.textColor = UIColor.white
                self.synapseValueLabels.pressLabels.valueLabel?.backgroundColor = UIColor.clear
                self.synapseValueLabels.pressLabels.valueLabel?.font = UIFont(name: "HelveticaNeue", size: fontS)
                self.synapseValueLabels.pressLabels.valueLabel?.textAlignment = NSTextAlignment.center
                self.synapseValueLabels.pressLabels.valueLabel?.numberOfLines = 1
                valueView.addSubview(self.synapseValueLabels.pressLabels.valueLabel!)

                self.synapseValueLabels.pressLabels.diffLabel = UILabel()
                self.synapseValueLabels.pressLabels.diffLabel?.text = ""
                self.synapseValueLabels.pressLabels.diffLabel?.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
                self.synapseValueLabels.pressLabels.diffLabel?.textColor = UIColor.white
                self.synapseValueLabels.pressLabels.diffLabel?.backgroundColor = UIColor.clear
                self.synapseValueLabels.pressLabels.diffLabel?.font = UIFont(name: "HelveticaNeue", size: fontU)
                self.synapseValueLabels.pressLabels.diffLabel?.textAlignment = NSTextAlignment.center
                self.synapseValueLabels.pressLabels.diffLabel?.numberOfLines = 1
                valueView.addSubview(self.synapseValueLabels.pressLabels.diffLabel!)

                self.synapseValueLabels.pressLabels.unitLabel = UILabel()
                self.synapseValueLabels.pressLabels.unitLabel?.text = "hPa"
                self.synapseValueLabels.pressLabels.unitLabel?.textColor = UIColor.white
                self.synapseValueLabels.pressLabels.unitLabel?.backgroundColor = UIColor.clear
                self.synapseValueLabels.pressLabels.unitLabel?.font = UIFont(name: "HelveticaNeue", size: fontU)
                self.synapseValueLabels.pressLabels.unitLabel?.textAlignment = NSTextAlignment.center
                self.synapseValueLabels.pressLabels.unitLabel?.numberOfLines = 1
                valueView.addSubview(self.synapseValueLabels.pressLabels.unitLabel!)
            }
            else if element == self.synapseCrystalInfo.sound.key {
                self.synapseValueLabels.soundLabels.valueLabel = UILabel()
                self.synapseValueLabels.soundLabels.valueLabel?.text = ""
                self.synapseValueLabels.soundLabels.valueLabel?.frame = CGRect(x: 0, y: 0, width: valueView.frame.size.width, height: valueView.frame.size.height)
                self.synapseValueLabels.soundLabels.valueLabel?.textColor = UIColor.white
                self.synapseValueLabels.soundLabels.valueLabel?.backgroundColor = UIColor.clear
                self.synapseValueLabels.soundLabels.valueLabel?.font = UIFont(name: "HelveticaNeue", size: fontS)
                self.synapseValueLabels.soundLabels.valueLabel?.textAlignment = NSTextAlignment.center
                self.synapseValueLabels.soundLabels.valueLabel?.numberOfLines = 1
                valueView.addSubview(self.synapseValueLabels.soundLabels.valueLabel!)

                self.synapseValueLabels.soundLabels.diffLabel = UILabel()
                self.synapseValueLabels.soundLabels.diffLabel?.text = ""
                self.synapseValueLabels.soundLabels.diffLabel?.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
                self.synapseValueLabels.soundLabels.diffLabel?.textColor = UIColor.white
                self.synapseValueLabels.soundLabels.diffLabel?.backgroundColor = UIColor.clear
                self.synapseValueLabels.soundLabels.diffLabel?.font = UIFont(name: "HelveticaNeue", size: fontU)
                self.synapseValueLabels.soundLabels.diffLabel?.textAlignment = NSTextAlignment.center
                self.synapseValueLabels.soundLabels.diffLabel?.numberOfLines = 1
                valueView.addSubview(self.synapseValueLabels.soundLabels.diffLabel!)

                self.synapseValueLabels.soundLabels.unitLabel = UILabel()
                self.synapseValueLabels.soundLabels.unitLabel?.text = ""
                //self.synapseValueLabels.soundLabels.unitLabel?.text = "dB"
                self.synapseValueLabels.soundLabels.unitLabel?.textColor = UIColor.white
                self.synapseValueLabels.soundLabels.unitLabel?.backgroundColor = UIColor.clear
                self.synapseValueLabels.soundLabels.unitLabel?.font = UIFont(name: "HelveticaNeue", size: fontU)
                self.synapseValueLabels.soundLabels.unitLabel?.textAlignment = NSTextAlignment.center
                self.synapseValueLabels.soundLabels.unitLabel?.numberOfLines = 1
                valueView.addSubview(self.synapseValueLabels.soundLabels.unitLabel!)
            }
            /*else if element == self.synapseCrystalInfo.mag.key {
                self.synapseValueLabels.magxLabels.valueLabel = UILabel()
                self.synapseValueLabels.magxLabels.valueLabel?.text = ""
                self.synapseValueLabels.magxLabels.valueLabel?.frame = CGRect(x: 0, y: 0, width: valueView.frame.size.width, height: valueView.frame.size.height)
                self.synapseValueLabels.magxLabels.valueLabel?.textColor = UIColor.white
                self.synapseValueLabels.magxLabels.valueLabel?.backgroundColor = UIColor.clear
                self.synapseValueLabels.magxLabels.valueLabel?.font = UIFont(name: "HelveticaNeue", size: fontS2)
                self.synapseValueLabels.magxLabels.valueLabel?.textAlignment = NSTextAlignment.center
                self.synapseValueLabels.magxLabels.valueLabel?.numberOfLines = 1
                valueView.addSubview(self.synapseValueLabels.magxLabels.valueLabel!)

                self.synapseValueLabels.magyLabels.valueLabel = UILabel()
                self.synapseValueLabels.magyLabels.valueLabel?.text = ""
                self.synapseValueLabels.magyLabels.valueLabel?.frame = CGRect(x: 0, y: 0, width: valueView.frame.size.width, height: valueView.frame.size.height)
                self.synapseValueLabels.magyLabels.valueLabel?.textColor = UIColor.white
                self.synapseValueLabels.magyLabels.valueLabel?.backgroundColor = UIColor.clear
                self.synapseValueLabels.magyLabels.valueLabel?.font = UIFont(name: "HelveticaNeue", size: fontS2)
                self.synapseValueLabels.magyLabels.valueLabel?.textAlignment = NSTextAlignment.center
                self.synapseValueLabels.magyLabels.valueLabel?.numberOfLines = 1
                valueView.addSubview(self.synapseValueLabels.magyLabels.valueLabel!)

                self.synapseValueLabels.magzLabels.valueLabel = UILabel()
                self.synapseValueLabels.magzLabels.valueLabel?.text = ""
                self.synapseValueLabels.magzLabels.valueLabel?.frame = CGRect(x: 0, y: 0, width: valueView.frame.size.width, height: valueView.frame.size.height)
                self.synapseValueLabels.magzLabels.valueLabel?.textColor = UIColor.white
                self.synapseValueLabels.magzLabels.valueLabel?.backgroundColor = UIColor.clear
                self.synapseValueLabels.magzLabels.valueLabel?.font = UIFont(name: "HelveticaNeue", size: fontS2)
                self.synapseValueLabels.magzLabels.valueLabel?.textAlignment = NSTextAlignment.center
                self.synapseValueLabels.magzLabels.valueLabel?.numberOfLines = 1
                valueView.addSubview(self.synapseValueLabels.magzLabels.valueLabel!)

                self.synapseValueLabels.magxLabels.diffLabel = UILabel()
                self.synapseValueLabels.magxLabels.diffLabel?.text = ""
                self.synapseValueLabels.magxLabels.diffLabel?.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
                self.synapseValueLabels.magxLabels.diffLabel?.textColor = UIColor.white
                self.synapseValueLabels.magxLabels.diffLabel?.backgroundColor = UIColor.clear
                self.synapseValueLabels.magxLabels.diffLabel?.font = UIFont(name: "HelveticaNeue", size: fontU)
                self.synapseValueLabels.magxLabels.diffLabel?.textAlignment = NSTextAlignment.center
                self.synapseValueLabels.magxLabels.diffLabel?.numberOfLines = 1
                valueView.addSubview(self.synapseValueLabels.magxLabels.diffLabel!)

                self.synapseValueLabels.magyLabels.diffLabel = UILabel()
                self.synapseValueLabels.magyLabels.diffLabel?.text = ""
                self.synapseValueLabels.magyLabels.diffLabel?.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
                self.synapseValueLabels.magyLabels.diffLabel?.textColor = UIColor.white
                self.synapseValueLabels.magyLabels.diffLabel?.backgroundColor = UIColor.clear
                self.synapseValueLabels.magyLabels.diffLabel?.font = UIFont(name: "HelveticaNeue", size: fontU)
                self.synapseValueLabels.magyLabels.diffLabel?.textAlignment = NSTextAlignment.center
                self.synapseValueLabels.magyLabels.diffLabel?.numberOfLines = 1
                valueView.addSubview(self.synapseValueLabels.magyLabels.diffLabel!)

                self.synapseValueLabels.magzLabels.diffLabel = UILabel()
                self.synapseValueLabels.magzLabels.diffLabel?.text = ""
                self.synapseValueLabels.magzLabels.diffLabel?.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
                self.synapseValueLabels.magzLabels.diffLabel?.textColor = UIColor.white
                self.synapseValueLabels.magzLabels.diffLabel?.backgroundColor = UIColor.clear
                self.synapseValueLabels.magzLabels.diffLabel?.font = UIFont(name: "HelveticaNeue", size: fontU)
                self.synapseValueLabels.magzLabels.diffLabel?.textAlignment = NSTextAlignment.center
                self.synapseValueLabels.magzLabels.diffLabel?.numberOfLines = 1
                valueView.addSubview(self.synapseValueLabels.magzLabels.diffLabel!)

                self.synapseValueLabels.magxLabels.unitLabel = UILabel()
                self.synapseValueLabels.magxLabels.unitLabel?.text = "μT"
                self.synapseValueLabels.magxLabels.unitLabel?.textColor = UIColor.white
                self.synapseValueLabels.magxLabels.unitLabel?.backgroundColor = UIColor.clear
                self.synapseValueLabels.magxLabels.unitLabel?.font = UIFont(name: "HelveticaNeue", size: fontU)
                self.synapseValueLabels.magxLabels.unitLabel?.textAlignment = NSTextAlignment.center
                self.synapseValueLabels.magxLabels.unitLabel?.numberOfLines = 1
                valueView.addSubview(self.synapseValueLabels.magxLabels.unitLabel!)

                self.synapseValueLabels.magyLabels.unitLabel = UILabel()
                self.synapseValueLabels.magyLabels.unitLabel?.text = "μT"
                self.synapseValueLabels.magyLabels.unitLabel?.textColor = UIColor.white
                self.synapseValueLabels.magyLabels.unitLabel?.backgroundColor = UIColor.clear
                self.synapseValueLabels.magyLabels.unitLabel?.font = UIFont(name: "HelveticaNeue", size: fontU)
                self.synapseValueLabels.magyLabels.unitLabel?.textAlignment = NSTextAlignment.center
                self.synapseValueLabels.magyLabels.unitLabel?.numberOfLines = 1
                valueView.addSubview(self.synapseValueLabels.magyLabels.unitLabel!)

                self.synapseValueLabels.magzLabels.unitLabel = UILabel()
                self.synapseValueLabels.magzLabels.unitLabel?.text = "μT"
                self.synapseValueLabels.magzLabels.unitLabel?.textColor = UIColor.white
                self.synapseValueLabels.magzLabels.unitLabel?.backgroundColor = UIColor.clear
                self.synapseValueLabels.magzLabels.unitLabel?.font = UIFont(name: "HelveticaNeue", size: fontU)
                self.synapseValueLabels.magzLabels.unitLabel?.textAlignment = NSTextAlignment.center
                self.synapseValueLabels.magzLabels.unitLabel?.numberOfLines = 1
                valueView.addSubview(self.synapseValueLabels.magzLabels.unitLabel!)
            }*/
            else if element == self.synapseCrystalInfo.move.key {
                self.synapseValueLabels.movexLabels.valueLabel = UILabel()
                self.synapseValueLabels.movexLabels.valueLabel?.text = ""
                self.synapseValueLabels.movexLabels.valueLabel?.frame = CGRect(x: 0, y: 0, width: valueView.frame.size.width, height: valueView.frame.size.height)
                self.synapseValueLabels.movexLabels.valueLabel?.textColor = UIColor.white
                self.synapseValueLabels.movexLabels.valueLabel?.backgroundColor = UIColor.clear
                self.synapseValueLabels.movexLabels.valueLabel?.font = UIFont(name: "HelveticaNeue", size: fontS2)
                self.synapseValueLabels.movexLabels.valueLabel?.textAlignment = NSTextAlignment.center
                self.synapseValueLabels.movexLabels.valueLabel?.numberOfLines = 1
                valueView.addSubview(self.synapseValueLabels.movexLabels.valueLabel!)

                self.synapseValueLabels.moveyLabels.valueLabel = UILabel()
                self.synapseValueLabels.moveyLabels.valueLabel?.text = ""
                self.synapseValueLabels.moveyLabels.valueLabel?.frame = CGRect(x: 0, y: 0, width: valueView.frame.size.width, height: valueView.frame.size.height)
                self.synapseValueLabels.moveyLabels.valueLabel?.textColor = UIColor.white
                self.synapseValueLabels.moveyLabels.valueLabel?.backgroundColor = UIColor.clear
                self.synapseValueLabels.moveyLabels.valueLabel?.font = UIFont(name: "HelveticaNeue", size: fontS2)
                self.synapseValueLabels.moveyLabels.valueLabel?.textAlignment = NSTextAlignment.center
                self.synapseValueLabels.moveyLabels.valueLabel?.numberOfLines = 1
                valueView.addSubview(self.synapseValueLabels.moveyLabels.valueLabel!)

                self.synapseValueLabels.movezLabels.valueLabel = UILabel()
                self.synapseValueLabels.movezLabels.valueLabel?.text = ""
                self.synapseValueLabels.movezLabels.valueLabel?.frame = CGRect(x: 0, y: 0, width: valueView.frame.size.width, height: valueView.frame.size.height)
                self.synapseValueLabels.movezLabels.valueLabel?.textColor = UIColor.white
                self.synapseValueLabels.movezLabels.valueLabel?.backgroundColor = UIColor.clear
                self.synapseValueLabels.movezLabels.valueLabel?.font = UIFont(name: "HelveticaNeue", size: fontS2)
                self.synapseValueLabels.movezLabels.valueLabel?.textAlignment = NSTextAlignment.center
                self.synapseValueLabels.movezLabels.valueLabel?.numberOfLines = 1
                valueView.addSubview(self.synapseValueLabels.movezLabels.valueLabel!)

                self.synapseValueLabels.movexLabels.diffLabel = UILabel()
                self.synapseValueLabels.movexLabels.diffLabel?.text = ""
                self.synapseValueLabels.movexLabels.diffLabel?.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
                self.synapseValueLabels.movexLabels.diffLabel?.textColor = UIColor.white
                self.synapseValueLabels.movexLabels.diffLabel?.backgroundColor = UIColor.clear
                self.synapseValueLabels.movexLabels.diffLabel?.font = UIFont(name: "HelveticaNeue", size: fontU)
                self.synapseValueLabels.movexLabels.diffLabel?.textAlignment = NSTextAlignment.center
                self.synapseValueLabels.movexLabels.diffLabel?.numberOfLines = 1
                valueView.addSubview(self.synapseValueLabels.movexLabels.diffLabel!)

                self.synapseValueLabels.moveyLabels.diffLabel = UILabel()
                self.synapseValueLabels.moveyLabels.diffLabel?.text = ""
                self.synapseValueLabels.moveyLabels.diffLabel?.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
                self.synapseValueLabels.moveyLabels.diffLabel?.textColor = UIColor.white
                self.synapseValueLabels.moveyLabels.diffLabel?.backgroundColor = UIColor.clear
                self.synapseValueLabels.moveyLabels.diffLabel?.font = UIFont(name: "HelveticaNeue", size: fontU)
                self.synapseValueLabels.moveyLabels.diffLabel?.textAlignment = NSTextAlignment.center
                self.synapseValueLabels.moveyLabels.diffLabel?.numberOfLines = 1
                valueView.addSubview(self.synapseValueLabels.moveyLabels.diffLabel!)

                self.synapseValueLabels.movezLabels.diffLabel = UILabel()
                self.synapseValueLabels.movezLabels.diffLabel?.text = ""
                self.synapseValueLabels.movezLabels.diffLabel?.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
                self.synapseValueLabels.movezLabels.diffLabel?.textColor = UIColor.white
                self.synapseValueLabels.movezLabels.diffLabel?.backgroundColor = UIColor.clear
                self.synapseValueLabels.movezLabels.diffLabel?.font = UIFont(name: "HelveticaNeue", size: fontU)
                self.synapseValueLabels.movezLabels.diffLabel?.textAlignment = NSTextAlignment.center
                self.synapseValueLabels.movezLabels.diffLabel?.numberOfLines = 1
                valueView.addSubview(self.synapseValueLabels.movezLabels.diffLabel!)

                self.synapseValueLabels.movexLabels.unitLabel = UILabel()
                self.synapseValueLabels.movexLabels.unitLabel?.text = "m/s2"
                self.synapseValueLabels.movexLabels.unitLabel?.textColor = UIColor.white
                self.synapseValueLabels.movexLabels.unitLabel?.backgroundColor = UIColor.clear
                self.synapseValueLabels.movexLabels.unitLabel?.font = UIFont(name: "HelveticaNeue", size: fontU)
                self.synapseValueLabels.movexLabels.unitLabel?.textAlignment = NSTextAlignment.center
                self.synapseValueLabels.movexLabels.unitLabel?.numberOfLines = 1
                valueView.addSubview(self.synapseValueLabels.movexLabels.unitLabel!)

                self.synapseValueLabels.moveyLabels.unitLabel = UILabel()
                self.synapseValueLabels.moveyLabels.unitLabel?.text = "m/s2"
                self.synapseValueLabels.moveyLabels.unitLabel?.textColor = UIColor.white
                self.synapseValueLabels.moveyLabels.unitLabel?.backgroundColor = UIColor.clear
                self.synapseValueLabels.moveyLabels.unitLabel?.font = UIFont(name: "HelveticaNeue", size: fontU)
                self.synapseValueLabels.moveyLabels.unitLabel?.textAlignment = NSTextAlignment.center
                self.synapseValueLabels.moveyLabels.unitLabel?.numberOfLines = 1
                valueView.addSubview(self.synapseValueLabels.moveyLabels.unitLabel!)

                self.synapseValueLabels.movezLabels.unitLabel = UILabel()
                self.synapseValueLabels.movezLabels.unitLabel?.text = "m/s2"
                self.synapseValueLabels.movezLabels.unitLabel?.textColor = UIColor.white
                self.synapseValueLabels.movezLabels.unitLabel?.backgroundColor = UIColor.clear
                self.synapseValueLabels.movezLabels.unitLabel?.font = UIFont(name: "HelveticaNeue", size: fontU)
                self.synapseValueLabels.movezLabels.unitLabel?.textAlignment = NSTextAlignment.center
                self.synapseValueLabels.movezLabels.unitLabel?.numberOfLines = 1
                valueView.addSubview(self.synapseValueLabels.movezLabels.unitLabel!)
            }
            else if element == self.synapseCrystalInfo.angle.key {
                self.synapseValueLabels.anglexLabels.valueLabel = UILabel()
                self.synapseValueLabels.anglexLabels.valueLabel?.text = ""
                self.synapseValueLabels.anglexLabels.valueLabel?.frame = CGRect(x: 0, y: 0, width: valueView.frame.size.width, height: valueView.frame.size.height)
                self.synapseValueLabels.anglexLabels.valueLabel?.textColor = UIColor.white
                self.synapseValueLabels.anglexLabels.valueLabel?.backgroundColor = UIColor.clear
                self.synapseValueLabels.anglexLabels.valueLabel?.font = UIFont(name: "HelveticaNeue", size: fontS2)
                self.synapseValueLabels.anglexLabels.valueLabel?.textAlignment = NSTextAlignment.center
                self.synapseValueLabels.anglexLabels.valueLabel?.numberOfLines = 1
                valueView.addSubview(self.synapseValueLabels.anglexLabels.valueLabel!)

                self.synapseValueLabels.angleyLabels.valueLabel = UILabel()
                self.synapseValueLabels.angleyLabels.valueLabel?.text = ""
                self.synapseValueLabels.angleyLabels.valueLabel?.frame = CGRect(x: 0, y: 0, width: valueView.frame.size.width, height: valueView.frame.size.height)
                self.synapseValueLabels.angleyLabels.valueLabel?.textColor = UIColor.white
                self.synapseValueLabels.angleyLabels.valueLabel?.backgroundColor = UIColor.clear
                self.synapseValueLabels.angleyLabels.valueLabel?.font = UIFont(name: "HelveticaNeue", size: fontS2)
                self.synapseValueLabels.angleyLabels.valueLabel?.textAlignment = NSTextAlignment.center
                self.synapseValueLabels.angleyLabels.valueLabel?.numberOfLines = 1
                valueView.addSubview(self.synapseValueLabels.angleyLabels.valueLabel!)

                self.synapseValueLabels.anglezLabels.valueLabel = UILabel()
                self.synapseValueLabels.anglezLabels.valueLabel?.text = ""
                self.synapseValueLabels.anglezLabels.valueLabel?.frame = CGRect(x: 0, y: 0, width: valueView.frame.size.width, height: valueView.frame.size.height)
                self.synapseValueLabels.anglezLabels.valueLabel?.textColor = UIColor.white
                self.synapseValueLabels.anglezLabels.valueLabel?.backgroundColor = UIColor.clear
                self.synapseValueLabels.anglezLabels.valueLabel?.font = UIFont(name: "HelveticaNeue", size: fontS2)
                self.synapseValueLabels.anglezLabels.valueLabel?.textAlignment = NSTextAlignment.center
                self.synapseValueLabels.anglezLabels.valueLabel?.numberOfLines = 1
                valueView.addSubview(self.synapseValueLabels.anglezLabels.valueLabel!)

                self.synapseValueLabels.anglexLabels.diffLabel = UILabel()
                self.synapseValueLabels.anglexLabels.diffLabel?.text = ""
                self.synapseValueLabels.anglexLabels.diffLabel?.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
                self.synapseValueLabels.anglexLabels.diffLabel?.textColor = UIColor.white
                self.synapseValueLabels.anglexLabels.diffLabel?.backgroundColor = UIColor.clear
                self.synapseValueLabels.anglexLabels.diffLabel?.font = UIFont(name: "HelveticaNeue", size: fontU)
                self.synapseValueLabels.anglexLabels.diffLabel?.textAlignment = NSTextAlignment.center
                self.synapseValueLabels.anglexLabels.diffLabel?.numberOfLines = 1
                valueView.addSubview(self.synapseValueLabels.anglexLabels.diffLabel!)

                self.synapseValueLabels.angleyLabels.diffLabel = UILabel()
                self.synapseValueLabels.angleyLabels.diffLabel?.text = ""
                self.synapseValueLabels.angleyLabels.diffLabel?.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
                self.synapseValueLabels.angleyLabels.diffLabel?.textColor = UIColor.white
                self.synapseValueLabels.angleyLabels.diffLabel?.backgroundColor = UIColor.clear
                self.synapseValueLabels.angleyLabels.diffLabel?.font = UIFont(name: "HelveticaNeue", size: fontU)
                self.synapseValueLabels.angleyLabels.diffLabel?.textAlignment = NSTextAlignment.center
                self.synapseValueLabels.angleyLabels.diffLabel?.numberOfLines = 1
                valueView.addSubview(self.synapseValueLabels.angleyLabels.diffLabel!)

                self.synapseValueLabels.anglezLabels.diffLabel = UILabel()
                self.synapseValueLabels.anglezLabels.diffLabel?.text = ""
                self.synapseValueLabels.anglezLabels.diffLabel?.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
                self.synapseValueLabels.anglezLabels.diffLabel?.textColor = UIColor.white
                self.synapseValueLabels.anglezLabels.diffLabel?.backgroundColor = UIColor.clear
                self.synapseValueLabels.anglezLabels.diffLabel?.font = UIFont(name: "HelveticaNeue", size: fontU)
                self.synapseValueLabels.anglezLabels.diffLabel?.textAlignment = NSTextAlignment.center
                self.synapseValueLabels.anglezLabels.diffLabel?.numberOfLines = 1
                valueView.addSubview(self.synapseValueLabels.anglezLabels.diffLabel!)

                self.synapseValueLabels.anglexLabels.unitLabel = UILabel()
                self.synapseValueLabels.anglexLabels.unitLabel?.text = "rad/s"
                self.synapseValueLabels.anglexLabels.unitLabel?.textColor = UIColor.white
                self.synapseValueLabels.anglexLabels.unitLabel?.backgroundColor = UIColor.clear
                self.synapseValueLabels.anglexLabels.unitLabel?.font = UIFont(name: "HelveticaNeue", size: fontU)
                self.synapseValueLabels.anglexLabels.unitLabel?.textAlignment = NSTextAlignment.center
                self.synapseValueLabels.anglexLabels.unitLabel?.numberOfLines = 1
                valueView.addSubview(self.synapseValueLabels.anglexLabels.unitLabel!)

                self.synapseValueLabels.angleyLabels.unitLabel = UILabel()
                self.synapseValueLabels.angleyLabels.unitLabel?.text = "rad/s"
                self.synapseValueLabels.angleyLabels.unitLabel?.textColor = UIColor.white
                self.synapseValueLabels.angleyLabels.unitLabel?.backgroundColor = UIColor.clear
                self.synapseValueLabels.angleyLabels.unitLabel?.font = UIFont(name: "HelveticaNeue", size: fontU)
                self.synapseValueLabels.angleyLabels.unitLabel?.textAlignment = NSTextAlignment.center
                self.synapseValueLabels.angleyLabels.unitLabel?.numberOfLines = 1
                valueView.addSubview(self.synapseValueLabels.angleyLabels.unitLabel!)

                self.synapseValueLabels.anglezLabels.unitLabel = UILabel()
                self.synapseValueLabels.anglezLabels.unitLabel?.text = "rad/s"
                self.synapseValueLabels.anglezLabels.unitLabel?.textColor = UIColor.white
                self.synapseValueLabels.anglezLabels.unitLabel?.backgroundColor = UIColor.clear
                self.synapseValueLabels.anglezLabels.unitLabel?.font = UIFont(name: "HelveticaNeue", size: fontU)
                self.synapseValueLabels.anglezLabels.unitLabel?.textAlignment = NSTextAlignment.center
                self.synapseValueLabels.anglezLabels.unitLabel?.numberOfLines = 1
                valueView.addSubview(self.synapseValueLabels.anglezLabels.unitLabel!)
            }
            else if element == self.synapseCrystalInfo.ill.key {
                self.synapseValueLabels.illLabels.valueLabel = UILabel()
                self.synapseValueLabels.illLabels.valueLabel?.text = ""
                self.synapseValueLabels.illLabels.valueLabel?.frame = CGRect(x: 0, y: 0, width: valueView.frame.size.width, height: valueView.frame.size.height)
                self.synapseValueLabels.illLabels.valueLabel?.textColor = UIColor.white
                self.synapseValueLabels.illLabels.valueLabel?.backgroundColor = UIColor.clear
                self.synapseValueLabels.illLabels.valueLabel?.font = UIFont(name: "HelveticaNeue", size: fontS)
                self.synapseValueLabels.illLabels.valueLabel?.textAlignment = NSTextAlignment.center
                self.synapseValueLabels.illLabels.valueLabel?.numberOfLines = 1
                valueView.addSubview(self.synapseValueLabels.illLabels.valueLabel!)

                self.synapseValueLabels.illLabels.diffLabel = UILabel()
                self.synapseValueLabels.illLabels.diffLabel?.text = ""
                self.synapseValueLabels.illLabels.diffLabel?.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
                self.synapseValueLabels.illLabels.diffLabel?.textColor = UIColor.white
                self.synapseValueLabels.illLabels.diffLabel?.backgroundColor = UIColor.clear
                self.synapseValueLabels.illLabels.diffLabel?.font = UIFont(name: "HelveticaNeue", size: fontU)
                self.synapseValueLabels.illLabels.diffLabel?.textAlignment = NSTextAlignment.center
                self.synapseValueLabels.illLabels.diffLabel?.numberOfLines = 1
                valueView.addSubview(self.synapseValueLabels.illLabels.diffLabel!)

                self.synapseValueLabels.illLabels.unitLabel = UILabel()
                self.synapseValueLabels.illLabels.unitLabel?.text = "lux"
                self.synapseValueLabels.illLabels.unitLabel?.textColor = UIColor.white
                self.synapseValueLabels.illLabels.unitLabel?.backgroundColor = UIColor.clear
                self.synapseValueLabels.illLabels.unitLabel?.font = UIFont(name: "HelveticaNeue", size: fontU)
                self.synapseValueLabels.illLabels.unitLabel?.textAlignment = NSTextAlignment.center
                self.synapseValueLabels.illLabels.unitLabel?.numberOfLines = 1
                valueView.addSubview(self.synapseValueLabels.illLabels.unitLabel!)
            }
            else if element == self.synapseCrystalInfo.hum.key {
                self.synapseValueLabels.humLabels.valueLabel = UILabel()
                self.synapseValueLabels.humLabels.valueLabel?.text = ""
                self.synapseValueLabels.humLabels.valueLabel?.frame = CGRect(x: 0, y: 0, width: valueView.frame.size.width, height: valueView.frame.size.height)
                self.synapseValueLabels.humLabels.valueLabel?.textColor = UIColor.white
                self.synapseValueLabels.humLabels.valueLabel?.backgroundColor = UIColor.clear
                self.synapseValueLabels.humLabels.valueLabel?.font = UIFont(name: "HelveticaNeue", size: fontS)
                self.synapseValueLabels.humLabels.valueLabel?.textAlignment = NSTextAlignment.center
                self.synapseValueLabels.humLabels.valueLabel?.numberOfLines = 1
                valueView.addSubview(self.synapseValueLabels.humLabels.valueLabel!)

                self.synapseValueLabels.humLabels.diffLabel = UILabel()
                self.synapseValueLabels.humLabels.diffLabel?.text = ""
                self.synapseValueLabels.humLabels.diffLabel?.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
                self.synapseValueLabels.humLabels.diffLabel?.textColor = UIColor.white
                self.synapseValueLabels.humLabels.diffLabel?.backgroundColor = UIColor.clear
                self.synapseValueLabels.humLabels.diffLabel?.font = UIFont(name: "HelveticaNeue", size: fontU)
                self.synapseValueLabels.humLabels.diffLabel?.textAlignment = NSTextAlignment.center
                self.synapseValueLabels.humLabels.diffLabel?.numberOfLines = 1
                valueView.addSubview(self.synapseValueLabels.humLabels.diffLabel!)

                self.synapseValueLabels.humLabels.unitLabel = UILabel()
                self.synapseValueLabels.humLabels.unitLabel?.text = "%"
                self.synapseValueLabels.humLabels.unitLabel?.textColor = UIColor.white
                self.synapseValueLabels.humLabels.unitLabel?.backgroundColor = UIColor.clear
                self.synapseValueLabels.humLabels.unitLabel?.font = UIFont(name: "HelveticaNeue", size: fontU)
                self.synapseValueLabels.humLabels.unitLabel?.textAlignment = NSTextAlignment.center
                self.synapseValueLabels.humLabels.unitLabel?.numberOfLines = 1
                valueView.addSubview(self.synapseValueLabels.humLabels.unitLabel!)
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
        self.maxValueLabel.font = UIFont(name: "Migu 2M", size: 12)
        self.maxValueLabel.textAlignment = NSTextAlignment.left
        self.maxValueLabel.numberOfLines = 1
        self.maxValueLabel.isHidden = true
        self.synapseValuesView.addSubview(self.maxValueLabel)

        y = self.graphAreaView.frame.origin.y - h
        self.minValueLabel = UILabel()
        self.minValueLabel.frame = CGRect(x: x, y: y, width: w, height: h)
        self.minValueLabel.text = ""
        self.minValueLabel.textColor = UIColor.black
        self.minValueLabel.backgroundColor = UIColor.clear
        self.minValueLabel.font = UIFont(name: "Migu 2M", size: 12)
        self.minValueLabel.textAlignment = NSTextAlignment.left
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
        self.nowValueLabel.font = UIFont(name: "Migu 2M", size: 12)
        self.nowValueLabel.textAlignment = NSTextAlignment.left
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

        self.min0Label = UILabel()
        self.min0Label.text = "0 min"
        self.min0Label.textColor = UIColor.black
        self.min0Label.backgroundColor = UIColor.clear
        self.min0Label.font = UIFont(name: "Migu 2M", size: 12)
        self.min0Label.textAlignment = NSTextAlignment.center
        self.min0Label.numberOfLines = 1
        self.graphScaleAreaView.addSubview(self.min0Label)
        self.min0Label.sizeToFit()
        self.min0Label.frame = CGRect(x: 0, y: 0, width: self.min0Label.frame.size.width, height: self.graphScaleAreaView.frame.size.height)

        self.min1Label = UILabel()
        self.min1Label.text = "1 min"
        self.min1Label.textColor = UIColor.black
        self.min1Label.backgroundColor = UIColor.clear
        self.min1Label.font = UIFont(name: "Migu 2M", size: 12)
        self.min1Label.textAlignment = NSTextAlignment.center
        self.min1Label.numberOfLines = 1
        self.graphScaleAreaView.addSubview(self.min1Label)
        self.min1Label.sizeToFit()
        self.min1Label.frame = CGRect(x: 0, y: 0, width: self.min1Label.frame.size.width, height: self.graphScaleAreaView.frame.size.height)

        self.min2Label = UILabel()
        self.min2Label.text = "2 min"
        self.min2Label.textColor = UIColor.black
        self.min2Label.backgroundColor = UIColor.clear
        self.min2Label.font = UIFont(name: "Migu 2M", size: 12)
        self.min2Label.textAlignment = NSTextAlignment.center
        self.min2Label.numberOfLines = 1
        self.graphScaleAreaView.addSubview(self.min2Label)
        self.min2Label.sizeToFit()
        self.min2Label.frame = CGRect(x: 0, y: 0, width: self.min2Label.frame.size.width, height: self.graphScaleAreaView.frame.size.height)

        self.min3Label = UILabel()
        self.min3Label.text = "3 min"
        self.min3Label.textColor = UIColor.black
        self.min3Label.backgroundColor = UIColor.clear
        self.min3Label.font = UIFont(name: "Migu 2M", size: 12)
        self.min3Label.textAlignment = NSTextAlignment.center
        self.min3Label.numberOfLines = 1
        self.graphScaleAreaView.addSubview(self.min3Label)
        self.min3Label.sizeToFit()
        self.min3Label.frame = CGRect(x: 0, y: 0, width: self.min3Label.frame.size.width, height: self.graphScaleAreaView.frame.size.height)

        self.min4Label = UILabel()
        self.min4Label.text = "4 min"
        self.min4Label.textColor = UIColor.black
        self.min4Label.backgroundColor = UIColor.clear
        self.min4Label.font = UIFont(name: "Migu 2M", size: 12)
        self.min4Label.textAlignment = NSTextAlignment.center
        self.min4Label.numberOfLines = 1
        self.graphScaleAreaView.addSubview(self.min4Label)
        self.min4Label.sizeToFit()
        self.min4Label.frame = CGRect(x: 0, y: 0, width: self.min4Label.frame.size.width, height: self.graphScaleAreaView.frame.size.height)

        let swipeGesture: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeSynapseValuesViewGestureAction(_:)))
        self.synapseValuesView.addGestureRecognizer(swipeGesture)
        let swipeGestureLeft: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeSynapseValuesViewGestureAction(_:)))
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
        self.synapseValuesAnalyzeButton.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 16)
        self.synapseValuesAnalyzeButton.backgroundColor = UIColor.clear
        self.synapseValuesAnalyzeButton.layer.cornerRadius = h / 2
        self.synapseValuesAnalyzeButton.clipsToBounds = true
        self.synapseValuesAnalyzeButton.layer.borderColor = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 0.3).cgColor
        self.synapseValuesAnalyzeButton.layer.borderWidth = 1.0
        self.synapseValuesAnalyzeButton.addTarget(self, action: #selector(self.pushAnalyzeViewAction), for: .touchUpInside)
        self.synapseValuesView.addSubview(self.synapseValuesAnalyzeButton)
        /*
        w = 100.0
        x = (self.synapseValuesView.frame.size.width - w) / 2
        y = self.graphScaleAreaView.frame.origin.y + self.graphScaleAreaView.frame.size.height + 10.0
        h = (self.synapseValuesView.frame.size.height - y) / 2
        if h > 44.0 {
            h = 44.0
        }
        self.synapseValuesAnalyzeButton = UIButton()
        self.synapseValuesAnalyzeButton.frame = CGRect(x: x, y: y, width: w, height: h)
        self.synapseValuesAnalyzeButton.setTitle("Analyze", for: .normal)
        self.synapseValuesAnalyzeButton.setTitleColor(UIColor.white, for: .normal)
        self.synapseValuesAnalyzeButton.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 16)
        self.synapseValuesAnalyzeButton.backgroundColor = UIColor.clear
        self.synapseValuesAnalyzeButton.addTarget(self, action: #selector(self.pushAnalyzeViewAction), for: .touchUpInside)
        self.synapseValuesView.addSubview(self.synapseValuesAnalyzeButton)

        y += h
        self.synapseValuesBackButton = UIButton()
        self.synapseValuesBackButton.frame = CGRect(x: x, y: y, width: w, height: h)
        self.synapseValuesBackButton.setTitle("Back", for: .normal)
        self.synapseValuesBackButton.setTitleColor(UIColor.white, for: .normal)
        self.synapseValuesBackButton.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 16)
        self.synapseValuesBackButton.backgroundColor = UIColor.clear
        self.synapseValuesBackButton.addTarget(self, action: #selector(self.closeSynapseValuesViewAction), for: .touchUpInside)
        self.synapseValuesView.addSubview(self.synapseValuesBackButton)*/
    }

    @objc func pushAnalyzeViewAction() {

        if self.synapseValueLabels.name == self.mainSynapseObject.synapseValues.name {
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
        self.debugAreaBtn.isHidden = false

        let action = SCNAction.move(to: SCNVector3(x: self.cameraNode.position.x, y: self.cameraNode.position.y, z: self.pinchZoomDef), duration: 0.1)
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
                view.frame = CGRect(x: tabX, y: view.frame.origin.y, width: view.frame.size.width, height: view.frame.size.height)
                tabX += view.frame.size.width
            }
            if let view = self.synapseDataLabels[key] {
                view.frame = CGRect(x: dataX, y: view.frame.origin.y, width: view.frame.size.width, height: view.frame.size.height)
                dataX += view.frame.size.width
            }
        }

        self.synapseTabView.frame = CGRect(x: (self.synapseValuesView.frame.width - self.synapseTabView.frame.size.width) / 2, y: self.synapseTabView.frame.origin.y, width: self.synapseTabView.frame.size.width, height: self.synapseTabView.frame.size.height)
        self.synapseDataView.frame = CGRect(x: (self.synapseValuesView.frame.width - self.synapseDataView.frame.size.width) / 2, y: self.synapseDataView.frame.origin.y, width: self.synapseDataView.frame.size.width, height: self.synapseDataView.frame.size.height)
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
            UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: { () -> Void in

                self.synapseTabView.frame = CGRect(x: self.synapseTabView.frame.origin.x + tabW * x, y: self.synapseTabView.frame.origin.y, width: self.synapseTabView.frame.size.width, height: self.synapseTabView.frame.size.height)
                self.synapseDataView.frame = CGRect(x: self.synapseDataView.frame.origin.x + dataW * x, y: self.synapseDataView.frame.origin.y, width: self.synapseDataView.frame.size.width, height: self.synapseDataView.frame.size.height)
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
            else if key == "ax", let val = synapseValues.ax {
                values = [1, Double(val)]
            }
            else if key == "ay", let val = synapseValues.ay {
                values = [1, Double(val)]
            }
            else if key == "az", let val = synapseValues.az {
                values = [1, Double(val)]
            }
            else if key == "gx", let val = synapseValues.gx {
                values = [1, Double(val)]
            }
            else if key == "gy", let val = synapseValues.gy {
                values = [1, Double(val)]
            }
            else if key == "gz", let val = synapseValues.gz {
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
            if let data = self.synapseGraphData["ax"] {
                graphData.append(data)
                if let ax = synapseObject.synapseValues.ax {
                    lastVals.append(Double(ax))
                }
                else {
                    lastVals.append(0)
                }
            }
            if let data = self.synapseGraphData["ay"] {
                graphData.append(data)
                if let ay = synapseObject.synapseValues.ay {
                    lastVals.append(Double(ay))
                }
                else {
                    lastVals.append(0)
                }
            }
            if let data = self.synapseGraphData["az"] {
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
            if let data = self.synapseGraphData["gx"] {
                graphData.append(data)
                if let gx = synapseObject.synapseValues.gx {
                    lastVals.append(Double(gx))
                }
                else {
                    lastVals.append(0)
                }
            }
            if let data = self.synapseGraphData["gy"] {
                graphData.append(data)
                if let gy = synapseObject.synapseValues.gy {
                    lastVals.append(Double(gy))
                }
                else {
                    lastVals.append(0)
                }
            }
            if let data = self.synapseGraphData["gz"] {
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
            self.min0Label.frame = CGRect(x: baseX - self.min0Label.frame.size.width / 2, y: self.min0Label.frame.origin.y, width: self.min0Label.frame.size.width, height: self.min0Label.frame.size.height)
            baseX -= blockW * 2
            self.min1Label.frame = CGRect(x: baseX - self.min1Label.frame.size.width / 2, y: self.min1Label.frame.origin.y, width: self.min1Label.frame.size.width, height: self.min1Label.frame.size.height)
            baseX -= blockW * 2
            self.min2Label.frame = CGRect(x: baseX - self.min2Label.frame.size.width / 2, y: self.min2Label.frame.origin.y, width: self.min2Label.frame.size.width, height: self.min2Label.frame.size.height)
            baseX -= blockW * 2
            self.min3Label.frame = CGRect(x: baseX - self.min3Label.frame.size.width / 2, y: self.min3Label.frame.origin.y, width: self.min3Label.frame.size.width, height: self.min3Label.frame.size.height)
            baseX -= blockW * 2
            self.min4Label.frame = CGRect(x: baseX - self.min4Label.frame.size.width / 2, y: self.min4Label.frame.origin.y, width: self.min4Label.frame.size.width, height: self.min4Label.frame.size.height)
        }
        if self.graphImageUnderView.frame.size.width == 0 {
            self.graphImageUnderView.frame = CGRect(x: self.graphImageUnderView.frame.origin.x, y: self.graphImageUnderView.frame.origin.y, width: imageW - self.graphAreaView.frame.origin.x, height: self.graphImageUnderView.frame.size.height)

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

        return image;
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
                self.mainSynapseObject.rotateSynapseNode()
                self.mainSynapseObject.scaleSynapseNode()
                self.mainSynapseObject.setColorSynapseNodeFromBatteryLevel()
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

        self.updateDebugAreaView(synapseObject: self.mainSynapseObject)
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
    }*/

    func updateSynapseValuesViewFromSetting() {

        if self.canUpdateValuesView {
            if self.synapseValueLabels.name == self.mainSynapseObject.synapseValues.name {
                self.updateSynapseValuesView(synapseValues: self.mainSynapseObject.synapseValues)
            }
        }
        //self.updateDebugAreaView(synapseObject: self.mainSynapseObject)
    }

    func updateSynapseValuesView(synapseValues: SynapseValues) {

        //print("\(Date()) updateSynapseValuesView")
        if !synapseValues.isConnected {
            return
        }

        self.resetSynapseValuesView()

        if let co2 = synapseValues.co2, let co2Label = self.synapseValueLabels.co2Labels.valueLabel {
            self.synapseValueLabels.co2Labels.diffLabel?.text = ""

            let co2Str: String = String(co2)
            if co2Label.text != co2Str {
                if let text = co2Label.text {
                    if text.count > 0 {
                        let val: Int = Int(text)!
                        if co2 > val {
                            self.synapseValueLabels.co2Labels.diffLabel?.text = "⬆︎ \(String(co2 - val))"
                        }
                        else if co2 < val {
                            self.synapseValueLabels.co2Labels.diffLabel?.text = "⬇︎ \(String(val - co2))"
                        }
                    }
                }

                co2Label.text = co2Str
                co2Label.sizeToFit()
                var w: CGFloat = co2Label.frame.size.width
                var h: CGFloat = co2Label.frame.size.height
                var x: CGFloat = (self.synapseValuesView.frame.width - w) / 2
                var y: CGFloat = (self.synapseDataView.frame.height - h) / 2
                co2Label.frame = CGRect(x: x, y: y, width: w, height: h)

                self.synapseValueLabels.co2Labels.unitLabel?.sizeToFit()
                x = x + w + 10.0
                y = y + h - (self.synapseValueLabels.co2Labels.unitLabel?.frame.size.height)! - 5.0
                w = (self.synapseValueLabels.co2Labels.unitLabel?.frame.size.width)!
                h = (self.synapseValueLabels.co2Labels.unitLabel?.frame.size.height)!
                self.synapseValueLabels.co2Labels.unitLabel?.frame = CGRect(x: x, y: y, width: w, height: h)

                self.synapseValueLabels.co2Labels.diffLabel?.sizeToFit()
                w = (self.synapseValueLabels.co2Labels.diffLabel?.frame.size.width)!
                h = (self.synapseValueLabels.co2Labels.diffLabel?.frame.size.height)!
                x = co2Label.frame.origin.x - (w + 5.0)
                y = co2Label.frame.origin.y
                if x < 0.0 {
                    x = 0
                    y -= h
                }
                self.synapseValueLabels.co2Labels.diffLabel?.frame = CGRect(x: x, y: y, width: w, height: h)
            }
        }
        if let temp = synapseValues.temp, let tempLabel = self.synapseValueLabels.tempLabels.valueLabel {
            self.synapseValueLabels.tempLabels.diffLabel?.text = ""

            var tempVal: Float = temp
            self.synapseValueLabels.tempLabels.unitLabel?.text = "℃"
            if self.appDelegate.temperatureScale == "F" {
                tempVal = CommonFunction.makeFahrenheitTemperatureValue(tempVal)
                self.synapseValueLabels.tempLabels.unitLabel?.text = "℉"
            }
            let tempStr: String = String(format:"%.1f", tempVal)
            if tempLabel.text != tempStr {
                if let text = tempLabel.text {
                    if text.count > 0 {
                        let val: Float = Float(atof(text))
                        if tempVal > val {
                            self.synapseValueLabels.tempLabels.diffLabel?.text = "⬆︎ \(String(format:"%.1f", tempVal - val))"
                        }
                        else if tempVal < val {
                            self.synapseValueLabels.tempLabels.diffLabel?.text = "⬇︎ \(String(format:"%.1f", val - tempVal))"
                        }
                    }
                }

                tempLabel.text = tempStr
                tempLabel.sizeToFit()
                var w: CGFloat = tempLabel.frame.size.width
                var h: CGFloat = tempLabel.frame.size.height
                var x: CGFloat = (self.synapseValuesView.frame.width - w) / 2
                var y: CGFloat = (self.synapseDataView.frame.height - h) / 2
                tempLabel.frame = CGRect(x: x, y: y, width: w, height: h)

                self.synapseValueLabels.tempLabels.unitLabel?.sizeToFit()
                x = x + w + 10.0
                y = y + h - (self.synapseValueLabels.tempLabels.unitLabel?.frame.size.height)! - 5.0
                w = (self.synapseValueLabels.tempLabels.unitLabel?.frame.size.width)!
                h = (self.synapseValueLabels.tempLabels.unitLabel?.frame.size.height)!
                self.synapseValueLabels.tempLabels.unitLabel?.frame = CGRect(x: x, y: y, width: w, height: h)

                self.synapseValueLabels.tempLabels.diffLabel?.sizeToFit()
                w = (self.synapseValueLabels.tempLabels.diffLabel?.frame.size.width)!
                h = (self.synapseValueLabels.tempLabels.diffLabel?.frame.size.height)!
                x = tempLabel.frame.origin.x - (w + 5.0)
                y = tempLabel.frame.origin.y
                if x < 0.0 {
                    x = 0
                    y -= h
                }
                self.synapseValueLabels.tempLabels.diffLabel?.frame = CGRect(x: x, y: y, width: w, height: h)
            }
        }
        if let pressure = synapseValues.pressure, let pressLabel = self.synapseValueLabels.pressLabels.valueLabel {
            self.synapseValueLabels.pressLabels.diffLabel?.text = ""

            let pressStr: String = String(format:"%.1f", pressure)
            if pressLabel.text != pressStr {
                if let text = pressLabel.text {
                    if text.count > 0 {
                        let val: Float = Float(atof(text))
                        if pressure > val {
                            self.synapseValueLabels.pressLabels.diffLabel?.text = "⬆︎ \(String(format:"%.1f", pressure - val))"
                        }
                        else if pressure < val {
                            self.synapseValueLabels.pressLabels.diffLabel?.text = "⬇︎ \(String(format:"%.1f", val - pressure))"
                        }
                    }
                }

                pressLabel.text = pressStr
                pressLabel.sizeToFit()
                var w: CGFloat = pressLabel.frame.size.width
                var h: CGFloat = pressLabel.frame.size.height
                var x: CGFloat = (self.synapseValuesView.frame.width - w) / 2
                var y: CGFloat = (self.synapseDataView.frame.height - h) / 2
                pressLabel.frame = CGRect(x: x, y: y, width: w, height: h)

                self.synapseValueLabels.pressLabels.unitLabel?.sizeToFit()
                x = x + w + 10.0
                y = y + h - (self.synapseValueLabels.pressLabels.unitLabel?.frame.size.height)! - 5.0
                w = (self.synapseValueLabels.pressLabels.unitLabel?.frame.size.width)!
                h = (self.synapseValueLabels.pressLabels.unitLabel?.frame.size.height)!
                self.synapseValueLabels.pressLabels.unitLabel?.frame = CGRect(x: x, y: y, width: w, height: h)

                self.synapseValueLabels.pressLabels.diffLabel?.sizeToFit()
                w = (self.synapseValueLabels.pressLabels.diffLabel?.frame.size.width)!
                h = (self.synapseValueLabels.pressLabels.diffLabel?.frame.size.height)!
                x = pressLabel.frame.origin.x - (w + 5.0)
                y = pressLabel.frame.origin.y
                if x < 0.0 {
                    x = 0
                    y -= h
                }
                self.synapseValueLabels.pressLabels.diffLabel?.frame = CGRect(x: x, y: y, width: w, height: h)
            }
        }
        /*if let mx = synapseValues.mx, let my = synapseValues.my, let mz = synapseValues.mz, let magxLabel = self.synapseValueLabels.magxLabels.valueLabel, let magyLabel = self.synapseValueLabels.magyLabels.valueLabel, let magzLabel = self.synapseValueLabels.magzLabels.valueLabel {
            self.synapseValueLabels.magxLabels.diffLabel?.text = ""
            self.synapseValueLabels.magyLabels.diffLabel?.text = ""
            self.synapseValueLabels.magzLabels.diffLabel?.text = ""

            let mxStr: String = String(mx)
            let myStr: String = String(my)
            let mzStr: String = String(mz)
            if magxLabel.text != mxStr || magyLabel.text != myStr || magzLabel.text != mzStr {
                if let text = magxLabel.text {
                    if text.count > 0 {
                        let val: Int = Int(text)!
                        if mx > val {
                            self.synapseValueLabels.magxLabels.diffLabel?.text = "⬆︎ \(String(mx - val))"
                        }
                        else if mx < val {
                            self.synapseValueLabels.magxLabels.diffLabel?.text = "⬇︎ \(String(val - mx))"
                        }
                    }
                }
                if let text = magyLabel.text {
                    if text.count > 0 {
                        let val: Int = Int(text)!
                        if my > val {
                            self.synapseValueLabels.magyLabels.diffLabel?.text = "⬆︎ \(String(my - val))"
                        }
                        else if my < val {
                            self.synapseValueLabels.magyLabels.diffLabel?.text = "⬇︎ \(String(val - my))"
                        }
                    }
                }
                if let text = magzLabel.text {
                    if text.count > 0 {
                        let val: Int = Int(text)!
                        if mz > val {
                            self.synapseValueLabels.magzLabels.diffLabel?.text = "⬆︎ \(String(mz - val))"
                        }
                        else if mz < val {
                            self.synapseValueLabels.magzLabels.diffLabel?.text = "⬇︎ \(String(val - mz))"
                        }
                    }
                }

                magxLabel.text = mxStr
                magxLabel.sizeToFit()
                magyLabel.text = myStr
                magyLabel.sizeToFit()
                magzLabel.text = mzStr
                magzLabel.sizeToFit()

                let baseY: CGFloat = (self.synapseDataView.frame.height - (magxLabel.frame.size.height + magyLabel.frame.size.height + magzLabel.frame.size.height + 10.0 * 2)) / 2
                var baseW: CGFloat = magxLabel.frame.size.width
                if baseW < magyLabel.frame.size.width {
                    baseW = magyLabel.frame.size.width
                }
                if baseW < magzLabel.frame.size.width {
                    baseW = magzLabel.frame.size.width
                }
                let baseX: CGFloat = (self.synapseValuesView.frame.width - baseW) / 2

                var w: CGFloat = magxLabel.frame.size.width
                var h: CGFloat = magxLabel.frame.size.height
                var x: CGFloat = baseX + (baseW - w)
                var y: CGFloat = baseY
                magxLabel.frame = CGRect(x: x, y: y, width: w, height: h)
                y += h + 10.0
                w = magyLabel.frame.size.width
                x = baseX + (baseW - w)
                h = magyLabel.frame.size.height
                magyLabel.frame = CGRect(x: x, y: y, width: w, height: h)
                y += h + 10.0
                w = magzLabel.frame.size.width
                x = baseX + (baseW - w)
                h = magzLabel.frame.size.height
                magzLabel.frame = CGRect(x: x, y: y, width: w, height: h)

                self.synapseValueLabels.magxLabels.unitLabel?.sizeToFit()
                x = magxLabel.frame.origin.x + magxLabel.frame.size.width + 10.0
                y = magxLabel.frame.origin.y + magxLabel.frame.size.height - (self.synapseValueLabels.magxLabels.unitLabel?.frame.size.height)! - 5.0
                w = (self.synapseValueLabels.magxLabels.unitLabel?.frame.size.width)!
                h = (self.synapseValueLabels.magxLabels.unitLabel?.frame.size.height)!
                self.synapseValueLabels.magxLabels.unitLabel?.frame = CGRect(x: x, y: y, width: w, height: h)
                self.synapseValueLabels.magyLabels.unitLabel?.sizeToFit()
                x = magyLabel.frame.origin.x + magyLabel.frame.size.width + 10.0
                y = magyLabel.frame.origin.y + magyLabel.frame.size.height - (self.synapseValueLabels.magyLabels.unitLabel?.frame.size.height)! - 5.0
                w = (self.synapseValueLabels.magyLabels.unitLabel?.frame.size.width)!
                h = (self.synapseValueLabels.magyLabels.unitLabel?.frame.size.height)!
                self.synapseValueLabels.magyLabels.unitLabel?.frame = CGRect(x: x, y: y, width: w, height: h)
                self.synapseValueLabels.magzLabels.unitLabel?.sizeToFit()
                x = magzLabel.frame.origin.x + magzLabel.frame.size.width + 10.0
                y = magzLabel.frame.origin.y + magzLabel.frame.size.height - (self.synapseValueLabels.magzLabels.unitLabel?.frame.size.height)! - 5.0
                w = (self.synapseValueLabels.magzLabels.unitLabel?.frame.size.width)!
                h = (self.synapseValueLabels.magzLabels.unitLabel?.frame.size.height)!
                self.synapseValueLabels.magzLabels.unitLabel?.frame = CGRect(x: x, y: y, width: w, height: h)

                self.synapseValueLabels.magxLabels.diffLabel?.sizeToFit()
                w = (self.synapseValueLabels.magxLabels.diffLabel?.frame.size.width)!
                h = (self.synapseValueLabels.magxLabels.diffLabel?.frame.size.height)!
                x = baseX - (w + 5.0)
                y = magxLabel.frame.origin.y
                if x < 0.0 {
                    x = 0
                    y -= h
                }
                self.synapseValueLabels.magxLabels.diffLabel?.frame = CGRect(x: x, y: y, width: w, height: h)
                self.synapseValueLabels.magyLabels.diffLabel?.sizeToFit()
                w = (self.synapseValueLabels.magyLabels.diffLabel?.frame.size.width)!
                h = (self.synapseValueLabels.magyLabels.diffLabel?.frame.size.height)!
                x = baseX - (w + 5.0)
                y = magyLabel.frame.origin.y
                if x < 0.0 {
                    x = 0
                    y -= h
                }
                self.synapseValueLabels.magyLabels.diffLabel?.frame = CGRect(x: x, y: y, width: w, height: h)
                self.synapseValueLabels.magzLabels.diffLabel?.sizeToFit()
                w = (self.synapseValueLabels.magzLabels.diffLabel?.frame.size.width)!
                h = (self.synapseValueLabels.magzLabels.diffLabel?.frame.size.height)!
                x = baseX - (w + 5.0)
                y = magzLabel.frame.origin.y
                if x < 0.0 {
                    x = 0
                    y -= h
                }
                self.synapseValueLabels.magzLabels.diffLabel?.frame = CGRect(x: x, y: y, width: w, height: h)
            }
        }*/
        if let ax = synapseValues.ax, let ay = synapseValues.ay, let az = synapseValues.az, let movexLabel = self.synapseValueLabels.movexLabels.valueLabel, let moveyLabel = self.synapseValueLabels.moveyLabels.valueLabel, let movezLabel = self.synapseValueLabels.movezLabels.valueLabel {
            self.synapseValueLabels.movexLabels.diffLabel?.text = ""
            self.synapseValueLabels.moveyLabels.diffLabel?.text = ""
            self.synapseValueLabels.movezLabels.diffLabel?.text = ""

            let axF: Float = Float(ax) * self.aScale
            let ayF: Float = Float(ay) * self.aScale
            let azF: Float = Float(az) * self.aScale
            let axStr: String = String(format:"%.4f", axF)
            let ayStr: String = String(format:"%.4f", ayF)
            let azStr: String = String(format:"%.4f", azF)
            if movexLabel.text != axStr || moveyLabel.text != ayStr || movezLabel.text != azStr {
                if let text = movexLabel.text {
                    if text.count > 0 {
                        let val: Float = Float(atof(text))
                        if axF > val {
                            self.synapseValueLabels.movexLabels.diffLabel?.text = "⬆︎ \(String(format:"%.4f", axF - val))"
                        }
                        else if axF < val {
                            self.synapseValueLabels.movexLabels.diffLabel?.text = "⬇︎ \(String(format:"%.4f", val - axF))"
                        }
                    }
                }
                if let text = moveyLabel.text {
                    if text.count > 0 {
                        let val: Float = Float(atof(text))
                        if ayF > val {
                            self.synapseValueLabels.moveyLabels.diffLabel?.text = "⬆︎ \(String(format:"%.4f", ayF - val))"
                        }
                        else if ayF < val {
                            self.synapseValueLabels.moveyLabels.diffLabel?.text = "⬇︎ \(String(format:"%.4f", val - ayF))"
                        }
                    }
                }
                if let text = movezLabel.text {
                    if text.count > 0 {
                        let val: Float = Float(atof(text))
                        if azF > val {
                            self.synapseValueLabels.movezLabels.diffLabel?.text = "⬆︎ \(String(format:"%.4f", azF - val))"
                        }
                        else if azF < val {
                            self.synapseValueLabels.movezLabels.diffLabel?.text = "⬇︎ \(String(format:"%.4f", val - azF))"
                        }
                    }
                }

                movexLabel.text = axStr
                movexLabel.sizeToFit()
                moveyLabel.text = ayStr
                moveyLabel.sizeToFit()
                movezLabel.text = azStr
                movezLabel.sizeToFit()

                let baseY: CGFloat = (self.synapseDataView.frame.height - (movexLabel.frame.size.height + moveyLabel.frame.size.height + movezLabel.frame.size.height + 10.0 * 2)) / 2
                var baseW: CGFloat = movexLabel.frame.size.width
                if baseW < moveyLabel.frame.size.width {
                    baseW = moveyLabel.frame.size.width
                }
                if baseW < movezLabel.frame.size.width {
                    baseW = movezLabel.frame.size.width
                }
                let baseX: CGFloat = (self.synapseValuesView.frame.width - baseW) / 2

                var w: CGFloat = movexLabel.frame.size.width
                var h: CGFloat = movexLabel.frame.size.height
                var x: CGFloat = baseX + (baseW - w)
                var y: CGFloat = baseY
                movexLabel.frame = CGRect(x: x, y: y, width: w, height: h)
                y += h + 10.0
                w = moveyLabel.frame.size.width
                x = baseX + (baseW - w)
                h = moveyLabel.frame.size.height
                moveyLabel.frame = CGRect(x: x, y: y, width: w, height: h)
                y += h + 10.0
                w = movezLabel.frame.size.width
                x = baseX + (baseW - w)
                h = movezLabel.frame.size.height
                movezLabel.frame = CGRect(x: x, y: y, width: w, height: h)

                self.synapseValueLabels.movexLabels.unitLabel?.sizeToFit()
                x = movexLabel.frame.origin.x + movexLabel.frame.size.width + 10.0
                y = movexLabel.frame.origin.y + movexLabel.frame.size.height - (self.synapseValueLabels.movexLabels.unitLabel?.frame.size.height)! - 5.0
                w = (self.synapseValueLabels.movexLabels.unitLabel?.frame.size.width)!
                h = (self.synapseValueLabels.movexLabels.unitLabel?.frame.size.height)!
                self.synapseValueLabels.movexLabels.unitLabel?.frame = CGRect(x: x, y: y, width: w, height: h)
                self.synapseValueLabels.moveyLabels.unitLabel?.sizeToFit()
                x = moveyLabel.frame.origin.x + moveyLabel.frame.size.width + 10.0
                y = moveyLabel.frame.origin.y + moveyLabel.frame.size.height - (self.synapseValueLabels.moveyLabels.unitLabel?.frame.size.height)! - 5.0
                w = (self.synapseValueLabels.moveyLabels.unitLabel?.frame.size.width)!
                h = (self.synapseValueLabels.moveyLabels.unitLabel?.frame.size.height)!
                self.synapseValueLabels.moveyLabels.unitLabel?.frame = CGRect(x: x, y: y, width: w, height: h)
                self.synapseValueLabels.movezLabels.unitLabel?.sizeToFit()
                x = movezLabel.frame.origin.x + movezLabel.frame.size.width + 10.0
                y = movezLabel.frame.origin.y + movezLabel.frame.size.height - (self.synapseValueLabels.movezLabels.unitLabel?.frame.size.height)! - 5.0
                w = (self.synapseValueLabels.movezLabels.unitLabel?.frame.size.width)!
                h = (self.synapseValueLabels.movezLabels.unitLabel?.frame.size.height)!
                self.synapseValueLabels.movezLabels.unitLabel?.frame = CGRect(x: x, y: y, width: w, height: h)

                self.synapseValueLabels.movexLabels.diffLabel?.sizeToFit()
                w = (self.synapseValueLabels.movexLabels.diffLabel?.frame.size.width)!
                h = (self.synapseValueLabels.movexLabels.diffLabel?.frame.size.height)!
                x = baseX - (w + 5.0)
                y = movexLabel.frame.origin.y
                if x < 0.0 {
                    x = 0
                    y -= h
                }
                self.synapseValueLabels.movexLabels.diffLabel?.frame = CGRect(x: x, y: y, width: w, height: h)
                self.synapseValueLabels.moveyLabels.diffLabel?.sizeToFit()
                w = (self.synapseValueLabels.moveyLabels.diffLabel?.frame.size.width)!
                h = (self.synapseValueLabels.moveyLabels.diffLabel?.frame.size.height)!
                x = baseX - (w + 5.0)
                y = moveyLabel.frame.origin.y
                if x < 0.0 {
                    x = 0
                    y -= h
                }
                self.synapseValueLabels.moveyLabels.diffLabel?.frame = CGRect(x: x, y: y, width: w, height: h)
                self.synapseValueLabels.movezLabels.diffLabel?.sizeToFit()
                w = (self.synapseValueLabels.movezLabels.diffLabel?.frame.size.width)!
                h = (self.synapseValueLabels.movezLabels.diffLabel?.frame.size.height)!
                x = baseX - (w + 5.0)
                y = movezLabel.frame.origin.y
                if x < 0.0 {
                    x = 0
                    y -= h
                }
                self.synapseValueLabels.movezLabels.diffLabel?.frame = CGRect(x: x, y: y, width: w, height: h)
            }
        }
        if let gx = synapseValues.gx, let gy = synapseValues.gy, let gz = synapseValues.gz, let anglexLabel = self.synapseValueLabels.anglexLabels.valueLabel, let angleyLabel = self.synapseValueLabels.angleyLabels.valueLabel, let anglezLabel = self.synapseValueLabels.anglezLabels.valueLabel {
            self.synapseValueLabels.anglexLabels.diffLabel?.text = ""
            self.synapseValueLabels.angleyLabels.diffLabel?.text = ""
            self.synapseValueLabels.anglezLabels.diffLabel?.text = ""

            let gxF: Float = Float(gx) * self.gScale * Float(Double.pi / 180.0)
            let gyF: Float = Float(gy) * self.gScale * Float(Double.pi / 180.0)
            let gzF: Float = Float(gz) * self.gScale * Float(Double.pi / 180.0)
            let gxStr: String = String(format:"%.4f", gxF)
            let gyStr: String = String(format:"%.4f", gyF)
            let gzStr: String = String(format:"%.4f", gzF)
            if anglexLabel.text != gxStr || angleyLabel.text != gyStr || anglezLabel.text != gzStr {
                if let text = anglexLabel.text {
                    if text.count > 0 {
                        let val: Float = Float(atof(text))
                        if gxF > val {
                            self.synapseValueLabels.anglexLabels.diffLabel?.text = "⬆︎ \(String(format:"%.4f", gxF - val))"
                        }
                        else if gxF < val {
                            self.synapseValueLabels.anglexLabels.diffLabel?.text = "⬇︎ \(String(format:"%.4f", val - gxF))"
                        }
                    }
                }
                if let text = angleyLabel.text {
                    if text.count > 0 {
                        let val: Float = Float(atof(text))
                        if gyF > val {
                            self.synapseValueLabels.angleyLabels.diffLabel?.text = "⬆︎ \(String(format:"%.4f", gyF - val))"
                        }
                        else if gyF < val {
                            self.synapseValueLabels.angleyLabels.diffLabel?.text = "⬇︎ \(String(format:"%.4f", val - gyF))"
                        }
                    }
                }
                if let text = anglezLabel.text {
                    if text.count > 0 {
                        let val: Float = Float(atof(text))
                        if gzF > val {
                            self.synapseValueLabels.anglezLabels.diffLabel?.text = "⬆︎ \(String(format:"%.4f", gzF - val))"
                        }
                        else if gzF < val {
                            self.synapseValueLabels.anglezLabels.diffLabel?.text = "⬇︎ \(String(format:"%.4f", val - gzF))"
                        }
                    }
                }

                anglexLabel.text = gxStr
                anglexLabel.sizeToFit()
                angleyLabel.text = gyStr
                angleyLabel.sizeToFit()
                anglezLabel.text = gzStr
                anglezLabel.sizeToFit()

                let baseY: CGFloat = (self.synapseDataView.frame.height - (anglexLabel.frame.size.height + angleyLabel.frame.size.height + anglezLabel.frame.size.height + 10.0 * 2)) / 2
                var baseW: CGFloat = anglexLabel.frame.size.width
                if baseW < angleyLabel.frame.size.width {
                    baseW = angleyLabel.frame.size.width
                }
                if baseW < anglezLabel.frame.size.width {
                    baseW = anglezLabel.frame.size.width
                }
                let baseX: CGFloat = (self.synapseValuesView.frame.width - baseW) / 2

                var w: CGFloat = anglexLabel.frame.size.width
                var h: CGFloat = anglexLabel.frame.size.height
                var x: CGFloat = baseX + (baseW - w)
                var y: CGFloat = baseY
                anglexLabel.frame = CGRect(x: x, y: y, width: w, height: h)
                y += h + 10.0
                w = angleyLabel.frame.size.width
                x = baseX + (baseW - w)
                h = angleyLabel.frame.size.height
                angleyLabel.frame = CGRect(x: x, y: y, width: w, height: h)
                y += h + 10.0
                w = anglezLabel.frame.size.width
                x = baseX + (baseW - w)
                h = anglezLabel.frame.size.height
                anglezLabel.frame = CGRect(x: x, y: y, width: w, height: h)

                self.synapseValueLabels.anglexLabels.unitLabel?.sizeToFit()
                x = anglexLabel.frame.origin.x + anglexLabel.frame.size.width + 10.0
                y = anglexLabel.frame.origin.y + anglexLabel.frame.size.height - (self.synapseValueLabels.anglexLabels.unitLabel?.frame.size.height)! - 5.0
                w = (self.synapseValueLabels.anglexLabels.unitLabel?.frame.size.width)!
                h = (self.synapseValueLabels.anglexLabels.unitLabel?.frame.size.height)!
                self.synapseValueLabels.anglexLabels.unitLabel?.frame = CGRect(x: x, y: y, width: w, height: h)
                self.synapseValueLabels.angleyLabels.unitLabel?.sizeToFit()
                x = angleyLabel.frame.origin.x + angleyLabel.frame.size.width + 10.0
                y = angleyLabel.frame.origin.y + angleyLabel.frame.size.height - (self.synapseValueLabels.angleyLabels.unitLabel?.frame.size.height)! - 5.0
                w = (self.synapseValueLabels.angleyLabels.unitLabel?.frame.size.width)!
                h = (self.synapseValueLabels.angleyLabels.unitLabel?.frame.size.height)!
                self.synapseValueLabels.angleyLabels.unitLabel?.frame = CGRect(x: x, y: y, width: w, height: h)
                self.synapseValueLabels.anglezLabels.unitLabel?.sizeToFit()
                x = anglezLabel.frame.origin.x + anglezLabel.frame.size.width + 10.0
                y = anglezLabel.frame.origin.y + anglezLabel.frame.size.height - (self.synapseValueLabels.anglezLabels.unitLabel?.frame.size.height)! - 5.0
                w = (self.synapseValueLabels.anglezLabels.unitLabel?.frame.size.width)!
                h = (self.synapseValueLabels.anglezLabels.unitLabel?.frame.size.height)!
                self.synapseValueLabels.anglezLabels.unitLabel?.frame = CGRect(x: x, y: y, width: w, height: h)

                self.synapseValueLabels.anglexLabels.diffLabel?.sizeToFit()
                w = (self.synapseValueLabels.anglexLabels.diffLabel?.frame.size.width)!
                h = (self.synapseValueLabels.anglexLabels.diffLabel?.frame.size.height)!
                x = baseX - (w + 5.0)
                y = anglexLabel.frame.origin.y
                if x < 0.0 {
                    x = 0
                    y -= h
                }
                self.synapseValueLabels.anglexLabels.diffLabel?.frame = CGRect(x: x, y: y, width: w, height: h)
                self.synapseValueLabels.angleyLabels.diffLabel?.sizeToFit()
                w = (self.synapseValueLabels.angleyLabels.diffLabel?.frame.size.width)!
                h = (self.synapseValueLabels.angleyLabels.diffLabel?.frame.size.height)!
                x = baseX - (w + 5.0)
                y = angleyLabel.frame.origin.y
                if x < 0.0 {
                    x = 0
                    y -= h
                }
                self.synapseValueLabels.angleyLabels.diffLabel?.frame = CGRect(x: x, y: y, width: w, height: h)
                self.synapseValueLabels.anglezLabels.diffLabel?.sizeToFit()
                w = (self.synapseValueLabels.anglezLabels.diffLabel?.frame.size.width)!
                h = (self.synapseValueLabels.anglezLabels.diffLabel?.frame.size.height)!
                x = baseX - (w + 5.0)
                y = anglezLabel.frame.origin.y
                if x < 0.0 {
                    x = 0
                    y -= h
                }
                self.synapseValueLabels.anglezLabels.diffLabel?.frame = CGRect(x: x, y: y, width: w, height: h)
            }
        }
        if let light = synapseValues.light, let illLabel = self.synapseValueLabels.illLabels.valueLabel {
            self.synapseValueLabels.illLabels.diffLabel?.text = ""

            let illStr: String = String(light)
            if illLabel.text != illStr {
                if let text = illLabel.text {
                    if text.count > 0 {
                        let val: Int = Int(text)!
                        if light > val {
                            self.synapseValueLabels.illLabels.diffLabel?.text = "⬆︎ \(String(light - val))"
                        }
                        else if light < val {
                            self.synapseValueLabels.illLabels.diffLabel?.text = "⬇︎ \(String(val - light))"
                        }
                    }
                }

                illLabel.text = illStr
                illLabel.sizeToFit()
                var w: CGFloat = illLabel.frame.size.width
                var h: CGFloat = illLabel.frame.size.height
                var x: CGFloat = (self.synapseValuesView.frame.width - w) / 2
                var y: CGFloat = (self.synapseDataView.frame.height - h) / 2
                illLabel.frame = CGRect(x: x, y: y, width: w, height: h)

                self.synapseValueLabels.illLabels.unitLabel?.sizeToFit()
                x = x + w + 10.0
                y = y + h - (self.synapseValueLabels.illLabels.unitLabel?.frame.size.height)! - 5.0
                w = (self.synapseValueLabels.illLabels.unitLabel?.frame.size.width)!
                h = (self.synapseValueLabels.illLabels.unitLabel?.frame.size.height)!
                self.synapseValueLabels.illLabels.unitLabel?.frame = CGRect(x: x, y: y, width: w, height: h)

                self.synapseValueLabels.illLabels.diffLabel?.sizeToFit()
                w = (self.synapseValueLabels.illLabels.diffLabel?.frame.size.width)!
                h = (self.synapseValueLabels.illLabels.diffLabel?.frame.size.height)!
                x = illLabel.frame.origin.x - (w + 5.0)
                y = illLabel.frame.origin.y
                if x < 0.0 {
                    x = 0
                    y -= h
                }
                self.synapseValueLabels.illLabels.diffLabel?.frame = CGRect(x: x, y: y, width: w, height: h)
            }
        }
        if let humidity = synapseValues.humidity, let humLabel = self.synapseValueLabels.humLabels.valueLabel {
            self.synapseValueLabels.humLabels.diffLabel?.text = ""

            let humStr: String = String(humidity)
            if humLabel.text != humStr {
                if let text = humLabel.text {
                    if text.count > 0 {
                        let val: Int = Int(text)!
                        if humidity > val {
                            self.synapseValueLabels.humLabels.diffLabel?.text = "⬆︎ \(String(humidity - val))"
                        }
                        else if humidity < val {
                            self.synapseValueLabels.humLabels.diffLabel?.text = "⬇︎ \(String(val - humidity))"
                        }
                    }
                }

                humLabel.text = "\(String(humidity))"
                humLabel.sizeToFit()
                var w: CGFloat = humLabel.frame.size.width
                var h: CGFloat = humLabel.frame.size.height
                var x: CGFloat = (self.synapseValuesView.frame.width - w) / 2
                var y: CGFloat = (self.synapseDataView.frame.height - h) / 2
                humLabel.frame = CGRect(x: x, y: y, width: w, height: h)

                self.synapseValueLabels.humLabels.unitLabel?.sizeToFit()
                x = x + w + 10.0
                y = y + h - (self.synapseValueLabels.humLabels.unitLabel?.frame.size.height)! - 5.0
                w = (self.synapseValueLabels.humLabels.unitLabel?.frame.size.width)!
                h = (self.synapseValueLabels.humLabels.unitLabel?.frame.size.height)!
                self.synapseValueLabels.humLabels.unitLabel?.frame = CGRect(x: x, y: y, width: w, height: h)

                self.synapseValueLabels.humLabels.diffLabel?.sizeToFit()
                w = (self.synapseValueLabels.humLabels.diffLabel?.frame.size.width)!
                h = (self.synapseValueLabels.humLabels.diffLabel?.frame.size.height)!
                x = humLabel.frame.origin.x - (w + 5.0)
                y = humLabel.frame.origin.y
                if x < 0.0 {
                    x = 0
                    y -= h
                }
                self.synapseValueLabels.humLabels.diffLabel?.frame = CGRect(x: x, y: y, width: w, height: h)
            }
        }
        if let sound = synapseValues.sound, let soundLabel = self.synapseValueLabels.soundLabels.valueLabel {
            self.synapseValueLabels.soundLabels.diffLabel?.text = ""

            let soundStr: String = String(sound)
            if soundLabel.text != soundStr {
                if let text = soundLabel.text {
                    if text.count > 0 {
                        let val: Int = Int(text)!
                        if sound > val {
                            self.synapseValueLabels.soundLabels.diffLabel?.text = "⬆︎ \(String(sound - val))"
                        }
                        else if sound < val {
                            self.synapseValueLabels.soundLabels.diffLabel?.text = "⬇︎ \(String(val - sound))"
                        }
                    }
                }

                soundLabel.text = soundStr
                soundLabel.sizeToFit()
                var w: CGFloat = soundLabel.frame.size.width
                var h: CGFloat = soundLabel.frame.size.height
                var x: CGFloat = (self.synapseValuesView.frame.width - w) / 2
                var y: CGFloat = (self.synapseDataView.frame.height - h) / 2
                soundLabel.frame = CGRect(x: x, y: y, width: w, height: h)

                self.synapseValueLabels.soundLabels.unitLabel?.sizeToFit()
                x = x + w + 10.0
                y = y + h - (self.synapseValueLabels.soundLabels.unitLabel?.frame.size.height)! - 5.0
                w = (self.synapseValueLabels.soundLabels.unitLabel?.frame.size.width)!
                h = (self.synapseValueLabels.soundLabels.unitLabel?.frame.size.height)!
                self.synapseValueLabels.soundLabels.unitLabel?.frame = CGRect(x: x, y: y, width: w, height: h)

                self.synapseValueLabels.soundLabels.diffLabel?.sizeToFit()
                w = (self.synapseValueLabels.soundLabels.diffLabel?.frame.size.width)!
                h = (self.synapseValueLabels.soundLabels.diffLabel?.frame.size.height)!
                x = soundLabel.frame.origin.x - (w + 5.0)
                y = soundLabel.frame.origin.y
                if x < 0.0 {
                    x = 0
                    y -= h
                }
                self.synapseValueLabels.soundLabels.diffLabel?.frame = CGRect(x: x, y: y, width: w, height: h)
            }
        }

        if synapseValues.name == self.mainSynapseObject.synapseValues.name {
            self.resetSynapseGraphImage()
            self.checkSynapseGraphData(synapseObject: self.mainSynapseObject)
            self.setSynapseGraphImage(synapseObject: self.mainSynapseObject)
            self.setSynapseMaxAndMinLabel(self.mainSynapseObject.synapseDataMaxAndMins, synapseValuesMain: self.mainSynapseObject.synapseValues)
        }
    }

    func resetSynapseValuesView() {

        self.synapseValueLabels.co2Labels.valueLabel?.text = ""
        self.synapseValueLabels.co2Labels.diffLabel?.text = ""
        self.synapseValueLabels.co2Labels.unitLabel?.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        self.synapseValueLabels.tempLabels.valueLabel?.text = ""
        self.synapseValueLabels.tempLabels.diffLabel?.text = ""
        self.synapseValueLabels.tempLabels.unitLabel?.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        self.synapseValueLabels.pressLabels.valueLabel?.text = ""
        self.synapseValueLabels.pressLabels.diffLabel?.text = ""
        self.synapseValueLabels.pressLabels.unitLabel?.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        self.synapseValueLabels.movexLabels.valueLabel?.text = ""
        self.synapseValueLabels.movexLabels.diffLabel?.text = ""
        self.synapseValueLabels.movexLabels.unitLabel?.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        self.synapseValueLabels.moveyLabels.valueLabel?.text = ""
        self.synapseValueLabels.moveyLabels.diffLabel?.text = ""
        self.synapseValueLabels.moveyLabels.unitLabel?.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        self.synapseValueLabels.movezLabels.valueLabel?.text = ""
        self.synapseValueLabels.movezLabels.diffLabel?.text = ""
        self.synapseValueLabels.movezLabels.unitLabel?.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        self.synapseValueLabels.anglexLabels.valueLabel?.text = ""
        self.synapseValueLabels.anglexLabels.diffLabel?.text = ""
        self.synapseValueLabels.anglexLabels.unitLabel?.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        self.synapseValueLabels.angleyLabels.valueLabel?.text = ""
        self.synapseValueLabels.angleyLabels.diffLabel?.text = ""
        self.synapseValueLabels.angleyLabels.unitLabel?.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        self.synapseValueLabels.anglezLabels.valueLabel?.text = ""
        self.synapseValueLabels.anglezLabels.diffLabel?.text = ""
        self.synapseValueLabels.anglezLabels.unitLabel?.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        self.synapseValueLabels.illLabels.valueLabel?.text = ""
        self.synapseValueLabels.illLabels.diffLabel?.text = ""
        self.synapseValueLabels.illLabels.unitLabel?.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        self.synapseValueLabels.humLabels.valueLabel?.text = ""
        self.synapseValueLabels.humLabels.diffLabel?.text = ""
        self.synapseValueLabels.humLabels.unitLabel?.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        self.synapseValueLabels.soundLabels.valueLabel?.text = ""
        self.synapseValueLabels.soundLabels.diffLabel?.text = ""
        self.synapseValueLabels.soundLabels.unitLabel?.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        /*self.synapseValueLabels.magxLabels.valueLabel?.text = ""
        self.synapseValueLabels.magxLabels.diffLabel?.text = ""
        self.synapseValueLabels.magxLabels.unitLabel?.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        self.synapseValueLabels.magyLabels.valueLabel?.text = ""
        self.synapseValueLabels.magyLabels.diffLabel?.text = ""
        self.synapseValueLabels.magyLabels.unitLabel?.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        self.synapseValueLabels.magzLabels.valueLabel?.text = ""
        self.synapseValueLabels.magzLabels.diffLabel?.text = ""
        self.synapseValueLabels.magzLabels.unitLabel?.frame = CGRect(x: 0, y: 0, width: 0, height: 0)*/
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
        //self.rfduinos = []
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
            for (index, synapse) in self.appDelegate.scanDevices.enumerated() {
                if synapse.peripheral.identifier == rfduino.peripheral.identifier {
                    synapseIndex = index
                    break
                }
            }
            if synapseIndex >= 0 && synapseIndex < self.appDelegate.scanDevices.count {
                self.appDelegate.scanDevices[synapseIndex] = rfduino
            }
            else {
                self.appDelegate.scanDevices.append(rfduino)
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
            self.updateDebugAreaView(synapseObject: self.mainSynapseObject)
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
        //print("setSynapseData: \(time)")
        synapseObject.setSynapseValues()

        var values: Data? = Data(bytes: synapseObject.receiveData)
        var time: TimeInterval? = self.appDelegate.synapseTimeInterval
        DispatchQueue.global(qos: .background).async {
            _ = synapseObject.synapseRecordFileManager?.setValues(values!, date: now, timeInterval: time!)
            values = nil
            time = nil
        }

        if synapseObject.synapseValues.isConnected {
            synapseObject.setSynapseMaxAndMinValues()

            if self.isSynapseAppActive && self.isUpdateViewActive {
                self.updateSynapseViews()
            }

            //self.checkSynapseNotifications(self.synapseValuesMain)
            self.setAudioValues(synapseObject.synapseValues)

            let timeInterval: TimeInterval = self.appDelegate.synapseTimeInterval
            DispatchQueue.global(qos: .background).async {
                synapseObject.checkSynapseDataSave(timeInterval: timeInterval)
            }
        }

        DispatchQueue.global(qos: .background).async {
            self.sendOSC(synapseValues: synapseObject.synapseValues)
        }
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

        self.nowValueLabel.text = ""
        self.maxValueLabel.text = ""
        self.minValueLabel.text = ""

        let key: String = self.synapseValues[self.focusSynapsePt]
        if key == self.synapseCrystalInfo.co2.key && self.synapseCrystalInfo.co2.hasGraph {
            if let value = synapseValuesMain.co2 {
                self.nowValueLabel.text = "\(String(value)) ppm"
            }
            if let maxNow = synapseDataMaxAndMins.co2.maxNow {
                self.maxValueLabel.text = "max:\(String(format:"%.0f", maxNow)) ppm"
            }
            if let minNow = synapseDataMaxAndMins.co2.minNow {
                self.minValueLabel.text = "min:\(String(format:"%.0f", minNow)) ppm"
            }
        }
        else if key == self.synapseCrystalInfo.temp.key && self.synapseCrystalInfo.temp.hasGraph {
            if let value = synapseValuesMain.temp {
                self.nowValueLabel.text = "\(String(format:"%.1f", value)) ℃"
                if self.appDelegate.temperatureScale == "F" {
                    self.nowValueLabel.text = "\(String(format:"%.1f", CommonFunction.makeFahrenheitTemperatureValue(value))) ℉"
                }
            }
            if let maxNow = synapseDataMaxAndMins.temp.maxNow {
                self.maxValueLabel.text = "max:\(String(format:"%.1f", maxNow)) ℃"
                if self.appDelegate.temperatureScale == "F" {
                    self.maxValueLabel.text = "max:\(String(format:"%.1f", CommonFunction.makeFahrenheitTemperatureValue(Float(maxNow)))) ℉"
                }
            }
            if let minNow = synapseDataMaxAndMins.temp.minNow {
                self.minValueLabel.text = "min:\(String(format:"%.1f", minNow)) ℃"
                if self.appDelegate.temperatureScale == "F" {
                    self.minValueLabel.text = "min:\(String(format:"%.1f", CommonFunction.makeFahrenheitTemperatureValue(Float(minNow)))) ℉"
                }
            }
        }
        else if key == self.synapseCrystalInfo.press.key && self.synapseCrystalInfo.press.hasGraph {
            if let value = synapseValuesMain.pressure {
                self.nowValueLabel.text = "\(String(format:"%.1f", value)) hPa"
            }
            if let maxNow = synapseDataMaxAndMins.press.maxNow {
                self.maxValueLabel.text = "max:\(String(format:"%.1f", maxNow)) hPa"
            }
            if let minNow = synapseDataMaxAndMins.press.minNow {
                self.minValueLabel.text = "min:\(String(format:"%.1f", minNow)) hPa"
            }
        }
        else if key == self.synapseCrystalInfo.ill.key && self.synapseCrystalInfo.ill.hasGraph {
            if let value = synapseValuesMain.light {
                self.nowValueLabel.text = "\(String(value)) lux"
            }
            if let maxNow = synapseDataMaxAndMins.light.maxNow {
                self.maxValueLabel.text = "max:\(String(format:"%.0f", maxNow)) lux"
            }
            if let minNow = synapseDataMaxAndMins.light.minNow {
                self.minValueLabel.text = "min:\(String(format:"%.0f", minNow)) lux"
            }
        }
        else if key == self.synapseCrystalInfo.hum.key && self.synapseCrystalInfo.hum.hasGraph {
            if let value = synapseValuesMain.humidity {
                self.nowValueLabel.text = "\(String(format:"%.1f", Float(value))) %"
            }
            if let maxNow = synapseDataMaxAndMins.hum.maxNow {
                self.maxValueLabel.text = "max:\(String(format:"%.1f", maxNow)) %"
            }
            if let minNow = synapseDataMaxAndMins.hum.minNow {
                self.minValueLabel.text = "min:\(String(format:"%.1f", minNow)) %"
            }
        }
        else if key == self.synapseCrystalInfo.sound.key && self.synapseCrystalInfo.sound.hasGraph {
            if let value = synapseValuesMain.sound {
                self.nowValueLabel.text = "\(String(value))"
                //self.nowValueLabel.text = "\(String(value)) dB"
            }
            if let maxNow = synapseDataMaxAndMins.sound.maxNow {
                self.maxValueLabel.text = "max:\(String(format:"%.0f", maxNow))"
                //self.maxValueLabel.text = "max:\(String(format:"%.0f", maxNow)) dB"
            }
            if let minNow = synapseDataMaxAndMins.sound.minNow {
                self.minValueLabel.text = "min:\(String(format:"%.0f", minNow))"
                //self.minValueLabel.text = "min:\(String(format:"%.0f", minNow)) dB"
            }
        }

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
            let alert: UIAlertController = UIAlertController(title: title, message: messageBody, preferredStyle: UIAlertControllerStyle.alert)
            let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {
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
        let bytes: [UInt8] = [UInt8](data)
        var restBytes: [UInt8]? = nil
        var cnt: Int = 0
        if synapseObject.receiveData.count > 2 {
            cnt = Int(synapseObject.receiveData[2])
        }
        else if bytes.count > 2 && Int(bytes[0]) == 0 && Int(bytes[1]) == 255 {
            cnt = Int(bytes[2])
        }
        if cnt >= minLength {
            for i in 0..<bytes.count {
                if synapseObject.receiveData.count < cnt {
                    synapseObject.receiveData.append(bytes[i])
                }
                else {
                    if restBytes == nil {
                        restBytes = []
                    }
                    restBytes?.append(bytes[i])
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
        restBytes = nil
        //print("receiveData: \(self.receiveData)")
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

        var timeInterval: String = ""
        if let str = self.settingFileManager.getSettingData(self.settingFileManager.synapseTimeIntervalKey) as? String {
            timeInterval = str
        }
        var isPlaySound: Bool = true
        if let flag = self.settingFileManager.getSettingData(self.settingFileManager.synapseSoundInfoKey) as? Bool {
            isPlaySound = flag
        }
        if self.settingFileManager.checkSynapseTimeIntervalUpdate(timeInterval, isPlaySound: isPlaySound) {
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
            self.appDelegate.synapseTimeInterval = self.getSynapseTimeInterval()
            var timeInt: Int = Int(self.appDelegate.synapseTimeInterval * 1000)
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

            var timeInterval: String = ""
            if let str = self.settingFileManager.getSettingData(self.settingFileManager.synapseTimeIntervalKey) as? String {
                timeInterval = str
            }
            if timeInterval == "Live" {
                data.append(0x01)
            }
            else if timeInterval == "Low Power" {
                data.append(0x02)
            }
            else {
                data.append(0x00)
            }

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
                self.appDelegate.synapseTimeIntervalBak = self.appDelegate.synapseTimeInterval
                print("receiveTimeIntervalToDevice OK: \(self.appDelegate.synapseTimeInterval)")
            }
            else {
                self.appDelegate.synapseTimeInterval = self.appDelegate.synapseTimeIntervalBak
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

        var timeInterval: String = ""
        if let str = self.settingFileManager.getSettingData(self.settingFileManager.synapseTimeIntervalKey) as? String {
            timeInterval = str
        }
        var isPlaySound: Bool = true
        if let flag = self.settingFileManager.getSettingData(self.settingFileManager.synapseSoundInfoKey) as? Bool {
            isPlaySound = flag
        }
        return self.settingFileManager.getSynapseTimeInterval(timeInterval, isBackground: !self.isSynapseAppActive, isPlaySound: isPlaySound)
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
            if let dic = self.settingFileManager.getSettingData(self.settingFileManager.synapseValidSensorsKey) as? [String: Bool], let flag = dic[self.synapseCrystalInfo.co2.key] {
                if !flag {
                    byte = 0x00
                }
            }
            data.append(byte)

            byte = 0x01
            if let dic = self.settingFileManager.getSettingData(self.settingFileManager.synapseValidSensorsKey) as? [String: Bool], let flag = dic[self.synapseCrystalInfo.temp.key] {
                if !flag {
                    byte = 0x00
                }
            }
            data.append(byte)

            byte = 0x01
            if let dic = self.settingFileManager.getSettingData(self.settingFileManager.synapseValidSensorsKey) as? [String: Bool], let flag = dic[self.synapseCrystalInfo.hum.key] {
                if !flag {
                    byte = 0x00
                }
            }
            data.append(byte)

            byte = 0x01
            if let dic = self.settingFileManager.getSettingData(self.settingFileManager.synapseValidSensorsKey) as? [String: Bool], let flag = dic[self.synapseCrystalInfo.ill.key] {
                if !flag {
                    byte = 0x00
                }
            }
            data.append(byte)

            byte = 0x01
            if let dic = self.settingFileManager.getSettingData(self.settingFileManager.synapseValidSensorsKey) as? [String: Bool], let flag = dic[self.synapseCrystalInfo.press.key] {
                if !flag {
                    byte = 0x00
                }
            }
            data.append(byte)

            byte = 0x01
            if let dic = self.settingFileManager.getSettingData(self.settingFileManager.synapseValidSensorsKey) as? [String: Bool], let flag = dic[self.synapseCrystalInfo.sound.key] {
                if !flag {
                    byte = 0x00
                }
            }
            data.append(byte)

            byte = 0x01
            if let dic = self.settingFileManager.getSettingData(self.settingFileManager.synapseValidSensorsKey) as? [String: Bool], let flag = dic[self.synapseCrystalInfo.move.key] {
                if !flag {
                    byte = 0x00
                }
            }
            data.append(byte)

            byte = 0x01
            if let dic = self.settingFileManager.getSettingData(self.settingFileManager.synapseValidSensorsKey) as? [String: Bool], let flag = dic[self.synapseCrystalInfo.angle.key] {
                if !flag {
                    byte = 0x00
                }
            }
            data.append(byte)

            byte = 0x01
            if let dic = self.settingFileManager.getSettingData(self.settingFileManager.synapseValidSensorsKey) as? [String: Bool], let flag = dic[self.synapseCrystalInfo.led.key] {
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
                let firmwareInfo: [String: Any] = [
                    "device_version": "\(versionVal1).\(versionVal2)",
                    "date": "\(dateVal1 + dateVal2 + dateVal3 + dateVal4)",
                ]
                print("receiveFirmwareVersionToDevice OK -> \(firmwareInfo)")

                var settingData: [String: Any] = [:]
                if let data = self.settingFileManager.getSettingData() {
                    settingData = data
                    settingData[self.settingFileManager.synapseFirmwareInfoKey] = firmwareInfo
                }
                else {
                    settingData = [self.settingFileManager.synapseFirmwareInfoKey: firmwareInfo]
                }
                _ = self.settingFileManager.setSettingData(settingData)
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

    func sendOSC(synapseValues: SynapseValues) {

        if let oscClient = self.appDelegate.oscClient, self.appDelegate.oscSendMode == "on" {
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
            /*
            if let mx = synapseValues.mx {
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
        if let oscClient = self.appDelegate.oscClient, self.appDelegate.oscSendMode == "on", name == self.mainSynapseObject.synapseValues.name {
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

        let message: F53OSCMessage = F53OSCMessage(addressPattern: addressPattern, arguments: arguments)
        client.send(message)
        //print("Send OSC: '\(String(describing: message))' To: \(client.host):\(client.port)")
    }

    func setOSCRecvMode() {

        if self.oscServer != nil {
            var oscRecvMode: String = ""
            var oscRecvPort: UInt16?
            if let settingData = self.settingFileManager.getSettingData() {
                if let mode = settingData[self.settingFileManager.oscRecvModeKey] as? String {
                    oscRecvMode = mode
                }
                if let port = settingData[self.settingFileManager.oscRecvPortKey] as? String, let portNum = UInt16(port) {
                    oscRecvPort = portNum
                }
            }

            if oscRecvMode != "on" {
                if let oscSynapseObject = self.oscSynapseObject, oscSynapseObject.synapseValues.isConnected {
                    oscSynapseObject.synapseValues.isConnected = false
                    oscSynapseObject.removeSynapseNode()

                    self.oscServer?.stopListening()
                    self.oscServer?.delegate = nil

                    self.resetCameraNodePosition()
                }
                self.oscSynapseObject = nil
            }
            else if oscRecvMode == "on" {
                if self.oscSynapseObject == nil {
                    self.oscSynapseObject = SynapseObject("osc")
                    self.oscSynapseObject?.rotateSynapseNodeDuration = self.updateSynapseViewTime
                    self.oscSynapseObject?.rotateCrystalNodeDuration = self.updateSynapseViewTime
                    self.oscSynapseObject?.scaleSynapseNodeDuration = self.updateSynapseViewTime
                    self.oscSynapseObject?.offColorTime = self.synapseOffColorTime
                    self.oscSynapseObject?.synapseValues.isConnected = false
                }
                if let oscSynapseObject = self.oscSynapseObject, !oscSynapseObject.synapseValues.isConnected {
                    print("Start OSCRecvMode")
                    self.oscSynapseObject?.synapseValues.isConnected = true
                    self.oscSynapseObject?.setSynapseNode(scnView: self.scnView, position: SCNVector3(x: 3.5, y: 0, z: 0))
                    self.oscSynapseObject?.setColorSynapseNode(colorLevel: 0)
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
                    oscSynapseObject.rotateSynapseNode()
                    oscSynapseObject.scaleSynapseNode()
                    oscSynapseObject.setColorSynapseNodeFromBatteryLevel()
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

    // MARK: mark - Notifications methods
    /*
    func setSynapseNotifications() {

        self.synapseNotifications.co2.value = nil
        var settingData: [String: Any] = [:]
        if let data = SettingFileManager().getSettingData() {
            settingData = data
        }
        if let notificationInfo = settingData["notification_info"] as? [String: Any] {
            if let co2Info = notificationInfo["co2"] as? [String: Any] {
                if let flag = co2Info["flag"] as? Bool {
                    if flag {
                        if let value = co2Info["value"] as? Int {
                            self.synapseNotifications.co2.value = Double(value)
                        }
                    }
                }
            }
        }
    }

    func checkSynapseNotifications(_ synapseValues: SynapseValues) {

        if let value = self.synapseNotifications.co2.value, let co2 = synapseValues.co2 {
            if co2 >= Int(value) {
                var isSend: Bool = false
                if let flag = self.synapseNotifications.co2.isSend {
                    isSend = flag
                }

                if !isSend {
                    print("CO2 value exceeded \(Int(value))")
                    self.sendSynapseNotification(notificationId: "co2Notification", body: "CO2 value exceeded \(Int(value))")
                }
                self.synapseNotifications.co2.isSend = true
            }
            else {
                if let flag = self.synapseNotifications.co2.isSend {
                    if flag {
                        print("CO2 value exceeded reset")
                    }
                }
                self.synapseNotifications.co2.isSend = false
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
    }*/

    // MARK: mark - DebugAreaView methods

    func setDebugButton() {

        let w: CGFloat = 44.0
        let h: CGFloat = 44.0
        let x: CGFloat = self.view.frame.size.width - (w + 10.0)
        let y: CGFloat = self.view.frame.size.height - (h + 10.0)
        self.debugAreaBtn = UIButton()
        self.debugAreaBtn.frame = CGRect(x: x, y: y, width: w, height: h)
        //self.debugAreaBtn.setTitle("Status", for: .normal)
        //self.debugAreaBtn.setTitleColor(UIColor.black, for: .normal)
        //self.debugAreaBtn.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 16)
        self.debugAreaBtn.backgroundColor = UIColor.clear
        self.debugAreaBtn.addTarget(self, action: #selector(self.setDebugAreaViewHiddenAction), for: .touchUpInside)
        self.view.addSubview(self.debugAreaBtn)

        let icon: UIImageView = UIImageView()
        icon.frame = CGRect(x: (self.debugAreaBtn.frame.size.width - 24.0) / 2, y: (self.debugAreaBtn.frame.size.height - 24.0) / 2, width: 24.0, height: 24.0)
        icon.image = UIImage(named: "status.png")
        icon.backgroundColor = UIColor.clear
        self.debugAreaBtn.addSubview(icon)

        self.debugView = DebugView()
    }

    func setDebugAreaView() {

        if let nav = self.navigationController as? NavigationController {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var w: CGFloat = nav.view.frame.width
            var h: CGFloat = nav.view.frame.height

            self.debugView.debugAreaView = UIView()
            self.debugView.debugAreaView?.frame = CGRect(x: x, y: y, width: w, height: h)
            self.debugView.debugAreaView?.backgroundColor = UIColor.black.withAlphaComponent(0.8)
            nav.view.addSubview(self.debugView.debugAreaView!)

            w = 44.0
            h = 44.0
            x = self.debugView.debugAreaView!.frame.size.width - w
            y = 20.0
            if #available(iOS 11.0, *) {
                y = self.view.safeAreaInsets.top
            }
            let closeButton: UIButton = UIButton()
            closeButton.tag = 2
            closeButton.frame = CGRect(x: x, y: y, width: w, height: h)
            closeButton.backgroundColor = UIColor.clear
            closeButton.addTarget(self, action: #selector(self.setDebugAreaViewHiddenAction), for: .touchUpInside)
            self.debugView.debugAreaView?.addSubview(closeButton)

            w = 18.0
            h = 18.0
            x = (closeButton.frame.size.width - w) / 2
            y = (closeButton.frame.size.height - h) / 2
            let closeIcon: CrossView = CrossView()
            closeIcon.frame = CGRect(x: x, y: y, width: w, height: h)
            closeIcon.backgroundColor = .clear
            closeIcon.isUserInteractionEnabled = false
            closeIcon.lineColor = UIColor.white
            closeButton.addSubview(closeIcon)

            x = 10.0
            y = closeButton.frame.origin.y + 44.0
            w = self.debugView.debugAreaView!.frame.size.width - x
            h = 50.0
            let titleLabel: UILabel = UILabel()
            titleLabel.frame = CGRect(x: x, y: y, width: w, height: h)
            titleLabel.text = "Status"
            titleLabel.textColor = UIColor.white
            titleLabel.backgroundColor = UIColor.clear
            titleLabel.font = UIFont(name: "HelveticaNeue", size: 24.0)
            titleLabel.textAlignment = NSTextAlignment.left
            titleLabel.numberOfLines = 1
            self.debugView.debugAreaView?.addSubview(titleLabel)

            x = 0
            y = titleLabel.frame.origin.y + titleLabel.frame.size.height + 10.0
            w = self.debugView.debugAreaView!.frame.size.width
            h = self.debugView.debugAreaView!.frame.size.height - y
            let mainScrollView: UIScrollView = UIScrollView()
            mainScrollView.frame = CGRect(x: x, y: y, width: w, height: h)
            mainScrollView.backgroundColor = UIColor.clear
            self.debugView.debugAreaView?.addSubview(mainScrollView)

            x = 10.0
            y = 0
            h = 24.0
            let label0: UILabel = UILabel()
            label0.text = "UUID:"
            label0.textColor = UIColor.white
            label0.backgroundColor = UIColor.clear
            label0.font = UIFont(name: "Migu 2M", size: 14)
            label0.textAlignment = NSTextAlignment.left
            label0.numberOfLines = 1
            label0.sizeToFit()
            label0.frame = CGRect(x: x, y: y, width: label0.frame.size.width, height: h)
            mainScrollView.addSubview(label0)

            x = label0.frame.origin.x + label0.frame.size.width + 10.0
            w = mainScrollView.frame.size.width - x
            self.debugView.data0Label = UILabel()
            self.debugView.data0Label?.text = ""
            self.debugView.data0Label?.frame = CGRect(x: x, y: y, width: w, height: h)
            self.debugView.data0Label?.textColor = UIColor.fluorescentPink
            self.debugView.data0Label?.backgroundColor = UIColor.clear
            self.debugView.data0Label?.font = UIFont(name: "Migu 2M", size: 14)
            self.debugView.data0Label?.textAlignment = NSTextAlignment.left
            self.debugView.data0Label?.numberOfLines = 1
            mainScrollView.addSubview(self.debugView.data0Label!)

            x = 10.0
            y += h
            let label1: UILabel = UILabel()
            label1.text = "Status:"
            label1.textColor = UIColor.white
            label1.backgroundColor = UIColor.clear
            label1.font = UIFont(name: "Migu 2M", size: 14)
            label1.textAlignment = NSTextAlignment.left
            label1.numberOfLines = 1
            label1.sizeToFit()
            label1.frame = CGRect(x: x, y: y, width: label1.frame.size.width, height: h)
            mainScrollView.addSubview(label1)

            x = label1.frame.origin.x + label1.frame.size.width + 10.0
            w = mainScrollView.frame.size.width - x
            self.debugView.data1Label = UILabel()
            self.debugView.data1Label?.text = ""
            self.debugView.data1Label?.frame = CGRect(x: x, y: y, width: w, height: h)
            self.debugView.data1Label?.textColor = UIColor.fluorescentPink
            self.debugView.data1Label?.backgroundColor = UIColor.clear
            self.debugView.data1Label?.font = UIFont(name: "Migu 2M", size: 14)
            self.debugView.data1Label?.textAlignment = NSTextAlignment.left
            self.debugView.data1Label?.numberOfLines = 1
            mainScrollView.addSubview(self.debugView.data1Label!)

            x = 10.0
            y += h
            let label2: UILabel = UILabel()
            label2.text = "Time:"
            label2.textColor = UIColor.white
            label2.backgroundColor = UIColor.clear
            label2.font = UIFont(name: "Migu 2M", size: 14)
            label2.textAlignment = NSTextAlignment.left
            label2.numberOfLines = 1
            label2.sizeToFit()
            label2.frame = CGRect(x: x, y: y, width: label2.frame.size.width, height: h)
            mainScrollView.addSubview(label2)

            x = label2.frame.origin.x + label2.frame.size.width + 10.0
            w = mainScrollView.frame.size.width - x
            self.debugView.data2Label = UILabel()
            self.debugView.data2Label?.text = ""
            self.debugView.data2Label?.frame = CGRect(x: x, y: y, width: w, height: h)
            self.debugView.data2Label?.textColor = UIColor.fluorescentPink
            self.debugView.data2Label?.backgroundColor = UIColor.clear
            self.debugView.data2Label?.font = UIFont(name: "Migu 2M", size: 14)
            self.debugView.data2Label?.textAlignment = NSTextAlignment.left
            self.debugView.data2Label?.numberOfLines = 1
            mainScrollView.addSubview(self.debugView.data2Label!)

            x = 10.0
            y += h
            let label3: UILabel = UILabel()
            label3.text = "CO2:"
            label3.textColor = UIColor.white
            label3.backgroundColor = UIColor.clear
            label3.font = UIFont(name: "Migu 2M", size: 14)
            label3.textAlignment = NSTextAlignment.left
            label3.numberOfLines = 1
            label3.sizeToFit()
            label3.frame = CGRect(x: x, y: y, width: label3.frame.size.width, height: h)
            mainScrollView.addSubview(label3)

            x = label3.frame.origin.x + label3.frame.size.width + 10.0
            w = mainScrollView.frame.size.width - x
            self.debugView.data3Label = UILabel()
            self.debugView.data3Label?.text = ""
            self.debugView.data3Label?.frame = CGRect(x: x, y: y, width: w, height: h)
            self.debugView.data3Label?.textColor = UIColor.fluorescentPink
            self.debugView.data3Label?.backgroundColor = UIColor.clear
            self.debugView.data3Label?.font = UIFont(name: "Migu 2M", size: 14)
            self.debugView.data3Label?.textAlignment = NSTextAlignment.left
            self.debugView.data3Label?.numberOfLines = 1
            mainScrollView.addSubview(self.debugView.data3Label!)

            x = 10.0
            y += h
            let label4: UILabel = UILabel()
            label4.text = "Accelerometer:"
            label4.textColor = UIColor.white
            label4.backgroundColor = UIColor.clear
            label4.font = UIFont(name: "Migu 2M", size: 14)
            label4.textAlignment = NSTextAlignment.left
            label4.numberOfLines = 1
            label4.sizeToFit()
            label4.frame = CGRect(x: x, y: y, width: label4.frame.size.width, height: h)
            mainScrollView.addSubview(label4)

            x = label4.frame.origin.x + label4.frame.size.width + 10.0
            w = mainScrollView.frame.size.width - x
            self.debugView.data4Label = UILabel()
            self.debugView.data4Label?.text = ""
            self.debugView.data4Label?.frame = CGRect(x: x, y: y, width: w, height: h)
            self.debugView.data4Label?.textColor = UIColor.fluorescentPink
            self.debugView.data4Label?.backgroundColor = UIColor.clear
            self.debugView.data4Label?.font = UIFont(name: "Migu 2M", size: 14)
            self.debugView.data4Label?.textAlignment = NSTextAlignment.left
            self.debugView.data4Label?.numberOfLines = 1
            mainScrollView.addSubview(self.debugView.data4Label!)

            x = 10.0
            y += h
            let label5: UILabel = UILabel()
            label5.text = "Light:"
            label5.textColor = UIColor.white
            label5.backgroundColor = UIColor.clear
            label5.font = UIFont(name: "Migu 2M", size: 14)
            label5.textAlignment = NSTextAlignment.left
            label5.numberOfLines = 1
            label5.sizeToFit()
            label5.frame = CGRect(x: x, y: y, width: label5.frame.size.width, height: h)
            mainScrollView.addSubview(label5)

            x = label5.frame.origin.x + label5.frame.size.width + 10.0
            w = mainScrollView.frame.size.width - x
            self.debugView.data5Label = UILabel()
            self.debugView.data5Label?.text = ""
            self.debugView.data5Label?.frame = CGRect(x: x, y: y, width: w, height: h)
            self.debugView.data5Label?.textColor = UIColor.fluorescentPink
            self.debugView.data5Label?.backgroundColor = UIColor.clear
            self.debugView.data5Label?.font = UIFont(name: "Migu 2M", size: 14)
            self.debugView.data5Label?.textAlignment = NSTextAlignment.left
            self.debugView.data5Label?.numberOfLines = 1
            mainScrollView.addSubview(self.debugView.data5Label!)

            x = 10.0
            y += h
            let label6: UILabel = UILabel()
            label6.text = "Gyro:"
            label6.textColor = UIColor.white
            label6.backgroundColor = UIColor.clear
            label6.font = UIFont(name: "Migu 2M", size: 14)
            label6.textAlignment = NSTextAlignment.left
            label6.numberOfLines = 1
            label6.sizeToFit()
            label6.frame = CGRect(x: x, y: y, width: label6.frame.size.width, height: h)
            mainScrollView.addSubview(label6)

            x = label6.frame.origin.x + label6.frame.size.width + 10.0
            w = mainScrollView.frame.size.width - x
            self.debugView.data6Label = UILabel()
            self.debugView.data6Label?.text = ""
            self.debugView.data6Label?.frame = CGRect(x: x, y: y, width: w, height: h)
            self.debugView.data6Label?.textColor = UIColor.fluorescentPink
            self.debugView.data6Label?.backgroundColor = UIColor.clear
            self.debugView.data6Label?.font = UIFont(name: "Migu 2M", size: 14)
            self.debugView.data6Label?.textAlignment = NSTextAlignment.left
            self.debugView.data6Label?.numberOfLines = 1
            mainScrollView.addSubview(self.debugView.data6Label!)

            x = 10.0
            y += h
            let label7: UILabel = UILabel()
            label7.text = "Pressure:"
            label7.textColor = UIColor.white
            label7.backgroundColor = UIColor.clear
            label7.font = UIFont(name: "Migu 2M", size: 14)
            label7.textAlignment = NSTextAlignment.left
            label7.numberOfLines = 1
            label7.sizeToFit()
            label7.frame = CGRect(x: x, y: y, width: label7.frame.size.width, height: h)
            mainScrollView.addSubview(label7)

            x = label7.frame.origin.x + label7.frame.size.width + 10.0
            w = mainScrollView.frame.size.width - x
            self.debugView.data7Label = UILabel()
            self.debugView.data7Label?.text = ""
            self.debugView.data7Label?.frame = CGRect(x: x, y: y, width: w, height: h)
            self.debugView.data7Label?.textColor = UIColor.fluorescentPink
            self.debugView.data7Label?.backgroundColor = UIColor.clear
            self.debugView.data7Label?.font = UIFont(name: "Migu 2M", size: 14)
            self.debugView.data7Label?.textAlignment = NSTextAlignment.left
            self.debugView.data7Label?.numberOfLines = 1
            mainScrollView.addSubview(self.debugView.data7Label!)

            x = 10.0
            y += h
            let label8: UILabel = UILabel()
            label8.text = "Temperature:"
            label8.textColor = UIColor.white
            label8.backgroundColor = UIColor.clear
            label8.font = UIFont(name: "Migu 2M", size: 14)
            label8.textAlignment = NSTextAlignment.left
            label8.numberOfLines = 1
            label8.sizeToFit()
            label8.frame = CGRect(x: x, y: y, width: label8.frame.size.width, height: h)
            mainScrollView.addSubview(label8)

            x = label8.frame.origin.x + label8.frame.size.width + 10.0
            w = mainScrollView.frame.size.width - x
            self.debugView.data8Label = UILabel()
            self.debugView.data8Label?.text = ""
            self.debugView.data8Label?.frame = CGRect(x: x, y: y, width: w, height: h)
            self.debugView.data8Label?.textColor = UIColor.fluorescentPink
            self.debugView.data8Label?.backgroundColor = UIColor.clear
            self.debugView.data8Label?.font = UIFont(name: "Migu 2M", size: 14)
            self.debugView.data8Label?.textAlignment = NSTextAlignment.left
            self.debugView.data8Label?.numberOfLines = 1
            mainScrollView.addSubview(self.debugView.data8Label!)

            x = 10.0
            y += h
            let label9: UILabel = UILabel()
            label9.text = "Humidity:"
            label9.textColor = UIColor.white
            label9.backgroundColor = UIColor.clear
            label9.font = UIFont(name: "Migu 2M", size: 14)
            label9.textAlignment = NSTextAlignment.left
            label9.numberOfLines = 1
            label9.sizeToFit()
            label9.frame = CGRect(x: x, y: y, width: label9.frame.size.width, height: h)
            mainScrollView.addSubview(label9)

            x = label9.frame.origin.x + label9.frame.size.width + 10.0
            w = mainScrollView.frame.size.width - x
            self.debugView.data9Label = UILabel()
            self.debugView.data9Label?.text = ""
            self.debugView.data9Label?.frame = CGRect(x: x, y: y, width: w, height: h)
            self.debugView.data9Label?.textColor = UIColor.fluorescentPink
            self.debugView.data9Label?.backgroundColor = UIColor.clear
            self.debugView.data9Label?.font = UIFont(name: "Migu 2M", size: 14)
            self.debugView.data9Label?.textAlignment = NSTextAlignment.left
            self.debugView.data9Label?.numberOfLines = 1
            mainScrollView.addSubview(self.debugView.data9Label!)

            x = 10.0
            y += h
            let label10: UILabel = UILabel()
            label10.text = "Environmental sound:"
            label10.textColor = UIColor.white
            label10.backgroundColor = UIColor.clear
            label10.font = UIFont(name: "Migu 2M", size: 14)
            label10.textAlignment = NSTextAlignment.left
            label10.numberOfLines = 1
            label10.sizeToFit()
            label10.frame = CGRect(x: x, y: y, width: label10.frame.size.width, height: h)
            mainScrollView.addSubview(label10)

            x = label10.frame.origin.x + label10.frame.size.width + 10.0
            w = mainScrollView.frame.size.width - x
            self.debugView.data10Label = UILabel()
            self.debugView.data10Label?.text = ""
            self.debugView.data10Label?.frame = CGRect(x: x, y: y, width: w, height: h)
            self.debugView.data10Label?.textColor = UIColor.fluorescentPink
            self.debugView.data10Label?.backgroundColor = UIColor.clear
            self.debugView.data10Label?.font = UIFont(name: "Migu 2M", size: 14)
            self.debugView.data10Label?.textAlignment = NSTextAlignment.left
            self.debugView.data10Label?.numberOfLines = 1
            mainScrollView.addSubview(self.debugView.data10Label!)

            x = 10.0
            y += h
            let label11: UILabel = UILabel()
            label11.text = "tVOC:"
            label11.textColor = UIColor.white
            label11.backgroundColor = UIColor.clear
            label11.font = UIFont(name: "Migu 2M", size: 14)
            label11.textAlignment = NSTextAlignment.left
            label11.numberOfLines = 1
            label11.sizeToFit()
            label11.frame = CGRect(x: x, y: y, width: label11.frame.size.width, height: h)
            mainScrollView.addSubview(label11)

            x = label11.frame.origin.x + label11.frame.size.width + 10.0
            w = mainScrollView.frame.size.width - x
            self.debugView.data11Label = UILabel()
            self.debugView.data11Label?.text = ""
            self.debugView.data11Label?.frame = CGRect(x: x, y: y, width: w, height: h)
            self.debugView.data11Label?.textColor = UIColor.fluorescentPink
            self.debugView.data11Label?.backgroundColor = UIColor.clear
            self.debugView.data11Label?.font = UIFont(name: "Migu 2M", size: 14)
            self.debugView.data11Label?.textAlignment = NSTextAlignment.left
            self.debugView.data11Label?.numberOfLines = 1
            mainScrollView.addSubview(self.debugView.data11Label!)

            x = 10.0
            y += h
            let label12: UILabel = UILabel()
            label12.text = "Volt:"
            label12.textColor = UIColor.white
            label12.backgroundColor = UIColor.clear
            label12.font = UIFont(name: "Migu 2M", size: 14)
            label12.textAlignment = NSTextAlignment.left
            label12.numberOfLines = 1
            label12.sizeToFit()
            label12.frame = CGRect(x: x, y: y, width: label12.frame.size.width, height: h)
            mainScrollView.addSubview(label12)

            x = label12.frame.origin.x + label12.frame.size.width + 10.0
            w = mainScrollView.frame.size.width - x
            self.debugView.data12Label = UILabel()
            self.debugView.data12Label?.text = ""
            self.debugView.data12Label?.frame = CGRect(x: x, y: y, width: w, height: h)
            self.debugView.data12Label?.textColor = UIColor.fluorescentPink
            self.debugView.data12Label?.backgroundColor = UIColor.clear
            self.debugView.data12Label?.font = UIFont(name: "Migu 2M", size: 14)
            self.debugView.data12Label?.textAlignment = NSTextAlignment.left
            self.debugView.data12Label?.numberOfLines = 1
            mainScrollView.addSubview(self.debugView.data12Label!)

            x = 10.0
            y += h
            let label13: UILabel = UILabel()
            label13.text = "Pow:"
            label13.textColor = UIColor.white
            label13.backgroundColor = UIColor.clear
            label13.font = UIFont(name: "Migu 2M", size: 14)
            label13.textAlignment = NSTextAlignment.left
            label13.numberOfLines = 1
            label13.sizeToFit()
            label13.frame = CGRect(x: x, y: y, width: label13.frame.size.width, height: h)
            mainScrollView.addSubview(label13)

            x = label13.frame.origin.x + label13.frame.size.width + 10.0
            w = mainScrollView.frame.size.width - x
            self.debugView.data13Label = UILabel()
            self.debugView.data13Label?.text = ""
            self.debugView.data13Label?.frame = CGRect(x: x, y: y, width: w, height: h)
            self.debugView.data13Label?.textColor = UIColor.fluorescentPink
            self.debugView.data13Label?.backgroundColor = UIColor.clear
            self.debugView.data13Label?.font = UIFont(name: "Migu 2M", size: 14)
            self.debugView.data13Label?.textAlignment = NSTextAlignment.left
            self.debugView.data13Label?.numberOfLines = 1
            mainScrollView.addSubview(self.debugView.data13Label!)

            x = 10.0
            y += h
            let label14: UILabel = UILabel()
            label14.text = "OSC Send Mode:"
            label14.textColor = UIColor.white
            label14.backgroundColor = UIColor.clear
            label14.font = UIFont(name: "Migu 2M", size: 14)
            label14.textAlignment = NSTextAlignment.left
            label14.numberOfLines = 1
            label14.sizeToFit()
            label14.frame = CGRect(x: x, y: y, width: label14.frame.size.width, height: h)
            mainScrollView.addSubview(label14)

            x = label14.frame.origin.x + label14.frame.size.width + 10.0
            w = mainScrollView.frame.size.width - x
            self.debugView.data14Label = UILabel()
            self.debugView.data14Label?.text = ""
            self.debugView.data14Label?.frame = CGRect(x: x, y: y, width: w, height: h)
            self.debugView.data14Label?.textColor = UIColor.fluorescentPink
            self.debugView.data14Label?.backgroundColor = UIColor.clear
            self.debugView.data14Label?.font = UIFont(name: "Migu 2M", size: 14)
            self.debugView.data14Label?.textAlignment = NSTextAlignment.left
            self.debugView.data14Label?.numberOfLines = 1
            mainScrollView.addSubview(self.debugView.data14Label!)

            x = 10.0
            y += h
            let label15: UILabel = UILabel()
            label15.text = "Address/Port:"
            label15.textColor = UIColor.white
            label15.backgroundColor = UIColor.clear
            label15.font = UIFont(name: "Migu 2M", size: 14)
            label15.textAlignment = NSTextAlignment.left
            label15.numberOfLines = 1
            label15.sizeToFit()
            label15.frame = CGRect(x: x, y: y, width: label15.frame.size.width, height: h)
            mainScrollView.addSubview(label15)

            x = label15.frame.origin.x + label15.frame.size.width + 10.0
            w = mainScrollView.frame.size.width - x
            self.debugView.data15Label = UILabel()
            self.debugView.data15Label?.text = ""
            self.debugView.data15Label?.frame = CGRect(x: x, y: y, width: w, height: h)
            self.debugView.data15Label?.textColor = UIColor.fluorescentPink
            self.debugView.data15Label?.backgroundColor = UIColor.clear
            self.debugView.data15Label?.font = UIFont(name: "Migu 2M", size: 14)
            self.debugView.data15Label?.textAlignment = NSTextAlignment.left
            self.debugView.data15Label?.numberOfLines = 1
            mainScrollView.addSubview(self.debugView.data15Label!)

            if self.oscServer != nil {
                x = 10.0
                y += h
                let label16: UILabel = UILabel()
                label16.text = "OSC Recv Mode:"
                label16.textColor = UIColor.white
                label16.backgroundColor = UIColor.clear
                label16.font = UIFont(name: "Migu 2M", size: 14)
                label16.textAlignment = NSTextAlignment.left
                label16.numberOfLines = 1
                label16.sizeToFit()
                label16.frame = CGRect(x: x, y: y, width: label16.frame.size.width, height: h)
                mainScrollView.addSubview(label16)

                x = label16.frame.origin.x + label16.frame.size.width + 10.0
                w = mainScrollView.frame.size.width - x
                self.debugView.data16Label = UILabel()
                self.debugView.data16Label?.text = ""
                self.debugView.data16Label?.frame = CGRect(x: x, y: y, width: w, height: h)
                self.debugView.data16Label?.textColor = UIColor.fluorescentPink
                self.debugView.data16Label?.backgroundColor = UIColor.clear
                self.debugView.data16Label?.font = UIFont(name: "Migu 2M", size: 14)
                self.debugView.data16Label?.textAlignment = NSTextAlignment.left
                self.debugView.data16Label?.numberOfLines = 1
                mainScrollView.addSubview(self.debugView.data16Label!)

                x = 10.0
                y += h
                let label17: UILabel = UILabel()
                label17.text = "Port:"
                label17.textColor = UIColor.white
                label17.backgroundColor = UIColor.clear
                label17.font = UIFont(name: "Migu 2M", size: 14)
                label17.textAlignment = NSTextAlignment.left
                label17.numberOfLines = 1
                label17.sizeToFit()
                label17.frame = CGRect(x: x, y: y, width: label17.frame.size.width, height: h)
                mainScrollView.addSubview(label17)

                x = label17.frame.origin.x + label17.frame.size.width + 10.0
                w = mainScrollView.frame.size.width - x
                self.debugView.data17Label = UILabel()
                self.debugView.data17Label?.text = ""
                self.debugView.data17Label?.frame = CGRect(x: x, y: y, width: w, height: h)
                self.debugView.data17Label?.textColor = UIColor.fluorescentPink
                self.debugView.data17Label?.backgroundColor = UIColor.clear
                self.debugView.data17Label?.font = UIFont(name: "Migu 2M", size: 14)
                self.debugView.data17Label?.textAlignment = NSTextAlignment.left
                self.debugView.data17Label?.numberOfLines = 1
                mainScrollView.addSubview(self.debugView.data17Label!)
            }

            y += h + 10.0
            mainScrollView.contentSize = CGSize(width: mainScrollView.frame.width, height: y)
        }
    }

    @objc func setDebugAreaViewHiddenAction() {

        if self.debugView.debugAreaView == nil {
            self.setDebugAreaView()
            self.updateDebugAreaView(synapseObject: self.mainSynapseObject)
        }
        else {
            self.debugView.debugAreaView?.removeFromSuperview()
            self.debugView.debugAreaView = nil
        }
    }

    func updateDebugAreaView(synapseObject: SynapseObject) {

        if let debugAreaView = self.debugView.debugAreaView {
            if !debugAreaView.isHidden {
                /*
                var synapseValues: SynapseValues = self.synapseValuesMain
                if self.synapseValuesOSC.isConnected {
                    synapseValues = self.synapseValuesOSC
                }*/

                var data0str: String = ""
                var data1str: String = ""
                var data2str: String = ""
                var data3str: String = ""
                var data4str: String = ""
                var data5str: String = ""
                var data6str: String = ""
                var data7str: String = ""
                var data8str: String = ""
                var data9str: String = ""
                var data10str: String = ""
                var data11str: String = ""
                var data12str: String = ""
                var data13str: String = ""

                if let uuid = synapseObject.synapseUUID {
                    data0str = uuid.uuidString
                }
                data1str = synapseObject.getDeviceStatus()
                if let time = synapseObject.synapseValues.time {
                    let formatter = DateFormatter()
                    formatter.locale = Locale(identifier: "en_US_POSIX")
                    formatter.dateFormat = "yyyy/MM/dd HH:mm:ss.SSS"
                    data2str = formatter.string(from: Date(timeIntervalSince1970: time))
                }
                if let co2 = synapseObject.synapseValues.co2 {
                    data3str = "\(String(co2))"
                }
                if let ax = synapseObject.synapseValues.ax, let ay = synapseObject.synapseValues.ay, let az = synapseObject.synapseValues.az {
                    data4str = "\(String(format:"%.4f", Float(ax) * self.aScale))/\(String(format:"%.4f", Float(ay) * self.aScale))/\(String(format:"%.4f", Float(az) * self.aScale))"
                }
                /*if let ax = synapseValues.ax, let ay = synapseValues.ay, let az = synapseValues.az {
                    let radx: Double = atan(Double(ax) / sqrt(pow(Double(ay), 2) + pow(Double(az), 2)))
                    let rady: Double = atan(Double(ay) / sqrt(pow(Double(ax), 2) + pow(Double(az), 2)))
                    let radz: Double = atan(Double(az) / sqrt(pow(Double(ay), 2) + pow(Double(ax), 2)))
                    data4str = "\(String(format:"%.2f", radx * 180.0 / Double.pi))/\(String(format:"%.2f", rady * 180.0 / Double.pi))/\(String(format:"%.2f", radz * 180.0 / Double.pi))"
                    //data4str = "\(String(ax)) | \(String(ay)) | \(String(az))"
                }*/
                if let light = synapseObject.synapseValues.light {
                    data5str = "\(String(light))"
                }
                if let gx = synapseObject.synapseValues.gx, let gy = synapseObject.synapseValues.gy, let gz = synapseObject.synapseValues.gz {
                    data6str = "\(String(format:"%.4f", Float(gx) * self.gScale * Float(Double.pi / 180.0)))/\(String(format:"%.4f", Float(gy) * self.gScale * Float(Double.pi / 180.0)))/\(String(format:"%.4f", Float(gz) * self.gScale * Float(Double.pi / 180.0)))"
                }
                if let pressure = synapseObject.synapseValues.pressure {
                    data7str = "\(String(pressure))"
                }
                if let temp = synapseObject.synapseValues.temp {
                    var tempVal: Float = temp
                    if self.appDelegate.temperatureScale == "F" {
                        tempVal = CommonFunction.makeFahrenheitTemperatureValue(tempVal)
                    }
                    data8str = "\(String(tempVal))"
                }
                if let humidity = synapseObject.synapseValues.humidity {
                    data9str = "\(String(humidity))"
                }
                if let sound = synapseObject.synapseValues.sound {
                    data10str = "\(String(sound))"
                }
                if let tvoc = synapseObject.synapseValues.tvoc {
                    data11str = "\(String(tvoc))"
                }
                if let power = synapseObject.synapseValues.power {
                    data12str = "\(String(power))"
                }
                if let battery = synapseObject.synapseValues.battery {
                    data13str = "\(String(battery))"
                }
                /*if let mx = synapseValues.mx, let my = synapseValues.my, let mz = synapseValues.mz {
                    data6str = "\(String(mx))/\(String(my))/\(String(mz))"
                }*/
                self.debugView.data0Label?.text = data0str
                self.debugView.data1Label?.text = data1str
                self.debugView.data2Label?.text = data2str
                self.debugView.data3Label?.text = data3str
                self.debugView.data4Label?.text = data4str
                self.debugView.data5Label?.text = data5str
                self.debugView.data6Label?.text = data6str
                self.debugView.data7Label?.text = data7str
                self.debugView.data8Label?.text = data8str
                self.debugView.data9Label?.text = data9str
                self.debugView.data10Label?.text = data10str
                self.debugView.data11Label?.text = data11str
                self.debugView.data12Label?.text = data12str
                self.debugView.data13Label?.text = data13str

                self.debugView.data14Label?.text = "\(self.appDelegate.oscSendMode)"
                var str: String = ""
                if let oscIPAddress = SettingFileManager().getSettingData(SettingFileManager().oscSendIPAddressKey) as? String {
                    str += oscIPAddress
                }
                if let oscPort = SettingFileManager().getSettingData(SettingFileManager().oscSendPortKey) as? String {
                    str += "/\(oscPort)"
                }
                self.debugView.data15Label?.text = str

                if self.oscServer != nil {
                    if let settingData = self.settingFileManager.getSettingData() {
                        self.debugView.data16Label?.text = ""
                        if let mode = settingData[self.settingFileManager.oscRecvModeKey] as? String {
                            self.debugView.data16Label?.text = "\(mode)"
                        }
                        self.debugView.data17Label?.text = ""
                        if let port = settingData[self.settingFileManager.oscRecvPortKey] as? String {
                            self.debugView.data17Label?.text = "\(port)"
                        }
                    }
                }
            }
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
                /*var flag: Bool = true
                if let soundInfo = self.settingFileManager.getSettingData(self.settingFileManager.synapseSoundInfoKey) as? Bool {
                    flag = soundInfo
                }
                if flag {
                    if let timeInterval = self.settingFileManager.getSettingData(self.settingFileManager.synapseTimeIntervalKey) as? String {
                        flag = self.settingFileManager.checkPlayableSound(timeInterval)
                    }
                }

                if flag {
                    self.playAudio()
                }*/
            }
            else if !play && synapseSound.isPlaying {
                self.stopAudio()
            }
        }
    }

    func checkEnableAudio() -> Bool {

        var flag: Bool = true
        if let soundInfo = self.settingFileManager.getSettingData(self.settingFileManager.synapseSoundInfoKey) as? Bool {
            flag = soundInfo
        }
        if flag {
            if let timeInterval = self.settingFileManager.getSettingData(self.settingFileManager.synapseTimeIntervalKey) as? String {
                flag = self.settingFileManager.checkPlayableSound(timeInterval)
            }
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

            self.synapseSoundTimer = Timer.scheduledTimer(timeInterval: synapseSound.getRoopTime(), target: self, selector: #selector(self.checkAudio), userInfo: nil, repeats: true)
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
}

class SynapseObject {

    // const
    let synapseCrystalInfo: SynapseCrystalStruct = SynapseCrystalStruct()
    let crystalGeometries: CrystalGeometries = CrystalGeometries()
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
    var rotateSynapseNodeDuration: TimeInterval = 0
    var rotateCrystalNodeDuration: TimeInterval = 0
    var scaleSynapseNodeDuration: TimeInterval = 0
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

        self.setColorSynapseNode(colorLevel: 0)

        if let synapseRecordFileManager = self.synapseRecordFileManager {
            _ = synapseRecordFileManager.setConnectLog("S")
        }
    }

    func disconnectSynapse() {

        //print("disconnectSynapse")
        if self.synapseValues.isConnected {
            if let synapseRecordFileManager = self.synapseRecordFileManager {
                _ = synapseRecordFileManager.setConnectLog("E")
            }
        }
        self.synapse = nil
        self.synapseValues.resetValues()
        self.synapseValuesBak = nil
        self.synapseData = []
        self.synapseValues.isConnected = false
        self.setColorOffSynapseNode()
        self.scaleSynapseNode()

        self.synapseRecordFileManager = nil
        if let uuid = self.synapseUUID {
            self.setSynapseUUID(uuid)
        }
    }

    // MARK: mark - CrystalNode methods

    func setSynapseNode(scnView: SCNView, position: SCNVector3?) {

        if let position = position {
            self.synapseCrystalNode.position = position
        }

        self.synapseCrystalNode.mainNodeRoll = SCNNode()
        self.synapseCrystalNode.mainNodeRoll?.position = self.synapseCrystalNode.position
        scnView.scene?.rootNode.addChildNode(synapseCrystalNode.mainNodeRoll!)

        self.synapseCrystalNode.mainNode = SCNNode()
        self.synapseCrystalNode.mainNode?.position = SCNVector3(x: 0, y: 0, z: 0)
        self.synapseCrystalNode.mainNodeRoll?.addChildNode(self.synapseCrystalNode.mainNode!)

        self.synapseCrystalNode.mainXNode = SCNNode()
        self.synapseCrystalNode.mainXNode?.position = SCNVector3(x: 0, y: 0, z: 0)
        self.synapseCrystalNode.mainNode?.addChildNode(self.synapseCrystalNode.mainXNode!)

        self.synapseCrystalNode.mainYNode = SCNNode()
        self.synapseCrystalNode.mainYNode?.position = SCNVector3(x: 0, y: 0, z: 0)
        self.synapseCrystalNode.mainXNode?.addChildNode(self.synapseCrystalNode.mainYNode!)

        self.synapseCrystalNode.mainZNode = SCNNode()
        self.synapseCrystalNode.mainZNode?.position = SCNVector3(x: 0, y: 0, z: 0)
        self.synapseCrystalNode.mainYNode?.addChildNode(self.synapseCrystalNode.mainZNode!)

        self.synapseCrystalNode.co2Node = SCNNode()
        self.synapseCrystalNode.co2Node?.geometry = self.crystalGeometries.makeCO2CrystalGeometry(1.0)
        self.synapseCrystalNode.co2Node?.position = SCNVector3(x: -0.4, y: 0.6, z: 0.7)
        self.synapseCrystalNode.co2Node?.rotation = SCNVector4(x: 0, y: 1.0, z: 0.8, w: Float(Double.pi / 180.0) * 70.0)
        self.synapseCrystalNode.co2Node?.geometry?.materials = self.crystalGeometries.setCrystalGeometryColor(0.5)
        self.synapseCrystalNode.mainZNode?.addChildNode(self.synapseCrystalNode.co2Node!)
        self.synapseCrystalNode.co2Node?.name = self.synapseCrystalInfo.co2.key
        if let name = self.synapseCrystalNode.name {
            self.synapseCrystalNode.co2Node?.name = "\(name)_\(self.synapseCrystalInfo.co2.key)"
        }
        /*
         self.co2BaseNode = SCNNode()
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
         self.co2CrystalNode.bottomNode.name = self.synapseCrystalInfo.co2.key
         */
        self.synapseCrystalNode.tempNode = SCNNode()
        self.synapseCrystalNode.tempNode?.geometry = self.crystalGeometries.makeTemperatureCrystalGeometry(1.0)
        self.synapseCrystalNode.tempNode?.position = SCNVector3(x: 0.4, y: 0, z: 0.7)
        self.synapseCrystalNode.tempNode?.rotation = SCNVector4(x: -0.3, y: -0.5, z: -1.0, w: Float(Double.pi / 180.0) * 120.0)
        self.synapseCrystalNode.tempNode?.geometry?.materials = self.crystalGeometries.setCrystalGeometryColor(0.5)
        self.synapseCrystalNode.mainZNode?.addChildNode(self.synapseCrystalNode.tempNode!)
        self.synapseCrystalNode.tempNode?.name = self.synapseCrystalInfo.temp.key
        if let name = self.synapseCrystalNode.name {
            self.synapseCrystalNode.tempNode?.name = "\(name)_\(self.synapseCrystalInfo.temp.key)"
        }

        self.synapseCrystalNode.humidityNode = SCNNode()
        self.synapseCrystalNode.humidityNode?.geometry = self.crystalGeometries.makeHumidityCrystalGeometry(1.0)
        self.synapseCrystalNode.humidityNode?.position = SCNVector3(x: -0.4, y: -0.45, z: 0.7)
        self.synapseCrystalNode.humidityNode?.rotation = SCNVector4(x: -0.5, y: 0, z: 1.0, w: Float(Double.pi / 180.0) * 150.0)
        self.synapseCrystalNode.humidityNode?.geometry?.materials = self.crystalGeometries.setCrystalGeometryColor(0.5)
        self.synapseCrystalNode.mainZNode?.addChildNode(self.synapseCrystalNode.humidityNode!)
        self.synapseCrystalNode.humidityNode?.name = self.synapseCrystalInfo.hum.key
        if let name = self.synapseCrystalNode.name {
            self.synapseCrystalNode.humidityNode?.name = "\(name)_\(self.synapseCrystalInfo.hum.key)"
        }

        self.synapseCrystalNode.pressureNode = SCNNode()
        self.synapseCrystalNode.pressureNode?.geometry = self.crystalGeometries.makePressureCrystalGeometry(3.0)
        self.synapseCrystalNode.pressureNode?.position = SCNVector3(x: 0, y: 0, z: -0.45)
        self.synapseCrystalNode.pressureNode?.rotation = SCNVector4(x: -0.4, y: -0.8, z: -1.0, w: Float(Double.pi / 180.0) * 90.0)
        self.synapseCrystalNode.pressureNode?.geometry?.materials = self.crystalGeometries.setCrystalGeometryColor(0.5)
        self.synapseCrystalNode.mainZNode?.addChildNode(self.synapseCrystalNode.pressureNode!)
        self.synapseCrystalNode.pressureNode?.name = self.synapseCrystalInfo.press.key
        if let name = self.synapseCrystalNode.name {
            self.synapseCrystalNode.pressureNode?.name = "\(name)_\(self.synapseCrystalInfo.press.key)"
        }

        self.synapseCrystalNode.light1Node = SCNNode()
        self.synapseCrystalNode.light1Node?.geometry = self.crystalGeometries.makeIlluminationCrystalGeometry(3.0)
        self.synapseCrystalNode.light1Node?.position = SCNVector3(x: 0, y: 0, z: 0.2)
        self.synapseCrystalNode.light1Node?.rotation = SCNVector4(x: 0, y: 0, z: 1.0, w: Float(Double.pi / 180.0) * 20.0)
        self.synapseCrystalNode.light1Node?.geometry?.materials = self.crystalGeometries.setCrystalGeometryColor(0.5)
        self.synapseCrystalNode.mainZNode?.addChildNode(self.synapseCrystalNode.light1Node!)
        self.synapseCrystalNode.light1Node?.name = self.synapseCrystalInfo.ill.key
        if let name = self.synapseCrystalNode.name {
            self.synapseCrystalNode.light1Node?.name = "\(name)_\(self.synapseCrystalInfo.ill.key)"
        }

        self.synapseCrystalNode.light2Node = SCNNode()
        self.synapseCrystalNode.light2Node?.geometry = self.crystalGeometries.makeIlluminationCrystalGeometry(3.0)
        self.synapseCrystalNode.light2Node?.position = SCNVector3(x: 0, y: 0, z: 0)
        self.synapseCrystalNode.light2Node?.rotation = SCNVector4(x: 0, y: 0, z: 1.0, w: Float(Double.pi / 180.0) * 46.0)
        self.synapseCrystalNode.light2Node?.geometry?.materials = self.crystalGeometries.setCrystalGeometryColor(0.5)
        self.synapseCrystalNode.mainZNode?.addChildNode(self.synapseCrystalNode.light2Node!)
        self.synapseCrystalNode.light2Node?.name = self.synapseCrystalInfo.ill.key
        if let name = self.synapseCrystalNode.name {
            self.synapseCrystalNode.light2Node?.name = "\(name)_\(self.synapseCrystalInfo.ill.key)"
        }

        self.synapseCrystalNode.light3Node = SCNNode()
        self.synapseCrystalNode.light3Node?.geometry = self.crystalGeometries.makeIlluminationCrystalGeometry(3.0)
        self.synapseCrystalNode.light3Node?.position = SCNVector3(x: 0, y: 0, z: 0.4)
        self.synapseCrystalNode.light3Node?.rotation = SCNVector4(x: 0, y: 0, z: 1.0, w: Float(Double.pi / 180.0) * 150.0)
        self.synapseCrystalNode.light3Node?.geometry?.materials = self.crystalGeometries.setCrystalGeometryColor(0.5)
        self.synapseCrystalNode.mainZNode?.addChildNode(self.synapseCrystalNode.light3Node!)
        self.synapseCrystalNode.light3Node?.name = self.synapseCrystalInfo.ill.key
        if let name = self.synapseCrystalNode.name {
            self.synapseCrystalNode.light3Node?.name = "\(name)_\(self.synapseCrystalInfo.ill.key)"
        }

        self.synapseCrystalNode.soundNode = SCNNode()
        self.synapseCrystalNode.soundNode?.geometry = self.crystalGeometries.makeMagneticCrystalGeometry(w: 3.0, h: 2.0)
        self.synapseCrystalNode.soundNode?.position = SCNVector3(x: 0.1, y: -0.1, z: -0.8)
        self.synapseCrystalNode.soundNode?.rotation = SCNVector4(x: 0, y: 0, z: -1.0, w: Float(Double.pi / 180.0) * 90.0)
        self.synapseCrystalNode.soundNode?.geometry?.materials = self.crystalGeometries.setCrystalGeometryColor(0.5)
        self.synapseCrystalNode.mainZNode?.addChildNode(self.synapseCrystalNode.soundNode!)
        self.synapseCrystalNode.soundNode?.name = self.synapseCrystalInfo.sound.key
        if let name = self.synapseCrystalNode.name {
            self.synapseCrystalNode.soundNode?.name = "\(name)_\(self.synapseCrystalInfo.sound.key)"
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
        scnView.scene?.rootNode.addChildNode(self.labelNode)*/

        self.synapseCrystalNode.lightingNode = SCNNode()
        self.synapseCrystalNode.lightingNode?.light = SCNLight()
        self.synapseCrystalNode.lightingNode?.light?.type = .omni
        self.synapseCrystalNode.lightingNode?.light?.color = UIColor.white
        self.synapseCrystalNode.lightingNode?.position = SCNVector3(x: -2.0 + self.synapseCrystalNode.position.x, y: 0 + self.synapseCrystalNode.position.y, z: 7.0 + self.synapseCrystalNode.position.z)
        self.synapseCrystalNode.lightingNode?.rotation = SCNVector4(x: 0, y: 1.0, z: 0, w: Float(Double.pi / 180.0) * -20.0)
        scnView.scene?.rootNode.addChildNode(self.synapseCrystalNode.lightingNode!)

        self.synapseCrystalNode.lightingNode2 = SCNNode()
        self.synapseCrystalNode.lightingNode2?.light = SCNLight()
        self.synapseCrystalNode.lightingNode2?.light?.type = .spot
        self.synapseCrystalNode.lightingNode2?.light?.color = UIColor.white
        self.synapseCrystalNode.lightingNode2?.position = SCNVector3(x: 0 + self.synapseCrystalNode.position.x, y: 10.0 + self.synapseCrystalNode.position.y, z: 0 + self.synapseCrystalNode.position.z)
        self.synapseCrystalNode.lightingNode2?.rotation = SCNVector4(x: 1.0, y: 0, z: 0, w: Float(Double.pi / 180.0) * -90.0)
        scnView.scene?.rootNode.addChildNode(self.synapseCrystalNode.lightingNode2!)
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

    func removeSynapseNode() {

        self.synapseCrystalNode.mainNodeRoll?.removeFromParentNode()
        self.synapseCrystalNode.mainNodeRoll = nil
        self.synapseCrystalNode.mainNode?.removeFromParentNode()
        self.synapseCrystalNode.mainNode = nil
        self.synapseCrystalNode.mainXNode?.removeFromParentNode()
        self.synapseCrystalNode.mainXNode = nil
        self.synapseCrystalNode.mainYNode?.removeFromParentNode()
        self.synapseCrystalNode.mainYNode = nil
        self.synapseCrystalNode.mainZNode?.removeFromParentNode()
        self.synapseCrystalNode.mainZNode = nil
        self.synapseCrystalNode.co2Node?.removeFromParentNode()
        self.synapseCrystalNode.co2Node = nil
        self.synapseCrystalNode.tempNode?.removeFromParentNode()
        self.synapseCrystalNode.tempNode = nil
        self.synapseCrystalNode.humidityNode?.removeFromParentNode()
        self.synapseCrystalNode.humidityNode = nil
        self.synapseCrystalNode.pressureNode?.removeFromParentNode()
        self.synapseCrystalNode.pressureNode = nil
        self.synapseCrystalNode.light1Node?.removeFromParentNode()
        self.synapseCrystalNode.light1Node = nil
        self.synapseCrystalNode.light2Node?.removeFromParentNode()
        self.synapseCrystalNode.light2Node = nil
        self.synapseCrystalNode.light3Node?.removeFromParentNode()
        self.synapseCrystalNode.light3Node = nil
        self.synapseCrystalNode.soundNode?.removeFromParentNode()
        self.synapseCrystalNode.soundNode = nil
        /*synapseCrystalNode.magneticXNode?.removeFromParentNode()
         synapseCrystalNode.magneticXNode = nil
         synapseCrystalNode.magneticYNode?.removeFromParentNode()
         synapseCrystalNode.magneticYNode = nil
         synapseCrystalNode.magneticZNode?.removeFromParentNode()
         synapseCrystalNode.magneticZNode = nil*/
        self.synapseCrystalNode.lightingNode?.removeFromParentNode()
        self.synapseCrystalNode.lightingNode = nil
        self.synapseCrystalNode.lightingNode2?.removeFromParentNode()
        self.synapseCrystalNode.lightingNode2 = nil
    }

    func rotateSynapseNode(dx: CGFloat, dy: CGFloat) {

        if let mainNodeRoll = self.synapseCrystalNode.mainNodeRoll {
            let aroundSide: SCNVector3 = SCNVector3(x: 0, y: 1, z: 0)
            let actionSide: SCNAction = SCNAction.rotate(by: CGFloat(Double.pi / 180.0) * dx, around: aroundSide, duration: 0)
            actionSide.timingMode = .easeOut
            mainNodeRoll.runAction(actionSide, completionHandler: {
                //print("mainNodeRoll: \(self.mainNodeRoll.rotation) mainNode: \(self.mainNode.rotation)")
                //self.mainNodeRoll.removeAllActions()
            })

            if let mainNode = self.synapseCrystalNode.mainNode {
                let aroundLong: SCNVector3 = SCNVector3(x: Float(cos(mainNodeRoll.rotation.y * mainNodeRoll.rotation.w)), y: 0, z: Float(sin(mainNodeRoll.rotation.y * mainNodeRoll.rotation.w)))
                let actionLong: SCNAction = SCNAction.rotate(by: CGFloat(Double.pi / 180.0) * dy, around: aroundLong, duration: 0)
                actionLong.timingMode = .easeOut
                mainNode.runAction(actionLong, completionHandler: {
                    //self.mainNode.removeAllActions()
                })
            }
        }
    }

    func rotateSynapseNode() {

        if let mainZNode = self.synapseCrystalNode.mainZNode, let ax = self.synapseValues.ax, let ay = self.synapseValues.ay, let az = self.synapseValues.az {
            let radx: Double = atan(Double(ax) / sqrt(pow(Double(ay), 2) + pow(Double(az), 2)))
            let rady: Double = atan(Double(ay) / sqrt(pow(Double(ax), 2) + pow(Double(az), 2)))
            let radz: Double = atan(Double(az) / sqrt(pow(Double(ay), 2) + pow(Double(ax), 2)))

            if let radxBak = self.synapseCrystalNode.radxBak, let radyBak = self.synapseCrystalNode.radyBak {
                var deltaX: Double = radx - radxBak
                var deltaY: Double = rady - radyBak
                if radz < 0.0 {
                    deltaX = -deltaX
                    deltaY = -deltaY
                }
                self.synapseCrystalNode.rotateX += deltaX
                self.synapseCrystalNode.rotateY += deltaY
            }
            self.synapseCrystalNode.radxBak = radx
            self.synapseCrystalNode.radyBak = rady

            let action: SCNAction = SCNAction.rotateTo(x: CGFloat(-self.synapseCrystalNode.rotateY), y: 0, z: CGFloat(-self.synapseCrystalNode.rotateX), duration: self.rotateSynapseNodeDuration)
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

    func rotateCrystalNode() {

        let rotationValue: CGFloat = 1.0
        let action: SCNAction = SCNAction.rotateBy(x: 0, y: CGFloat(Double.pi / 180.0) * rotationValue, z: 0, duration: self.rotateCrystalNodeDuration)
        self.synapseCrystalNode.co2Node?.runAction(action, completionHandler: {
            //synapseCrystalNode.co2Node?.removeAllActions()
        })
        self.synapseCrystalNode.tempNode?.runAction(action, completionHandler: {
            //synapseCrystalNode.tempNode?.removeAllActions()
        })
        self.synapseCrystalNode.humidityNode?.runAction(action, completionHandler: {
            //synapseCrystalNode.humidityNode?.removeAllActions()
        })

        let rotationValue2: CGFloat = 0.5
        let action2: SCNAction = SCNAction.rotateBy(x: 0, y: 0, z: CGFloat(Double.pi / 180.0) * rotationValue2, duration: self.rotateCrystalNodeDuration)
        self.synapseCrystalNode.light1Node?.runAction(action2, completionHandler: {
            //synapseCrystalNode.light1Node?.removeAllActions()
        })
        self.synapseCrystalNode.light2Node?.runAction(action2, completionHandler: {
            //synapseCrystalNode.light2Node?.removeAllActions()
        })
        self.synapseCrystalNode.light3Node?.runAction(action2, completionHandler: {
            //synapseCrystalNode.light3Node?.removeAllActions()
        })

        let rotationValue3: CGFloat = 0.5
        let action3: SCNAction = SCNAction.rotateBy(x: 0, y: 0, z: CGFloat(Double.pi / 180.0) * -rotationValue3, duration: self.rotateCrystalNodeDuration)
        self.synapseCrystalNode.pressureNode?.runAction(action3, completionHandler: {
            //synapseCrystalNode.pressureNode?.removeAllActions()
        })
    }

    func scaleSynapseNode() {

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
        if self.synapseValues.isConnected {
            co2Scale = 0
            if let co2 = self.synapseValues.co2 {
                co2Scale = CGFloat(sqrt(Double(co2)) / sqrt(co2Base)) * co2BaseScale
            }
        }
        /*if co2Scale > 2.0 {
         co2Scale = 2.0
         }
         else if co2Scale < 0.2 {
         co2Scale = 0.2
         }*/
        let co2Action: SCNAction = SCNAction.scale(to: co2Scale, duration: self.scaleSynapseNodeDuration)
        co2Action.timingMode = .easeOut
        self.synapseCrystalNode.co2Node?.runAction(co2Action, completionHandler: {
            //synapseCrystalNode.co2Node?.removeAllActions()
        })

        var tempScale: CGFloat = 1.0
        if self.synapseValues.isConnected {
            tempScale = 0
            if let temp = self.synapseValues.temp {
                if temp > 0.0 {
                    tempScale = CGFloat(sqrt(Double(temp)) / sqrt(tempBase)) * tempBaseScale
                }
                else {
                    tempScale = 0
                }
            }
        }
        /*if tempScale > 2.0 {
         tempScale = 2.0
         }
         else if tempScale < 0.2 {
         tempScale = 0.2
         }*/
        let tempAction: SCNAction = SCNAction.scale(to: tempScale, duration: self.scaleSynapseNodeDuration)
        tempAction.timingMode = .easeOut
        self.synapseCrystalNode.tempNode?.runAction(tempAction, completionHandler: {
            //synapseCrystalNode.tempNode?.removeAllActions()
        })

        var pressScale: CGFloat = 1.0
        if self.synapseValues.isConnected {
            pressScale = 0
            if let press = self.synapseValues.pressure {
                pressScale = CGFloat(sqrt(Double(press)) / sqrt(pressBase)) * pressBaseScale
            }
        }
        /*if pressScale > 2.0 {
         pressScale = 2.0
         }
         else if pressScale < 0.2 {
         pressScale = 0.2
         }*/
        let pressAction: SCNAction = SCNAction.scale(to: pressScale, duration: self.scaleSynapseNodeDuration)
        pressAction.timingMode = .easeOut
        self.synapseCrystalNode.pressureNode?.runAction(pressAction, completionHandler: {
            //synapseCrystalNode.pressureNode?.removeAllActions()
        })

        var lightScale: CGFloat = 1.0
        if self.synapseValues.isConnected {
            lightScale = 0
            if let light = self.synapseValues.light {
                lightScale = CGFloat(sqrt(Double(light)) / sqrt(lightBase)) * lightBaseScale
            }
        }
        /*if lightScale > 2.0 {
         lightScale = 2.0
         }
         else if lightScale < 0.2 {
         lightScale = 0.2
         }*/
        let lightAction: SCNAction = SCNAction.scale(to: lightScale, duration: self.scaleSynapseNodeDuration)
        lightAction.timingMode = .easeOut
        self.synapseCrystalNode.light1Node?.runAction(lightAction, completionHandler: {
            //synapseCrystalNode.light1Node?.removeAllActions()
        })
        self.synapseCrystalNode.light2Node?.runAction(lightAction, completionHandler: {
            //synapseCrystalNode.light2Node?.removeAllActions()
        })
        self.synapseCrystalNode.light3Node?.runAction(lightAction, completionHandler: {
            //synapseCrystalNode.light3Node?.removeAllActions()
        })

        var humScale: CGFloat = 1.0
        if self.synapseValues.isConnected {
            humScale = 0
            if let hum = self.synapseValues.humidity {
                humScale = CGFloat(Double(hum) / humBase) * humBaseScale
            }
        }
        /*if humScale > 2.0 {
         humScale = 2.0
         }
         else if humScale < 0.2 {
         humScale = 0.2
         }*/
        let humAction: SCNAction = SCNAction.scale(to: humScale, duration: self.scaleSynapseNodeDuration)
        humAction.timingMode = .easeOut
        self.synapseCrystalNode.humidityNode?.runAction(humAction, completionHandler: {
            //synapseCrystalNode.humidityNode?.removeAllActions()
        })

        var soundScale: CGFloat = 1.0
        if self.synapseValues.isConnected {
            soundScale = 0
            if let sound = self.synapseValues.sound {
                soundScale = CGFloat(sqrt(Double(sound)) / sqrt(soundBase)) * soundBaseScale
            }
        }
        /*if soundScale > 2.0 {
         soundScale = 2.0
         }
         else if soundScale < 0.2 {
         soundScale = 0.2
         }*/
        let soundAction: SCNAction = SCNAction.scale(to: soundScale, duration: self.scaleSynapseNodeDuration)
        soundAction.timingMode = .easeOut
        self.synapseCrystalNode.soundNode?.runAction(soundAction, completionHandler: {
            //synapseCrystalNode.humidityNode?.removeAllActions()
        })
        /*
        var magxScale: CGFloat = 1.0
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

    func setColorSynapseNode(colorLevel: Double) {

        self.synapseCrystalNode.co2Node?.geometry?.materials = self.crystalGeometries.setCrystalGeometryColor(colorLevel)
        self.synapseCrystalNode.tempNode?.geometry?.materials = self.crystalGeometries.setCrystalGeometryColor(colorLevel)
        self.synapseCrystalNode.humidityNode?.geometry?.materials = self.crystalGeometries.setCrystalGeometryColor(colorLevel)
        self.synapseCrystalNode.pressureNode?.geometry?.materials = self.crystalGeometries.setCrystalGeometryColor(colorLevel)
        self.synapseCrystalNode.light1Node?.geometry?.materials = self.crystalGeometries.setCrystalGeometryColor(colorLevel)
        self.synapseCrystalNode.light2Node?.geometry?.materials = self.crystalGeometries.setCrystalGeometryColor(colorLevel)
        self.synapseCrystalNode.light3Node?.geometry?.materials = self.crystalGeometries.setCrystalGeometryColor(colorLevel)
        self.synapseCrystalNode.soundNode?.geometry?.materials = self.crystalGeometries.setCrystalGeometryColor(colorLevel)
        /*
         synapseCrystalNode.magneticXNode?.geometry?.materials = self.crystalGeometries.setCrystalGeometryColor(colorLevel)
         synapseCrystalNode.magneticYNode?.geometry?.materials = self.crystalGeometries.setCrystalGeometryColor(colorLevel)
         synapseCrystalNode.magneticZNode?.geometry?.materials = self.crystalGeometries.setCrystalGeometryColor(colorLevel)*/
        self.synapseCrystalNode.colorLevel = colorLevel
    }

    func setColorSynapseNodeFromBatteryLevel() {

        if let battery = self.synapseValues.battery {
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
            if level != self.synapseCrystalNode.colorLevel {
                self.setColorSynapseNode(colorLevel: level)
                //print("batteryLevel: \(self.batteryLevel)")
            }
        }
    }

    func setColorOffSynapseNode() {

        var isOff: Bool = true
        if let synapseRecordFileManager = self.synapseRecordFileManager {
            var connectDate: Date? = nil
            let logDays: [String] = synapseRecordFileManager.getDayDirectories()
            if logDays.count > 0 {
                let day: String = logDays[0]
                let logs: [String] = synapseRecordFileManager.getConnectLogs(day: day)
                if logs.count > 0 {
                    let log: String = logs[0]
                    //print("ConnectLog: \(log)")
                    let arr: [String] = log.components(separatedBy: "_")
                    if arr.count > 1 {
                        if let time = Double(arr[0]) {
                            connectDate = Date(timeIntervalSince1970: time)
                        }
                    }
                }
            }
            if let date = connectDate {
                let time: TimeInterval = date.timeIntervalSinceNow
                if -time < self.offColorTime {
                    isOff = false
                }
            }
        }

        self.synapseCrystalNode.co2Node?.geometry?.materials = self.crystalGeometries.setCrystalGeometryColorOff(isOff)
        self.synapseCrystalNode.tempNode?.geometry?.materials = self.crystalGeometries.setCrystalGeometryColorOff(isOff)
        self.synapseCrystalNode.humidityNode?.geometry?.materials = self.crystalGeometries.setCrystalGeometryColorOff(isOff)
        self.synapseCrystalNode.pressureNode?.geometry?.materials = self.crystalGeometries.setCrystalGeometryColorOff(isOff)
        self.synapseCrystalNode.light1Node?.geometry?.materials = self.crystalGeometries.setCrystalGeometryColorOff(isOff)
        self.synapseCrystalNode.light2Node?.geometry?.materials = self.crystalGeometries.setCrystalGeometryColorOff(isOff)
        self.synapseCrystalNode.light3Node?.geometry?.materials = self.crystalGeometries.setCrystalGeometryColorOff(isOff)
        self.synapseCrystalNode.soundNode?.geometry?.materials = self.crystalGeometries.setCrystalGeometryColorOff(isOff)
        /*
         synapseCrystalNode.magneticXNode?.geometry?.materials = self.crystalGeometries.setCrystalGeometryColorOff(isOff)
         synapseCrystalNode.magneticYNode?.geometry?.materials = self.crystalGeometries.setCrystalGeometryColorOff(isOff)
         synapseCrystalNode.magneticZNode?.geometry?.materials = self.crystalGeometries.setCrystalGeometryColorOff(isOff)*/
        self.synapseCrystalNode.colorLevel = nil
    }

    // MARK: mark - Make SynapseData methods

    func setSynapseValues() {

        if self.synapseData.count > 0 {
            let synapse = self.synapseData[0]
            //print("setSynapseValues: \(synapse)")
            if let time = synapse["time"] as? TimeInterval, let data = synapse["data"] as? [UInt8] {
                let formatter = DateFormatter()
                formatter.locale = Locale(identifier: "en_US_POSIX")
                formatter.dateFormat = "yyyyMMddHHmmss"
                self.synapseNowDate = formatter.string(from: Date(timeIntervalSince1970: time))
                //print("setSynapseNowDate: \(self.synapseNowDate)")
                self.synapseValues.time = time

                self.synapseValues.axBak = self.synapseValues.ax
                self.synapseValues.ayBak = self.synapseValues.ay
                self.synapseValues.azBak = self.synapseValues.az
                self.synapseValues.gxBak = self.synapseValues.gx
                self.synapseValues.gyBak = self.synapseValues.gy
                self.synapseValues.gzBak = self.synapseValues.gz
                self.synapseValues.co2 = nil
                self.synapseValues.ax = nil
                self.synapseValues.ay = nil
                self.synapseValues.az = nil
                self.synapseValues.light = nil
                self.synapseValues.gx = nil
                self.synapseValues.gy = nil
                self.synapseValues.gz = nil
                self.synapseValues.pressure = nil
                self.synapseValues.temp = nil
                self.synapseValues.humidity = nil
                self.synapseValues.sound = nil
                self.synapseValues.tvoc = nil
                self.synapseValues.power = nil
                self.synapseValues.battery = nil
                let values: [String: Any] = self.makeSynapseData(data)
                //print("setSynapseValues: \(self.synapseNowDate)\n\(values)")
                if let co2 = values["co2"] as? Int, co2 >= 400 {
                    self.synapseValues.co2 = co2
                }
                if let ax = values["ax"] as? Int {
                    self.synapseValues.ax = ax
                }
                if let ay = values["ay"] as? Int {
                    self.synapseValues.ay = ay
                }
                if let az = values["az"] as? Int {
                    self.synapseValues.az = az
                }
                if let light = values["light"] as? Int {
                    self.synapseValues.light = light
                }
                if let gx = values["gx"] as? Int {
                    self.synapseValues.gx = gx
                }
                if let gy = values["gy"] as? Int {
                    self.synapseValues.gy = gy
                }
                if let gz = values["gz"] as? Int {
                    self.synapseValues.gz = gz
                }
                if let pressure = values["pressure"] as? Float {
                    self.synapseValues.pressure = pressure
                }
                if let temp = values["temp"] as? Float {
                    self.synapseValues.temp = temp
                }
                if let humidity = values["humidity"] as? Int {
                    self.synapseValues.humidity = humidity
                }
                if let sound = values["sound"] as? Int {
                    self.synapseValues.sound = sound
                }
                if let tvoc = values["tvoc"] as? Int {
                    self.synapseValues.tvoc = tvoc
                }
                if let volt = values["volt"] as? Float {
                    self.synapseValues.power = volt
                }
                if let pow = values["pow"] as? Float {
                    self.synapseValues.battery = pow
                }
                /*
                if let mx = values["mx"] as? Int {
                    synapseValues.mx = mx
                }
                if let my = values["my"] as? Int {
                    synapseValues.my = my
                }
                if let mz = values["mz"] as? Int {
                    synapseValues.mz = mz
                }*/
            }
        }
    }

    func makeSynapseData(_ data: [UInt8]) -> [String: Any] {

        //print("makeSynapseData: \(data)")
        var synapseData: [String: Any] = [:]
        if data.count >= 6 {
            if data[4] != 0xff || data[5] != 0xff {
                synapseData["co2"] = self.makeSynapseInt(byte1: data[4], byte2: data[5], unsigned: true)
            }
            //print("co2: \(String(describing: synapseData["co2"]))")
        }
        if data.count >= 8 {
            if data[6] != 0xff || data[7] != 0xff {
                synapseData["ax"] = -self.makeSynapseInt(byte1: data[6], byte2: data[7], unsigned: false)
            }
            //print("ax: \(String(describing: synapseData["ax"]))")
        }
        if data.count >= 10 {
            if data[8] != 0xff || data[9] != 0xff {
                synapseData["ay"] = -self.makeSynapseInt(byte1: data[8], byte2: data[9], unsigned: false)
            }
            //print("ay: \(String(describing: synapseData["ay"]))")
        }
        if data.count >= 12 {
            if data[10] != 0xff || data[11] != 0xff {
                synapseData["az"] = self.makeSynapseInt(byte1: data[10], byte2: data[11], unsigned: false)
            }
            //print("az: \(String(describing: synapseData["az"]))")
        }
        if data.count >= 14 {
            if data[12] != 0xff || data[13] != 0xff {
                synapseData["gx"] = -self.makeSynapseInt(byte1: data[12], byte2: data[13], unsigned: false)
            }
            //print("gx: \(String(describing: synapseData["gx"]))")
        }
        if data.count >= 16 {
            if data[14] != 0xff || data[15] != 0xff {
                synapseData["gy"] = -self.makeSynapseInt(byte1: data[14], byte2: data[15], unsigned: false)
            }
            //print("gy: \(String(describing: synapseData["gy"]))")
        }
        if data.count >= 18 {
            if data[16] != 0xff || data[17] != 0xff {
                synapseData["gz"] = self.makeSynapseInt(byte1: data[16], byte2: data[17], unsigned: false)
            }
            //print("gz: \(String(describing: synapseData["gz"]))")
        }
        if data.count >= 20 {
            if data[18] != 0xff || data[19] != 0xff {
                synapseData["light"] = self.makeSynapseInt(byte1: data[18], byte2: data[19], unsigned: true)
            }
            //print("light: \(String(describing: synapseData["light"]))")
        }
        if data.count >= 22 {
            if data[20] != 0xff {
                synapseData["temp"] = self.makeSynapseFloat8(byte1: data[20], byte2: data[21])
            }
            //print("temp: \(String(describing: synapseData["temp"]))")
        }
        if data.count >= 23 {
            if data[22] != 0xff {
                synapseData["humidity"] = Int(data[22])
            }
            //print("humidity: \(String(describing: synapseData["humidity"]))")
        }
        if data.count >= 26 {
            if data[23] != 0xff || data[24] != 0xff {
                synapseData["pressure"] = self.makeSynapseFloat16(byte1: data[23], byte2: data[24], byte3: data[25])
            }
            //print("pressure: \(String(describing: synapseData["pressure"]))")
        }
        if data.count >= 28 {
            if data[26] != 0xff || data[27] != 0xff {
                synapseData["tvoc"] = self.makeSynapseInt(byte1: data[26], byte2: data[27], unsigned: true)
            }
            //print("tvoc: \(String(describing: synapseData["tvoc"]))")
        }
        if data.count >= 30 {
            if data[28] != 0xff || data[29] != 0xff {
                synapseData["volt"] = self.makeSynapseVoltageValue(byte1: data[28], byte2: data[29])
            }
            //print("volt: \(String(describing: synapseData["volt"]))")
        }
        if data.count >= 32 {
            if data[30] != 0xff || data[31] != 0xff {
                synapseData["pow"] = self.makeSynapsePowerValue(byte1: data[30], byte2: data[31])
            }
            //print("pow: \(String(describing: synapseData["pow"]))")
        }
        if data.count >= 34 {
            if data[32] != 0xff || data[33] != 0xff {
                synapseData["sound"] = self.makeSynapseInt(byte1: data[32], byte2: data[33], unsigned: true)
                //synapseData["sound"] = self.makeSynapseSoundDBValue(byte1: data[32], byte2: data[33])
            }
            //print("sound: \(String(describing: synapseData["sound"]))")
        }
        /*
        if synapseValues.count >= 20 {
            synapseData["my"] = -self.makeSynapseValue(synapseValues[19] + synapseValues[18], unsigned: false)
            //print("my: \(String(describing: synapseData["my"]))")
        }
        if synapseValues.count >= 22 {
            synapseData["mx"] = -self.makeSynapseValue(synapseValues[21] + synapseValues[20], unsigned: false)
            //print("mx: \(String(describing: synapseData["mx"]))")
        }
        if synapseValues.count >= 24 {
            synapseData["mz"] = -self.makeSynapseValue(synapseValues[23] + synapseValues[22], unsigned: false)
            //print("mz: \(String(describing: synapseData["mz"]))")
        }*/
        return synapseData
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
    }*/

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
    }*/

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
            //print("check saveSynapseMaxAndMinValues")
        }
        DispatchQueue.global(qos: .background).async {
            self.checkSynapseTotalInHour()
            //print("check SynapseTotalInHour")
        }
    }

    func copySynapseValues(_ synapseValues: SynapseValues) -> SynapseValues {

        let synapseValuesCopy: SynapseValues = SynapseValues("")
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
    }*/

    func saveSynapseTotal(_ synapseValues: SynapseValues) -> Bool {

        var res: Bool = false
        var dateStr: String = ""
        if let time = synapseValues.time {
            let formatter = DateFormatter()
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
                        res = synapseRecordFileManager.setSynapseRecordTotal(Double(ax), day: day, hour: hour, min: min, sec: sec, type: "ax")
                        res = synapseRecordFileManager.setSynapseRecordTotal(Double(ay), day: day, hour: hour, min: min, sec: sec, type: "ay")
                        res = synapseRecordFileManager.setSynapseRecordTotal(Double(az), day: day, hour: hour, min: min, sec: sec, type: "az")
                    }
                }
                if self.synapseCrystalInfo.ill.hasGraph {
                    if let light = synapseValues.light {
                        res = synapseRecordFileManager.setSynapseRecordTotal(Double(light), day: day, hour: hour, min: min, sec: sec, type: self.synapseCrystalInfo.ill.key)
                    }
                }
                if self.synapseCrystalInfo.angle.hasGraph {
                    if let gx = synapseValues.gx, let gy = synapseValues.gy, let gz = synapseValues.gz {
                        res = synapseRecordFileManager.setSynapseRecordTotal(Double(gx), day: day, hour: hour, min: min, sec: sec, type: "gx")
                        res = synapseRecordFileManager.setSynapseRecordTotal(Double(gy), day: day, hour: hour, min: min, sec: sec, type: "gy")
                        res = synapseRecordFileManager.setSynapseRecordTotal(Double(gz), day: day, hour: hour, min: min, sec: sec, type: "gz")
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
                /*
                if self.synapseCrystalInfo.mag.hasGraph {
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
                    res = synapseRecordFileManager.setSynapseRecordTotal(Double(axDiff), day: day, hour: hour, min: min, sec: sec, type: "ax_diff")
                    res = synapseRecordFileManager.setSynapseRecordTotal(Double(ayDiff), day: day, hour: hour, min: min, sec: sec, type: "ay_diff")
                    res = synapseRecordFileManager.setSynapseRecordTotal(Double(azDiff), day: day, hour: hour, min: min, sec: sec, type: "az_diff")
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
                    res = synapseRecordFileManager.setSynapseRecordTotal(Double(gxDiff), day: day, hour: hour, min: min, sec: sec, type: "gx_diff")
                    res = synapseRecordFileManager.setSynapseRecordTotal(Double(gyDiff), day: day, hour: hour, min: min, sec: sec, type: "gy_diff")
                    res = synapseRecordFileManager.setSynapseRecordTotal(Double(gzDiff), day: day, hour: hour, min: min, sec: sec, type: "gz_diff")
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
            self.synapseRecordFileManager?.setSynapseRecordTotalInHour(type: "ax", start: startDate)
            self.synapseRecordFileManager?.setSynapseRecordTotalInHour(type: "ay", start: startDate)
            self.synapseRecordFileManager?.setSynapseRecordTotalInHour(type: "az", start: startDate)
        }
        if self.synapseCrystalInfo.ill.hasGraph {
            self.synapseRecordFileManager?.setSynapseRecordTotalInHour(type: self.synapseCrystalInfo.ill.key, start: startDate)
        }
        if self.synapseCrystalInfo.angle.hasGraph {
            self.synapseRecordFileManager?.setSynapseRecordTotalInHour(type: "gx", start: startDate)
            self.synapseRecordFileManager?.setSynapseRecordTotalInHour(type: "gy", start: startDate)
            self.synapseRecordFileManager?.setSynapseRecordTotalInHour(type: "gz", start: startDate)
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
        /*
        if self.synapseCrystalInfo.mag.hasGraph {
            self.synapseRecordFileManager.setSynapseRecordTotalInHour(type: "mx")
            self.synapseRecordFileManager.setSynapseRecordTotalInHour(type: "my")
            self.synapseRecordFileManager.setSynapseRecordTotalInHour(type: "mz")
            self.synapseRecordFileManager.setSynapseRecordTotalInHour(type: self.synapseCrystalInfo.mag.key)
        }*/

        self.synapseRecordFileManager?.setSynapseRecordTotalInHour(type: "ax_diff", start: startDate)
        self.synapseRecordFileManager?.setSynapseRecordTotalInHour(type: "ay_diff", start: startDate)
        self.synapseRecordFileManager?.setSynapseRecordTotalInHour(type: "az_diff", start: startDate)
        self.synapseRecordFileManager?.setSynapseRecordTotalInHour(type: "gx_diff", start: startDate)
        self.synapseRecordFileManager?.setSynapseRecordTotalInHour(type: "gy_diff", start: startDate)
        self.synapseRecordFileManager?.setSynapseRecordTotalInHour(type: "gz_diff", start: startDate)
    }

    // MARK: mark - SynapseData MaxAndMin methods

    func setSynapseMaxAndMinValues() {

        if let co2 = self.synapseValues.co2 {
            let co2Val: Double = Double(co2)
            if let dateStr = self.synapseDataMaxAndMins.co2.dateStr, let max = self.synapseDataMaxAndMins.co2.max, let maxNow = self.synapseDataMaxAndMins.co2.maxNow, let min = self.synapseDataMaxAndMins.co2.min, let minNow = self.synapseDataMaxAndMins.co2.minNow {
                let dateNow: String = String(self.synapseNowDate[self.synapseNowDate.startIndex..<self.synapseNowDate.index(self.synapseNowDate.startIndex, offsetBy: 12)])
                let dateCheck: String = String(dateStr[dateStr.startIndex..<dateStr.index(dateStr.startIndex, offsetBy: 12)])
                //print("setSynapseMaxAndMinValues dateStr: \(dateNow) - \(dateCheck)")
                if maxNow < co2Val {
                    self.synapseDataMaxAndMins.co2.maxNow = co2Val
                    self.synapseDataMaxAndMins.co2.updatedMax = true
                }
                if max < co2Val || dateNow != dateCheck {
                    self.synapseDataMaxAndMins.co2.max = co2Val
                    self.synapseDataMaxAndMins.co2.updatedMax = true
                }
                if minNow > co2Val {
                    self.synapseDataMaxAndMins.co2.minNow = co2Val
                    self.synapseDataMaxAndMins.co2.updatedMin = true
                }
                if min > co2Val || dateNow != dateCheck {
                    self.synapseDataMaxAndMins.co2.min = co2Val
                    self.synapseDataMaxAndMins.co2.updatedMin = true
                }
            }
            else {
                self.synapseDataMaxAndMins.co2.maxNow = co2Val
                self.synapseDataMaxAndMins.co2.max = co2Val
                self.synapseDataMaxAndMins.co2.minNow = co2Val
                self.synapseDataMaxAndMins.co2.min = co2Val
                self.synapseDataMaxAndMins.co2.updatedMax = true
                self.synapseDataMaxAndMins.co2.updatedMin = true
            }
            self.synapseDataMaxAndMins.co2.dateStr = self.synapseNowDate
        }
        if let ax = self.synapseValues.ax {
            let axVal: Double = Double(ax)
            if let dateStr = self.synapseDataMaxAndMins.ax.dateStr, let max = self.synapseDataMaxAndMins.ax.max, let maxNow = self.synapseDataMaxAndMins.ax.maxNow, let min = self.synapseDataMaxAndMins.ax.min, let minNow = self.synapseDataMaxAndMins.ax.minNow {
                let dateNow: String = String(self.synapseNowDate[self.synapseNowDate.startIndex..<self.synapseNowDate.index(self.synapseNowDate.startIndex, offsetBy: 12)])
                let dateCheck: String = String(dateStr[dateStr.startIndex..<dateStr.index(dateStr.startIndex, offsetBy: 12)])
                //print("setSynapseMaxAndMinValues dateStr: \(dateNow) - \(dateCheck)")
                if maxNow < axVal {
                    self.synapseDataMaxAndMins.ax.maxNow = axVal
                    self.synapseDataMaxAndMins.ax.updatedMax = true
                }
                if max < axVal || dateNow != dateCheck {
                    self.synapseDataMaxAndMins.ax.max = axVal
                    self.synapseDataMaxAndMins.ax.updatedMax = true
                }
                if minNow > axVal {
                    self.synapseDataMaxAndMins.ax.minNow = axVal
                    self.synapseDataMaxAndMins.ax.updatedMin = true
                }
                if min > axVal || dateNow != dateCheck {
                    self.synapseDataMaxAndMins.ax.min = axVal
                    self.synapseDataMaxAndMins.ax.updatedMin = true
                }
            }
            else {
                self.synapseDataMaxAndMins.ax.maxNow = axVal
                self.synapseDataMaxAndMins.ax.max = axVal
                self.synapseDataMaxAndMins.ax.minNow = axVal
                self.synapseDataMaxAndMins.ax.min = axVal
                self.synapseDataMaxAndMins.ax.updatedMax = true
                self.synapseDataMaxAndMins.ax.updatedMin = true
            }
            self.synapseDataMaxAndMins.ax.dateStr = self.synapseNowDate
        }
        if let ay = self.synapseValues.ay {
            let ayVal: Double = Double(ay)
            if let dateStr = self.synapseDataMaxAndMins.ay.dateStr, let max = self.synapseDataMaxAndMins.ay.max, let maxNow = self.synapseDataMaxAndMins.ay.maxNow, let min = self.synapseDataMaxAndMins.ay.min, let minNow = self.synapseDataMaxAndMins.ay.minNow {
                let dateNow: String = String(self.synapseNowDate[self.synapseNowDate.startIndex..<self.synapseNowDate.index(self.synapseNowDate.startIndex, offsetBy: 12)])
                let dateCheck: String = String(dateStr[dateStr.startIndex..<dateStr.index(dateStr.startIndex, offsetBy: 12)])
                //print("setSynapseMaxAndMinValues dateStr: \(dateNow) - \(dateCheck)")
                if maxNow < ayVal {
                    self.synapseDataMaxAndMins.ay.maxNow = ayVal
                    self.synapseDataMaxAndMins.ay.updatedMax = true
                }
                if max < ayVal || dateNow != dateCheck {
                    self.synapseDataMaxAndMins.ay.max = ayVal
                    self.synapseDataMaxAndMins.ay.updatedMax = true
                }
                if minNow > ayVal {
                    self.synapseDataMaxAndMins.ay.minNow = ayVal
                    self.synapseDataMaxAndMins.ay.updatedMin = true
                }
                if min > ayVal || dateNow != dateCheck {
                    self.synapseDataMaxAndMins.ay.min = ayVal
                    self.synapseDataMaxAndMins.ay.updatedMin = true
                }
            }
            else {
                self.synapseDataMaxAndMins.ay.maxNow = ayVal
                self.synapseDataMaxAndMins.ay.max = ayVal
                self.synapseDataMaxAndMins.ay.minNow = ayVal
                self.synapseDataMaxAndMins.ay.min = ayVal
                self.synapseDataMaxAndMins.ay.updatedMax = true
                self.synapseDataMaxAndMins.ay.updatedMin = true
            }
            self.synapseDataMaxAndMins.ay.dateStr = self.synapseNowDate
        }
        if let az = self.synapseValues.az {
            let azVal: Double = Double(az)
            if let dateStr = self.synapseDataMaxAndMins.az.dateStr, let max = self.synapseDataMaxAndMins.az.max, let maxNow = self.synapseDataMaxAndMins.az.maxNow, let min = self.synapseDataMaxAndMins.az.min, let minNow = self.synapseDataMaxAndMins.az.minNow {
                let dateNow: String = String(self.synapseNowDate[self.synapseNowDate.startIndex..<self.synapseNowDate.index(self.synapseNowDate.startIndex, offsetBy: 12)])
                let dateCheck: String = String(dateStr[dateStr.startIndex..<dateStr.index(dateStr.startIndex, offsetBy: 12)])
                //print("setSynapseMaxAndMinValues dateStr: \(dateNow) - \(dateCheck)")
                if maxNow < azVal {
                    self.synapseDataMaxAndMins.az.maxNow = azVal
                    self.synapseDataMaxAndMins.az.updatedMax = true
                }
                if max < azVal || dateNow != dateCheck {
                    self.synapseDataMaxAndMins.az.max = azVal
                    self.synapseDataMaxAndMins.az.updatedMax = true
                }
                if minNow > azVal {
                    self.synapseDataMaxAndMins.az.minNow = azVal
                    self.synapseDataMaxAndMins.az.updatedMin = true
                }
                if min > azVal || dateNow != dateCheck {
                    self.synapseDataMaxAndMins.az.min = azVal
                    self.synapseDataMaxAndMins.az.updatedMin = true
                }
            }
            else {
                self.synapseDataMaxAndMins.az.maxNow = azVal
                self.synapseDataMaxAndMins.az.max = azVal
                self.synapseDataMaxAndMins.az.minNow = azVal
                self.synapseDataMaxAndMins.az.min = azVal
                self.synapseDataMaxAndMins.az.updatedMax = true
                self.synapseDataMaxAndMins.az.updatedMin = true
            }
            self.synapseDataMaxAndMins.az.dateStr = self.synapseNowDate
        }
        if let light = self.synapseValues.light {
            let lightVal: Double = Double(light)
            if let dateStr = self.synapseDataMaxAndMins.light.dateStr, let max = self.synapseDataMaxAndMins.light.max, let maxNow = self.synapseDataMaxAndMins.light.maxNow, let min = self.synapseDataMaxAndMins.light.min, let minNow = self.synapseDataMaxAndMins.light.minNow {
                let dateNow: String = String(self.synapseNowDate[self.synapseNowDate.startIndex..<self.synapseNowDate.index(self.synapseNowDate.startIndex, offsetBy: 12)])
                let dateCheck: String = String(dateStr[dateStr.startIndex..<dateStr.index(dateStr.startIndex, offsetBy: 12)])
                //print("setSynapseMaxAndMinValues dateStr: \(dateNow) - \(dateCheck)")
                if maxNow < lightVal {
                    self.synapseDataMaxAndMins.light.maxNow = lightVal
                    self.synapseDataMaxAndMins.light.updatedMax = true
                }
                if max < lightVal || dateNow != dateCheck {
                    self.synapseDataMaxAndMins.light.max = lightVal
                    self.synapseDataMaxAndMins.light.updatedMax = true
                }
                if minNow > lightVal {
                    self.synapseDataMaxAndMins.light.minNow = lightVal
                    self.synapseDataMaxAndMins.light.updatedMin = true
                }
                if min > lightVal || dateNow != dateCheck {
                    self.synapseDataMaxAndMins.light.min = lightVal
                    self.synapseDataMaxAndMins.light.updatedMin = true
                }
            }
            else {
                self.synapseDataMaxAndMins.light.maxNow = lightVal
                self.synapseDataMaxAndMins.light.max = lightVal
                self.synapseDataMaxAndMins.light.minNow = lightVal
                self.synapseDataMaxAndMins.light.min = lightVal
                self.synapseDataMaxAndMins.light.updatedMax = true
                self.synapseDataMaxAndMins.light.updatedMin = true
            }
            self.synapseDataMaxAndMins.light.dateStr = self.synapseNowDate
        }
        if let gx = self.synapseValues.gx {
            let gxVal: Double = Double(gx)
            if let dateStr = self.synapseDataMaxAndMins.gx.dateStr, let max = self.synapseDataMaxAndMins.gx.max, let maxNow = self.synapseDataMaxAndMins.gx.maxNow, let min = self.synapseDataMaxAndMins.gx.min, let minNow = self.synapseDataMaxAndMins.gx.minNow {
                let dateNow: String = String(self.synapseNowDate[self.synapseNowDate.startIndex..<self.synapseNowDate.index(self.synapseNowDate.startIndex, offsetBy: 12)])
                let dateCheck: String = String(dateStr[dateStr.startIndex..<dateStr.index(dateStr.startIndex, offsetBy: 12)])
                //print("setSynapseMaxAndMinValues dateStr: \(dateNow) - \(dateCheck)")
                if maxNow < gxVal {
                    self.synapseDataMaxAndMins.gx.maxNow = gxVal
                    self.synapseDataMaxAndMins.gx.updatedMax = true
                }
                if max < gxVal || dateNow != dateCheck {
                    self.synapseDataMaxAndMins.gx.max = gxVal
                    self.synapseDataMaxAndMins.gx.updatedMax = true
                }
                if minNow > gxVal {
                    self.synapseDataMaxAndMins.gx.minNow = gxVal
                    self.synapseDataMaxAndMins.gx.updatedMin = true
                }
                if min > gxVal || dateNow != dateCheck {
                    self.synapseDataMaxAndMins.gx.min = gxVal
                    self.synapseDataMaxAndMins.gx.updatedMin = true
                }
            }
            else {
                self.synapseDataMaxAndMins.gx.maxNow = gxVal
                self.synapseDataMaxAndMins.gx.max = gxVal
                self.synapseDataMaxAndMins.gx.minNow = gxVal
                self.synapseDataMaxAndMins.gx.min = gxVal
                self.synapseDataMaxAndMins.gx.updatedMax = true
                self.synapseDataMaxAndMins.gx.updatedMin = true
            }
            self.synapseDataMaxAndMins.gx.dateStr = self.synapseNowDate
        }
        if let gy = self.synapseValues.gy {
            let gyVal: Double = Double(gy)
            if let dateStr = self.synapseDataMaxAndMins.gy.dateStr, let max = self.synapseDataMaxAndMins.gy.max, let maxNow = self.synapseDataMaxAndMins.gy.maxNow, let min = self.synapseDataMaxAndMins.gy.min, let minNow = self.synapseDataMaxAndMins.gy.minNow {
                let dateNow: String = String(self.synapseNowDate[self.synapseNowDate.startIndex..<self.synapseNowDate.index(self.synapseNowDate.startIndex, offsetBy: 12)])
                let dateCheck: String = String(dateStr[dateStr.startIndex..<dateStr.index(dateStr.startIndex, offsetBy: 12)])
                //print("setSynapseMaxAndMinValues dateStr: \(dateNow) - \(dateCheck)")
                if maxNow < gyVal {
                    self.synapseDataMaxAndMins.gy.maxNow = gyVal
                    self.synapseDataMaxAndMins.gy.updatedMax = true
                }
                if max < gyVal || dateNow != dateCheck {
                    self.synapseDataMaxAndMins.gy.max = gyVal
                    self.synapseDataMaxAndMins.gy.updatedMax = true
                }
                if minNow > gyVal {
                    self.synapseDataMaxAndMins.gy.minNow = gyVal
                    self.synapseDataMaxAndMins.gy.updatedMin = true
                }
                if min > gyVal || dateNow != dateCheck {
                    self.synapseDataMaxAndMins.gy.min = gyVal
                    self.synapseDataMaxAndMins.gy.updatedMin = true
                }
            }
            else {
                self.synapseDataMaxAndMins.gy.maxNow = gyVal
                self.synapseDataMaxAndMins.gy.max = gyVal
                self.synapseDataMaxAndMins.gy.minNow = gyVal
                self.synapseDataMaxAndMins.gy.min = gyVal
                self.synapseDataMaxAndMins.gy.updatedMax = true
                self.synapseDataMaxAndMins.gy.updatedMin = true
            }
            self.synapseDataMaxAndMins.gy.dateStr = self.synapseNowDate
        }
        if let gz = self.synapseValues.gz {
            let gzVal: Double = Double(gz)
            if let dateStr = self.synapseDataMaxAndMins.gz.dateStr, let max = self.synapseDataMaxAndMins.gz.max, let maxNow = self.synapseDataMaxAndMins.gz.maxNow, let min = self.synapseDataMaxAndMins.gz.min, let minNow = self.synapseDataMaxAndMins.gz.minNow {
                let dateNow: String = String(self.synapseNowDate[self.synapseNowDate.startIndex..<self.synapseNowDate.index(self.synapseNowDate.startIndex, offsetBy: 12)])
                let dateCheck: String = String(dateStr[dateStr.startIndex..<dateStr.index(dateStr.startIndex, offsetBy: 12)])
                //print("setSynapseMaxAndMinValues dateStr: \(dateNow) - \(dateCheck)")
                if maxNow < gzVal {
                    self.synapseDataMaxAndMins.gz.maxNow = gzVal
                    self.synapseDataMaxAndMins.gz.updatedMax = true
                }
                if max < gzVal || dateNow != dateCheck {
                    self.synapseDataMaxAndMins.gz.max = gzVal
                    self.synapseDataMaxAndMins.gz.updatedMax = true
                }
                if minNow > gzVal {
                    self.synapseDataMaxAndMins.gz.minNow = gzVal
                    self.synapseDataMaxAndMins.gz.updatedMin = true
                }
                if min > gzVal || dateNow != dateCheck {
                    self.synapseDataMaxAndMins.gz.min = gzVal
                    self.synapseDataMaxAndMins.gz.updatedMin = true
                }
            }
            else {
                self.synapseDataMaxAndMins.gz.maxNow = gzVal
                self.synapseDataMaxAndMins.gz.max = gzVal
                self.synapseDataMaxAndMins.gz.minNow = gzVal
                self.synapseDataMaxAndMins.gz.min = gzVal
                self.synapseDataMaxAndMins.gz.updatedMax = true
                self.synapseDataMaxAndMins.gz.updatedMin = true
            }
            self.synapseDataMaxAndMins.gz.dateStr = self.synapseNowDate
        }
        if let press = self.synapseValues.pressure {
            let pressVal: Double = Double(press)
            if let dateStr = self.synapseDataMaxAndMins.press.dateStr, let max = self.synapseDataMaxAndMins.press.max, let maxNow = self.synapseDataMaxAndMins.press.maxNow, let min = self.synapseDataMaxAndMins.press.min, let minNow = self.synapseDataMaxAndMins.press.minNow {
                let dateNow: String = String(self.synapseNowDate[self.synapseNowDate.startIndex..<self.synapseNowDate.index(self.synapseNowDate.startIndex, offsetBy: 12)])
                let dateCheck: String = String(dateStr[dateStr.startIndex..<dateStr.index(dateStr.startIndex, offsetBy: 12)])
                //print("setSynapseMaxAndMinValues dateStr: \(dateNow) - \(dateCheck)")
                if maxNow < pressVal {
                    self.synapseDataMaxAndMins.press.maxNow = pressVal
                    self.synapseDataMaxAndMins.press.updatedMax = true
                }
                if max < pressVal || dateNow != dateCheck {
                    self.synapseDataMaxAndMins.press.max = pressVal
                    self.synapseDataMaxAndMins.press.updatedMax = true
                }
                if minNow > pressVal {
                    self.synapseDataMaxAndMins.press.minNow = pressVal
                    self.synapseDataMaxAndMins.press.updatedMin = true
                }
                if min > pressVal || dateNow != dateCheck {
                    self.synapseDataMaxAndMins.press.min = pressVal
                    self.synapseDataMaxAndMins.press.updatedMin = true
                }
            }
            else {
                self.synapseDataMaxAndMins.press.maxNow = pressVal
                self.synapseDataMaxAndMins.press.max = pressVal
                self.synapseDataMaxAndMins.press.minNow = pressVal
                self.synapseDataMaxAndMins.press.min = pressVal
                self.synapseDataMaxAndMins.press.updatedMax = true
                self.synapseDataMaxAndMins.press.updatedMin = true
            }
            self.synapseDataMaxAndMins.press.dateStr = self.synapseNowDate
        }
        if let temp = self.synapseValues.temp {
            let tempVal: Double = Double(temp)
            if let dateStr = self.synapseDataMaxAndMins.temp.dateStr, let max = self.synapseDataMaxAndMins.temp.max, let maxNow = self.synapseDataMaxAndMins.temp.maxNow, let min = self.synapseDataMaxAndMins.temp.min, let minNow = self.synapseDataMaxAndMins.temp.minNow {
                let dateNow: String = String(self.synapseNowDate[self.synapseNowDate.startIndex..<self.synapseNowDate.index(self.synapseNowDate.startIndex, offsetBy: 12)])
                let dateCheck: String = String(dateStr[dateStr.startIndex..<dateStr.index(dateStr.startIndex, offsetBy: 12)])
                //print("setSynapseMaxAndMinValues dateStr: \(dateNow) - \(dateCheck)")
                if maxNow < tempVal {
                    self.synapseDataMaxAndMins.temp.maxNow = tempVal
                    self.synapseDataMaxAndMins.temp.updatedMax = true
                }
                if max < tempVal || dateNow != dateCheck {
                    self.synapseDataMaxAndMins.temp.max = tempVal
                    self.synapseDataMaxAndMins.temp.updatedMax = true
                }
                if minNow > tempVal {
                    self.synapseDataMaxAndMins.temp.minNow = tempVal
                    self.synapseDataMaxAndMins.temp.updatedMin = true
                }
                if min > tempVal || dateNow != dateCheck {
                    self.synapseDataMaxAndMins.temp.min = tempVal
                    self.synapseDataMaxAndMins.temp.updatedMin = true
                }
            }
            else {
                self.synapseDataMaxAndMins.temp.maxNow = tempVal
                self.synapseDataMaxAndMins.temp.max = tempVal
                self.synapseDataMaxAndMins.temp.minNow = tempVal
                self.synapseDataMaxAndMins.temp.min = tempVal
                self.synapseDataMaxAndMins.temp.updatedMax = true
                self.synapseDataMaxAndMins.temp.updatedMin = true
            }
            self.synapseDataMaxAndMins.temp.dateStr = self.synapseNowDate
        }
        if let hum = self.synapseValues.humidity {
            let humVal: Double = Double(hum)
            if let dateStr = self.synapseDataMaxAndMins.hum.dateStr, let max = self.synapseDataMaxAndMins.hum.max, let maxNow = self.synapseDataMaxAndMins.hum.maxNow, let min = self.synapseDataMaxAndMins.hum.min, let minNow = self.synapseDataMaxAndMins.hum.minNow {
                let dateNow: String = String(self.synapseNowDate[self.synapseNowDate.startIndex..<self.synapseNowDate.index(self.synapseNowDate.startIndex, offsetBy: 12)])
                let dateCheck: String = String(dateStr[dateStr.startIndex..<dateStr.index(dateStr.startIndex, offsetBy: 12)])
                //print("setSynapseMaxAndMinValues dateStr: \(dateNow) - \(dateCheck)")
                if maxNow < humVal {
                    self.synapseDataMaxAndMins.hum.maxNow = humVal
                    self.synapseDataMaxAndMins.hum.updatedMax = true
                }
                if max < humVal || dateNow != dateCheck {
                    self.synapseDataMaxAndMins.hum.max = humVal
                    self.synapseDataMaxAndMins.hum.updatedMax = true
                }
                if minNow > humVal {
                    self.synapseDataMaxAndMins.hum.minNow = humVal
                    self.synapseDataMaxAndMins.hum.updatedMin = true
                }
                if min > humVal || dateNow != dateCheck {
                    self.synapseDataMaxAndMins.hum.min = humVal
                    self.synapseDataMaxAndMins.hum.updatedMin = true
                }
            }
            else {
                self.synapseDataMaxAndMins.hum.maxNow = humVal
                self.synapseDataMaxAndMins.hum.max = humVal
                self.synapseDataMaxAndMins.hum.minNow = humVal
                self.synapseDataMaxAndMins.hum.min = humVal
                self.synapseDataMaxAndMins.hum.updatedMax = true
                self.synapseDataMaxAndMins.hum.updatedMin = true
            }
            self.synapseDataMaxAndMins.hum.dateStr = self.synapseNowDate
        }
        if let sound = self.synapseValues.sound {
            let soundVal: Double = Double(sound)
            if let dateStr = self.synapseDataMaxAndMins.sound.dateStr, let max = self.synapseDataMaxAndMins.sound.max, let maxNow = self.synapseDataMaxAndMins.sound.maxNow, let min = self.synapseDataMaxAndMins.sound.min, let minNow = self.synapseDataMaxAndMins.sound.minNow {
                let dateNow: String = String(self.synapseNowDate[self.synapseNowDate.startIndex..<self.synapseNowDate.index(self.synapseNowDate.startIndex, offsetBy: 12)])
                let dateCheck: String = String(dateStr[dateStr.startIndex..<dateStr.index(dateStr.startIndex, offsetBy: 12)])
                //print("setSynapseMaxAndMinValues dateStr: \(dateNow) - \(dateCheck)")
                if maxNow < soundVal {
                    self.synapseDataMaxAndMins.sound.maxNow = soundVal
                    self.synapseDataMaxAndMins.sound.updatedMax = true
                }
                if max < soundVal || dateNow != dateCheck {
                    self.synapseDataMaxAndMins.sound.max = soundVal
                    self.synapseDataMaxAndMins.sound.updatedMax = true
                }
                if minNow > soundVal {
                    self.synapseDataMaxAndMins.sound.minNow = soundVal
                    self.synapseDataMaxAndMins.sound.updatedMin = true
                }
                if min > soundVal || dateNow != dateCheck {
                    self.synapseDataMaxAndMins.sound.min = soundVal
                    self.synapseDataMaxAndMins.sound.updatedMin = true
                }
            }
            else {
                self.synapseDataMaxAndMins.sound.maxNow = soundVal
                self.synapseDataMaxAndMins.sound.max = soundVal
                self.synapseDataMaxAndMins.sound.minNow = soundVal
                self.synapseDataMaxAndMins.sound.min = soundVal
                self.synapseDataMaxAndMins.sound.updatedMax = true
                self.synapseDataMaxAndMins.sound.updatedMin = true
            }
            self.synapseDataMaxAndMins.sound.dateStr = self.synapseNowDate
        }
        if let volt = self.synapseValues.power {
            let voltVal: Double = Double(volt)
            if let dateStr = self.synapseDataMaxAndMins.volt.dateStr, let max = self.synapseDataMaxAndMins.volt.max, let maxNow = self.synapseDataMaxAndMins.volt.maxNow, let min = self.synapseDataMaxAndMins.volt.min, let minNow = self.synapseDataMaxAndMins.volt.minNow {
                let dateNow: String = String(self.synapseNowDate[self.synapseNowDate.startIndex..<self.synapseNowDate.index(self.synapseNowDate.startIndex, offsetBy: 12)])
                let dateCheck: String = String(dateStr[dateStr.startIndex..<dateStr.index(dateStr.startIndex, offsetBy: 12)])
                //print("setSynapseMaxAndMinValues dateStr: \(dateNow) - \(dateCheck)")
                if maxNow < voltVal {
                    self.synapseDataMaxAndMins.volt.maxNow = voltVal
                    self.synapseDataMaxAndMins.volt.updatedMax = true
                }
                if max < voltVal || dateNow != dateCheck {
                    self.synapseDataMaxAndMins.volt.max = voltVal
                    self.synapseDataMaxAndMins.volt.updatedMax = true
                }
                if minNow > voltVal {
                    self.synapseDataMaxAndMins.volt.minNow = voltVal
                    self.synapseDataMaxAndMins.volt.updatedMin = true
                }
                if min > voltVal || dateNow != dateCheck {
                    self.synapseDataMaxAndMins.volt.min = voltVal
                    self.synapseDataMaxAndMins.volt.updatedMin = true
                }
            }
            else {
                self.synapseDataMaxAndMins.volt.maxNow = voltVal
                self.synapseDataMaxAndMins.volt.max = voltVal
                self.synapseDataMaxAndMins.volt.minNow = voltVal
                self.synapseDataMaxAndMins.volt.min = voltVal
                self.synapseDataMaxAndMins.volt.updatedMax = true
                self.synapseDataMaxAndMins.volt.updatedMin = true
            }
            self.synapseDataMaxAndMins.volt.dateStr = self.synapseNowDate
        }
        /*
        if let mx = synapseValues.mx {
            let mxVal: Double = Double(mx)
            if let dateStr = self.synapseDataMaxAndMins.mx.dateStr, let max = self.synapseDataMaxAndMins.mx.max, let maxNow = self.synapseDataMaxAndMins.mx.maxNow, let min = self.synapseDataMaxAndMins.mx.min, let minNow = self.synapseDataMaxAndMins.mx.minNow {
                let dateNow: String = self.synapseNowDate.substring(to: self.synapseNowDate.index(self.synapseNowDate.startIndex, offsetBy: 12))
                let dateCheck: String = dateStr.substring(to: dateStr.index(dateStr.startIndex, offsetBy: 12))
                if maxNow < mxVal {
                    self.synapseDataMaxAndMins.mx.maxNow = mxVal
                    self.synapseDataMaxAndMins.mx.updatedMax = true
                }
                if max < mxVal || dateNow != dateCheck {
                    self.synapseDataMaxAndMins.mx.max = mxVal
                    self.synapseDataMaxAndMins.mx.updatedMax = true
                }
                if minNow > mxVal {
                    self.synapseDataMaxAndMins.mx.minNow = mxVal
                    self.synapseDataMaxAndMins.mx.updatedMin = true
                }
                if min > mxVal || dateNow != dateCheck {
                    self.synapseDataMaxAndMins.mx.min = mxVal
                    self.synapseDataMaxAndMins.mx.updatedMin = true
                }
            }
            else {
                self.synapseDataMaxAndMins.mx.maxNow = mxVal
                self.synapseDataMaxAndMins.mx.max = mxVal
                self.synapseDataMaxAndMins.mx.minNow = mxVal
                self.synapseDataMaxAndMins.mx.min = mxVal
                self.synapseDataMaxAndMins.mx.updatedMax = true
                self.synapseDataMaxAndMins.mx.updatedMin = true
            }
            self.synapseDataMaxAndMins.mx.dateStr = self.synapseNowDate
        }
        if let my = synapseValues.my {
            let myVal: Double = Double(my)
            if let dateStr = self.synapseDataMaxAndMins.my.dateStr, let max = self.synapseDataMaxAndMins.my.max, let maxNow = self.synapseDataMaxAndMins.my.maxNow, let min = self.synapseDataMaxAndMins.my.min, let minNow = self.synapseDataMaxAndMins.my.minNow {
                let dateNow: String = self.synapseNowDate.substring(to: self.synapseNowDate.index(self.synapseNowDate.startIndex, offsetBy: 12))
                let dateCheck: String = dateStr.substring(to: dateStr.index(dateStr.startIndex, offsetBy: 12))
                if maxNow < myVal {
                    self.synapseDataMaxAndMins.my.maxNow = myVal
                    self.synapseDataMaxAndMins.my.updatedMax = true
                }
                if max < myVal || dateNow != dateCheck {
                    self.synapseDataMaxAndMins.my.max = myVal
                    self.synapseDataMaxAndMins.my.updatedMax = true
                }
                if minNow > myVal {
                    self.synapseDataMaxAndMins.my.minNow = myVal
                    self.synapseDataMaxAndMins.my.updatedMin = true
                }
                if min > myVal || dateNow != dateCheck {
                    self.synapseDataMaxAndMins.my.min = myVal
                    self.synapseDataMaxAndMins.my.updatedMin = true
                }
            }
            else {
                self.synapseDataMaxAndMins.my.maxNow = myVal
                self.synapseDataMaxAndMins.my.max = myVal
                self.synapseDataMaxAndMins.my.minNow = myVal
                self.synapseDataMaxAndMins.my.min = myVal
                self.synapseDataMaxAndMins.my.updatedMax = true
                self.synapseDataMaxAndMins.my.updatedMin = true
            }
            self.synapseDataMaxAndMins.my.dateStr = self.synapseNowDate
        }
        if let mz = synapseValues.mz {
            let mzVal: Double = Double(mz)
            if let dateStr = self.synapseDataMaxAndMins.mz.dateStr, let max = self.synapseDataMaxAndMins.mz.max, let maxNow = self.synapseDataMaxAndMins.mz.maxNow, let min = self.synapseDataMaxAndMins.mz.min, let minNow = self.synapseDataMaxAndMins.mz.minNow {
                let dateNow: String = self.synapseNowDate.substring(to: self.synapseNowDate.index(self.synapseNowDate.startIndex, offsetBy: 12))
                let dateCheck: String = dateStr.substring(to: dateStr.index(dateStr.startIndex, offsetBy: 12))
                if maxNow < mzVal {
                    self.synapseDataMaxAndMins.mz.maxNow = mzVal
                    self.synapseDataMaxAndMins.mz.updatedMax = true
                }
                if max < mzVal || dateNow != dateCheck {
                    self.synapseDataMaxAndMins.mz.max = mzVal
                    self.synapseDataMaxAndMins.mz.updatedMax = true
                }
                if minNow > mzVal {
                    self.synapseDataMaxAndMins.mz.minNow = mzVal
                    self.synapseDataMaxAndMins.mz.updatedMin = true
                }
                if min > mzVal || dateNow != dateCheck {
                    self.synapseDataMaxAndMins.mz.min = mzVal
                    self.synapseDataMaxAndMins.mz.updatedMin = true
                }
            }
            else {
                self.synapseDataMaxAndMins.mz.maxNow = mzVal
                self.synapseDataMaxAndMins.mz.max = mzVal
                self.synapseDataMaxAndMins.mz.minNow = mzVal
                self.synapseDataMaxAndMins.mz.min = mzVal
                self.synapseDataMaxAndMins.mz.updatedMax = true
                self.synapseDataMaxAndMins.mz.updatedMin = true
            }
            self.synapseDataMaxAndMins.mz.dateStr = self.synapseNowDate
        }*/
    }

    func saveSynapseMaxAndMinValues() {

        if self.synapseCrystalInfo.co2.hasGraph {
            if let dateStr = self.synapseDataMaxAndMins.co2.dateStr {
                if let max = self.synapseDataMaxAndMins.co2.max, let updated = self.synapseDataMaxAndMins.co2.updatedMax {
                    if updated {
                        if self.saveSynapseMaxAndMinValue(value: max, date: dateStr, type: self.synapseCrystalInfo.co2.key, valueType: "max") {
                            self.synapseDataMaxAndMins.co2.updatedMax = false
                        }
                    }
                }
                if let min = self.synapseDataMaxAndMins.co2.min, let updated = self.synapseDataMaxAndMins.co2.updatedMin {
                    if updated {
                        if self.saveSynapseMaxAndMinValue(value: min, date: dateStr, type: self.synapseCrystalInfo.co2.key, valueType: "min") {
                            self.synapseDataMaxAndMins.co2.updatedMin = false
                        }
                    }
                }
            }
        }
        if self.synapseCrystalInfo.move.hasGraph {
            if let dateStr = self.synapseDataMaxAndMins.ax.dateStr {
                if let max = self.synapseDataMaxAndMins.ax.max, let updated = self.synapseDataMaxAndMins.ax.updatedMax {
                    if updated {
                        if self.saveSynapseMaxAndMinValue(value: max, date: dateStr, type: "ax", valueType: "max") {
                            self.synapseDataMaxAndMins.ax.updatedMax = false
                        }
                    }
                }
                if let min = self.synapseDataMaxAndMins.ax.min, let updated = self.synapseDataMaxAndMins.ax.updatedMin {
                    if updated {
                        if self.saveSynapseMaxAndMinValue(value: min, date: dateStr, type: "ax", valueType: "min") {
                            self.synapseDataMaxAndMins.ax.updatedMin = false
                        }
                    }
                }
            }
            if let dateStr = self.synapseDataMaxAndMins.ay.dateStr {
                if let max = self.synapseDataMaxAndMins.ay.max, let updated = self.synapseDataMaxAndMins.ay.updatedMax {
                    if updated {
                        if self.saveSynapseMaxAndMinValue(value: max, date: dateStr, type: "ay", valueType: "max") {
                            self.synapseDataMaxAndMins.ay.updatedMax = false
                        }
                    }
                }
                if let min = self.synapseDataMaxAndMins.ay.min, let updated = self.synapseDataMaxAndMins.ay.updatedMin {
                    if updated {
                        if self.saveSynapseMaxAndMinValue(value: min, date: dateStr, type: "ay", valueType: "min") {
                            self.synapseDataMaxAndMins.ay.updatedMin = false
                        }
                    }
                }
            }
            if let dateStr = self.synapseDataMaxAndMins.az.dateStr {
                if let max = self.synapseDataMaxAndMins.az.max, let updated = self.synapseDataMaxAndMins.az.updatedMax {
                    if updated {
                        if self.saveSynapseMaxAndMinValue(value: max, date: dateStr, type: "az", valueType: "max") {
                            self.synapseDataMaxAndMins.az.updatedMax = false
                        }
                    }
                }
                if let min = self.synapseDataMaxAndMins.az.min, let updated = self.synapseDataMaxAndMins.az.updatedMin {
                    if updated {
                        if self.saveSynapseMaxAndMinValue(value: min, date: dateStr, type: "az", valueType: "min") {
                            self.synapseDataMaxAndMins.az.updatedMin = false
                        }
                    }
                }
            }
        }
        if self.synapseCrystalInfo.ill.hasGraph {
            if let dateStr = self.synapseDataMaxAndMins.light.dateStr {
                if let max = self.synapseDataMaxAndMins.light.max, let updated = self.synapseDataMaxAndMins.light.updatedMax {
                    if updated {
                        if self.saveSynapseMaxAndMinValue(value: max, date: dateStr, type: self.synapseCrystalInfo.ill.key, valueType: "max") {
                            self.synapseDataMaxAndMins.light.updatedMax = false
                        }
                    }
                }
                if let min = self.synapseDataMaxAndMins.light.min, let updated = self.synapseDataMaxAndMins.light.updatedMin {
                    if updated {
                        if self.saveSynapseMaxAndMinValue(value: min, date: dateStr, type: self.synapseCrystalInfo.ill.key, valueType: "min") {
                            self.synapseDataMaxAndMins.light.updatedMin = false
                        }
                    }
                }
            }
        }
        if self.synapseCrystalInfo.angle.hasGraph {
            if let dateStr = self.synapseDataMaxAndMins.gx.dateStr {
                if let max = self.synapseDataMaxAndMins.gx.max, let updated = self.synapseDataMaxAndMins.gx.updatedMax {
                    if updated {
                        if self.saveSynapseMaxAndMinValue(value: max, date: dateStr, type: "gx", valueType: "max") {
                            self.synapseDataMaxAndMins.gx.updatedMax = false
                        }
                    }
                }
                if let min = self.synapseDataMaxAndMins.gx.min, let updated = self.synapseDataMaxAndMins.gx.updatedMin {
                    if updated {
                        if self.saveSynapseMaxAndMinValue(value: min, date: dateStr, type: "gx", valueType: "min") {
                            self.synapseDataMaxAndMins.gx.updatedMin = false
                        }
                    }
                }
            }
            if let dateStr = self.synapseDataMaxAndMins.gy.dateStr {
                if let max = self.synapseDataMaxAndMins.gy.max, let updated = self.synapseDataMaxAndMins.gy.updatedMax {
                    if updated {
                        if self.saveSynapseMaxAndMinValue(value: max, date: dateStr, type: "gy", valueType: "max") {
                            self.synapseDataMaxAndMins.gy.updatedMax = false
                        }
                    }
                }
                if let min = self.synapseDataMaxAndMins.gy.min, let updated = self.synapseDataMaxAndMins.gy.updatedMin {
                    if updated {
                        if self.saveSynapseMaxAndMinValue(value: min, date: dateStr, type: "gy", valueType: "min") {
                            self.synapseDataMaxAndMins.gy.updatedMin = false
                        }
                    }
                }
            }
            if let dateStr = self.synapseDataMaxAndMins.gz.dateStr {
                if let max = self.synapseDataMaxAndMins.gz.max, let updated = self.synapseDataMaxAndMins.gz.updatedMax {
                    if updated {
                        if self.saveSynapseMaxAndMinValue(value: max, date: dateStr, type: "gz", valueType: "max") {
                            self.synapseDataMaxAndMins.gz.updatedMax = false
                        }
                    }
                }
                if let min = self.synapseDataMaxAndMins.gz.min, let updated = self.synapseDataMaxAndMins.gz.updatedMin {
                    if updated {
                        if self.saveSynapseMaxAndMinValue(value: min, date: dateStr, type: "gz", valueType: "min") {
                            self.synapseDataMaxAndMins.gz.updatedMin = false
                        }
                    }
                }
            }
        }
        if self.synapseCrystalInfo.temp.hasGraph {
            if let dateStr = self.synapseDataMaxAndMins.temp.dateStr {
                if let max = self.synapseDataMaxAndMins.temp.max, let updated = self.synapseDataMaxAndMins.temp.updatedMax {
                    if updated {
                        if self.saveSynapseMaxAndMinValue(value: max, date: dateStr, type: self.synapseCrystalInfo.temp.key, valueType: "max") {
                            self.synapseDataMaxAndMins.temp.updatedMax = false
                        }
                    }
                }
                if let min = self.synapseDataMaxAndMins.temp.min, let updated = self.synapseDataMaxAndMins.temp.updatedMin {
                    if updated {
                        if self.saveSynapseMaxAndMinValue(value: min, date: dateStr, type: self.synapseCrystalInfo.temp.key, valueType: "min") {
                            self.synapseDataMaxAndMins.temp.updatedMin = false
                        }
                    }
                }
            }
        }
        if self.synapseCrystalInfo.hum.hasGraph {
            if let dateStr = self.synapseDataMaxAndMins.hum.dateStr {
                if let max = self.synapseDataMaxAndMins.hum.max, let updated = self.synapseDataMaxAndMins.hum.updatedMax {
                    if updated {
                        if self.saveSynapseMaxAndMinValue(value: max, date: dateStr, type: self.synapseCrystalInfo.hum.key, valueType: "max") {
                            self.synapseDataMaxAndMins.hum.updatedMax = false
                        }
                    }
                }
                if let min = self.synapseDataMaxAndMins.hum.min, let updated = self.synapseDataMaxAndMins.hum.updatedMin {
                    if updated {
                        if self.saveSynapseMaxAndMinValue(value: min, date: dateStr, type: self.synapseCrystalInfo.hum.key, valueType: "min") {
                            self.synapseDataMaxAndMins.hum.updatedMin = false
                        }
                    }
                }
            }
        }
        if self.synapseCrystalInfo.press.hasGraph {
            if let dateStr = self.synapseDataMaxAndMins.press.dateStr {
                if let max = self.synapseDataMaxAndMins.press.max, let updated = self.synapseDataMaxAndMins.press.updatedMax {
                    if updated {
                        if self.saveSynapseMaxAndMinValue(value: max, date: dateStr, type: self.synapseCrystalInfo.press.key, valueType: "max") {
                            self.synapseDataMaxAndMins.press.updatedMax = false
                        }
                    }
                }
                if let min = self.synapseDataMaxAndMins.press.min, let updated = self.synapseDataMaxAndMins.press.updatedMin {
                    if updated {
                        if self.saveSynapseMaxAndMinValue(value: min, date: dateStr, type: self.synapseCrystalInfo.press.key, valueType: "min") {
                            self.synapseDataMaxAndMins.press.updatedMin = false
                        }
                    }
                }
            }
        }
        if self.synapseCrystalInfo.sound.hasGraph {
            if let dateStr = self.synapseDataMaxAndMins.sound.dateStr {
                if let max = self.synapseDataMaxAndMins.sound.max, let updated = self.synapseDataMaxAndMins.sound.updatedMax {
                    if updated {
                        if self.saveSynapseMaxAndMinValue(value: max, date: dateStr, type: self.synapseCrystalInfo.sound.key, valueType: "max") {
                            self.synapseDataMaxAndMins.sound.updatedMax = false
                        }
                    }
                }
                if let min = self.synapseDataMaxAndMins.sound.min, let updated = self.synapseDataMaxAndMins.sound.updatedMin {
                    if updated {
                        if self.saveSynapseMaxAndMinValue(value: min, date: dateStr, type: self.synapseCrystalInfo.sound.key, valueType: "min") {
                            self.synapseDataMaxAndMins.sound.updatedMin = false
                        }
                    }
                }
            }
        }
        if self.synapseCrystalInfo.volt.hasGraph {
            if let dateStr = self.synapseDataMaxAndMins.volt.dateStr {
                if let max = self.synapseDataMaxAndMins.volt.max, let updated = self.synapseDataMaxAndMins.volt.updatedMax {
                    if updated {
                        if self.saveSynapseMaxAndMinValue(value: max, date: dateStr, type: self.synapseCrystalInfo.volt.key, valueType: "max") {
                            self.synapseDataMaxAndMins.volt.updatedMax = false
                        }
                    }
                }
                if let min = self.synapseDataMaxAndMins.volt.min, let updated = self.synapseDataMaxAndMins.volt.updatedMin {
                    if updated {
                        if self.saveSynapseMaxAndMinValue(value: min, date: dateStr, type: self.synapseCrystalInfo.volt.key, valueType: "min") {
                            self.synapseDataMaxAndMins.volt.updatedMin = false
                        }
                    }
                }
            }
        }
        /*
        if self.synapseCrystalInfo.mag.hasGraph {
            if let dateStr = self.synapseDataMaxAndMins.mx.dateStr {
                if let max = self.synapseDataMaxAndMins.mx.max, let updated = self.synapseDataMaxAndMins.mx.updatedMax {
                    if updated {
                        if self.saveSynapseMaxAndMinValue(value: max, date: dateStr, type: "mx", valueType: "max") {
                            self.synapseDataMaxAndMins.mx.updatedMax = false
                        }
                    }
                }
                if let min = self.synapseDataMaxAndMins.mx.min, let updated = self.synapseDataMaxAndMins.mx.updatedMin {
                    if updated {
                        if self.saveSynapseMaxAndMinValue(value: min, date: dateStr, type: "mx", valueType: "min") {
                            self.synapseDataMaxAndMins.mx.updatedMin = false
                        }
                    }
                }
            }
            if let dateStr = self.synapseDataMaxAndMins.my.dateStr {
                if let max = self.synapseDataMaxAndMins.my.max, let updated = self.synapseDataMaxAndMins.my.updatedMax {
                    if updated {
                        if self.saveSynapseMaxAndMinValue(value: max, date: dateStr, type: "my", valueType: "max") {
                            self.synapseDataMaxAndMins.my.updatedMax = false
                        }
                    }
                }
                if let min = self.synapseDataMaxAndMins.my.min, let updated = self.synapseDataMaxAndMins.my.updatedMin {
                    if updated {
                        if self.saveSynapseMaxAndMinValue(value: min, date: dateStr, type: "my", valueType: "min") {
                            self.synapseDataMaxAndMins.my.updatedMin = false
                        }
                    }
                }
            }
            if let dateStr = self.synapseDataMaxAndMins.mz.dateStr {
                if let max = self.synapseDataMaxAndMins.mz.max, let updated = self.synapseDataMaxAndMins.mz.updatedMax {
                    if updated {
                        if self.saveSynapseMaxAndMinValue(value: max, date: dateStr, type: "mz", valueType: "max") {
                            self.synapseDataMaxAndMins.mz.updatedMax = false
                        }
                    }
                }
                if let min = self.synapseDataMaxAndMins.mz.min, let updated = self.synapseDataMaxAndMins.mz.updatedMin {
                    if updated {
                        if self.saveSynapseMaxAndMinValue(value: min, date: dateStr, type: "mz", valueType: "min") {
                            self.synapseDataMaxAndMins.mz.updatedMin = false
                        }
                    }
                }
            }
        }*/
    }

    func saveSynapseMaxAndMinValue(value: Double, date: String, type: String, valueType: String) -> Bool {

        var res: Bool = false
        if date.count >= 14, let synapseRecordFileManager = self.synapseRecordFileManager {
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
            }
        }
        return res
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

        let settingFileManager: SettingFileManager = SettingFileManager()
        if let flag = settingFileManager.getSettingData(settingFileManager.synapseSendFlagKey) as? Bool, let url = settingFileManager.getSettingData(settingFileManager.synapseSendURLKey) as? String, flag, url.count > 0 {
            self.startSynapseSendData(url: url)
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
    /*
     var mx: Int?
     var my: Int?
     var mz: Int?*/
    var axBak: Int?
    var ayBak: Int?
    var azBak: Int?
    var gxBak: Int?
    var gyBak: Int?
    var gzBak: Int?
    var isConnected: Bool = false

    init(_ name: String) {

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
        /*
         self.mx = nil
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
}

class SynapseCrystalNodes {

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
    /*
     var magneticXNode: SCNNode?
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

    init(_ name: String, position: SCNVector3, isDisplay: Bool) {

        self.name = name
        self.position = position
        self.isDisplay = isDisplay
    }
}

class SynapseValueLabels {

    var valueLabel: UILabel?
    var unitLabel: UILabel?
    var diffLabel: UILabel?
}

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
    /*
     var magxLabels: SynapseValueLabels = SynapseValueLabels()
     var magyLabels: SynapseValueLabels = SynapseValueLabels()
     var magzLabels: SynapseValueLabels = SynapseValueLabels()*/
}

class SynapseDataMaxAndMin {

    var maxNow: Double?
    var minNow: Double?
    var max: Double?
    var min: Double?
    var updatedMax: Bool?
    var updatedMin: Bool?
    var dateStr: String?
}

class AllSynapseDataMaxAndMins {

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
    /*
     var mx: SynapseDataMaxAndMin = SynapseDataMaxAndMin()
     var my: SynapseDataMaxAndMin = SynapseDataMaxAndMin()
     var mz: SynapseDataMaxAndMin = SynapseDataMaxAndMin()*/
}

class SynapseNotification {

    var value: Double?
    var isSend: Bool?
}

class AllSynapseNotifications {

    var co2: SynapseNotification = SynapseNotification()
}

class DebugView {

    var debugAreaView: UIView?
    var data0Label: UILabel?
    var data1Label: UILabel?
    var data2Label: UILabel?
    var data3Label: UILabel?
    var data4Label: UILabel?
    var data5Label: UILabel?
    var data6Label: UILabel?
    var data7Label: UILabel?
    var data8Label: UILabel?
    var data9Label: UILabel?
    var data10Label: UILabel?
    var data11Label: UILabel?
    var data12Label: UILabel?
    var data13Label: UILabel?
    var data14Label: UILabel?
    var data15Label: UILabel?
    var data16Label: UILabel?
    var data17Label: UILabel?
}
