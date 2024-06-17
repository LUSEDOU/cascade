//ignore_for_file: public_member_api_docs
import 'dart:async';

class FlutterContext {
  bool get mounted => true;

  FutureOr<T?> Function() push<T>(T route) {
    return () => Future.value(route);
  }
}

class Context {
  Context(this.context);
  final FlutterContext context;
}

typedef BaseOnCtx<T> = FutureOr<T> Function(FlutterContext context);

BaseOnCtx<T> onContext<T>(
  FutureOr<T> Function(FlutterContext) fn,
) =>
    (FlutterContext context) async => await fn(context);

extension Emit<T> on BaseOnCtx<T> {
  FutureOr<T> emit(Context context) => this(context.context);
}

sealed class OnContext<T> {
  const OnContext();
}

class Mounted<T> extends OnContext<T> {
  const Mounted();
}

class Unmounted<T> extends OnContext<T> {
  const Unmounted();
}

FutureOr<OnContext<T>> Function(FlutterContext) unsatisfied<T>(
  FutureOr<T> Function() fn,
  bool Function(T) predicate,
) =>
    (FlutterContext context) async => const Unmounted();

  void saveInRepository(String result) { }

  void reportError(String result) { }
  void tryAgain() { }

void main(List<String> args) async {

  final flutterContext = FlutterContext();
  final context = Context(flutterContext);

  final result = await context.push('/dialogWithResult');
  if (!context.mounted || result == null || result == 'noResult') return;

  switch (result) {
    case 'goodResult':
      await saveInRepository(result);
    case 'badResult':
      await reportError(result);
    default:
      await tryAgain();
  }


  onContext(
    (context) => unsatisfied(
      // Same as `() async => await context.push('/dialogWithResult')`
      context.push('/dialogWithResult'),
      (result) => result != null || result != 'noResult',
    ),
  ).bind(
    (String result) => switch (result) {
       'goodResult' => saveInRepository(result),
       'badResult' => reportError(result),
        _ => tryAgain(),
    },
  ).emit(context);

  onContext((context) => context.push('/dialogWithResult'))
    .unsatisfied((result) => result != null || result != 'noResult')
    .bind(
      (String result) => switch (result) {
         'goodResult' => saveInRepository(result),
         'badResult' => reportError(result),
          _ => tryAgain(),
      },
    ).emit(context);


  final confirm = await context.push('/confirmationDialog');
  if (!context.mounted || confirm != true) return;

  try {
    final message = await saveDataInCloud(data);
    if (!context.mounted) return;

    await SuccessDialog.show(message, context);

  } catch (error) {
    final message = error is HandledError ? error.message : 'Oops!';
    if (context.mounted){
      await ErrorDialog.show('Oops!', context);
      return;
    }
  }


  onContext(ConfirmationDialog.show)
    .unsatisfied((confirm) => confirm != true)
    .bind((_) => saveDataInCloud(data))
    ..onError((error) => error is HandledError ? error.message : 'Oops!')
      .withContext((message, context) => ErrorDialog.show(message, context))
      .emit(context);
    ..withContext((message) => SuccessDialog.show(message))
      .emit(context);
}
