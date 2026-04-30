//
//  LoginRegisterView.swift
//  Week_10_MAD
//
//  Created by Felicia Sword on 30/04/26.
//

import SwiftUI

struct LoginRegisterView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var isRegistering = false
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "book.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            Text(isRegistering ? "Register" : "Login")
                .font(.largeTitle).bold()
            
            Text("Catatan selamat datang di sini")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            VStack(spacing: 12) {
                if isRegistering {
                    TextField("Name", text: $authVM.myUser.name)
                        .textFieldStyle(.roundedBorder)
                }
                
                TextField("Email", text: $authVM.myUser.email)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                
                SecureField("Password", text: $authVM.myUser.password)
                    .textFieldStyle(.roundedBorder)
            }
            .padding(.horizontal)
            
            if !authVM.errorMessage.isEmpty {
                Text(authVM.errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Button(isRegistering ? "Register" : "Login") {
                Task {
                    if isRegistering {
                        await authVM.signUp()
                    } else {
                        await authVM.signIn()
                    }
                }
            }
            .buttonStyle(.borderedProminent)
            .frame(maxWidth: .infinity)
            .padding(.horizontal)
            
            Button(isRegistering ? "Back to Login" : "Register New Account") {
                isRegistering.toggle()
                authVM.errorMessage = ""
            }
            .foregroundColor(.blue)
            
            Spacer()
        }
    }
}
