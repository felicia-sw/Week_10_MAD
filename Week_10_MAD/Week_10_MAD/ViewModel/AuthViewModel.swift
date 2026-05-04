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

/**
 AuthViewModel manages user authentication state and user-related data.
 
 This view model interfaces with Firebase Authentication to handle sign-in,
 sign-up, and sign-out operations, and Firestore to persist and observe user achievements.
 
 It publishes user session and authentication state changes so SwiftUI views can react accordingly.
 */
@MainActor // Ensures all published state updates happen on the main thread for UI consistency
class AuthViewModel: ObservableObject {
    /// Mirrors FirebaseAuth current user; optional because user may be signed out
    @Published var user: User?
    /// Derived convenience flag, updated by checkUserSession to indicate sign-in status
    @Published var isSignedIn: Bool = false
    /// Temporary form model used during sign-in/up flows; reset after success to clear form
    @Published var myUser: MyUser = MyUser()
    /// Surfaced to UI to display any authentication-related error messages
    @Published var errorMessage: String = ""
    /// Kept in sync with Firestore using a snapshot listener; stores completed story titles
    @Published var achievements: [String] = []   // list of completed story titles

    /// Shared Firestore instance used for all database operations
    private let db = Firestore.firestore()

    init() {
        // Eagerly restore session and start listeners if already signed in
        checkUserSession()
    }

    /// Reads the current user from FirebaseAuth, sets isSignedIn accordingly,
    /// and conditionally fetches achievements for signed-in users.
    ///
    /// Safe to call after sign in/out to refresh state and update listeners.
    func checkUserSession() {
        self.user = Auth.auth().currentUser
        self.isSignedIn = self.user != nil
        // user and isSignedIn are kept in sync: user non-nil means signed in
        // Attach Firestore listener for achievements only when authenticated
        if isSignedIn { fetchAchievements() }
    }

    /// Attempts to sign in using credentials stored in myUser,
    /// clears previous error message, refreshes session on success,
    /// resets the form model, and captures any error encountered.
    func signIn() async {
        errorMessage = ""
        do {
            _ = try await Auth.auth().signIn(
                withEmail: myUser.email,
                password: myUser.password
            )
            checkUserSession() // Also triggers achievement fetch listener if signed in
            myUser = MyUser()  // Reset form model after successful sign-in
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Creates a new auth user and initializes a Firestore user document
    /// with an empty achievements array, then refreshes session and clears the form.
    func signUp() async {
        errorMessage = ""
        do {
            let result = try await Auth.auth().createUser(
                withEmail: myUser.email,
                password: myUser.password
            )
            let uid = result.user.uid  // Use uid as Firestore document ID for user
            // Set initial user data schema, including empty achievements to track progress
            try await db.collection("users").document(uid).setData([
                "uid": uid,
                "name": myUser.name,
                "email": myUser.email,
                "achievements": []
            ])
            checkUserSession() // Refresh session and start listeners after sign-up
            myUser = MyUser()  // Clear the sign-up form
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Signs out locally, clears cached achievements immediately,
    /// and refreshes session state.
    func signOut() {
        try? Auth.auth().signOut()
        achievements = [] // Clear local cache immediately since listener stops when unauthenticated
        checkUserSession()
    }

    /// Registers a snapshot listener on the user's Firestore document,
    /// keeping the achievements array up to date in real time.
    ///
    /// The listener updates the published achievements property whenever the document changes.
    /// Uses [weak self] to avoid retain cycles.
    func fetchAchievements() {
        guard let uid = Auth.auth().currentUser?.uid else { return } // Only proceed if authenticated
        
        // Streams changes from Firestore user's document.
        // We do not store the listener because the view model's lifecycle is tied to user session.
        db.collection("users").document(uid).addSnapshotListener { [weak self] snapshot, _ in
            // Extract the achievements array from document data, fallback to empty array if missing
            guard let data = snapshot?.data() else { return }
            self?.achievements = data["achievements"] as? [String] ?? []
        }
    }

    /// Appends a story title to the user's achievements in Firestore,
    /// preventing duplicates both locally and on the server with FieldValue.arrayUnion.
    ///
    /// This is an idempotent write that will not add the same achievement more than once.
    func addAchievement(_ storyTitle: String) async {
        guard let uid = Auth.auth().currentUser?.uid else { return } // Require authenticated user
        guard !achievements.contains(storyTitle) else { return }     // Avoid write if already present locally
        do {
            try await db.collection("users").document(uid).updateData([
                // Append the title only if missing from the array (server-side guarantee)
                "achievements": FieldValue.arrayUnion([storyTitle])
            ])
        } catch {
            // Log error but do not update UI; failure to save achievement is non-critical
            print("Achievement save error: \(error.localizedDescription)")
        }
    }
}

