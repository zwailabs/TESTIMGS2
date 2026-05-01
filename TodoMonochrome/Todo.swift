import Foundation

enum TodoSection: String, Codable, CaseIterable, Identifiable {
	case morning
	case workload
	case night

	var id: String { rawValue }

	var title: String {
		switch self {
		case .morning: return "Morning"
		case .workload: return "Workload"
		case .night: return "Night"
		}
	}
}

struct Todo: Identifiable, Codable, Equatable {
	let id: UUID
	var title: String
	var isDone: Bool
	var section: TodoSection
	var isPending: Bool
	var emoji: String?
	var scheduledDate: Date
	let createdAt: Date

	init(
		id: UUID = UUID(),
		title: String,
		isDone: Bool = false,
		section: TodoSection = .workload,
		isPending: Bool = false,
		emoji: String? = nil,
		scheduledDate: Date = Date(),
		createdAt: Date = Date()
	) {
		self.id = id
		self.title = title
		self.isDone = isDone
		self.section = section
		self.isPending = isPending
		self.emoji = emoji
		self.scheduledDate = scheduledDate
		self.createdAt = createdAt
	}

	enum CodingKeys: String, CodingKey {
		case id
		case title
		case isDone
		case section
		case isPending
		case emoji
		case scheduledDate
		case createdAt
	}

	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		let decodedId = try container.decodeIfPresent(UUID.self, forKey: .id)
		let decodedTitle = try container.decodeIfPresent(String.self, forKey: .title)

		let decodedCreatedAt = try container.decodeIfPresent(Date.self, forKey: .createdAt) ?? Date()
		let decodedScheduledDate = try container.decodeIfPresent(Date.self, forKey: .scheduledDate) ?? decodedCreatedAt

		self.id = decodedId ?? UUID()
		self.title = decodedTitle ?? ""
		self.isDone = try container.decodeIfPresent(Bool.self, forKey: .isDone) ?? false
		self.section = try container.decodeIfPresent(TodoSection.self, forKey: .section) ?? .workload
		self.isPending = try container.decodeIfPresent(Bool.self, forKey: .isPending) ?? false
		self.emoji = try container.decodeIfPresent(String.self, forKey: .emoji)
		self.scheduledDate = decodedScheduledDate
		self.createdAt = decodedCreatedAt
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(id, forKey: .id)
		try container.encode(title, forKey: .title)
		try container.encode(isDone, forKey: .isDone)
		try container.encode(section, forKey: .section)
		try container.encode(isPending, forKey: .isPending)
		try container.encodeIfPresent(emoji, forKey: .emoji)
		try container.encode(scheduledDate, forKey: .scheduledDate)
		try container.encode(createdAt, forKey: .createdAt)
	}
}
