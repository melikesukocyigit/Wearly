import UIKit

final class ClothingDetailViewController: UIViewController {

    private let viewModel: ClothingDetailViewModel
    var onDelete: ((UUID) -> Void)?

    init(viewModel: ClothingDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .pageSheet
        title = "Details"
    }
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        setupSheet()
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Delete",
            style: .done,
            target: self,
            action: #selector(deleteTapped)
        )
        navigationItem.rightBarButtonItem?.tintColor = .systemRed
    }

    private func setupSheet() {
        if let sheet = sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }
    }

    private func setupUI() {
        let iv = UIImageView(image: viewModel.image)
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.layer.cornerRadius = 12
        iv.clipsToBounds = true

        let cat = makeRow(title: "Category", value: viewModel.categoryText)
        let season = makeRow(title: "Season", value: viewModel.seasonText)
        let colorRow = makeColorRow(hex: viewModel.colorHex, color: viewModel.color())

        let stack = UIStackView(arrangedSubviews: [iv, cat, season, colorRow])
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stack)
        NSLayoutConstraint.activate([
            iv.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),

            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }

    private func makeRow(title: String, value: String) -> UIStackView {
        let l1 = UILabel(); l1.text = title; l1.font = .systemFont(ofSize: 13, weight: .semibold)
        let l2 = UILabel(); l2.text = value; l2.font = .systemFont(ofSize: 15)
        let row = UIStackView(arrangedSubviews: [l1, l2])
        row.axis = .horizontal
        row.distribution = .equalSpacing
        return row
    }

    private func makeColorRow(hex: String, color: UIColor) -> UIStackView {
        let title = UILabel(); title.text = "Color"; title.font = .systemFont(ofSize: 13, weight: .semibold)
        let sw = UIView()
        sw.translatesAutoresizingMaskIntoConstraints = false
        sw.layer.cornerRadius = 10
        sw.clipsToBounds = true
        sw.backgroundColor = color
        sw.widthAnchor.constraint(equalToConstant: 20).isActive = true
        sw.heightAnchor.constraint(equalToConstant: 20).isActive = true

        let label = UILabel(); label.text = hex; label.font = .systemFont(ofSize: 15)

        let right = UIStackView(arrangedSubviews: [label, sw])
        right.axis = .horizontal
        right.spacing = 8
        let row = UIStackView(arrangedSubviews: [title, right])
        row.axis = .horizontal
        row.distribution = .equalSpacing
        return row
    }

    @objc private func deleteTapped() {
        let ac = UIAlertController(
            title: "Do you want to delete this item?",
            message: "Do you really want to delete this item?",
            preferredStyle: .alert
        )
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        ac.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
            guard let self else { return }
            self.onDelete?(self.viewModel.id)
            self.dismiss(animated: true)
        }))
        present(ac, animated: true)
    }
}


