enum L10n {
  static var ok: String { "ok".localized() }
  enum Error {
    static var title: String { "Error.title".localized() }
  }
  enum Auth {
    static var reason: String { "Auth.reason".localized() }
    enum Error {
      static var message: String { "Auth.Error.message".localized() }
      static var title: String { "Auth.Error.title".localized() }
    }
    static var cancel: String { "Auth.cancel".localized() }
  }
}
