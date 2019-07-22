/**
 Provides definition of a request made to a service.
 
 License: MIT
 
 Copyright © 2018 Upstart Illustration LLC. All rights reserved.
 */

import Alamofire
import BrightFutures
import Foundation

extension ServiceResult {
    static func make(from response: DataResponse<Any>) -> ServiceResult {
        return ServiceResult(statusCode: response.response?.statusCode, data: response.data, error: response.error)
    }
}

class AlamofireServiceRequester: ServiceRequester {
    func initialized<T>(_ endpoint: T) -> Future<IgnorableValue, NoError> where T : ServiceEndpoint {
        // If your app requires service services to be initialized (such as NewRelic) _before_ requests are made, you can return a `Future` here which will prevent any request from being made until it is resolved.
        // For now, all requests will be executed immediately.
        return Future(value: IgnorableValue())
    }

    func request(_ urlRequest: URLRequest, callback: @escaping (ServiceResult) -> Void) {
        Alamofire.request(urlRequest).responseJSON { (response) in
            callback(ServiceResult.make(from: response))
        }
    }
}
