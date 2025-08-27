//
//  RecipeView.swift
//  RecipeCart
//
//  Created by Oscar De Moya on 2025/8/25.
//

import SwiftUI
import FoundationModels
import MapKit
import OSLog

struct RecipeView: View {
    @State private var generator: RecipeGenerator?
    @State private var prompt: String = ""
    @State private var locationManager = LocationManager()
    @State private var isGenerating: Bool = false
    @State private var isAnimating: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .center, spacing: 16) {
                PromptInputView(prompt: $prompt) {
                    Task {
                        do {
                            isGenerating = true
                            try await generator?.generateRecipe(from: prompt)
                            isGenerating = false
                        } catch {
                            logger.error("Error generating recipe: \(error.localizedDescription)")
                            isGenerating = false
                        }
                    }
                }
                .disabled(isGenerating)
                if let recipe = generator?.recipe {
                    VStack(spacing: 16) {
                        RecipeHeader(recipe: recipe)
                        if let ingredients = recipe.ingredients {
                            IngredientList(ingredients: ingredients)
                        }
                    }
                    .animation(.easeInOut, value: recipe.id)
                } else if isGenerating {
                    Label("Generating...", systemImage: "sparkle.magnifyingglass")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(.secondary)
                        .padding()
                        .background(.thickMaterial)
                        .cornerRadius(16, antialiased: true)
                        .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 2)
                        .transition(.opacity)
                        .background {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(
                                    AngularGradient(colors: [.blue, .purple, .pink, .orange, .yellow, .green, .blue], center: .center, angle: .degrees(isAnimating ? 360 : 0))
                                )
                                .padding(4)
                                .blur(radius: 16)
                        }
                        .onAppear {
                            withAnimation(.linear(duration: 5).repeatForever(autoreverses: false)) {
                                isAnimating = true
                            }
                        }
                        .padding(.horizontal)
                }
                Spacer()
            }
            .navigationTitle("Ingredients List")
            .edgesIgnoringSafeArea(.bottom)
        }
        .onAppear {
            locationManager.startUpdatingLocation()
        }
        .onDisappear {
            locationManager.stopUpdatingLocation()
        }
        .onChange(of: locationManager.location) { _, newValue in
            locationManager.stopUpdatingLocation()
            guard let location = locationManager.location else {
                logger.error("Error: Could not get user's location")
                return
            }
            logger.debug("User's location: \(location.latitude), \(location.longitude)")
            generator = RecipeGenerator(location: location)
            generator?.session.prewarm()
            logger.info("Prewarmed language model session")
        }
    }
}

struct PromptInputView: View {
    @Binding var prompt: String
    let action: @MainActor () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            TextField("Enter a recipe name", text: $prompt)
                .textFieldStyle(.plain)
                .frame(height: 44)
                .padding(EdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(lineWidth: 1.0)
                        .foregroundColor(Color.gray.opacity(0.3))
                )
            Button(action: action) {
                HStack {
                    Image(systemName: "wand.and.stars")
                    Text("Generate")
                }
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.roundedRectangle)
            .controlSize(.extraLarge)
        }
        .padding(.horizontal)
    }
}

struct RecipeHeader: View {
    let recipe: Recipe.PartiallyGenerated
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                if let name = recipe.name {
                    Text(name)
                        .contentTransition(.opacity)
                        .font(.title2)
                        .fontWeight(.bold)
                }
                Spacer()
                if let estimatedTime = recipe.estimatedTime {
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .contentTransition(.opacity)
                            .foregroundColor(.orange)
                        Text(estimatedTime)
                            .contentTransition(.opacity)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            Group {
                if let description = recipe.description {
                    Text(description)
                }
                if let storesNearby = recipe.storesNearby {
                    Text(storesNearby)
                }
                if let restaurantsNearby = recipe.restaurantsNearby {
                    Text(restaurantsNearby)
                }
            }
            .contentTransition(.opacity)
            .font(.subheadline)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.leading)
        }
        .padding()
        .background(.background)
        .cornerRadius(16, antialiased: true)
        .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 2)
        .padding(.horizontal)
    }
}

struct IngredientList: View {
    let ingredients: [Ingredient].PartiallyGenerated
    @State private var boughtIngredients: Set<GenerationID> = []
    
    var body: some View {
        if !ingredients.contains(where: { !boughtIngredients.contains($0.id) }) {
            ContentUnavailableView {
                Label("All ingredients bought!", systemImage: "fork.knife.circle.fill")
                    .font(.title2)
                    .fontWeight(.bold)
            } description: {
                Text("Enjoy your meal!")
            } actions: {
                Button("Reset") {
                    withAnimation {
                        boughtIngredients.removeAll()
                    }
                }
                .buttonStyle(.glassProminent)
                .tint(.accentColor)
            }
        } else {
            List {
                ForEach(ingredients) { ingredient in
                    IngredientRowView(
                        ingredient: ingredient,
                        bought: boughtIngredients.contains(ingredient.id)
                    ) { isBought in
                        withAnimation {
                            if isBought {
                                boughtIngredients.insert(ingredient.id)
                            } else {
                                boughtIngredients.remove(ingredient.id)
                            }
                        }
                    }
                    .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
                    .transition(.blurReplace)
                }
            }
            .listStyle(.plain)
        }
    }
}

struct IngredientRowView: View {
    let ingredient: Ingredient.PartiallyGenerated
    var bought: Bool
    var onBoughtChanged: (Bool) -> Void
    
    var body: some View {
        HStack {
            Button(action: {
                onBoughtChanged(!bought)
            }) {
                Image(systemName: bought ? "checkmark.square.fill" : "square")
                    .foregroundColor(bought ? .green : .gray)
                    .font(.title2)
            }
            .buttonStyle(.plain)
            
            if let name = ingredient.name {
                Text(name)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            Spacer(minLength: 12)
            if let quantity = ingredient.quantity, let unit = ingredient.unit {
                Text("\(quantity, specifier: "%g") \(unit.rawValue)")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .frame(alignment: .trailing)
                    .multilineTextAlignment(.trailing)
            }
        }
        .contentShape(.rect)
        .onTapGesture {
            onBoughtChanged(!bought)
        }
        .padding()
    }
}

#Preview("Recipe View") {
    RecipeView()
}
