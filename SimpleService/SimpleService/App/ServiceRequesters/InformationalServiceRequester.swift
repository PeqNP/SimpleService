/**
 Prints out all of the information for a `URLRequest`.
 
 This does not make a network request. It's used to simply get insight into a request.
 
 License: MIT
 
 Copyright © 2018 Upstart Illustration LLC. All rights reserved.
 */

import BrightFutures
import Foundation

enum InformationalError: Error {
    case requestIgnored
}

class InformationalServiceRequester: ServiceRequester {
    func initialized<T>(_ endpoint: T) -> Future<IgnorableValue, NoError> where T : ServiceEndpoint {
        // If your app requires service services to be initialized (such as NewRelic) _before_ requests are made, you can return a `Future` here which will prevent any request from being made until it is resolved.
        // For now, all requests will be executed immediately.
        return Future(value: IgnorableValue())
    }
    
    func request(_ urlRequest: URLRequest, callback: @escaping (ServiceResult) -> Void) {
        print("URL: \(urlRequest)")
        print("  Headers: \(urlRequest.allHTTPHeaderFields ?? [String: String]())")
        if let httpBody = urlRequest.httpBody {
            print("  Body: \(String(data: httpBody, encoding: .utf8) ?? "nil")")
        }
        else {
            print("  Body: nil")
        }
        callback(ServiceResult(statusCode: 0, data: nil, error: InformationalError.requestIgnored))
    }
}
