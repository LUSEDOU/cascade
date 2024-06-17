/// {@template result}
/// A class that represents the result of a work done by a controller.
/// {@endtemplate}
abstract class Result {
  /// {@macro result}
  const Result();
}

/// {@template failure}
/// Represents an validation failure, that the user needs to be informed.
/// {@endtemplate}
class Failure extends Result {
  /// {@macro failure}
  const Failure(this.message);

  /// The message to be displayed.
  final String message;

  @override
  String toString() => 'Failure: $message';
}

/// {@template crash}
/// Represents an fatal error, that will crash the page and exit the user.
/// {@endtemplate}
class Crash extends Result {
  /// {@macro crash}
  const Crash(this.message);

  /// The message to be displayed before crashing.
  final String message;

  @override
  String toString() => 'Crash: $message';
}

/// {@template move}
/// Represents a call to move to a specific route.
/// {@endtemplate}
class Move extends Result {
  /// {@macro move}
  const Move(
    this.redirect, {
    this.to,
    this.routeBuilder,
    this.extra,
  }) : assert(
          redirect == Redirect.pop || (to != null || routeBuilder != null),
          'to or routeBuilder must be provided',
        );

  /// Redirects to the previous route.
  const Move.pop() : this(Redirect.pop);

  /// The type of redirection.
  final Redirect redirect;

  /// The route to be redirected to.
  final String? to;

  final Route route;

  /// Extra data to be passed to the route.
  final dynamic extra;
}

/// {@template redirect}
/// Represents the handled redirections to a new route.
/// {@endtemplate}
enum Redirect {
  /// Redirects to the previous route.
  pop,

  /// Redirects to the previous route until a certain route.
  popUntil,

  /// Redirects to a new route.
  go,
}
