//
//  AppSettings.swift
//  Skeleton
//
//  Created by Systango on 01/06/17.
//  Copyright © 2017 Systango. All rights reserved.
//

import UIKit
//import JSONModel

class AppSettings: NSObject {
    var networkMode: String = ""
    var localURL: String = ""
    var productionURL: String = ""
    var stagingURL: String = ""
    var urlPathSubstring: String = ""
    var enableSecureConnection: Bool = false
    var enablePullToRefresh: Bool = false
    var enableBanner: Bool = false
    var enableCoreData: Bool = false
    var enableTwitter: Bool = false
    var enableFacebook: Bool = false
    
    override init() {
        super.init()
    }
    
    convenience init(dictionary: [String: Any]) {
        self.init()
        networkMode = dictionary.getString(forKey: "NetworkMode")
        localURL = dictionary.getString(forKey: "LocalURL")
        productionURL = dictionary.getString(forKey: "ProductionURL")
        stagingURL = dictionary.getString(forKey: "StagingURL")
        urlPathSubstring = dictionary.getString(forKey: "URLPathSubstring")
        enableSecureConnection = dictionary.getBool(forKey: "EnableSecureConnection")
        enablePullToRefresh = dictionary.getBool(forKey: "EnablePullToRefresh")
        enableBanner = dictionary.getBool(forKey: "EnableBanner")
        enableCoreData = dictionary.getBool(forKey: "EnableCoreData")
        enableTwitter = dictionary.getBool(forKey: "EnableTwitter")
        enableFacebook = dictionary.getBool(forKey: "EnableFacebook")
    }
}
