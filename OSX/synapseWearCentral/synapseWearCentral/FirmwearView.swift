//
//  FirmwearView.swift
//  synapseWearCentral
//
//  Copyright © 2018年 art and program, Inc. For license and other information refer to https://github.com/artandprogram/synapseWear. All rights reserved.
//

import Cocoa

class FirmwearView: NSTableCellView {

    var nowVersionLabel: NSTextField!
    var firmwearComboBox: NSComboBox!
    var updateButton: NSButton!

    init() {
        super.init(frame: CGRect.zero)
        //print("init")

        self.nowVersionLabel = NSTextField()
        self.nowVersionLabel.isEditable = false
        self.nowVersionLabel.isBordered = false
        self.nowVersionLabel.stringValue = ""
        self.nowVersionLabel.layer?.backgroundColor = NSColor.clear.cgColor
        self.addSubview(self.nowVersionLabel)

        self.firmwearComboBox = NSComboBox()
        self.firmwearComboBox.stringValue = "00.0 (00000000)"
        self.addSubview(self.firmwearComboBox)

        self.updateButton = NSButton()
        self.updateButton.title = "update"
        self.addSubview(self.updateButton)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
        self.firmwearComboBox.frame = NSRect(x: 55.0, y: 0, width: 130.0, height: 26.0)
        self.updateButton.frame = NSRect(x: 0, y: 2.0, width: 50.0, height: 22.0)
        /*self.nowVersionLabel.frame = NSRect(x: 0, y: 0, width: 60.0, height: 20.0)
        self.nowVersionLabel.frame = NSRect(x: 0, y: 0, width: 60.0, height: 20.0)*/
        
        self.nowVersionLabel.sizeToFit()
        self.nowVersionLabel.frame = NSRect(x: 0, y: 0, width: self.nowVersionLabel.frame.size.width, height: 26.0)


        self.textField?.frame = NSRect(x: 0, y: 0, width: 130.0, height: 0)
        //print("draw: \(self.textField)")
    }
    
}
