import SwiftUI
import UniformTypeIdentifiers

struct MagicPlusButton: View {
    var addAction: () -> Void
    @GestureState private var pressed = false

    var body: some View {
        Circle()
            .fill(Color.accentColor)
            .frame(width: 56, height: 56)
            .overlay(Image(systemName: "plus").foregroundColor(.white))
            .scaleEffect(pressed ? 1.2 : 1)
            .animation(.spring(), value: pressed)
            .padding()
            .onTapGesture(perform: addAction)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .updating($pressed) { _, state, _ in state = true }
            )
            .draggable(NSItemProvider(object: NSString(string: "plus")))
    }
}

#Preview {
    MagicPlusButton(addAction: {})
}
