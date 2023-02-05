//
//  Sender.swift
//  Messanger_version_1
//
//  Created by Khachatur Sargsyan on 13.01.23.
//

import MessageKit
import UIKit

public struct Sender: SenderType {
   public var senderId: String
   public var displayName: String
}

public struct Media: MediaItem {
    public var url: URL?
    public var image: UIImage?
    public var placeholderImage: UIImage
    public var size: CGSize
}
