import UIKit
import AVFoundation

class FaceDetectionController: BaseViewController<FaceDetectionVM> {
    
    private let faceDetectionServicesQueue = DispatchQueue(label: "NomLibrary.faceDetectionServicesQueue", qos: .userInitiated)
    private var previewLayer = AVCaptureVideoPreviewLayer()
    private let canvasView = CanvasView()
    
    override func configure() {
        super.configure()
        buildUI()
        bindVM()
        setupPreviewLayer(viewModel.captureService.captureSession)
        let rect = self.view.bounds
        faceDetectionServicesQueue.async {
            self.viewModel.configure(rect)
        }
    }
    
    private func buildUI(){
        view.addSubview(canvasView)
        view.addSubview(putOnGlassesButton)
        view.addSubview(closeButton)
        view.addSubview(takeShotButton)
        
        canvasView.translatesAutoresizingMaskIntoConstraints = false
        canvasView.backgroundColor = .clear
       
        NSLayoutConstraint.activate([
            canvasView.topAnchor.constraint(equalTo: view.topAnchor),
            canvasView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            canvasView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            canvasView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            putOnGlassesButton.widthAnchor.constraint(equalToConstant: Layout.buttonSize.width),
            putOnGlassesButton.heightAnchor.constraint(equalToConstant: Layout.buttonSize.height),
            putOnGlassesButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Layout.offset),
            putOnGlassesButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Layout.spacing),
            closeButton.widthAnchor.constraint(equalToConstant: Layout.buttonSize.width),
            closeButton.heightAnchor.constraint(equalToConstant: Layout.buttonSize.height),
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Layout.offset),
            closeButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Layout.spacing),
            takeShotButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Layout.takeShotButtonBottom),
            takeShotButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            takeShotButton.widthAnchor.constraint(equalToConstant: Layout.takeShotButtonSize.width),
            takeShotButton.heightAnchor.constraint(equalToConstant: Layout.takeShotButtonSize.height)
        ])
       
        putOnGlassesButton.addTarget(self, action: #selector(putOnGlasses), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        takeShotButton.addTarget(self, action: #selector(takeShot), for: .touchUpInside)
        takeShotButton.isEnabled = false
    }
    
    private func bindVM() {
        viewModel.didClose.bind { [weak self] value in
            guard let self = self else { return }
            if value { self.close() }
        }
        viewModel.haveFaceRect.bind { [weak self] rect in
            guard let self = self else { return }
            DispatchQueue.main.async {
                defer {
                  DispatchQueue.main.async {
                    self.canvasView.setNeedsDisplay()
                  }
                }
                self.canvasView.clear()
                guard rect != nil else { return }
                self.canvasView.faceRect = rect!
                let isCenter = rect!.isCenterPosition(in: self.previewLayer.frame, with: 0.2)
                self.canvasView.faceColor = isCenter ? UIColor.green : UIColor.red
                let rightEyePoints = self.viewModel.rightEyePoints ?? []
                let leftEyePoints = self.viewModel.leftEyePoints ?? []
                self.canvasView.rightEye = rightEyePoints
                self.canvasView.leftEye = leftEyePoints
                self.takeShotButton.isEnabled = isCenter && rightEyePoints.isEmpty && rightEyePoints.isEmpty
            }
        }
    }
    
    private func setupPreviewLayer(_ session: AVCaptureSession) {
        // Insert preview layer
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resize
        previewLayer.frame = view.bounds
        view.layer.insertSublayer(previewLayer, at: 0)
    }
    
    @objc private func close() {
        self.viewModel.stopSession()
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc private func putOnGlasses() {
        faceDetectionServicesQueue.async {
            self.viewModel.putOnGlasses()
        }
    }
    
    @objc private func takeShot() {
        viewModel.takeShot = true
    }
    
    private let putOnGlassesButton = UIButton().createButton(for: "eyeglasses", size: Layout.buttonSize.width / 2)
    private let closeButton = UIButton().createButton(for: "xmark.circle", size: Layout.buttonSize.width / 2)
    private let takeShotButton = UIButton().createButton(for: "largecircle.fill.circle", size: Layout.takeShotButtonSize.width)
}
