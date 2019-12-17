//
//  AppDelegate.swift
//  synapseWearCentral
//
//  Copyright © 2018 art and program, Inc. For license and other information refer to https://github.com/artandprogram/synapseWear. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application

        NSApp.windows.first?.delegate = self
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func windowDidResize(_ aNotification: Notification) {
    }
}

