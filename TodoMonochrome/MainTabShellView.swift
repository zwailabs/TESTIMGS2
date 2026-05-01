import SwiftUI

enum AppTab: Hashable {
	case home
	case insights
	case profile
}

struct MainTabShellView: View {
	@EnvironmentObject private var router: AppRouter
	@ObservedObject var store: TodoStore

	@State private var tab: AppTab = .home
	@State private var isPresentingAdd = false
	@State private var homeSelectedDate: Date = Date()

	var body: some View {
		ZStack {
			AppBackground()

			Group {
				switch tab {
				case .home:
					HomeView(store: store, selectedDate: $homeSelectedDate)
				case .insights:
					InsightsView()
				case .profile:
					ProfileView()
				}
			}
			.safeAreaInset(edge: .bottom) {
				bottomBar
					.padding(.horizontal, 18)
					.padding(.bottom, 10)
			}
		}
		.sheet(isPresented: $isPresentingAdd) {
			AddTodoView(defaultDate: homeSelectedDate) { input in
				withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
					store.add(
						title: input.title,
						section: input.section,
						scheduledDate: input.scheduledDate,
						emoji: input.emoji,
						isPending: input.isPending
					)
				}
			}
			.presentationDetents([.height(420), .medium])
			.presentationDragIndicator(.visible)
		}
		.onAppear {
			if router.shouldPresentAddTodo {
				isPresentingAdd = true
				router.shouldPresentAddTodo = false
			}
		}
		.onReceive(router.$shouldPresentAddTodo) { shouldPresent in
			guard shouldPresent else { return }
			isPresentingAdd = true
			router.shouldPresentAddTodo = false
		}
	}

	private var bottomBar: some View {
		ZStack(alignment: .trailing) {
			HStack(spacing: 8) {
				tabButton(
					tab: .home,
					title: "Home",
					systemImage: "house.fill"
				)

				tabButton(
					tab: .insights,
					title: "Insights",
					systemImage: "chart.bar"
				)

				tabButton(
					tab: .profile,
					title: "Profile",
					systemImage: "person.fill"
				)
			}
			.padding(8)
			.padding(.trailing, 62)
			.background(Theme.cardAlt, in: Capsule())
			.overlay(Capsule().stroke(Theme.stroke, lineWidth: 1))
			.shadow(color: Theme.shadow, radius: 16, x: 0, y: 6)

			Button {
				isPresentingAdd = true
			} label: {
				Image(systemName: "plus")
					.font(.system(size: 18, weight: .bold))
					.foregroundStyle(.white)
					.frame(width: 56, height: 56)
					.background(Theme.pillSelected, in: Circle())
					.shadow(color: Theme.shadow.opacity(1.4), radius: 18, x: 0, y: 8)
			}
			.accessibilityLabel("Add Todo")
		}
	}

	private func tabButton(tab target: AppTab, title: String, systemImage: String) -> some View {
		Button {
			withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
				tab = target
			}
		} label: {
			if tab == target {
				Label(title, systemImage: systemImage)
					.font(.system(size: 14, weight: .semibold, design: .rounded))
					.foregroundStyle(Theme.textPrimary)
					.padding(.horizontal, 14)
					.padding(.vertical, 10)
					.background(Theme.card, in: Capsule())
			} else {
				VStack(spacing: 4) {
					Image(systemName: systemImage)
						.font(.system(size: 16, weight: .semibold))
					Text(title)
						.font(.system(size: 12, weight: .semibold, design: .rounded))
				}
				.foregroundStyle(Theme.textSecondary)
				.frame(maxWidth: .infinity)
				.padding(.vertical, 6)
			}
		}
		.buttonStyle(.plain)
	}
}
