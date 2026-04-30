//
//  StoryViewModel.swift
//  Week_10_MAD
//
//  Created by Felicia Sword on 30/04/26.
//
import Foundation
import Combine
import FirebaseFirestore

class StoryViewModel: ObservableObject {
    @Published var nodes: [StoryNode] = []
    private let db = Firestore.firestore()

    func fetchNodes() {
        db.collection("storyNodes").addSnapshotListener { snapshot, _ in
            guard let documents = snapshot?.documents else { return }
            self.nodes = documents.compactMap { try? $0.data(as: StoryNode.self) }
        }
    }

    func addNode(_ node: StoryNode) {
        try? db.collection("storyNodes").document(node.id).setData(from: node)
    }

    func updateNode(_ node: StoryNode) {
        try? db.collection("storyNodes").document(node.id).setData(from: node)
    }

    func deleteNode(_ node: StoryNode) {
        db.collection("storyNodes").document(node.id).delete()
    }

    var storyTitles: [String] {
        Array(Set(nodes.map { $0.storyTitle })).sorted()
    }

    func entryNode(for title: String) -> StoryNode? {
        nodes.first { $0.storyTitle == title && $0.isEntryPoint }
    }

    func node(byId id: String) -> StoryNode? {
        nodes.first { $0.id == id }
    }

    func seedNinja() {
        let node1 = StoryNode(id: UUID().uuidString, storyTitle: "Jalan Ninja", narrative: "Ian berlatih di hutan. Ujian ninja tinggal besok pagi. Ian merasa kurang menguasai chakra-nya.", choices: [], isEntryPoint: true)
        addNode(node1)
    }

    func seedRomance() {
        let node1 = StoryNode(id: UUID().uuidString, storyTitle: "Sakura Terakhir", narrative: "Gavin berdiri di bawah pohon sakura. Musim semi hampir berakhir.", choices: [], isEntryPoint: true)
        addNode(node1)
    }

    func seedPirate() {
        let node1 = StoryNode(id: UUID().uuidString, storyTitle: "Tekad Sang Kapten", narrative: "Dylan berdiri di atas dek kapalnya. Peta harta karun ada di tangannya.", choices: [], isEntryPoint: true)
        addNode(node1)
    }
}
