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
}
