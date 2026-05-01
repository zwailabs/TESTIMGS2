import SwiftUI

struct InsightsView: View {
	var body: some View {
		VStack(spacing: 10) {
			Image(systemName: "chart.bar")
				.font(.system(size: 26, weight: .semibold))
				.foregroundStyle(Theme.iconMuted)
			Text("Insights")
				.font(.system(size: 18, weight: .semibold, design: .rounded))
				.foregroundStyle(Theme.textPrimary)
			Text("Coming soon")
				.font(.system(size: 14, weight: .semibold, design: .rounded))
				.foregroundStyle(Theme.textSecondary)
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.padding(.bottom, 80)
	}
}

