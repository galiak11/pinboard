import UIKit

enum WaterfallLayout {
    static let columnCount = 2
    static let interItemSpacing: CGFloat = 8
    static let sectionInset: CGFloat = 8
    static let textAreaHeight: CGFloat = 70

    /// Creates a waterfall-style compositional layout.
    /// The `heightProvider` closure returns the aspect ratio (height/width) for a given index.
    static func makeLayout(
        heightProvider: @escaping (Int) -> CGFloat
    ) -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout { sectionIndex, environment in
            let containerWidth = environment.container.effectiveContentSize.width
            let itemWidth = (containerWidth - sectionInset * 2 - interItemSpacing) / CGFloat(columnCount)

            let group = NSCollectionLayoutGroup.custom(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .estimated(300)
                )
            ) { environment in
                var items: [NSCollectionLayoutGroupCustomItem] = []
                let totalWidth = environment.container.effectiveContentSize.width
                let columnWidth = (totalWidth - sectionInset * 2 - interItemSpacing) / CGFloat(columnCount)

                // Track the bottom Y position of each column
                var columnHeights = [CGFloat](repeating: 0, count: columnCount)

                let itemCount = environment.container.effectiveContentSize.height > 0
                    ? Int(environment.container.effectiveContentSize.height / 100)
                    : 20

                for index in 0..<itemCount {
                    // Place in shortest column
                    let shortestColumn = columnHeights.enumerated()
                        .min(by: { $0.element < $1.element })?.offset ?? 0

                    let x = sectionInset + CGFloat(shortestColumn) * (columnWidth + interItemSpacing)
                    let y = columnHeights[shortestColumn]

                    let aspectRatio = heightProvider(index)
                    let imageHeight = columnWidth * aspectRatio
                    let totalHeight = imageHeight + textAreaHeight

                    let frame = CGRect(x: x, y: y, width: columnWidth, height: totalHeight)
                    items.append(NSCollectionLayoutGroupCustomItem(frame: frame))

                    columnHeights[shortestColumn] = y + totalHeight + interItemSpacing
                }

                return items
            }

            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(
                top: sectionInset, leading: 0, bottom: sectionInset, trailing: 0
            )

            // Footer for loading spinner
            let footerSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(50)
            )
            let footer = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: footerSize,
                elementKind: UICollectionView.elementKindSectionFooter,
                alignment: .bottom
            )
            section.boundarySupplementaryItems = [footer]

            return section
        }
    }
}
