//
//  MainTabView.swift
//  Week_10_MAD
//
//  Created by Felicia Sword on 30/04/26.
//

import SwiftUI

struct MainTabView: View {
    @StateObject var storyVM = StoryViewModel()

    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("Home", systemImage: "book.fill") }

            AdminView()
                .tabItem { Label("Admin", systemImage: "pencil") }

            ProfileView()
                .tabItem { Label("Profil", systemImage: "person.fill") }
        }
        .environmentObject(storyVM)
        .onAppear { storyVM.fetchNodes() }
    }
}
