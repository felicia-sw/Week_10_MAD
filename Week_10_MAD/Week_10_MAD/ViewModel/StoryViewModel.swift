//
//  StoryViewModel.swift
//  Week_10_MAD
//
//  Created by Felicia Sword on 30/04/26.
//

import Foundation
import Combine
import FirebaseFirestore

// Constrain all published updates and Firestore callbacks to the main actor for UI safety
@MainActor
class StoryViewModel: ObservableObject {
    @Published var nodes: [StoryNode] = [] // Live, in-memory cache of all story nodes mirrored from Firestore
    private let db = Firestore.firestore() // Shared Firestore instance

    func fetchNodes() {
        // Attach a real-time listener so local state stays in sync with the backend.
        // addSnapshotListener delivers initial data and subsequent updates (adds/changes/deletes).
        // The listener closure may be invoked on a background queue; @MainActor ensures UI-safe assignment.
        db.collection("storyNodes").addSnapshotListener { [weak self] snapshot, _ in
            guard let documents = snapshot?.documents else { return } // If snapshot is nil (e.g., permission issues), do nothing
            self?.nodes = documents.compactMap { try? $0.data(as: StoryNode.self) } // Decode each document into StoryNode; silently drop malformed docs
        }
    }

    func addNode(_ node: StoryNode) {
        // setData(from:) encodes the model using Codable; using document(id) makes writes idempotent per node.id
        try? db.collection("storyNodes").document(node.id).setData(from: node) // Swallow errors for now; consider surfacing to UI/logging
    }

    func updateNode(_ node: StoryNode) {
        // Update is implemented as a full overwrite to keep schema consistent; partial updates could use updateData(_).
        try? db.collection("storyNodes").document(node.id).setData(from: node) // Same as add: id-based upsert
    }

    func deleteNode(_ node: StoryNode) {
        // Remove document; the snapshot listener will observe this and update local cache automatically
        db.collection("storyNodes").document(node.id).delete()
    }

    var storyTitles: [String] {
        // Unique, alphabetized list of story titles derived from current nodes
        Array(Set(nodes.map { $0.storyTitle })).sorted()
    }

    func entryNode(for title: String) -> StoryNode? {
        // Find the designated entry point node for a given story title
        nodes.first { $0.storyTitle == title && $0.isEntryPoint }
    }

    func node(byId id: String) -> StoryNode? {
        // Lookup helper to resolve StoryChoice.nextNodeId to a concrete node
        nodes.first { $0.id == id }
    }

    // MARK: - Seed helpers

    // These methods populate Firestore with sample stories. They are safe to call multiple times.
    // Only seeds if story doesn't already exist in Firestore
    private func seedIfNeeded(storyTitle: String, nodes: [StoryNode]) {
        // Only writes the provided nodes if we don't already have any node with the same storyTitle.
        // This is a coarse idempotency check at the view-model layer; it does not guard against partial seeds.
        let exists = self.nodes.contains { $0.storyTitle == storyTitle } // Checks current in-memory cache, which mirrors Firestore via listener
        guard !exists else { return } // Abort seeding if story already present
        nodes.forEach { addNode($0) } // Bulk upsert each node; snapshot listener will reflect results
    }

    func seedNinja() {
        // Define deterministic ids so choices can reference next nodes reliably across runs
        // Minimal branching narrative graph for demo purposes
        let id1 = "ninja-1"
        let id2 = "ninja-2"
        let id3 = "ninja-3"
        let id4 = "ninja-4"
        let id5 = "ninja-5"

        let newNodes: [StoryNode] = [
            StoryNode(
                id: id1,
                storyTitle: "Jalan Ninja",
                narrative: "Ian berlatih di hutan. Ujian ninja tinggal besok pagi. Ian merasa kurang menguasai chakra-nya.",
                choices: [
                    StoryChoice(id: "ninja-c1", label: "Meditasi Chakra",     nextNodeId: id2),
                    StoryChoice(id: "ninja-c2", label: "Latihan Fisik Keras", nextNodeId: id3)
                ],
                isEntryPoint: true
            ),
            StoryNode(
                id: id2,
                storyTitle: "Jalan Ninja",
                narrative: "Ian duduk bersila di tepi sungai. Nafasnya melambat. Chakra mulai mengalir dengan tenang. Ia merasa siap.",
                choices: [
                    StoryChoice(id: "ninja-c3", label: "Tidur lebih awal",      nextNodeId: id4),
                    StoryChoice(id: "ninja-c4", label: "Berlatih sampai fajar", nextNodeId: id5)
                ],
                isEntryPoint: false
            ),
            StoryNode(
                id: id3,
                storyTitle: "Jalan Ninja",
                narrative: "Ian berlari, melompat, dan berguling sepanjang malam. Tubuhnya lelah, tapi semangatnya membara.",
                choices: [
                    StoryChoice(id: "ninja-c5", label: "Istirahat sejenak", nextNodeId: id4),
                    StoryChoice(id: "ninja-c6", label: "Terus berlatih",    nextNodeId: id5)
                ],
                isEntryPoint: false
            ),
            StoryNode(
                id: id4,
                storyTitle: "Jalan Ninja",
                narrative: "Ian beristirahat dengan cukup. Keesokan harinya ia mengikuti ujian dengan pikiran segar dan lulus dengan nilai sempurna.",
                choices: [],
                isEntryPoint: false
            ),
            StoryNode(
                id: id5,
                storyTitle: "Jalan Ninja",
                narrative: "Ian terlalu lelah saat ujian dimulai. Ia gagal dalam tes kecepatan, namun berjanji untuk mencoba lagi musim depan.",
                choices: [],
                isEntryPoint: false
            )
        ]
        seedIfNeeded(storyTitle: "Jalan Ninja", nodes: newNodes) // Write only if not already present
    }

    func seedRomance() {
        // Define deterministic ids so choices can reference next nodes reliably across runs
        // Minimal branching narrative graph for demo purposes
        let id1 = "sakura-1"
        let id2 = "sakura-2"
        let id3 = "sakura-3"
        let id4 = "sakura-4"

        let newNodes: [StoryNode] = [
            StoryNode(
                id: id1,
                storyTitle: "Sakura Terakhir",
                narrative: "Gavin berdiri di bawah pohon sakura. Musim semi hampir berakhir. Seorang gadis bernama Hana berjalan melewatinya.",
                choices: [
                    StoryChoice(id: "sakura-c1", label: "Sapa Hana duluan",    nextNodeId: id2),
                    StoryChoice(id: "sakura-c2", label: "Diam saja dan pergi", nextNodeId: id3)
                ],
                isEntryPoint: true
            ),
            StoryNode(
                id: id2,
                storyTitle: "Sakura Terakhir",
                narrative: "Hai, kata Gavin gemetar. Hana tersenyum dan berhenti. Mereka mengobrol hingga kelopak sakura terakhir jatuh.",
                choices: [
                    StoryChoice(id: "sakura-c3", label: "Minta nomor telepon Hana", nextNodeId: id4),
                    StoryChoice(id: "sakura-c4", label: "Berpisah dan pulang",       nextNodeId: id3)
                ],
                isEntryPoint: false
            ),
            StoryNode(
                id: id3,
                storyTitle: "Sakura Terakhir",
                narrative: "Gavin pulang dengan tangan kosong. Ia berjanji pada dirinya sendiri untuk lebih berani di musim semi berikutnya.",
                choices: [],
                isEntryPoint: false
            ),
            StoryNode(
                id: id4,
                storyTitle: "Sakura Terakhir",
                narrative: "Hana memberikan nomornya sambil tersenyum malu. Hubungi aku, bisiknya. Sebuah cerita cinta baru dimulai.",
                choices: [],
                isEntryPoint: false
            )
        ]
        seedIfNeeded(storyTitle: "Sakura Terakhir", nodes: newNodes) // Write only if not already present
    }

    func seedPirate() {
        // Define deterministic ids so choices can reference next nodes reliably across runs
        // Minimal branching narrative graph for demo purposes
        let id1 = "pirate-1"
        let id2 = "pirate-2"
        let id3 = "pirate-3"
        let id4 = "pirate-4"
        let id5 = "pirate-5"

        let newNodes: [StoryNode] = [
            StoryNode(
                id: id1,
                storyTitle: "Tekad Sang Kapten",
                narrative: "Dylan berdiri di atas dek kapalnya. Peta harta karun ada di tangannya. Badai mendekat dari barat.",
                choices: [
                    StoryChoice(id: "pirate-c1", label: "Terobos badai",       nextNodeId: id2),
                    StoryChoice(id: "pirate-c2", label: "Berlabuh dan tunggu", nextNodeId: id3)
                ],
                isEntryPoint: true
            ),
            StoryNode(
                id: id2,
                storyTitle: "Tekad Sang Kapten",
                narrative: "Kapal berderak keras dihantam gelombang. Tapi Dylan berhasil melewatinya dan menemukan pulau yang tertera di peta.",
                choices: [
                    StoryChoice(id: "pirate-c3", label: "Gali harta sendirian",       nextNodeId: id4),
                    StoryChoice(id: "pirate-c4", label: "Panggil seluruh awak kapal", nextNodeId: id5)
                ],
                isEntryPoint: false
            ),
            StoryNode(
                id: id3,
                storyTitle: "Tekad Sang Kapten",
                narrative: "Dylan menunggu badai berlalu. Tapi saat ia tiba di pulau, bajak laut lain sudah lebih dulu menggali harta itu.",
                choices: [],
                isEntryPoint: false
            ),
            StoryNode(
                id: id4,
                storyTitle: "Tekad Sang Kapten",
                narrative: "Dylan menggali sendirian semalam suntuk. Ia menemukan peti emas yang penuh. Kekayaan itu sepenuhnya miliknya.",
                choices: [],
                isEntryPoint: false
            ),
            StoryNode(
                id: id5,
                storyTitle: "Tekad Sang Kapten",
                narrative: "Bersama awak kapalnya, Dylan merayakan penemuan harta karun terbesar di lautan selatan. Sebuah legenda lahir.",
                choices: [],
                isEntryPoint: false
            )
        ]
        seedIfNeeded(storyTitle: "Tekad Sang Kapten", nodes: newNodes) // Write only if not already present
    }
}

