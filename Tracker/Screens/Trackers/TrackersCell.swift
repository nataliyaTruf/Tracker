//
//  TrackersCell.swift
//  Tracker
//
//  Created by Natasha Trufanova on 27/01/2024.
//

import UIKit

final class TrackersCell: UICollectionViewCell {
    // MARK: - Properties
    
    static let cellIdetnifier = "TrackersCell"
    var onToggleCompleted: (() -> Void)?
    var onPin: (() -> Void)?
    var onEdit: (() -> Void)?
    var onDelete: (() -> Void)?
    
    var isCompleted: Bool = false {
        didSet {
            let buttonImage = isCompleted ? UIImage(named: "done") : plusImage
            markAsCompleteButton.setImage(buttonImage, for: .normal)
            markAsCompleteButton.alpha = isCompleted ? 0.3 : 1
        }
    }
    
    var isPinned: Bool = false {
        didSet {
            pinImageView.isHidden = !isPinned
            pinActionTitle = isPinned ? L10n.unpin : L10n.pin
            print("isPinned updated to: \(isPinned)")
        }
    }
    
    private var pinActionTitle = L10n.pin
    
    // MARK: - UI Components
    
    private lazy var topBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(resource: .colorSelection18)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16)
        label.text = L10n.defaultEmoji
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var emojiBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .white.withAlphaComponent(0.3)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textColor = .white
        label.font = Fonts.medium(size: 12)
        label.text = L10n.defaultGoodThing
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var bottomBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var daysCounterLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = Fonts.medium(size: 12)
        let initialCount = 0
        label.text = String.localizedStringWithFormat(
            NSLocalizedString("daysCounter", comment: "Number of days"),
            initialCount
        )
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var plusImage: UIImage? = {
        return UIImage(systemName: "plus")?
            .withTintColor(.ypWhiteDay, renderingMode: .alwaysOriginal)
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 12, weight: .bold))
    }()
    
    private lazy var markAsCompleteButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .colorSelection18
        button.setImage(plusImage, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var pinImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "pinned")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
        markAsCompleteButton.addTarget(
            self,
            action: #selector(markAsCompleteButtonTapped),
            for: .touchUpInside
        )
        setupContextMenu()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle Methods
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        topBackgroundView.layer.cornerRadius = 16
        topBackgroundView.layer.masksToBounds = true
        
        emojiBackgroundView.layer.cornerRadius = 12
        emojiBackgroundView.clipsToBounds = true
        
        markAsCompleteButton.layer.cornerRadius = 17
        markAsCompleteButton.clipsToBounds = true
    }
    
    // MARK: - Configuration
    
    func configure(with tracker: Tracker, completedDays: Int, isPinned: Bool) {
        emojiLabel.text = tracker.emodji
        nameLabel.text = tracker.name
        topBackgroundView.backgroundColor =  UIColor.color(from: tracker.color) ?? .blue
        markAsCompleteButton.backgroundColor = topBackgroundView.backgroundColor
        daysCounterLabel.text = getDayWordForCount(completedDays)
        self.isPinned = isPinned
        print("Configure called with isPinned: \(isPinned)")
    }
    
    // MARK: - Setup Methods
    
    private func setupViews() {
        contentView.addSubview(topBackgroundView)
        contentView.addSubview(bottomBackgroundView)
        topBackgroundView.addSubview(emojiBackgroundView)
        topBackgroundView.addSubview(emojiLabel)
        topBackgroundView.addSubview(nameLabel)
        contentView.addSubview(daysCounterLabel)
        contentView.addSubview(markAsCompleteButton)
        topBackgroundView.addSubview(pinImageView)
        setupLayout()
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            topBackgroundView.topAnchor.constraint(equalTo: contentView.topAnchor),
            topBackgroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            topBackgroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            topBackgroundView.heightAnchor.constraint(equalToConstant: 90),
            
            emojiBackgroundView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            emojiBackgroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            emojiBackgroundView.widthAnchor.constraint(equalToConstant: 24),
            emojiBackgroundView.heightAnchor.constraint(equalToConstant: 24),
            
            emojiLabel.centerXAnchor.constraint(equalTo: emojiBackgroundView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiBackgroundView.centerYAnchor),
            
            nameLabel.leadingAnchor.constraint(equalTo: topBackgroundView.leadingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: topBackgroundView.trailingAnchor, constant: -12),
            nameLabel.heightAnchor.constraint(equalToConstant: 34),
            nameLabel.bottomAnchor.constraint(equalTo: topBackgroundView.bottomAnchor, constant: -12),
            
            bottomBackgroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bottomBackgroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            bottomBackgroundView.topAnchor.constraint(equalTo: topBackgroundView.bottomAnchor),
            bottomBackgroundView.heightAnchor.constraint(equalToConstant: 58),
            
            markAsCompleteButton.trailingAnchor.constraint(equalTo: bottomBackgroundView.trailingAnchor, constant: -12),
            markAsCompleteButton.bottomAnchor.constraint(equalTo: bottomBackgroundView.bottomAnchor, constant: -16),
            markAsCompleteButton.widthAnchor.constraint(equalToConstant: 34),
            markAsCompleteButton.heightAnchor.constraint(equalToConstant: 34),
            
            daysCounterLabel.centerYAnchor.constraint(equalTo: markAsCompleteButton.centerYAnchor),
            daysCounterLabel.leadingAnchor.constraint(equalTo: bottomBackgroundView.leadingAnchor, constant: 12),
            pinImageView.topAnchor.constraint(equalTo: topBackgroundView.topAnchor, constant: 12),
            pinImageView.trailingAnchor.constraint(equalTo: topBackgroundView.trailingAnchor, constant: -4),
            pinImageView.widthAnchor.constraint(equalToConstant: 24),
            pinImageView.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    // MARK: - Private Methods
    
    private func setupContextMenu() {
        let interaction = UIContextMenuInteraction(delegate: self)
        topBackgroundView.addInteraction(interaction)
    }
    
    private func getDayWordForCount(_ count: Int) -> String {
        return String.localizedStringWithFormat(
            NSLocalizedString("daysCounter", comment: "Number of days"),
            count
        )
    }
    
    // MARK: - Actions
    
    @objc private func markAsCompleteButtonTapped() {
        onToggleCompleted?()
    }
}

// MARK: UIContextMenuInteractionDelegate

extension TrackersCell: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        print("contextMenuInteraction called")
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] suggestedActions in
            guard let self = self else { return nil }
            
            let pinAction = UIAction(title: self.pinActionTitle) { [weak self] action in
                self?.onPin?()
            }
            
            let editAction = UIAction(title: L10n.editActionTitle) { [weak self] action in
                AnalyticsService.didClickEdit()
                self?.onEdit?()
            }
            
            let deleteAction = UIAction(title: L10n.deleteActionTitle, attributes: .destructive) { [weak self] action in
                AnalyticsService.didClickDelete()
                self?.onDelete?()
            }
            return UIMenu(title: "", children: [pinAction, editAction, deleteAction])
        }
    }
}
