//
//  ViewModelOTPEntryState.swift
//  SwiftUIOTPEntry
//
//  Created by Julio Arregoitía Val on 2/27/26.
//

import SwiftUI

// MARK: - OTP ENTRY STATE
/// Observable state object that keeps `code` and `filledCount` synchronised.
/// Every coordinator (one per box) shares the **same reference**, so `filledCount`
/// is always up-to-date when UIKit asks `textFieldShouldBeginEditing`.
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
    
    /// Sends `resignFirstResponder` through the responder chain to dismiss the keyboard.
    func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
