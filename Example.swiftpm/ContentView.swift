import SwiftUI
import ColorPicker

struct ContentView: View {
    @State var isPresented: Bool = false
    
    var body: some View {
        Button(action: {
            isPresented.toggle()
        }, label: {
            Text("Launch ColorPicker")
        }).sheet(isPresented: $isPresented) {
            ColorPicker().ignoresSafeArea()
        }
    }
}

struct ColorPicker: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> ColorPickerViewController {
        ColorPickerViewController()
    }
    
    func updateUIViewController(_ uiViewController: ColorPickerViewController, context: Context) {
        uiViewController.selectedColor = .white
        uiViewController.setDelegate(context.coordinator)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: ColorPickerViewControllerDelegate {
        func colorPickerViewControllerDidFinish(_ viewController: ColorPickerViewController) {
            print("Finish:", viewController.selectedColor)
        }
        
        func colorPickerViewController(_ viewController: ColorPickerViewController, didSelect color: UIColor, continuously: Bool) {
            print("Continuously:", color)
        }
    }
}
