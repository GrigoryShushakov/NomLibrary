import XCTest
@testable import NomLibrary

final class PermissionsTests: XCTestCase {
    func testPermissions() {
        let checkService = CheckPermissionsService()
        checkService.checkPermissions { result in
            guard case .success(let value) = result else {
                return XCTFail("Expected to be a success but got a failure with \(result)")
            }
            XCTAssertNotNil(value)
        }
    }
}
