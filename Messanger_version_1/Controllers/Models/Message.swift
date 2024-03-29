//
//  Message.swift
//  Messanger_version_1
//
//  Created by Khachatur Sargsyan on 13.01.23.
//

import MessageKit
import Foundation

struct Message: MessageType {
   public var sender: MessageKit.SenderType
   public var messageId: String
   public var sentDate: Date
   public var kind: MessageKit.MessageKind
}

extension MessageKind {
    var description: String {
        switch self {
            case .text(_):
                return "text"
            case .attributedText(_):
                return "attributedText"
            case .photo(_):
                return "photo"
            case .video(_):
                return "video"
            case .location(_):
                return "location"
            case .emoji(_):
                return "emoji"
            case .audio(_):
                return "audio"
            case .contact(_):
                return "contact"
            case .linkPreview(_):
                return "linkPreview"
            case .custom(_):
                return "custom"
        }
    }
}
