//
//  RestaurantLocatorTool.swift
//  RecipeCart
//
//  Created by Oscar De Moya on 2025/8/26.
//

import FoundationModels
import MapKit

struct RestaurantLocatorTool: Tool {
    let name = "restaurantLocator"
    let description = "Find restaurants, bakeries, and cafes, based on a given location."
    let location: CLLocationCoordinate2D
    
    @Generable
    struct Arguments {
        @Guide(description: "The input name of the meal to search for restaurants.")
        let meal: String
    }
    
    func call(arguments: Arguments) async throws -> String {
        let items = try await pointsOfInterest(location: location, arguments: arguments)
        let results = items.prefix(3).compactMap { $0.name }
        return "Feeling lazy? Here are some nearby restaurants where the user can eat what you're planning to cook:\n" +
            results.enumerated().map { "\($0 + 1). \($1)" }.joined(separator: "\n")
    }
    
    func pointsOfInterest(location: CLLocationCoordinate2D, arguments: Arguments) async throws -> [MKMapItem] {
        let request = MKLocalSearch.Request()
        request.pointOfInterestFilter = .init(including: [.restaurant, .bakery, .cafe])
        request.naturalLanguageQuery = arguments.meal
        request.region = MKCoordinateRegion(center: location, latitudinalMeters: 20_000, longitudinalMeters: 20_000)
        let search = MKLocalSearch(request: request)
        return try await search.start().mapItems
    }
}
