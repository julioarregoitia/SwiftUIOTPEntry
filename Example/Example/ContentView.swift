//
//  ContentView.swift
//  Example
//
//  Created by Julio Arregoitía on 7/18/25.
//

import SwiftUI
import SwiftUIOTPEntry

/// Main view that demonstrates the usage of the SwiftUIOTPEntry component
/// This view displays an OTP (One-Time Password) input field with 6 digits
struct ContentView: View {
    
    /// Configuration model for the OTP component
    /// Defines the visual style and behavior of the input field
    let model: ModelUISwiftUIOTPEntry = .init(
        font: .preferredFont(forTextStyle: .body),             // Text font
        textAccessibilityForEmptyBox: "Empty box", // The info for VoiceOver when a box is empty
        textAccessibilityPosition: "Position",     // The position of a box for VoiceOver
        count: 6,                                  // Number of OTP digits
        spacing: 8,                                // Spacing between fields
        colorFocused: .red,                        // Color when field is focused
        colorEmpty: .gray,                         // Color when field is empty
        colorFill: .green,                         // Color when field has content
        size: 55                                   // Size of each individual field
    )
        
    /// State variable that stores the entered OTP number
    /// Updates automatically when user enters digits
    @State var number: String = ""
    
    /// State variable to control keyboard dismissal
    /// When true, the keyboard is automatically hidden
    @State var isDismissKeyboard: Bool = false
    
    var body: some View {
        ZStack {
            // White background that allows closing keyboard by tapping outside the field
            Color.white.onTapGesture {
                isDismissKeyboard = true
            }
            
            // Main OTP input component
            // Connects with state variables to synchronize data
            ViewSwiftUIOTPEntry(
                model: model,                    // Component configuration
                number: $number,                 // OTP number binding
                isDismissKeyboard: $isDismissKeyboard  // Keyboard control binding
            )
        }
    }
}

/// Preview view for development and testing
/// Allows viewing the component in Xcode Preview
#Preview {
    ContentView()
}
