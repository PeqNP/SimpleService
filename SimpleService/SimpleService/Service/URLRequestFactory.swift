/**
 `URLRequest` factory
 
 License: MIT
 
 Copyright © 2018 Upstart Illustration LLC. All rights reserved.
 */

import Foundation

class URLRequestFactory {
    
    func make<T: ServiceEndpoint>(from request: T, in environment: Environment) throws -> URLRequest {
        guard let rawUrlString = request.endpoints[environment] else {
            throw ServiceError.noURLForEnvironment(environment)
        }
        
        let urlString = interpolatePathParameters(for: request, on: rawUrlString)
        
        var urlComponents = URLComponents(string: urlString)
        urlComponents?.queryItems = queryItems(for: request)
        
        guard let url = urlComponents?.url else {
            throw ServiceError.invalidURLForEnvironment(environment)
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.allHTTPHeaderFields = httpHeaderFields(for: request)
        urlRequest.httpMethod = httpMethod(for: request)
        urlRequest.httpBody = httpBody(for: request)
        
        return urlRequest
    }
    
    // MARK: - Private
    
    private func nameValue(for string: String) -> (name: String, value: String)? {
        guard let range = string.range(of: "(") else {
            return nil
        }
        
        let name = string.prefix(upTo: range.lowerBound)
        let startIndex = string.index(after: range.lowerBound)
        let endIndex = string.index(before: string.endIndex)
        let valueSubstring = string[startIndex..<endIndex]
        let value = String(valueSubstring).replacingOccurrences(of: "\"", with: "")
        return (name: String(name), value: value)
    }
    
    private func interpolatePathParameters<T: ServiceEndpoint>(for request: T, on urlString: String) -> String {
        guard let pathParameters = request.pathParameters else {
            return urlString
        }
        
        return pathParameters.reduce(urlString) { (result, parameter) -> String in
            guard let param = nameValue(for: "\(parameter)") else {
                log.e("Failed to extract key/value path parameter for \(parameter). It must be an `enum` case with a single associated value.")
                return ""
            }
            return result.replacingOccurrences(of: "{\(param.name)}", with: param.value)
        }
    }
    
    private func httpHeaderFields<T: ServiceEndpoint>(for request: T) -> [String: String]? {
        guard let headers = request.headers else {
            return nil
        }
        
        var headerFields = [String: String]()
        for header in headers {
            guard let param = nameValue(for: "\(header)") else {
                log.e("Failed to extract key/value header parameter for \(header). It must be an `enum` case with a single associated value.")
                return nil
            }
            headerFields[param.name] = param.value
        }
        return headerFields
    }
    
    private func queryItems<T: ServiceEndpoint>(for request: T) -> [URLQueryItem]? {
        guard let parameters = request.queryParameters else {
            return nil
        }
        
        var items = [URLQueryItem]()
        for parameter in parameters {
            guard let param = nameValue(for: "\(parameter)") else {
                log.e("Failed to extract key/value GET parameter for \(parameter). It must be an `enum` case with a single associated value.")
                return nil
            }
            
            items.append(URLQueryItem(name: param.name, value: param.value))
        }
        return items
    }
    
    private func httpMethod<T: ServiceEndpoint>(for request: T) -> String {
        switch request.type {
        case .get:
            return "GET"
        case .post:
            return "POST"
        }
    }
    
    private func httpBody<T: ServiceEndpoint>(for request: T) -> Data? {
        // The post body is `Data`
        if request.httpBodyEncodingStrategy == .data {
            // WARN: if `postBody` is `nil`
            return request.postBody as? Data
        }
        
        if let encodable = request.postBody as? Encodable {
            switch request.httpBodyEncodingStrategy {
            case .json:
                return encodable.asJson
            case .keyValue:
                log.w("Encoding POST w/ `Encodable` key-value parameters is not yet supported")
                return nil
            case .data:
                return nil
            }
        }
        
        // Attempt to encode similar to `PathParameter` and `QueryParameter`.
        // `Any` in this case must be an `enum`.
        guard let parameters = request.postBody as? [Any] else {
            // WARN: Invalid type provide
            return nil
        }
        
        var dict = [String: String]()
        
        for parameter in parameters {
            guard let param = nameValue(for: "\(parameter)") else {
                log.e("Failed to extract POST key/value parameter for \(parameter). It must be an `enum` case with a single associated value.")
                return nil
            }
            
            dict[param.name] = param.value
        }
        
        switch request.httpBodyEncodingStrategy {
        case .json:
            return dict.asJson
        case .keyValue:
            return dict.asKeyValuePairs
        case .data:
            return nil
        }
    }
}

extension Dictionary where Key == String {
    var asKeyValuePairs: Data? {
        let kv: [String] = self.map { (arg) -> String in
            let (key, value) = arg
            return "\(key)=\(value)"
        }
        return kv.joined(separator: "&").data(using: .utf8)
    }
}

extension Encodable {
    var asJson: Data? {
        if self is [String: Any] || self is [[String: Any]] {
            return try? JSONSerialization.data(withJSONObject: self, options: [])
        }
        return try? JSONEncoder().encode(self)
    }
}
