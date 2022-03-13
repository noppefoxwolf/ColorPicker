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
        uiViewController.setDelegate(context.coordinator)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: ColorPickerViewControllerDelegate {
        func colorPickerViewControllerDidFinish(_ viewController: ColorPickerViewController) {
            
        }
        
        func colorPickerViewController(_ viewController: ColorPickerViewController, didSelect color: UIColor, continuously: Bool) {
            print(color)
        }
    }
}
