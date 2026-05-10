import SwiftUI

extension View {
    /// Applies .navigationBarTitleDisplayMode(.inline) on iOS; no-op on macOS.
    @ViewBuilder
    func inlineNavigationTitle() -> some View {
#if os(iOS)
        self.navigationBarTitleDisplayMode(.inline)
#else
        self
#endif
    }
}
