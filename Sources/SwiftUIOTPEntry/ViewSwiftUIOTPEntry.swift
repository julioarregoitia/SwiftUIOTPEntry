//
//  ViewSwiftUIOTPEntry.swift
//  SwiftUIOTPEntry
//
//  Created by Julio Arregoitía on 1/28/25.
//

import SwiftUI
import Combine

// MARK: - OTP ENTRY VIEW
/// A SwiftUI View that displays a row of text fields for entering numbers (e.g., OTP or PIN input).
public struct ViewSwiftUIOTPEntry: View {
    
    // Keep Combine subscriptions in @State so they persist across view updates (SwiftUI re-renders)
    // and are tied to this view's lifetime. This prevents the cancellables from being recreated
    // on each body recomputation and ensures the pipeline stays alive while the view is on-screen.
    @State var subscriptions: Set<AnyCancellable> = .init()
    
    // Publisher used to receive each individual digit from the text fields (emitted on every key press or paste fragment).
    @State var publisherForCodeFromMessage: PassthroughSubject<String, Never> = .init()
    
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
                EnhancedTextField(publisherForCodeFromMessage: publisherForCodeFromMessage, placeholder: "", font: model.font, index: index, codeFilledCount: codeFilledCount, count: model.count, focusedField: $focusIndex, text: $code[index], code: $code) { onEmpty in
                                        
                    let currentFilled = self.codeFilledCount
                    // Check if the focus is in the last filled box or the next one that is empty
                    guard currentFilled == index + 1 || currentFilled == index else { return }
                    
                    // If it's not empty, that means the cursos is on front of the number and still needs to be erased
                    if onEmpty, index > 0 {
                        code[index - 1] = ""
                        focusIndex = index - 1
                        
                    } else {
                        code[index] = ""
                    }
                }
                .frame(width: model.size, height: model.size)
                .background(RoundedRectangle(cornerRadius: 8)
                .stroke(strokeColor(for: index), lineWidth: 1))
                .focused($focusedField, equals: index)
                .tag(index)
                .accessibilityLabel(Text(model.textAccessibilityPosition + ":" + String(index + 1)))
                .accessibilityValue(Text(code[index].isEmpty ? model.textAccessibilityForEmptyBox : code[index]))
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
        .task {
            // Accumulate all digit fragments coming from the text fields within a short time window
            // and then emit them together as a single string. This behaves like a time-based buffer
            // (collect-by-time) instead of a classic debounce that only forwards the last value.
            publisherForCodeFromMessage
                // Collect every value received during a 250ms window on the main queue.
                // Example: if the keyboard/autofill emits multiple small chunks quickly,
                // they will be grouped in one batch.
                .collect(.byTime(DispatchQueue.main, .seconds(0.25)))
                // Join the collected array of strings into one single string to process as a whole code.
                .map { $0.joined() }
                // Send the accumulated code to our handler once the time window closes.
                .sink { joined in
                    self.receiveText(text: joined)
                }
                // Keep the subscription alive while this view is active.
                .store(in: &subscriptions)
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

    private func receiveText(text: String) {
        // Normalize the incoming string to digits only (ignore spaces, non-digits, etc.).
        let cleanValue = text.onlyDigits()

        // Only handle multi-character input here (e.g., paste/autofill bursts). Single-key strokes are handled by the text fields themselves.
        if cleanValue.count > 1 {
            
            // Proceed only if the incoming code matches the expected OTP length.
            if cleanValue.count == model.count {
                
                // Split the code into individual characters and place each one into its corresponding text field box.
                for (i, char) in cleanValue.enumerated() {
                    self.code[i] = String(char)
                }

                // Wait briefly to ensure UI bindings/updates have settled before dismissing the keyboard.
                Task { @MainActor in
                    try await Task.sleep(for: .seconds(0.2))

                    // Clear focus to dismiss the keyboard and stop further edits.
                    self.focusedField = nil
                    self.focusIndex = nil
                }
            }
        }
    }
}

// MARK: - ENHANCED TEXT FIELD
/// A UIViewRepresentable wrapper for a custom UITextField that supports enhanced behaviors for OTP/PIN entry.
fileprivate struct EnhancedTextField: UIViewRepresentable {
    
    // Publisher used to receive each individual digit from the text fields (emitted on every key press or paste fragment).
    let publisherForCodeFromMessage: PassthroughSubject<String, Never>
    
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
        EnhancedTextFieldCoordinator(publisherForCodeFromMessage: publisherForCodeFromMessage, textBinding: $text, index: index, codeFilledCount: codeFilledCount, count: count, focusedField: $focusedField, code: $code)
    }
    
    /// Creates the underlying UITextField view.
    func makeUIView(context: Context) -> EnhancedUITextField {
        let view = EnhancedUITextField()
        view.placeholder = placeholder
        view.delegate = context.coordinator
        view.textAlignment = .center
        view.keyboardType = .numberPad
        view.font = font
        view.adjustsFontForContentSizeCategory = true
        view.textContentType = .oneTimeCode

        return view
    }
    
    /// Updates the UITextField view with the latest state.
    func updateUIView(_ uiView: EnhancedUITextField, context: Context) {
        uiView.text = text
        uiView.onBackspace = onBackspace
    
        context.coordinator.codeFilledCount = codeFilledCount
    }
    
    
    // MARK: ENCHACED TEXT FIELD
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
    
    
    // MARK: - ENCHACE TEXT FIELD COORDINATOR
    /// Coordinator class to bridge UITextFieldDelegate methods to SwiftUI bindings and manage OTP logic.
    class EnhancedTextFieldCoordinator: NSObject, UITextFieldDelegate {
        // Publisher used to receive each individual digit from the text fields (emitted on every key press or paste fragment).
        let publisherForCodeFromMessage: PassthroughSubject<String, Never>
        
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
        ///   - publisherForCodeFromMessage: Publisher used to receive each individual digit from the text fields (emitted on every key press or paste fragment).
        ///   - textBinding: Binding to the text value.
        ///   - index: Index of the field.
        ///   - codeFilledCount: Number of filled boxes.
        ///   - count: Total number of boxes.
        ///   - focusedField: Binding to the focused field index.
        ///   - code: Binding to the code array.
        init(publisherForCodeFromMessage: PassthroughSubject<String, Never>, textBinding: Binding<String>, index: Int, codeFilledCount: Int, count: Int, focusedField: Binding<Int?>, code: Binding<[String]>) {
            self.publisherForCodeFromMessage = publisherForCodeFromMessage
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
            
            // Publish the current digit (or pasted fragment) so the view's Combine pipeline can collect and process it.
            // (ONLY USEFULL FOR THE COPY/PASTE SCENARIO
            publisherForCodeFromMessage.send(cleanValue)
            
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
            
            // Snapshot the current text before any change is applied.
            let currentText = textField.text ?? ""

            // Branch on (currentText.isEmpty, newValue.isEmpty) to handle all input states clearly
            // without nested if/else. Each case covers a distinct scenario.
            switch (currentText.isEmpty, newValue.isEmpty) {
            case (_, true):
                // newValue is empty — the character typed was non-digit and got stripped.
                // Allow the no-op replacement; real deletions are handled by deleteBackward().
                return true

            case (true, false), (false, false):
                // A valid digit arrived regardless of whether the field was empty or already filled.
                // Overwrite the field with the single new digit and advance focus to the next box.
                textField.text = newValue
                self.textBinding.wrappedValue = newValue
                advanceBox()
                return true
            }
        }
        
        /// Moves focus to the next box after a digit is entered, or dismisses the keyboard when the last box is filled.
        private func advanceBox() {
            // Check if it's not the last box of the row
            if index < count - 1 {
                focusedField.wrappedValue = index + 1

                // When it's the last box of the row gets the keyboard off
            } else {
                focusedField.wrappedValue = nil
            }
        }
        
    }
}

