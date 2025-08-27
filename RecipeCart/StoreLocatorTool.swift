//
//  StoreLocatorTool.swift
//  RecipeCart
//
//  Created by Oscar De Moya on 2025/8/25.
//

import FoundationModels
import MapKit

struct StoreLocatorTool: Tool {
    let name = "storeLocator"
    let description = "Find grocery stores or food markets based on a given location."
    let location: CLLocationCoordinate2D
    
    @Generable
    struct Arguments {
    }
    
    func call(arguments: Arguments) async throws -> String {
        let items = try await pointsOfInterest(location: location, arguments: arguments)
        let results = items.prefix(3).compactMap { $0.name }
        return "Here are some nearby grocery stores locations where the user can buy the ingredients:\n" +
            results.enumerated().map { "\($0 + 1). \($1)" }.joined(separator: "\n")
    }
    
    func pointsOfInterest(location: CLLocationCoordinate2D, arguments: Arguments) async throws -> [MKMapItem] {
        let request = MKLocalSearch.Request()
        request.pointOfInterestFilter = .init(including: [.foodMarket, .store])
        request.naturalLanguageQuery = "grocery stores"
        request.region = MKCoordinateRegion(center: location, latitudinalMeters: 20_000, longitudinalMeters: 20_000)
        let search = MKLocalSearch(request: request)
        return try await search.start().mapItems
    }
}
