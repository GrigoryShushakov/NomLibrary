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
        XCTAssert(viewModel.takeShot == false)
        XCTAssert(viewModel.didClose.value == false)
        XCTAssert(viewModel.isCenter.value == false)
        XCTAssert(viewModel.eyesIsOpen.value == false)
        XCTAssert(viewModel.notRolled.value == false)
        XCTAssert(viewModel.notYawed.value == false)
        XCTAssertTrue(viewModel.rightEyePoints.isEmpty && viewModel.leftEyePoints.isEmpty)
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
