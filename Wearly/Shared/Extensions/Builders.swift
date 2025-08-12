//
//  Builders.swift
//  Wearly
//
//  Created by Melike Su KOÇYİĞİT on 12.08.2025.
//

import UIKit

// MARK: - UIImageView
extension UIImageView {
    static func buildRounded(background: UIColor? = nil,
                             contentMode: UIView.ContentMode = .scaleAspectFit,
                             cornerRadius: CGFloat = 12) -> UIImageView {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = contentMode
        iv.layer.cornerRadius = cornerRadius
        iv.clipsToBounds = true
        if let bg = background { iv.backgroundColor = bg }
        return iv
    }
}

// MARK: - UITextField
extension UITextField {
    static func buildRounded(placeholder: String? = nil) -> UITextField {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.placeholder = placeholder
        tf.borderStyle = .roundedRect
        return tf
    }
}

// MARK: - UILabel
extension UILabel {
    static func buildCenter(text: String? = nil) -> UILabel {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.text = text
        lb.textAlignment = .center
        lb.numberOfLines = 1
        return lb
    }

    static func buildBold(text: String? = nil, size: CGFloat = 15) -> UILabel {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.text = text
        lb.font = .systemFont(ofSize: size, weight: .semibold)
        return lb
    }

    static func buildSecondary(text: String? = nil, size: CGFloat = 13) -> UILabel {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.text = text
        lb.font = .systemFont(ofSize: size)
        lb.textColor = .secondaryLabel
        return lb
    }
}

// MARK: - UIView
extension UIView {
    static func buildCircle(cornerRadius: CGFloat = 10, background: UIColor = .systemGray3) -> UIView {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.layer.cornerRadius = cornerRadius
        v.clipsToBounds = true
        v.backgroundColor = background
        return v
    }
}

// MARK: - UIButton
extension UIButton {
    static func buildFilled(title: String) -> UIButton {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle(title, for: .normal)
        b.heightAnchor.constraint(equalToConstant: 44).isActive = true
        return b
    }

    static func buildDisabled(title: String) -> UIButton {
        let b = buildFilled(title: title)
        b.isEnabled = false
        b.alpha = 0.5
        return b
    }

    static func buildColorSwatch(hex: String, tag: Int, size: CGFloat = 40) -> UIButton {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.widthAnchor.constraint(equalToConstant: size).isActive = true
        b.heightAnchor.constraint(equalToConstant: size).isActive = true
        b.layer.cornerRadius = size / 2
        b.clipsToBounds = true
        b.layer.borderWidth = 2
        b.layer.borderColor = (hex.uppercased() == "#FFFFFF") ? UIColor.lightGray.cgColor : UIColor.clear.cgColor
        b.tag = tag
        return b
    }
}
