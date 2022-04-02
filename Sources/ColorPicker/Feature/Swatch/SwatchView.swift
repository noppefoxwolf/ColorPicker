import UIKit

class SwatchView: UIControl {
    enum CellItem: Hashable {
        case color(ColorItem)
        case add
    }
    enum Section {
        case items
    }
    let debounceAction = DispatchQueue.main.debounce(delay: .milliseconds(160))
    
    private var _selectedColor: UIColor = .white {
        didSet {
            /// 逐次実行だと重いので遅延させる
            debounceAction { [weak self] in
                self?.reconfigureCells()
            }
        }
    }
    
    var selectedColor: UIColor {
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
            let hGroup = NSCollectionLayoutGroup.horizontal(
                layoutSize: hGroupSize, subitem: item, count: 5)
            //            hGroup.interItemSpacing = .flexible(16)
            let vGroupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .fractionalHeight(1)
            )
            let vGroup = NSCollectionLayoutGroup.vertical(
                layoutSize: vGroupSize, subitem: hGroup, count: 2)
            vGroup.interItemSpacing = .flexible(-4)
            let section = NSCollectionLayoutSection(group: vGroup)
            section.orthogonalScrollingBehavior = .groupPaging
            section.visibleItemsInvalidationHandler = { [unowned self]
                (visibleItems, point, environment: NSCollectionLayoutEnvironment) in
                guard self.pageControl.interactionState == .none else { return }
                self.pageControl.currentPage = Int(point.x / environment.container.contentSize.width)
            }
            return section
        },
        configuration: configuration
    )
    lazy var collectionView = UICollectionView(frame: .null, collectionViewLayout: layout)
    
    struct ColorCellConfiguration {
        let color: UIColor
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
    var longPressedItem: CellItem? = nil
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
        
        pageControl.pageIndicatorTintColor = .systemGray
        pageControl.currentPageIndicatorTintColor = .label
        // hiddenするとレイアウトに影響が出るのでしない
        pageControl.hidesForSinglePage = false
        
        let stackView = UIStackView(arrangedSubviews: [collectionView, pageControl])
        stackView.axis = .vertical
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        collectionView.snp.makeConstraints { make in
            make.height.equalTo(76)
        }
        pageControl.snp.makeConstraints { make in
            make.height.equalTo(20)
        }
        
        pageControl.addAction(UIAction { [unowned self] action in
            let pageControl = action.sender as! UIPageControl
            self.scrollTo(page: pageControl.currentPage, animated: true)
        }, for: .valueChanged)
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(onLongPress(_:)))
        collectionView.addGestureRecognizer(longPress)
        
        snapshot.appendSections([.items])
        
        becomeFirstResponder()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    @objc func onLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        let menu = UIMenuController.shared
        let location = gesture.location(in: gesture.view)
        guard let indexPath = collectionView.indexPathForItem(at: location) else { return }
        guard dataSource.itemIdentifier(for: indexPath) != .add else { return }
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }
        menu.showMenu(from: cell, rect: cell.bounds)
        longPressedItem = dataSource.itemIdentifier(for: indexPath)
    }
    
    override var canBecomeFirstResponder: Bool {
        true
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        [
            #selector(UIResponderStandardEditActions.delete)
        ].contains(action)
    }
    
    override func delete(_ sender: Any?) {
        if let longPressedItem = longPressedItem {
            snapshot.deleteItems([longPressedItem])
            self.longPressedItem = nil
            apply(snapshot)
        }
    }
    
    func setColorItems(_ colorItems: [ColorItem]) {
        snapshot.appendItems(colorItems.map({ .color($0) }), toSection: .items)
        snapshot.appendItems([.add], toSection: .items)
        apply(snapshot)
    }
    
    var colorItems: [ColorItem] {
        snapshot.itemIdentifiers(inSection: .items).compactMap({
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
            snapshot.insertItems([
                .color(ColorItem(id: UUID(), color: selectedColor))
            ], beforeItem: .add)
            apply(snapshot)
        }
    }
}

extension SwatchView: UICollectionViewDragDelegate {
    func collectionView(
        _ collectionView: UICollectionView, itemsForBeginning session: UIDragSession,
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
        _ collectionView: UICollectionView, dragPreviewParametersForItemAt indexPath: IndexPath
    ) -> UIDragPreviewParameters? {
        let parameters = UIDragPreviewParameters()
        parameters.backgroundColor = .clear
        return parameters
    }
}

extension SwatchView: UICollectionViewDropDelegate {
    func collectionView(
        _ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession,
        withDestinationIndexPath destinationIndexPath: IndexPath?
    ) -> UICollectionViewDropProposal {
        if session.localDragSession != nil {
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
            } else {
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
