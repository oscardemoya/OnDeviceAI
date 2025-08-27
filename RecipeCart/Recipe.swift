//
//  Recipe.swift
//  RecipeCart
//
//  Created by Oscar De Moya on 2025/8/25.
//

import Foundation
import FoundationModels

@Generable
struct Recipe: Identifiable {
    let id = UUID()
    let name: String
    let estimatedTime: String
    @Guide(description: "Describe the recipe in a few sentences with exiting keywords.")
    let description: String
    @Guide(description: "Grocery stores or markets where to buy the ingredients for this recipe near user's location.")
    let storesNearby: String
    @Guide(description: "Restaurants, bakeries, or cafes where you can enjoy this recipe near user's location.")
    let restaurantsNearby: String
    var ingredients: [Ingredient]
}

@Generable
struct Ingredient {
    let name: String
    let quantity: Double
    let unit: IngredientUnit
    var bought: Bool = false
}

@Generable
enum IngredientUnit: String, CaseIterable {
    case grams = "g"
    case kilograms = "kg"
    case milliliters = "ml"
    case liters = "L"
    case pieces = "pcs"
    case cups = "cups"
    case tablespoons = "tbsp"
    case teaspoons = "tsp"
    case slices = "slices"
    case units = "unit"
    case none = ""
}

extension Recipe {
    static let sample = Recipe(
        name: "Classic Pancakes",
        estimatedTime: "25 min",
        description: "Fluffy, golden pancakes perfect for a weekend breakfast. Serve with honey, butter, or your favorite toppings.",
        storesNearby: "You can find the ingredients for this recipe at nearby grocery stores such as Walmart, Kroger, or Safeway.",
        restaurantsNearby: "Enjoy delicious pancakes at local cafes like IHOP, Denny's, and other nearby eateries.",
        ingredients: [
            Ingredient(name: "All-purpose flour", quantity: 200, unit: .grams),
            Ingredient(name: "Milk", quantity: 300, unit: .milliliters),
            Ingredient(name: "Eggs", quantity: 2, unit: .pieces),
            Ingredient(name: "Baking powder", quantity: 2, unit: .teaspoons),
            Ingredient(name: "Salt", quantity: 0.5, unit: .teaspoons),
            Ingredient(name: "Sugar", quantity: 2, unit: .tablespoons),
            Ingredient(name: "Butter (melted)", quantity: 30, unit: .grams)
        ]
    )
}
