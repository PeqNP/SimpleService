/**
 Provides definition of a request made to a service.
 
 License: MIT
 
 Copyright © 2018 Upstart Illustration LLC. All rights reserved.
 */

import Foundation

enum ServiceRequestType {
    case delete
    case get
    case options
    case patch
    case post
    case put
}

typealias Endpoints = [Environment: String]
typealias EndpointKey = String

enum HTTPBodyEncodingStrategy {
    /// Encode data as JSON object
    case json
    
    /// Encode data as k1=v1[&k2=v2...]
    case keyValue
    
    /// Data (images, binaries, files, etc.)
    case data
}

/**
 Provides a mechansim where parameters defined as `enum` cases can have their associated values returned.
 */
protocol ServiceParameter {
    
}

extension ServiceParameter {
    var param: (name: String, value: Any)? {
        let mirror = Mirror(reflecting: self)
        guard let child = mirror.children.first else {
            return nil
        }
        guard let name = child.label else {
            return nil
        }
        return (name, child.value)
    }
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
    associatedtype PostBody
    
    static var key: EndpointKey { get }
    var key: EndpointKey { get }
    var type: ServiceRequestType { get }
    var plugins: [ServicePluginKey]? { get }
    var endpoints: Endpoints { get }
    var headers: [Header]? { get }
    var pathParameters: [PathParameter]? { get }
    var queryParameters: [QueryParameter]? { get }
    
    /**
     The post body will be encoded differently depending on the `HTTPBodyEncodingStrategy`.
     
     When the value type is:
     `Data` - use only case `.data`
     `[String: Any]` - use cases `.json` or `.keyValue`. `Any` must be any value that can be transformed into a `String`.
     `Encodable` - use only case `.json` or `.keyValue`. In the case of `.keyValue`, the `Encodable` object must only be one level deep.
     
     The default value is `.json`
     */
    var postBody: PostBody? { get }
    var httpBodyEncodingStrategy: HTTPBodyEncodingStrategy { get }
    
    var decoder: ((Data?) -> ResponseType)? { get }
}

/// Default implementations
extension ServiceEndpoint {
    static var key: EndpointKey {
        return String(describing: self)
    }
    var key: EndpointKey {
        return Self.key
    }
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
    var postBody: PostBody? {
        return nil
    }
    var httpBodyEncodingStrategy: HTTPBodyEncodingStrategy {
        return .json
    }
    var decoder: ((Data?) -> ResponseType)? {
        return nil
    }
}
