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
        return ServiceResult(data: response.data, error: response.error)
    }
}

class AlamofireServiceRequester: ServiceRequester {
    func request(_ urlRequest: URLRequest, callback: @escaping (ServiceResult) -> Void) {
        Alamofire.request(urlRequest).responseJSON { (response) in
            callback(ServiceResult.make(from: response))
        }
    }
}
