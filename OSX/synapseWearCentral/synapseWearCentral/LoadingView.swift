//
//  LoadingView.swift
//  synapseWearCentral
//
//  Copyright © 2018 art and program, Inc. For license and other information refer to https://github.com/artandprogram/synapseWear. All rights reserved.
//

import Cocoa

class LoadingView: NSView {

    var indicator: NSProgressIndicator!

    init() {
        super.init(frame: CGRect.zero)

        self.wantsLayer = true
        self.layer?.backgroundColor = NSColor(calibratedRed: 0, green: 0, blue: 0, alpha: 0.2).cgColor

        self.indicator = NSProgressIndicator(frame: NSRect(x: 0, y: 0, width: 50.0, height: 50.0))
        self.indicator.style = .spinning
        self.addSubview(self.indicator)

        //self.indicator.startAnimation(nil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        //print("draw")
        // Drawing code here.
        self.indicator.frame = NSRect(x: (self.frame.size.width - self.indicator.frame.size.width) / 2,
                                      y: (self.frame.size.height - self.indicator.frame.size.height) / 2,
                                      width: self.indicator.frame.size.width,
                                      height: self.indicator.frame.size.height)
    }

    override func mouseDown(with theEvent: NSEvent) {
        //print("left mouse")
    }

    override func rightMouseDown(with theEvent: NSEvent) {
        //print("right mouse")
    }
    /*
    override func viewDidEndLiveResize() {
        //print("viewDidEndLiveResize")
    }*/
}
