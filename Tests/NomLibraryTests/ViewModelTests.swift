import XCTest
import AVFoundation
@testable import NomLibrary

final class ViewModelTests: XCTestCase {
    
    var captureService: CaptureSessionServiceProtocol!
    var permissionService: CheckPermissionServiceProtocol!
    
    override func setUpWithError() throws {
        permissionService = CheckPermissionServiceMock()
        captureService = CaptureSessionServiceMock()
    }

    func testViewModel() {
        let viewModel = FaceDetectionVM(callback: {_ in },
                                        captureService: captureService,
                                        permissionService: permissionService)
        viewModel.configure()
        XCTAssert(viewModel.takeShot == false)
        XCTAssertNil(viewModel.haveFaceRect.value)
    }
}

private class CaptureSessionServiceMock: CaptureSessionServiceProtocol {
    var captureSession: AVCaptureSession = AVCaptureSession()
    func startSession(delegate: AVCaptureVideoDataOutputSampleBufferDelegate,
                      completion: ((Result<Void, Error>) -> Void)) {}
    func stopSession() {}
}

private class CheckPermissionServiceMock: CheckPermissionServiceProtocol {
    func checkPermissions(completion: @escaping (Result<Void, Error>) -> ()) {}
}
