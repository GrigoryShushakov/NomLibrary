import UIKit
import AVFoundation

class FaceDetectionController: BaseViewController<FaceDetectionVM> {
    
    private let faceDetectionServicesQueue = DispatchQueue(label: "NomLibrary.faceDetectionServicesQueue", qos: .userInitiated)
    private var faceRectangle: OvalView?
    
    override func configure() {
        super.configure()
        buildUI()
        bindVM()
        setupPreviewLayer(viewModel.captureService.captureSession)
        faceDetectionServicesQueue.async {
            self.viewModel.configure()
        }
    }
    
    private func buildUI(){
        view.addSubview(putOnGlassesButton)
        view.addSubview(closeButton)
        view.addSubview(takeShotButton)
       
        NSLayoutConstraint.activate([
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
                self.takeShotButton.isEnabled = rect != nil
                if self.faceRectangle != nil { self.faceRectangle?.removeFromSuperview() }
                guard rect != nil else { return }
                let uikitRect = rect!.transform(to: self.view.frame)
                self.faceRectangle = OvalView(frame: uikitRect)
                self.view.addSubview(self.faceRectangle!)
            }
        }
    }
    
    private func setupPreviewLayer(_ session: AVCaptureSession) {
        // Insert preview layer
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        view.layer.insertSublayer(previewLayer, at: 0)
        previewLayer.frame = view.layer.frame
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
