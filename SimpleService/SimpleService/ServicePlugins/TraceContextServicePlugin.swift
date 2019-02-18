/**
 An example of a plugin can be used to modify a request.
 
 License: MIT
 
 Copyright © 2019 Upstart Illustration LLC. All rights reserved.
 */

import Foundation

class TraceContextServicePlugin: ServicePlugin {
    
    var key: ServicePluginKey = .traceContext
    
    func willSendRequest(_ request: URLRequest) -> URLRequest {
        var headers = request.allHTTPHeaderFields ?? [String: String]()
        headers["Trace-Context"] = "my-trace-context" // This trace context could be injected from a provider
        
        // Modify and return the request w/ our new header
        var request = request
        request.allHTTPHeaderFields = headers
        return request
    }
    
    func didSendRequest(_ request: URLRequest) {
        // Do something with the request. Maybe log it to your favorite metrics provider?
    }
    
    func didReceiveResponse(_ response: ServiceResult) -> ServiceResult {
        // This gives you a change to modify the result and return a new result in its place.
        return response
    }
}
