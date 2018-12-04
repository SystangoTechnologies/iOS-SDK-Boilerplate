//
//  RealAPI.swift
//  Skeleton
//
//  Created by Systango on 01/06/17.
//  Copyright © 2017 Systango. All rights reserved.
//

import UIKit
import AFNetworking

class RealAPI: NSObject, APIInteractor {
    
    var VMRequest: Request = Request()
    var isForbiddenRetry: Bool = false
    var realAPIBlock: CompletionHandler = { _,_ in }
    
    func initialSetup(request: Request, requestType: NSInteger) -> Void {
        VMRequest = request
        VMRequest.requestType = requestType
    }
    
    func isForbiddenResponse(statusCode: NSInteger) -> Bool {
        if statusCode == HTTPStatusCode.kResponseStatusForbidden && isForbiddenRetry == false {
            isForbiddenRetry = true
            return true
        }
        return false
    }
    //MARK: - AFNetworking
    func getObject(request: Request, completion: @escaping CompletionHandler) {
        interactAPIWithGetObject(request: request, completion: completion)
    }
    
    func postObject(request: Request, completion: @escaping CompletionHandler) {
        interactAPIWithPostObject(request: request, completion: completion)
    }
    
    func putObject(request: Request, completion: @escaping CompletionHandler) {
        interactAPIWithPutObject(request: request, completion: completion)
    }
    
    func deleteObject(request: Request, completion: @escaping CompletionHandler) {
        interactAPIWithDeleteObject(request: request, completion: completion)
    }
    
    func multiPartObjectPost(request: Request, progress: ProgressBlock?, completion: @escaping CompletionHandler) -> Void {
        interactAPIWithMultipartObjectPost(request: request, progress: progress, completion: completion)
    }
    
    func interactAPIWithGetObject(request: Request, completion: @escaping CompletionHandler) -> Void {
        initialSetup(request: request, requestType: Constants.RequestType.get.rawValue)
        NetworkHttpClient.sharedInstance.getAPICall(request.urlPath, parameters: request.getParams(), headers: request.headers, success: { (responseDataTask,responseObject) in
            self.handleSuccessResponse(response: responseObject, responseDataTask: responseDataTask, block: completion)
        }, failure: { (responseDataTask,error) in
            self.handleError(error: error as Any, responseDataTask: responseDataTask, block: completion)
        })
    }
    
    func interactAPIWithPutObject(request: Request, completion: @escaping CompletionHandler) -> Void {
        initialSetup(request: request, requestType: Constants.RequestType.put.rawValue)
        NetworkHttpClient.sharedInstance.putAPICall(request.urlPath, parameters: request.getParams(), headers: request.headers!, success: { (responseDataTask,responseObject) in
            self.handleSuccessResponse(response: responseObject, responseDataTask: responseDataTask, block: completion)
        }, failure: { (responseDataTask,error) in
            self.handleError(error: error as Any, responseDataTask: responseDataTask, block: completion)
        })
    }
    
    func interactAPIWithPostObject(request: Request, completion: @escaping CompletionHandler) -> Void {
        initialSetup(request: request, requestType: Constants.RequestType.post.rawValue)
        NetworkHttpClient.sharedInstance.postAPICall(request.urlPath, parameters: request.getParams(), headers: request.headers, success: { (responseDataTask, responseObject) in
            self.handleSuccessResponse(response: responseObject, responseDataTask: responseDataTask, block: completion)
        }, failure: { (responseDataTask, error) in
            self.handleError(error: error as Any, responseDataTask: responseDataTask, block: completion)
        })
    }
    func interactAPIWithDeleteObject(request: Request, completion: @escaping CompletionHandler) -> Void {
        initialSetup(request: request, requestType: Constants.RequestType.delete.rawValue)
        NetworkHttpClient.sharedInstance.deleteAPICall(request.urlPath, parameters: request.getParams(), headers: request.headers, success: { (responseDataTask,responseObject) in
            self.handleSuccessResponse(response: responseObject, responseDataTask: responseDataTask, block: completion)
        }, failure: { (responseDataTask,error) in
            self.handleError(error: error as Any, responseDataTask: responseDataTask, block: completion)
        })
    }
    
    func interactAPIWithMultipartObjectPost(request: Request, progress: ProgressBlock?, completion: @escaping CompletionHandler) -> Void {
        initialSetup(request: request, requestType: Constants.RequestType.multiPartPost.rawValue)
        
        NetworkHttpClient.sharedInstance.multipartPostAPICall(request.urlPath, parameters: request.getParams(), headers: request.headers, data: request.fileData, name: request.dataFilename, fileName: request.fileName, mimeType: request.mimeType, progress: progress, success: { (response, responseObject) in
            self.handleSuccessResponse(response: responseObject, block: completion)
        }) { (response, error) in
            self.handleError(error: error as Any, responseDataTask: response, block: completion)
        }
        
    }
    
    func handleSuccessResponse(response: Any?, responseDataTask: Any? = nil, block:@escaping CompletionHandler) -> Void {
        if response != nil {
            isForbiddenRetry = false
            block(true, response)
        } else if let dataTask = responseDataTask as? URLSessionDataTask {
            if let networkError = dataTask.error as NSError? {
                self.handleError(error: networkError, responseDataTask: responseDataTask, block: block)
            } else {
                var errorMessage: String? = nil
                var errorCode = 0
                if let responseErrorData = (responseDataTask as? [AnyHashable: Any])?[AFNetworkingOperationFailingURLResponseDataErrorKey] as? Data, let responseString = String(data: responseErrorData, encoding: String.Encoding.utf8) {
                    errorMessage = responseString
                }
                if let httpResonseData = (responseDataTask as? [AnyHashable: Any])?[AFNetworkingOperationFailingURLResponseErrorKey] as? HTTPURLResponse?{
                    errorCode = httpResonseData!.statusCode
                }
                if let httpResonseData = dataTask.response as? HTTPURLResponse {
                    errorCode = httpResonseData.statusCode
                }
                if errorCode == HTTPStatusCode.kResponseStatusCreated || errorCode == HTTPStatusCode.kResponseStatusAccepted {
                    block(true, errorMessage)
                    return
                } else if errorCode == HTTPStatusCode.kResponseStatusAleradyExist || errorCode == HTTPStatusCode.kResponseStatusEmailNotFound || errorCode == HTTPStatusCode.kResponseStatusSuccess {
                    block(false, errorMessage)
                    return
                } else if errorCode == HTTPStatusCode.kResponseStatusSuccess {
                    block(true, errorMessage)
                    return
                } else if errorCode == HTTPStatusCode.kResponseStatusNoResponse {
                    block(true, errorMessage)
                    return
                } else if errorCode == HTTPStatusCode.kResponseStatusUserNotExist {
                    block(false, errorMessage)
                    return
                } else if errorCode == HTTPStatusCode.kResponseInvalidCredential {
                    block(false, Constants.kMessageInvalidCredential)
                    return
                } else if errorCode == HTTPStatusCode.kResponseStatusServerError {
                    block(false, Constants.kMessageInternalServer)
                    return
                } else {
                    block(false, dataTask.error?.localizedDescription)
                    return
                }
            }
        } else {
            block(false,nil)
        }
    }
    
    func handleError(error: Any, responseDataTask: Any?, block: @escaping CompletionHandler) -> Void {
        let networkError = error as? NSError
        if (networkError != nil){
            var errorCode = 0
            var errorMessage = networkError?.localizedDescription
            if let userInfo = networkError?.userInfo as NSDictionary? {
                if let responseErrorData = userInfo.value(forKey: AFNetworkingOperationFailingURLResponseDataErrorKey) as? Data, let responseString = String(data: responseErrorData, encoding: String.Encoding.utf8) {
                    errorMessage = responseString
                }
                if let httpResonseData = userInfo.value(forKey: AFNetworkingOperationFailingURLResponseErrorKey) as? HTTPURLResponse?{
                    errorCode = httpResonseData!.statusCode
                }
            }
            if self.isForbiddenResponse(statusCode:(networkError?.code)!) {
                realAPIBlock = block
                return
            } else if errorCode == HTTPStatusCode.kResponseStatusCreated || errorCode == HTTPStatusCode.kResponseStatusAccepted {
                block(true, errorMessage)
                return
            } else if errorCode == HTTPStatusCode.kResponseStatusAleradyExist || errorCode == HTTPStatusCode.kResponseStatusEmailNotFound {
                block(false, errorMessage)
                return
            } else if errorCode == HTTPStatusCode.kResponseStatusSuccess {
                block(true, errorMessage)
                return
            } else if errorCode == HTTPStatusCode.kResponseStatusUserNotExist {
                block(false, errorMessage)
                return
            } else if errorCode == HTTPStatusCode.kResponseInvalidCredential {
                block(false, Constants.kMessageInvalidCredential)
                return
            } else if errorCode == HTTPStatusCode.kResponseStatusServerError {
                block(false, Constants.kMessageInternalServer)
                return
            } else {
                block(false, networkError?.localizedDescription)
                return
            }
        }else{
            block(false, nil)
        }
    }
}
