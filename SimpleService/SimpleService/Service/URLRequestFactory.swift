/**
 Provides definition of a request made to a service.
 
 License: MIT
 
 Copyright © 2018 Upstart Illustration LLC. All rights reserved.
 */

import Foundation

class URLRequestFactory {
    
    func make<T: ServiceEndpoint>(from request: T, in environment: Environment) throws -> URLRequest {
        guard let urlString = request.endpoints[environment] else {
            throw ServiceError.noURLForEnvironment(environment)
        }
        
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
    
    private func httpHeaderFields<T: ServiceEndpoint>(for request: T) -> [String: String]? {
        guard let headers = request.headers else {
            return nil
        }

        var headerFields = [String: String]()
        for header in headers {
            guard let param = nameValue(for: "\(header)") else {
                print("Failed to extract key/value header parameter for \(header). It must be an `enum` case with a single associated value.")
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
                print("Failed to extract key/value GET parameter for \(parameter). It must be an `enum` case with a single associated value.")
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
        guard let parameters = request.postParameters else {
            return nil
        }
        
        var dict = [String: String]()
        
        for parameter in parameters {
            guard let param = nameValue(for: "\(parameter)") else {
                print("Failed to extract POST key/value parameter for \(parameter). It must be an `enum` case with a single associated value.")
                return nil
            }

            dict[param.name] = param.value
        }
        
        switch request.httpBodyEncodingStrategy {
        case .json:
            return dict.asJson
        case .keyValue:
            return dict.asKeyValuePairs
        }
    }
}

private extension Dictionary where Key == String {
    var asJson: Data? {
        // TODO: Does this need to be URL encoded?
        return try? JSONSerialization.data(withJSONObject: self, options: [])
    }
    
    var asKeyValuePairs: Data? {
        let kv: [String] = self.map { (arg) -> String in
            let (key, value) = arg
            return "\(key)=\(value)"
        }
        return kv.joined(separator: "&").data(using: .utf8)
    }
}
