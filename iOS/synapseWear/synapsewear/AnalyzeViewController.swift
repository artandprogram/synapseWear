//
//  AnalyzeViewController.swift
//  synapsewear
//
//  Copyright © 2017年 art and program, Inc. For license and other information refer to https://github.com/artandprogram/synapseWear. All rights reserved.
//

import UIKit

class AnalyzeViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, CommonFunctionProtocol {

    // const
    let timeRangeMin: TimeInterval = 5.0 * 60.0
    let timeRangeMax: TimeInterval = 30.0 * 24.0 * 60.0 * 60.0
    let timeRangeInterval: Int = 5
    let graphSpace: CGFloat = 10.0
    let graphSpaceR: CGFloat = 20.0
    let graphCirclePointW: CGFloat = 3.0
    let synapseCrystalInfo: SynapseCrystalStruct = SynapseCrystalStruct()
    let dayFormatter: DateFormatter = DateFormatter()
    let hourFormatter: DateFormatter = DateFormatter()
    let minFormatter: DateFormatter = DateFormatter()
    let secFormatter: DateFormatter = DateFormatter()
    // variables
    var synapseRecordFileManager: SynapseRecordFileManager?
    var synapseUUID: UUID?
    var graphDates: [Date] = []
    var graphCategories: [CrystalStruct] = []
    var graphDataList: [String: [Double?]] = [:]
    var graphMaxList: [String: Double] = [:]
    var graphMinList: [String: Double] = [:]
    var graphDisplays: [String: Bool] = [:]
    var changeGraphTimer: Timer?
    //var changeGraphTimerCnt: Int = 0
    var timeRange: TimeInterval = 1.0
    var baseDate: Date? = nil
    var startDate: Date? = nil
    var endDate: Date? = nil
    var graphX: CGFloat = 0
    var graphY: CGFloat = 0
    var graphW: CGFloat = 0
    var graphH: CGFloat = 0
    var graphBlock: CGFloat = 1.0
    var graphCnt: Int = 0
    var graphSelectpt: Int = -1
    var graphValues: [CrystalStruct] = []
    var graphMaxValues: [String: Double] = [:]
    var graphMinValues: [String: Double] = [:]
    var graphDataViewParts: [String: [UIView]] = [:]
    var graphMaxRanges: [String: Double] = [:]
    var graphMinRanges: [String: Double] = [:]
    var graphRangeDefault: [String: [String: Double]] = [:]
    var graphRangeViewParts: [String: [String: UILabel]]? = nil
    var graphRangeLongPressTimer: Timer? = nil
    var graphRangeLongPressPt: Int? = nil
    var graphRangeLongPressCnt: Int = 0
    // audio variables
    var isSoundPlay: Bool = false
    var synapseSound: SynapseSound?
    var synapseSoundTimer: Timer?
    var synapseSoundStartDate: Date?
    var synapseSoundValues: SynapseValues?
    var synapseSoundPt: Int?
    // realtime variables
    let realtimeGraphTimeIntervalKeys: [String] = [
        "1m",
        "5m",
        "1h",
        "6h",
        "12h",
        "24h",
    ]
    let realtimeGraphTimeIntervalValues: [String: [String: TimeInterval]] = [
        "1m": ["interval": 0.2, "range": 1.0],
        "5m": ["interval": 1.0, "range": 10.0],
        "1h": ["interval": 10.0, "range": 60.0],
        "6h": ["interval": 60.0, "range": 600.0],
        "12h": ["interval": 120.0, "range": 600.0],
        "24h": ["interval": 300.0, "range": 3600.0],
    ]
    var isRealtime: Bool = false
    var realtimeGraphTimer: Timer?
    var realtimeGraphTimeIntervals: [String] = []
    var realtimeGraphTimeIntervalKey: String = ""
    var realtimeGraphTimeInterval: TimeInterval = 1.0
    var realtimeGraphLastTime: TimeInterval?
    var realtimeGraphBlock: CGFloat = 1.0
    // views
    var baseView: UIView!
    var selectLineView: UIView!
    var realtimeModeLabel: UILabel!
    var startLabel: UILabel!
    var endLabel: UILabel!
    var dateStartLabel: UILabel!
    var dateEndLabel: UILabel!
    var dateStartArrow: ArrowView!
    var dateEndArrow: ArrowView!
    var dateStartButton: UIButton!
    var dateEndButton: UIButton!
    var graphRealtimeButton: UIButton!
    var graphPeriodButton: UIButton!
    var realtimeUnitLabel: UILabel!
    var realtimeUnitArrow: ArrowView!
    var realtimeUnitButton: UIButton!
    var graphPickerView: UIView?
    var graphDatePicker: UIDatePicker?
    var graphPickerCancelBtn: UIButton?
    var graphRealtimePicker: UIPickerView?
    var graphMusicButton: UIButton!
    var displaySettingButton: UIButton!
    var displaySettingView: UIView?
    var graphDataSmallView: UIView!
    var graphDataSmallCloseButton: UIButton!
    var graphDataSmallOpenButton: UIButton!
    var graphDataSmallDateLabel: UILabel!
    var graphDataView: UIView?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.changeGraphData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.appearNavigationArea()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if self.isSoundPlay {
            self.stopAudio()
        }

        self.realtimeGraphTimer?.invalidate()
        self.realtimeGraphTimer = nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func setParam() {
        super.setParam()

        if let uuid = self.synapseUUID {
            self.synapseRecordFileManager = SynapseRecordFileManager()
            self.synapseRecordFileManager?.setSynapseId(uuid.uuidString)
        }
        /*var synapseId: String = ""
        if let id = SettingFileManager().getSettingData(SettingFileManager().synapseIDKey) as? String {
            synapseId = id
        }
        self.synapseRecordFileManager.setSynapseId(synapseId)*/

        if self.synapseCrystalInfo.co2.hasGraph {
            self.graphCategories.append(self.synapseCrystalInfo.co2)
            self.graphDisplays[self.synapseCrystalInfo.co2.key] = true
        }
        if self.synapseCrystalInfo.temp.hasGraph {
            self.graphCategories.append(self.synapseCrystalInfo.temp)
            self.graphDisplays[self.synapseCrystalInfo.temp.key] = true
        }
        if self.synapseCrystalInfo.hum.hasGraph {
            self.graphCategories.append(self.synapseCrystalInfo.hum)
            self.graphDisplays[self.synapseCrystalInfo.hum.key] = true
        }
        if self.synapseCrystalInfo.ill.hasGraph {
            self.graphCategories.append(self.synapseCrystalInfo.ill)
            self.graphDisplays[self.synapseCrystalInfo.ill.key] = true
        }
        if self.synapseCrystalInfo.press.hasGraph {
            self.graphCategories.append(self.synapseCrystalInfo.press)
            self.graphDisplays[self.synapseCrystalInfo.press.key] = true
        }
        if self.synapseCrystalInfo.sound.hasGraph {
            self.graphCategories.append(self.synapseCrystalInfo.sound)
            self.graphDisplays[self.synapseCrystalInfo.sound.key] = true
        }
        if self.synapseCrystalInfo.volt.hasGraph {
            self.graphCategories.append(self.synapseCrystalInfo.volt)
            self.graphDisplays[self.synapseCrystalInfo.volt.key] = true
        }
        /*//self.synapseCrystalInfo.mag.hasGraph = false
        if self.synapseCrystalInfo.mag.hasGraph {
            self.graphCategories.append(self.synapseCrystalInfo.mag)
            self.graphDisplays[self.synapseCrystalInfo.mag.key] = true
        }*/
        if self.synapseCrystalInfo.move.hasGraph {
            self.graphCategories.append(self.synapseCrystalInfo.move)
            self.graphDisplays[self.synapseCrystalInfo.move.key] = true
        }
        if self.synapseCrystalInfo.angle.hasGraph {
            self.graphCategories.append(self.synapseCrystalInfo.angle)
            self.graphDisplays[self.synapseCrystalInfo.angle.key] = true
        }

        self.graphRangeDefault = [
            self.synapseCrystalInfo.co2.key: [
                "min": 400.0,
                "max": 10000.0,
                "interval": 10.0,
            ],
            self.synapseCrystalInfo.temp.key: [
                "min": 0,
                "max": 100.0,
                "interval": 1.0,
            ],
            self.synapseCrystalInfo.hum.key: [
                "min": 0,
                "max": 100.0,
                "interval": 1.0,
            ],
            self.synapseCrystalInfo.ill.key: [
                "min": 0,
                "max": 65540.0,
                //"max": 65535.0,
                "interval": 10.0,
            ],
            self.synapseCrystalInfo.press.key: [
                "min": 0,
                "max": 2000.0,
                "interval": 10.0,
            ],
            self.synapseCrystalInfo.sound.key: [
                "min": 0,
                "max": 1030.0,
                //"max": 1023.0,
                "interval": 10.0,
            ],
            self.synapseCrystalInfo.volt.key: [
                "min": 0,
                "max": 10.0,
                "interval": 0.1,
            ],
        ]

        self.dayFormatter.locale = Locale(identifier: "en_US_POSIX")
        self.dayFormatter.dateFormat = "yyyyMMdd"
        self.hourFormatter.locale = Locale(identifier: "en_US_POSIX")
        self.hourFormatter.dateFormat = "HH"
        self.minFormatter.locale = Locale(identifier: "en_US_POSIX")
        self.minFormatter.dateFormat = "mm"
        self.secFormatter.locale = Locale(identifier: "en_US_POSIX")
        self.secFormatter.dateFormat = "ss"

        for key in self.realtimeGraphTimeIntervalKeys {
            if let values = self.realtimeGraphTimeIntervalValues[key], let interval = values["interval"], let nav = self.navigationController as? NavigationController {
                if interval >= nav.topVC.synapseTimeInterval {
                    self.realtimeGraphTimeIntervals.append(key)
                }
            }
        }
        if self.realtimeGraphTimeIntervals.count > 0 {
            self.realtimeGraphTimeIntervalKey = self.realtimeGraphTimeIntervals[0]
            if let values = self.realtimeGraphTimeIntervalValues[self.realtimeGraphTimeIntervalKey], let interval = values["interval"] {
                self.realtimeGraphTimeInterval = interval
            }
            else {
                self.realtimeGraphTimeIntervalKey = ""
            }
        }

        self.setNotificationCenter()
    }

    func setNotificationCenter() {

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(viewWillEnterForeground(
            notification:)),
                                               name: Notification.Name.UIApplicationWillEnterForeground,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(viewDidEnterBackground(
            notification:)),
                                               name: Notification.Name.UIApplicationDidEnterBackground,
                                               object: nil)
    }

    override func setView() {
        super.setView()

        let colorS: UIColor = UIColor(red:  93/255.0, green: 23/255.0, blue: 135/255.0, alpha: 1)
        let colorE: UIColor = UIColor(red: 228/255.0, green:  9/255.0, blue: 102/255.0, alpha: 1)
        let bgLayer: CAGradientLayer = CAGradientLayer()
        bgLayer.colors = [colorS.cgColor, colorE.cgColor]
        bgLayer.startPoint = CGPoint(x: 0, y: 0)
        bgLayer.endPoint = CGPoint(x: 1, y: 1)
        bgLayer.frame = self.view.frame
        self.view.layer.addSublayer(bgLayer)

        var x: CGFloat = 10.0
        var y: CGFloat = 0
        var w: CGFloat = (self.view.frame.size.width - x * 3) / 2
        var h: CGFloat = 20.0
        if let nav = self.navigationController as? NavigationController {
            y = nav.headerView.frame.origin.y + nav.headerView.frame.size.height
        }
        self.startLabel = UILabel()
        self.startLabel.frame = CGRect(x: x, y: y, width: w, height: h)
        self.startLabel.text = "START"
        self.startLabel.textColor = UIColor.white
        self.startLabel.backgroundColor = UIColor.clear
        self.startLabel.font = UIFont(name: "HelveticaNeue", size: 14.0)
        self.startLabel.textAlignment = .left
        self.startLabel.numberOfLines = 1
        self.startLabel.alpha = 0.5
        self.view.addSubview(self.startLabel)

        self.dateStartLabel = UILabel()
        self.dateStartLabel.frame = CGRect(x: x, y: y + h, width: w, height: h)
        self.dateStartLabel.text = ""
        self.dateStartLabel.textColor = UIColor.white
        self.dateStartLabel.backgroundColor = UIColor.clear
        self.dateStartLabel.font = UIFont(name: "HelveticaNeue", size: 16.0)
        self.dateStartLabel.textAlignment = .left
        self.dateStartLabel.numberOfLines = 1
        self.view.addSubview(self.dateStartLabel)

        self.dateStartArrow = ArrowView()
        self.dateStartArrow.frame = CGRect(x: x + w - 8.0,
                                           y: y + h + (h - 4.0) / 2,
                                           width: 8.0,
                                           height: 4.0)
        self.dateStartArrow.backgroundColor = UIColor.clear
        self.dateStartArrow.triangleColor = UIColor.white
        self.dateStartArrow.alpha = 0.8
        self.view.addSubview(self.dateStartArrow)

        self.dateStartButton = UIButton()
        self.dateStartButton.tag = 1
        self.dateStartButton.frame = CGRect(x: x, y: y, width: w, height: h * 2)
        self.dateStartButton.backgroundColor = UIColor.clear
        self.dateStartButton.addTarget(self, action: #selector(self.displayGraphDatePicker(_:)), for: .touchUpInside)
        self.view.addSubview(self.dateStartButton)

        x += x + w
        self.endLabel = UILabel()
        self.endLabel.frame = CGRect(x: x, y: y, width: w, height: h)
        self.endLabel.text = "END"
        self.endLabel.textColor = UIColor.white
        self.endLabel.backgroundColor = UIColor.clear
        self.endLabel.font = UIFont(name: "HelveticaNeue", size: 14.0)
        self.endLabel.textAlignment = .left
        self.endLabel.numberOfLines = 1
        self.endLabel.alpha = 0.5
        self.view.addSubview(endLabel)

        self.dateEndLabel = UILabel()
        self.dateEndLabel.frame = CGRect(x: x, y: y + h, width: w, height: h)
        self.dateEndLabel.text = ""
        self.dateEndLabel.textColor = UIColor.white
        self.dateEndLabel.backgroundColor = UIColor.clear
        self.dateEndLabel.font = UIFont(name: "HelveticaNeue", size: 16.0)
        self.dateEndLabel.textAlignment = .left
        self.dateEndLabel.numberOfLines = 1
        self.view.addSubview(self.dateEndLabel)

        self.dateEndArrow = ArrowView()
        self.dateEndArrow.frame = CGRect(x: x + w - 8.0,
                                         y: y + h + (h - 4.0) / 2,
                                         width: 8.0,
                                         height: 4.0)
        self.dateEndArrow.backgroundColor = UIColor.clear
        self.dateEndArrow.triangleColor = UIColor.white
        self.dateEndArrow.alpha = 0.8
        self.view.addSubview(self.dateEndArrow)

        self.dateEndButton = UIButton()
        self.dateEndButton.tag = 2
        self.dateEndButton.frame = CGRect(x: x, y: y, width: w, height: h * 2)
        self.dateEndButton.backgroundColor = UIColor.clear
        self.dateEndButton.addTarget(self, action: #selector(self.displayGraphDatePicker(_:)), for: .touchUpInside)
        self.view.addSubview(self.dateEndButton)

        x = 10.0
        y = self.dateStartLabel.frame.origin.y
        w = self.view.frame.size.width - x * 2
        h = self.dateStartLabel.frame.size.height
        self.realtimeModeLabel = UILabel()
        self.realtimeModeLabel.frame = CGRect(x: x, y: y, width: w, height: h)
        self.realtimeModeLabel.text = "Realtime Mode"
        self.realtimeModeLabel.textColor = UIColor.white
        self.realtimeModeLabel.backgroundColor = UIColor.clear
        self.realtimeModeLabel.font = UIFont(name: "HelveticaNeue", size: 16.0)
        self.realtimeModeLabel.textAlignment = .center
        self.realtimeModeLabel.numberOfLines = 1
        self.view.addSubview(self.realtimeModeLabel)

        w = 44.0
        h = 44.0
        x = (self.view.frame.size.width / 2 - w) / 2
        y = self.view.frame.size.height - h
        self.graphMusicButton = UIButton()
        self.graphMusicButton.frame = CGRect(x: x, y: y, width: w, height: h)
        self.graphMusicButton.backgroundColor = UIColor.clear
        self.graphMusicButton.addTarget(self, action: #selector(self.changeAudioStatus), for: .touchUpInside)
        self.view.addSubview(self.graphMusicButton)

        let icon1: UIImageView = UIImageView()
        icon1.frame = CGRect(x: (self.graphMusicButton.frame.size.width - 24.0) / 2,
                             y: (self.graphMusicButton.frame.size.height - 24.0) / 2,
                             width: 24.0,
                             height: 24.0)
        icon1.image = UIImage(named: "music.png")
        icon1.backgroundColor = UIColor.clear
        self.graphMusicButton.addSubview(icon1)

        x = self.view.frame.size.width / 2 + (self.view.frame.size.width / 2 - w) / 2
        self.displaySettingButton = UIButton()
        self.displaySettingButton.frame = CGRect(x: x, y: y, width: w, height: h)
        self.displaySettingButton.backgroundColor = UIColor.clear
        self.displaySettingButton.addTarget(self, action: #selector(self.setDisplaySettingView), for: .touchUpInside)
        self.view.addSubview(self.displaySettingButton)

        let icon2: UIImageView = UIImageView()
        icon2.frame = CGRect(x: (self.displaySettingButton.frame.size.width - 24.0) / 2,
                             y: (self.displaySettingButton.frame.size.height - 24.0) / 2,
                             width: 24.0,
                             height: 24.0)
        icon2.image = UIImage(named: "graph.png")
        icon2.backgroundColor = UIColor.clear
        self.displaySettingButton.addSubview(icon2)

        x = 0
        y = self.dateStartLabel.frame.origin.y + self.dateStartLabel.frame.size.height + 20.0
        w = self.view.frame.size.width
        h = self.displaySettingButton.frame.origin.y - y
        self.baseView = UIView()
        self.baseView.frame = CGRect(x: x, y: y, width: w, height: h)
        self.baseView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        self.view.addSubview(self.baseView)

        w = 1.0
        h = self.baseView.frame.size.height
        x = -w
        y = self.baseView.frame.origin.y
        self.selectLineView = UIView()
        self.selectLineView.frame = CGRect(x: x, y: y, width: w, height: h)
        self.selectLineView.backgroundColor = UIColor.fluorescentPink
        self.selectLineView.isHidden = true
        self.view.addSubview(self.selectLineView)

        x = 10.0
        y = self.baseView.frame.origin.y + 10.0
        w = 74.0
        h = 26.0
        self.graphRealtimeButton = UIButton()
        self.graphRealtimeButton.frame = CGRect(x: x, y: y, width: w, height: h)
        self.graphRealtimeButton.setTitle("Realtime", for: .normal)
        self.graphRealtimeButton.setTitleColor(UIColor.white, for: .normal)
        self.graphRealtimeButton.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 14.0)
        self.graphRealtimeButton.backgroundColor = UIColor.clear
        self.graphRealtimeButton.layer.borderColor = UIColor.white.cgColor
        self.graphRealtimeButton.layer.borderWidth = 1.0
        self.graphRealtimeButton.addTarget(self, action: #selector(self.changeGraphModeAction(_:)), for: .touchUpInside)
        self.view.addSubview(self.graphRealtimeButton)

        x += w - 1.0
        self.graphPeriodButton = UIButton()
        self.graphPeriodButton.frame = CGRect(x: x, y: y, width: w, height: h)
        self.graphPeriodButton.setTitle("Period", for: .normal)
        self.graphPeriodButton.setTitleColor(UIColor.white, for: .normal)
        self.graphPeriodButton.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 14.0)
        self.graphPeriodButton.backgroundColor = UIColor.clear
        self.graphPeriodButton.layer.borderColor = UIColor.white.cgColor
        self.graphPeriodButton.layer.borderWidth = 1.0
        self.graphPeriodButton.addTarget(self, action: #selector(self.changeGraphModeAction(_:)), for: .touchUpInside)
        self.view.addSubview(self.graphPeriodButton)

        x = self.view.frame.size.width - (10.0 * 2 + 8.0)
        y = self.graphRealtimeButton.frame.origin.y
        w = 0.0
        h = 18.0
        self.realtimeUnitLabel = UILabel()
        self.realtimeUnitLabel.frame = CGRect(x: x, y: y, width: w, height: h)
        self.realtimeUnitLabel.text = ""
        self.realtimeUnitLabel.textColor = UIColor.white
        self.realtimeUnitLabel.backgroundColor = UIColor.clear
        self.realtimeUnitLabel.font = UIFont(name: "HelveticaNeue", size: 14.0)
        self.realtimeUnitLabel.textAlignment = .left
        self.realtimeUnitLabel.numberOfLines = 1
        self.view.addSubview(self.realtimeUnitLabel)

        x = self.view.frame.size.width - (10.0 + 8.0)
        y += (h - 4.0) / 2
        w = 8.0
        h = 4.0
        self.realtimeUnitArrow = ArrowView()
        self.realtimeUnitArrow.frame = CGRect(x: x, y: y, width: w, height: h)
        self.realtimeUnitArrow.backgroundColor = UIColor.clear
        self.realtimeUnitArrow.triangleColor = UIColor.white
        self.realtimeUnitArrow.alpha = 0.8
        self.view.addSubview(self.realtimeUnitArrow)

        x = self.realtimeUnitLabel.frame.origin.x
        y = self.realtimeUnitLabel.frame.origin.y
        w = self.view.frame.size.width - x
        h = self.realtimeUnitLabel.frame.size.height
        self.realtimeUnitButton = UIButton()
        self.realtimeUnitButton.tag = 0
        self.realtimeUnitButton.frame = CGRect(x: x, y: y, width: w, height: h)
        self.realtimeUnitButton.backgroundColor = UIColor.clear
        self.realtimeUnitButton.addTarget(self, action: #selector(self.displayGraphDatePicker(_:)), for: .touchUpInside)
        self.view.addSubview(self.realtimeUnitButton)

        self.setGraphModeViews()
        self.setGraphDataSmallView()
    }

    func setGraphModeViews() {

        if self.isRealtime {
            self.startLabel.isHidden = true
            self.dateStartLabel.isHidden = true
            self.dateStartArrow.isHidden = true
            self.dateStartButton.isHidden = true
            self.endLabel.isHidden = true
            self.dateEndLabel.isHidden = true
            self.dateEndArrow.isHidden = true
            self.dateEndButton.isHidden = true
            self.realtimeModeLabel.isHidden = false
            self.realtimeUnitLabel.isHidden = false
            self.realtimeUnitArrow.isHidden = false
            self.realtimeUnitButton.isHidden = false
            self.graphRealtimeButton.setTitleColor(UIColor.black, for: .normal)
            self.graphRealtimeButton.backgroundColor = UIColor.white
            self.graphPeriodButton.setTitleColor(UIColor.white, for: .normal)
            self.graphPeriodButton.backgroundColor = UIColor.clear
            self.setRealtimeUnitViews()
        }
        else {
            self.startLabel.isHidden = false
            self.dateStartLabel.isHidden = false
            self.dateStartArrow.isHidden = false
            self.dateStartButton.isHidden = false
            self.endLabel.isHidden = false
            self.dateEndLabel.isHidden = false
            self.dateEndArrow.isHidden = false
            self.dateEndButton.isHidden = false
            self.realtimeModeLabel.isHidden = true
            self.realtimeUnitLabel.isHidden = true
            self.realtimeUnitArrow.isHidden = true
            self.realtimeUnitButton.isHidden = true
            self.graphRealtimeButton.setTitleColor(UIColor.white, for: .normal)
            self.graphRealtimeButton.backgroundColor = UIColor.clear
            self.graphPeriodButton.setTitleColor(UIColor.black, for: .normal)
            self.graphPeriodButton.backgroundColor = UIColor.white
        }
    }

    func setRealtimeUnitViews() {

        self.realtimeUnitLabel.text = "unit: \(self.realtimeGraphTimeIntervalKey)"
        self.realtimeUnitLabel.sizeToFit()

        var x: CGFloat = self.realtimeUnitArrow.frame.origin.x - (self.realtimeUnitLabel.frame.size.width + 10.0)
        let y: CGFloat = self.realtimeUnitLabel.frame.origin.y
        var w: CGFloat = self.realtimeUnitLabel.frame.size.width
        let h: CGFloat = 18.0
        self.realtimeUnitLabel.frame = CGRect(x: x, y: y, width: w, height: h)

        x = self.realtimeUnitLabel.frame.origin.x
        w = self.view.frame.size.width - x
        self.realtimeUnitButton.frame = CGRect(x: x, y: y, width: w, height: h)
    }

    func appearNavigationArea() {

        if let nav = self.navigationController as? NavigationController {
            nav.headerTitle.text = "Analyze"
            nav.setHeaderColor(isWhite: true)
            nav.headerSettingBtn.isHidden = true
        }
    }

    // MARK: mark - GraphData methods

    func changeGraphData() {

        if self.isRealtime {
            self.changeRealtimeGraphDataStart()
        }
        else {
            self.changePeriodGraphDataStart()
        }
    }

    @objc func changeGraphModeAction(_ sender: UIButton) {

        var flag: Bool = false
        if sender == self.graphRealtimeButton {
            if !self.isRealtime {
                flag = true
            }
        }
        else if sender == self.graphPeriodButton {
            if self.isRealtime {
                flag = true
            }
        }
        if flag {
            if self.isRealtime {
                self.realtimeGraphTimer?.invalidate()
                self.realtimeGraphTimer = nil

                self.changeDateRealtimeToPeriod()
            }

            self.isRealtime = !self.isRealtime
            self.setGraphModeViews()
            self.changeGraphData()
        }
    }

    func changeDateRealtimeToPeriod() {

        if let startDate = self.startDate {
            self.startDate = Date(timeIntervalSince1970: floor(startDate.timeIntervalSince1970 / 300) * 300)
        }
        if let endDate = self.endDate {
            self.endDate = Date(timeIntervalSince1970: ceil(endDate.timeIntervalSince1970 / 300) * 300)
            //self.endDate = Date(timeIntervalSince1970: floor(endDate.timeIntervalSince1970 / 300) * 300)
        }
        /*if let startDate = self.startDate, let endDate = self.endDate {
            if endDate.timeIntervalSince(startDate) < 300.0 {
                self.endDate = Date(timeInterval: 300.0, since: startDate)
            }
        }*/
        //print("setGraphDateAction isRealtime: \(self.startDate), \(self.endDate)")
    }

    func changePeriodGraphDataStart() {

        self.isRealtime = false

        self.closeGraphDataSmallView()
        self.setHiddenLoadingView(false)
        
        self.changeGraphTimer = Timer.scheduledTimer(timeInterval: 0.1,
                                                     target: self,
                                                     selector: #selector(self.changePeriodGraphData),
                                                     userInfo: nil,
                                                     repeats: true)
    }

    @objc func changePeriodGraphData() {

        self.changeGraphTimer?.invalidate()
        self.changeGraphTimer = nil

        self.setGraphData()
        self.setGraphViews()
        self.changeGraphIsHiddenAction()
        self.setDateLabels()
        self.setHiddenLoadingView(true)
    }

    func setDateLabels() {

        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy.M.d HH:mm"
        self.dateStartLabel.text = dateFormatter.string(from: self.startDate!)
        self.dateEndLabel.text = dateFormatter.string(from: self.endDate!)

        self.dateStartLabel.sizeToFit()
        var w: CGFloat = self.dateStartButton.frame.size.width
        if w > self.dateStartLabel.frame.size.width {
            w = self.dateStartLabel.frame.size.width
        }
        var h: CGFloat = self.dateStartButton.frame.size.height / 2
        self.dateStartLabel.frame = CGRect(x: self.dateStartLabel.frame.origin.x,
                                           y: self.dateStartLabel.frame.origin.y,
                                           width: w,
                                           height: h)

        var x: CGFloat = w + 8.0
        if x + self.dateStartArrow.frame.size.width > self.dateStartButton.frame.size.width {
            x = self.dateStartButton.frame.size.width - self.dateStartArrow.frame.size.width
        }
        self.dateStartArrow.frame = CGRect(x: x + self.dateStartLabel.frame.origin.x,
                                           y: self.dateStartArrow.frame.origin.y,
                                           width: self.dateStartArrow.frame.size.width,
                                           height: self.dateStartArrow.frame.size.height)

        self.dateEndLabel.sizeToFit()
        w = self.dateEndButton.frame.size.width
        if w > self.dateEndLabel.frame.size.width {
            w = self.dateEndLabel.frame.size.width
        }
        h = self.dateEndButton.frame.size.height / 2
        self.dateEndLabel.frame = CGRect(x: self.dateEndLabel.frame.origin.x,
                                         y: self.dateEndLabel.frame.origin.y,
                                         width: w,
                                         height: h)

        x = w + 8.0
        if x + self.dateEndArrow.frame.size.width > self.dateEndButton.frame.size.width {
            x = self.dateEndButton.frame.size.width - self.dateEndArrow.frame.size.width
        }
        self.dateEndArrow.frame = CGRect(x: x + self.dateEndLabel.frame.origin.x,
                                         y: self.dateEndArrow.frame.origin.y,
                                         width: self.dateEndArrow.frame.size.width,
                                         height: self.dateEndArrow.frame.size.height)

        self.setHiddenLoadingView(true)
    }

    func setGraphData() {

        if self.endDate == nil {
            let now: Date = self.makeGraphDateNow()
            let dateFormatter: DateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.dateFormat = "yyyyMMddHHmm"
            let dateStr: String = dateFormatter.string(from: now)
            dateFormatter.dateFormat = "yyyyMMddHHmmss"
            self.endDate = dateFormatter.date(from: "\(dateStr)00")
        }
        if self.startDate == nil {
            self.startDate = Date(timeInterval: -self.timeRangeMin, since: self.endDate!)
        }

        var hourCnt: Int = 0
        self.timeRange = 10.0
        let time: TimeInterval = self.endDate!.timeIntervalSince(self.startDate!)
        let timePerPixel: Double = time / Double(self.baseView.frame.size.width - self.graphSpaceR)
        //print("setGraphData timePerPixel: \(timePerPixel)")
        if timePerPixel > 10.0 && timePerPixel <= 60.0 {
            self.timeRange = 60.0
        }
        else if timePerPixel > 60.0 && timePerPixel <= 600.0 {
            self.timeRange = 600.0
        }
        else if timePerPixel > 600.0 {
            /*if timePerPixel > 3600.0 {
                self.setGraphDataPerDay()
                return
            }*/
            self.timeRange = 3600.0

            hourCnt = 1
            if timePerPixel > 3600.0 {
                hourCnt = Int(ceil(timePerPixel / 3600.0))
                if hourCnt > 12 {
                    hourCnt = 24
                }
                else if hourCnt > 6 {
                    hourCnt = 12
                }
                else if hourCnt > 3 {
                    hourCnt = 6
                }
            }
        }
        //print("Date: \(String(describing: self.startDate)) - \(String(describing: self.endDate)) Range: \(self.timeRange)")

        self.resetGraphData()

        if self.synapseRecordFileManager == nil {
            return
        }

        /*self.graphBlock = self.view.frame.size.width / CGFloat(self.endDate!.timeIntervalSince(self.startDate!) / self.timeRange)
        if self.timeRange == 3600.0 && hourCnt > 1 {
            self.graphBlock = self.graphBlock * CGFloat(hourCnt)
        }*/
        var date: Date = self.endDate!
        self.graphCnt = 0
        while date >= self.startDate! {
            self.setGraphDataOfDate(date, hourCnt: hourCnt)

            self.graphCnt += 1
            if self.timeRange == 3600.0 && hourCnt > 1 {
                date = Date(timeInterval: -self.timeRange * Double(hourCnt), since: date)
            }
            else {
                date = Date(timeInterval: -self.timeRange, since: date)
            }
        }
        //print("Data: \(self.graphDataList)")
        self.setGraphRanges()

        if self.timeRange == 3600.0 && hourCnt > 1 {
            self.timeRange = self.timeRange * Double(hourCnt)
        }
    }

    func setGraphDataOfDate(_ date: Date, hourCnt: Int = 0, position: Int = -1, isRealtime: Bool = false) {

        if position >= 0 {
            if position < graphDates.count {
                self.graphDates[position] = date
            }
            else {
                self.graphDates.append(date)
            }
        }
        else {
            self.graphDates.insert(date, at: 0)
        }

        let day: String = self.dayFormatter.string(from: date)
        let hour: String = self.hourFormatter.string(from: date)
        let min: String = self.minFormatter.string(from: date)
        let sec: String = self.secFormatter.string(from: date)
        //print("setGraphData: date -> \(day)\(hour)\(min)\(sec) timeRange -> \(self.timeRange) isRealtime -> \(isRealtime)")
        for (_, element) in self.graphCategories.enumerated() {
            let key: String = element.key
            var values: [String: Double?] = [:]
            if isRealtime {
                values = self.getRealtimeGraphValues(key: key)
                //print(" isRealtime -> \(values)")
            }
            else {
                values = self.getGraphValues(key: key, timeRange: self.timeRange, day: day, hour: hour, min: min, sec: sec, date: date, hourCnt: hourCnt)
                //print(" notRealtime -> \(values)")
            }
            var value: Double? = nil
            if let val = values["value"] {
                value = val
            }
            var minVal: Double? = nil
            if let val = values["minVal"] {
                minVal = val
            }
            var maxVal: Double? = nil
            if let val = values["maxVal"] {
                maxVal = val
            }
            //print("setGraphData: \(key) -> \(value), \(minVal), \(maxVal)")
            if position >= 0 {
                if let graphDataListOfKey = self.graphDataList[key], position < graphDataListOfKey.count {
                    self.graphDataList[key]?[position] = value
                }
                else {
                    //print("setGraphData: \(key) -> \(value)")
                    self.graphDataList[key]?.append(value)
                }
            }
            else {
                self.graphDataList[key]?.insert(value, at: 0)
            }

            if let value = value {
                if let max = self.graphMaxList[key] {
                    if max < value {
                        self.graphMaxList[key] = value
                    }
                }
                else {
                    self.graphMaxList[key] = value
                }
                if let min = self.graphMinList[key] {
                    if min > value {
                        self.graphMinList[key] = value
                    }
                }
                else {
                    self.graphMinList[key] = value
                }
                
                if minVal == nil {
                    minVal = value
                }
                if maxVal == nil {
                    maxVal = value
                }
            }
            
            if let minVal = minVal {
                if let min = self.graphMinValues[key] {
                    if min > minVal {
                        self.graphMinValues[key] = minVal
                    }
                }
                else {
                    self.graphMinValues[key] = minVal
                }
            }
            if let maxVal = maxVal {
                if let max = self.graphMaxValues[key] {
                    if max < maxVal {
                        self.graphMaxValues[key] = maxVal
                    }
                }
                else {
                    self.graphMaxValues[key] = maxVal
                }
            }
        }
    }

    func getGraphValues(key: String, timeRange: TimeInterval, day: String, hour: String, min: String, sec: String, date: Date, hourCnt: Int) -> [String: Double?] {

        var value: Double? = nil
        var minVal: Double? = nil
        var maxVal: Double? = nil
        if timeRange == 10.0 {
            let values: [Double] = self.synapseRecordFileManager!.getSynapseRecordTotal(day: day, hour: hour, min: min, sec: sec, type: key)
            if values.count > 1 {
                value = values[1] / values[0]
            }

            var records: [String]? = self.synapseRecordFileManager!.getSynapseRecordValueType(day: day, hour: hour, min: min, type: key, valueType: "min")
            if records != nil && records!.count > 0 {
                let record: [String] = records![0].components(separatedBy: "_")
                if record.count > 1, let val = Double(record[1]) {
                    minVal = val
                }
            }
            records = self.synapseRecordFileManager!.getSynapseRecordValueType(day: day, hour: hour, min: min, type: key, valueType: "max")
            if records != nil && records!.count > 0 {
                let record: [String] = records![0].components(separatedBy: "_")
                if record.count > 1, let val = Double(record[1]) {
                    maxVal = val
                }
            }
        }
        else if timeRange == 60.0 {
            let values: [Double] = self.synapseRecordFileManager!.getSynapseRecordTotal(day: day, hour: hour, min: min, sec: nil, type: key)
            if values.count > 1 {
                value = values[1] / values[0]
            }

            var records: [String]? = self.synapseRecordFileManager!.getSynapseRecordValueType(day: day, hour: hour, min: min, type: key, valueType: "min")
            if records != nil && records!.count > 0 {
                let record: [String] = records![0].components(separatedBy: "_")
                if record.count > 1, let val = Double(record[1]) {
                    minVal = val
                }
            }
            records = self.synapseRecordFileManager!.getSynapseRecordValueType(day: day, hour: hour, min: min, type: key, valueType: "max")
            if records != nil && records!.count > 0 {
                let record: [String] = records![0].components(separatedBy: "_")
                if record.count > 1, let val = Double(record[1]) {
                    maxVal = val
                }
            }
        }
        else if timeRange == 600.0 {
            value = self.synapseRecordFileManager!.getSynapseRecordTotalIn10min(day: day, hour: hour, min: Int(min)! / 10, type: key, isSave: false)

            var records: [String]? = self.synapseRecordFileManager!.getSynapseRecordValueTypeIn10min(day: day, hour: hour, min: Int(min)! / 10, type: key, valueType: "min")
            if records != nil && records!.count > 0 {
                let record: [String] = records![0].components(separatedBy: "_")
                if record.count > 1, let val = Double(record[1]) {
                    minVal = val
                }
            }
            records = self.synapseRecordFileManager!.getSynapseRecordValueTypeIn10min(day: day, hour: hour, min: Int(min)! / 10, type: key, valueType: "max")
            if records != nil && records!.count > 0 {
                let record: [String] = records![0].components(separatedBy: "_")
                if record.count > 1, let val = Double(record[1]) {
                    maxVal = val
                }
            }
        }
        else if timeRange == 3600.0 {
            var cnt: Int = 0
            var dayAlt: String = day
            var hourAlt: String = hour
            for i in 0..<hourCnt {
                if i > 0 {
                    let dateAlt: Date = Date(timeInterval: timeRange * Double(i), since: date)
                    dayAlt = self.dayFormatter.string(from: dateAlt)
                    hourAlt = self.hourFormatter.string(from: dateAlt)
                    //print("setGraphData Alt: \(day)\(hour)\(min)\(sec)")
                }

                if let val = self.synapseRecordFileManager!.getSynapseRecordTotalInHour(day: dayAlt, hour: hourAlt, type: key, isSave: false) {
                    cnt += 1
                    if value != nil {
                        value = value! + val
                    }
                    else {
                        value = val
                    }
                }

                var records: [String]? = self.synapseRecordFileManager!.getSynapseRecordValueTypeInHour(day: dayAlt, hour: hourAlt, type: key, valueType: "min")
                if records != nil && records!.count > 0 {
                    let record: [String] = records![0].components(separatedBy: "_")
                    if record.count > 1, let val = Double(record[1]) {
                        if minVal != nil {
                            if minVal! > val {
                                minVal = val
                            }
                        }
                        else {
                            minVal = val
                        }
                    }
                }
                records = self.synapseRecordFileManager!.getSynapseRecordValueTypeInHour(day: dayAlt, hour: hourAlt, type: key, valueType: "max")
                if records != nil && records!.count > 0 {
                    let record: [String] = records![0].components(separatedBy: "_")
                    if record.count > 1, let val = Double(record[1]) {
                        if maxVal != nil {
                            if maxVal! < val {
                                maxVal = val
                            }
                        }
                        else {
                            maxVal = val
                        }
                    }
                }
            }
            if value != nil && cnt > 0 {
                value = value! / Double(cnt)
            }
        }
        return ["value": value, "minVal": minVal, "maxVal": maxVal]
    }

    func setGraphDataPerDay() {

        self.resetGraphData()

        if self.synapseRecordFileManager == nil || self.endDate == nil || self.startDate == nil {
            return
        }

        self.timeRange = 24.0 * 3600.0
        let fdTime: TimeInterval = floor(self.startDate!.timeIntervalSince1970 / (24 * 60 * 60)) * (24 * 60 * 60)
        let sdTime: TimeInterval = fdTime + ceil((self.startDate!.timeIntervalSince1970 - fdTime) / (60 * 60)) * (60 * 60)
        let ldTime: TimeInterval = floor(self.endDate!.timeIntervalSince1970 / (24 * 60 * 60)) * (24 * 60 * 60)
        let edTime: TimeInterval = ldTime + ceil((self.endDate!.timeIntervalSince1970 - ldTime) / (60 * 60)) * (60 * 60)

        let dateS: Date = Date(timeIntervalSince1970: sdTime)
        let dateE: Date = Date(timeIntervalSince1970: edTime)
        //print("setGraphDataPerDay: \(dateS) - \(dateE)")
        var date: Date = Date(timeIntervalSince1970: fdTime)
        self.graphCnt = 0
        while date <= dateE {
            self.graphDates.insert(date, at: 0)
            //print("setGraphDataPerDay: \(date)")
            var cnts: [String: Int] = [:]
            var values: [String: Double] = [:]
            for _ in 0..<24 {
                if date >= dateS && date <= dateE {
                    //print("setGraphDataPerDay In: \(date)")
                    let day: String = self.dayFormatter.string(from: date)
                    let hour: String = self.hourFormatter.string(from: date)
                    for (_, element) in self.graphCategories.enumerated() {
                        let key: String = element.key
                        if let val = self.synapseRecordFileManager!.getSynapseRecordTotalInHour(day: day, hour: hour, type: key, isSave: false) {
                            var cnt: Int = 1
                            if let cntBak = cnts[key] {
                                cnt += cntBak
                            }
                            cnts[key] = cnt
                            var value: Double = val
                            if let valueBak = values[key] {
                                value += valueBak
                            }
                            values[key] = value
                        }

                        var records: [String]? = self.synapseRecordFileManager!.getSynapseRecordValueTypeInHour(day: day, hour: hour, type: key, valueType: "min")
                        if records != nil && records!.count > 0 {
                            let record: [String] = records![0].components(separatedBy: "_")
                            if record.count > 1, let val = Double(record[1]) {
                                if let minVal = self.graphMinValues[key] {
                                    if minVal > val {
                                        self.graphMinValues[key] = val
                                    }
                                }
                                else {
                                    self.graphMinValues[key] = val
                                }
                            }
                        }
                        records = self.synapseRecordFileManager!.getSynapseRecordValueTypeInHour(day: day, hour: hour, type: key, valueType: "max")
                        if records != nil && records!.count > 0 {
                            let record: [String] = records![0].components(separatedBy: "_")
                            if record.count > 1, let val = Double(record[1]) {
                                if let maxVal = self.graphMaxValues[key] {
                                    if maxVal < val {
                                        self.graphMaxValues[key] = val
                                    }
                                }
                                else {
                                    self.graphMaxValues[key] = val
                                }
                            }
                        }
                    }
                }
                date = Date(timeInterval: TimeInterval(60 * 60), since: date)
            }

            for (_, element) in self.graphCategories.enumerated() {
                let key: String = element.key
                var value: Double? = nil
                if let val = values[key], let cnt = cnts[key] {
                    value = val / Double(cnt)
                }
                self.graphDataList[key]?.append(value)

                if let value = value {
                    if let max = self.graphMaxList[key] {
                        if max < value {
                            self.graphMaxList[key] = value
                        }
                    }
                    else {
                        self.graphMaxList[key] = value
                    }
                    if self.graphMaxValues[key] == nil {
                        self.graphMaxValues[key] = self.graphMaxList[key]
                    }

                    if let min = self.graphMinList[key] {
                        if min > value {
                            self.graphMinList[key] = value
                        }
                    }
                    else {
                        self.graphMinList[key] = value
                    }
                    if self.graphMinValues[key] == nil {
                        self.graphMinValues[key] = self.graphMinList[key]
                    }
                }
            }
            self.graphCnt += 1
        }
        self.setGraphRanges()
    }

    func getRealtimeGraphValues(key: String) -> [String: Double?] {

        var value: Double? = nil
        if let nav = self.navigationController as? NavigationController {
            if key == self.synapseCrystalInfo.co2.key, let co2 = nav.topVC.mainSynapseObject.synapseValues.co2 {
                value = Double(co2)
            }
            else if key == self.synapseCrystalInfo.temp.key, let temp = nav.topVC.mainSynapseObject.synapseValues.temp {
                value = Double(temp)
            }
            else if key == self.synapseCrystalInfo.hum.key, let humidity = nav.topVC.mainSynapseObject.synapseValues.humidity {
                value = Double(humidity)
            }
            else if key == self.synapseCrystalInfo.ill.key, let light = nav.topVC.mainSynapseObject.synapseValues.light {
                value = Double(light)
            }
            else if key == self.synapseCrystalInfo.press.key, let pressure = nav.topVC.mainSynapseObject.synapseValues.pressure {
                value = Double(pressure)
            }
            else if key == self.synapseCrystalInfo.sound.key, let sound = nav.topVC.mainSynapseObject.synapseValues.sound {
                value = Double(sound)
            }
            else if key == self.synapseCrystalInfo.volt.key, let power = nav.topVC.mainSynapseObject.synapseValues.power {
                value = Double(power)
            }
        }
        return ["value": value, "minVal": value, "maxVal": value]
    }

    func resetGraphData() {

        self.graphDates = []
        for (_, element) in self.graphCategories.enumerated() {
            let key: String = element.key
            self.graphDataList[key] = []
        }
        self.graphMaxList = [:]
        self.graphMinList = [:]
        self.graphMinValues = [:]
        self.graphMaxValues = [:]
    }

    func makeGraphDateNow() -> Date {

        let now: Date = Date()
        var time: TimeInterval = floor(now.timeIntervalSince1970 / (TimeInterval(self.timeRangeInterval) * 60.0)) * TimeInterval(self.timeRangeInterval) * 60.0
        if now.timeIntervalSince1970 - time >= 60.0 {
            time += TimeInterval(self.timeRangeInterval) * 60.0
        }
        return Date(timeIntervalSince1970: time)
    }

    func setGraphRanges() {

        for (_, element) in self.graphCategories.enumerated() {
            let key: String = element.key
            if let max = self.graphMaxList[key], let min = self.graphMinList[key] {
                if let value = self.graphMaxRanges[key] {
                    if value < max {
                        self.graphMaxRanges[key] = max
                    }
                }
                else {
                    self.graphMaxRanges[key] = max
                }
                if let value = self.graphMinRanges[key] {
                    if value > min - (max - min) {
                        self.graphMinRanges[key] = min - (max - min)
                    }
                }
                else {
                    self.graphMinRanges[key] = min - (max - min)
                }
                //self.graphMinRanges[key] = min / 2

                if let def = self.graphRangeDefault[key] {
                    if let interval = def["interval"] {
                        self.graphMaxRanges[key] = ceil(self.graphMaxRanges[key]! / interval) * interval
                        if (max - min) * 2 < interval {
                            self.graphMinRanges[key] = max - interval
                        }
                        self.graphMinRanges[key] = floor(self.graphMinRanges[key]! / interval) * interval
                    }

                    if let maxDef = def["max"], self.graphMaxRanges[key]! > maxDef {
                        self.graphMaxRanges[key] = maxDef
                    }
                    if let minDef = def["min"], self.graphMinRanges[key]! < minDef {
                        self.graphMinRanges[key] = minDef
                    }
                }
            }
        }
        //print("setGraphRanges Max: \(self.graphMaxRanges)")
        //print("setGraphRanges Min: \(self.graphMinRanges)")
    }

    // MARK: mark - RealtimeGraph methods

    func changeRealtimeGraphDataStart(_ time: TimeInterval? = nil) {

        if self.realtimeGraphTimeIntervalKey.count <= 0 {
            return
        }

        self.isRealtime = true

        self.realtimeGraphTimer?.invalidate()
        self.realtimeGraphTimer = nil

        self.closeGraphDataSmallView()
        self.setHiddenLoadingView(false)

        var realtimeGraphTime: TimeInterval = 1.0
        if let time = time {
            realtimeGraphTime = time
        }
        self.realtimeGraphTimer = Timer.scheduledTimer(timeInterval: realtimeGraphTime,
                                                       target: self,
                                                       selector: #selector(self.setRealtimeGraphData),
                                                       userInfo: nil,
                                                       repeats: true)
    }

    @objc func setRealtimeGraphData() {

        self.realtimeGraphTimer?.invalidate()
        self.realtimeGraphTimer = nil

        self.setHiddenLoadingView(true)

        if self.realtimeGraphTimeIntervalKey.count > 0, let values = self.realtimeGraphTimeIntervalValues[self.realtimeGraphTimeIntervalKey], let range = values["range"] {
            self.timeRange = range
            //print("setRealtimeGraphData time: \(self.realtimeGraphTimeInterval), \(self.timeRange)")
            let width: Double = Double(self.baseView.frame.size.width - self.graphSpaceR)
            self.graphCnt = Int(ceil(width / (self.timeRange / self.realtimeGraphTimeInterval))) + 1
            //print("setRealtimeGraphData width: \(width), \(self.graphCnt)")

            self.endDate = Date()
            var endDateAlt: Date = Date(timeIntervalSince1970: floor(self.endDate!.timeIntervalSince1970))
            if self.realtimeGraphTimeInterval > 1.0 {
                endDateAlt = Date(timeIntervalSince1970: floor(self.endDate!.timeIntervalSince1970 / self.realtimeGraphTimeInterval) * self.realtimeGraphTimeInterval)
            }
            self.startDate = Date(timeInterval: -self.timeRange * Double(self.graphCnt), since: endDateAlt)
            self.realtimeGraphLastTime = self.endDate!.timeIntervalSince1970
            //print("setRealtimeGraphData: \(self.startDate), \(self.endDate)")

            self.resetGraphData()

            if self.synapseRecordFileManager == nil {
                return
            }

            if self.realtimeGraphTimeInterval < 1.0 {
                self.setRealtimeGraphDataWithinSecond(floor(self.startDate!.timeIntervalSince1970))
            }
            else {
                var count: Int = 0
                var date: Date = self.endDate!
                while date >= self.startDate! {
                    if count >= self.graphCnt {
                        break
                    }
                    
                    if count == 0 {
                        self.setGraphDataOfDate(date, isRealtime: true)
                    }
                    else {
                        if self.timeRange >= 3600.0 {
                            self.setGraphDataOfDate(date, hourCnt: 1)
                        }
                        else {
                            self.setGraphDataOfDate(date)
                        }
                    }
                    
                    if count == 0 {
                        date = endDateAlt
                    }
                    let time: TimeInterval = floor(date.timeIntervalSince1970 / self.timeRange) * self.timeRange - self.timeRange
                    date = Date(timeIntervalSince1970: time)
                    //print("setRealtimeGraphData Date: \(date)")
                    count += 1
                }
            }

            self.setGraphRanges()
            self.setGraphViews()
            self.changeGraphIsHiddenAction()
            self.setDateLabels()

            self.realtimeGraphTimer = Timer.scheduledTimer(timeInterval: 1.0,
                                                           target: self,
                                                           selector: #selector(self.updateRealtimeGraphData),
                                                           userInfo: nil,
                                                           repeats: true)
        }
    }

    @objc func updateRealtimeGraphData() {

        /*if let realtimeGraphLastTime = self.realtimeGraphLastTime, Date().timeIntervalSince1970 - realtimeGraphLastTime < self.realtimeGraphTimeInterval {
            return
        }*/

        self.endDate = Date()
        //self.endDate = Date(timeIntervalSince1970: floor(Date().timeIntervalSince1970 / self.realtimeGraphTimeInterval) * self.realtimeGraphTimeInterval)
        if let realtimeGraphLastTime = self.realtimeGraphLastTime {
            if self.realtimeGraphTimeInterval < 1.0 {
                self.setRealtimeGraphDataWithinSecond(floor(realtimeGraphLastTime))
            }
            else {
                let checkEndTime: TimeInterval = floor((self.endDate!.timeIntervalSince1970 - self.realtimeGraphTimeInterval) / self.timeRange)
                let checkLastTime: TimeInterval = floor((realtimeGraphLastTime - self.realtimeGraphTimeInterval) / self.timeRange)
                if checkEndTime != checkLastTime {
                    if self.timeRange >= 3600.0 {
                        self.setGraphDataOfDate(Date(timeIntervalSince1970: checkLastTime * self.timeRange), hourCnt: 1, position: self.graphDates.count - 1)
                    }
                    else {
                        self.setGraphDataOfDate(Date(timeIntervalSince1970: checkLastTime * self.timeRange), position: self.graphDates.count - 1)
                    }
                    
                    self.setGraphDataOfDate(self.endDate!, position: self.graphDates.count, isRealtime: true)
                    self.graphDates.removeFirst()
                    for (_, element) in self.graphCategories.enumerated() {
                        self.graphDataList[element.key]?.removeFirst()
                    }
                }
                /*else if floor(self.endDate!.timeIntervalSince1970 / self.timeRange) != floor(realtimeGraphLastTime / self.timeRange) {
                    self.setGraphDataOfDate(self.endDate!, position: self.graphDates.count - 1)
                }*/
                else {
                    self.setGraphDataOfDate(self.endDate!, position: self.graphDates.count - 1, isRealtime: true)
                }
            }
        }
        self.startDate = Date(timeInterval: -self.timeRange * Double(self.graphCnt), since: self.endDate!)
        self.realtimeGraphLastTime = self.endDate!.timeIntervalSince1970
        //print("setGraphData: \(self.graphDates.count) / \(self.graphCnt)")

        self.setGraphRanges()
        self.setGraphViews()
        self.changeGraphIsHiddenAction()
        self.setDateLabels()

        if !self.selectLineView.isHidden {
            self.setSelectPoint(self.selectLineView.frame.origin.x)
            if self.graphSelectpt >= 0 {
                self.enableGraphDataSmallView()
            }
        }
    }

    func setRealtimeGraphViewSize() {

        self.graphBlock = CGFloat(self.timeRange / self.realtimeGraphTimeInterval)
        var lastW: CGFloat = 0
        if let endDate = self.endDate {
            lastW = CGFloat(floor((endDate.timeIntervalSince1970 - floor(endDate.timeIntervalSince1970 / self.timeRange) * self.timeRange) / self.realtimeGraphTimeInterval))
        }
        if lastW <= 0.0 {
            lastW = self.graphBlock
        }
        //print("setRealtimeGraphViewSize: \(lastW)")
        self.graphW = self.graphBlock * CGFloat(self.graphCnt - 1) + lastW + self.graphCirclePointW
        //print("setGraphData: \(self.graphW)")
        self.graphX = self.baseView.frame.size.width - self.graphSpaceR - self.graphW
        self.graphY = self.graphSpace
        self.graphH = self.baseView.frame.size.height - self.graphY * 2
        self.setGraphScaleLines()
        //print("setGraphData setRealtimeGraphViewSize: \(lastW), \(self.graphBlock), \(self.timeRange)")
    }

    func makeRealtimeGraphImage(_ data: [Double?], color: UIColor, imageW: CGFloat, imageH: CGFloat, minValue: Double, maxValue: Double) -> UIImage? {

        var image: UIImage? = nil
        let w: CGFloat = self.graphBlock
        var h: CGFloat = CGFloat(maxValue - minValue)
        if h <= 0 {
            h = 0
        }
        var sx: CGFloat = -1
        var sy: CGFloat? = nil
        var lx: CGFloat? = nil
        var ly: CGFloat? = nil
        UIGraphicsBeginImageContextWithOptions(CGSize(width: imageW, height: imageH), false, 0)
        color.setStroke()
        for (index, element) in data.enumerated() {
            var ex: CGFloat = w * CGFloat(index)
            if index == data.count - 1 {
                ex = imageW - self.graphCirclePointW
            }
            var ey: CGFloat? = nil
            if let yVal = element {
                ey = imageH - self.graphCirclePointW
                if h > 0 {
                    ey = (imageH - self.graphCirclePointW * 2) * (1.0 - CGFloat(yVal - minValue) / h) + self.graphCirclePointW
                }
            }
            if sy != nil {
                var x: CGFloat = sx + 1.0
                var y: CGFloat = sy! + 1.0
                if ey != nil {
                    x = ex
                    y = ey!
                }

                let path: UIBezierPath = UIBezierPath()
                path.move(to: CGPoint(x: sx, y: sy!))
                //path.addQuadCurve(to: CGPoint(x: ex, y: ey), controlPoint: CGPoint(x: sx, y: ey))
                path.addLine(to: CGPoint(x: x, y: y))
                path.lineWidth = 1.0
                path.stroke()
            }
            sx = ex
            sy = ey
            if sy != nil {
                lx = sx
                ly = sy
            }
            /*if index == data.count - 1 {
                lx = ex
                ly = ey
            }*/
        }

        if lx != nil && ly != nil {
            let circlePath: UIBezierPath = UIBezierPath(ovalIn: CGRect(x: lx! - self.graphCirclePointW, y: ly! - self.graphCirclePointW, width: self.graphCirclePointW * 2, height: self.graphCirclePointW * 2))
            color.setFill()
            circlePath.fill()
        }

        image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }

    func setRealtimeGraphDataWithinSecond(_ lastTime: TimeInterval) {

        if let nav = self.navigationController as? NavigationController {
            var graphValues: [String: [String: Double?]]? = [:]
            for synapse in nav.topVC.mainSynapseObject.synapseData {
                if let time = synapse["time"] as? TimeInterval, let data = synapse["data"] as? [UInt8] {
                    if time < lastTime {
                        break
                    }

                    let timeKey: String = String(format:"%.0f", floor(time))
                    let values: SynapseValues = nav.topVC.mainSynapseObject.makeSynapseData(data)
                    for (_, element) in self.graphCategories.enumerated() {
                        let key: String = element.key
                        var value: Double? = nil
                        if key == self.synapseCrystalInfo.co2.key, let co2 = values.co2 {
                            value = Double(co2)
                        }
                        else if key == self.synapseCrystalInfo.temp.key, let temp = values.temp {
                            value = Double(temp)
                        }
                        else if key == self.synapseCrystalInfo.hum.key, let humidity = values.humidity {
                            value = Double(humidity)
                        }
                        else if key == self.synapseCrystalInfo.ill.key, let light = values.light {
                            value = Double(light)
                        }
                        else if key == self.synapseCrystalInfo.press.key, let pressure = values.pressure {
                            value = Double(pressure)
                        }
                        else if key == self.synapseCrystalInfo.sound.key, let sound = values.sound {
                            value = Double(sound)
                        }
                        else if key == self.synapseCrystalInfo.volt.key, let power = values.power {
                            value = Double(power)
                        }

                        if graphValues![key] == nil {
                            graphValues![key] = [:]
                        }
                        if let value = value {
                            graphValues![key]![timeKey] = value

                            if let max = self.graphMaxList[key] {
                                if max < value {
                                    self.graphMaxList[key] = value
                                }
                            }
                            else {
                                self.graphMaxList[key] = value
                            }
                            if let min = self.graphMinList[key] {
                                if min > value {
                                    self.graphMinList[key] = value
                                }
                            }
                            else {
                                self.graphMinList[key] = value
                            }
                        }
                    }
                }
            }

            let position: Int = self.graphDates.count
            let stratTime: TimeInterval = floor(Date().timeIntervalSince1970)
            var time: TimeInterval = stratTime
            while time >= lastTime {
                let date: Date = Date(timeIntervalSince1970: time)
                let index: Int? = self.graphDates.index(of: date)
                if index == nil {
                    if position < self.graphDates.count {
                        self.graphDates.insert(date, at: position)
                    }
                    else {
                        self.graphDates.append(date)
                    }
                }
                //print("setRealtimeGraphDataWithinSecond: \(date), \(index), \(position) << \(self.graphDates.count)")

                let timeKey: String = String(format:"%.0f", floor(time))
                for (_, element) in self.graphCategories.enumerated() {
                    let key: String = element.key
                    var value: Double? = nil
                    if let values = graphValues![key] {
                        value = values[timeKey] ?? nil
                    }
                    if time == stratTime {
                        let realtimeGraphValues: [String: Double?] = self.getRealtimeGraphValues(key: key)
                        value = realtimeGraphValues["value"] ?? nil
                        if let value = value {
                            if let max = self.graphMaxList[key] {
                                if max < value {
                                    self.graphMaxList[key] = value
                                }
                            }
                            else {
                                self.graphMaxList[key] = value
                            }
                            if let min = self.graphMinList[key] {
                                if min > value {
                                    self.graphMinList[key] = value
                                }
                            }
                            else {
                                self.graphMinList[key] = value
                            }
                        }
                    }

                    if let index = index {
                        if let graphDataListOfKey = self.graphDataList[key], index < graphDataListOfKey.count {
                            self.graphDataList[key]?[index] = value
                        }
                    }
                    else {
                        if let graphDataListOfKey = self.graphDataList[key], position < graphDataListOfKey.count {
                            self.graphDataList[key]?.insert(value, at: position)
                        }
                        else {
                            self.graphDataList[key]?.append(value)
                        }
                    }
                    //print("setRealtimeGraphDataWithinSecond:   \(key) -> \(value)")
                }
                time -= 1.0
            }
            while self.graphDates.count > self.graphCnt {
                self.graphDates.removeFirst()
                for (_, element) in self.graphCategories.enumerated() {
                    self.graphDataList[element.key]?.removeFirst()
                }
            }
            graphValues = nil
        }
    }

    // MARK: mark - GraphView methods

    func setGraphViews() {

        for (_, element) in self.baseView.subviews.enumerated() {
            element.removeFromSuperview()
        }

        if self.isRealtime {
            self.setRealtimeGraphViewSize()
        }
        else {
            self.setGraphViewSize()
        }

        let spaceH: CGFloat = self.graphRealtimeButton.frame.size.height + 10.0 * 2
        for (index, element) in self.graphCategories.enumerated() {
            if let data = self.graphDataList[element.key] {
                var max: Double = 0
                var min: Double = 0
                if let value = self.graphMaxRanges[element.key] {
                    max = value
                }
                if let value = self.graphMinRanges[element.key] {
                    min = value
                }
                //print("setGraphViews: \([element.key) -> \(min) - \(max)")

                let imageView: UIImageView = UIImageView()
                imageView.tag = index
                imageView.frame = CGRect(x: self.graphX, y: self.graphY + spaceH, width: self.graphW, height: self.graphH - spaceH)
                imageView.backgroundColor = UIColor.clear
                if self.isRealtime {
                    imageView.image = self.makeRealtimeGraphImage(data, color: element.graphColor, imageW: imageView.frame.size.width, imageH: imageView.frame.size.height, minValue: min, maxValue: max)
                }
                else {
                    imageView.image = self.makeGraphImage(data, color: element.graphColor, imageW: imageView.frame.size.width, imageH: imageView.frame.size.height, minValue: min, maxValue: max)
                }
                self.baseView.addSubview(imageView)
            }
        }
    }

    func setGraphViewSize() {

        self.graphX = 0
        self.graphY = self.graphSpace
        self.graphW = self.baseView.frame.size.width - self.graphSpaceR
        self.graphH = self.baseView.frame.size.height - self.graphY * 2
        self.graphBlock = 0
        if self.graphCnt > 1 {
            self.graphBlock = (self.graphW - self.graphCirclePointW) / CGFloat(self.graphCnt - 1)
            self.setGraphScaleLines()
        }
        //print("setGraphViewSize: \(self.graphBlock) / \(self.timeRange)")
    }

    func makeGraphImage(_ data: [Double?], color: UIColor, imageW: CGFloat, imageH: CGFloat, minValue: Double, maxValue: Double) -> UIImage? {

        var image: UIImage? = nil
        var w: CGFloat = imageW
        if self.graphBlock > 0 {
            w = self.graphBlock
        }
        var h: CGFloat = CGFloat(maxValue - minValue)
        if h <= 0 {
            h = 0
        }

        var sx: CGFloat = -1
        var sy: CGFloat? = nil
        var lx: CGFloat? = nil
        var ly: CGFloat? = nil
        UIGraphicsBeginImageContextWithOptions(CGSize(width: imageW, height: imageH), false, 0)
        color.setStroke()
        for (index, element) in data.enumerated() {
            let ex: CGFloat = w * CGFloat(index)
            var ey: CGFloat? = nil
            if let yVal = element {
                ey = imageH - self.graphCirclePointW
                if h > 0 {
                    ey = (imageH - self.graphCirclePointW * 2) * (1.0 - CGFloat(yVal - minValue) / h) + self.graphCirclePointW
                }
                /*if ey! > imageH - self.graphCirclePointW {
                    ey = imageH - self.graphCirclePointW
                }
                else if ey! < self.graphCirclePointW {
                    ey = self.graphCirclePointW
                }*/
            }
            if sy != nil {
                var x: CGFloat = sx + 1.0
                var y: CGFloat = sy! + 1.0
                if ey != nil {
                    x = ex
                    y = ey!
                }

                let path: UIBezierPath = UIBezierPath()
                path.move(to: CGPoint(x: sx, y: sy!))
                //path.addQuadCurve(to: CGPoint(x: ex, y: ey), controlPoint: CGPoint(x: sx, y: ey))
                path.addLine(to: CGPoint(x: x, y: y))
                path.lineWidth = 1.0
                path.stroke()
            }
            sx = ex
            sy = ey
            if sy != nil {
                lx = sx
                ly = sy
            }
        }
        if lx != nil && ly != nil {
            let circlePath: UIBezierPath = UIBezierPath(ovalIn: CGRect(x: lx! - self.graphCirclePointW, y: ly! - self.graphCirclePointW, width: self.graphCirclePointW * 2, height: self.graphCirclePointW * 2))
            color.setFill()
            circlePath.fill()
        }

        image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }

    func setGraphScaleLines() {

        if self.graphBlock > 0 {
            var pt: CGFloat = self.graphW - self.graphCirclePointW
            var blockBase: CGFloat = self.graphBlock * 6
            let cntBase: CGFloat = ceil(pt / blockBase)

            var cnt: CGFloat = 1.0
            if self.timeRange == 10.0 {
                if cntBase >= 50.0 {
                    cnt = 10.0
                }
                else if cntBase >= 10.0 {
                    cnt = 5.0
                }
            }
            else if self.timeRange == 60.0 {
                if cntBase >= 50.0 {
                    cnt = 10.0
                }
                else if cntBase >= 10.0 {
                    cnt = 5.0
                }
            }
            else if self.timeRange == 600.0 {
                if cntBase >= 120.0 {
                    cnt = 24.0
                }
                else if cntBase >= 60.0 {
                    cnt = 12.0
                }
                else if cntBase >= 30.0 {
                    cnt = 6.0
                }
                else if cntBase >= 10.0 {
                    cnt = 3.0
                }
            }
            else if self.timeRange == 3600.0 {
                if cntBase >= 20.0 {
                    cnt = 4.0
                }
                else if cntBase >= 10.0 {
                    cnt = 2.0
                }
            }
            /*else if self.timeRange == 24.0 * 3600.0 {
                blockBase = self.graphBlock
                cnt = 1
            }*/
            else if self.timeRange > 3600.0 {
                blockBase = self.graphBlock
                cnt = 24.0 / CGFloat(self.timeRange / 3600.0)
                if cnt < 1.0 {
                    cnt = 1.0
                }
            }
            //print("setGraphScaleLines: \(self.timeRange), \(blockBase), \(cnt)")
            while pt >= 0 {
                let line: UIView = UIView()
                line.frame = CGRect(x: pt + self.graphX,
                                    y: 0,
                                    width: 1.0,
                                    height: self.baseView.frame.size.height)
                line.backgroundColor = UIColor.white.withAlphaComponent(0.1)
                self.baseView.addSubview(line)
                pt -= blockBase * cnt
            }
        }
    }

    // MARK: mark - GraphSettingView methods

    @objc func setDisplaySettingView() {

        if let nav = self.navigationController as? NavigationController {
            if self.isRealtime {
                self.realtimeGraphTimer?.invalidate()
                self.realtimeGraphTimer = nil
            }

            var x: CGFloat = 0
            var y: CGFloat = 0
            var w: CGFloat = nav.view.frame.size.width
            var h: CGFloat = nav.view.frame.size.height
            self.displaySettingView = UIView()
            self.displaySettingView?.frame = CGRect(x: x, y: y, width: w, height: h)
            self.displaySettingView?.backgroundColor = UIColor.black.withAlphaComponent(0.9)
            nav.view.addSubview(self.displaySettingView!)

            w = 44.0
            h = 44.0
            x = self.displaySettingView!.frame.size.width - w
            y = 20.0
            if #available(iOS 11.0, *) {
                y = self.view.safeAreaInsets.top
            }
            let closeButton: UIButton = UIButton()
            closeButton.tag = 2
            closeButton.frame = CGRect(x: x, y: y, width: w, height: h)
            closeButton.backgroundColor = UIColor.clear
            closeButton.addTarget(self, action: #selector(self.closeDisplaySettingView), for: .touchUpInside)
            self.displaySettingView?.addSubview(closeButton)

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

            x = 0
            y = closeButton.frame.origin.y + closeButton.frame.size.height
            w = self.displaySettingView!.frame.size.width
            h = self.displaySettingView!.frame.size.height - y
            let mainScrollView: UIScrollView = UIScrollView()
            mainScrollView.frame = CGRect(x: x, y: y, width: w, height: h)
            mainScrollView.backgroundColor = UIColor.clear
            self.displaySettingView?.addSubview(mainScrollView)

            x = 10.0
            y = 0
            w = mainScrollView.frame.size.width - x
            h = 50.0
            let titleLabel: UILabel = UILabel()
            titleLabel.frame = CGRect(x: x, y: y, width: w, height: h)
            titleLabel.text = "Graph Setting"
            titleLabel.textColor = UIColor.white
            titleLabel.backgroundColor = UIColor.clear
            titleLabel.font = UIFont(name: "HelveticaNeue", size: 24.0)
            titleLabel.textAlignment = .left
            titleLabel.numberOfLines = 1
            mainScrollView.addSubview(titleLabel)

            w = 50.0
            h = 32.0
            let blockW: CGFloat = 40.0
            x = mainScrollView.frame.size.width - (w + 10.0)
            y = titleLabel.frame.origin.y + titleLabel.frame.size.height + 20.0
            self.graphRangeViewParts = [:]
            for (index, element) in self.graphCategories.enumerated() {
                self.graphRangeViewParts![element.key] = [:]

                let imageView: UIImageView = UIImageView()
                imageView.frame = CGRect(x: 10.0, y: y, width: blockW, height: blockW)
                imageView.backgroundColor = UIColor.clear
                if element.key == self.synapseCrystalInfo.co2.key {
                    imageView.image = UIImage.co2LW
                }
                else if element.key == self.synapseCrystalInfo.temp.key {
                    imageView.image = UIImage.temperatureLW
                }
                else if element.key == self.synapseCrystalInfo.hum.key {
                    imageView.image = UIImage.humidityLW
                }
                else if element.key == self.synapseCrystalInfo.ill.key {
                    imageView.image = UIImage.illuminationLW
                }
                else if element.key == self.synapseCrystalInfo.press.key {
                    imageView.image = UIImage.airpressureLW
                }
                else if element.key == self.synapseCrystalInfo.sound.key {
                    imageView.image = UIImage.environmentalsoundLW
                }
                /*else if element.key == self.synapseCrystalInfo.mag.key {
                     imageView.image = UIImage(named: "mag.png")
                }*/
                else if element.key == self.synapseCrystalInfo.move.key {
                    imageView.image = UIImage.movementLW
                }
                else if element.key == self.synapseCrystalInfo.angle.key {
                    imageView.image = UIImage.angleLW
                }
                else if element.key == self.synapseCrystalInfo.volt.key {
                    imageView.image = UIImage.magneticfieldLW
                }
                mainScrollView.addSubview(imageView)

                let label: UILabel = UILabel()
                label.text = element.name
                label.textColor = UIColor.white
                label.backgroundColor = UIColor.clear
                label.font = UIFont(name: "HelveticaNeue", size: 15.0)
                label.textAlignment = .left
                label.numberOfLines = 1
                label.sizeToFit()
                label.frame = CGRect(x: imageView.frame.origin.x * 2 + imageView.frame.size.width,
                                     y: y,
                                     width: label.frame.size.width,
                                     height: blockW)
                mainScrollView.addSubview(label)

                let circleView: UIView = UIView()
                circleView.frame = CGRect(x: label.frame.origin.x + label.frame.size.width + 10.0,
                                          y: y + (blockW - 16.0) / 2,
                                          width: 16.0,
                                          height: 16.0)
                circleView.backgroundColor = element.graphColor
                circleView.layer.cornerRadius = circleView.frame.size.width / 2
                circleView.clipsToBounds = true
                mainScrollView.addSubview(circleView)

                let button: UIButton = UIButton()
                button.tag = index
                button.frame = CGRect(x: x, y: y, width: blockW, height: blockW)
                button.backgroundColor = UIColor.white
                if let flag = self.graphDisplays[element.key] {
                    if !flag {
                        button.backgroundColor = UIColor.clear
                    }
                }
                button.layer.borderColor = UIColor.white.cgColor
                button.layer.borderWidth = 1.0
                button.addTarget(self, action: #selector(self.changeGraphIsHiddenAction(_:)), for: .touchDown)
                mainScrollView.addSubview(button)

                let iconW: CGFloat = 18.0
                let iconH: CGFloat = 16.0
                let checkmarkView: CheckmarkView = CheckmarkView()
                checkmarkView.tag = 1
                checkmarkView.frame = CGRect(x: (button.frame.size.width - iconW) / 2,
                                             y: (button.frame.size.height - iconH) / 2,
                                             width: iconW,
                                             height: iconH)
                checkmarkView.backgroundColor = UIColor.clear
                checkmarkView.triangleColor = UIColor.black
                checkmarkView.isUserInteractionEnabled = false
                checkmarkView.isHidden = false
                if let flag = self.graphDisplays[element.key] {
                    if !flag {
                        checkmarkView.isHidden = true
                    }
                }
                button.addSubview(checkmarkView)

                y += blockW + 10.0

                let minPlusButton: UIButton = UIButton()
                minPlusButton.tag = index * 4
                minPlusButton.frame = CGRect(x: x, y: y, width: blockW, height: blockW)
                minPlusButton.backgroundColor = UIColor.clear
                minPlusButton.layer.borderColor = UIColor.white.cgColor
                minPlusButton.layer.borderWidth = 1.0
                minPlusButton.addTarget(self, action: #selector(self.changeGraphRangeAction(_:)), for: .touchDown)
                mainScrollView.addSubview(minPlusButton)

                let minPlusLongPressRecognizer: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.changeGraphRangeLongPressed(_:)))
                minPlusButton.addGestureRecognizer(minPlusLongPressRecognizer)

                let minPlusViewS: UIView = UIView()
                minPlusViewS.frame = CGRect(x: minPlusButton.frame.size.width / 3,
                                            y: minPlusButton.frame.size.height / 2,
                                            width: minPlusButton.frame.size.width / 3 + 1.0,
                                            height: 1.0)
                minPlusViewS.backgroundColor = UIColor.white
                minPlusViewS.isUserInteractionEnabled = false
                minPlusButton.addSubview(minPlusViewS)

                let minPlusViewL: UIView = UIView()
                minPlusViewL.frame = CGRect(x: minPlusButton.frame.size.width / 2,
                                            y: minPlusButton.frame.size.height / 3,
                                            width: 1.0,
                                            height: minPlusButton.frame.size.height / 3 + 1.0)
                minPlusViewL.backgroundColor = UIColor.white
                minPlusViewL.isUserInteractionEnabled = false
                minPlusButton.addSubview(minPlusViewL)

                let minMinusButton: UIButton = UIButton()
                minMinusButton.tag = index * 4 + 1
                minMinusButton.frame = CGRect(x: x - minPlusButton.frame.size.width + 1.0,
                                              y: y,
                                              width: minPlusButton.frame.size.width,
                                              height: minPlusButton.frame.size.height)
                minMinusButton.backgroundColor = UIColor.clear
                minMinusButton.layer.borderColor = UIColor.white.cgColor
                minMinusButton.layer.borderWidth = 1.0
                minMinusButton.addTarget(self, action: #selector(self.changeGraphRangeAction(_:)), for: .touchDown)
                mainScrollView.addSubview(minMinusButton)

                let minMinusLongPressRecognizer: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.changeGraphRangeLongPressed(_:)))
                minMinusButton.addGestureRecognizer(minMinusLongPressRecognizer)

                let minMinusView: UIView = UIView()
                minMinusView.frame = CGRect(x: minMinusButton.frame.size.width / 3,
                                            y: minMinusButton.frame.size.height / 2,
                                            width: minMinusButton.frame.size.width / 3,
                                            height: 1.0)
                minMinusView.backgroundColor = UIColor.white
                minMinusView.isUserInteractionEnabled = false
                minMinusButton.addSubview(minMinusView)

                let minLabel: UILabel = UILabel()
                minLabel.text = "GRAPH RANGE MIN"
                minLabel.backgroundColor = UIColor.clear
                minLabel.font = UIFont(name: "HelveticaNeue", size: 12.0)
                minLabel.textColor = UIColor.white
                minLabel.textAlignment = .left
                minLabel.numberOfLines = 1
                minLabel.sizeToFit()
                minLabel.frame = CGRect(x: 10.0,
                                        y: minMinusButton.frame.origin.y,
                                        width: minLabel.frame.size.width + 4.0,
                                        height: minMinusButton.frame.size.height)
                mainScrollView.addSubview(minLabel)

                let minUnitLabel: UILabel = UILabel()
                minUnitLabel.backgroundColor = UIColor.clear
                minUnitLabel.font = UIFont(name: "Migu 2M", size: 14.0)
                minUnitLabel.textColor = UIColor.white
                minUnitLabel.textAlignment = .left
                minUnitLabel.numberOfLines = 1
                minUnitLabel.text = ""
                if element.key == self.synapseCrystalInfo.co2.key {
                    minUnitLabel.text = "ppm"
                }
                else if element.key == self.synapseCrystalInfo.temp.key {
                    minUnitLabel.text = self.getTemperatureUnit(SettingFileManager.shared.synapseTemperatureScale)
                }
                else if element.key == self.synapseCrystalInfo.hum.key {
                    minUnitLabel.text = "%"
                }
                else if element.key == self.synapseCrystalInfo.ill.key {
                    minUnitLabel.text = "lux"
                }
                else if element.key == self.synapseCrystalInfo.press.key {
                    minUnitLabel.text = "hPa"
                }
                else if element.key == self.synapseCrystalInfo.volt.key {
                    minUnitLabel.text = "V"
                }
                minUnitLabel.sizeToFit()
                minUnitLabel.frame = CGRect(x: minMinusButton.frame.origin.x - (minUnitLabel.frame.size.width + 10.0),
                                            y: minMinusButton.frame.origin.y,
                                            width: minUnitLabel.frame.size.width,
                                            height: minMinusButton.frame.size.height)
                mainScrollView.addSubview(minUnitLabel)

                var labelW: CGFloat = minUnitLabel.frame.origin.x - (minLabel.frame.origin.x + minLabel.frame.size.width)
                if minUnitLabel.frame.size.width > 0 {
                    labelW -= 5.0
                }
                let minValueLabel: UILabel = UILabel()
                minValueLabel.frame = CGRect(x: minLabel.frame.origin.x + minLabel.frame.size.width,
                                             y: minMinusButton.frame.origin.y,
                                             width: labelW,
                                             height: minMinusButton.frame.size.height)
                minValueLabel.backgroundColor = UIColor.clear
                minValueLabel.font = UIFont(name: "Migu 2M", size: 14.0)
                minValueLabel.textColor = UIColor.fluorescentPink
                minValueLabel.textAlignment = .right
                minValueLabel.numberOfLines = 1
                minValueLabel.text = ""
                if let value = self.graphMinRanges[element.key] {
                    minValueLabel.text = String(format:"%.1f", value)
                    if element.key == self.synapseCrystalInfo.temp.key {
                        minValueLabel.text = String(format:"%.1f", self.getTemperatureValue(SettingFileManager.shared.synapseTemperatureScale, value: Float(value)))
                    }
                }
                mainScrollView.addSubview(minValueLabel)
                self.graphRangeViewParts![element.key]!["min"] = minValueLabel

                y += blockW + 10.0

                let maxPlusButton: UIButton = UIButton()
                maxPlusButton.tag = index * 4 + 2
                maxPlusButton.frame = CGRect(x: minPlusButton.frame.origin.x,
                                             y: y,
                                             width: minPlusButton.frame.size.width,
                                             height: minPlusButton.frame.size.height)
                maxPlusButton.backgroundColor = UIColor.clear
                maxPlusButton.layer.borderColor = UIColor.white.cgColor
                maxPlusButton.layer.borderWidth = 1.0
                maxPlusButton.addTarget(self, action: #selector(self.changeGraphRangeAction(_:)), for: .touchDown)
                mainScrollView.addSubview(maxPlusButton)

                let maxPlusLongPressRecognizer: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.changeGraphRangeLongPressed(_:)))
                maxPlusButton.addGestureRecognizer(maxPlusLongPressRecognizer)

                let maxPlusViewS: UIView = UIView()
                maxPlusViewS.frame = CGRect(x: minPlusViewS.frame.origin.x,
                                            y: minPlusViewS.frame.origin.y,
                                            width: minPlusViewS.frame.size.width,
                                            height: minPlusViewS.frame.size.height)
                maxPlusViewS.backgroundColor = UIColor.white
                maxPlusViewS.isUserInteractionEnabled = false
                maxPlusButton.addSubview(maxPlusViewS)

                let maxPlusViewL: UIView = UIView()
                maxPlusViewL.frame = CGRect(x: minPlusViewL.frame.origin.x,
                                            y: minPlusViewL.frame.origin.y,
                                            width: minPlusViewL.frame.size.width,
                                            height: minPlusViewL.frame.size.height)
                maxPlusViewL.backgroundColor = UIColor.white
                maxPlusViewL.isUserInteractionEnabled = false
                maxPlusButton.addSubview(maxPlusViewL)

                let maxMinusButton: UIButton = UIButton()
                maxMinusButton.tag = index * 4 + 3
                maxMinusButton.frame = CGRect(x: x - maxPlusButton.frame.size.width + 1.0,
                                              y: y,
                                              width: maxPlusButton.frame.size.width,
                                              height: maxPlusButton.frame.size.height)
                maxMinusButton.backgroundColor = UIColor.clear
                maxMinusButton.layer.borderColor = UIColor.white.cgColor
                maxMinusButton.layer.borderWidth = 1.0
                maxMinusButton.addTarget(self, action: #selector(self.changeGraphRangeAction(_:)), for: .touchDown)
                mainScrollView.addSubview(maxMinusButton)

                let maxMinusLongPressRecognizer: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.changeGraphRangeLongPressed(_:)))
                maxMinusButton.addGestureRecognizer(maxMinusLongPressRecognizer)

                let maxMinusView: UIView = UIView()
                maxMinusView.frame = CGRect(x: minMinusView.frame.origin.x,
                                            y: minMinusView.frame.origin.y,
                                            width: minMinusView.frame.size.width,
                                            height: minMinusView.frame.size.height)
                maxMinusView.backgroundColor = UIColor.white
                maxMinusView.isUserInteractionEnabled = false
                maxMinusButton.addSubview(maxMinusView)

                let maxLabel: UILabel = UILabel()
                maxLabel.text = "GRAPH RANGE MAX"
                maxLabel.frame = CGRect(x: minLabel.frame.origin.x,
                                        y: maxMinusButton.frame.origin.y,
                                        width: minLabel.frame.size.width,
                                        height: maxMinusButton.frame.size.height)
                maxLabel.backgroundColor = UIColor.clear
                maxLabel.font = UIFont(name: "HelveticaNeue", size: 12.0)
                maxLabel.textColor = UIColor.white
                maxLabel.textAlignment = .left
                maxLabel.numberOfLines = 1
                mainScrollView.addSubview(maxLabel)

                let maxUnitLabel: UILabel = UILabel()
                maxUnitLabel.text = minUnitLabel.text
                maxUnitLabel.frame = CGRect(x: minUnitLabel.frame.origin.x,
                                            y: maxMinusButton.frame.origin.y,
                                            width: minUnitLabel.frame.size.width,
                                            height: maxMinusButton.frame.size.height)
                maxUnitLabel.backgroundColor = UIColor.clear
                maxUnitLabel.font = UIFont(name: "Migu 2M", size: 14.0)
                maxUnitLabel.textColor = UIColor.white
                maxUnitLabel.textAlignment = .left
                maxUnitLabel.numberOfLines = 1
                mainScrollView.addSubview(maxUnitLabel)

                let maxValueLabel: UILabel = UILabel()
                maxValueLabel.frame = CGRect(x: maxLabel.frame.origin.x + maxLabel.frame.size.width,
                                             y: maxMinusButton.frame.origin.y,
                                             width: labelW,
                                             height: maxMinusButton.frame.size.height)
                maxValueLabel.backgroundColor = UIColor.clear
                maxValueLabel.font = UIFont(name: "Migu 2M", size: 14.0)
                maxValueLabel.textColor = UIColor.fluorescentPink
                maxValueLabel.textAlignment = .right
                maxValueLabel.numberOfLines = 1
                maxValueLabel.text = ""
                if let value = self.graphMaxRanges[element.key] {
                    maxValueLabel.text = String(format:"%.1f", value)
                    if element.key == self.synapseCrystalInfo.temp.key {
                        maxValueLabel.text = String(format:"%.1f", self.getTemperatureValue(SettingFileManager.shared.synapseTemperatureScale, value: Float(value)))
                    }
                }
                mainScrollView.addSubview(maxValueLabel)
                self.graphRangeViewParts![element.key]!["max"] = maxValueLabel

                y += blockW + 10.0

                let lineView: UIView = UIView()
                lineView.frame = CGRect(x: 10.0,
                                        y: y,
                                        width: mainScrollView.frame.size.width - 10.0 * 2,
                                        height: 1.0)
                lineView.backgroundColor = UIColor.white.withAlphaComponent(0.1)
                mainScrollView.addSubview(lineView)

                y += 10.0
            }
            mainScrollView.contentSize = CGSize(width: mainScrollView.frame.width, height: y)
        }
    }

    @objc func changeGraphIsHiddenAction(_ sender: UIButton) {

        if sender.tag < self.graphCategories.count {
            var isDisplay = true
            if let flag = self.graphDisplays[self.graphCategories[sender.tag].key] {
                isDisplay = !flag
                sender.backgroundColor = UIColor.clear
                if isDisplay {
                    sender.backgroundColor = UIColor.white
                }
                for subview in sender.subviews {
                    if subview.tag == 1 {
                        subview.isHidden = !isDisplay
                        break
                    }
                }
                self.graphDisplays[self.graphCategories[sender.tag].key] = isDisplay
            }
        }
    }

    @objc func changeGraphRangeAction(_ sender: UIButton) {

        self.changeGraphRange(sender.tag, scale: 1.0)
    }

    @objc func changeGraphRangeLongPressed(_ sender: UILongPressGestureRecognizer) {

        switch sender.state {
        case UIGestureRecognizerState.began:
            //print("changeGraphRangeLongPressed: began")
            if let view = sender.view {
                self.graphRangeLongPressPt = view.tag
                self.graphRangeLongPressCnt = 0
                self.graphRangeLongPressTimer = Timer.scheduledTimer(timeInterval: 0.1,
                                                                     target: self,
                                                                     selector: #selector(self.changeGraphRangeTimerAction),
                                                                     userInfo: nil,
                                                                     repeats: true)
                self.graphRangeLongPressTimer?.fire()
            }
        case UIGestureRecognizerState.ended:
            //print("changeGraphRangeLongPressed: ended")
            self.graphRangeLongPressTimer?.invalidate()
            self.graphRangeLongPressTimer = nil
            self.graphRangeLongPressPt = nil
        default:
            break
        }
    }

    @objc func changeGraphRangeTimerAction() {

        if let pt = self.graphRangeLongPressPt {
            var scale: Double = 1.0
            if self.graphRangeLongPressCnt > 8 {
                scale = 10.0
            }
            self.changeGraphRange(pt, scale: scale)
            self.graphRangeLongPressCnt += 1
        }
    }

    func changeGraphRange(_ pt: Int, scale: Double) {

        let index: Int = pt / 4
        if index < self.graphCategories.count {
            if let def = self.graphRangeDefault[self.graphCategories[index].key], let minDef = def["min"], let maxDef = def["max"], let interval = def["interval"], let min = self.graphMinRanges[self.graphCategories[index].key], let max = self.graphMaxRanges[self.graphCategories[index].key] {
                if pt % 4 < 2 {
                    if pt % 4 == 0 && min >= max - interval {
                        return
                    }
                    else if pt % 4 == 1 && min <= minDef {
                        return
                    }

                    var value: Double = floor(min / interval) * interval
                    if pt % 4 == 0 {
                        value += interval * scale
                        if value == min {
                            value += interval * scale
                        }
                        if value > max - interval {
                            value = max - interval
                        }
                    }
                    else if pt % 4 == 1 {
                        if value == min {
                            value -= interval * scale
                        }
                        if value < minDef {
                            value = minDef
                        }
                    }

                    self.graphMinRanges[self.graphCategories[index].key] = value
                    if let viewParts = self.graphRangeViewParts, let labels = viewParts[self.graphCategories[index].key], let label = labels["min"] {
                        label.text = String(format:"%.1f", value)
                        if self.graphCategories[index].key == self.synapseCrystalInfo.temp.key {
                            label.text = String(format:"%.1f", self.getTemperatureValue(SettingFileManager.shared.synapseTemperatureScale, value: Float(value)))
                        }
                    }
                }
                else if pt % 4 < 4 {
                    if pt % 4 == 2 && max >= maxDef {
                        return
                    }
                    else if pt % 4 == 3 && max <= min + interval {
                        return
                    }

                    var value: Double = floor(max / interval) * interval
                    if pt % 4 == 2 {
                        value += interval * scale
                        if value == max {
                            value += interval * scale
                        }
                        if value > maxDef {
                            value = maxDef
                        }
                    }
                    else if pt % 4 == 3 {
                        if value == max {
                            value -= interval * scale
                        }
                        if value < min + interval {
                            value = min + interval
                        }
                    }

                    self.graphMaxRanges[self.graphCategories[index].key] = value
                    if let viewParts = self.graphRangeViewParts, let labels = viewParts[self.graphCategories[index].key], let label = labels["max"] {
                        label.text = String(format:"%.1f", value)
                        if self.graphCategories[index].key == self.synapseCrystalInfo.temp.key {
                            label.text = String(format:"%.1f", self.getTemperatureValue(SettingFileManager.shared.synapseTemperatureScale, value: Float(value)))
                        }
                    }
                }
            }
        }
    }

    func changeGraphIsHiddenAction() {

        for (_, element) in self.baseView.subviews.enumerated() {
            if let iv = element as? UIImageView {
                if iv.tag < self.graphCategories.count {
                    if let flag = self.graphDisplays[self.graphCategories[iv.tag].key] {
                        iv.isHidden = !flag
                    }
                }
            }
        }
    }

    @objc func closeDisplaySettingView() {

        if self.isRealtime {
            self.changeRealtimeGraphDataStart()
        }
        else {
            self.closeGraphDataSmallView()
            self.setGraphViews()
            self.changeGraphIsHiddenAction()
        }

        self.graphRangeViewParts = nil
        self.displaySettingView?.removeFromSuperview()
        self.displaySettingView = nil
    }

    // MARK: mark - GraphDatePicker methods

    @objc func displayGraphDatePicker(_ sender: UIButton) {

        //print("displayGraphDatePicker: \(sender.tag)")
        var x: CGFloat = 0
        var y: CGFloat = 0
        var w: CGFloat = self.view.frame.size.width
        var h: CGFloat = self.view.frame.size.height
        self.graphPickerView = UIView()
        self.graphPickerView?.tag = sender.tag
        self.graphPickerView?.frame = CGRect(x: x, y: y, width: w, height: h)
        self.graphPickerView?.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        self.view.addSubview(self.graphPickerView!)

        x = 0
        y = (self.view.frame.size.height - 200.0) / 2
        w = self.view.frame.size.width
        h = 200.0
        self.graphDatePicker = UIDatePicker()
        self.graphDatePicker?.frame = CGRect(x: x, y: y, width: w, height: h)
        self.graphDatePicker?.backgroundColor = UIColor.white
        self.graphDatePicker?.datePickerMode = .dateAndTime
        self.graphDatePicker?.minuteInterval = self.timeRangeInterval
        self.graphPickerView?.addSubview(self.graphDatePicker!)

        self.graphRealtimePicker = UIPickerView()
        self.graphRealtimePicker?.frame = CGRect(x: x, y: y, width: w, height: h)
        self.graphRealtimePicker?.backgroundColor = UIColor.white
        self.graphRealtimePicker?.dataSource = self
        self.graphRealtimePicker?.delegate = self
        self.graphPickerView?.addSubview(self.graphRealtimePicker!)
        if let row = self.realtimeGraphTimeIntervals.index(of: self.realtimeGraphTimeIntervalKey) {
            self.graphRealtimePicker?.selectRow(row, inComponent: 0, animated: true)
            self.graphRealtimePicker?.reloadComponent(0)
        }

        w = 40.0
        h = 40.0
        x = self.view.frame.size.width - (w + 10.0)
        y = (self.view.frame.size.height - 200.0) / 2 - (h + 10.0)
        self.graphPickerCancelBtn = UIButton()
        self.graphPickerCancelBtn?.tag = 0
        self.graphPickerCancelBtn?.frame = CGRect(x: x, y: y, width: w, height: h)
        self.graphPickerCancelBtn?.backgroundColor = UIColor.clear
        self.graphPickerCancelBtn?.addTarget(self, action: #selector(self.setGraphDateAction(_:)), for: .touchUpInside)
        self.graphPickerView?.addSubview(self.graphPickerCancelBtn!)

        w = 18.0
        h = 18.0
        x = (self.graphPickerCancelBtn!.frame.size.width - w) / 2
        y = (self.graphPickerCancelBtn!.frame.size.height - h) / 2
        let closeIcon: CrossView = CrossView()
        closeIcon.frame = CGRect(x: x, y: y, width: w, height: h)
        closeIcon.backgroundColor = UIColor.clear
        closeIcon.isUserInteractionEnabled = false
        closeIcon.lineColor = UIColor.white
        self.graphPickerCancelBtn!.addSubview(closeIcon)

        self.graphDatePicker?.date = Date()
        self.graphDatePicker?.minimumDate = Date()
        self.graphDatePicker?.maximumDate = Date()
        if sender.tag == 1 {
            let now: Date = self.makeGraphDateNow()
            let dateFormatter: DateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.dateFormat = "yyyyMMdd"
            let dateStr: String = dateFormatter.string(from: now)
            dateFormatter.dateFormat = "yyyyMMddHHmmss"
            let date: Date = dateFormatter.date(from: "\(dateStr)000000")!
            self.graphDatePicker?.minimumDate = Date(timeInterval: -self.timeRangeMax, since: date)
            self.graphDatePicker?.maximumDate = Date(timeInterval: -self.timeRangeMin, since: self.endDate!)

            self.graphDatePicker?.date = self.startDate!
            if self.isRealtime, let startDate = self.startDate {
                self.graphDatePicker?.date = Date(timeIntervalSince1970: floor(startDate.timeIntervalSince1970 / 300) * 300)
            }
        }
        else if sender.tag == 2 {
            self.graphDatePicker?.minimumDate = Date(timeInterval: self.timeRangeMin, since: self.startDate!)

            let now: Date = self.makeGraphDateNow()
            let dateFormatter: DateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.dateFormat = "yyyyMMddHHmm"
            let dateStr: String = dateFormatter.string(from: now)
            dateFormatter.dateFormat = "yyyyMMddHHmmss"
            self.graphDatePicker?.maximumDate = dateFormatter.date(from: "\(dateStr)00")

            self.graphDatePicker?.date = self.endDate!
            if self.isRealtime, let endDate = self.endDate {
                self.graphDatePicker?.date = Date(timeIntervalSince1970: ceil(endDate.timeIntervalSince1970 / 300) * 300)
            }
        }

        self.graphDatePicker?.isHidden = true
        self.graphRealtimePicker?.isHidden = true
        if self.isRealtime {
            self.graphRealtimePicker?.isHidden = false
        }
        else {
            self.graphDatePicker?.isHidden = false
        }
    }

    func removeGraphDatePicker() {

        self.graphPickerCancelBtn?.removeFromSuperview()
        self.graphPickerCancelBtn = nil
        self.graphDatePicker?.removeFromSuperview()
        self.graphDatePicker = nil
        self.graphRealtimePicker?.removeFromSuperview()
        self.graphRealtimePicker = nil
        self.graphPickerView?.removeFromSuperview()
        self.graphPickerView = nil
    }

    @objc func setGraphDateAction(_ sender: UIButton) {

        if !self.graphDatePicker!.isHidden {
            var isUpdate: Bool = false
            if self.graphPickerView?.tag == 1 {
                if self.startDate != self.graphDatePicker?.date {
                    self.startDate = self.graphDatePicker?.date
                    isUpdate = true
                }
            }
            else if self.graphPickerView?.tag == 2 {
                if self.endDate != self.graphDatePicker?.date {
                    self.endDate = self.graphDatePicker?.date
                    isUpdate = true
                }
            }
            //print("setGraphDateAction: \(self.startDate), \(self.endDate)")
            if isUpdate {
                self.changePeriodGraphDataStart()
            }
        }
        else if !self.graphRealtimePicker!.isHidden {
            var isUpdate: Bool = false
            let selectedRow: Int = self.graphRealtimePicker!.selectedRow(inComponent: 0)
            if selectedRow < self.realtimeGraphTimeIntervals.count && self.realtimeGraphTimeIntervalKey != self.realtimeGraphTimeIntervals[selectedRow] {
                self.realtimeGraphTimeIntervalKey = self.realtimeGraphTimeIntervals[selectedRow]
                //print("setGraphDateAction graphRealtimePicker: \(self.realtimeGraphTimeInterval)")
                if let values = self.realtimeGraphTimeIntervalValues[self.realtimeGraphTimeIntervalKey], let interval = values["interval"] {
                    self.realtimeGraphTimeInterval = interval
                    isUpdate = true
                }
            }
            if isUpdate {
                self.setRealtimeUnitViews()
                self.changeRealtimeGraphDataStart()
            }
        }

        self.removeGraphDatePicker()
    }

    // MARK: mark - TouchEvent methods

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        if self.isSoundPlay {
            return
        }

        let touchEvent: UITouch = touches.first!
        //print("touchesBegan x:\(touchEvent.location(in: self.baseView).x) y:\(touchEvent.location(in: self.baseView).y)")
        self.setSelectLine(touchEvent.location(in: self.baseView).x)
        if self.graphSelectpt >= 0 {
            self.selectLineView.isHidden = false
            self.enableGraphDataSmallView()
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {

        if self.isSoundPlay {
            return
        }

        let touchEvent: UITouch = touches.first!
        //print("touchesMoved x:\(touchEvent.previousLocation(in: self.baseView).x) y:\(touchEvent.previousLocation(in: self.baseView).y) -> x:\(touchEvent.location(in: self.baseView).x) y:\(touchEvent.location(in: self.baseView).y)")
        self.setSelectLine(touchEvent.location(in: self.baseView).x)
        if self.graphSelectpt >= 0 {
            self.enableGraphDataSmallView()
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {

        if self.isSoundPlay {
            return
        }

        //let touchEvent = touches.first!
        //print("touchesEnded x:\(touchEvent.location(in: self.baseView).x) y:\(touchEvent.location(in: self.baseView).y)")
    }

    func setSelectLine(_ x: CGFloat) {

        self.graphSelectpt = -1
        if self.graphBlock > 0 {
            self.setSelectPoint(x)

            var lineX: CGFloat = CGFloat(self.graphSelectpt) * self.graphBlock
            if self.isRealtime {
                lineX += self.graphX
                if self.graphSelectpt == self.graphCnt - 1 {
                    lineX = self.graphX + self.graphW - self.graphCirclePointW
                }
            }
            self.selectLineView.frame = CGRect(x: lineX,
                                               y: self.selectLineView.frame.origin.y,
                                               width: self.selectLineView.frame.size.width,
                                               height: self.selectLineView.frame.size.height)
            self.selectLineView.isHidden = false
        }
    }

    func setSelectPoint(_ x: CGFloat) {

        if self.graphBlock > 0 {
            self.graphSelectpt = Int(floor(x / self.graphBlock))
            if self.isRealtime {
                self.graphSelectpt = Int(floor((x - self.graphX) / self.graphBlock))
            }
            if self.graphSelectpt > self.graphCnt - 1 {
                self.graphSelectpt = self.graphCnt - 1
            }
        }
    }

    // MARK: mark - GraphDataSmallView methods

    func setGraphDataSmallView() {

        self.graphDataSmallView = UIView()
        self.graphDataSmallView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        self.graphDataSmallView.isHidden = true
        self.view.addSubview(self.graphDataSmallView)

        var x: CGFloat = 0
        var y: CGFloat = 0
        var w: CGFloat = 40.0
        var h: CGFloat = 40.0
        self.graphDataSmallCloseButton = UIButton()
        self.graphDataSmallCloseButton.frame = CGRect(x: x, y: y, width: w, height: h)
        self.graphDataSmallCloseButton.backgroundColor = UIColor.clear
        self.graphDataSmallCloseButton.addTarget(self, action: #selector(self.closeGraphDataSmallView), for: .touchUpInside)
        self.graphDataSmallView.addSubview(self.graphDataSmallCloseButton)

        w = 16.0
        h = 16.0
        x = (self.graphDataSmallCloseButton.frame.size.width - w) / 2
        y = (self.graphDataSmallCloseButton.frame.size.height - h) / 2
        let closeIcon: CrossView = CrossView()
        closeIcon.frame = CGRect(x: x, y: y, width: w, height: h)
        closeIcon.backgroundColor = UIColor.clear
        closeIcon.isUserInteractionEnabled = false
        closeIcon.lineColor = UIColor.white
        self.graphDataSmallCloseButton.addSubview(closeIcon)

        x = self.graphDataSmallCloseButton.frame.origin.x + self.graphDataSmallCloseButton.frame.size.width
        y = self.graphDataSmallCloseButton.frame.origin.y
        w = 24.0 + 50.0
        h = self.graphDataSmallCloseButton.frame.size.height
        self.graphDataSmallOpenButton = UIButton()
        self.graphDataSmallOpenButton.frame = CGRect(x: x, y: y, width: w, height: h)
        self.graphDataSmallOpenButton.backgroundColor = UIColor.clear
        self.graphDataSmallOpenButton.addTarget(self, action: #selector(self.setGraphDataView), for: .touchUpInside)
        self.graphDataSmallView.addSubview(self.graphDataSmallOpenButton)

        w = 9.0
        h = 17.0
        x = 8.0
        y = (self.graphDataSmallOpenButton.frame.size.height - h) / 2
        let openIcon: ArrowView = ArrowView()
        openIcon.frame = CGRect(x: x, y: y, width: w, height: h)
        openIcon.backgroundColor = UIColor.clear
        openIcon.isUserInteractionEnabled = false
        openIcon.type = ArrowView.left
        openIcon.triangleColor = UIColor.white
        self.graphDataSmallOpenButton.addSubview(openIcon)

        x = openIcon.frame.origin.x + openIcon.frame.size.width + 6.0
        y = 0
        w = self.graphDataSmallOpenButton.frame.size.width - x
        h = self.graphDataSmallOpenButton.frame.size.height
        let openLabel: UILabel = UILabel()
        openLabel.frame = CGRect(x: x, y: y, width: w, height: h)
        openLabel.text = "Detail"
        openLabel.font = UIFont(name: "HelveticaNeue", size: 18.0)
        openLabel.textColor = UIColor.white
        openLabel.backgroundColor = UIColor.clear
        openLabel.textAlignment = .left
        openLabel.numberOfLines = 1
        self.graphDataSmallOpenButton.addSubview(openLabel)

        x = 8.0
        y = 44.0
        w = 0
        h = 20.0
        self.graphDataSmallDateLabel = UILabel()
        self.graphDataSmallDateLabel.frame = CGRect(x: x, y: y, width: w, height: h)
        self.graphDataSmallDateLabel.text = ""
        self.graphDataSmallDateLabel.font = UIFont(name: "HelveticaNeue", size: 16.0)
        self.graphDataSmallDateLabel.textColor = UIColor.white
        self.graphDataSmallDateLabel.backgroundColor = UIColor.clear
        self.graphDataSmallDateLabel.textAlignment = .left
        self.graphDataSmallDateLabel.numberOfLines = 1
        self.graphDataSmallDateLabel.isUserInteractionEnabled = false
        self.graphDataSmallView.addSubview(self.graphDataSmallDateLabel)

        self.graphDataViewParts = [:]
        for (_, element) in self.graphCategories.enumerated() {
            var views: [UIView] = []

            let icon: UIView = UIView()
            //icon.tag = index
            icon.backgroundColor = element.graphColor
            icon.clipsToBounds = true
            icon.isUserInteractionEnabled = false
            icon.isHidden = true
            self.graphDataSmallView.addSubview(icon)
            views.append(icon)

            let label: UILabel = UILabel()
            //label.tag = index * 2
            label.font = UIFont(name: "Migu 2M", size: 16.0)
            label.textColor = UIColor.fluorescentPink
            label.backgroundColor = UIColor.clear
            label.textAlignment = .left
            label.numberOfLines = 1
            label.isUserInteractionEnabled = false
            label.isHidden = true
            self.graphDataSmallView.addSubview(label)
            views.append(label)

            let labelUnit: UILabel = UILabel()
            //labelAlt.tag = index * 2 + 1
            labelUnit.font = UIFont(name: "HelveticaNeue", size: 16.0)
            labelUnit.textColor = UIColor.white
            labelUnit.backgroundColor = UIColor.clear
            labelUnit.textAlignment = .left
            labelUnit.numberOfLines = 1
            labelUnit.isUserInteractionEnabled = false
            labelUnit.isHidden = true
            if element.key == self.synapseCrystalInfo.co2.key {
                labelUnit.text = "ppm"
            }
            else if element.key == self.synapseCrystalInfo.temp.key {
                labelUnit.text = self.getTemperatureUnit(SettingFileManager.shared.synapseTemperatureScale)
            }
            else if element.key == self.synapseCrystalInfo.hum.key {
                labelUnit.text = "%"
            }
            else if element.key == self.synapseCrystalInfo.ill.key {
                labelUnit.text = "lux"
            }
            else if element.key == self.synapseCrystalInfo.press.key {
                labelUnit.text = "hPa"
            }
            else if element.key == self.synapseCrystalInfo.volt.key {
                labelUnit.text = "V"
            }
            self.graphDataSmallView.addSubview(labelUnit)
            views.append(labelUnit)

            self.graphDataViewParts[element.key] = views
        }
    }

    func enableGraphDataSmallView() {

        var x: CGFloat = 0
        var y: CGFloat = self.graphDataSmallDateLabel.frame.origin.y + self.graphDataSmallDateLabel.frame.size.height + 5.0
        var w: CGFloat = 0
        var h: CGFloat = 0
        var maxW: CGFloat = 0
        for (_, element) in self.graphCategories.enumerated() {
            if let views = self.graphDataViewParts[element.key], views.count > 2 {
                let icon: UIView = views[0]
                let label: UILabel = views[1] as! UILabel
                let labelUnit: UILabel = views[2] as! UILabel
                icon.isHidden = true
                label.isHidden = true
                labelUnit.isHidden = true
                if let flag = self.graphDisplays[element.key], flag {
                    icon.isHidden = false
                    label.isHidden = false
                    labelUnit.isHidden = false

                    w = 14.0
                    h = 14.0
                    x = 10.0
                    icon.frame = CGRect(x: x + (20.0 - w) / 2, y: y + (20.0 - h) / 2, width: w, height: h)
                    icon.layer.cornerRadius = w / 2

                    label.text = "-"
                    if let data = self.graphDataList[element.key], data.count > self.graphSelectpt, let value = data[self.graphSelectpt] {
                        label.text = String(format:"%.1f", value)
                        if element.key == self.synapseCrystalInfo.temp.key {
                            label.text = String(format:"%.1f", self.getTemperatureValue(SettingFileManager.shared.synapseTemperatureScale, value: Float(value)))
                        }
                    }
                    label.sizeToFit()
                    x += w + 10.0
                    w = label.frame.size.width
                    h = 20.0
                    label.frame = CGRect(x: x, y: y, width: w, height: h)

                    labelUnit.sizeToFit()
                    x += w + 5.0
                    w = labelUnit.frame.size.width
                    h = 20.0
                    labelUnit.frame = CGRect(x: x, y: y, width: w, height: h)

                    y += h + 5.0
                    if maxW < x + w + 10.0 {
                        maxW = x + w + 10.0
                    }
                }
            }
        }

        self.graphDataSmallDateLabel.text = ""
        if self.graphDates.count > self.graphSelectpt {
            let dateFormatter: DateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.dateFormat = "yyyy.M.d HH:mm:ss"
            self.graphDataSmallDateLabel.text = dateFormatter.string(from: self.graphDates[self.graphSelectpt])
        }
        //print("setGraphData: \(self.graphSelectpt), \(self.graphDataSmallDateLabel.text)")

        if maxW > 0 {
            w = maxW + 10.0
            if w < self.baseView.frame.size.width / 2 {
                w = self.baseView.frame.size.width / 2
            }
            else if w < self.graphDataSmallCloseButton.frame.size.width + self.graphDataSmallOpenButton.frame.size.width {
                w = self.graphDataSmallCloseButton.frame.size.width + self.graphDataSmallOpenButton.frame.size.width
            }
            h = y + 10.0
            x = 0
            if self.selectLineView.frame.origin.x + self.selectLineView.frame.size.width < self.baseView.frame.size.width / 2 {
                x = self.baseView.frame.size.width - w
            }
            y = self.baseView.frame.origin.y

            self.graphDataSmallView.isHidden = false
            self.graphDataSmallView.frame = CGRect(x: x, y: y, width: w, height: h)
            self.graphDataSmallOpenButton.frame = CGRect(x: 0, y: self.graphDataSmallOpenButton.frame.origin.y, width: self.graphDataSmallOpenButton.frame.size.width, height: self.graphDataSmallOpenButton.frame.size.height)
            self.graphDataSmallCloseButton.frame = CGRect(x: w - (self.graphDataSmallCloseButton.frame.size.width), y: self.graphDataSmallCloseButton.frame.origin.y, width: self.graphDataSmallCloseButton.frame.size.width, height: self.graphDataSmallCloseButton.frame.size.height)
            self.graphDataSmallDateLabel.frame = CGRect(x: self.graphDataSmallDateLabel.frame.origin.x, y: self.graphDataSmallDateLabel.frame.origin.y, width: w - self.graphDataSmallDateLabel.frame.origin.x, height: self.graphDataSmallDateLabel.frame.size.height)
        }
        else {
            self.graphDataSmallView.isHidden = true
        }
    }

    @objc func closeGraphDataSmallView() {

        self.graphDataSmallView.isHidden = true
        self.selectLineView.isHidden = true
    }

    // MARK: mark - GraphDataView methods

    @objc func setGraphDataView() {

        self.closeGraphDataSmallView()

        if let nav = self.navigationController as? NavigationController {
            self.graphValues = []
            for (_, element) in self.graphCategories.enumerated() {
                if let flag = self.graphDisplays[element.key], flag {
                    self.graphValues.append(element)
                }
            }

            if self.graphValues.count > 0 {
                var x: CGFloat = 0
                var y: CGFloat = 0
                var w: CGFloat = nav.view.frame.size.width
                var h: CGFloat = nav.view.frame.size.height
                self.graphDataView = UIView()
                self.graphDataView?.frame = CGRect(x: x, y: y, width: w, height: h)
                self.graphDataView?.backgroundColor = UIColor.black.withAlphaComponent(0.9)
                nav.view.addSubview(self.graphDataView!)

                w = 44.0
                h = 44.0
                x = self.graphDataView!.frame.size.width - w
                y = 20.0
                if #available(iOS 11.0, *) {
                    y = self.view.safeAreaInsets.top
                }
                let closeButton: UIButton = UIButton()
                closeButton.tag = 2
                closeButton.frame = CGRect(x: x, y: y, width: w, height: h)
                closeButton.backgroundColor = UIColor.clear
                closeButton.addTarget(self, action: #selector(self.closeGraphDataView), for: .touchUpInside)
                self.graphDataView?.addSubview(closeButton)

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

                x = 0
                y = closeButton.frame.origin.y + closeButton.frame.size.height
                w = self.graphDataView!.frame.size.width
                h = self.graphDataView!.frame.size.height - y
                let tableView: UITableView = UITableView()
                tableView.frame = CGRect(x: x, y: y, width: w, height: h)
                tableView.backgroundColor = UIColor.clear
                tableView.separatorStyle = .none
                tableView.delegate = self
                tableView.dataSource = self
                self.graphDataView?.addSubview(tableView)
            }
        }
    }

    @objc func closeGraphDataView() {

        self.graphDataView?.removeFromSuperview()
        self.graphDataView = nil
    }

    // MARK: mark - NotificationCenter methods

    @objc func viewWillEnterForeground(notification: Notification) {

        if self.isRealtime {
            self.changeRealtimeGraphDataStart(3.0)
        }
    }

    @objc func viewDidEnterBackground(notification: Notification) {

        self.realtimeGraphTimer?.invalidate()
        self.realtimeGraphTimer = nil
    }

    // MARK: mark - UITableViewDataSource methods

    func numberOfSections(in tableView: UITableView) -> Int {

        let sections: Int = self.graphValues.count
        return sections
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        var num: Int = 0
        if section < self.graphValues.count {
            num = 3
        }
        return num
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell: UITableViewCell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        cell.backgroundColor = UIColor.clear
        cell.selectionStyle = .none

        if indexPath.section < self.graphValues.count {
            let crystal: CrystalStruct = self.graphValues[indexPath.section]
            if indexPath.row == 0 {
                let cell: GraphDataTableViewCell = GraphDataTableViewCell(style: .default, reuseIdentifier: "top_cell")
                cell.backgroundColor = UIColor.clear
                cell.selectionStyle = .none

                cell.type = 1
                cell.titleLabel.text = crystal.name
                cell.iconImageView.image = nil
                if crystal.key == self.synapseCrystalInfo.co2.key {
                    cell.iconImageView.image = UIImage.co2LW
                }
                else if crystal.key == self.synapseCrystalInfo.temp.key {
                    cell.iconImageView.image = UIImage.temperatureLW
                }
                else if crystal.key == self.synapseCrystalInfo.hum.key {
                    cell.iconImageView.image = UIImage.humidityLW
                }
                else if crystal.key == self.synapseCrystalInfo.ill.key {
                    cell.iconImageView.image = UIImage.illuminationLW
                }
                else if crystal.key == self.synapseCrystalInfo.press.key {
                    cell.iconImageView.image = UIImage.airpressureLW
                }
                else if crystal.key == self.synapseCrystalInfo.sound.key {
                    cell.iconImageView.image = UIImage.environmentalsoundLW
                }
                else if crystal.key == self.synapseCrystalInfo.move.key {
                    cell.iconImageView.image = UIImage.movementLW
                }
                else if crystal.key == self.synapseCrystalInfo.angle.key {
                    cell.iconImageView.image = UIImage.angleLW
                }
                else if crystal.key == self.synapseCrystalInfo.volt.key {
                    cell.iconImageView.image = UIImage.magneticfieldLW
                }
                return cell
            }
            else if indexPath.row == 1 {
                let cell: GraphDataTableViewCell = GraphDataTableViewCell(style: .default, reuseIdentifier: "value_cell")
                cell.backgroundColor = UIColor.clear
                cell.selectionStyle = .none

                cell.type = 0
                cell.text1Label.text = "-"
                if let data = self.graphDataList[crystal.key], data.count > self.graphSelectpt, let value = data[self.graphSelectpt] {
                    cell.text1Label.text = String(format:"%.1f", value)
                    if crystal.key == self.synapseCrystalInfo.temp.key {
                        cell.text1Label.text = String(format:"%.1f", self.getTemperatureValue(SettingFileManager.shared.synapseTemperatureScale, value: Float(value)))
                    }
                }
                cell.text2Label.text = ""
                if crystal.key == self.synapseCrystalInfo.co2.key {
                    cell.text2Label.text = "ppm"
                }
                else if crystal.key == self.synapseCrystalInfo.temp.key {
                    cell.text2Label.text = self.getTemperatureUnit(SettingFileManager.shared.synapseTemperatureScale)
                }
                else if crystal.key == self.synapseCrystalInfo.hum.key {
                    cell.text2Label.text = "%"
                }
                else if crystal.key == self.synapseCrystalInfo.ill.key {
                    cell.text2Label.text = "lux"
                }
                else if crystal.key == self.synapseCrystalInfo.press.key {
                    cell.text2Label.text = "hPa"
                }
                else if crystal.key == self.synapseCrystalInfo.volt.key {
                    cell.text2Label.text = "V"
                }

                cell.text3Label.text = ""
                cell.text4Label.text = ""
                cell.text5Label.text = ""
                cell.text6Label.text = ""
                if let min = self.graphMinValues[crystal.key], let max = self.graphMaxValues[crystal.key] {
                    cell.text3Label.text = "("
                    cell.text4Label.text = String(format:"%.1f - %.1f", min, max)
                    if crystal.key == self.synapseCrystalInfo.temp.key {
                        cell.text4Label.text = String(format:"%.1f - %.1f", self.getTemperatureValue(SettingFileManager.shared.synapseTemperatureScale, value: Float(min)), self.getTemperatureValue(SettingFileManager.shared.synapseTemperatureScale, value: Float(max)))
                    }
                    cell.text5Label.text = cell.text2Label.text
                    cell.text6Label.text = ")"
                }
                return cell
            }
            else if indexPath.row == 2 {
                let cell: GraphDataTableViewCell = GraphDataTableViewCell(style: .default, reuseIdentifier: "bottom_cell")
                cell.backgroundColor = UIColor.clear
                cell.selectionStyle = .none
                cell.type = 2
                return cell
            }
        }
        return cell
    }

    // MARK: mark - UITableViewDelegate methods

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        var height: CGFloat = 0
        if indexPath.section < self.graphValues.count {
            let cell: GraphDataTableViewCell = GraphDataTableViewCell()
            cell.type = -1
            if indexPath.row == 0 {
                cell.type = 1
            }
            else if indexPath.row == 1 {
                cell.type = 0
            }
            else if indexPath.row == 2 {
                cell.type = 2
            }
            height = cell.getCellHeight()
        }
        return height
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: false)
    }

    // MARK: mark - UIPickerViewDataSource methods

    func numberOfComponents(in pickerView: UIPickerView) -> Int {

        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {

        return self.realtimeGraphTimeIntervals.count
    }

    // MARK: mark - PickerViewDelegate methods
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {

        return self.realtimeGraphTimeIntervals[row]
    }

    // MARK: mark - Audio methods

    @objc func changeAudioStatus() {

        if self.isSoundPlay {
            self.stopAudio()
        }
        else {
            self.playAudio()
        }
    }

    func playAudio() {

        self.isSoundPlay = true

        if let nav = self.navigationController as? NavigationController {
            nav.topVC.stopAudio()
        }
        if self.isRealtime {
            self.realtimeGraphTimer?.invalidate()
            self.realtimeGraphTimer = nil

            if self.graphDates.count > 0 {
                self.realtimeGraphBlock = (self.graphW - self.graphCirclePointW) / CGFloat(self.graphDates.count)
            }
            else {
                self.realtimeGraphBlock = self.graphBlock
            }
        }

        self.dateStartButton.isEnabled = false
        self.dateEndButton.isEnabled = false
        self.displaySettingButton.isEnabled = false
        self.closeGraphDataSmallView()

        self.synapseSoundValues = SynapseValues("sound")
        self.synapseSoundStartDate = Date()
        self.synapseSoundPt = nil
        self.synapseSound = SynapseSound()
        self.synapseSound?.play(isRoop: true)

        self.synapseSoundTimer = Timer.scheduledTimer(timeInterval: self.synapseSound!.getRoopTime(),
                                                      target: self,
                                                      selector: #selector(self.checkAudio),
                                                      userInfo: nil,
                                                      repeats: true)
        self.synapseSoundTimer?.fire()
    }

    func stopAudio() {

        self.synapseSoundTimer?.invalidate()
        self.synapseSoundTimer = nil

        self.synapseSound?.stop()
        self.synapseSound = nil

        self.dateStartButton.isEnabled = true
        self.dateEndButton.isEnabled = true
        self.displaySettingButton.isEnabled = true
        self.selectLineView.isHidden = true

        if let nav = self.navigationController as? NavigationController {
            nav.topVC.playAudioStart(synapseObject: nav.topVC.mainSynapseObject)
        }
        if self.isRealtime {
            self.changeRealtimeGraphDataStart()
        }

        self.isSoundPlay = false
    }
    
    @objc func checkAudio() {

        if self.isSoundPlay, let start = self.synapseSoundStartDate {
            let date: Date = Date()
            let time: TimeInterval = date.timeIntervalSince(start) / 2
            let pt: Int = Int(floor(time))
            if pt < self.graphDates.count {
                //print("checkAudio: \(self.graphDates[pt])")
                var lineX: CGFloat = CGFloat(time) * self.graphBlock
                if self.isRealtime {
                    lineX = CGFloat(time) * self.realtimeGraphBlock + self.graphX
                }

                self.selectLineView.frame = CGRect(x: lineX,
                                                   y: self.selectLineView.frame.origin.y,
                                                   width: self.selectLineView.frame.size.width,
                                                   height: self.selectLineView.frame.size.height)
                self.selectLineView.isHidden = false

                if self.synapseSoundPt != pt {
                    //print("checkAudio: \(pt) -> \(self.graphDates[pt])")
                    self.synapseSoundValues?.co2 = nil
                    if let data = self.graphDataList[self.synapseCrystalInfo.co2.key], data.count > pt, let value = data[pt] {
                        self.synapseSoundValues?.co2 = Int(value)
                    }
                    self.synapseSoundValues?.temp = nil
                    if let data = self.graphDataList[self.synapseCrystalInfo.temp.key], data.count > pt, let value = data[pt] {
                        self.synapseSoundValues?.temp = Float(value)
                    }
                    self.synapseSoundValues?.humidity = nil
                    if let data = self.graphDataList[self.synapseCrystalInfo.hum.key], data.count > pt, let value = data[pt] {
                        self.synapseSoundValues?.humidity = Int(value)
                    }
                    self.synapseSoundValues?.light = nil
                    if let data = self.graphDataList[self.synapseCrystalInfo.ill.key], data.count > pt, let value = data[pt] {
                        self.synapseSoundValues?.light = Int(value)
                    }
                    self.synapseSoundValues?.pressure = nil
                    if let data = self.graphDataList[self.synapseCrystalInfo.press.key], data.count > pt, let value = data[pt] {
                        self.synapseSoundValues?.pressure = Float(value)
                    }
                    self.synapseSound?.setSynapseValues(self.synapseSoundValues!)
                }
                self.synapseSoundPt = pt

                self.synapseSound?.checkSound(date: Date())
                /*let date: Date = Date()
                DispatchQueue.global(qos: .background).async {
                    //print("\(Date()) checkSoundTimer")
                    self.synapseSound?.checkSound(date: date)
                }*/
            }
            else {
                self.stopAudio()
            }
        }
    }
}
