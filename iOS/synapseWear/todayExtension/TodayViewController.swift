//
//  TodayViewController.swift
//  synapsewear
//
//  Copyright © 2018 art and program, Inc. For license and other information refer to https://github.com/artandprogram/synapseWear. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {

    @IBOutlet weak var co2Value: UILabel!
    @IBOutlet weak var batteryValue: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var tempHumidLabel: UILabel!
    @IBOutlet weak var pressureLabel: UILabel!
    @IBOutlet weak var minLabel: UILabel!
    @IBOutlet weak var maxLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var graphView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let _ = self.reloadData()
    }

    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.

        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData

        guard self.reloadData() else {
            completionHandler(NCUpdateResult.failed)
            return
        }
        completionHandler(NCUpdateResult.newData)
    }

    @IBAction func tapped(_ sender: Any) {

        if let url = URL(string: "synapseWear://") {
            extensionContext?.open(url, completionHandler: nil)
        }
    }

    func reloadData() -> Bool {

        guard let userDefaults = TodayExtensionData.read() else {
            return false
        }

        let updateLimit: TimeInterval = 30 * 60.0
        let updatedAt: TimeInterval = userDefaults.double(forKey: "updatedAt")
        let updatedDate: Date = Date(timeIntervalSince1970: updatedAt)
        if updatedDate.timeIntervalSinceNow > -updateLimit {
            let co2: Int = userDefaults.integer(forKey: "co2")
            let battery: Int = Int(userDefaults.float(forKey: "battery"))
            let temp: Float = userDefaults.float(forKey: "temp")
            let humidity: Int = userDefaults.integer(forKey: "humidity")
            let pressure: Float = userDefaults.float(forKey: "pressure")
            let graphData: [Any]? = userDefaults.array(forKey: "graphData")
            let minutes: Int = abs(Int(updatedDate.timeIntervalSinceNow)) / 60

            self.updateViewWithData(co2: co2, battery: battery, temp: temp, humidity: humidity, pressure: pressure, updateMins: minutes)
            self.updateGraph(co2: co2, graphData: graphData)
        }
        else {
            self.updateViewWithNoData()
        }
        return true
    }

    func updateViewWithData(co2: Int, battery: Int, temp: Float, humidity: Int, pressure: Float, updateMins: Int){

        if co2 < 0 {
            self.co2Value.text = "---"
        }
        else {
            self.co2Value.text = String(format: "%dppm", co2)
        }

        if battery < 0 {
            self.batteryValue.text = "---"
        }
        else {
            self.batteryValue.text = String(format: "%d%%", battery)
        }

        self.tempHumidLabel.isHidden = false
        var str: String = ""
        if temp >= 0.0 {
            str = String(format: "%.1f℃ ", temp)
        }
        if humidity >= 0 {
            str = "\(str)\(String(format: "%d%%", humidity))"
        }
        self.tempHumidLabel.text = str
        if str.count <= 0 {
            self.tempHumidLabel.isHidden = true
        }

        if pressure < 0 {
            self.pressureLabel.text = ""
            self.pressureLabel.isHidden = true
        }
        else {
            self.pressureLabel.text = String(format: "%.1fhPa", pressure)
            self.pressureLabel.isHidden = false
        }

        if updateMins == 0 {
            self.dateLabel.text = "now"
        }
        else if updateMins == 1 {
            self.dateLabel.text = String(format: "%dmin ago", updateMins)
        }
        else {
            self.dateLabel.text = String(format: "%dmins ago", updateMins)
        }
    }

    func updateGraph(co2: Int, graphData: [Any]?) {

        if let data = graphData as? [Int] {
            if let maxGraphVal = data.max() {
                self.maxLabel.text = String(max(maxGraphVal, co2))
            }
            self.graphView.image = self.makeGraphImage(data: data, color: UIColor.white, imageW: self.graphView.frame.width, imageH: self.graphView.frame.height)

            self.graphView.backgroundColor = UIColor(white: 0, alpha: 0.1)
            self.maxLabel.isHidden = false
            self.minLabel.isHidden = false
            self.timeLabel.isHidden = false
        }
    }

    func updateViewWithNoData() {

        self.co2Value.text = "---"
        self.batteryValue.text = "---"
        self.dateLabel.text = "No Data"
        self.tempHumidLabel.isHidden = true
        self.pressureLabel.isHidden = true
        self.graphView.image = nil
        self.graphView.backgroundColor = UIColor.clear
        self.maxLabel.isHidden = true
        self.minLabel.isHidden = true
        self.timeLabel.isHidden = true
    }

    func makeGraphImage(data: [Int], color: UIColor, imageW: CGFloat, imageH: CGFloat) -> UIImage? {

        var image: UIImage? = nil
        UIGraphicsBeginImageContextWithOptions(CGSize(width: imageW, height: imageH), false, 0)

        let offsetH: CGFloat = 5.0
        let graphH: CGFloat = imageH - offsetH * 2
        let min: Int = 400
        var max: Int = data.max() ?? 400
        if max <= min {
            max = 440
        }
        let hRatio: CGFloat = graphH / CGFloat(max - min)
        let wRatio: CGFloat = (imageW - 10) / CGFloat(data.count)

        let nowX: CGFloat = imageW - 10
        let nowY: CGFloat = graphH - CGFloat(data[0] - min) * hRatio + offsetH

        if data[0] > 0 {
            let circlePath: UIBezierPath = UIBezierPath(ovalIn: CGRect(x: nowX - 3.0, y: nowY - 3.0, width: 6.0, height: 6.0))
            color.setFill()
            circlePath.fill()
        }

        let guideX: CGFloat = nowX - wRatio * CGFloat(30)
        let guide: UIBezierPath = UIBezierPath()
        guide.move(to: CGPoint(x: guideX, y: 0))
        guide.addLine(to: CGPoint(x: guideX, y: imageH))
        guide.close()
        guide.lineWidth = 1.0
        UIColor(white: 0, alpha: 0.1).setStroke()
        guide.stroke()

        for (index, val) in data.enumerated() {
            if val < 0 {
                continue
            }

            let rx: CGFloat = nowX - wRatio * CGFloat(index)
            let ry: CGFloat = graphH - CGFloat(val - min) * hRatio + offsetH
            let circlePath: UIBezierPath = UIBezierPath(ovalIn: CGRect(x: rx - 1.0, y: ry - 1.0, width: 2.0, height: 2.0))
            color.setFill()
            circlePath.fill()

            guard index != data.count - 1 else {
                continue
            }

            let nextVal: Int = data[index + 1]
            if nextVal > 0 {
                let lx: CGFloat = rx - wRatio
                let ly: CGFloat = graphH - CGFloat(nextVal - min) * hRatio + offsetH

                let line: UIBezierPath = UIBezierPath()
                line.move(to: CGPoint(x: rx, y: ry))
                line.addLine(to: CGPoint(x: lx, y: ly))
                line.close()
                line.lineWidth = 1.0
                color.setStroke()
                line.stroke()
            }
        }

        image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
