//
//  GameplayView.swift
//  Week_10_MAD
//
//  Created by Felicia Sword on 30/04/26.
//

import SwiftUI

struct GameplayView: View {
    // Gameplay screen for an interactive story.
    // Drives progression through `StoryNode`s, animates narrative text,
    // and awards an achievement when a story path reaches an ending.

    // The title (or identifier) of the story being played; used to locate the entry node and to save achievements.
    let storyTitle: String
    // Provides access to the story graph (nodes and choices).
    @EnvironmentObject var storyVM: StoryViewModel
    // Used to persist achievements for the signed-in user.
    @EnvironmentObject var authVM: AuthViewModel
    // Allows this view to programmatically pop/dismiss itself.
    @Environment(\.dismiss) var dismiss

    // The node the player is currently reading/interacting with.
    @State private var currentNode: StoryNode? = nil
    // The text currently shown on screen; filled gradually by `animateText(_:)` to create a typing effect.
    @State private var displayedText: String = ""
    // Ensures we only record the achievement once per playthrough/end.
    @State private var storyFinished = false
    // A token used to cancel an in-flight typing animation when moving to a new node.
    @State private var animationID: UUID = UUID()

    var body: some View {
        ZStack {
            // Simple full-screen black background for cinematic reading.
            Color.black.ignoresSafeArea()

            VStack {
                // Close button to leave gameplay and return to the previous screen.
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .foregroundColor(.white)
                        .padding()
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Spacer()

                if let node = currentNode {
                    // When a node is loaded, show its animated narrative and either choices or an ending state.
                    VStack(spacing: 16) {
                        // Narrative text is revealed with a typing animation (see `animateText`).
                        Text(displayedText)
                            .foregroundColor(.white)
                            .padding()

                        // No choices means this node is a terminal node (an ending).
                        if node.choices.isEmpty {
                            VStack(spacing: 12) {
                                // "Tamat" indicates the story has concluded.
                                Text("— Tamat —")
                                    .foregroundColor(.gray)
                                    .italic()
                                Button("Kembali ke Beranda") {
                                    dismiss()
                                }
                                .buttonStyle(.borderedProminent)
                            }
                            .padding(.top, 8)
                        } else {
                            // Present available choices that lead to subsequent nodes.
                            ForEach(node.choices) { choice in
                                Button {
                                    // Resolve the next node from the story graph and transition to it.
                                    if let next = storyVM.node(byId: choice.nextNodeId) {
                                        currentNode = next
                                        // Start a fresh typing animation for the new node's narrative.
                                        animateText(next.narrative)
                                        // If the new node is terminal, record the achievement once.
                                        if next.choices.isEmpty {
                                            saveAchievement()
                                        }
                                    }
                                } label: {
                                    HStack {
                                        Text(choice.label)
                                            .foregroundColor(.white)
                                        Spacer()
                                        Image(systemName: "arrow.right")
                                            .foregroundColor(.white)
                                    }
                                    .padding()
                                    .background(Color(.systemGray5).opacity(0.3))
                                    .cornerRadius(8)
                                    .padding(.horizontal)
                                }
                            }
                        }
                    }
                } else {
                    Text("Cerita tidak ditemukan.")
                        .foregroundColor(.white)
                }

                Spacer()
            }
        }
        .onAppear {
            // Load the entry node for this story and kick off the first typing animation.
            currentNode = storyVM.entryNode(for: storyTitle)
            if let node = currentNode {
                animateText(node.narrative)
                // If the very first node is an ending (edge case), still award the achievement.
                if node.choices.isEmpty { saveAchievement() }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    // Typing animation: progressively appends characters with a small delay.
    // Uses `animationID` to cancel any previous animation when moving to a new node.
    func animateText(_ text: String) {
        // Reset the visible text and generate a fresh animation token.
        displayedText = ""
        let id = UUID()
        animationID = id
        for (i, char) in text.enumerated() {
            // Schedule each character with a staggered delay to simulate typing.
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.03) {
                // If a newer animation started, abandon this one to prevent interleaving characters.
                guard self.animationID == id else { return }
                self.displayedText += String(char)
            }
        }
    }

    // Records the completion achievement exactly once per playthrough.
    func saveAchievement() {
        // Prevent duplicate writes if multiple endings are reached or the function is triggered again.
        guard !storyFinished else { return }
        storyFinished = true
        // Persist asynchronously via the authentication/view model context.
        Task { await authVM.addAchievement(storyTitle) }
    }
}

