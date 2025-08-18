//
//  CombinationsViewController.swift
//  OOtdays
//
//  Created by Melike Su KOÇYİĞİT on 6.08.2025.
//

import UIKit

final class CombinationsViewController: UIViewController {
    var wardrobeProvider: (() -> [ClothingItem])!

    private var viewModel: CombinationsViewModel!

    // UI
    private let topImageView = UIImageView()
    private let bottomImageView = UIImageView()
    private let shoesImageView = UIImageView()
    private let scoreLabel = UILabel()
    private let emptyLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        title = "Combinations"

        configureUI()
        configureViewModel()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let allItems = wardrobeProvider()
        FeatureExtractor.shared.warmCache(items: allItems)

        loadSuggestions()
    }

    // MARK: - Setup
    private func configureViewModel() {
        precondition(wardrobeProvider != nil, "wardrobeProvider set edilmedi")

        viewModel = CombinationsViewModel(
            wardrobeProvider: wardrobeProvider,
            weights: Weights(style: 0.6, color: 0.3, season: 0.1),
            strictSeason: true
        )
        viewModel.topK = 10
    }

    private func configureUI() {
        [topImageView, bottomImageView, shoesImageView].forEach {
            $0.contentMode = .scaleAspectFit
            $0.clipsToBounds = true
            $0.backgroundColor = .secondarySystemGroupedBackground
            $0.layer.cornerRadius = 12
            $0.heightAnchor.constraint(equalToConstant: 140).isActive = true
        }

        scoreLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        scoreLabel.textAlignment = .center
        scoreLabel.textColor = .label

        emptyLabel.text = "Kombin bulunamadı.\nLütfen filtreleri gevşetmeyi deneyin."
        emptyLabel.textAlignment = .center
        emptyLabel.textColor = .secondaryLabel
        emptyLabel.numberOfLines = 0
        emptyLabel.isHidden = true

        let stack = UIStackView(arrangedSubviews: [
            topImageView, bottomImageView, shoesImageView, scoreLabel, emptyLabel
        ])
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16)
        ])
    }

    private func loadSuggestions() {
        let suggestions = viewModel.suggest()
        guard let best = suggestions.first else {
            showEmptyState(true)
            return
        }
        render(suggestion: best)
    }

    private func render(suggestion: CombinationSuggestion) {
        showEmptyState(false)
        topImageView.image = suggestion.top.image
        bottomImageView.image = suggestion.bottom.image
        shoesImageView.image = suggestion.shoes.image
        let pct = Int((suggestion.score * 100).rounded())
        scoreLabel.text = "Skor: \(pct)%"
    }

    private func showEmptyState(_ show: Bool) {
        emptyLabel.isHidden = !show
        topImageView.isHidden = show
        bottomImageView.isHidden = show
        shoesImageView.isHidden = show
        scoreLabel.isHidden = show
    }
}

