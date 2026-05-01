import SwiftUI

struct ContentView: View {
	@StateObject private var store = TodoStore()

	var body: some View {
		MainTabShellView(store: store)
	}
}
