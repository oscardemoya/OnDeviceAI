//
//  RecipeGenerator.swift
//  RecipeCart
//
//  Created by Oscar De Moya on 2025/8/25.
//

import FoundationModels
import Observation
import MapKit

@Observable
@MainActor
final class RecipeGenerator {
    private(set) var recipe: Recipe.PartiallyGenerated?
    let session: LanguageModelSession
    
    init(location: CLLocationCoordinate2D) {
        let storeLocator = StoreLocatorTool(location: location)
        let restaurantLocator = RestaurantLocatorTool(location: location)
        self.session = LanguageModelSession(tools: [storeLocator, restaurantLocator]) {
            "Your job is to generate a detailed recipe based on the user's input."
            "Use the storeLocator tool to find grocery stores or markets where the user can find the ingredients."
            "Use the restaurantLocator tool to find restaurants where the user can eat the meal."
            "Here is an example of a recipe:"
            Recipe.sample
        }
    }
    
    func generateRecipe(from meal: String) async throws {
        recipe = nil
        let stream = session.streamResponse(generating: Recipe.self) {
            """
            Generate a recipe for the following meal name: \(meal)
            Make sure you always use the tools provided to get accurate and relevant information about locations.
            The recipe should include a name, a brief description, an estimated time to prepare,
            suggestions for grocery stores to buy the ingredients, restaurants where the user can eat the meal,
            and a list of ingredients with their quantities and units.
            """
        }
        for try await partialRecipe in stream {
            recipe = partialRecipe.content
        }
    }
}
