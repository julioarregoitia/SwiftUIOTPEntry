//
//  ContentView.swift
//  Example
//
//  Created by Julio Arregoitía on 7/18/25.
//

import SwiftUI
import SwiftUIOTPEntry

struct ContentView: View {
    
    let model: ModelUISwiftUIOTPEntry = .init(font: .systemFont(ofSize: 20),
                                              count: 6,
                                              spacing: 8,
                                              colorFocused: .red,
                                              colorEmpty: .gray,
                                              colorFill: .green, size: 55)
        
        
    @State var number: String = ""
    
    /// `Bool for dismiss the keyboard
    @State var isDismissKeyboard: Bool = false
    
    var body: some View {
        ZStack {
            Color.white.onTapGesture {
                isDismissKeyboard = true
            }
            
            ViewSwiftUIOTPEntry(model: model, number: $number, isDismissKeyboard: $isDismissKeyboard)
        }
    }
}

#Preview {
    ContentView()
}
