//
//  ViewSwiftUIOTPEntry.swift
//  SwiftUIOTPEntry
//
//  Created by Julio Arregoitía on 1/28/25.
//

import SwiftUI

// MARK: - OTP ENTRY VIEW
/// A SwiftUI View that displays a row of text fields for entering numbers (e.g., OTP or PIN input).
public struct ViewSwiftUIOTPEntry: View {

    /// UI model containing configuration for the OTP entry fields.
    let model: ModelUISwiftUIOTPEntry
    
    /// The complete code entered by the user, bound to an external state.
    @Binding var number: String
    
    /// Binding to control keyboard dismissal state.
    @Binding var isDismissKeyboard: Bool
    
    /// Array holding the value of each individual text field box.
    @State private var code: [String]
    
    /// The count of filled boxes.
    @State private var codeFilledCount: Int = 0
    
    /// The index of the currently focused text field.
    @FocusState private var focusedField: Int?
    
    /// The index to programmatically focus a text field.
    @State private var focusIndex: Int? = nil

    /// Initializes the ViewSwiftUIOTPEntry with a model and bindings for number and keyboard state.
    /// - Parameters:
    ///   - model: The UI model for the text fields.
    ///   - number: The binding to the code string.
    ///   - isDismissKeyboard: The binding to control keyboard dismissal.
    public init(model: ModelUISwiftUIOTPEntry, number: Binding<String>, isDismissKeyboard: Binding<Bool>) {
        self.model = model
        _number = number
        _isDismissKeyboard = isDismissKeyboard
        self.code = Array(repeating: "", count: model.count)
    }

    /// The main view body displaying the row of OTP input boxes.
    public var body: some View {
        // OTP INPUT ROW
        HStack(spacing: model.spacing) {
            ForEach(0..<model.count, id: \.self) { index in
                EnhancedTextField(placeholder: "", font: model.font, index: index, codeFilledCount: codeFilledCount, count: model.count, focusedField: $focusIndex, text: $code[index], code: $code) { onEmpty in
                                        
                    let currentFilled = self.codeFilledCount
                    // Check if the focus is in the last filled box or the next one that is empty
                    guard currentFilled == index + 1 || currentFilled == index else { return }
                    
                    // Move focus to the previous field if not the first
                    if index > 0 {
                        focusedField = index - 1
                    }
                    
                    // If it's not empty, that means the cursos is on front of the number and still needs to be erased
                    if !onEmpty {
                        code[index] = ""
                    }
                }
                .frame(width: model.size, height: model.size)
                .background(RoundedRectangle(cornerRadius: 8)
                .stroke(strokeColor(for: index), lineWidth: 1))
                .focused($focusedField, equals: index)
                .tag(index)
                .onChange(of: focusIndex) { oldValue, newValue in
                    // Update focus when focusIndex changes
                    focusedField = newValue
                    if newValue != nil {
                        isDismissKeyboard = false
                    }
                }
                .onChange(of: code) { _, newValue in
                    let joined = newValue.joined()
                    self.number = joined
                    
                    var count: Int = 0
                    for value in newValue {
                        guard !value.isEmpty else { break }
                        count += 1
                    }
                    self.codeFilledCount = count
                }
                
            } //: FOR EACH
            
        } //: HSTACK
        .onChange(of: isDismissKeyboard) { _, newValue in
            // Dismiss keyboard if requested
            if newValue {
                self.focusedField = nil
            }
        }
    }
    
    /// Returns the appropriate border color for a given text field index.
    /// - Parameter index: The index of the text field.
    /// - Returns: The color to use for the border.
    private func strokeColor(for index: Int) -> Color {
        if let focusedField {
            
            if focusedField == index {
                return model.colorFocused
                
            } else {
                let color = code[index].isEmpty ? model.colorEmpty : model.colorFill
                return color
            }
            
        } else {
            let color = code[index].isEmpty ? model.colorEmpty : model.colorFill
            return color
        }
    }

}

// MARK: - ENHANCED TEXT FIELD
/// A UIViewRepresentable wrapper for a custom UITextField that supports enhanced behaviors for OTP/PIN entry.
fileprivate struct EnhancedTextField: UIViewRepresentable {
    
    /// The placeholder text for the text field.
    let placeholder: String
    
    /// The font used for the text field.
    let font: UIFont
    
    /// The index of this text field in the row.
    let index: Int
    
    /// The number of boxes that have been filled.
    let codeFilledCount: Int
    
    /// The total number of boxes.
    let count: Int
    
    /// The binding to the currently focused field index.
    @Binding var focusedField: Int?
    
    /// The binding to the text value of this field.
    @Binding var text: String
    
    /// The binding to the entire code array.
    @Binding var code: [String]
    
    /// Callback for when backspace is pressed on an empty field.
    let onBackspace: (Bool) -> Void
    
    /// Creates the coordinator for the EnhancedTextField.
    func makeCoordinator() -> EnhancedTextFieldCoordinator {
        EnhancedTextFieldCoordinator(textBinding: $text, index: index, codeFilledCount: codeFilledCount, count: count, focusedField: $focusedField, code: $code)
    }
    
    /// Creates the underlying UITextField view.
    func makeUIView(context: Context) -> EnhancedUITextField {
        let view = EnhancedUITextField()
        view.placeholder = placeholder
        view.delegate = context.coordinator
        view.textAlignment = .center
        view.keyboardType = .numberPad
        view.font = font

        return view
    }
    
    /// Updates the UITextField view with the latest state.
    func updateUIView(_ uiView: EnhancedUITextField, context: Context) {
        uiView.text = text
        uiView.onBackspace = onBackspace
    
        context.coordinator.codeFilledCount = codeFilledCount
    }
    
    /// Custom UITextField subclass that detects backspace events.
    class EnhancedUITextField: UITextField {
        /// Closure called when backspace is pressed.
        var onBackspace: ((Bool) -> Void)?
        
        override init(frame: CGRect) {
            onBackspace = nil
            super.init(frame: frame)
        }
        
        required init?(coder: NSCoder) {
            fatalError()
        }
        
        /// Detects backspace key press and calls the onBackspace closure.
        override func deleteBackward() {
            onBackspace?(text?.isEmpty == true)
            super.deleteBackward()
        }
    }
    
    /// Coordinator class to bridge UITextFieldDelegate methods to SwiftUI bindings and manage OTP logic.
    class EnhancedTextFieldCoordinator: NSObject, UITextFieldDelegate {
        /// Binding to the text value of this field.
        let textBinding: Binding<String>
        
        /// The index of this text field in the row.
        let index: Int

        /// The number of boxes that have been filled.
        var codeFilledCount: Int

        /// The total number of boxes.
        let count: Int

        /// Binding to the currently focused field index.
        let focusedField: Binding<Int?>

        /// Binding to the entire code array.
        let code: Binding<[String]>

        /// Initializes the coordinator.
        /// - Parameters:
        ///   - textBinding: Binding to the text value.
        ///   - index: Index of the field.
        ///   - codeFilledCount: Number of filled boxes.
        ///   - count: Total number of boxes.
        ///   - focusedField: Binding to the focused field index.
        ///   - code: Binding to the code array.
        init(textBinding: Binding<String>, index: Int, codeFilledCount: Int, count: Int, focusedField: Binding<Int?>, code: Binding<[String]>) {
            self.textBinding = textBinding
            self.index = index
            self.codeFilledCount = codeFilledCount
            self.count = count
            self.focusedField = focusedField
            self.code = code
        }
                
        /// Controls whether the text field should begin editing, enforcing sequential entry.
        func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
            let currentIndex = self.index
            let currentFilled = self.codeFilledCount
            
            // Prevent editing fields ahead of the current filled count
            if currentIndex > currentFilled {
                self.focusedField.wrappedValue = currentFilled
                return false
                
            } else if let focusedFieldIndex = self.focusedField.wrappedValue, focusedFieldIndex != currentIndex {
                self.focusedField.wrappedValue = currentIndex
                return true
                
            } else {
                return true
            }
        }
        
        /// Updates the focused field index when editing begins.
        func textFieldDidBeginEditing(_ textField: UITextField) {
            let currentIndex = self.index
            self.focusedField.wrappedValue = currentIndex
        }
        
        /// Handles character changes, focus movement, and input restrictions for OTP entry.
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            
            // Remove the extra characters to leave only the digits
            let cleanValue = string.onlyDigits()
            
            // Handle paste of full code
            if cleanValue.count > 1 {
                
                if cleanValue.count == count && index == 0 {
                    
                    for (i, char) in cleanValue.enumerated() {
                        self.code.wrappedValue[i] = String(char)
                    }
                    self.focusedField.wrappedValue = nil
                }
                return false
            }

            // Get the last character of the String
            let newValue = String(cleanValue.suffix(1))
            
            let currentIndex = self.index
            let currentFilled = self.codeFilledCount

            // If the value is Empty, must delete only if it's the last member
            if newValue.isEmpty {
                guard currentIndex + 1 == currentFilled else { return false }
            }
            
            // Update the final value for the current textField
            textField.text = newValue
            self.textBinding.wrappedValue = newValue
            
            // If the value is empty, that means that the number was deleted
            if newValue.isEmpty {
                
                // Check if the index is not the first, to go for the previous one
                if index > 0 {
                    focusedField.wrappedValue = index - 1
                }
                
            // Go to this part if exists a value
            } else {
                
                // Check if it's not the last box of the row
                if index < count - 1 {
                    focusedField.wrappedValue = index + 1
                    
                // When it's the last box of the row gets the keyboard off
                } else {
                    focusedField.wrappedValue = nil
                }
            }

            return true
        }
    }
}
