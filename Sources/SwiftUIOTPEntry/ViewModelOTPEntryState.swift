//
//  ViewModelOTPEntryState.swift
//  SwiftUIOTPEntry
//
//  Created by Julio Arregoitía Val on 2/27/26.
//

import SwiftUI

// MARK: - OTP ENTRY STATE
/// Shared OTP entry state used by all input boxes in the component.
/// 
/// `ViewModelOTPEntryState` keeps the per-digit `code` array and the derived
/// `filledCount` in sync, and stores UIKit text field references so focus can be
/// moved imperatively between boxes.
/// 
/// Use one instance per OTP input so all coordinators operate on the same source
/// of truth.
/// 
/// Example:
/// ```swift
/// let state = ViewModelOTPEntryState(count: 6)
/// state.code[0] = "1"
/// state.setTextFieldFirstResponder(at: 1)
/// ```
@Observable @MainActor
final class ViewModelOTPEntryState {
    
    /// Number of consecutively filled boxes from the beginning of the OTP.
    /// This value is derived from `code` and used to enforce sequential editing.
    private(set) var filledCount: Int
    
    /// Registry of UIKit text fields by index, used for imperative focus handoff.
    var textFields: [Int: EnhancedTextField.EnhancedUITextField] = [:]

    /// Per-box OTP values. Updating this array recalculates `filledCount` in `willSet`.
    var code: [String] {
        willSet { filledCount = computeFilledCount(newValue) }
    }

    /// Creates a fresh OTP state with all boxes empty.
    /// - Parameter count: Total number of OTP boxes.
    init(count: Int) {
        let initial = Array(repeating: "", count: count)
        self.code = initial
        self.filledCount = 0
    }

    /// Counts how many boxes are filled consecutively from left to right.
    private func computeFilledCount(_ code: [String]) -> Int {
        var count = 0
        for value in code {
            guard !value.isEmpty else { break }
            count += 1
        }
        return count
    }
    
    /// Returns the UIKit text field registered at a given index, if available.
    func getTextField(at index: Int) -> EnhancedTextField.EnhancedUITextField? {
        textFields[index]
    }
    
    /// Stores a UIKit text field reference for a specific OTP index.
    func setTextField(_ textField: EnhancedTextField.EnhancedUITextField, at index: Int) {
        textFields[index] = textField
    }
    
    /// Moves first responder to the registered text field at the provided index.
    func setTextFieldFirstResponder(at index: Int) {
        textFields[index]?.becomeFirstResponder()
    }
    
    /// Dismisses the current keyboard by asking the active first responder to resign.
    ///
    /// This method sends `resignFirstResponder` through the UIKit responder chain,
    /// allowing whichever control is currently focused to relinquish first responder
    /// status.
    ///
    /// Example:
    /// ```swift
    /// state.dismissKeyboard()
    /// ```
    func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
