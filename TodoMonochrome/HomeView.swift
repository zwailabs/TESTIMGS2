import SwiftUI

enum TodoFilter: String, CaseIterable, Identifiable {
	case todo = "To do"
	case completed = "Completed"
	case pending = "Pending"

	var id: String { rawValue }

	var systemImage: String {
		switch self {
		case .todo: return "sparkles"
		case .completed: return "checkmark"
		case .pending: return "clock"
		}
	}
}

struct HomeView: View {
	@ObservedObject var store: TodoStore

	@Binding var selectedDate: Date
	@State private var filter: TodoFilter = .todo
	@State private var collapsed: Set<TodoSection> = []

	var body: some View {
		ScrollView(showsIndicators: false) {
			VStack(spacing: 14) {
				header
					.padding(.top, 6)

				DateStripCard(selectedDate: $selectedDate)

				TodoCard(
					filter: $filter,
					collapsed: $collapsed,
					todos: visibleTodos
				) { todo in
					withAnimation(.spring(response: 0.30, dampingFraction: 0.9)) {
						store.toggle(todo)
					}
				}
			}
			.padding(.horizontal, 18)
			.padding(.bottom, 96)
		}
	}

	private var header: some View {
		HStack(alignment: .top) {
			VStack(alignment: .leading, spacing: 4) {
				Text("Hey, Karthik 👋")
					.font(.system(size: 28, weight: .semibold, design: .rounded))
					.foregroundStyle(Theme.textPrimary)
				Text("Let’s make progress today!")
					.font(.system(size: 16, weight: .medium, design: .rounded))
					.italic()
					.foregroundStyle(Theme.textSecondary)
			}

			Spacer()

			Button { } label: {
				Image(systemName: "sun.max")
					.font(.system(size: 16, weight: .semibold))
					.foregroundStyle(Theme.textPrimary)
					.frame(width: 42, height: 42)
					.background(Theme.card, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
					.shadow(color: Theme.shadow, radius: 10, x: 0, y: 4)
			}
			.buttonStyle(.plain)
			.accessibilityLabel("Theme")
		}
	}

	private var visibleTodos: [Todo] {
		let calendar = Calendar.current
		let selectedDay = calendar.startOfDay(for: selectedDate)

		let dayTodos = store.todos.filter { calendar.isDate($0.scheduledDate, inSameDayAs: selectedDay) }

		switch filter {
		case .todo:
			return dayTodos.filter { !$0.isDone && !$0.isPending }
		case .completed:
			return dayTodos.filter { $0.isDone }
		case .pending:
			return dayTodos.filter { !$0.isDone && $0.isPending }
		}
	}
}

private struct DateStripCard: View {
	@Binding var selectedDate: Date

	var body: some View {
		ScrollView(.horizontal, showsIndicators: false) {
			HStack(spacing: 10) {
				ForEach(weekDays, id: \.self) { date in
					DayCell(
						date: date,
						isSelected: Calendar.current.isDate(date, inSameDayAs: selectedDate)
					)
					.onTapGesture {
						withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
							selectedDate = date
						}
					}
				}
			}
			.padding(.horizontal, 12)
			.padding(.vertical, 10)
		}
		.background(Theme.card, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
		.shadow(color: Theme.shadow, radius: 16, x: 0, y: 7)
	}

	private var weekDays: [Date] {
		let calendar = Calendar.current
		let startOfDay = calendar.startOfDay(for: selectedDate)
		let weekday = calendar.component(.weekday, from: startOfDay)
		let firstWeekday = calendar.firstWeekday // usually 1 (Sunday) in many locales

		// Force Monday-based week like the mock.
		let mondayIndex = 2
		let deltaToMonday = (weekday - mondayIndex + 7) % 7
		let monday = calendar.date(byAdding: .day, value: -deltaToMonday, to: startOfDay) ?? startOfDay

		return (0...5).compactMap { calendar.date(byAdding: .day, value: $0, to: monday) }
	}
}

private struct DayCell: View {
	let date: Date
	let isSelected: Bool

	private static let dayFormatter: DateFormatter = {
		let f = DateFormatter()
		f.dateFormat = "E"
		return f
	}()

	private static let numberFormatter: DateFormatter = {
		let f = DateFormatter()
		f.dateFormat = "d"
		return f
	}()

	var body: some View {
		VStack(spacing: 6) {
			Text(Self.dayFormatter.string(from: date))
				.font(.system(size: 12, weight: .semibold, design: .rounded))
				.foregroundStyle(isSelected ? Theme.textPrimary : Theme.textSecondary)
			Text(Self.numberFormatter.string(from: date))
				.font(.system(size: 18, weight: .semibold, design: .rounded))
				.foregroundStyle(isSelected ? Theme.textPrimary : Theme.textTertiary)
		}
		.frame(width: 44, height: 56)
		.background(
			Group {
				if isSelected {
					Theme.cardAlt
				} else {
					Color.clear
				}
			},
			in: RoundedRectangle(cornerRadius: 16, style: .continuous)
		)
	}
}

private struct TodoCard: View {
	@Binding var filter: TodoFilter
	@Binding var collapsed: Set<TodoSection>

	let todos: [Todo]
	let onToggle: (Todo) -> Void

	var body: some View {
		VStack(spacing: 14) {
			filterPills

			VStack(spacing: 14) {
				ForEach(TodoSection.allCases) { section in
					SectionBlock(
						section: section,
						isCollapsed: collapsed.contains(section),
						todos: todos.filter { $0.section == section },
						onHeaderTap: {
							withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
								if collapsed.contains(section) {
									collapsed.remove(section)
								} else {
									collapsed.insert(section)
								}
							}
						},
						onToggle: onToggle
					)
				}
			}
		}
		.padding(16)
		.background(Theme.card, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
		.shadow(color: Theme.shadow, radius: 18, x: 0, y: 8)
	}

	private var filterPills: some View {
		HStack(spacing: 10) {
			ForEach(TodoFilter.allCases) { item in
				Button {
					withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
						filter = item
					}
				} label: {
					Label(item.rawValue, systemImage: item.systemImage)
						.labelStyle(.titleAndIcon)
						.font(.system(size: 13, weight: .semibold, design: .rounded))
						.foregroundStyle(filter == item ? .white : Theme.textSecondary)
						.padding(.horizontal, 14)
						.padding(.vertical, 10)
						.frame(maxWidth: .infinity)
						.background(
							Group {
								if filter == item {
									Theme.pillSelected
								} else {
									Theme.cardAlt
								}
							},
							in: Capsule(style: .continuous)
						)
				}
				.buttonStyle(.plain)
			}
		}
		.padding(6)
		.background(Theme.cardAlt, in: Capsule(style: .continuous))
	}
}

private struct SectionBlock: View {
	let section: TodoSection
	let isCollapsed: Bool
	let todos: [Todo]
	let onHeaderTap: () -> Void
	let onToggle: (Todo) -> Void

	var body: some View {
		VStack(alignment: .leading, spacing: 10) {
			Button(action: onHeaderTap) {
				HStack(spacing: 8) {
					Image(systemName: "chevron.down")
						.font(.system(size: 12, weight: .semibold))
						.rotationEffect(.degrees(isCollapsed ? -90 : 0))
						.foregroundStyle(Theme.textSecondary)

					Text(section.title)
						.font(.system(size: 15, weight: .semibold, design: .rounded))
						.foregroundStyle(Theme.textPrimary)

					Spacer()
				}
			}
			.buttonStyle(.plain)

			if !isCollapsed {
				VStack(spacing: 10) {
					ForEach(todos) { todo in
						TodoItemRow(todo: todo) {
							onToggle(todo)
						}
					}

					if todos.isEmpty {
						Text("No tasks")
							.font(.system(size: 13, weight: .semibold, design: .rounded))
							.foregroundStyle(Theme.textTertiary)
							.padding(.leading, 28)
					}
				}
			}
		}
	}
}

private struct TodoItemRow: View {
	let todo: Todo
	let onToggle: () -> Void

	var body: some View {
		HStack(spacing: 10) {
			Button(action: onToggle) {
				ZStack {
					RoundedRectangle(cornerRadius: 7, style: .continuous)
						.stroke(Theme.strokeStrong, lineWidth: 1)
						.frame(width: 22, height: 22)
						.background(Theme.cardAlt, in: RoundedRectangle(cornerRadius: 7, style: .continuous))

					if todo.isDone {
						Image(systemName: "checkmark")
							.font(.system(size: 10, weight: .bold))
							.foregroundStyle(Theme.textPrimary)
					}
				}
			}
			.buttonStyle(.plain)

			Text(todo.emoji ?? "•")
				.font(.system(size: 14))
				.frame(width: 18, alignment: .center)

			Text(todo.title)
				.font(.system(size: 15, weight: .semibold, design: .rounded))
				.foregroundStyle(todo.isDone ? Theme.textTertiary : Theme.textPrimary)
				.strikethrough(todo.isDone, color: Theme.textTertiary)
				.lineLimit(2)

			Spacer(minLength: 0)
		}
		.padding(.leading, 4)
		.accessibilityElement(children: .combine)
	}
}
