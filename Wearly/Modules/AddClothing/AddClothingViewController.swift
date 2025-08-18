import UIKit
import VisionKit

final class AddClothingViewController: UIViewController, VNDocumentCameraViewControllerDelegate {

    private let viewModel: AddClothingViewModel
    init(viewModel: AddClothingViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        title = "Add Item"
    }
    @available(*, unavailable) // required init kullanılmadan önce kullanılır
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    var onSave: ((UIImage, String, ClothingCategory, String, String) -> Void)?

    private let imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.backgroundColor = .systemGray5
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let nameField = AddClothingViewController.makeTextField(placeholder: "Name")
    private let categoryField = AddClothingViewController.makeTextField(placeholder: "Category")
    private let seasonField = AddClothingViewController.makeTextField(placeholder: "Season")

    private let resultLabel: UILabel = {
        let l = UILabel()
        l.text = "Predicted:"
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let colorTitle: UILabel = {
        let l = UILabel()
        l.text = "Color"
        l.font = .systemFont(ofSize: 15, weight: .semibold)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    private let colorPreview: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 10
        v.clipsToBounds = true
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .systemGray3
        return v
    }()
    private let colorHexLabel: UILabel = {
        let l = UILabel()
        l.text = "#"
        l.textColor = .secondaryLabel
        l.font = .systemFont(ofSize: 13)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let colorScroll = UIScrollView()
    private let colorStack = UIStackView()
    private var colorButtons: [UIButton] = []

    private let scanButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Scan / Camera", for: .normal)
        b.heightAnchor.constraint(equalToConstant: 44).isActive = true
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    private let saveButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Save", for: .normal)
        b.heightAnchor.constraint(equalToConstant: 44).isActive = true
        b.isEnabled = false
        b.alpha = 0.5
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    private let categoryPicker = UIPickerView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupHeader()
        setupLayout()
        setupPickers()
        setupColorPalette()
        bindViewModel()

        scanButton.addTarget(self, action: #selector(openScanner), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
    }

    private func setupHeader() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(closeTapped)
        )
    }
    @objc private func closeTapped() { dismiss(animated: true) }

    private func setupLayout() {
        [imageView, nameField, categoryField, seasonField,
         resultLabel, colorTitle, colorPreview, colorHexLabel,
         colorScroll, scanButton, saveButton].forEach { view.addSubview($0) }

        colorScroll.translatesAutoresizingMaskIntoConstraints = false
        colorScroll.showsHorizontalScrollIndicator = false

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),

            nameField.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 12),
            nameField.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            nameField.trailingAnchor.constraint(equalTo: imageView.trailingAnchor),

            categoryField.topAnchor.constraint(equalTo: nameField.bottomAnchor, constant: 8),
            categoryField.leadingAnchor.constraint(equalTo: nameField.leadingAnchor),
            categoryField.trailingAnchor.constraint(equalTo: nameField.trailingAnchor),

            seasonField.topAnchor.constraint(equalTo: categoryField.bottomAnchor, constant: 8),
            seasonField.leadingAnchor.constraint(equalTo: nameField.leadingAnchor),
            seasonField.trailingAnchor.constraint(equalTo: nameField.trailingAnchor),

            resultLabel.topAnchor.constraint(equalTo: seasonField.bottomAnchor, constant: 8),
            resultLabel.leadingAnchor.constraint(equalTo: nameField.leadingAnchor),
            resultLabel.trailingAnchor.constraint(equalTo: nameField.trailingAnchor),

            colorTitle.topAnchor.constraint(equalTo: resultLabel.bottomAnchor, constant: 12),
            colorTitle.leadingAnchor.constraint(equalTo: nameField.leadingAnchor),

            colorPreview.centerYAnchor.constraint(equalTo: colorTitle.centerYAnchor),
            colorPreview.trailingAnchor.constraint(equalTo: nameField.trailingAnchor),
            colorPreview.widthAnchor.constraint(equalToConstant: 20),
            colorPreview.heightAnchor.constraint(equalToConstant: 20),

            colorHexLabel.centerYAnchor.constraint(equalTo: colorTitle.centerYAnchor),
            colorHexLabel.trailingAnchor.constraint(equalTo: colorPreview.leadingAnchor, constant: -8),

            colorScroll.topAnchor.constraint(equalTo: colorTitle.bottomAnchor, constant: 8),
            colorScroll.leadingAnchor.constraint(equalTo: nameField.leadingAnchor),
            colorScroll.trailingAnchor.constraint(equalTo: nameField.trailingAnchor),
            colorScroll.heightAnchor.constraint(equalToConstant: 40),

            scanButton.topAnchor.constraint(equalTo: colorScroll.bottomAnchor, constant: 12),
            scanButton.leadingAnchor.constraint(equalTo: nameField.leadingAnchor),
            scanButton.trailingAnchor.constraint(equalTo: nameField.trailingAnchor),

            saveButton.topAnchor.constraint(equalTo: scanButton.bottomAnchor, constant: 8),
            saveButton.leadingAnchor.constraint(equalTo: nameField.leadingAnchor),
            saveButton.trailingAnchor.constraint(equalTo: nameField.trailingAnchor),
        ])
    }

    private func setupPickers() {
        categoryPicker.dataSource = self
        categoryPicker.delegate = self
        categoryPicker.tag = 0
        categoryField.inputView = categoryPicker

        let seasonPicker = UIPickerView()
        seasonPicker.dataSource = self
        seasonPicker.delegate = self
        seasonPicker.tag = 1
        seasonField.inputView = seasonPicker

        [categoryField, seasonField].forEach {
            let tb = UIToolbar()
            tb.sizeToFit()
            tb.items = [UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(endEditingNow))]
            $0.inputAccessoryView = tb
        }
    }
    @objc private func endEditingNow() { view.endEditing(true) }

    private func setupColorPalette() {
        colorStack.axis = .horizontal
        colorStack.alignment = .center
        colorStack.spacing = 12
        colorStack.translatesAutoresizingMaskIntoConstraints = false
        colorScroll.addSubview(colorStack)

        colorButtons = viewModel.staticColors.enumerated().map { idx, hex in
            let b = UIButton(type: .system)
            b.translatesAutoresizingMaskIntoConstraints = false
            b.widthAnchor.constraint(equalToConstant: 40).isActive = true
            b.heightAnchor.constraint(equalToConstant: 40).isActive = true
            b.layer.cornerRadius = 20
            b.clipsToBounds = true
            b.layer.borderWidth = 2
            b.layer.borderColor = (hex.uppercased() == "#FFFFFF") ? UIColor.lightGray.cgColor : UIColor.clear.cgColor
            b.backgroundColor = viewModel.uiColor(from: hex) ?? .systemGray4
            b.tag = idx
            b.addTarget(self, action: #selector(colorSelected(_:)), for: .touchUpInside)
            return b
        }
        colorButtons.forEach { colorStack.addArrangedSubview($0) }

        NSLayoutConstraint.activate([
            colorStack.topAnchor.constraint(equalTo: colorScroll.topAnchor),
            colorStack.bottomAnchor.constraint(equalTo: colorScroll.bottomAnchor),
            colorStack.leadingAnchor.constraint(equalTo: colorScroll.leadingAnchor),
            colorStack.trailingAnchor.constraint(equalTo: colorScroll.trailingAnchor),
            colorStack.heightAnchor.constraint(equalTo: colorScroll.heightAnchor)
        ])
    }

    private func bindViewModel() {
        viewModel.onImageUpdate = { [weak self] img in
            self?.imageView.image = img
        }
        viewModel.onPredictionUpdate = { [weak self] category in
            self?.resultLabel.text = "Predicted: \(category.rawValue)"
            self?.categoryField.text = category.rawValue
        }
        viewModel.onColorUpdate = { [weak self] hex, color in
            self?.colorPreview.backgroundColor = color
            self?.colorHexLabel.text = hex
            self?.refreshSwatchSelectionUI()
        }
        viewModel.onSaveEnabled = { [weak self] enabled in
            self?.saveButton.isEnabled = enabled
            self?.saveButton.alpha = enabled ? 1.0 : 0.5
        }
    }

    @objc private func openScanner() {
        let scanner = VNDocumentCameraViewController()
        scanner.delegate = self
        present(scanner, animated: true)
    }

    func documentCameraViewController(_ controller: VNDocumentCameraViewController,
                                      didFinishWith scan: VNDocumentCameraScan) {
        defer { controller.dismiss(animated: true) }
        guard scan.pageCount > 0 else { return }
        let img = scan.imageOfPage(at: 0)
        viewModel.setImage(img)
        _ = viewModel.autoPickNearestColorForCurrentImage()
        refreshSwatchSelectionUI()
        // kategori tahmini yoksa en azından picker textini dolduralım
        categoryField.text = viewModel.selectedCategory.rawValue
        saveButton.isEnabled = true
        saveButton.alpha = 1.0
    }
    @objc private func saveTapped() {
        if let payload = viewModel.buildPayload(name: nameField.text) {
            onSave?(payload.image, payload.name, payload.category, payload.season, payload.colorHex)
            dismiss(animated: true)
        }
    }
    @objc private func colorSelected(_ sender: UIButton) {
        viewModel.selectColor(at: sender.tag)
    }
    private func refreshSwatchSelectionUI() {
        for (i, b) in colorButtons.enumerated() {
            b.layer.borderColor = (i == viewModel.selectedColorIndex) ? UIColor.systemGray3.cgColor : UIColor.clear.cgColor
        }
    }

    // Helpers
    private static func makeTextField(placeholder: String) -> UITextField {
        let tf = UITextField()
        tf.placeholder = placeholder
        tf.borderStyle = .roundedRect
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }
}

extension AddClothingViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        pickerView.tag == 0 ? ClothingCategory.allCases.count : viewModel.seasons.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        pickerView.tag == 0 ? ClothingCategory.allCases[row].rawValue : viewModel.seasons[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 0 {
            viewModel.setCategory(ClothingCategory.allCases[row])
            categoryField.text = ClothingCategory.allCases[row].rawValue
        } else {
            let s = viewModel.seasons[row]
            viewModel.setSeason(s)
            seasonField.text = s
        }
    }
}

    


