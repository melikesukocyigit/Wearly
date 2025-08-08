
import UIKit



class WardrobeViewController: UIViewController, UICollectionViewDelegate,UICollectionViewDataSource{
    
    private let viewModel = WardrobeViewModel()
    private var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemGroupedBackground
        title = "My Wardrobe"

        setupAddButton()
    

        let topsItems = viewModel.filteredItems

        for item in topsItems {
         print("Ürün: \(item.name), Kategori: \(item.category.rawValue), Sezon: \(item.season), Renk: \(item.color)")
            }
        setupCollectionView()

    }
    
    private func setupAddButton() {
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
        navigationItem.rightBarButtonItem = addButton
    }
  
    @objc private func addButtonTapped() {
        let addItemVC = AddClothingViewController()
        addItemVC.modalPresentationStyle = .pageSheet
        present(addItemVC,animated: true, completion: nil)
    }
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 150, height: 100)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ClothingCell.self, forCellWithReuseIdentifier: "ClothingCell")

        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.filteredItems.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ClothingCell", for: indexPath) as! ClothingCell
        let item = viewModel.filteredItems[indexPath.item]
        cell.configure(with: item)
         return cell
    }

}




