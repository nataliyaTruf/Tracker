//
//  CreateTrackerController.swift
//  Tracker
//
//  Created by Natasha Trufanova on 09/02/2024.
//

import UIKit

// MARK: - Protocols

protocol TrackerCreationDelegate: AnyObject {
    func trackerCreated(_ tracker: Tracker)
}

// MARK: - Main Class

final class CreateTrackerViewController: UIViewController {
    // MARK: - Delegate
    
    weak var delegate: TrackerCreationDelegate?
    
    // MARK: - Properties
    
    private var selectedSchedule: ReccuringSchedule?
    var onCompletion: (() -> Void)?
    private let params: GeometricParams
    private var isHabitTracker: Bool
    
    private var emojis: [String] = [
        "😀", "😻", "🌺", "🐶", "❤️", "😱",
        "😇", "😡", "🥶", "🤔", "🙌", "🍔",
        "🥦", "🏓", "🥇", "🎸", "🏝️", "😪"
    ]
    private var colors: [UIColor] = [
        .colorSelection1, .colorSelection2, .colorSelection3, .colorSelection4, .colorSelection5,
        .colorSelection6, .colorSelection7, .colorSelection8, .colorSelection9, .colorSelection10,
        .colorSelection11, .colorSelection12, .colorSelection13, .colorSelection14, .colorSelection15,
        .colorSelection16, .colorSelection17, .colorSelection18
    ]
    private var selectedEmojiIndex: IndexPath?
    private var selectedColorIndex: IndexPath?
    
    // MARK: - UI Components
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .ypWhiteDay
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var titleView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Новая привычка"
        label.font = UIFont(name: "YSDisplay-Medium", size: 16)
        label.textAlignment = .center
        label.textColor = UIColor.ypBlackDay
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var nameTextField = {
        let textField = UITextField()
        textField.placeholder = "Введите назывние трекера"
        textField.textColor = .ypBlackDay
        textField.textAlignment = .left
        textField.borderStyle = .none
        textField.layer.masksToBounds = true
        textField.layer.cornerRadius = 16
        textField.backgroundColor = .ypBackgroundDay
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var categoryView: CustomOptionView = {
        let view = CustomOptionView()
        view.configure(with: "Категория", additionalText: nil)
        view.layer.cornerRadius = 16
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return view
    }()
    
    private lazy var scheduleView: CustomOptionView = {
        let view = CustomOptionView()
        view.configure(with: "Расписание", additionalText: nil)
        view.layer.cornerRadius = 16
        view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
        view.onTap = { [weak self] in
            self?.showScheduleViewController()
        }
        return view
    }()
    
    private lazy var buttonsView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Отменить", for: .normal)
        button.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 16)
        button.tintColor = UIColor.ypRed
        button.layer.borderColor = UIColor.ypRed.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 16
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Создать", for: .normal)
        button.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 16)
        button.backgroundColor = UIColor.ypGray
        button.layer.borderColor = UIColor.ypGray.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 16
        button.tintColor = UIColor.ypWhiteDay
        button.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var emojiCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(EmojiCell.self, forCellWithReuseIdentifier: EmojiCell.idetnifier)
        collectionView.register(
            ReusableHeader.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: ReusableHeader.identifier
        )
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private lazy var colorCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(ColorCell.self, forCellWithReuseIdentifier: ColorCell.idetnifier)
        collectionView.register(
            ReusableHeader.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: ReusableHeader.identifier
        )
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private lazy var characterLimitLabel: UILabel = {
        let label = UILabel()
        label.text = "Ограничение 38 символов"
        label.font = UIFont(name: "YSDisplay-Medium", size: 17)
        label.textAlignment = .center
        label.textColor = .ypRed
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Initialization
    
    init(isHabit: Bool) {
        self.params = GeometricParams(cellCount: 6, leftInsets: 2, rightInsets: 2, cellSpacing: 5)
        self.isHabitTracker = isHabit
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        setupKeyboardDismiss()
        nameTextField.delegate = self
        
        titleLabel.text = isHabitTracker ? "Новая привычка" : "Новое нерегулярное событие"
        updateSpacing(isVisible: false)
    }
    
    // MARK: - Actions
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func createButtonTapped() {
        let trackerName = nameTextField.text ?? ""
        let selectedEmoji = selectedEmojiIndex != nil ? emojis[selectedEmojiIndex!.item] : "🍔"
        let selectedColor = selectedColorIndex != nil ? colors[selectedColorIndex!.item] : .colorSelection6
        let selectedColorString = UIColor.string(from: selectedColor) ?? "colorSelection6"
        
        let tracker = CoreDataStack.shared.trackerStore.createTracker(
            id: UUID(),
            name: trackerName,
            color: selectedColorString,
            emoji: selectedEmoji,
            schedule: selectedSchedule
        )
        
        delegate?.trackerCreated(tracker)
        onCompletion?()
        dismiss(animated: false, completion: nil)
    }
    
    // MARK: - Navigation
    
    private func showScheduleViewController() {
        let scheduleVC = ScheduleViewController()
        scheduleVC.trackerStore = CoreDataStack.shared.trackerStore
        scheduleVC.onScheduleUpdated = { [weak self] updatedSchedule in
            self?.selectedSchedule = updatedSchedule
            
            if let scheduleData = self?.selectedSchedule?.recurringDays {
                print("✅ CreateTrackerViewController - Received updated schedule: \(scheduleData)")
            } else {
                print("⚠️ CreateTrackerViewController - Received nil for updated schedule")
            }
            
            let formattedSchedule = updatedSchedule.scheduleText
            self?.scheduleView.configure(with: "Расписание", additionalText: formattedSchedule)
            self?.updateCreateButtonState()
        }
        
        scheduleVC.modalPresentationStyle = .pageSheet
        present(scheduleVC, animated: true)
    }
    
    // MARK: - Initial UI Setup
    
    private func setupViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        
        stackView.addArrangedSubview(titleView)
        stackView.addArrangedSubview(nameTextField)
        stackView.addArrangedSubview(characterLimitLabel)
        stackView.addArrangedSubview(categoryView)
        let divider = createDivider()
        divider.isHidden = !isHabitTracker
        
        if !isHabitTracker {
            categoryView.layer.cornerRadius = 16
            categoryView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else {
            stackView.addArrangedSubview(divider)
            stackView.addArrangedSubview(scheduleView)}
        
        stackView.addArrangedSubview(emojiCollectionView)
        stackView.addArrangedSubview(colorCollectionView)
        stackView.addArrangedSubview(buttonsView)
        
        setupTitleView()
        setupButtonsView()
        setupSpacing()
    }
    
    private func setupSpacing() {
        stackView.setCustomSpacing(24, after: titleView)
        stackView.setCustomSpacing(24, after: nameTextField)
        
        let spacingAfterCategoryView = isHabitTracker ? 0 : 50
        stackView.setCustomSpacing(CGFloat(spacingAfterCategoryView), after: categoryView)
        if isHabitTracker {
            stackView.setCustomSpacing(50, after: scheduleView)
        }
        
        stackView.setCustomSpacing(34, after: emojiCollectionView)
        stackView.setCustomSpacing(16, after: colorCollectionView)
        
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
    
    private func updateSpacing(isVisible: Bool) {
        let spacingAfterTextField: CGFloat = isVisible ? 8 : 24
            let spacingAfterCharacterLimitLabel: CGFloat = isVisible ? 32 : 0
            
            stackView.setCustomSpacing(spacingAfterTextField, after: nameTextField)
            stackView.setCustomSpacing(spacingAfterCharacterLimitLabel, after: characterLimitLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            buttonsView.heightAnchor.constraint(equalToConstant: 60),
            categoryView.heightAnchor.constraint(equalToConstant: 75),
            scheduleView.heightAnchor.constraint(equalToConstant: 75),
            titleView.heightAnchor.constraint(equalToConstant: 70),
            nameTextField.heightAnchor.constraint(equalToConstant: 75),
            characterLimitLabel.heightAnchor.constraint(equalToConstant: 22),
            emojiCollectionView.heightAnchor.constraint(equalToConstant: 222),
            colorCollectionView.heightAnchor.constraint(equalToConstant: 222)
        ])
    }
}

// MARK: - UITextFieldDelegate

extension CreateTrackerViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    internal func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updateText = currentText.replacingCharacters(in: stringRange, with: string)
        let isAcceptableLength =  updateText.count <= 38
        characterLimitLabel.isHidden = isAcceptableLength
        updateSpacing(isVisible: !isAcceptableLength)
        
        if isAcceptableLength {
            self.updateCreateButtonState()
        }
        
        return isAcceptableLength
    }
}

// MARK: - Additional UI Setup

extension CreateTrackerViewController {
    private func setupTitleView() {
        titleView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: titleView.centerXAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: titleView.bottomAnchor, constant: -14),
            titleLabel.heightAnchor.constraint(equalToConstant: 22)
        ])
    }
    
    private func setupButtonsView() {
        buttonsView.addSubview(cancelButton)
        buttonsView.addSubview(createButton)
        
        NSLayoutConstraint.activate([
            cancelButton.leadingAnchor.constraint(equalTo: buttonsView.leadingAnchor, constant: 4),
            cancelButton.topAnchor.constraint(equalTo: buttonsView.topAnchor),
            cancelButton.bottomAnchor.constraint(equalTo: buttonsView.bottomAnchor),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            
            createButton.leadingAnchor.constraint(equalTo: cancelButton.trailingAnchor, constant: 8),
            createButton.trailingAnchor.constraint(equalTo: buttonsView.trailingAnchor, constant: -4),
            createButton.topAnchor.constraint(equalTo: buttonsView.topAnchor),
            createButton.bottomAnchor.constraint(equalTo: buttonsView.bottomAnchor),
            createButton.heightAnchor.constraint(equalToConstant: 60),
            createButton.widthAnchor.constraint(equalTo: cancelButton.widthAnchor)
        ])
    }
    
    private func createDivider() -> UIView {
        let dividerContainer = UIView()
        dividerContainer.translatesAutoresizingMaskIntoConstraints = false
        
        let divider = UIView()
        divider.backgroundColor = UIColor.ypGray
        divider.translatesAutoresizingMaskIntoConstraints = false
        dividerContainer.addSubview(divider)
        
        NSLayoutConstraint.activate([
            divider.heightAnchor.constraint(equalToConstant: 0.5),
            divider.centerXAnchor.constraint(equalTo: dividerContainer.centerXAnchor),
            divider.centerYAnchor.constraint(equalTo: dividerContainer.centerYAnchor),
            divider.widthAnchor.constraint(equalTo: dividerContainer.widthAnchor, multiplier: 0.9)
        ])
        NSLayoutConstraint.activate([
            dividerContainer.heightAnchor.constraint(equalToConstant: 0.5)
        ])
        
        return dividerContainer
    }
    
    private func setupKeyboardDismiss() {
        scrollView.keyboardDismissMode = .onDrag
    }
    
    private func updateCreateButtonState() {
        let isNameEntered = !(nameTextField.text?.isEmpty ?? true)
        let isEmojiSelected = selectedEmojiIndex != nil
        let isColorSelected = selectedColorIndex != nil
        let isScheduleSet = selectedSchedule != nil || !isHabitTracker
        
        let isFormComplete = isNameEntered && isEmojiSelected && isColorSelected && isScheduleSet
        
        createButton.isEnabled = isFormComplete
        createButton.backgroundColor = isFormComplete ? .ypBlackDay : .ypGray
    }
}

// MARK: - UICollectionViewDataSource

extension CreateTrackerViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == emojiCollectionView {
            return emojis.count
        } else {
            return colors.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == emojiCollectionView {
            guard let cell = emojiCollectionView.dequeueReusableCell(withReuseIdentifier: EmojiCell.idetnifier, for: indexPath) as? EmojiCell else {
                assertionFailure("Error: Unable to dequeue EmojiCell")
                return UICollectionViewCell()
            }
            let isSelected = indexPath == selectedEmojiIndex
            cell.configure(with: emojis[indexPath.item], isSelected: isSelected)
            
            return cell
            
        } else {
            guard let cell = colorCollectionView.dequeueReusableCell(withReuseIdentifier: ColorCell.idetnifier, for: indexPath) as? ColorCell else {
                assertionFailure("Error: Unable to dequeue ColorCell")
                return UICollectionViewCell()
            }
            let isSelected = indexPath == selectedColorIndex
            cell.configure(with: colors[indexPath.item], isSelected: isSelected)
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            assertionFailure( "Failed to cast UICollectionReusableView" )
            return UICollectionReusableView()
        }
        
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: ReusableHeader.identifier,
            for: indexPath) as? ReusableHeader
        else { assertionFailure("Failed to cast UICollectionReusableView" )
            return UICollectionReusableView()
        }
        
        if collectionView == emojiCollectionView {
            header.configure(with: "Emoji")
        } else if collectionView == colorCollectionView {
            header.configure(with: "Цвет")
        }
        
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == emojiCollectionView {
            
            if selectedEmojiIndex == indexPath {
                selectedEmojiIndex = nil
            }
            selectedEmojiIndex = indexPath
        } else if collectionView == colorCollectionView {
            if selectedColorIndex == indexPath {
                selectedColorIndex = nil
            }
            selectedColorIndex = indexPath
        }
        
        collectionView.reloadData()
        updateCreateButtonState()
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension CreateTrackerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalSpacing = (params.cellSpacing * CGFloat(params.cellCount - 1)) + params.leftInsets + params.rightInsets
        let availableWidth = collectionView.bounds.width - totalSpacing
        let widthPerItem = availableWidth / CGFloat(params.cellCount)
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 24, left: params.leftInsets, bottom: 24, right: params.rightInsets)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return params.cellSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 18)
    }
}
