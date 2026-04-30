//
//  ContentView.swift
//  Week_10_MAD
//
//  Created by Felicia Sword on 30/04/26.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authVM: AuthViewModel
    
    var body: some View {
        if authVM.isSignedIn {
            MainTabView()
        } else {
            LoginRegisterView()
        }
    }
}
