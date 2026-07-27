import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Smoke test', () {
    test('placeholder — akan diganti test aplikasi sesungguhnya', () {
      // Test nyata (widget test untuk App, router, dsb) ditambahkan
      // seiring modul diimplementasikan. File ini memastikan pipeline
      // `flutter test` di CI punya minimal 1 test yang lulus.
      expect(1 + 1, 2);
    });
  });
}
