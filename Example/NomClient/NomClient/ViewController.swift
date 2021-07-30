import UIKit
import NomLibrary

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemBackground
        buildUI()
    }
    
    private func buildUI() {
        view.addSubview(takeSelfieButton)
        takeSelfieButton.translatesAutoresizingMaskIntoConstraints = false
        takeSelfieButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        takeSelfieButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    @objc private func startTakeSelfie() {
        NomLibrary.shared.takeSelfie() { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let image):
                self.showFaceImage(image)
            case .failure(let error):
                self.showError(error)
            }
        }
    }
    
    private func showFaceImage(_ image: UIImage) {
        showAlert(NSLocalizedString("Take selfie result", comment: ""), "", image)
    }
    
    private func showError(_ error: Error) {
        showAlert(NSLocalizedString("Error", comment: ""), error.localizedDescription, nil)
    }
    
    private func showAlert(_ title: String, _ message: String, _ image: UIImage?) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .actionSheet)
        if let image = image {
            let scaledSize = CGSize(width: image.size.width / 3, height: image.size.height / 3)
            let scaledImage = image.imageWithSize(scaledToSize: scaledSize)
            let action = UIAlertAction(title: "", style: .default, handler: nil)
            action.setValue(scaledImage.withRenderingMode(.alwaysOriginal), forKey: "image")
            alert.addAction(action)
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private let takeSelfieButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Start Take Selfie", for: .normal)
        button.addTarget(self, action: #selector(startTakeSelfie), for: .touchUpInside)
        return button
    }()
}

extension UIImage {
    // Scale image for UIAlertAction
    func imageWithSize(scaledToSize newSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
}

