import Foundation

struct InsuranceSearchFilters {
    var search: String?
    var minPrice: Double?
    var maxPrice: Double?
    var duration: String?
    var minRating: Int?
    var coverage: [String]?
    var sortBy: String?
    var sortOrder: String?
    
    func toQueryItems() -> [URLQueryItem] {
        var items: [URLQueryItem] = []
        
        if let search = search, !search.isEmpty {
            items.append(URLQueryItem(name: "search", value: search))
        }
        
        if let minPrice = minPrice {
            items.append(URLQueryItem(name: "minPrice", value: String(minPrice)))
        }
        
        if let maxPrice = maxPrice {
            items.append(URLQueryItem(name: "maxPrice", value: String(maxPrice)))
        }
        
        if let duration = duration, !duration.isEmpty {
            items.append(URLQueryItem(name: "duration", value: duration))
        }
        
        if let minRating = minRating {
            items.append(URLQueryItem(name: "minRating", value: String(minRating)))
        }
        
        if let coverage = coverage, !coverage.isEmpty {
            items.append(URLQueryItem(name: "coverage", value: coverage.joined(separator: ",")))
        }
        
        if let sortBy = sortBy, !sortBy.isEmpty {
            items.append(URLQueryItem(name: "sortBy", value: sortBy))
        }
        
        if let sortOrder = sortOrder, !sortOrder.isEmpty {
            items.append(URLQueryItem(name: "sortOrder", value: sortOrder))
        }
        
        return items
    }
}
