/**
 License: MIT

 Copyright © 2019 Upstart Illustration LLC. All rights reserved.
 */

import Foundation

extension Encodable {
    
    var asJson: Data? {
        if self is [String: Any] || self is [[String: Any]] {
            return try? JSONSerialization.data(withJSONObject: self, options: [])
        }
        return try? JSONEncoder().encode(self)
    }
    
    var asJsonString: String? {
        guard let json = asJson else {
            return nil
        }
        return String(data: json, encoding: .utf8)
    }
    
    var asDictionary: [String: Any]? {
        // Already a dictionary
        if let dict = self as? [String: Any] {
            return dict
        }
        guard let json = asJson else {
            return nil
        }
        // Self is an object
        return (try? JSONSerialization.jsonObject(with: json)) as? [String: Any]
    }
}
