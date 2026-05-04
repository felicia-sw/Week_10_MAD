//
//  AdminView.swift
//  Week_10_MAD
//
//  Created by Felicia Sword on 30/04/26.
//

import SwiftUI

struct AdminView: View {
    @EnvironmentObject var storyVM: StoryViewModel
    @State private var showAddNode = false

    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Rancangan Cerita")) {
                    ForEach(storyVM.storyTitles, id: \.self) { title in
                        NavigationLink(destination: StoryNodeListView(storyTitle: title)) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(title)
                                    .font(.headline)
                                Text(storyVM.entryNode(for: title)?.narrative ?? "")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .lineLimit(2)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationTitle("Arsitek")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { showAddNode = true } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddNode) {
                AddNodeView()
            }
        }
    }
}

// MARK: - Story node list (all nodes for one story title)

struct StoryNodeListView: View {
    let storyTitle: String
    @EnvironmentObject var storyVM: StoryViewModel

    var nodes: [StoryNode] {
        storyVM.nodes.filter { $0.storyTitle == storyTitle }
    }

    var body: some View {
        List {
            ForEach(nodes) { node in
                NavigationLink(destination: EditNodeView(node: node)) {
                    VStack(alignment: .leading, spacing: 4) {
                        if node.isEntryPoint {
                            Text("Entry Point")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                        Text(node.narrative)
                            .lineLimit(2)
                            .font(.subheadline)
                        if !node.choices.isEmpty {
                            Text("\(node.choices.count) pilihan")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.vertical, 2)
                }
            }
            .onDelete { indexSet in
                indexSet.forEach { storyVM.deleteNode(nodes[$0]) }
            }
        }
        .navigationTitle(storyTitle)
    }
}

// MARK: - Add Node

struct AddNodeView: View {
    @EnvironmentObject var storyVM: StoryViewModel
    @Environment(\.dismiss) var dismiss

    @State private var narrative = ""
    @State private var storyTitle = ""
    @State private var isEntryPoint = false
    @State private var choices: [StoryChoice] = []
    @State private var newChoiceLabel = ""
    @State private var newChoiceTarget = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Informasi Cerita") {
                    TextField("Judul cerita (e.g. Jalan Ninja)", text: $storyTitle)
                    Toggle("Main Entry Point", isOn: $isEntryPoint)
                }

                Section("Narasi Saat Ini") {
                    TextEditor(text: $narrative)
                        .frame(height: 100)
                }

                Section("Pilihan Cabang") {
                    ForEach(choices.indices, id: \.self) { i in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(choices[i].label)
                                    .font(.subheadline)
                                Text("→ \(targetLabel(choices[i].nextNodeId))")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Button {
                                choices.remove(at: i)
                            } label: {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        TextField("Teks Pilihan (Misal: 'Lari')", text: $newChoiceLabel)
                            .font(.subheadline)

                        Picker("Pilih Tujuan", selection: $newChoiceTarget) {
                            Text("Pilih node tujuan").tag("")
                            ForEach(storyVM.nodes.filter { $0.storyTitle == storyTitle }) { node in
                                Text(String(node.narrative.prefix(50)))
                                    .tag(node.id)
                            }
                        }
                        .pickerStyle(.menu)

                        Button("Simpan Cabang") {
                            guard !newChoiceLabel.isEmpty else { return }
                            choices.append(StoryChoice(
                                label: newChoiceLabel,
                                nextNodeId: newChoiceTarget
                            ))
                            newChoiceLabel = ""
                            newChoiceTarget = ""
                        }
                        .disabled(newChoiceLabel.isEmpty)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Node Baru")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Batal") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Simpan") {
                        let node = StoryNode(
                            id: UUID().uuidString,
                            storyTitle: storyTitle,
                            narrative: narrative,
                            choices: choices,
                            isEntryPoint: isEntryPoint
                        )
                        storyVM.addNode(node)
                        dismiss()
                    }
                    .disabled(storyTitle.isEmpty || narrative.isEmpty)
                }
            }
        }
    }

    func targetLabel(_ id: String) -> String {
        guard !id.isEmpty else { return "belum dipilih" }
        return String((storyVM.node(byId: id)?.narrative.prefix(30) ?? "?") + "…")
    }
}

// MARK: - Edit Node

struct EditNodeView: View {
    @EnvironmentObject var storyVM: StoryViewModel
    @Environment(\.dismiss) var dismiss
    @State var node: StoryNode
    @State private var newChoiceLabel = ""
    @State private var newChoiceTarget = ""

    var body: some View {
        Form {
            Section("Informasi Cerita") {
                TextField("Judul cerita", text: $node.storyTitle)
                Toggle("Main Entry Point", isOn: $node.isEntryPoint)
            }

            Section("Narasi Saat Ini") {
                TextEditor(text: $node.narrative)
                    .frame(height: 100)
            }

            Section("Pilihan Cabang") {
                ForEach(node.choices.indices, id: \.self) { i in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(node.choices[i].label)
                                .font(.subheadline)
                            Text("→ \(targetLabel(node.choices[i].nextNodeId))")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Button {
                            node.choices.remove(at: i)
                        } label: {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    TextField("Teks Pilihan (Misal: 'Lari')", text: $newChoiceLabel)
                        .font(.subheadline)

                    Picker("Pilih Tujuan", selection: $newChoiceTarget) {
                        Text("Pilih node tujuan").tag("")
                        ForEach(storyVM.nodes.filter {
                            $0.storyTitle == node.storyTitle && $0.id != node.id
                        }) { dest in
                            Text(String(dest.narrative.prefix(50)))
                                .tag(dest.id)
                        }
                    }
                    .pickerStyle(.menu)

                    Button("Simpan Cabang") {
                        guard !newChoiceLabel.isEmpty else { return }
                        node.choices.append(StoryChoice(
                            label: newChoiceLabel,
                            nextNodeId: newChoiceTarget
                        ))
                        newChoiceLabel = ""
                        newChoiceTarget = ""
                    }
                    .disabled(newChoiceLabel.isEmpty)
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle("Keputusan")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Simpan") {
                    storyVM.updateNode(node)
                    dismiss()
                }
            }
        }
    }

    func targetLabel(_ id: String) -> String {
        guard !id.isEmpty else { return "belum dipilih" }
        return String((storyVM.node(byId: id)?.narrative.prefix(30) ?? "?") + "…")
    }
}
