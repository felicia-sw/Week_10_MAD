//
//  ProfileView.swift
//  Week_10_MAD
//
//  Created by Felicia Sword on 30/04/26.
//

import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var storyVM: StoryViewModel

    var body: some View {
        NavigationStack {
            List {
                // --- User info ---
                Section {
                    HStack {
                        Spacer()
                        VStack(spacing: 8) {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 60))
                            Text(authVM.user?.email ?? "")
                                .font(.headline)
                            Text("Pencatat takdir yang bijaksana")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                    }
                    .padding(.vertical)
                }

                // --- Achievements (live from Firestore) ---
                Section("Achievements") {
                    if authVM.achievements.isEmpty {
                        Text("Belum ada cerita yang selesai.")
                            .font(.caption)
                            .foregroundColor(.gray)
                    } else {
                        ForEach(authVM.achievements, id: \.self) { title in
                            HStack {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.orange)
                                VStack(alignment: .leading) {
                                    Text(title)
                                        .font(.subheadline).bold()
                                    Text("Cerita selesai.")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                }

                // --- Seed Data ---
                Section("Seed Data") {
                    Button {
                        storyVM.seedPirate()
                    } label: {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Bajak laut").bold()
                                Text("Mulai petualangan mencari harta karun samudra.")
                                    .font(.caption).foregroundColor(.gray)
                            }
                            Spacer()
                            Image(systemName: "plus")
                        }
                    }

                    Button {
                        storyVM.seedNinja()
                    } label: {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Ninja").bold()
                                Text("Mulai perjalanan ninja menembus batas desa.")
                                    .font(.caption).foregroundColor(.gray)
                            }
                            Spacer()
                            Image(systemName: "plus")
                        }
                    }

                    Button {
                        storyVM.seedRomance()
                    } label: {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Romance").bold()
                                Text("Mulai kisah asmara manis di bawah sakura.")
                                    .font(.caption).foregroundColor(.gray)
                            }
                            Spacer()
                            Image(systemName: "plus")
                        }
                    }
                }

                // --- Logout ---
                Section {
                    Button("Keluar Akun") {
                        authVM.signOut()
                    }
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .navigationTitle("Profil")
        }
    }
}
