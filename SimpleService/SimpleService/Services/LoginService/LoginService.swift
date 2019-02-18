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
        let endpoint = LoginEndpoint(
            headers: [
                .secret_key("super-secret-hash" /* dependency may provide this value */)
            ],
            pathParameters: [
                .version("1.1"),
                .sessionid("my-session-id" /* dependency may provide this value */)
            ],
            queryParameters: [
                .format("json")
            ],
            postParameters: [
                .username(username),
                .password(password)
            ]
        )
        return request(endpoint)
            .map { response -> LoginResponse in
                return LoginResponse(firstName: "Leonardo", lastName: "da Vinci")
            }
            .mapError { (error) -> LoginServiceError in
                return .none
            }
    }
    
    /// func logout
}
