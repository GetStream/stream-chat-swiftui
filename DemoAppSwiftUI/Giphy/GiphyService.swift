//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Foundation

/// Minimal Giphy API client for the demo GIF grid.
/// Get a free API key at https://developers.giphy.com/dashboard/ and set it below (or use the deprecated beta key for basic testing).
enum GiphyService {
    /// Replace with your own key from https://developers.giphy.com/dashboard/ — the old public beta key may return 403.
    static let apiKey = ""

    struct SearchResponse: Decodable {
        let data: [GiphyItem]?
    }

    struct GiphyItem: Decodable {
        let id: String
        let title: String?
        let images: Images?

        struct Images: Decodable {
            let fixedHeight: ImageInfo?
            let fixedHeightSmall: ImageInfo?
            let downsized: ImageInfo?
            enum CodingKeys: String, CodingKey {
                case fixedHeight = "fixed_height"
                case fixedHeightSmall = "fixed_height_small"
                case downsized
            }
        }

        struct ImageInfo: Decodable {
            let url: URL?
            let width: String?
            let height: String?
        }

        var previewURL: URL? {
            images?.fixedHeightSmall?.url ?? images?.fixedHeight?.url ?? images?.downsized?.url
        }

        var fullURL: URL? {
            images?.fixedHeight?.url ?? images?.downsized?.url
        }
    }

    static func search(query: String, limit: Int = 24) async throws -> [GiphyItem] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        let useTrending = q.isEmpty || q.lowercased() == "trending"
        let path = useTrending ? "/v1/gifs/trending" : "/v1/gifs/search"
        var components = URLComponents(string: "https://api.giphy.com")!
        components.path = path
        components.queryItems = [
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "limit", value: String(limit))
        ]
        if !useTrending {
            components.queryItems?.append(URLQueryItem(name: "q", value: q))
        }
        guard let url = components.url else { return [] }
        let (data, response) = try await URLSession.shared.data(from: url)
        if let http = response as? HTTPURLResponse, http.statusCode != 200 {
            throw NSError(domain: "GiphyService", code: http.statusCode, userInfo: [NSLocalizedDescriptionKey: "HTTP \(http.statusCode)"])
        }
        let decoded = try JSONDecoder().decode(SearchResponse.self, from: data)
        return decoded.data ?? []
    }
}
