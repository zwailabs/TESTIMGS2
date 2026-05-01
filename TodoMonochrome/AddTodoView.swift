import SwiftUI

struct NewTodoInput {
	let title: String
	let section: TodoSection
	let scheduledDate: Date
	let emoji: String?
	let isPending: Bool
}

struct AddTodoView: View {
	@Environment(\.dismiss) private var dismiss
	@State private var title: String = ""
	@State private var section: TodoSection = .workload
	@State private var emoji: String = ""
	@State private var isPending: Bool = false
	@State private var scheduledDate: Date
	@FocusState private var isFocused: Bool

	let defaultDate: Date
	let onAdd: (NewTodoInput) -> Void

	init(defaultDate: Date = Date(), onAdd: @escaping (NewTodoInput) -> Void) {
		self.defaultDate = defaultDate
		self.onAdd = onAdd
		_scheduledDate = State(initialValue: Calendar.current.startOfDay(for: defaultDate))
	}

	var body: some View {
		ZStack {
			AppBackground()
			GlassGroup(spacing: 18) {
				VStack(alignment: .leading, spacing: 14) {
					HStack {
						Text("New Task")
							.font(.system(size: 22, weight: .semibold, design: .rounded))
							.foregroundStyle(Theme.textPrimary)
						Spacer()
						Button("Cancel") { dismiss() }
							.font(.system(size: 15, weight: .semibold, design: .rounded))
							.foregroundStyle(Theme.textSecondary)
					}

					VStack(spacing: 12) {
						TextField("What do you need to do?", text: $title)
							.focused($isFocused)
							.textInputAutocapitalization(.sentences)
							.autocorrectionDisabled(false)
							.submitLabel(.done)
							.onSubmit(addAndDismiss)
							.font(.system(size: 16, weight: .semibold, design: .rounded))
							.foregroundStyle(Theme.textPrimary)
							.padding(.horizontal, 12)
							.padding(.vertical, 12)
							.background(Theme.card, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
							.overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(Theme.stroke, lineWidth: 1))

						HStack(spacing: 10) {
							Picker("Section", selection: $section) {
								ForEach(TodoSection.allCases) { s in
									Text(s.title).tag(s)
								}
							}
							.pickerStyle(.segmented)

							TextField("🙂", text: $emoji)
								.multilineTextAlignment(.center)
								.font(.system(size: 18, weight: .semibold))
								.frame(width: 48, height: 36)
								.background(Theme.card, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
								.overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(Theme.stroke, lineWidth: 1))
								.accessibilityLabel("Emoji")
						}

						Toggle("Mark as pending", isOn: $isPending)
							.font(.system(size: 14, weight: .semibold, design: .rounded))
							.foregroundStyle(Theme.textPrimary)

						DatePicker("Date", selection: $scheduledDate, displayedComponents: .date)
							.font(.system(size: 14, weight: .semibold, design: .rounded))
							foregroundStyle(Theme.textPrimary)

						Button(action: addAndDismiss) {
							Text("Add")
								.frame(maxWidth: .infinity)
								.font(.system(size: 16, weight: .semibold, design: .rounded))
								.foregroundStyle(.white)
								.padding(.vertical, 12)
								.background(
									Theme.pillSelected,
									in: RoundedRectangle(cornerRadius: 18, style: .continuous)
								)
								.shadow(color: Theme.shadow.opacity(1.4), radius: 16, x: 0, y: 8)
						}
						.disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
						.opacity(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.45 : 1.0)
					}

					Spacer()
				}
				.padding(16)
				.background(Theme.card, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
				.shadow(color: Theme.shadow, radius: 18, x: 0, y: 8)
				.padding(12)
			}
		}
		.onAppear {
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
				isFocused = true
			}
		}
	}

	private func addAndDismiss() {
		let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
		let trimmedEmoji = emoji.trimmingCharacters(in: .whitespacesAndNewlines)
		onAdd(
			NewTodoInput(
				title: trimmedTitle,
				section: section,
				scheduledDate: Calendar.current.startOfDay(for: scheduledDate),
				emoji: trimmedEmoji.isEmpty ? nil : trimmedEmoji,
				isPending: isPending
			)
		)
		dismiss()
	}
}
