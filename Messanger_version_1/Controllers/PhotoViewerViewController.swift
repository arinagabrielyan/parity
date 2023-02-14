//
//  PhotoViewerViewController.swift
//  Messanger_version_1
//
//  Created by Khachatur Sargsyan on 05.02.23.
//

import UIKit

class PhotoViewerViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    private var imageUrl: URL? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let imageUrl else { return }

        ImageDownloader.load(url: imageUrl) { image in
            self.imageView.image = image
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        view.backgroundColor = AppColors.blackAndWhite
    }

    func set(url: URL) {
        imageUrl = url
    }
}
