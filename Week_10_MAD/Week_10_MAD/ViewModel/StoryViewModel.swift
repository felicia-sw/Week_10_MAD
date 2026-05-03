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

    // MARK: - Seed Data with proper branching

    func seedNinja() {
        // Build IDs first so we can cross-reference choices
        let id1 = UUID().uuidString
        let id2 = UUID().uuidString
        let id3 = UUID().uuidString
        let id4 = UUID().uuidString
        let id5 = UUID().uuidString

        let node1 = StoryNode(
            id: id1,
            storyTitle: "Jalan Ninja",
            narrative: "Ian berlatih di hutan. Ujian ninja tinggal besok pagi. Ian merasa kurang menguasai chakra-nya.",
            choices: [
                StoryChoice(label: "Meditasi Chakra", nextNodeId: id2),
                StoryChoice(label: "Latihan Fisik Keras", nextNodeId: id3)
            ],
            isEntryPoint: true
        )

        let node2 = StoryNode(
            id: id2,
            storyTitle: "Jalan Ninja",
            narrative: "Ian duduk bersila di tepi sungai. Nafasnya melambat. Chakra mulai mengalir dengan tenang. Ia merasa siap.",
            choices: [
                StoryChoice(label: "Tidur lebih awal", nextNodeId: id4),
                StoryChoice(label: "Berlatih sampai fajar", nextNodeId: id5)
            ],
            isEntryPoint: false
        )

        let node3 = StoryNode(
            id: id3,
            storyTitle: "Jalan Ninja",
            narrative: "Ian berlari, melompat, dan berguling sepanjang malam. Tubuhnya lelah, tapi semangatnya membara.",
            choices: [
                StoryChoice(label: "Istirahat sejenak", nextNodeId: id4),
                StoryChoice(label: "Terus berlatih", nextNodeId: id5)
            ],
            isEntryPoint: false
        )

        let node4 = StoryNode(
            id: id4,
            storyTitle: "Jalan Ninja",
            narrative: "Ian beristirahat dengan cukup. Keesokan harinya ia mengikuti ujian dengan pikiran segar dan lulus dengan nilai sempurna.",
            choices: [],
            isEntryPoint: false
        )

        let node5 = StoryNode(
            id: id5,
            storyTitle: "Jalan Ninja",
            narrative: "Ian terlalu lelah saat ujian dimulai. Ia gagal dalam tes kecepatan, namun berjanji untuk mencoba lagi musim depan.",
            choices: [],
            isEntryPoint: false
        )

        [node1, node2, node3, node4, node5].forEach { addNode($0) }
    }

    func seedRomance() {
        let id1 = UUID().uuidString
        let id2 = UUID().uuidString
        let id3 = UUID().uuidString
        let id4 = UUID().uuidString

        let node1 = StoryNode(
            id: id1,
            storyTitle: "Sakura Terakhir",
            narrative: "Gavin berdiri di bawah pohon sakura. Musim semi hampir berakhir. Seorang gadis bernama Hana berjalan melewatinya.",
            choices: [
                StoryChoice(label: "Sapa Hana duluan", nextNodeId: id2),
                StoryChoice(label: "Diam saja dan pergi", nextNodeId: id3)
            ],
            isEntryPoint: true
        )

        let node2 = StoryNode(
            id: id2,
            storyTitle: "Sakura Terakhir",
            narrative: "\"Hai,\" kata Gavin gemetar. Hana tersenyum dan berhenti. Mereka mengobrol hingga kelopak sakura terakhir jatuh.",
            choices: [
                StoryChoice(label: "Minta nomor telepon Hana", nextNodeId: id4),
                StoryChoice(label: "Berpisah dan pulang", nextNodeId: id3)
            ],
            isEntryPoint: false
        )

        let node3 = StoryNode(
            id: id3,
            storyTitle: "Sakura Terakhir",
            narrative: "Gavin pulang dengan tangan kosong. Ia berjanji pada dirinya sendiri untuk lebih berani di musim semi berikutnya.",
            choices: [],
            isEntryPoint: false
        )

        let node4 = StoryNode(
            id: id4,
            storyTitle: "Sakura Terakhir",
            narrative: "Hana memberikan nomornya sambil tersenyum malu. \"Hubungi aku,\" bisiknya. Sebuah cerita cinta baru dimulai.",
            choices: [],
            isEntryPoint: false
        )

        [node1, node2, node3, node4].forEach { addNode($0) }
    }

    func seedPirate() {
        let id1 = UUID().uuidString
        let id2 = UUID().uuidString
        let id3 = UUID().uuidString
        let id4 = UUID().uuidString
        let id5 = UUID().uuidString

        let node1 = StoryNode(
            id: id1,
            storyTitle: "Tekad Sang Kapten",
            narrative: "Dylan berdiri di atas dek kapalnya. Peta harta karun ada di tangannya. Badai mendekat dari barat.",
            choices: [
                StoryChoice(label: "Terobos badai", nextNodeId: id2),
                StoryChoice(label: "Berlabuh dan tunggu", nextNodeId: id3)
            ],
            isEntryPoint: true
        )

        let node2 = StoryNode(
            id: id2,
            storyTitle: "Tekad Sang Kapten",
            narrative: "Kapal berderak keras dihantam gelombang. Tapi Dylan berhasil melewatinya dan menemukan pulau yang tertera di peta.",
            choices: [
                StoryChoice(label: "Gali harta sendirian", nextNodeId: id4),
                StoryChoice(label: "Panggil seluruh awak kapal", nextNodeId: id5)
            ],
            isEntryPoint: false
        )

        let node3 = StoryNode(
            id: id3,
            storyTitle: "Tekad Sang Kapten",
            narrative: "Dylan menunggu badai berlalu. Tapi saat ia tiba di pulau, bajak laut lain sudah lebih dulu menggali harta itu.",
            choices: [],
            isEntryPoint: false
        )

        let node4 = StoryNode(
            id: id4,
            storyTitle: "Tekad Sang Kapten",
            narrative: "Dylan menggali sendirian semalam suntuk. Ia menemukan peti emas yang penuh. Kekayaan itu sepenuhnya miliknya.",
            choices: [],
            isEntryPoint: false
        )

        let node5 = StoryNode(
            id: id5,
            storyTitle: "Tekad Sang Kapten",
            narrative: "Bersama awak kapalnya, Dylan merayakan penemuan harta karun terbesar di lautan selatan. Sebuah legenda lahir.",
            choices: [],
            isEntryPoint: false
        )

        [node1, node2, node3, node4, node5].forEach { addNode($0) }
    }
}
