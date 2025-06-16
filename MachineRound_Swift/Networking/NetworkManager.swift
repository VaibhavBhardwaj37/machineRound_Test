import Foundation

enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError
    case serverError(String)
}

class NetworkManager {
    static let shared = NetworkManager()
    private let baseURL = "https://admin.38nguk.in/api"
    
    private init() {}
    
    func fetchSportsData() async throws -> [SportsAPI] {
        guard let url = URL(string: "\(baseURL)/get_all_sports_data") else {
            throw NetworkError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.serverError("Invalid server response")
        }

        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let response = try decoder.decode(SportsAPIResponseModel.self, from: data)
            return response.data ?? []
        } catch {
            throw NetworkError.decodingError
        }
    }

} 
struct SportsAPIResponseModel : Codable {
    let status : String?
    let statusCode : Int?
    let message : String?
    let count : Int?
    let data : [SportsAPI]?

    enum CodingKeys: String, CodingKey {

        case status = "status"
        case statusCode = "statusCode"
        case message = "message"
        case count = "count"
        case data = "data"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        status = try values.decodeIfPresent(String.self, forKey: .status)
        statusCode = try values.decodeIfPresent(Int.self, forKey: .statusCode)
        message = try values.decodeIfPresent(String.self, forKey: .message)
        count = try values.decodeIfPresent(Int.self, forKey: .count)
        data = try values.decodeIfPresent([SportsAPI].self, forKey: .data)
    }

}
struct SportsAPI : Codable {
    let id : Int?
    let sport_id : Int?
    let nsrs_sport_id : Int?
    let sport_name : String?
    let start_date : String?
    let end_date : String?
    let cluster_name : String?
    let venue_name : String?
    let status : String?
    let rf_sport_db_name : String?
    let sport_image_url : String?
    let sport_icon_url : String?
    let mascot_image_url : String?

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case sport_id = "sport_id"
        case nsrs_sport_id = "nsrs_sport_id"
        case sport_name = "sport_name"
        case start_date = "start_date"
        case end_date = "end_date"
        case cluster_name = "cluster_name"
        case venue_name = "venue_name"
        case status = "status"
        case rf_sport_db_name = "rf_sport_db_name"
        case sport_image_url = "sport_image_url"
        case sport_icon_url = "sport_icon_url"
        case mascot_image_url = "mascot_image_url"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(Int.self, forKey: .id)
        sport_id = try values.decodeIfPresent(Int.self, forKey: .sport_id)
        nsrs_sport_id = try values.decodeIfPresent(Int.self, forKey: .nsrs_sport_id)
        sport_name = try values.decodeIfPresent(String.self, forKey: .sport_name)
        start_date = try values.decodeIfPresent(String.self, forKey: .start_date)
        end_date = try values.decodeIfPresent(String.self, forKey: .end_date)
        cluster_name = try values.decodeIfPresent(String.self, forKey: .cluster_name)
        venue_name = try values.decodeIfPresent(String.self, forKey: .venue_name)
        status = try values.decodeIfPresent(String.self, forKey: .status)
        rf_sport_db_name = try values.decodeIfPresent(String.self, forKey: .rf_sport_db_name)
        sport_image_url = try values.decodeIfPresent(String.self, forKey: .sport_image_url)
        sport_icon_url = try values.decodeIfPresent(String.self, forKey: .sport_icon_url)
        mascot_image_url = try values.decodeIfPresent(String.self, forKey: .mascot_image_url)
    }
    
    init(id: Int?, sport_id: Int?, nsrs_sport_id: Int?, sport_name: String?, start_date: String?, end_date: String?, cluster_name: String?, venue_name: String?, status: String?, rf_sport_db_name: String?, sport_image_url: String?, sport_icon_url: String?, mascot_image_url: String?) {
        self.id = id
        self.sport_id = sport_id
        self.nsrs_sport_id = nsrs_sport_id
        self.sport_name = sport_name
        self.start_date = start_date
        self.end_date = end_date
        self.cluster_name = cluster_name
        self.venue_name = venue_name
        self.status = status
        self.rf_sport_db_name = rf_sport_db_name
        self.sport_image_url = sport_image_url
        self.sport_icon_url = sport_icon_url
        self.mascot_image_url = mascot_image_url
    }
}
