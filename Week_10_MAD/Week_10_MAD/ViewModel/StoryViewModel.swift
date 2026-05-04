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
        db.collection("storyNodes").addSnapshotListener { [weak self] snapshot, _ in
            guard let documents = snapshot?.documents else { return }
            self?.nodes = documents.compactMap { try? $0.data(as: StoryNode.self) }
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

    // MARK: - Seed helpers

    // Only seeds if story doesn't already exist in Firestore
    private func seedIfNeeded(storyTitle: String, nodes: [StoryNode]) {
        let exists = self.nodes.contains { $0.storyTitle == storyTitle }
        guard !exists else { return }
        nodes.forEach { addNode($0) }
    }

    func seedNinja() {
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
        seedIfNeeded(storyTitle: "Jalan Ninja", nodes: newNodes)
    }

    func seedRomance() {
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
        seedIfNeeded(storyTitle: "Sakura Terakhir", nodes: newNodes)
    }

    func seedPirate() {
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
        seedIfNeeded(storyTitle: "Tekad Sang Kapten", nodes: newNodes)
    }
}
