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
                                VStack(alignment: .leading) {
                                    if node.isEntryPoint {
                                        Text("Entry Point")
                                            .font(.caption)
                                            .foregroundColor(.blue)
                                    }
                                    Text(node.narrative)
                                        .lineLimit(2)
                                        .font(.subheadline)
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
                    TextField("Story title", text: $storyTitle)
                    Toggle("Main Entry Point", isOn: $isEntryPoint)
                }
                Section("Narrative") {
                    TextEditor(text: $narrative)
                        .frame(height: 120)
                }
                Section("Choices") {
                    ForEach($choices) { $choice in
                        VStack {
                            TextField("Choice label", text: $choice.label)
                            TextField("Next node ID", text: $choice.nextNodeId)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    Button("Add Choice") {
                        choices.append(StoryChoice())
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
                        let node = StoryNode(id: UUID().uuidString, storyTitle: storyTitle, narrative: narrative, choices: choices, isEntryPoint: isEntryPoint)
                        storyVM.addNode(node)
                        dismiss()
                    }
                    .disabled(storyTitle.isEmpty || narrative.isEmpty)
                }
            }
        }
    }
}

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
                ForEach($node.choices) { $choice in
                    VStack {
                        TextField("Choice label", text: $choice.label)
                        TextField("Next node ID", text: $choice.nextNodeId)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                Button("Add Choice") {
                    node.choices.append(StoryChoice())
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
