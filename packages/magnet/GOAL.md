# Cascade

The goal is make a safe wrapper to interact with the BuildContext and Navigator
in logic patterns, without the need to use the context directly.

## Alternatives
1. Indirect
    With the help of abstract classes, we can create a layer of abstraction to
    interact with the context and navigator. This way, we can create a safe
    wrapper to interact with the context and navigator.
2. Nested
    We can use the cascade operator to interact with the context and navigator
    in a safe way.
    Read Monad Pattern.
3. Emissions
    We can use the StreamBuilder to interact with the context and navigator in
    a safe way. Such as the BLoC pattern.


## Example

### Indirect

### Nested

1. Push Dialog and get result

OG
```dart
final result = await context.push('/pageWithResult');
if (!context.mounted || result == null || result == 'noResult') return;

switch (result) {
case 'goodResult':
  await saveInRepository(result);
case 'badResult':
  await reportError(result);
default:
  await tryAgain();
}
```

Cascade
```dart
onContext(
  (context) => unsatisfied(
    // Same as `() async => await context.push('/pageWithResult')`
    context.push('/pageWithResult'),
    (result) => result != null || result != 'noResult',
  ),
).bind(
  (String result) => switch (result) {
     'goodResult' => saveInRepository(result),
     'badResult' => reportError(result),
      _ => tryAgain(),
  },
).emit(context);
```

Cascade also
```dart
onContext((context) => context.push('/pageWithResult'))
  .unsatisfied((result) => result != null || result != 'noResult')
  .bind(
    (String result) => switch (result) {
       'goodResult' => saveInRepository(result),
       'badResult' => reportError(result),
        _ => tryAgain(),
    },
  ).emit(context);
```

2. Confirm Dialog, Success and Error Dialog

OG
```dart
final confirm = await context.push('/confirmationDialog');
if (!context.mounted || confirm != true) return;

try {
  final message = await saveDataInCloud(data);
  if (!context.mounted) return;

  await SuccessDialog(message).show(context);

} catch (error) {
  final message = error is HandledError ? error.message : 'Oops!';
  if (context.mounted){
    await ErrorDialog(message).show(context);
    return;
  }
}
```

Cascade
```dart
onContext(ConfirmationDialog.show)
  .unsatisfied((confirm) => confirm != true)
  .bind((_) => saveDataInCloud(data))
  ..onError((error) => error is HandledError ? error.message : 'Oops!')
    .withContext((message, context) => ErrorDialog(message).show(context))
    .emit(context);
  ..withContext((message, context) => SuccessDialog(message).show(context))
    .emit(context);
```

### Emissions
Cascade Pattern
```dart
class Success extends Result {
  const Success();
}

sealed class Load extends Result {
  const Load();
}

class Loading extends Load {
  const Loading({required this.onLoading, this.onLoaded});

  final Future<dynamic> Function() onLoading;
  final Future<void> Function(dynamic)? onLoaded;
}

class Loaded extends Load {
  const Loaded({this.onLoaded});
  final Future<void> Function()? onLoaded;
}

Future<void> _onSave() async {
  observer.log('save');
  emit(
    Loading(
      onLoading: () async {
        observer.log('saving');
        final vendorCode =
            int.tryParse(_authRepo.currentVendor?.codAgente ?? '');

        if (vendorCode == null) {
          observer.log('No se pudo obtener el código del vendedor');
          crash('No se pudo obtener el código del vendedor');
        }

        final companyCode =
            int.tryParse(_authRepo.currentBusiness?.codEmpresa ?? '');
        if (companyCode == null) {
          observer.log('No se pudo obtener el código de la empresa');
          crash('No se pudo obtener el código de la empresa');
        }

        observer.log('posting devolution');
        final observations = await _devoRepo.postDevolution(
          DevolutionRequest(
            observation: data.description,
            serie: '',
            document: 0,
            dateProcess: DateTime.now(),
            address: data.address!.order,
            reason: data.reason!.reason,
            policy: data.policy?.policy,
            email: data.email,
            items: data.items
                .mapIndexed((index, i) => i.toModel(index + 1))
                .toList(),
            // TODO(LUSEDOU): Add files to the model.
            files: [],
          ),
          customerCode: data.customer.code,
          companyCode: companyCode,
          vendorCode: vendorCode,
        );

        observer.log('devolution posted');

        if (observations == null) {
          fail(
            _devoRepo.popError() ?? 'no se pudo registrar la devolución',
          );
        }

        if (observations.isNotEmpty) {
          final items = [...data.items];
          for (final observation in observations) {
            final item = items.elementAtOrNull(observation.lineNumber - 1);
            if (item == null) {
              crash('No se pudo encontrar el ítem de la observación');
            }
            items[observation.lineNumber - 1] = item.copyWith(
              observation: observation.observation,
            );
          }
          failSafe(
            _devoRepo.popError() ?? 'hay observaciones en los ítems',
          );
          observer.log('observations found');
        } else {
          observer.log('no observations');
          return const [];
        }
      },
      onLoaded: (result) async {
        observer.log('loaded');
        if (result == null) return;

        if (result is List<ArticleReturned>) {
          if (result.isEmpty) {
            emit(const Success());
            return;
          }

          workSafe((data) => data.copyWith(items: result));
        }
      },
    ),
  );
}

Future<void> onSaveTap({
  required GlobalKey<FormState> formKey,
}) async {
  final isValid = formKey.currentState?.validate();
  // Check for false or null
  if (isValid case false || null) {
    return failSafe('Existen campos vacíos o inválidos');
  }

  formKey.currentState?.save();

  final data = checkData();

  if (!data.isValid) failSafe('Existen campos vacíos o inválidos');

  emit(
    Show(
      BoolDialog(
        content: Text(
          '¿Está seguro de finalizar el registro de devolución?',
          textAlign: TextAlign.center,
        ),
      ).show,
      onResult: (result) async {
        if (result == null || result == false) return;
        return _onSave();
      },
    )
  );
}
```
