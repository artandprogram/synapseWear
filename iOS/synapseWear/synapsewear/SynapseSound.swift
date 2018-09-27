//
//  SynapseSound.swift
//  synapsewear
//
//  Copyright © 2018年 art and program, Inc. For license and other information refer to https://github.com/artandprogram/synapseWear. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

protocol SynapseSoundDelegate: class {

    func accelerateSoundKick()
}

class SynapseSound: NSObject {

    // const
    let bpm: Int = 120
    let interval: Int = 32
    let roopSound: String = "hat"
    let lightSounds: [String] = [
        "c1",
        "c2",
        "c3",
        "c4",
        ]
    let co2Sounds: [String] = [
        "n1",
        "n2",
        "n3",
        "n4",
        "n5",
        ]
    let humiditySounds: [String] = [
        "s1",
        "s2",
        "s3",
        "s4",
        "s5",
        ]
    let pressureSounds: [String] = [
        "k1",
        "k2",
        ]
    let temperatureSounds: [String] = [
        "g1",
        "g2",
        "g3",
        "g4",
        ]
    let accelerateSounds: [String] = [
        "pc1",
        "pc2",
        "pc3",
        "b1",
        "b2",
        "b3",
        "b4",
        "p1",
        "p2",
        "p3",
        ]
    let lightMax: Int = 30000
    let co2Max: Int = 3000
    let co2Min: Int = 400
    let co2Time: TimeInterval = 4.0
    let humidityMax: Int = 100
    let humidityMin: Int = 0
    let humidityTime: TimeInterval = 4.0
    let pressureThreshold: Float = 0.5
    let pressureTime: TimeInterval = 1.0
    let temperatureThreshold: Float = 0.5
    let temperatureTime: TimeInterval = 30.0
    let maxTime: TimeInterval = 60.0
    let axDiffMax: Int = 10000
    // variables
    var lastDate: Date = Date()
    var name: String?
    var roopPlayer: AVAudioPlayer? = nil
    var players: [String: AVAudioPlayer?] = [:]
    var isPlaying: Bool = false
    var lightCheckStartTime: TimeInterval?
    var lightCheckTime: TimeInterval?
    var lightCheckPreTime: TimeInterval?
    var lightInterval: TimeInterval = 0
    var co2CheckTime: TimeInterval?
    var co2: Int?
    var co2Now: String = ""
    var co2ANow: String = ""
    var co2BNow: String = ""
    var humidityCheckTime: TimeInterval?
    var humidity: Int?
    var humidityNow: String = ""
    var humidityANow: String = ""
    var humidityBNow: String = ""
    var pressureCheckStartTime: TimeInterval?
    var pressureCheckTime: TimeInterval?
    var pressureCheckPreTime: TimeInterval?
    var pressureIntervalCheckTime: TimeInterval?
    var pressureInterval: TimeInterval = 0
    var pressure: Float?
    var pressureBak: Float?
    var pressureDiff: Float?
    var temperatureCheckTime: TimeInterval?
    var temperature: Float?
    var temperatureBak: Float?
    var temperatureDiff: Float?
    var ax: Int = 0
    var ay: Int = 0
    var az: Int = 0
    var axBak: Int?
    var ayBak: Int?
    var azBak: Int?
    weak var delegate: SynapseSoundDelegate?

    override init() {
        super.init()

        self.setPlayers()
    }

    func getRoopTime() -> TimeInterval {

        return 60.0 / TimeInterval(self.bpm) / TimeInterval(self.interval) * 4
    }

    func setPlayers() {

        if let url = Bundle.main.url(forResource: self.roopSound, withExtension: "wav") {
            do {
                self.roopPlayer = try AVAudioPlayer(contentsOf: url)
                self.roopPlayer?.volume = 0
                self.roopPlayer?.numberOfLoops = -1
                self.roopPlayer?.prepareToPlay()
            }
            catch {
            }
        }
        for fileName in self.lightSounds {
            if let url = Bundle.main.url(forResource: fileName, withExtension: "wav") {
                do {
                    let player: AVAudioPlayer? = try AVAudioPlayer(contentsOf: url)
                    player?.volume = 1
                    player?.numberOfLoops = 0
                    player?.prepareToPlay()
                    self.players[fileName] = player
                }
                catch {
                }
            }
        }
        for fileName in self.co2Sounds {
            if let url = Bundle.main.url(forResource: fileName, withExtension: "wav") {
                do {
                    let playerA: AVAudioPlayer? = try AVAudioPlayer(contentsOf: url)
                    playerA?.volume = 0
                    playerA?.numberOfLoops = 0
                    playerA?.prepareToPlay()
                    self.players["\(fileName)_A"] = playerA

                    let playerB: AVAudioPlayer? = try AVAudioPlayer(contentsOf: url)
                    playerB?.volume = 0
                    playerB?.numberOfLoops = 0
                    playerB?.prepareToPlay()
                    self.players["\(fileName)_B"] = playerB
                }
                catch {
                }
            }
        }
        for fileName in self.humiditySounds {
            if let url = Bundle.main.url(forResource: fileName, withExtension: "wav") {
                do {
                    let playerA: AVAudioPlayer? = try AVAudioPlayer(contentsOf: url)
                    playerA?.volume = 0
                    playerA?.numberOfLoops = 0
                    playerA?.prepareToPlay()
                    self.players["\(fileName)_A"] = playerA

                    let playerB: AVAudioPlayer? = try AVAudioPlayer(contentsOf: url)
                    playerB?.volume = 0
                    playerB?.numberOfLoops = 0
                    playerB?.prepareToPlay()
                    self.players["\(fileName)_B"] = playerB
                }
                catch {
                }
            }
        }
        for fileName in self.pressureSounds {
            if let url = Bundle.main.url(forResource: fileName, withExtension: "wav") {
                do {
                    let player: AVAudioPlayer? = try AVAudioPlayer(contentsOf: url)
                    player?.volume = 1
                    player?.numberOfLoops = 0
                    player?.prepareToPlay()
                    self.players[fileName] = player
                }
                catch {
                }
            }
        }
        for fileName in self.temperatureSounds {
            if let url = Bundle.main.url(forResource: fileName, withExtension: "wav") {
                do {
                    let player: AVAudioPlayer? = try AVAudioPlayer(contentsOf: url)
                    player?.volume = 1
                    player?.numberOfLoops = 0
                    player?.prepareToPlay()
                    self.players[fileName] = player
                }
                catch {
                }
            }
        }
        for fileName in self.accelerateSounds {
            if let url = Bundle.main.url(forResource: fileName, withExtension: "wav") {
                do {
                    let player: AVAudioPlayer? = try AVAudioPlayer(contentsOf: url)
                    player?.volume = 1
                    player?.numberOfLoops = 0
                    player?.prepareToPlay()
                    self.players[fileName] = player
                }
                catch {
                }
            }
        }
    }

    func play(isRoop: Bool = false) {

        self.lastDate = Date()
        //let now: TimeInterval = Date().timeIntervalSince1970
        self.lightCheckStartTime = self.lastDate.timeIntervalSince1970
        self.lightCheckTime = nil
        self.lightCheckPreTime = nil
        self.co2CheckTime = nil
        self.humidityCheckTime = nil
        self.pressureCheckStartTime = self.lastDate.timeIntervalSince1970
        self.pressureCheckTime = nil
        self.pressureCheckPreTime = nil
        self.pressureIntervalCheckTime = nil
        self.temperatureCheckTime = nil
        self.co2Now = ""
        self.co2ANow = ""
        self.co2BNow = ""
        self.humidityNow = ""
        self.humidityANow = ""
        self.humidityBNow = ""
        self.isPlaying = true

        if isRoop {
            self.roopPlayer?.play()
        }
    }

    func stop() {

        self.isPlaying = false
        for player in self.players {
            player.value?.stop()
        }
        self.roopPlayer?.stop()
    }

    func setSynapseValues(_ synapseValues: SynapseValues) {

        self.name = synapseValues.name
        self.setLightCnt(value: synapseValues.light)
        self.co2 = synapseValues.co2
        self.humidity = synapseValues.humidity
        self.setPressureDiff(value: synapseValues.pressure)
        self.setTemperatureDiff(value: synapseValues.temp)
        self.setAccelerateValue(x: synapseValues.ax, y: synapseValues.ay, z: synapseValues.az)
    }

    func checkSound(date: Date) {

        //CommonFunction.log("checkSound")
        if self.isPlaying {
            if date >= self.lastDate {
                self.lastDate = date
            }
            else {
                CommonFunction.log("checkSound late: \(date)")
                return
            }

            self.checkCO2Sound()
            self.checkHumiditySound()
            self.checkLightSound()
            self.checkPressureSound()
            self.checkTemperatureSound()
        }
    }

    func checkLightSound() {

        if self.isPlaying, self.lightInterval > 0, let start = self.lightCheckStartTime {
            let now: TimeInterval = Date().timeIntervalSince1970
            var flag: Bool = false
            if let time = self.lightCheckTime {
                let diff: TimeInterval = floor((now - start) / self.lightInterval)
                let diffPre: TimeInterval = floor((time - start) / self.lightInterval)
                if diff != diffPre {
                    flag = true
                }
            }
            else {
                flag = true
            }
            self.lightCheckTime = now

            if flag {
                //print("\(self.debugFormatter.string(from: Date())) checkLightSound: \(self.lightInterval)")
                if let key = self.getLightSoundKey(), let player = self.players[key] {
                    //CommonFunction.log("checkSound Light -> \(key) (\(self.lightInterval))")
                    /*if let player = player, player.isPlaying {
                        print("player.isPlaying -> \(key)")
                    }*/
                    player?.stop()
                    player?.currentTime = 0
                    player?.play()
                }
            }
        }
    }

    func setLightCnt(value: Int?) {

        self.lightInterval = 0
        if let value = value {
            let scale1: Double = Double(value) / Double(self.lightMax)
            var scale2: Double = floor(5.0 * scale1)
            if scale2 > 5.0 {
                scale2 = 5.0
            }
            self.lightInterval = self.getRoopTime() * Double(self.interval) / pow(2, scale2)
        }
    }

    func getLightSoundKey() -> String? {

        var key: String? = nil
        let random: UInt32 = arc4random_uniform(10)
        if random == 0 || random == 1 {
            key = "c1"
        }
        else if random == 2 || random == 3 {
            key = "c2"
        }
        else if random == 4 || random == 5 {
            key = "c3"
        }
        else if random == 6 {
            if arc4random_uniform(4) == 0 {
                key = "c4"
            }
        }
        return key
    }

    func checkCO2Sound() {

        if self.isPlaying {
            let now: TimeInterval = Date().timeIntervalSince1970
            var timeDiff: TimeInterval = 0
            var flag: Bool = false
            if let time = self.co2CheckTime {
                timeDiff = now - time
                if timeDiff >= self.co2Time {
                    flag = true
                }
            }
            else {
                flag = true
            }
            if flag {
                self.co2CheckTime = now
            }

            if flag {
                if self.co2Now == "A" {
                    if self.co2ANow.count > 0, let player = self.players[self.co2ANow] {
                        player?.volume = 1.0
                    }
                    if self.co2BNow.count > 0, let player = self.players[self.co2BNow] {
                        player?.stop()
                    }
                }
                else if self.co2Now == "B" {
                    if self.co2ANow.count > 0, let player = self.players[self.co2ANow] {
                        player?.stop()
                    }
                    if self.co2BNow.count > 0, let player = self.players[self.co2BNow] {
                        player?.volume = 1.0
                    }
                }

                if self.co2Now == "A" {
                    self.co2Now = "B"
                    self.co2BNow = ""
                    if let key = self.getCO2SoundKey() {
                        self.co2BNow = "\(key)_B"
                        //CommonFunction.log("checkSound CO2 -> \(self.co2BNow)")
                        if let player = self.players[self.co2BNow] {
                            player?.volume = 0
                            player?.currentTime = 0
                            player?.play()
                        }
                    }
                }
                else {
                    self.co2Now = "A"
                    self.co2ANow = ""
                    if let key = self.getCO2SoundKey() {
                        self.co2ANow = "\(key)_A"
                        //CommonFunction.log("checkSound CO2 -> \(self.co2ANow)")
                        if let player = self.players[self.co2ANow] {
                            player?.volume = 0
                            player?.currentTime = 0
                            player?.play()
                        }
                    }
                }
            }
            else {
                let vol: Float = Float(timeDiff) / Float(self.co2Time)
                //print("\(self.debugFormatter.string(from: Date())) checkCO2Sound vol: \(vol)")
                if self.co2Now == "A" {
                    if self.co2ANow.count > 0, let player = self.players[self.co2ANow] {
                        player?.volume = vol
                    }
                    if self.co2BNow.count > 0, let player = self.players[self.co2BNow] {
                        player?.volume = 1.0 - vol
                    }
                }
                else if self.co2Now == "B" {
                    if self.co2ANow.count > 0, let player = self.players[self.co2ANow] {
                        player?.volume = 1.0 - vol
                    }
                    if self.co2BNow.count > 0, let player = self.players[self.co2BNow] {
                        player?.volume = vol
                    }
                }
            }
        }
    }

    func getCO2SoundKey() -> String? {

        var key: String? = nil
        if let co2 = self.co2 {
            var scale1: Double = Double(co2 - self.co2Min) / Double(self.co2Max - self.co2Min)
            if scale1 < 0 {
                scale1 = 0
            }
            else if scale1 > 1.0 {
                scale1 = 1.0
            }

            let scale2: Int = Int(floor(4.0 * scale1))
            if scale2 == 0 {
                key = "n1"
            }
            else if scale2 == 1 {
                key = "n2"
            }
            else if scale2 == 2 {
                key = "n3"
            }
            else if scale2 == 3 {
                key = "n4"
            }
            else if scale2 == 4 {
                key = "n5"
            }
        }
        return key
    }

    func checkHumiditySound() {

        if self.isPlaying {
            let now: TimeInterval = Date().timeIntervalSince1970
            var timeDiff: TimeInterval = 0
            var flag: Bool = false
            if let time = self.humidityCheckTime {
                timeDiff = now - time
                if timeDiff >= self.humidityTime {
                    flag = true
                }
            }
            else {
                flag = true
            }
            if flag {
                self.humidityCheckTime = now
            }

            if flag {
                if self.humidityNow == "A" {
                    if self.humidityANow.count > 0, let player = self.players[self.humidityANow] {
                        player?.volume = 1.0
                        //print("\(Date()) checkHumiditySound A: \(player?.volume)")
                    }
                    if self.humidityBNow.count > 0, let player = self.players[self.humidityBNow] {
                        player?.stop()
                        //print("\(Date()) checkHumiditySound B: stop")
                    }
                }
                else if self.humidityNow == "B" {
                    if self.humidityANow.count > 0, let player = self.players[self.humidityANow] {
                        player?.stop()
                        //print("\(Date()) checkHumiditySound A: stop")
                    }
                    if self.humidityBNow.count > 0, let player = self.players[self.humidityBNow] {
                        player?.volume = 1.0
                        //print("\(Date()) checkHumiditySound B: \(player?.volume)")
                    }
                }

                if self.humidityNow == "A" {
                    self.humidityNow = "B"
                    self.humidityBNow = ""
                    if let key = self.getHumiditySoundKey() {
                        self.humidityBNow = "\(key)_B"
                        //CommonFunction.log("checkSound Humidity -> \(self.humidityBNow)")
                        if let player = self.players[self.humidityBNow] {
                            player?.volume = 0
                            player?.currentTime = 0
                            player?.play()
                        }
                    }
                }
                else {
                    self.humidityNow = "A"
                    self.humidityANow = ""
                    if let key = self.getHumiditySoundKey() {
                        self.humidityANow = "\(key)_A"
                        //CommonFunction.log("checkSound Humidity -> \(self.humidityANow)")
                        if let player = self.players[self.humidityANow] {
                            player?.volume = 0
                            player?.currentTime = 0
                            player?.play()
                        }
                    }
                }
            }
            else {
                let vol: Float = Float(timeDiff) / Float(self.humidityTime)
                //print("\(self.debugFormatter.string(from: Date())) checkHumiditySound vol: \(vol)")
                if self.humidityNow == "A" {
                    if self.humidityANow.count > 0, let player = self.players[self.humidityANow] {
                        player?.volume = vol
                        //print("\(Date()) checkHumiditySound A: \(player?.volume)")
                    }
                    if self.humidityBNow.count > 0, let player = self.players[self.humidityBNow] {
                        player?.volume = 1.0 - vol
                        //print("\(Date()) checkHumiditySound B: \(player?.volume)")
                    }
                }
                else if self.humidityNow == "B" {
                    if self.humidityANow.count > 0, let player = self.players[self.humidityANow] {
                        player?.volume = 1.0 - vol
                        //print("\(Date()) checkHumiditySound A: \(player?.volume)")
                    }
                    if self.humidityBNow.count > 0, let player = self.players[self.humidityBNow] {
                        player?.volume = vol
                        //print("\(Date()) checkHumiditySound B: \(player?.volume)")
                    }
                }
            }
        }
    }

    func getHumiditySoundKey() -> String? {

        var key: String? = nil
        if let humidity = self.humidity {
            var scale1: Double = Double(humidity - self.humidityMin) / Double(self.humidityMax - self.humidityMin)
            if scale1 < 0 {
                scale1 = 0
            }
            else if scale1 > 1.0 {
                scale1 = 1.0
            }

            let scale2: Int = Int(floor(4.0 * scale1))
            if scale2 == 0 {
                key = "s1"
            }
            else if scale2 == 1 {
                key = "s2"
            }
            else if scale2 == 2 {
                key = "s3"
            }
            else if scale2 == 3 {
                key = "s4"
            }
            else if scale2 == 4 {
                key = "s5"
            }
        }
        return key
    }

    func checkPressureSound() {

        if self.isPlaying {
            let now: TimeInterval = Date().timeIntervalSince1970
            var flag: Bool = false
            if let time = self.pressureIntervalCheckTime {
                if now - time >= self.pressureTime {
                    flag = true
                }
            }
            else {
                flag = true
            }
            if flag {
                self.pressureIntervalCheckTime = now
                self.setPressureCnt()
                //print("\(self.debugFormatter.string(from: Date())) checkPressureInterval: \(self.pressureInterval)")
            }

            flag = false
            if self.pressureInterval > 0, let start = self.pressureCheckStartTime {
                if let time = self.pressureCheckTime {
                    let diff: TimeInterval = floor((now - start) / self.pressureInterval)
                    let diffPre: TimeInterval = floor((time - start) / self.pressureInterval)
                    if diff != diffPre {
                        flag = true
                    }
                }
                else {
                    flag = true
                }
                self.pressureCheckTime = now
            }
            if flag {
                //print("\(self.debugFormatter.string(from: Date())) checkPressureSound")
                if let key = self.getPressureSoundKey(), let player = self.players[key] {
                    //CommonFunction.log("checkSound Pressure -> \(key) (\(self.pressureInterval))")
                    /*if let player = player, player.isPlaying {
                        print("player.isPlaying -> \(key)")
                    }*/
                    player?.stop()
                    player?.currentTime = 0
                    player?.play()
                }
            }
        }
    }

    func setPressureDiff(value: Float?) {

        self.pressure = value
        if let pressure = self.pressure, let pressureBak = self.pressureBak {
            let diff: Float = abs(pressure - pressureBak)
            if let pressureDiff = self.pressureDiff {
                if diff > pressureDiff {
                    self.pressureDiff = diff
                }
            }
            else {
                self.pressureDiff = diff
            }
        }
    }

    func setPressureCnt() {

        self.pressureInterval = 0
        if let pressureDiff = self.pressureDiff {
            let scale1: Double = Double(pressureDiff) / Double(self.pressureThreshold)
            var scale2: Double = floor(5.0 * scale1)
            if scale2 > 5.0 {
                scale2 = 5.0
            }
            self.pressureInterval = self.getRoopTime() * Double(self.interval) / pow(2, scale2)
        }

        self.pressureBak = self.pressure
        self.pressure = nil
        self.pressureDiff = nil
    }

    func getPressureSoundKey() -> String? {

        var key: String? = nil
        let random: UInt32 = arc4random_uniform(10)
        if random == 0 || random == 1 || random == 2 {
            key = "k1"
        }
        else if random == 3 {
            key = "k2"
        }
        return key
    }

    func checkTemperatureSound() {

        if self.isPlaying {
            let now: TimeInterval = Date().timeIntervalSince1970
            var timeDiff: TimeInterval = 0
            var flag: Bool = false
            if let time = self.temperatureCheckTime {
                timeDiff = now - time
                if timeDiff >= self.temperatureTime {
                    flag = true
                }
            }
            else {
                flag = true
            }
            if flag {
                self.temperatureCheckTime = now
            }

            if flag {
                //print("\(self.debugFormatter.string(from: Date())) checkTemperatureSound")
                if let key = self.getTemperatureSoundKey(), let player = self.players[key] {
                    //CommonFunction.log("checkSound Temperature -> \(key)")
                    /*if let player = player, player.isPlaying {
                        print("player.isPlaying -> \(key)")
                    }*/
                    player?.stop()
                    player?.currentTime = 0
                    player?.play()
                }
            }
        }
    }

    func setTemperatureDiff(value: Float?) {

        self.temperature = value
        if let temperature = self.temperature, let temperatureBak = self.temperatureBak {
            let diff: Float = abs(temperature - temperatureBak)
            if let temperatureDiff = self.temperatureDiff {
                if diff > temperatureDiff {
                    self.temperatureDiff = diff
                }
            }
            else {
                self.temperatureDiff = diff
            }
        }
    }

    func getTemperatureSoundKey() -> String? {
        
        var key: String? = nil
        if let temperatureDiff = self.temperatureDiff, temperatureDiff >= self.temperatureThreshold {
            let random: UInt32 = arc4random_uniform(4)
            if random == 0 {
                key = "g1"
            }
            else if random == 1 {
                key = "g2"
            }
            else if random == 2 {
                key = "g3"
            }
            else if random == 3 {
                key = "g4"
            }
        }
        self.temperatureBak = self.temperature
        self.temperature = nil
        self.temperatureDiff = nil
        return key
    }

    func setAccelerateValue(x: Int?, y: Int?, z: Int?) {

        if x != nil && y != nil && z != nil && self.axBak != nil && self.ayBak != nil && self.azBak != nil {
            self.ax = abs(x! - self.axBak!)
            self.ay = abs(y! - self.ayBak!)
            self.az = abs(z! - self.azBak!)
            self.checkAccelerateSound(ax: self.ax, ay: self.ay, az: self.az)
        }
        self.axBak = x
        self.ayBak = y
        self.azBak = z
    }

    func checkAccelerateSound(ax: Int, ay: Int, az: Int) {

        if self.isPlaying && ax > self.axDiffMax {
            if let key = self.getAccelerateSoundKey(), let player = self.players[key] {
                //CommonFunction.log("checkSound Accelerate -> \(key) (\(ax))")
                player?.stop()
                player?.currentTime = 0
                player?.play()

                self.delegate?.accelerateSoundKick()
            }
        }
    }

    func getAccelerateSoundKey() -> String? {

        var key: String? = nil
        let random1: UInt32 = arc4random_uniform(10)
        if random1 <= 5 {
            let random2: UInt32 = arc4random_uniform(10)
            if random2 == 0 || random2 == 3 || random2 == 4 {
                key = "pc1"
            }
            else if random2 == 1 || random2 == 5 {
                key = "pc2"
            }
            else if random2 == 2 {
                key = "pc3"
            }
            else if random2 == 6 {
                key = "b1"
            }
            else if random2 == 7 {
                key = "b2"
            }
            else if random2 == 8 {
                key = "b3"
            }
            else if random2 == 9 {
                key = "b4"
            }
        }
        else {
            let random1: UInt32 = arc4random_uniform(4)
            if random1 == 0 || random1 == 3 {
                key = "p1"
            }
            else if random1 == 1 {
                key = "p2"
            }
            else if random1 == 2 {
                key = "p3"
            }
        }
        return key
    }
}
