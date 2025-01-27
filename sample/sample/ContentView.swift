//
//  ContentView.swift
//  sample
//
//  Created by 郑瑞阳 on 1/26/25.
//

import SwiftUI

struct ContentView: View {
    let url =  "https://d3jbb8n5wk0qxi.cloudfront.net/recipes.json"
    @State private var jsonData: Data? = nil
    @State private var decodedData: Recipes?
    @State private var last_seen = 0
    @State private var zoom_in_toggle = false
    @State private var zoom_in_picture: String?
    
    
    var dataCount: Int {
        decodedData?.recipes.count ?? 0
    }
    
    @State var max: Int = 0
    
    var body: some View {
        ZStack {
            if dataCount == 0 {
                Text("No recipes are available")
            } else {
                VStack {
                    ScrollView(.vertical) {
                        ForEach(0..<max, id: \.self) { index in
                            if let recipe = decodedData?.recipes[index] {
                                ZStack {
                                    Rectangle()
                                        .frame(width: .infinity, height:100)
                                        .foregroundColor(.gray.opacity(0.3))
                                    HStack {
                                        AsyncImage(url: URL(string: recipe.photo_url_small!)) { phase in
                                            switch phase {
                                            case .success(let image):
                                                image
                                                    .resizable()
                                                    .scaledToFit()
                                            case .failure(_):
                                                Image(systemName: "photo.fill")
                                                    .foregroundColor(.gray)
                                                    .scaledToFit()
                                            default:
                                                ProgressView()
                                            }
                                        }.onTapGesture {
                                            zoom_in_toggle = true
                                            zoom_in_picture = recipe.photo_url_large
                                        }
                                        Spacer()
                                        VStack {
                                            HStack {
                                                Spacer()
                                                Text(recipe.cuisine + " " + recipe.name)
                                                    .foregroundColor(.red)
                                                    .multilineTextAlignment(.trailing)
                                                    .onTapGesture {
                                                        if recipe.source_url != nil {
                                                            guard let url = URL(string: recipe.source_url!) else { return }
                                                            UIApplication.shared.open(url)
                                                        }
                                                    }
                                            }
                                            if recipe.youtube_url != nil {
                                                HStack {
                                                    Spacer()
                                                    Text("Youtube Link")
                                                        .foregroundColor(.blue)
                                                        .multilineTextAlignment(.trailing)
                                                        .underline()
                                                        .onTapGesture {
                                                            guard let url = URL(string: recipe.youtube_url!) else { return }
                                                            UIApplication.shared.open(url)
                                                        }
                                                }
                                            }
                                        }
                                        .font(.title3)
                                    }
                                }
                                .frame(width: .infinity, height:100)
                                .padding()
                                
                            }
                        }
                    }
                    
                    .frame(height:500)
                    Text("More")
                        .frame(width: 100, height: 50)
                        .background(.gray)
                        .onTapGesture {
                            max = min(max + 10, dataCount)
                        }
                        .padding()
                }
                if zoom_in_toggle {
                    ZStack {
                        Color.gray
                            .opacity(zoom_in_toggle ? 0.7 : 0)
                            .ignoresSafeArea()
                            .onTapGesture {
                                zoom_in_toggle = false
                                zoom_in_picture = nil
                            }
                        VStack {
                            if zoom_in_picture != nil {
                                
                                AsyncImage(url: URL(string: zoom_in_picture!)) { phase in
                                    switch phase {
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFit()
                                    case .failure(_):
                                        Image(systemName: "photo.fill")
                                            .foregroundColor(.gray)
                                            .scaledToFit()
                                    default:
                                        ProgressView()
                                    }
                                }.onTapGesture {
                                    zoom_in_toggle = false
                                    zoom_in_picture = nil
                                }
                            } else {
                                Image(systemName: "photo.fill")
                                    .foregroundColor(.gray)
                                    .scaledToFit()
                                    .onTapGesture {
                                        zoom_in_toggle = false
                                        zoom_in_picture = nil
                                    }
                            }
                        }
                        .opacity(zoom_in_toggle ? 1 : 0)
                        .padding()
                    }
                }
            }
        }
        .onAppear {
            Task {
                do {
                    try await fetchData(url: url)
                } catch {
                    print("Error loading JSON: \(error.localizedDescription)")
                }
            }
        }
    }
    
    
    func fetchData(url: String) async throws {
        guard let url = URL(string: url) else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        self.jsonData = data
        self.decodedData = try JSONDecoder().decode(Recipes.self, from: self.jsonData!)
        self.max = self.decodedData == nil ? 0 : min(10, self.decodedData!.recipes.count)
    }
}

#Preview {
    ContentView()
}
