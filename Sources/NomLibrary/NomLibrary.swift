import UIKit

public class NomLibrary {
    public static let shared = NomLibrary()
    
    public func takeSelfie(_ callback: @escaping (Result<UIImage, Error>) -> Void) {
        guard let topController = UIApplication.shared.window()?.topViewController() else { return }
        let viewModel = FaceDetectionVM(callback: callback,
                                        captureService: CaptureSessionService(),
                                        permissionService: CheckPermissionsService())
        let controller = FaceDetectionController(viewModel: viewModel)
        controller.modalPresentationStyle = .fullScreen
        topController.present(controller, animated: true, completion: nil)
    }
}
