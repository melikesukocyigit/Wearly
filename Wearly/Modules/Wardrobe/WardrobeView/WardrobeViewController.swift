import UIKit

final class WardrobeViewController: UIViewController,
                                    UICollectionViewDelegate,
                                    UICollectionViewDataSource {

    private let viewModel: WardrobeViewModel
    private var collectionView: UICollectionView!

    private lazy var categoryTabs: UISegmentedControl = {
        let seg = UISegmentedControl(items: ["Tops", "Bottoms", "Shoes", "Accessories"])
        seg.selectedSegmentIndex = 0
        seg.addTarget(self, action: #selector(categoryChanged), for: .valueChanged)
        seg.translatesAutoresizingMaskIntoConstraints = false
        return seg
    }()

    init(viewModel: WardrobeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        title = "My Wardrobe"
    }
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground

        setupAddButton()
        setupCategoryTabs()
        setupCollectionView()

        bindViewModel()
        viewModel.loadFromDisk()
    }

    private func bindViewModel() {
        viewModel.onItemsChanged = { [weak self] _ in
            self?.collectionView.reloadData()
        }
        viewModel.onDataChanged = { [weak self] in
            self?.collectionView.reloadData()
        }
        viewModel.onError = { msg in print("VM Error:", msg) }
    }

    private func setupAddButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addButtonTapped)
        )
    }
    private func setupCategoryTabs() {
        view.addSubview(categoryTabs)
        NSLayoutConstraint.activate([
            categoryTabs.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            categoryTabs.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            categoryTabs.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
    }

    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 150, height: 150) 
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .white
        cv.delegate = self
        cv.dataSource = self
        cv.register(ClothingCell.self, forCellWithReuseIdentifier: "ClothingCell")
        collectionView = cv

        view.addSubview(cv)
        NSLayoutConstraint.activate([
            cv.topAnchor.constraint(equalTo: categoryTabs.bottomAnchor, constant: 8), 
            cv.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            cv.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            cv.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    @objc private func categoryChanged() {
        let map: [ClothingCategory] = [.tops, .bottoms, .shoes, .accessories]
        let idx = categoryTabs.selectedSegmentIndex
        guard map.indices.contains(idx) else { return }
        viewModel.updateCategory(to: map[idx])
    }

    @objc private func addButtonTapped() {
        let addVM = AddClothingViewModel()
        let addVC = AddClothingViewController(viewModel: addVM)
        addVC.onSave = { [weak self] image, name, category, season, colorHex in
            self?.viewModel.add(image: image, name: name, category: category, season: season, color: colorHex)
        }
        let nav = UINavigationController(rootViewController: addVC)
        nav.modalPresentationStyle = .pageSheet
        if let sheet = nav.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }
        present(nav, animated: true)
    }

    // MARK: - DataSource / Delegate
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.filteredItems.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "ClothingCell",
            for: indexPath
        ) as! ClothingCell
        cell.configure(with: viewModel.filteredItems[indexPath.item])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = viewModel.filteredItems[indexPath.item]
        let vm = ClothingDetailViewModel(item: item)
        let vc = ClothingDetailViewController(viewModel: vm)
        vc.onDelete = { [weak self] id in
            self?.viewModel.remove(itemID: id)
        }
        present(UINavigationController(rootViewController: vc), animated: true)
    }
}

