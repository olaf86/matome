import SwiftUI

struct NewLogEntrySheetView: View {
    
    @Binding var isPresented: Bool
    @Binding var draftMessage: String
    var onSave: (String) -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                TextEditor(text: $draftMessage)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
            }
            .navigationTitle("New Message")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let trimmed = draftMessage.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmed.isEmpty else { return }
                        onSave(trimmed)
                        isPresented = false
                    }
                    .disabled(draftMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

#Preview {
    StatefulPreviewWrapper(false, "") { isPresented, draft in
        NewLogEntrySheetView(isPresented: isPresented, draftMessage: draft) { _ in }
    }
}

// Helper for binding previews with two values
struct StatefulPreviewWrapper<Value1, Value2, Content: View>: View {
    @State private var value1: Value1
    @State private var value2: Value2
    let content: (Binding<Value1>, Binding<Value2>) -> Content

    init(_ initialValue1: Value1, _ initialValue2: Value2, @ViewBuilder content: @escaping (Binding<Value1>, Binding<Value2>) -> Content) {
        _value1 = State(initialValue: initialValue1)
        _value2 = State(initialValue: initialValue2)
        self.content = content
    }

    var body: some View {
        content($value1, $value2)
    }
}

