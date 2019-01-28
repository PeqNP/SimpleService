/**
 Provides definition of a request made to a service.
 
 License: MIT
 
 Copyright © 2018 Upstart Illustration LLC. All rights reserved.
 */

import Foundation

enum ServiceRequestType {
    case get
    case post
}

typealias Endpoints = [Environment: String]

/**
 Notes:
 `Header`, `PathParameter`, `GetParameter`, and `PostParameter` must be enums with a single associated value for every case.
 */
protocol ServiceEndpoint {
    associatedtype ResponseType: Decodable
    associatedtype Header
    associatedtype PathParameter
    associatedtype QueryParameter
    associatedtype PostParameter
    
    var type: ServiceRequestType { get }
    var endpoints: Endpoints { get }
    var headers: [Header]? { get }
    var pathParameters: [PathParameter]? { get }
    var queryParameters: [QueryParameter]? { get }
    var postParameters: [PostParameter]? { get }
}

/// Default implementations
extension ServiceEndpoint {
    var headers: [Header]? {
        return nil
    }
    var pathParameters: [PathParameter]? {
        return nil
    }
    var queryParameters: [QueryParameter]? {
        return nil
    }
    var postParameters: [PostParameter]? {
        return nil
    }
}
