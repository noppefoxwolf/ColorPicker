import SwiftUI
import ColorPicker

struct ContentView: View {
    var body: some View {
        Text("ColorPicker Demo")
            .sheet(isPresented: .constant(true)) {
                ColorPicker()
            }
    }
}


struct ColorPicker: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> ColorPickerViewController {
        ColorPickerViewController()
    }
    
    func updateUIViewController(_ uiViewController: ColorPickerViewController, context: Context) {
        uiViewController.selectedColor = .magenta
    }
}
