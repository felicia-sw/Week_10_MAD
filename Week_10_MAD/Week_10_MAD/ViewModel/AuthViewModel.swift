//
//  AuthViewModel.swift
//  Week_10_MAD
//
//  Created by Felicia Sword on 30/04/26.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import Combine

@MainActor
class AuthViewModel: ObservableObject {
    @Published var user: User?
    @Published var isSignedIn: Bool = false
    @Published var myUser: MyUser = MyUser()
    @Published var errorMessage: String = ""

    private let db = Firestore.firestore()

    init() {
        checkUserSession()
    }

    func checkUserSession() {
        self.user = Auth.auth().currentUser
        self.isSignedIn = self.user != nil
    }

    func signIn() async {
        errorMessage = ""
        do {
            _ = try await Auth.auth().signIn(
                withEmail: myUser.email,
                password: myUser.password
            )
            checkUserSession()
            myUser = MyUser()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func signUp() async {
        errorMessage = ""
        do {
            let result = try await Auth.auth().createUser(
                withEmail: myUser.email,
                password: myUser.password
            )

            // Save name + email to Firestore under "users/{uid}"
            let uid = result.user.uid
            try await db.collection("users").document(uid).setData([
                "uid": uid,
                "name": myUser.name,
                "email": myUser.email
            ])

            checkUserSession()
            myUser = MyUser()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func signOut() {
        try? Auth.auth().signOut()
        checkUserSession()
    }
}
