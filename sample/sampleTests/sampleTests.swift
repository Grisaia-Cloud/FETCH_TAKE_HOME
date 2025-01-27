//
//  sampleTests.swift
//  sampleTests
//
//  Created by 郑瑞阳 on 1/26/25.
//

import XCTest
@testable import sample

final class sampleTests: XCTestCase {

    func good_data() {
        let viewModel = ContentView()
        let url = "https://d3jbb8n5wk0qxi.cloudfront.net/recipes.json"
        XCTAssertNoThrow(
            Task {
                try await viewModel.fetchData(url: url)
            }
        )
    }
    
    func malformed_data() {
        let viewModel = ContentView()
        let url = "https://d3jbb8n5wk0qxi.cloudfront.net/recipes-malformed.json"
        XCTAssertThrowsError(
            Task {
                try await viewModel.fetchData(url: url)
            }
        ) { error in
            guard let urlError = error as? URLError else {
                XCTFail("Expected URLError, but got \(error)")
                return
            }
            XCTAssertEqual(urlError.code, .badServerResponse)
        }
    }
    
    func empty_data() {
        let viewModel = ContentView()
        let url = "https://d3jbb8n5wk0qxi.cloudfront.net/recipes-empty.json"
        XCTAssertThrowsError(
            Task {
                try await viewModel.fetchData(url: url)
            }
        ) { error in
            guard let urlError = error as? URLError else {
                XCTFail("Expected URLError, but got \(error)")
                return
            }
            XCTAssertEqual(urlError.code, .badServerResponse)
        }
    }
    
    func bad_url() {
        let viewModel = ContentView()
        let url = "1"
        XCTAssertThrowsError(
            Task {
                try await viewModel.fetchData(url: url)
            }
        ) { error in
            guard let urlError = error as? URLError else {
                XCTFail("Expected URLError, but got \(error)")
                return
            }
            XCTAssertEqual(urlError.code, .badURL)
        }
    }
    

}
