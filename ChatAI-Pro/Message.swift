import Foundation

struct Message: Identifiable, Equatable {
    let id = UUID()
    var text: String
    let isUser: Bool
}
//
//  Message.swift
//  ChatAI-Pro
//
//  Created by Pranjal on 11/07/25.
//

