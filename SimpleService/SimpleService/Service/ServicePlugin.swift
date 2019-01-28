/**
 Provides the ability to modify a `URLRequest` before the request is made.
 
 License: MIT
 
 Copyright © 2018 Upstart Illustration LLC. All rights reserved.
 */

import Foundation

protocol ServicePlugin {
    func willSendRequest(_ request: URLRequest) -> URLRequest
    func didSendRequest(_ request: URLRequest)
    func didReceiveResponse(_ response: ServiceResult) -> ServiceResult
}
