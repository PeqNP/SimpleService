/**
 A fake login service that shows how to consume a `LoginServiceEndpoint` which is configured with every possible property of a `ServiceEndpoint`.
 
 License: MIT
 
 Copyright © 2019 Upstart Illustration LLC. All rights reserved.
 */

import BrightFutures
import Foundation

enum LoginServiceError: Error {
    case none
}

struct LoginResponse {
    let firstName: String
    let lastName: String
}

class LoginService: Service {
    
    func login(username: String, password: String) -> Future<LoginResponse, LoginServiceError> {
        return Future(error: .none)
    }
    
    /// func logout
}
