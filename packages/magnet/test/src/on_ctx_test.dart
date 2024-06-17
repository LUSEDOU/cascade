// ignore_for_file: prefer_const_constructors

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:magnet/src/on_context.dart';

void main() {
  group('on_context', () {
    late FlutterContext flutterContext;
    late Context context;

    setUp(() {
      flutterContext = FlutterContext();
      context = Context(flutterContext);
    });

    group('BaseOnCtx<T>', () {
      test('should return a function', () {
        expect(onContext((_) => 1), isA<Function>());
      });

      test('should return a function that returns a FutureOr', () {
        expect(onContext((_) => 1)(flutterContext), isA<FutureOr<dynamic>>());
      });

      test('should return a function that returns a FutureOr of the type of fn',
          () {
        expect(onContext((_) => 1)(flutterContext), completion(isA<int>()));
      });

      test('should return a function that returns the result of fn', () {
        expect(onContext((_) => 1)(flutterContext), completion(1));
      });
    });

    group('Emit<T>', () {
      group('emit', () {
        test('should return a FutureOr', () {
          expect(onContext((_) => 1).emit(context), isA<FutureOr<dynamic>>());
        });

        test('should return a FutureOr of the type of fn', () {
          expect(onContext((_) => 1).emit(context), completion(isA<int>()));
        });

        test('should return the result of fn', () {
          expect(onContext((_) => 1).emit(context), completion(1));
        });
      });

      group('bind', () {
        test('should return a function', () {});

        test('should return a function that returns an OnContext', () {});

        test(
          'should return a function that returns the type of the OnContext',
          () {},
        );

        test('should return a function that returns the OnContext', () {});
      });
    });

    group('OnContext<T>', () {
      group('Mounted<T>', () {
        test('should be a const class', () {
          expect(Mounted<dynamic>(), isA<OnContext<dynamic>>());
        });

        test('should pass the type parameter to the superclass', () {
          expect(Mounted<int>(), isA<OnContext<int>>());
        });
      });

      group('Unmounted<T>', () {
        test('should be a const class', () {
          expect(Unmounted<dynamic>(), isA<OnContext<dynamic>>());
        });

        test('should pass the type parameter to the superclass', () {
          expect(Unmounted<int>(), isA<OnContext<int>>());
        });
      });
    });
  });
}
