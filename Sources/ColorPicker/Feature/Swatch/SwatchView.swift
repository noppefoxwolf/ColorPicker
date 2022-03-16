import UIKit
import Combine

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
        sectionProvider: { section, environment in
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
            cell.color = configuration.color
            cell.style = configuration.isSelected ? .outlined : .normal
        }
    )
    let addColorCellRegistration = UICollectionView.CellRegistration(
        handler: { (cell: AddColorCell, indexPath, color: Void) in
        }
    )
    lazy var dataSource: UICollectionViewDiffableDataSource<Section, CellItem> = .init(
        collectionView: collectionView,
        cellProvider: { (collectionView, indexPath, item) in
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
    var cancellables: Set<AnyCancellable> = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .clear
        collectionView.backgroundColor = .clear
        collectionView.allowsSelection = true
        collectionView.delegate = self
        collectionView.alwaysBounceVertical = false
        
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
        
        pageControl.addAction(UIAction { action in
            let pageControl = action.sender as! UIPageControl
            self.scrollTo(page: pageControl.currentPage, animated: true)
        }, for: .valueChanged)
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(onLongPress(_:)))
        collectionView.addGestureRecognizer(longPress)
        
        snapshot.appendSections([.items])
        
        becomeFirstResponder()
        
        let count = 3
        snapshot.appendItems((0..<count).map({ i in
                .color(ColorItem(id: UUID(), color: UIColor(white: Double(i) / Double(count), alpha: 1)))
        }), toSection: .items)
        snapshot.appendItems([.add], toSection: .items)
        apply(snapshot)
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
    
    private func apply(_ snapshot: NSDiffableDataSourceSnapshot<Section, CellItem>) {
        let itemCount = snapshot.numberOfItems(inSection: .items)
        pageControl.numberOfPages = Int(ceil(Double(itemCount) / 10.0))
        dataSource.apply(snapshot)
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
