import Foundation
import SwiftUI

@MainActor
final class TodoStore: ObservableObject {
	@Published private(set) var todos: [Todo] = []

	init() {
		todos = TodoStorage.load()
		if todos.isEmpty, !TodoStorage.hasSavedTodos() {
			todos = TodoStore.makeSampleTodos()
			save()
		}
	}

	var remainingCount: Int {
		todos.filter { !$0.isDone }.count
	}

	func add(
		title: String,
		section: TodoSection = .workload,
		scheduledDate: Date = Date(),
		emoji: String? = nil,
		isPending: Bool = false
	) {
		let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
		guard !trimmed.isEmpty else { return }
		todos.insert(
			Todo(
				title: trimmed,
				section: section,
				isPending: isPending,
				emoji: emoji,
				scheduledDate: scheduledDate
			),
			at: 0
		)
		save()
	}

	func toggle(_ todo: Todo) {
		guard let index = todos.firstIndex(where: { $0.id == todo.id }) else { return }
		todos[index].isDone.toggle()
		if todos[index].isDone {
			todos[index].isPending = false
		}
		save()
	}

	func delete(_ todo: Todo) {
		todos.removeAll { $0.id == todo.id }
		save()
	}

	func clearCompleted() {
		todos.removeAll { $0.isDone }
		save()
	}

	private func load() {
		todos = TodoStorage.load()
	}

	private func save() {
		TodoStorage.save(todos)
	}
}

private extension TodoStore {
	static func makeSampleTodos() -> [Todo] {
		let calendar = Calendar.current
		let today = calendar.startOfDay(for: Date())

		return [
			Todo(title: "Wake up on time", section: .morning, emoji: "⏰", scheduledDate: today),
			Todo(title: "Gym / workout", section: .morning, emoji: "🏋️", scheduledDate: today),
			Todo(title: "Polish UI / components", section: .workload, emoji: "🧩", scheduledDate: today),
			Todo(title: "Share updates with team / client", section: .workload, emoji: "📨", scheduledDate: today),
			Todo(title: "Improve portfolio or case study", section: .workload, emoji: "📁", scheduledDate: today),
			Todo(title: "Plan tomorrow’s top task", section: .night, emoji: "🗓️", scheduledDate: today),
			Todo(title: "No phone 30 mins before sleep", section: .night, emoji: "⛔️", scheduledDate: today)
		]
	}
}
