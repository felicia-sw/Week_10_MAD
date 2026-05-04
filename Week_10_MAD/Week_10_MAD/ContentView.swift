//
//  ContentView.swift
//  Week_10_MAD
//
//  Created by Felicia Sword on 30/04/26.
//

import SwiftUI

/// ContentView acts as a simple router. It decides which top-level
/// screen to show based on authentication state exposed by `AuthViewModel`.
struct ContentView: View {
    /// `AuthViewModel` is injected from the environment (e.g., in the app entry point).
    /// Make sure `.environmentObject(AuthViewModel())` is applied to an ancestor view,
    /// otherwise the app will crash at runtime.
    @EnvironmentObject var authVM: AuthViewModel
    
    /// Show the main app interface when signed in, otherwise show the auth flow.
    var body: some View {
        // This condition reacts to changes in `authVM.isSignedIn` and swaps the root view accordingly.
        if authVM.isSignedIn {
            // Primary, post-login experience (tabs, home, etc.).
            MainTabView()
        } else {
            // Authentication flow for signing in or creating an account.
            LoginRegisterView()
        }
    }
}

