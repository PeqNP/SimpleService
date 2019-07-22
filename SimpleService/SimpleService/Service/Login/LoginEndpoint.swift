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
    
    var plugins: [ServicePluginKey]? {
        return [
            // This endpoint requires the trace context plugin.
            .traceContext
            // You could also imagine having an "Authorization Plugin" which manages the user's session. Where the endpoint would require the user's session ID in the request (perhaps via a header). The plugin could also be responsible for logging the user in, if needed.
        ]
    }
    
    enum Header: ServiceParameter {
        // All headers are camelcased with underscores replaced with hyphens. Thes will turn into `Secret-Key`.
        case secret_key(String)
    }
    enum PathParameter: ServiceParameter {
        // The `case` name must be contained within the endpoint URL string w/ the same name in the following format: `{sessionid}`.
        case sessionid(String)
        case version(String)
    }
    enum QueryParameter: ServiceParameter {
        // The name of the `case` is the name of the corresponding w/ no transformation. Therefore, `case funding(Bool)` will be represented as `format=json[&...N]` when sent to the server.
        case format(String)
    }
    // Similar to `PathParameter` and `QueryParameter`, it is possible to allow the `PostBody` to be used as a key/value pair for `.keyValue` and `.json` encoding types.
    enum PostParameter: ServiceParameter {
        case username(String)
        case password(String)
    }
    typealias PostBody = [PostParameter]
    
    var type: ServiceRequestType = .post
    var endpoints: Endpoints = [
        // Notice: the `sessionid` and `version` are interpolated with the respective `enum PathParameter` `case` values.
        .prod: "https://www.example.com/{version}/{sessionid}/login"
    ]
    var headers: [Header]?
    var pathParameters: [PathParameter]?
    var queryParameters: [QueryParameter]?
    var postBody: PostBody?
    
    init(headers: [Header], pathParameters: [PathParameter], queryParameters: [QueryParameter], postBody: PostBody?) {
        self.headers = headers
        self.pathParameters = pathParameters
        self.queryParameters = queryParameters
        self.postBody = postBody
    }
}
