//
//  ApiPostdata.swift
//  synapsewear
//
//  Created by 中口大雅 on 2018/07/12.
//  Copyright © 2018年 art and program, Inc. For license and other information refer to https://github.com/artandprogram/synapseWear. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ApiPostdata: ApiManager {

    init(url: String?) {

        super.init()

        if let url = url, url.count > 0 {
            self.url = url
        }
        else {
            if let url = self.getAppinfoValue("postdata_url") as? String {
                self.url = url
            }
        }
        print("ApiPostdata url: \(self.url)")
    }

    override convenience init() {

        self.init(url: nil)
    }

    func postDataRequest(data: String, success: @escaping (_ response: HTTPURLResponse?) -> Void, fail: @escaping (_ error: Error?) -> Void) {

        let method: HTTPMethod = .post
        let parameters: Parameters = ["data": data]

        Alamofire.request(self.url, method: method, parameters: parameters).responseString { response in
            if response.result.isSuccess {
                success(response.response)
            }
            else {
                fail(response.result.error)
            }
        }
    }

    func postDataRequest(data: String, success: @escaping (_ json: JSON?) -> Void, fail: @escaping (_ error: Error?) -> Void) {

        let method: HTTPMethod = .post
        let parameters: Parameters = ["data": data]

        self.request(self.url, method: method, parameters: parameters, success: {
            (json: JSON?) in success(json)
        }, fail: {
            (error: Error?) in fail(error)
        })
    }
}
