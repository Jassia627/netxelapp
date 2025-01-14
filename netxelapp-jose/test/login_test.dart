import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:mocktail/mocktail.dart';
import 'package:netxelapp/features/home/pages/stocks/products/product_stock.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockPostgrestClient extends Mock implements PostgrestClient {
  select() {}
}

class MockPostgrestResponse extends Mock implements PostgrestResponse {}

void main() {
  late MockSupabaseClient mockSupabaseClient;
  late MockPostgrestClient mockPostgrestClient;
  late MockPostgrestResponse mockPostgrestResponse;

  setUp(() {
    mockSupabaseClient = MockSupabaseClient();
    mockPostgrestClient = MockPostgrestClient();
    mockPostgrestResponse = MockPostgrestResponse();

    when(() => mockSupabaseClient.from(any()))
        .thenReturn(mockPostgrestClient as SupabaseQueryBuilder);
  });

  test(
      'Stock_Cp01 - Mostrar productos en el stock',
      (WidgetTester tester) async {
        // Simula la respuesta con productos
        final products = [
          {
            'name': 'Producto A',
            'stock_quantity': 10,
            'units_of_measures': {'short_name': 'kg'}
          },
          {
            'name': 'Producto B',
            'stock_quantity': 5,
            'units_of_measures': {'short_name': 'L'}
          }
        ];

        // Simula la respuesta del cliente Postgrest
        when(() => mockPostgrestClient.select())
            .thenAnswer((_) async => mockPostgrestResponse);
        when(() => mockPostgrestResponse.data).thenReturn(products);

        // Construye la interfaz de la pantalla de stock de productos
        await tester.pumpWidget(MaterialApp(home: ProductStock()));

        // Permite que se realicen las operaciones asincrónicas
        await tester.pumpAndSettle();

        // Verifica que los productos se muestran en la UI
        expect(find.text('Producto A'), findsOneWidget);
        expect(find.text('Producto B'), findsOneWidget);
      } as Function());

  test(
      'Stock_Cp02 - Error al obtener productos',
      (WidgetTester tester) async {
        // Simula un error en la obtención de productos
        when(() => mockPostgrestClient.select())
            .thenThrow(Exception('Error al obtener productos'));

        // Construye la interfaz de la pantalla de stock de productos
        await tester.pumpWidget(MaterialApp(home: ProductStock()));

        // Permite que se realicen las operaciones asincrónicas
        await tester.pumpAndSettle();

        // Verifica que se muestra un mensaje de error en la UI
        expect(find.text('Error al obtener productos'), findsOneWidget);
      } as Function());
}
