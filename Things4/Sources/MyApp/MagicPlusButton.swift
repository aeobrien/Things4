import SwiftUI
import UniformTypeIdentifiers

struct MagicPlusButton: View {
    var addAction: () -> Void
    var body: some View {
        Circle()
            .fill(Color.accentColor)
            .frame(width: 56, height: 56)
            .overlay(Image(systemName: "plus").foregroundColor(.white))
            .padding()
            .onTapGesture(perform: addAction)
            .draggable(NSItemProvider(object: NSString(string: "plus")))
    }
}

#Preview {
    MagicPlusButton(addAction: {})
}
