/**
 Provides definition of a request made to a service.
 
 License: MIT
 
 Copyright © 2018 Upstart Illustration LLC. All rights reserved.
 */

import Foundation

class URLRequestFactory {
    
    func make<T: ServiceEndpoint>(from endpoint: T, in environment: Environment) throws -> URLRequest {
        guard var urlString = endpoint.endpoints[environment] else {
            throw ServiceError.noURLForEnvironment(environment)
        }
        
        urlString = interpolatePathParameters(urlString: urlString, using: endpoint)
        
        var urlComponents = URLComponents(string: urlString)
        urlComponents?.queryItems = queryItems(for: endpoint)
        
        guard let url = urlComponents?.url else {
            throw ServiceError.invalidURLForEnvironment(environment)
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.allHTTPHeaderFields = httpHeaderFields(for: endpoint)
        urlRequest.httpMethod = httpMethod(for: endpoint)
        urlRequest.httpBody = httpBody(for: endpoint)
        
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
    
    private func httpHeaderFields<T: ServiceEndpoint>(for endpoint: T) -> [String: String]? {
        guard let headers = endpoint.headers else {
            return nil
        }
        
        var headerFields = [String: String]()
        for header in headers {
            guard let param = nameValue(for: "\(header)") else {
                print("ERROR: Failed to extract key/value header parameter for \(header). It must be an `enum` case with a single associated value.")
                return nil
            }
            let nameParts = param.name.components(separatedBy: "_").map { (string) -> String in
                return string.capitalizedFirstLetter()
            }
            let camelCasedName = nameParts.joined(separator: "-")
            headerFields[camelCasedName] = param.value
        }
        return headerFields
    }
    
    private func queryItems<T: ServiceEndpoint>(for endpoint: T) -> [URLQueryItem]? {
        guard let parameters = endpoint.queryParameters else {
            return nil
        }
        
        var items = [URLQueryItem]()
        for parameter in parameters {
            guard let param = nameValue(for: "\(parameter)") else {
                print("ERROR: Failed to extract key/value GET parameter for \(parameter). It must be an `enum` case with a single associated value.")
                return nil
            }
            
            items.append(URLQueryItem(name: param.name, value: param.value))
        }
        return items
    }
    
    private func httpMethod<T: ServiceEndpoint>(for endpoint: T) -> String {
        switch endpoint.type {
        case .delete:
            return "DELETE"
        case .get:
            return "GET"
        case .head:
            return "HEAD"
        case .patch:
            return "PATCH"
        case .post:
            return "POST"
        case .put:
            return "PUT"
        }
    }
    
    private func httpBody<T: ServiceEndpoint>(for endpoint: T) -> Data? {
        guard let parameters = endpoint.postParameters else {
            return nil
        }
        
        var dict = [String: String]()
        
        for parameter in parameters {
            guard let param = nameValue(for: "\(parameter)") else {
                print("ERROR: Failed to extract POST key/value parameter for \(parameter). It must be an `enum` case with a single associated value.")
                return nil
            }
            
            dict[param.name] = param.value
        }
        
        switch endpoint.httpBodyEncodingStrategy {
        case .json:
            return dict.asJson
        case .keyValue:
            return dict.asKeyValuePairs
        }
    }
    
    func interpolatePathParameters<T: ServiceEndpoint>(urlString: String, using endpoint: T) -> String {
        guard let parameters = endpoint.pathParameters else {
            return urlString
        }
        
        var urlString = urlString
        for parameter in parameters {
            guard let param = nameValue(for: "\(parameter)") else {
                print("ERROR: Failed to extract path parameter key/value for \(parameter). It must be an `enum` case with a single associated value.")
                return urlString
            }
            // TODO: Throw error if the parameter was not found in the URL.
            guard urlString.range(of: param.name) != nil else {
                print("ERROR: Failed to interpolate parameter \(param.name) as it was not found in the URL string. Either remove the path parameter or add it to the `ServiceEndpoint` URL string.")
                return urlString
            }
            urlString = urlString.replacingOccurrences(of: "%{\(param.name)}", with: param.value)
        }
        return urlString
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

private extension String {
    func capitalizedFirstLetter() -> String {
        return prefix(1).uppercased() + lowercased().dropFirst()
    }
}
