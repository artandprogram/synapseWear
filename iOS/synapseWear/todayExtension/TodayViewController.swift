//
//  TodayViewController.swift
//  todayExtension
//
//  Created by toru on 2018/11/27.
//  Copyright © 2018年 art and program, Inc. For license and other information refer to https://github.com/artandprogram/synapseWear. All rights reserved.
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
        let _ = reloadData();
    }
        
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        guard reloadData() else {
            completionHandler(NCUpdateResult.failed)
            return
        }
        
        completionHandler(NCUpdateResult.newData)
    }
    
    @IBAction func tapped(_ sender: Any) {
        let url = URL(string: "synapseWear://")
        extensionContext?.open(url!, completionHandler: nil)
    }
    
    func reloadData() -> Bool{
        guard let userDefaults = UserDefaults(suiteName: "group.com.artandprogram.sW") else{
            return false
        }
        
        let updatedAt:TimeInterval = userDefaults.double(forKey: "updatedAt")
        let updatedDate = Date(timeIntervalSince1970: updatedAt)
        
        if updatedDate.timeIntervalSinceNow > -1800 {
            let co2 = userDefaults.integer(forKey: "co2")
            let battery = Int(userDefaults.float(forKey: "battery"))
            let temp = userDefaults.float(forKey: "temp")
            let humidity = userDefaults.integer(forKey: "humidity")
            let pressure = userDefaults.float(forKey: "pressure")
            let graphData = userDefaults.array(forKey: "graphData")
            let minutes = abs(Int(updatedDate.timeIntervalSinceNow))/60
            
            updateViewWithData(co2: co2, battery: battery, temp: temp, humidity: humidity, pressure: pressure, updateMins: minutes)
            updateGraph(co2: co2, graphData: graphData)
        }else{
            updateViewWithNoData()
        }
        
        return true
    }
    
    func updateViewWithData(co2: Int, battery: Int, temp: Float, humidity: Int, pressure: Float, updateMins: Int){
        if co2 < 0 {
            co2Value.text = "---"
        }else{
            co2Value.text = String(format: "%dppm", co2)
        }
        batteryValue.text = String(format: "%d%%", battery)
        tempHumidLabel.text = String(format: "%.1f℃ %d%%", temp, humidity)
        tempHumidLabel.isHidden = false
        pressureLabel.text = String(format: "%.1fhPa", pressure)
        pressureLabel.isHidden = false
        
        if updateMins == 0 {
            dateLabel.text = "now"
        }else if updateMins == 1{
            dateLabel.text = String(format:"%dmin ago", updateMins)
        }else{
            dateLabel.text = String(format:"%dmins ago", updateMins)
        }
    }
    
    func updateGraph(co2: Int, graphData: [Any]?){
        if let data = graphData as? [Int] {
            print(data)
            if let maxGraphVal = data.max() {
                maxLabel.text = String(max(maxGraphVal, co2))
            }
            graphView.image = makeGraphImage(data: data, color: UIColor.white, imageW: graphView.frame.width, imageH: graphView.frame.height)
            
            graphView.backgroundColor = UIColor(white: 0, alpha: 0.1)
            maxLabel.isHidden = false
            minLabel.isHidden = false
            timeLabel.isHidden = false
        }
    }
    
    func updateViewWithNoData(){
        co2Value.text = "---"
        batteryValue.text = "---"
        dateLabel.text = "No Data"
        tempHumidLabel.isHidden = true
        pressureLabel.isHidden = true
        
        graphView.image = nil
        graphView.backgroundColor = UIColor.clear
        maxLabel.isHidden = true
        minLabel.isHidden = true
        timeLabel.isHidden = true
    }

    func makeGraphImage(data: [Int], color: UIColor, imageW: CGFloat, imageH: CGFloat) -> UIImage? {
        var image: UIImage? = nil
        UIGraphicsBeginImageContextWithOptions(CGSize(width: imageW, height: imageH), false, 0)
        
        let offsetH:CGFloat = 5.0
        let graphH:CGFloat = imageH - offsetH*2
        let min = 400
        var max = data.max() ?? 400
        if max <= min {
            max = 440
        }
        let hRatio:CGFloat = graphH / CGFloat(max - min)
        let wRatio:CGFloat = (imageW - 10) / CGFloat(data.count)
        
        let nowX = imageW - 10
        let nowY = graphH - CGFloat(data[0] - min) * hRatio + offsetH

        if data[0] > 0 {
            let circlePath: UIBezierPath = UIBezierPath(ovalIn: CGRect(x:nowX-3.0, y:nowY-3.0, width: 6.0, height: 6.0))
            color.setFill()
            circlePath.fill()
        }
        
        let guideX = nowX - wRatio * CGFloat(30)
        let guide = UIBezierPath()
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
            
            let rx = nowX - wRatio * CGFloat(index)
            let ry = graphH - CGFloat(val - min) * hRatio + offsetH
            let circlePath: UIBezierPath = UIBezierPath(ovalIn: CGRect(x:rx-1.0, y:ry-1.0, width: 2.0, height: 2.0))
            color.setFill()
            circlePath.fill()
            
            guard index != data.count - 1 else {
                continue
            }
            
            let nextVal = data[index+1]
            if nextVal > 0 {
                let lx = rx - wRatio
                let ly = graphH - CGFloat(nextVal - min) * hRatio + offsetH
                
                let line = UIBezierPath()
                line.move(to: CGPoint(x: rx, y: ry))
                line.addLine(to: CGPoint(x: lx, y: ly))
                line.close()
                line.lineWidth = 1.0
                color.setStroke();
                line.stroke()
            }
        }
        
        image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image;
    }
}
