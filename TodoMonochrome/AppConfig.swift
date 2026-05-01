import Foundation

enum AppConfig {
	// App Groups + widget extension are disabled for easier sideloading with free Apple IDs.
	static let appGroupID: String? = nil
	static let addTodoURL = URL(string: "todomonochrome://add")!
}
