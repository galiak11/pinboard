import UIKit

/// Custom waterfall layout for UICollectionView
final class WaterfallLayout: UICollectionViewLayout {

    // MARK: - Configuration

    static let columnCount = 2
    static let interItemSpacing: CGFloat = 8
    static let sectionInset: CGFloat = 8
    static let textAreaHeight: CGFloat = 70

    weak var delegate: WaterfallLayoutDelegate?

    private var cache: [UICollectionViewLayoutAttributes] = []
    private var footerAttributes: UICollectionViewLayoutAttributes?
    private var contentHeight: CGFloat = 0

    private var contentWidth: CGFloat {
        guard let collectionView = collectionView else { return 0 }
        let insets = collectionView.contentInset
        return collectionView.bounds.width - (insets.left + insets.right)
    }

    override var collectionViewContentSize: CGSize {
        CGSize(width: contentWidth, height: contentHeight)
    }

    // MARK: - Layout

    override func prepare() {
        guard let collectionView = collectionView,
              cache.isEmpty else { return }

        // Guard against no sections (data source not set up yet)
        guard collectionView.numberOfSections > 0 else { return }

        let columnWidth = (contentWidth - Self.sectionInset * 2 - Self.interItemSpacing) / CGFloat(Self.columnCount)
        var xOffset: [CGFloat] = []
        for column in 0..<Self.columnCount {
            xOffset.append(Self.sectionInset + CGFloat(column) * (columnWidth + Self.interItemSpacing))
        }

        var column = 0
        var yOffset: [CGFloat] = Array(repeating: Self.sectionInset, count: Self.columnCount)

        // Layout items
        for item in 0..<collectionView.numberOfItems(inSection: 0) {
            let indexPath = IndexPath(item: item, section: 0)

            let aspectRatio = delegate?.collectionView(collectionView, aspectRatioForItemAt: indexPath) ?? 1.0
            let imageHeight = columnWidth * aspectRatio
            let cellHeight = imageHeight + Self.textAreaHeight

            let frame = CGRect(
                x: xOffset[column],
                y: yOffset[column],
                width: columnWidth,
                height: cellHeight
            )

            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = frame
            cache.append(attributes)

            contentHeight = max(contentHeight, frame.maxY)
            yOffset[column] = yOffset[column] + cellHeight + Self.interItemSpacing

            column = column < (Self.columnCount - 1) ? (column + 1) : 0
        }

        // Layout footer
        contentHeight += Self.sectionInset
        let footerIndexPath = IndexPath(item: 0, section: 0)
        let footerFrame = CGRect(
            x: 0,
            y: contentHeight,
            width: contentWidth,
            height: 50
        )
        let footerAttrs = UICollectionViewLayoutAttributes(
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
            with: footerIndexPath
        )
        footerAttrs.frame = footerFrame
        footerAttributes = footerAttrs
        contentHeight = footerFrame.maxY
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var visibleLayoutAttributes: [UICollectionViewLayoutAttributes] = []

        for attributes in cache {
            if attributes.frame.intersects(rect) {
                visibleLayoutAttributes.append(attributes)
            }
        }

        if let footerAttributes = footerAttributes, footerAttributes.frame.intersects(rect) {
            visibleLayoutAttributes.append(footerAttributes)
        }

        return visibleLayoutAttributes
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache[safe: indexPath.item]
    }

    override func layoutAttributesForSupplementaryView(
        ofKind elementKind: String,
        at indexPath: IndexPath
    ) -> UICollectionViewLayoutAttributes? {
        return elementKind == UICollectionView.elementKindSectionFooter ? footerAttributes : nil
    }

    override func invalidateLayout() {
        super.invalidateLayout()
        cache.removeAll()
        footerAttributes = nil
        contentHeight = 0
    }
}

// MARK: - Delegate Protocol

protocol WaterfallLayoutDelegate: AnyObject {
    func collectionView(_ collectionView: UICollectionView, aspectRatioForItemAt indexPath: IndexPath) -> CGFloat
}

// MARK: - Array Extension

private extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
