import SwiftUI
import FamilyControls

@available(iOS 16.0, *)
struct ContentView: View {
    @StateObject var model = ParentalControlManager.shared
    @State var isPresented = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack {
                Button("Giới hạn ứng dụng") {
                    isPresented = true
                }
                .familyActivityPicker(isPresented: $isPresented, selection: $model.selectionToDiscourage)
            }
            .navigationTitle("Kiểm soát ứng dụng")
            .navigationBarItems(trailing: Button("Đóng") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}
