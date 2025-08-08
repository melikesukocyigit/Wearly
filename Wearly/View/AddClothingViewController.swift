//
//  AddClothingViewController.swift
//  OOtdays
//
//  Created by Melike Su KOÇYİĞİT on 7.08.2025.
//

import UIKit
import VisionKit

class AddClothingViewController: UIViewController, VNDocumentCameraViewControllerDelegate {
    
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.backgroundColor = .systemGray5
        iv.layer.cornerRadius = 12
        iv.clipsToBounds = true
        return iv
    }()

    private let photoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Fotoğraf Ekle", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray6

        setupHeader()
        view.addSubview(imageView)
        view.addSubview(photoButton)

        photoButton.addTarget(self, action: #selector(openDocumentCamera), for: .touchUpInside)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 200),
            imageView.heightAnchor.constraint(equalToConstant: 200),

            photoButton.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            photoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    private func setupHeader() {
        let closeButton = UIButton(type: .system)
        closeButton.setTitle("✕", for: .normal)
        closeButton.setTitleColor(.black, for: .normal)
        closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)

        let titleLabel = UILabel()
        titleLabel.text = "Add Item"
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = .black
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(closeButton)
        view.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),

            titleLabel.centerYAnchor.constraint(equalTo: closeButton.centerYAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    @objc private func closeTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    // 📷 VisionKit Kamera Açma
    @objc private func openDocumentCamera() {
        let scannerVC = VNDocumentCameraViewController()
        scannerVC.delegate = self
        present(scannerVC, animated: true)
    }
    
    // 📄 Tarama tamamlandığında
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        if scan.pageCount > 0 {
            let scannedImage = scan.imageOfPage(at: 0)
            imageView.image = scannedImage
            // Burada ML Kit'e gönderebiliriz
        }
        controller.dismiss(animated: true)
    }
    
    // ❌ İptal edilirse
    func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
        controller.dismiss(animated: true)
    }
    
    // ⚠️ Hata olursa
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
        print("❌ Tarama hatası: \(error.localizedDescription)")
        controller.dismiss(animated: true)
    }
}



