//
//  GameplayView.swift
//  Week_10_MAD
//
//  Created by Felicia Sword on 30/04/26.
//

import SwiftUI

struct GameplayView: View {
    let storyTitle: String
    @EnvironmentObject var storyVM: StoryViewModel
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.dismiss) var dismiss

    @State private var currentNode: StoryNode? = nil
    @State private var displayedText: String = ""
    @State private var storyFinished = false
    @State private var animationID: UUID = UUID()

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack {
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .foregroundColor(.white)
                        .padding()
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Spacer()

                if let node = currentNode {
                    VStack(spacing: 16) {
                        Text(displayedText)
                            .foregroundColor(.white)
                            .padding()

                        if node.choices.isEmpty {
                            VStack(spacing: 12) {
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
                            ForEach(node.choices) { choice in
                                Button {
                                    if let next = storyVM.node(byId: choice.nextNodeId) {
                                        currentNode = next
                                        animateText(next.narrative)
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
            currentNode = storyVM.entryNode(for: storyTitle)
            if let node = currentNode {
                animateText(node.narrative)
                if node.choices.isEmpty { saveAchievement() }
            }
        }
        .navigationBarHidden(true)
    }

    func animateText(_ text: String) {
        displayedText = ""
        let id = UUID()
        animationID = id
        for (i, char) in text.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.03) {
                guard self.animationID == id else { return }
                self.displayedText += String(char)
            }
        }
    }

    func saveAchievement() {
        guard !storyFinished else { return }
        storyFinished = true
        Task { await authVM.addAchievement(storyTitle) }
    }
}
