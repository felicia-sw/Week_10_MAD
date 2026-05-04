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
    @Published var achievements: [String] = []   // list of completed story titles

    private let db = Firestore.firestore()

    init() {
        checkUserSession()
    }

    // MARK: - Session

    func checkUserSession() {
        self.user = Auth.auth().currentUser
        self.isSignedIn = self.user != nil
        if isSignedIn { fetchAchievements() }
    }

    // MARK: - Sign in

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

    // MARK: - Sign up

    func signUp() async {
        errorMessage = ""
        do {
            let result = try await Auth.auth().createUser(
                withEmail: myUser.email,
                password: myUser.password
            )
            let uid = result.user.uid
            try await db.collection("users").document(uid).setData([
                "uid": uid,
                "name": myUser.name,
                "email": myUser.email,
                "achievements": []
            ])
            checkUserSession()
            myUser = MyUser()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Sign out

    func signOut() {
        try? Auth.auth().signOut()
        achievements = []
        checkUserSession()
    }

    // MARK: - Achievements

    /// Fetches the user's achievements array from Firestore
    func fetchAchievements() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        db.collection("users").document(uid).addSnapshotListener { [weak self] snapshot, _ in
            guard let data = snapshot?.data() else { return }
            self?.achievements = data["achievements"] as? [String] ?? []
        }
    }

    /// Appends a story title to the user's achievements (no duplicates)
    func addAchievement(_ storyTitle: String) async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard !achievements.contains(storyTitle) else { return }
        do {
            try await db.collection("users").document(uid).updateData([
                "achievements": FieldValue.arrayUnion([storyTitle])
            ])
        } catch {
            print("Achievement save error: \(error.localizedDescription)")
        }
    }
}
