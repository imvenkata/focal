import UIKit

final class HapticManager {
    static let shared = HapticManager()

    private init() {}

    func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }

    func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }

    func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }

    // MARK: - Convenience Methods

    func taskCompleted() {
        notification(.success)
    }

    func colorSelected() {
        impact(.light)
    }

    func iconSelected() {
        impact(.light)
    }

    func timeSnapped() {
        selection()
    }

    func deleted() {
        notification(.warning)
    }

    func error() {
        notification(.error)
    }

    func fabTapped() {
        impact(.medium)
    }

    func buttonTapped() {
        impact(.light)
    }

    // MARK: - Drag & Drop

    func dragActivated() {
        impact(.heavy)
    }

    func dragMoved() {
        impact(.soft)
    }

    func dragDropped() {
        notification(.success)
    }

    func dragCancelled() {
        impact(.light)
    }
}
