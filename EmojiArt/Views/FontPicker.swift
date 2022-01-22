import SwiftUI
import UIKit


typealias FontPickHandler = (UIFont?) -> Void
struct FontPicker: UIViewControllerRepresentable {
    let handlePickedFont: FontPickHandler

    func makeUIViewController(context: Context) -> some UIViewController {
        let viewController = UIFontPickerViewController()
        viewController.delegate = context.coordinator
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(handlePickedFont: handlePickedFont)
    }

    class Coordinator: NSObject, UIFontPickerViewControllerDelegate, UINavigationControllerDelegate {
        let handlePickedFont: FontPickHandler

        init(handlePickedFont: @escaping FontPickHandler) {
            self.handlePickedFont = handlePickedFont
        }

        func fontPickerViewControllerDidPickFont(_ picker: UIFontPickerViewController) {
            let descriptor = picker.selectedFontDescriptor ?? UIFontDescriptor.init()
            handlePickedFont(UIFont(descriptor: descriptor, size: UIFont.systemFontSize))
        }

        func fontPickerViewControllerDidCancel(_ picker: UIFontPickerViewController) {
            handlePickedFont(nil)
        }
    }
}
