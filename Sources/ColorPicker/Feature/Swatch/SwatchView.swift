import UIKit

class SwatchView: UIControl {
    enum CellItem: Hashable, Sendable {
        case color(ColorItem)
        case add
    }
    enum Section: Sendable {
        case items
    }

    private lazy var editMenuInteraction: UIEditMenuInteraction = {
        let interaction = UIEditMenuInteraction(delegate: self)
        return interaction
    }()

    let debounceAction = Debounce<() -> Void>(
        duration: .milliseconds(160),
        output: { $0() }
    )

    private var _selectedColor: HSVA = .noop {
        didSet {
            /// 逐次実行だと重いので遅延させる
            debounceAction.emit { [weak self] in
                self?.reconfigureCells()
            }
        }
    }

    var selectedColor: HSVA {
        get { _selectedColor }
        set {
            guard _selectedColor != newValue else { return }
            _selectedColor = newValue
        }
    }

    let configuration: UICollectionViewCompositionalLayoutConfiguration = {
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        configuration.scrollDirection = .vertical
        return configuration
    }()
    lazy var layout: UICollectionViewLayout = UICollectionViewCompositionalLayout(
        sectionProvider: { [unowned self] section, environment in
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .fractionalHeight(1)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let hGroupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .fractionalHeight(1)
            )

            let count: Int
            switch environment.traitCollection.horizontalSizeClass {
            case .regular:
                count = 8
            default:
                count = 5
            }
            let hGroup = NSCollectionLayoutGroup.horizontal(
                layoutSize: hGroupSize,
                subitem: item,
                count: count
            )
            //            hGroup.interItemSpacing = .flexible(16)
            let vGroupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .fractionalHeight(1)
            )
            let vGroup = NSCollectionLayoutGroup.vertical(
                layoutSize: vGroupSize,
                subitem: hGroup,
                count: 2
            )
            vGroup.interItemSpacing = .flexible(-4)
            let section = NSCollectionLayoutSection(group: vGroup)
            section.orthogonalScrollingBehavior = .groupPaging
            section.visibleItemsInvalidationHandler = {
                [unowned self]
                (visibleItems, point, environment: NSCollectionLayoutEnvironment) in
                guard self.pageControl.interactionState == .none else { return }
                self.pageControl.currentPage = Int(
                    point.x / environment.container.contentSize.width
                )
            }
            return section
        },
        configuration: configuration
    )
    lazy var collectionView = UICollectionView(frame: .null, collectionViewLayout: layout)

    struct ColorCellConfiguration {
        let color: HSVA
        let isSelected: Bool
    }
    let colorCellRegistration = UICollectionView.CellRegistration(
        handler: { (cell: ColorCell, indexPath, configuration: ColorCellConfiguration) in
            cell.colorView.color = configuration.color
            cell.colorView.style = configuration.isSelected ? .outlined : .normal
        }
    )
    let addColorCellRegistration = UICollectionView.CellRegistration(
        handler: { (cell: AddColorCell, indexPath, void: Void) in
        }
    )
    lazy var dataSource: UICollectionViewDiffableDataSource<Section, CellItem> = .init(
        collectionView: collectionView,
        cellProvider: { [weak self] (collectionView, indexPath, item) in
            guard let self = self else { return nil }
            switch item {
            case .add:
                return collectionView.dequeueConfiguredReusableCell(
                    using: self.addColorCellRegistration,
                    for: indexPath,
                    item: ()
                )
            case let .color(cellItem):
                return collectionView.dequeueConfiguredReusableCell(
                    using: self.colorCellRegistration,
                    for: indexPath,
                    item: ColorCellConfiguration(
                        color: cellItem.color,
                        isSelected: cellItem.color == self.selectedColor
                    )
                )
            }
        }
    )

    let pageControl: UIPageControl = .init(frame: .null)
    var snapshot = NSDiffableDataSourceSnapshot<Section, CellItem>()
    var onChanged: (([ColorItem]) -> Void) = { _ in }

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .clear
        collectionView.backgroundColor = .clear
        collectionView.allowsSelection = true
        collectionView.delegate = self
        collectionView.alwaysBounceVertical = false
        collectionView.dragDelegate = self
        collectionView.dropDelegate = self
        collectionView.dragInteractionEnabled = true
        // FIXME: ドラッグ時の影がクリップされてしまう
        // collectionView.clipsToBounds = false

        pageControl.pageIndicatorTintColor = .systemGray
        pageControl.currentPageIndicatorTintColor = .label
        // hiddenするとレイアウトに影響が出るのでしない
        pageControl.hidesForSinglePage = false

        let stackView = UIStackView(arrangedSubviews: [collectionView, pageControl])
        stackView.axis = .vertical
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.heightAnchor.constraint(equalToConstant: 76),
            pageControl.heightAnchor.constraint(equalToConstant: 20),
        ])

        pageControl.addAction(
            UIAction { [unowned self] action in
                let pageControl = action.sender as! UIPageControl
                self.scrollTo(page: pageControl.currentPage, animated: true)
            },
            for: .valueChanged
        )

        let longPress = UILongPressGestureRecognizer(
            target: self,
            action: #selector(onLongPress(_:))
        )
        collectionView.addGestureRecognizer(longPress)
        collectionView.addInteraction(editMenuInteraction)

        snapshot.appendSections([.items])

        becomeFirstResponder()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    @objc func onLongPress(_ gesture: UILongPressGestureRecognizer) {
        let location = gesture.location(in: gesture.view)
        guard let indexPath = collectionView.indexPathForItem(at: location) else { return }
        guard dataSource.itemIdentifier(for: indexPath) != .add else { return }
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }
        let configuration = UIEditMenuConfiguration(identifier: nil, sourcePoint: cell.center)
        editMenuInteraction.presentEditMenu(with: configuration)
    }

    override var canBecomeFirstResponder: Bool {
        true
    }

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        [
            #selector(UIResponderStandardEditActions.delete)
        ]
        .contains(action)
    }

    func setColorItems(_ colorItems: [ColorItem]) {
        snapshot.deleteAllItems()
        snapshot.appendSections([.items])
        snapshot.appendItems(colorItems.map({ .color($0) }), toSection: .items)
        snapshot.appendItems([.add], toSection: .items)
        apply(snapshot)
    }

    var colorItems: [ColorItem] {
        snapshot.itemIdentifiers(inSection: .items)
            .compactMap({
                guard case let .color(colorItem) = $0 else { return nil }
                return colorItem
            })
    }

    private func apply(_ snapshot: NSDiffableDataSourceSnapshot<Section, CellItem>) {
        let itemCount = snapshot.numberOfItems(inSection: .items)
        pageControl.numberOfPages = Int(ceil(Double(itemCount) / 10.0))
        dataSource.apply(snapshot)

        let colorItems = snapshot.itemIdentifiers.compactMap({ (cellItem) -> ColorItem? in
            switch cellItem {
            case .add:
                return nil
            case .color(let colorItem):
                return colorItem
            }
        })
        onChanged(colorItems)
    }

    private func reconfigureCells() {
        snapshot.reconfigureItems(snapshot.itemIdentifiers)
        dataSource.apply(snapshot)
    }
}

extension SwatchView: UICollectionViewDelegate {
    func scrollTo(page: Int, animated: Bool) {
        collectionView.scrollToItem(
            at: IndexPath(row: page * 10, section: 0),
            at: .top,
            animated: animated
        )
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        switch item {
        case .color(let colorItem):
            selectedColor = colorItem.color
            reconfigureCells()
            sendActions(for: .primaryActionTriggered)
        case .add:
            snapshot.insertItems(
                [
                    .color(ColorItem(id: UUID(), color: selectedColor))
                ],
                beforeItem: .add
            )
            apply(snapshot)
        }
    }
}

extension SwatchView: UICollectionViewDragDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        itemsForBeginning session: UIDragSession,
        at indexPath: IndexPath
    ) -> [UIDragItem] {
        guard let itemIdentifier = dataSource.itemIdentifier(for: indexPath) else {
            return []
        }
        guard case let .color(colorItem) = itemIdentifier else {
            return []
        }
        let itemProvider = NSItemProvider(
            object: colorItem.id.uuidString as NSItemProviderWriting
        )
        let dragItem = UIDragItem(itemProvider: itemProvider)
        return [dragItem]
    }

    func collectionView(
        _ collectionView: UICollectionView,
        dragPreviewParametersForItemAt indexPath: IndexPath
    ) -> UIDragPreviewParameters? {
        guard let cell = collectionView.cellForItem(at: indexPath) as? ColorCell else {
            return nil
        }
        let parameters = UIDragPreviewParameters()
        parameters.visiblePath = UIBezierPath(ovalIn: cell.contentRect())
        parameters.backgroundColor = .clear
        return parameters
    }
}

extension SwatchView: UICollectionViewDropDelegate {

    func collectionView(
        _ collectionView: UICollectionView,
        dropSessionDidUpdate session: UIDropSession,
        withDestinationIndexPath destinationIndexPath: IndexPath?
    ) -> UICollectionViewDropProposal {
        if session.localDragSession != nil {
            if let destinationIndexPath = destinationIndexPath {
                if let item = dataSource.itemIdentifier(for: destinationIndexPath),
                    case .add = item
                {
                    return UICollectionViewDropProposal(
                        operation: .cancel
                    )
                } else {
                    if session.items.count > 1 {
                        return UICollectionViewDropProposal(
                            operation: .move,
                            intent: .insertIntoDestinationIndexPath
                        )
                    } else {
                        return UICollectionViewDropProposal(
                            operation: .move,
                            intent: .insertAtDestinationIndexPath
                        )
                    }
                }
            } else {
                return UICollectionViewDropProposal(
                    operation: .cancel
                )
            }
        } else {
            // 外部からのD&Dは受け付けない
            return UICollectionViewDropProposal(
                operation: .cancel
            )
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        performDropWith coordinator: UICollectionViewDropCoordinator
    ) {
        switch coordinator.proposal.operation {
        case .move:
            guard let destinationIndexPath = coordinator.destinationIndexPath else {
                return
            }
            guard let sourceIndexPath = coordinator.items.first?.sourceIndexPath else {
                return
            }
            let sourceItem = snapshot.itemIdentifiers(inSection: .items)[sourceIndexPath.row]
            let destItem = snapshot.itemIdentifiers(inSection: .items)[destinationIndexPath.row]

            if destinationIndexPath > sourceIndexPath {
                snapshot.moveItem(sourceItem, afterItem: destItem)
            } else if destinationIndexPath < sourceIndexPath {
                snapshot.moveItem(sourceItem, beforeItem: destItem)
            }

            apply(snapshot)

            coordinator.items.forEach { item in
                coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
            }
        case .cancel, .forbidden, .copy:
            return
        @unknown default:
            fatalError()
        }
    }
}

extension SwatchView: @MainActor UIEditMenuInteractionDelegate {
    func editMenuInteraction(
        _ interaction: UIEditMenuInteraction,
        menuFor configuration: UIEditMenuConfiguration,
        suggestedActions: [UIMenuElement]
    ) -> UIMenu? {
        let location = interaction.location(in: collectionView)
        guard let indexPath = collectionView.indexPathForItem(at: location) else { return nil }
        guard dataSource.itemIdentifier(for: indexPath) != .add else { return nil }

        // Remember which item was long-pressed for the Delete action
        let item = dataSource.itemIdentifier(for: indexPath)
        
        // Provide a Delete action when we have a valid long-pressed color item
        let delete = UIAction(
            title: LocalizedString.delete,
            image: UIImage(systemName: "trash"),
            attributes: [.destructive]
        ) { [weak self] _ in
            guard let self else { return }
            if let item {
                self.snapshot.deleteItems([item])
                self.apply(self.snapshot)
            }
        }
        return UIMenu(children: [delete])
    }
}
