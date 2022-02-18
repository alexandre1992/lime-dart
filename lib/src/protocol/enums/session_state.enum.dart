enum SessionState {
  /// The session is new and doesn't exists an
  /// established context. It is sent by a client
  /// node to start a session with a server.
  isNew,

  /// The server and the client are negotiating the
  /// session options, like cryptography and compression.
  /// The server sends to the client the options (if available)
  /// and the client chooses the desired options.
  /// If there's no options (for instance, if the connection
  /// is already encrypted or the transport protocol doesn't
  /// support these options), the server SHOULD skip the negotiation.
  negotiating,

  /// The session is being authenticated. The server sends to
  /// the client the available authentication schemes list and
  /// the client must choose one and send the specific authentication
  /// data. The authentication can occurs in multiple roundtrips,
  /// according to the selected schema.
  authenticating,

  /// The session is active and it is possible to send and receive
  /// messages and commands. The server sends this state
  /// after the session was authenticated.
  established,

  /// The client node is requesting to
  /// the server to finish the session.
  finishing,

  /// The session was gracefully
  /// finished by the server.
  finished,

  /// A problem occurred while the session was established, under
  /// negotiation or authentication and it was closed by the server.
  /// In this case, the property reason MUST be present to provide
  /// more details about the problem.
  failed
}
