# SwiftUIOTPEntry

**SwiftUIOTPEntry** is a lightweight and customizable SwiftUI component for entering OTP (One-Time Password) or PIN-style codes. Designed for simplicity and full compatibility with **iOS 17+**.

---

![SwiftOTPEntry Demo](Assets/PreviewShow.gif)

## 🚀 Features

- 📱 Built with SwiftUI
- 🔢 Supports variable code lengths (default: 6 digits)
- 🎨 Easy customization of colors, borders, and behavior
- ♿️ Enhanced accessibility (VoiceOver support and Dynamic Type for accessibility texts)
- 🔐 Ideal for OTP and authentication flows

---

## 📦 Installation

You can integrate **SwiftUIOTPEntry** using **Swift Package Manager**.

### Xcode

1. Go to `File > Add Packages...`
2. Enter the repository URL:
   ```
   https://github.com/julioarregoitia/SwiftUIOTPEntry.git
   ```
3. Choose the desired version and add the package to your target.

### Using `Package.swift`

```swift
dependencies: [
    .package(url: "https://github.com/julioarregoitia/SwiftUIOTPEntry.git", from: "1.0.0")
]
```

Then include it in your target:

```swift
.target(
    name: "YourApp",
    dependencies: ["SwiftUIOTPEntry"]
)
```

---

## 🧪 Basic Usage

```swift

import SwiftUI
import SwiftUIOTPEntry

/// Main view that demonstrates the usage of the SwiftUIOTPEntry component
/// This view displays an OTP (One-Time Password) input field with 6 digits
struct ContentView: View {
    
    /// Configuration model for the OTP component
    /// Defines the visual style and behavior of the input field
    let model: ModelUISwiftUIOTPEntry = .init(
        font: .systemFont(ofSize: 20),             // Text font
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
```

---

## ⚙️ Customization

> You can customize the components with the next propierties that shows below:

```swift
struct ModelUISwiftUIOTPEntry {
    /// `Font of each number in the row`
    let font: UIFont
    
    /// `The text with a box is empty to say with VoiceOver`
    let textAccessibilityForEmptyBox: String
    
    /// `The text for VoiceOver to say a position`
    let textAccessibilityPosition: String

    /// `The number of square boxes to fill with numbers`
    let count: Int
    
    /// `The space in horizontal between each square box`
    let spacing: CGFloat
    
    /// `The color of the border of the square when an item is focused`
    let colorFocused: Color
    
    /// `The color of the border of the square when an item is not focused and also NOT filled with a number`
    let colorEmpty: Color

    /// `The color of the border of the square when an item is not focused and also IS filled with a number`
    let colorFill: Color
    
    /// `The size of each square box (take into account that each box is a square)`
    let size: CGFloat
}
```

---

## 📱 Requirements

- iOS 17.0+
- Swift 6.2+
- SwiftUI

---

## 📄 License

This project is released under the MIT License.  
See the `LICENSE` file for more information.

---

## ✨ Contributions

Contributions are welcome!  
Feel free to open issues, suggest features, or submit pull requests.
