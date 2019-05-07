/**
 
 License: MIT
 
 Copyright © 2019 Upstart Illustration LLC. All rights reserved.
 */

import BrightFutures
import Foundation

enum LoginProviderError: Error {
    case unknown(Error)
}

protocol LoginProvider {
    func login(username: String, password: String) -> Future<User, LoginProviderError>
}
