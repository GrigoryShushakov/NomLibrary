import UIKit
import AVFoundation
import Vision

final class FaceDetectionVM: NSObject {
    var callback: ((Result<UIImage, Error>) -> Void)
    let captureService: CaptureSessionServiceProtocol
    let permissionService: CheckPermissionServiceProtocol
    var takeShot = false
    
    // Preview frame rect for transformations
    var previewFrame = CGRect()
    // Vision requests for face and landmarks detection
    private var requests = [VNRequest]()
    
    // Points for draw closed eyes, UIKit coordinates
    var leftEyePoints: [CGPoint]? = [CGPoint]()
    var rightEyePoints: [CGPoint]? = [CGPoint]()
    
    // Custom observables, for binding changes to ui layer
    let didClose: SimpleObservable<Bool> = SimpleObservable(false)
    let haveFaceRect: SimpleObservable<CGRect?> = SimpleObservable(nil)
    
    init(callback: @escaping ((Result<UIImage, Error>) -> Void),
         captureService: CaptureSessionServiceProtocol,
         permissionService: CheckPermissionServiceProtocol) {
        
        self.callback = callback
        self.captureService = captureService
        self.permissionService = permissionService
    }
    
    func configure(_ previewRect: CGRect) {
        self.previewFrame = previewRect
        permissionService.checkPermissions { [weak self] result in
            guard let self = self else { return }
            
            if case let .failure(error) = result {
                self.didClose.value = true
                self.callback(.failure(error))
            } else {
                self.startSession()
            }
        }
    }
    
    private func startSession() {
        captureService.startSession(delegate: self,
                                    completion: { [weak self] result in
            guard let self = self else { return }
                                            
            if case let .failure(error) = result {
                self.didClose.value = true
                self.callback(.failure(error))
            }
        })

        setupVision()
    }
    
    func stopSession() {
        captureService.stopSession()
        requests = []
    }
    
    func putOnGlasses() {
        // TODO:
    }
    
    private func setupVision() {
        let requests = VNDetectFaceLandmarksRequest(completionHandler: self.detectionHandler)
        self.requests = [requests]
    }
    
    private func detectionHandler(request: VNRequest, error: Error?) {
        guard let observations = request.results as? [VNFaceObservation] else { return }
        let result = observations.compactMap { $0 }
        handleResult(result)
    }
    
    private func handleResult(_ result: [VNFaceObservation]) {
        // Only one face accepted
        if result.isEmpty || result.count > 1 {
            haveFaceRect.value = nil
            return
        } else {
            guard let faceRect = result.first?.boundingBox.transform(to: previewFrame) else { return }
            
            let rightEye = result.compactMap { $0.landmarks?.rightEye }
            let rightPoints = rightEye.flatMap { $0.normalizedPoints }
            guard let rightMinY = rightPoints.map({ $0.y }).min(),
                  let rightMaxY = rightPoints.map({ $0.y }).max() else { return }
            let rightEyeHeight = (rightMaxY - rightMinY) / rightMaxY
            
            // Just experimental value
            if rightEyeHeight < 0.045 {
                rightEyePoints = rightPoints.map { $0.transform(to: faceRect) }
            } else {
                rightEyePoints = nil
            }
            
            let leftEye = result.compactMap { $0.landmarks?.leftEye }
            let leftPoints = leftEye.flatMap { $0.normalizedPoints }
            guard let leftMinY = leftPoints.map({ $0.y }).min(),
                  let leftMaxY = leftPoints.map({ $0.y }).max() else { return }
            let leftEyeHeight = (leftMaxY - leftMinY) / leftMaxY
            
            if leftEyeHeight < 0.045 {
                leftEyePoints = leftPoints.map { $0.transform(to: faceRect) }
            } else {
                leftEyePoints = nil
            }
            
            haveFaceRect.value = faceRect
        }
    }
}

extension FaceDetectionVM: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer,
                                                        orientation: .up,
                                                        options: [:])
        do {
            try imageRequestHandler.perform(self.requests)
        } catch {
            print(error)
        }

        if takeShot {
            takeShot = false
            // Try and get a CVImageBuffer out of the sample buffer
            guard let cvBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
            let ciImage = CIImage(cvImageBuffer: cvBuffer)
            let uiImage = UIImage(ciImage: ciImage)

            self.didClose.value = true
            DispatchQueue.main.async {
                self.callback(.success(uiImage))
            }
        }
    }
}
