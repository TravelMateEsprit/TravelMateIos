import Foundation

enum SortOption: String, CaseIterable {
    case dateAscending = "Date (earliest first)"
    case dateDescending = "Date (latest first)"
    case priceLowToHigh = "Price (low to high)"
    case priceHighToLow = "Price (high to low)"
    case destinationAZ = "Destination (A-Z)"
    case destinationZA = "Destination (Z-A)"
}

protocol FilterViewControllerDelegate: AnyObject {
    func didApplyFilters(sortOption: SortOption,
                        typeFilter: String?,
                        minPrice: Double?,
                        maxPrice: Double?)
}
