import SwiftUI
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

extension Color {
    /// Cross-platform equivalent of UIColor.secondarySystemBackground / NSColor.controlBackgroundColor.
    static var secondaryBackground: Color {
#if canImport(UIKit)
        Color(UIColor.secondarySystemBackground)
#elseif canImport(AppKit)
        Color(NSColor.controlBackgroundColor)
#endif
    }
}
