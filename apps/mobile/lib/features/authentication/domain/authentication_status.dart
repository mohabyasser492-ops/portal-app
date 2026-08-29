/// Represents the current authentication stage of Portal App.
enum AuthenticationStatus {
  /// The application has not completed its initial session check.
  initializing,

  /// No authenticated session is available.
  signedOut,

  /// An interactive sign-in operation is running.
  signingIn,

  /// A valid authenticated session is available.
  signedIn,

  /// A sign-out operation is running.
  signingOut,

  /// Authentication failed and may be retried.
  failure,
}
