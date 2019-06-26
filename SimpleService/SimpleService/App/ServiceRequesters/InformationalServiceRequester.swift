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
