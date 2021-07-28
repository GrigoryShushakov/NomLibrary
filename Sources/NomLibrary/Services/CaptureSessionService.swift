import UIKit
import AVFoundation

protocol CaptureSessionServiceProtocol {
    func startSession(delegate: AVCaptureVideoDataOutputSampleBufferDelegate,
                      completion: ((Result<Void,Error>) -> Void))
    func stopSession()
    var captureSession: AVCaptureSession { get }
}

final class CaptureSessionService: CaptureSessionServiceProtocol {
    var captureSession = AVCaptureSession()
    var frontInput: AVCaptureInput!
    var videoOutput: AVCaptureVideoDataOutput!
    
    func stopSession() {
        captureSession.stopRunning()
        videoOutput.setSampleBufferDelegate(nil, queue: nil)
    }
    
    func startSession(delegate: AVCaptureVideoDataOutputSampleBufferDelegate,
                      completion: (Result<Void, Error>) -> Void) {
        
        // Start configuration
        captureSession.beginConfiguration()
        // Setup inputs
        do {
            try self.setupInputs(captureSession)
        } catch {
            completion(.failure(error))
        }
        // Setup output
        do {
            try self.setupOutput(captureSession, delegate)
        } catch {
            completion(.failure(error))
        }
        // Commit configuration
        captureSession.commitConfiguration()
        // Start running session
        captureSession.startRunning()
    }
    
    private func searchCamera(deviceTypes: [AVCaptureDevice.DeviceType],
                              mediaType: AVMediaType,
                              position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        return AVCaptureDevice.DiscoverySession(deviceTypes: deviceTypes,
                                                mediaType: mediaType,
                                                position: position).devices.first
    }
    
    private func setupInputs(_ session: AVCaptureSession) throws {
        // Get front camera
        guard let frontCamera = searchCamera(deviceTypes: [.builtInWideAngleCamera],
                                     mediaType: .video,
                                     position: .front)  else {
            throw AVSessionError.deviceInitFailure("Front camera")
        }
        // Setup input data from devices
        do {
            frontInput = try AVCaptureDeviceInput(device: frontCamera)
        } catch {
            throw AVSessionError.deviceInputInitFailure(error.localizedDescription)
        }
        // Check input for session
        guard session.canAddInput(frontInput) else {
            throw AVSessionError.addInputToSessionFailure("Front camera")
        }
        // Connect camera input to session
        session.addInput(frontInput)
    }
    
    private func setupOutput(_ session: AVCaptureSession, _ delegate: AVCaptureVideoDataOutputSampleBufferDelegate) throws {
        // Create session output
        videoOutput = AVCaptureVideoDataOutput()
        let callbackQueue = DispatchQueue(label: "NomLibrary.callbackQueue", qos: .userInteractive)
        // Setup session output delegate
        videoOutput.setSampleBufferDelegate(delegate, queue: callbackQueue)
        
        guard session.canAddOutput(videoOutput)  else {
            throw AVSessionError.addOutputToSessionFailure
        }
        // Add output to session
        session.addOutput(videoOutput)
        // Only portrait mode in use
        videoOutput.connections.first?.videoOrientation = .portrait
        // Mirror the video stream for front camera
        videoOutput.connections.first?.isVideoMirrored = true
    }
}
