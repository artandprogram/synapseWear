//
//  ApiManager.swift
//  synapsewear
//
//  Copyright © 2017年 art and program, Inc. For license and other information refer to https://github.com/artandprogram/synapseWear. All rights reserved.
//

import Alamofire
import SwiftyJSON

class ApiManager {

    public var host: String = ""
    public var url: String = ""

    init() {

        self.host = "https://purple.artandprogram.com"
    }

    public func request(_ url: String, method: HTTPMethod, parameters: Parameters, success: @escaping (_ json: JSON?) -> Void, fail: @escaping (_ error: Error?) -> Void) {
        Alamofire.request(url, method: method, parameters: parameters).responseJSON { response in
            if response.result.isSuccess {
                if let object = response.result.value {
                    success(JSON(object))
                }
                else {
                    success(nil)
                }
            }
            else {
                fail(response.result.error)
            }
        }
    }
}
