//
//  Constants.swift
//  Skeleton
//
//  Created by Systango on 01/06/17.
//  Copyright © 2017 Systango. All rights reserved.
//

import Foundation
import UIKit

typealias CompletionHandler = (_ success: Bool, _ response: Any?) -> Void
typealias ProgressBlock = ((Progress) -> Void)

struct HTTPStatusCode {
    static let kResponseStatusSuccess = 200
    static let kResponseStatusCreated = 201
    static let kResponseStatusAccepted = 202
    static let kResponseStatusNoResponse = 204
    static let kResponseStatusForbidden = 401
    static let kResponseStatusAleradyExist = 409
    static let kResponseStatusEmailNotFound = 422
    static let kResponseStatusServerError = 500
    static let kResponseInvalidCredential = 401
    static let kResponseStatusUserNotExist = 404
}
struct Constants {

    // MARK: General Constants
    static let EmptyString = ""
    
    // MARK: User Defaults
    static let UserDefaultsDeviceTokenKey = "DeviceTokenKey"
    
    // MARK: Enums
    enum RequestType: NSInteger {
        case get
        case post
        case multiPartPost
        case delete
        case put
    }

    // MARK: Network Keys
    static let InsecureProtocol = "http://"
    static let SecureProtocol = "https://"
    static let LocalEnviroment = "LOCAL"
    static let StagingEnviroment = "STAGING"
    static let LiveEnviroment = "LIVE"
    
    
    static let kMessageInternalServer = "Internal Server Error"
    static let kMessageInvalidCredential = "Invalid Credential"
}
