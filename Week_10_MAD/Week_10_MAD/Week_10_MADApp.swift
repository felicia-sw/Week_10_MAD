//
//  Week_10_MADApp.swift
//  Week_10_MAD
//
//  Created by Felicia Sword on 30/04/26.
//

import SwiftUI
import Firebase

@main
struct Week_10_MADApp: App {
    @StateObject var authVM: AuthViewModel

    init() {
        // Firebase MUST be configured before any Firebase service is touched.
        // AuthViewModel's init calls Auth.auth().currentUser, so configure first.
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        // Now safe to create AuthViewModel
        _authVM = StateObject(wrappedValue: AuthViewModel())
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authVM)
        }
    }
}
