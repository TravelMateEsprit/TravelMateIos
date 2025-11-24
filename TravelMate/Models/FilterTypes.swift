import Foundation

// MARK: - Sort Option
enum SortOption: String, CaseIterable {
    case dateAscending = "Date croissante"
    case dateDescending = "Date décroissante"
    case priceAscending = "Prix croissant"
    case priceDescending = "Prix décroissant"
}

// MARK: - Filter Delegate
protocol FilterViewControllerDelegate: AnyObject {
    func didApplyFilters(sortOption: SortOption, typeFilter: String?, minPrice: Double?, maxPrice: Double?)
}
