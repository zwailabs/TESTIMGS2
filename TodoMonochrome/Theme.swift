import SwiftUI

enum Theme {
	// Light palette (matches the provided mock).
	static let bg = Color(white: 0.95)
	static let card = Color.white
	static let cardAlt = Color(white: 0.94)
	static let stroke = Color.black.opacity(0.08)
	static let strokeStrong = Color.black.opacity(0.14)
	static let shadow = Color.black.opacity(0.08)
	static let textPrimary = Color.black.opacity(0.92)
	static let textSecondary = Color.black.opacity(0.58)
	static let textTertiary = Color.black.opacity(0.40)
	static let icon = Color.black.opacity(0.78)
	static let iconMuted = Color.black.opacity(0.40)
	static let pillSelected = Color.black.opacity(0.92)
}

struct AppBackground: View {
	var body: some View {
		Theme.bg
		.ignoresSafeArea()
	}
}

struct GlassGroup<Content: View>: View {
	let content: Content

	init(spacing: CGFloat? = nil, @ViewBuilder content: () -> Content) {
		self.content = content()
	}

	var body: some View {
		content
	}
}

struct GlassCardModifier: ViewModifier {
	@Environment(\.accessibilityReduceTransparency) private var reduceTransparency

	var cornerRadius: CGFloat
	var tint: Color?
	var interactive: Bool

	func body(content: Content) -> some View {
		let bg = tint ?? Theme.card
		return content
			.background(bg, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
			.overlay(
				RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
					.stroke(reduceTransparency ? Theme.stroke : Theme.strokeStrong, lineWidth: 1)
			)
			.shadow(color: Theme.shadow, radius: 14, x: 0, y: 6)
	}
}

extension View {
	func glassCard(cornerRadius: CGFloat, tint: Color? = nil, interactive: Bool = false) -> some View {
		modifier(GlassCardModifier(cornerRadius: cornerRadius, tint: tint, interactive: interactive))
	}
}
