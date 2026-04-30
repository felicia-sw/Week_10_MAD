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
    @Environment(\.dismiss) var dismiss
    @State private var currentNode: StoryNode? = nil
    @State private var displayedText: String = ""

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
                            .animation(.easeIn, value: displayedText)

                        ForEach(node.choices) { choice in
                            Button {
                                if let next = storyVM.node(byId: choice.nextNodeId) {
                                    currentNode = next
                                    animateText(next.narrative)
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
                } else {
                    Text("Cerita tidak ditemukan.")
                        .foregroundColor(.white)
                }

                Spacer()
            }
        }
        .onAppear {
            currentNode = storyVM.entryNode(for: storyTitle)
            if let node = currentNode { animateText(node.narrative) }
        }
        .navigationBarHidden(true)
    }

    func animateText(_ text: String) {
        displayedText = ""
        for (i, char) in text.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.03) {
                displayedText += String(char)
            }
        }
    }
}
