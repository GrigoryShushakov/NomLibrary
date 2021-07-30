
[![Swift 5.1](https://img.shields.io/badge/swift-5.1-red.svg?style=flat)](https://developer.apple.com/swift)

# NomLibrary

**NomLibrary** is a Framework helped and suitable for take a selfie. The SDK calls the user interface for photography and returns the result of face detection. Also some additional functions available.


## Need Help?

Please, use [GitHub Issues](https://github.com/GrigoryShushakov/nomlibrary/issues) for reporting a bug or requesting a new feature.


## Examples

[Sample App](https://github.com/GrigoryShushakov/NomLibraryClient)


## Installation

NomLibrary can be installed with [Swift Package Manager](https://swift.org/package-manager/).
### Swift Package Manager (Xcode 12 or higher)

1. In Xcode, open your project and navigate to **File** → **Swift Packages** → **Add Package Dependency...**
2. Paste the repository URL (`https://github.com/GrigoryShushakov/NomLibrary.git`) and click **Next**.
3. For **Rules**, select **Version (Up to Next Major)** and click **Next**.
4. Click **Finish**.

[Adding Package Dependencies to Your App](https://developer.apple.com/documentation/swift_packages/adding_package_dependencies_to_your_app)


## Usage

1. For face detection please call `takeSelfie` sdk method in your application.
Method returns UIImage or Error with localized description.

```
NomLibrary.shared.takeSelfie() { result in
    switch result {
    case .success(let image):
        // Face detection image - UIImage
    case .failure(let error):
        showError(error)
    }
}
```

## Adding permissions

NomLibrary requires camera permissions for capturing photos. Your application is responsible to describe the reason why camera is used. You must add `NSCameraUsageDescription` value to info.plist of your application with the explanation of the usage.


## Requirements

- iOS 13.0+
- Swift 5.1+ (Library is written in Swift 5.3)


## Author

Grigory Shushakov


## License

**NomLibrary** is available under the MIT license. See the LICENSE file for more info.

