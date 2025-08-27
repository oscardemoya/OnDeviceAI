//
//  PromptPlayground.swift
//  RecipeCart
//
//  Created by Oscar De Moya on 2025/8/25.
//

import Playgrounds
import FoundationModels
import Foundation

#Playground {
    let session = LanguageModelSession()
    let response = try await session.respond(to: "Write some tasks for an iOS app project for keep track of daily habits.")
    print(response.content)
}
