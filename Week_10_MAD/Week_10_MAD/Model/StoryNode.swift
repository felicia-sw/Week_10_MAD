//
//  StoryNode.swift
//  Week_10_MAD
//
//  Created by Felicia Sword on 30/04/26.
//

import Foundation

struct StoryChoice: Identifiable, Codable {
    var id: String = UUID().uuidString
    var label: String = ""        // The button text e.g. "Meditasi Chakra"
    var nextNodeId: String = ""   // Which node to go to next
}

struct StoryNode: Identifiable, Codable {
    var id: String = UUID().uuidString
    var storyTitle: String = ""       // Which story this belongs to
    var narrative: String = ""        // The story text shown to the player
    var choices: [StoryChoice] = []   // The choice buttons
    var isEntryPoint: Bool = false    // Is this the first node of the story?
}
