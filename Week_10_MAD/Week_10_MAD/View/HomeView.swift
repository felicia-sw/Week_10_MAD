//
//  HomeView.swift
//  Week_10_MAD
//
//  Created by Felicia Sword on 30/04/26.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var storyVM: StoryViewModel
    @State private var selectedStory: String? = nil

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Pilih jalan yang ingin kau telusuri")
                        .foregroundColor(.gray)
                        .padding(.horizontal)

                    ForEach(storyVM.storyTitles, id: \.self) { title in
                        StoryCardView(title: title, selectedStory: $selectedStory)
                    }
                }
                .padding(.top)
            }
            .navigationTitle("Daftar Cerita")
            .navigationDestination(item: $selectedStory) { title in
                GameplayView(storyTitle: title)
            }
        }
    }
}

struct StoryCardView: View {
    let title: String
    @Binding var selectedStory: String?
    @EnvironmentObject var storyVM: StoryViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.headline)
            Text(storyVM.entryNode(for: title)?.narrative ?? "")
                .font(.caption)
                .foregroundColor(.gray)
                .lineLimit(2)
            Button("Mulai cerita") {
                selectedStory = title
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}
