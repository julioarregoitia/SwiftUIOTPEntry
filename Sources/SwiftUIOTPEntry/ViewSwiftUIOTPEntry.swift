//
//  ViewSwiftUIOTPEntry.swift
//  SwiftUIOTPEntry
//
//  Created by Julio Arregoitía on 1/28/25.
//

import SwiftUI


// MARK: - TEXT FIELD NUMBERS BOXS
/// A SwiftUI View that displays a row of text fields for entering numbers (e.g., OTP or PIN input).
public struct ViewSwiftUIOTPEntry: View {

    /// Model containing UI configuration for the text fields.
    let model: ModelUISwiftUIOTPEntry
    /// The complete number entered by the user, bound to an external state.
    @Binding var number: String
    
    @Binding var isDismissKeyboard: Bool
    
    /// Array holding the value of each individual text field box.
    @State private var code: [String]
    
    /// The count of filled boxes.
    @State private var codeFilledCount: Int = 0
    
    /// The index of the currently focused text field.
    @FocusState private var focusedField: Int?
    
    /// The index to programmatically focus a text field.
    @State private var focusIndex: Int? = nil

    /// Initializes the ViewTextFieldsNumberBoxs with a model and a binding to the number string.
    /// - Parameters:
    ///   - model: The UI model for the text fields.
    ///   - number: The binding to the number string.
    public init(model: ModelUISwiftUIOTPEntry, number: Binding<String>, isDismissKeyboard: Binding<Bool>) {
        self.model = model
        _number = number
        _isDismissKeyboard = isDismissKeyboard
        self.code = Array(repeating: "", count: model.count)
    }

    /// The main view body displaying the row of number boxes.
    public var body: some View {
        // OTP INPUT
        HStack(spacing: model.spacing) {
            ForEach(0..<model.count, id: \.self) { index in
                EnhancedTextField(placeholder: "", font: model.font, index: index, codeFilledCount: codeFilledCount, count: model.count, focusedField: $focusIndex, text: $code[index]) { onEmpty in
                    if onEmpty && index > 0 {
                        focusedField = index - 1
                    }
                }
                .frame(width: model.size, height: model.size)
                .background(RoundedRectangle(cornerRadius: 8)
                .stroke(strokeColor(for: index), lineWidth: 1))
                .focused($focusedField, equals: index)
                .tag(index)
                .onChange(of: focusIndex) { oldValue, newValue in
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
            if newValue {
                self.focusedField = nil
            }
        }
    }
    
    /// Returns the appropriate stroke color for a given text field index.
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

    public func dismissKeyboard() {
        self.focusedField = nil
    }
}


// MARK: - ENHANCED TEXT FIELD
/// A UIViewRepresentable wrapper for a custom UITextField that supports enhanced behaviors for OTP/PIN entry.
fileprivate struct EnhancedTextField: UIViewRepresentable {
    
    /// The placeholder text for the text field.
    let placeholder: String // text field placeholder
    /// The font used for the text field.
    let font: UIFont // Font of the each number on the Box
    /// The index of this text field in the row.
    let index: Int // Index of each box in the row
    /// The number of boxes that have been filled.
    let codeFilledCount: Int // The counter
    /// The total number of boxes.
    let count: Int
    /// The binding to the currently focused field index.
    @Binding var focusedField: Int?
    /// The binding to the text value of this field.
    @Binding var text: String // input binding
    /// Callback for when backspace is pressed on an empty field.
    let onBackspace: (Bool) -> Void // true if backspace on empty input
    
    /// Creates the coordinator for the EnhancedTextField.
    func makeCoordinator() -> EnhancedTextFieldCoordinator {
        EnhancedTextFieldCoordinator(textBinding: $text, index: index, codeFilledCount: codeFilledCount, count: count, focusedField: $focusedField)
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
    
    /// Coordinator class to bridge UITextFieldDelegate methods to SwiftUI bindings.
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
        var focusedField: Binding<Int?>

        /// Initializes the coordinator.
        /// - Parameters:
        ///   - textBinding: Binding to the text value.
        ///   - index: Index of the field.
        ///   - codeFilledCount: Number of filled boxes.
        ///   - count: Total number of boxes.
        ///   - focusedField: Binding to the focused field index.
        init(textBinding: Binding<String>, index: Int, codeFilledCount: Int, count: Int, focusedField: Binding<Int?>) {
            self.textBinding = textBinding
            self.index = index
            self.codeFilledCount = codeFilledCount
            self.count = count
            self.focusedField = focusedField
        }
                
        /// Controls whether the text field should begin editing.
        func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
            let currentIndex = self.index
            let currentFilled = self.codeFilledCount
            
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
        
        /// Handles character changes in the text field, including moving focus and restricting input.
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            
            // Remove the extra characters to leave only the digits
            let cleanValue = string.onlyDigits()
            
            // Get the last character of the String
            let newValue = String(cleanValue.suffix(1))
            
            // Get the current index locally only for porpuse of Debugging
            let currentIndex = self.index

            // Get the current index locally only for porpuse of Debugging
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
