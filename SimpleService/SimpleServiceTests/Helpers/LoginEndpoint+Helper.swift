import AutoEquatable
import Foundation
import Spry

@testable import SimpleService

extension LoginEndpoint: AutoEquatable, SpryEquatable { }
extension LoginEndpoint.Header: AutoEquatable, SpryEquatable { }
extension LoginEndpoint.PathParameter: AutoEquatable, SpryEquatable { }
extension LoginEndpoint.QueryParameter: AutoEquatable, SpryEquatable { }
extension LoginEndpoint.PostParameter: AutoEquatable, SpryEquatable { }
