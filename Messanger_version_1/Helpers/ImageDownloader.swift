//
//  ImageDownloader.swift
//  Messanger_version_1
//
//  Created by Khachatur Sargsyan on 24.01.23.
//

import Foundation
import UIKit

class ImageDownloader {
    static func load(url: URL, completion: @escaping ((UIImage?) -> Void)) {
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        completion(image)
                    }
                }
            } else {
                completion(nil)
            }
        }
    }

    static func downloadProfileImage() {
        guard let url = LocaleStorageManager.shared.profileImageUrl, !url.isEmpty else { return }

        DispatchQueue.global(qos: .background).async {
            ImageDownloader.load(url: URL(string: url)!) { image in
                guard let image else { return }

                LocaleStorageManager.shared.profileImage = image.pngData()
            }
        }
    }
}
