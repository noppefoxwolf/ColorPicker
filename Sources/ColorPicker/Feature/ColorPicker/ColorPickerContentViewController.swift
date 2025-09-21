import SwiftUI
import UIKit

protocol ColorPickerContentViewControllerDelegate: AnyObject {
    func colorPickerViewController(
        _ viewController: ColorPickerContentViewController,
        didSelect color: HSVA,
        continuously: Bool
    )
    func colorPickerViewControllerDidFinish(_ viewController: ColorPickerContentViewController)
    func colorPickerSwatchDidChanged(_ viewController: ColorPickerContentViewController)

    func colorPickerDropperDidSelect(_ viewController: ColorPickerContentViewController)
}

class ColorPickerContentViewController: UIViewController {
    weak var delegate: ColorPickerContentViewControllerDelegate? = nil
    let scrollView = UIScrollView()
    let segmentControl = UISegmentedControl(items: nil)
    let swatchAndPreviewView: SwatchAndPreviewView = SwatchAndPreviewView(frame: .null)
    let alphaColorPicker: AlphaColorPicker = .init(frame: .null)

    /// segment - colorPickerAndSwatch - alphaPicker(Optional)
    let tabStackView: UIStackView = UIStackView()
    /// colorPicker - Swatch
    let colorPickersStackView = UIStackView()

    private var _color: HSVA = .noop {
        didSet {
            onUpdate(_color)
        }
    }

    var color: HSVA {
        get { _color }
        set {
            guard _color != newValue else { return }
            _color = newValue
        }
    }

    var continuously: Bool {
        configuration.colorPickers.map(\.continuously).contains(true)
    }

    var colorItems: [ColorItem] {
        get { swatchAndPreviewView.swatchView.colorItems }
        set { swatchAndPreviewView.swatchView.setColorItems(newValue) }
    }

    var supportsAlpha: Bool = false

    var configuration: ColorPickerConfiguration = ColorPickerConfiguration()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        view.backgroundColor = .secondarySystemBackground
        navigationItem.title = LocalizedString.color
        navigationItem.largeTitleDisplayMode = .always

        if configuration.usesDropperTool {
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                image: UIImage(systemName: "eyedropper"),
                primaryAction: UIAction { [unowned self] _ in
                    self.delegate?.colorPickerDropperDidSelect(self)
                }
            )
        }

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            systemItem: .close,
            primaryAction: UIAction { [unowned self] _ in
                self.dismiss(animated: true) { [unowned self] in
                    self.delegate?.colorPickerViewControllerDidFinish(self)
                }
            }
        )

        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        view.keyboardLayoutGuide.snp.makeConstraints { make in
            make.top.equalTo(scrollView.snp.bottom)
        }

        let contentView = UIView()
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }

        let hairlineView = HairlineView()
        let swatchStack = UIStackView(arrangedSubviews: [hairlineView, swatchAndPreviewView])
        swatchStack.axis = .vertical
        swatchStack.spacing = 20

        colorPickersStackView.spacing = 26
        colorPickersStackView.addArrangedSubview(tabStackView)
        if supportsAlpha {
            colorPickersStackView.addArrangedSubview(alphaColorPicker)
        }
        colorPickersStackView.addArrangedSubview(swatchStack)
        colorPickersStackView.axis = .vertical

        tabStackView.axis = .vertical
        tabStackView.spacing = 26
        tabStackView.layoutMargins = .init(top: 20, left: 20, bottom: 20, right: 20)
        tabStackView.isLayoutMarginsRelativeArrangement = true
        contentView.addSubview(tabStackView)
        tabStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        tabStackView.addArrangedSubview(segmentControl)
        tabStackView.addArrangedSubview(colorPickersStackView)

        for colorPicker in configuration.colorPickers {
            let segmentAction = UIAction(
                title: colorPicker.title,
                handler: { [unowned self] action in
                    self.updateCurrentColorPicker()
                }
            )
            segmentControl.insertSegment(
                action: segmentAction,
                at: segmentControl.numberOfSegments + 1,
                animated: false
            )

            let colorPickerAction = UIAction {
                [unowned self, unowned colorPicker, unowned alphaColorPicker] _ in
                var newColor = colorPicker.color
                newColor.a = alphaColorPicker.color.a
                self.color = newColor
                self.delegate?
                    .colorPickerViewController(
                        self,
                        didSelect: self.color,
                        continuously: self.continuously
                    )
            }
            colorPicker.addAction(colorPickerAction, for: .primaryActionTriggered)
        }

        alphaColorPicker.addAction(
            UIAction { [unowned self, unowned alphaColorPicker] _ in
                self.color = alphaColorPicker.color
                self.delegate?
                    .colorPickerViewController(
                        self,
                        didSelect: self.color,
                        continuously: self.continuously
                    )
            },
            for: .primaryActionTriggered
        )

        swatchAndPreviewView.addAction(
            UIAction { [unowned self] _ in
                self.color = self.swatchAndPreviewView.color
                self.delegate?
                    .colorPickerViewController(
                        self,
                        didSelect: self.color,
                        continuously: false
                    )
            },
            for: .primaryActionTriggered
        )

        swatchAndPreviewView.swatchView.onChanged = { [unowned self] _ in
            self.delegate?.colorPickerSwatchDidChanged(self)
        }

        swatchAndPreviewView.isHidden = !configuration.usesSwatchTool
        hairlineView.isHidden = !configuration.usesSwatchTool
        segmentControl.isHidden = configuration.colorPickers.count == 1

        segmentControl.selectedSegmentIndex = 0
        if let initialColorItems = configuration.initialColorItems {
            self.colorItems = initialColorItems
        }

        selectLatestUseOrInitialColorPicker()
        onUpdate(_color)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        switch (traitCollection.horizontalSizeClass, traitCollection.verticalSizeClass) {
        case (.compact, .compact):  // iPhone landscape
            colorPickersStackView.axis = .horizontal
            colorPickersStackView.distribution = .fillEqually
        default:
            colorPickersStackView.axis = .vertical
            colorPickersStackView.distribution = .fill
        }
    }

    func selectLatestUseOrInitialColorPicker() {
        let index = configuration.colorPickers.firstIndex(where: {
            $0.id == UserDefaults.standard.latestColorPickerID
        })
        segmentControl.selectedSegmentIndex = index ?? 0
        updateCurrentColorPicker()
    }

    func updateCurrentColorPicker() {
        let index = segmentControl.selectedSegmentIndex
        colorPickersStackView
            .arrangedSubviews
            .filter({ ($0 is ColorPicker) })
            .forEach({ $0.removeFromSuperview() })
        let colorPicker = configuration.colorPickers[index]
        colorPickersStackView.insertArrangedSubview(
            colorPicker,
            at: 0
        )
        UserDefaults.standard.latestColorPickerID = colorPicker.id
    }

    func onUpdate(_ color: HSVA) {
        swatchAndPreviewView.color = color
        alphaColorPicker.color = color
        configuration.colorPickers.forEach({ $0.color = color })
    }
}
