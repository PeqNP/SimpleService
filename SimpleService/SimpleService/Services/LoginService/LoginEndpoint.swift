/**
 This endpoint shows a complete example, albeit fake, of how every feature of an `ServiceEndpoint` can be used.
 
 License: MIT
 
 Copyright © 2019 Upstart Illustration LLC. All rights reserved.
 */

import Foundation

struct LoginEndpoint: ServiceEndpoint {
    
    struct ResponseType: Decodable {
        let firstName: String
        let lastName: String
        let rewardsLevel: Int
        let lastLogin: Date
    }
    
    enum Header {
        // All headers are camelcased with underscores replaced with hyphens. Thes will turn into `Secret-Key` and `Trace-Context`, respectively.
        case secret_key(String)
        case trace_context(String)
    }
    enum PathParameter {
        // The `case` name must be contained within the endpoint URL string w/ the same name in the following format: `%{sessionid}`.
        case sessionid(String)
    }
    enum QueryParameter {
        // The name of the `case` is the name of the corresponding w/ no transformation. Therefore, `case funding(Bool)` will be represented as `funding=true&backerCountMin=10[&...N]` when sent to the server.
        case funding(Bool)
        case backerCountMin(Int)
        case country(String)
        case sort(String)
        case sortDirection(String)
        case offset(Int)
        case limit(Int)
    }
    enum PostParameter {
        // This works the same as a `QueryParameter` where the `case` name is the value of the key w/ no transformation.
        case username(String)
        case password(String)
    }
    
    var type: ServiceRequestType = .post
    var endpoints: Endpoints = [
        // Notice: the `sessionid` is interpolated with the respective `enum PathParameter` `case` name
        .prod: "https://www.example.com/%{sessionid}/login"
    ]
    var headers: [Header]?
    var pathParameters: [PathParameter]?
    var queryParameters: [QueryParameter]?
    var postParameters: [PostParameter]?
    
    init(headers: [Header], pathParameters: [PathParameter], queryParameters: [QueryParameter], postParameters: [PostParameter]) {
        self.headers = headers
        self.pathParameters = pathParameters
        self.queryParameters = queryParameters
        self.postParameters = postParameters
    }
}
