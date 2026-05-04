//
//  StoryNode.swift
//  Week_10_MAD
//
//  Created by Felicia Sword on 30/04/26.
//

import Foundation

struct StoryChoice: Identifiable, Codable {
    var id: String
    var label: String
    var nextNodeId: String

    // Provide defaults so you can still write StoryChoice() or StoryChoice(label:nextNodeId:)
    init(id: String = UUID().uuidString, label: String = "", nextNodeId: String = "") {
        self.id = id
        self.label = label
        self.nextNodeId = nextNodeId
    }
}

struct StoryNode: Identifiable, Codable {
    var id: String
    var storyTitle: String
    var narrative: String
    var choices: [StoryChoice]
    var isEntryPoint: Bool

    init(
        id: String = UUID().uuidString,
        storyTitle: String = "",
        narrative: String = "",
        choices: [StoryChoice] = [],
        isEntryPoint: Bool = false
    ) {
        self.id = id
        self.storyTitle = storyTitle
        self.narrative = narrative
        self.choices = choices
        self.isEntryPoint = isEntryPoint
    }
}
