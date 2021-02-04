//
//  ApiFirmware.swift
//  synapsewear
//
//  Copyright © 2018 art and program, Inc. For license and other information refer to https://github.com/artandprogram/synapseWear. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ApiFirmware: ApiManager {

    init(url: String?) {

        super.init()

        if let url = url, url.count > 0 {
            self.url = url
        }
        else {
            if let host = self.getAppinfoValue("firmware_domain") as? String {
                self.host = host
            }
            self.url = self.host + "list.php"
        }
        //print("ApiFirmware url: \(self.url)")
    }

    override convenience init() {

        self.init(url: nil)
    }
    /*
    override init() {

        super.init()

        if let path = Bundle.main.path(forResource: "appinfo", ofType: "plist"), let dict = NSDictionary(contentsOfFile: path) as? [String: Any], let host = dict["firmware_domain"] as? String {
            self.host = host
        }
        self.url = self.host + "list.php"
        //print("url: \(self.url)")
    }*/

    func getFirmwareDataRequest(success: @escaping (_ json: JSON?) -> Void, fail: @escaping (_ error: Error?) -> Void) {

        let method: HTTPMethod = .get
        let parameters: Parameters = [:]

        self.request(self.url, method: method, parameters: parameters, success: {
            (json: JSON?) in success(json)
        }, fail: {
            (error: Error?) in fail(error)
        })
    }
}
