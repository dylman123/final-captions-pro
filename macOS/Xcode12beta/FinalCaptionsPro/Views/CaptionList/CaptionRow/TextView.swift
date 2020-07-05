//
//  TextView.swift
//  FinalCaptionsPro
//
//  Created by Dylan Klein on 30/6/20.
//

import SwiftUI

//struct CustomTextField: NSViewRepresentable {
//
//    class Coordinator: NSObject, NSTextFieldDelegate {
//
//        @Binding var text: String
//        var didBecomeFirstResponder = false
//
//        init(text: Binding<String>) {
//            _text = text
//        }
//
//        func textFieldDidChangeSelection(_ textField: NSTextField) {
//            text = textField.stringValue
//        }
//
//    }
//
//    @Binding var text: String
//    var isFirstResponder: Bool = false
//
//    func makeNSView(context: NSViewRepresentableContext<CustomTextField>) -> NSTextField {
//        let textField = NSTextField(frame: .zero)
//        textField.delegate = context.coordinator
//        return textField
//    }
//
//    func makeCoordinator() -> CustomTextField.Coordinator {
//        return Coordinator(text: $text)
//    }
//
//    func updateNSView(_ nsView: NSTextField, context: NSViewRepresentableContext<CustomTextField>) {
//        nsView.stringValue = text
//        if isFirstResponder && !context.coordinator.didBecomeFirstResponder  {
//            nsView.becomeFirstResponder()
//            context.coordinator.didBecomeFirstResponder = true
//        }
//    }
//}

//struct CustomTextField: NSViewRepresentable {
//
//  class Coordinator: NSObject, NSTextFieldDelegate {
//
//     @Binding var text: String
//     //@Binding var nextResponder : Bool?
//     @Binding var isResponder : Bool?
//
//
//     init(text: Binding<String>, /*nextResponder : Binding<Bool?>,*/ isResponder : Binding<Bool?>) {
//       _text = text
//       _isResponder = isResponder
//       //_nextResponder = nextResponder
//     }
//
//     func textFieldDidChangeSelection(_ textField: NSTextField) {
//        text = textField.stringValue
//     }
//
//     func textFieldDidBeginEditing(_ textField: NSTextField) {
//        DispatchQueue.main.async {
//            self.isResponder = true
//        }
//     }
//
//     func textFieldDidEndEditing(_ textField: NSTextField) {
//        DispatchQueue.main.async {
//            self.isResponder = false
////            if self.nextResponder != nil {
////                self.nextResponder = true
////            }
//        }
//     }
// }
//
// @Binding var text: String
// //@Binding var nextResponder : Bool?
// @Binding var isResponder : Bool?
//
// var isSecured : Bool = false
// var keyboard : CGEventSourceKeyboardType
//
// func makeNSView(context: NSViewRepresentableContext<CustomTextField>) -> NSTextField {
//     let textField = NSTextField(frame: .zero)
////     textField.isSecureTextEntry = isSecured
////     textField.autocapitalizationType = .none
////     textField.autocorrectionType = .no
////     textField.keyboardType = keyboard
//     textField.delegate = context.coordinator
//     return textField
// }
//
// func makeCoordinator() -> CustomTextField.Coordinator {
//     return Coordinator(text: $text, /*nextResponder: $nextResponder,*/ isResponder: $isResponder)
// }
//
// func updateNSView(_ nsView: NSTextField, context: NSViewRepresentableContext<CustomTextField>) {
//      nsView.stringValue = text
//      if isResponder ?? false {
//          nsView.becomeFirstResponder()
//      }
// }
//
//}

struct TextView: View {
    
    // Constants
    let textWidth = CGFloat(300.0)
    let textOffset = CGFloat(-40.0)
    let deltaOffset = CGFloat(6.0)
    
    // Variables
    @EnvironmentObject var app: AppState
    @EnvironmentObject var row: RowProperties
//    @State private var isFirstResponder : Bool? = true  // set true , if you want to focus it initially, and set false if you want to focus it by tapping on it.
    
    // The current caption binding (for text)
    var binding: Binding<Caption> {
        return $app.captions[row.index]
    }
    
    var body: some View {
        
        if row.isSelected {
            // Caption text
            return AnyView(ZStack {
                if app.mode == .edit {
                    TextField(row.caption.text, text: binding.text, onCommit: {
                        NotificationCenter.default.post(name: .returnKey, object: nil)
                    })
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                } else {
                    Text(row.caption.text)
                        .offset(x: -5)
                }
            }
            .multilineTextAlignment(.center)
            .lineLimit(2)
            .clickable(app, row, fromView: .text)
            .offset(x: textOffset + deltaOffset)
            .frame(width: textWidth)
            )
        
        }
        else {
            return AnyView(Text(row.caption.text)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(width: textWidth)
                .offset(x: textOffset)
                .clickable(app, row, fromView: .text)
            )
        }
    }
}

struct TextView_Previews: PreviewProvider {
    static var previews: some View {
        TextView()
            .environmentObject(RowProperties(Caption(), 0, true, 1, .black))
    }
}
