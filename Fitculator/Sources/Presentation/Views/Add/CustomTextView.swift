//
//  CustomTextView.swift
//  Fitculator
//
//  Created by 임재현 on 2/20/25.
//

import SwiftUI

struct CustomTextView: UIViewRepresentable {
    @Binding var text: String
    @FocusState var isFocused: Bool
    var onFocus: ((Bool) -> Void)?
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.font = .systemFont(ofSize: 16)
        textView.textColor = .white
        textView.backgroundColor = .clear
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: CustomTextView
        
        init(_ textView: CustomTextView) {
            self.parent = textView
        }
        
        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            parent.isFocused = true
            parent.onFocus?(true)
        }
                
        func textViewDidEndEditing(_ textView: UITextView) {
            parent.isFocused = false
            parent.onFocus?(false)
        }
    }
}
