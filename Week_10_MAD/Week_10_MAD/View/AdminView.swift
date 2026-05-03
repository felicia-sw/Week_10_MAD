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
                ForEach(storyVM.storyTitles, id: \.self) { title in
                    Section(header: Text(title)) {
                        ForEach(storyVM.nodes.filter { $0.storyTitle == title }) { node in
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
                            }
                        }
                        .onDelete { indexSet in
                            let filtered = storyVM.nodes.filter { $0.storyTitle == title }
                            indexSet.forEach { storyVM.deleteNode(filtered[$0]) }
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

// MARK: - Add Node

struct AddNodeView: View {
    @EnvironmentObject var storyVM: StoryViewModel
    @Environment(\.dismiss) var dismiss

    @State private var narrative = ""
    @State private var storyTitle = ""
    @State private var isEntryPoint = false
    @State private var choices: [StoryChoice] = []

    var body: some View {
        NavigationStack {
            Form {
                Section("Story Info") {
                    TextField("Story title (e.g. Jalan Ninja)", text: $storyTitle)
                    Toggle("Main Entry Point", isOn: $isEntryPoint)
                }

                Section("Narrative") {
                    TextEditor(text: $narrative)
                        .frame(height: 120)
                }

                Section("Choices") {
                    // We bind by index so changes propagate correctly
                    ForEach(choices.indices, id: \.self) { i in
                        VStack(alignment: .leading, spacing: 6) {
                            TextField("Choice label", text: $choices[i].label)
                                .font(.subheadline)

                            // Picker to select the destination node
                            Picker("Goes to", selection: $choices[i].nextNodeId) {
                                Text("— pilih node —").tag("")
                                ForEach(storyVM.nodes.filter { $0.storyTitle == storyTitle }) { node in
                                    Text(String(node.narrative.prefix(40)) + "…")
                                        .tag(node.id)
                                }
                            }
                            .pickerStyle(.menu)
                            .font(.caption)
                        }
                        .padding(.vertical, 4)
                    }

                    Button(action: { choices.append(StoryChoice()) }) {
                        Label("Add Choice", systemImage: "plus.circle")
                    }
                }
            }
            .navigationTitle("New Node")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
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
}

// MARK: - Edit Node

struct EditNodeView: View {
    @EnvironmentObject var storyVM: StoryViewModel
    @Environment(\.dismiss) var dismiss
    @State var node: StoryNode

    var body: some View {
        Form {
            Section("Story Info") {
                TextField("Story title", text: $node.storyTitle)
                Toggle("Main Entry Point", isOn: $node.isEntryPoint)
            }

            Section("Narrative") {
                TextEditor(text: $node.narrative)
                    .frame(height: 120)
            }

            Section("Choices") {
                ForEach(node.choices.indices, id: \.self) { i in
                    VStack(alignment: .leading, spacing: 6) {
                        TextField("Choice label", text: $node.choices[i].label)
                            .font(.subheadline)

                        // Picker — shows all nodes in the same story (excluding self)
                        Picker("Goes to", selection: $node.choices[i].nextNodeId) {
                            Text("— pilih node —").tag("")
                            ForEach(storyVM.nodes.filter {
                                $0.storyTitle == node.storyTitle && $0.id != node.id
                            }) { dest in
                                Text(String(dest.narrative.prefix(40)) + "…")
                                    .tag(dest.id)
                            }
                        }
                        .pickerStyle(.menu)
                        .font(.caption)
                    }
                    .padding(.vertical, 4)
                }

                Button(action: { node.choices.append(StoryChoice()) }) {
                    Label("Add Choice", systemImage: "plus.circle")
                }
            }
        }
        .navigationTitle("Edit Node")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    storyVM.updateNode(node)
                    dismiss()
                }
            }
        }
    }
}
