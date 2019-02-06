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

enum HTTPBodyEncodingStrategy {
    /// Encode data as JSON object
    case json
    
    /// Encode data as k1=v1[&k2=v2...]
    case keyValue
}

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
    var plugins: [ServicePluginKey]? { get }
    var endpoints: Endpoints { get }
    var headers: [Header]? { get }
    var pathParameters: [PathParameter]? { get }
    var queryParameters: [QueryParameter]? { get }
    var postParameters: [PostParameter]? { get }
    var httpBodyEncodingStrategy: HTTPBodyEncodingStrategy { get }
}

/// Default implementations
extension ServiceEndpoint {
    var plugins: [ServicePluginKey]? {
        return nil
    }
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
    var httpBodyEncodingStrategy: HTTPBodyEncodingStrategy {
        return .json
    }
}
