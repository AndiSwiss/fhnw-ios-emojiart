import SwiftUI

struct EditableText: View {
    var text: String = ""
    var isEditing: Bool
    var onChanged: (String) -> Void

    @State private var editableText: String = ""

    init(_ text: String, isEditing: Bool, onChanged: @escaping (String) -> Void) {
        self.text = text
        self.isEditing = isEditing
        self.onChanged = onChanged
    }

    var body: some View {
        Group {
            if isEditing {
                TextField(text, text: $editableText)
                    .onChange(of: editableText) { text in
                        onChanged(editableText)
                    }
            } else {
                Text(text)
            }
        }
        .onAppear { self.editableText = self.text }
    }
}
