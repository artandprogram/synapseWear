//
//  FirmwearUpdateViewController.swift
//  synapseWearCentral
//
//  Copyright © 2019 art and program, Inc. For license and other information refer to https://github.com/artandprogram/synapseWear. All rights reserved.
//

import Cocoa
import Alamofire
import SwiftyJSON
import Foundation

protocol FirmwearUpdateDelegate: class {

    func updateFirmwearPreStart(_ synapseObject: SynapseObject)
}

class FirmwearUpdateViewController: NSViewController, OTABootloaderControllerDelegate {

    @IBOutlet var mainView: NSView!
    @IBOutlet var label1: NSTextField!
    @IBOutlet var label2: NSTextField!
    @IBOutlet var label3: NSTextField!
    @IBOutlet var loadingProgress: NSProgressIndicator!
    @IBOutlet var fileTransferringProgress: NSProgressIndicator!
    @IBOutlet var cancelButton: NSButton!
    @IBOutlet var closeButton: NSButton!

    var synapseObject: SynapseObject?
    var hexFileName: String?
    var firmwearFileUrl: URL?
    var request: DownloadRequest?
    var otaBootloaderController: OTABootloaderController?
    weak var delegate: FirmwearUpdateDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view..s
        self.viewSetting()

        self.updateFirmwareData()
    }

    override func viewWillDisappear() {
        super.viewWillDisappear()

        self.updateFirmwearEnd()
    }

    override var representedObject: Any? {

        didSet {
            // Update the view, if already loaded.
        }
    }

    func viewSetting() {

        self.label1.stringValue = "None"
        if let synapseObject = self.synapseObject, let synapse = synapseObject.synapse {
            self.label1.stringValue = synapse.peripheral.identifier.uuidString
        }
        self.label2.stringValue = ""
        if let hexFileName = self.hexFileName {
            self.label2.stringValue = hexFileName
        }
        self.label3.stringValue = ""

        self.loadingProgress.isHidden = true
        self.fileTransferringProgress.isHidden = true
        self.cancelButton.isHidden = true
        //self.cancelButton.isEnabled = false
        self.closeButton.isHidden = false

        self.cancelButton.action = #selector(cancelButtonAction)
        self.closeButton.action = #selector(closeButtonAction)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.resized),
                                               name: NSWindow.didResizeNotification,
                                               object: nil)
    }

    @objc func resized() {

        var x: CGFloat = self.mainView.frame.origin.x
        var y: CGFloat = self.mainView.frame.origin.y
        var w: CGFloat = self.mainView.frame.size.width
        var h: CGFloat = self.mainView.frame.size.height
        if let window = self.view.window {
            y = (window.frame.size.height - h) / 2
            w = window.frame.size.width
        }
        self.mainView.frame = NSRect(x: x, y: y, width: w, height: h)

        x = 0
        y = self.label1.frame.origin.y
        h = self.label1.frame.size.height
        self.label1.frame = NSRect(x: x, y: y, width: w, height: h)

        y = self.label2.frame.origin.y
        h = self.label2.frame.size.height
        self.label2.frame = NSRect(x: x, y: y, width: w, height: h)

        y = self.label3.frame.origin.y
        h = self.label3.frame.size.height
        self.label3.frame = NSRect(x: x, y: y, width: w, height: h)

        w = self.loadingProgress.frame.size.width
        h = self.loadingProgress.frame.size.height
        x = (self.mainView.frame.size.width - w) / 2
        y = self.loadingProgress.frame.origin.y
        self.loadingProgress.frame = NSRect(x: x, y: y, width: w, height: h)

        w = self.fileTransferringProgress.frame.size.width
        h = self.fileTransferringProgress.frame.size.height
        x = (self.mainView.frame.size.width - w) / 2
        y = self.fileTransferringProgress.frame.origin.y
        self.fileTransferringProgress.frame = NSRect(x: x, y: y, width: w, height: h)

        w = self.cancelButton.frame.size.width
        h = self.cancelButton.frame.size.height
        x = (self.mainView.frame.size.width - w) / 2
        y = self.cancelButton.frame.origin.y
        self.cancelButton.frame = NSRect(x: x, y: y, width: w, height: h)

        w = self.closeButton.frame.size.width
        h = self.closeButton.frame.size.height
        x = (self.mainView.frame.size.width - w) / 2
        y = self.closeButton.frame.origin.y
        self.closeButton.frame = NSRect(x: x, y: y, width: w, height: h)
    }

    @objc private func cancelButtonAction() {

        self.otaBootloaderController?.cancel()
    }

    @objc private func closeButtonAction() {

        self.dismiss(nil)
    }

    func updateFirmwareData() {

        self.loadingProgress.isHidden = false
        self.loadingProgress.startAnimation(nil)

        if let host = CommonFunction.getAppinfoValue("firmware_domain") as? String, let hexFile = self.hexFileName, let url = URL(string: "\(host)\(hexFile)") {
            self.startDownload(url.absoluteString)
        }
    }

    func startDownload(_ hexUrl: String/*, firmwareInfo: [String: Any]*/) {

        self.firmwearFileUrl = self.getSaveFileUrl(fileName: hexUrl)
        if self.firmwearFileUrl == nil {
            return
        }
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            return (self.firmwearFileUrl!, [.removePreviousFile, .createIntermediateDirectories])
        }
        print("startDownload: \(self.firmwearFileUrl!.absoluteString)")

        self.label3.stringValue = "Firmwear File Download..."

        self.request = Alamofire.download(hexUrl, to: destination)
            .downloadProgress { (progress) in
            }
            .responseData { (data) in
                if let synapseObject = self.synapseObject {
                    self.delegate?.updateFirmwearPreStart(synapseObject)
                }
                self.request = nil
        }
    }

    func getSaveFileUrl(fileName: String) -> URL? {

        guard let nameUrl = URL(string: fileName) else { return nil }
        var fileName: String = nameUrl.lastPathComponent
        if let synapseObject = self.synapseObject, let synapse = synapseObject.synapse {
            fileName = "\(synapse.peripheral.identifier.uuidString)-\(fileName)"
        }
        //print("getSaveFileUrl fileName: \(fileName)")
        let documentsUrl: URL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let fileUrl: URL = documentsUrl.appendingPathComponent(fileName)
        //print("getSaveFileUrl fileUrl: \(fileUrl.absoluteString)")
        return fileUrl
    }

    func updateFirmwearStart() {

        //print("updateFirmwearStart")
        if let url = self.firmwearFileUrl {
            self.label3.stringValue = "Update Firmwear Start"

            self.otaBootloaderController = OTABootloaderController()
            self.otaBootloaderController?.delegate = self
            self.otaBootloaderController?.fileURL = url
            self.otaBootloaderController?.start()
        }
    }

    func updateFirmwearEnd() {

        self.synapseObject = nil
        self.hexFileName = nil
        self.firmwearFileUrl = nil

        self.request?.cancel()

        self.otaBootloaderController?.stop()
        self.otaBootloaderController?.delegate = nil
        self.otaBootloaderController = nil
    }

    func onConnectDevice() {

        self.label3.stringValue = "Connecting..."
    }

    func onPerformDFUOnFile() {

        self.label3.stringValue = "Starting..."
    }

    func onDeviceConnected() {

        self.label3.stringValue = "Device Connected"
    }

    func onDeviceConnectedWithVersion() {

        self.label3.stringValue = "Device Connected With Version"
    }

    func onDeviceDisconnected() {

        //print("onDeviceDisconnected")
        self.label3.stringValue = "Device Disconnected"
    }

    func onReadDFUVersion() {

        self.label3.stringValue = "Read DFU Version"
    }

    func onDFUStarted(_ uploadStatusMessage: String!) {

        self.label3.stringValue = uploadStatusMessage
        self.loadingProgress.stopAnimation(nil)
        self.loadingProgress.isHidden = true
        self.fileTransferringProgress.isHidden = false
        self.fileTransferringProgress.doubleValue = 0
        self.cancelButton.isHidden = false
        //self.cancelButton.isEnabled = true
        self.closeButton.isHidden = true
    }

    func onDFUCancelled() {

        self.label3.stringValue = "Update Firmwear Cancelled"
        self.cancelButton.isHidden = true
        self.closeButton.isHidden = false
    }

    func onBootloaderUploadStarted() {

        self.label3.stringValue = "Uploading Bootloader..."
    }

    func onTransferPercentage(_ percentage: Int32) {

        self.label3.stringValue = "File Transferring..."
        //self.label3.stringValue = "File Transferring \(Int(percentage)) %"
        self.fileTransferringProgress.doubleValue = Double(percentage)
    }

    func onSuccessfulFileTransferred(_ message: String!) {

        self.label3.stringValue = message
        self.fileTransferringProgress.doubleValue = 100
        self.cancelButton.isHidden = true
        self.closeButton.isHidden = false
    }

    func onError(_ errorMessage: String!) {

        self.label3.stringValue = "Update Firmwear Error"
        if let message = errorMessage {
            self.label3.stringValue = "\(self.label3.stringValue): \(message)"
        }
        self.cancelButton.isHidden = true
        self.closeButton.isHidden = false
    }
}
