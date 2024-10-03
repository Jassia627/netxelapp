// ignore_for_file: unnecessary_null_comparison, avoid_print

import 'package:netxelapp/features/home/Entities/client.dart';
import 'package:netxelapp/features/home/Entities/sales.dart';
import 'package:netxelapp/main.dart';

class SalesService {
  final _supabaseClient = supabase;

  // Método para crear una nueva venta
  Future<Sale?> createSale(double total,
      {int? clientId,
      String? clientName,
      required String invoiceNumber}) async {
    try {
      final data = await _supabaseClient
          .from('sales')
          .insert({
            'total': total,
            'client_id': clientId,
            'client_name': clientName,
            'confirmed': false,
            'numero_factura':
                invoiceNumber // Añadido para inicializar como no confirmada
          })
          .select()
          .maybeSingle();

      if (data != null) {
        return Sale.fromMap(data);
      } else {
        return null;
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<Client?> createClient(String name) async {
    try {
      final data = await _supabaseClient
          .from('clients')
          .insert({'name': name})
          .select()
          .single();

      if (data != null) {
        return Client.fromMap(data);
      } else {
        return null;
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> discontProductQuantity({
    required int id,
    required int quantity,
  }) async {
    try {
      final data = await _supabaseClient
          .from('products')
          .select('stock_quantity')
          .eq('id', id)
          .single();
      final currentQuantity = data['stock_quantity'];
      final newQuantity = currentQuantity - quantity;
      if (newQuantity >= 0) {
        await _supabaseClient
            .from('products')
            .update({'stock_quantity': newQuantity}).eq('id', id);
      } else {
        print('No hay suficiente stock para descontar la cantidad solicitada');
      }
    } catch (e) {
      print('Error al descontar la cantidad del producto: $e');
    }
  }

  // Método para crear un detalle de venta
  Future<SaleDetail?> createSaleDetail({
    required int soldProductId,
    required int quantity,
    required int saleId,
    required String userId,
  }) async {
    try {
      if (soldProductId == null ||
          quantity == null ||
          saleId == null ||
          userId == null) {
        throw Exception(
            'Parámetros inválidos $soldProductId $quantity $saleId $userId');
      }

      final data = await _supabaseClient
          .from('sale_details')
          .insert({
            'sold_product_id': soldProductId,
            'quantity': quantity,
            'sale_id': saleId,
            'user_id': userId,
          })
          .select()
          .maybeSingle();

      if (data != null) {
        return SaleDetail.fromMap(data);
      } else {
        return null;
      }
    } catch (e) {
      throw Exception('Detalle: $e');
    }
  }

  // Método para obtener todos los productos
  Future<List<Product>> getProducts() async {
    final data =
        await _supabaseClient.from('products').select().eq('active', true);
    List<Product> products = [];
    for (var map in data) {
      try {
        products.add(Product.fromMap(map));
      } catch (e) {
        print('Error al mapear $map: $e');
      }
    }
    return products;
  }

  Future<List<SaleDetail>> getSaleDetailBySaleId(int saleId) async {
    final data = await _supabaseClient
        .from('sale_details')
        .select()
        .eq('active', true)
        .eq('sale_id', saleId);
    List<SaleDetail> saleDetails = [];
    for (var map in data) {
      try {
        saleDetails.add(SaleDetail.fromMap(map));
      } catch (e) {
        print('Error al mapear $map: $e');
      }
    }
    return saleDetails;
  }

  Future<List<Product>> getProductsBySaleId(int saleId) async {
    final data = await _supabaseClient
        .from('sale_details')
        .select('sold_product_id')
        .eq('sale_id', saleId);

    List<Product> products = [];
    for (var map in data) {
      try {
        int productId = map['sold_product_id'];
        final productData = await _supabaseClient
            .from('products')
            .select()
            .eq('id', productId)
            .maybeSingle();
        if (productData != null) {
          products.add(Product.fromMap(productData));
        }
      } catch (e) {
        print('Error al obtener el producto $map: $e');
      }
    }
    return products;
  }

  Future<List<Client>> getClients() async {
    try {
      final response =
          await _supabaseClient.from('clients').select().eq('active', true);
      return response.map((data) => Client.fromMap(data)).toList();
    } catch (e) {
      throw e;
    }
  }

  // Método para verificar la disponibilidad de productos
  Future<bool> checkProductAvailability(int productId, int quantity) async {
    final data = await _supabaseClient
        .from('products')
        .select('stock_quantity')
        .eq('id', productId)
        .maybeSingle();

    if (data != null) {
      int stockQuantity = data['stock_quantity'];
      return stockQuantity >= quantity;
    } else {
      throw Exception('Error al obtener la información del producto');
    }
  }

  Future<List<Sale>> getSales() async {
    try {
      final data = await _supabaseClient
          .from('sales')
          .select()
          .order('created_at', ascending: false);
      print(data);
      if (data != null) {
        return (data as List).map((json) => Sale.fromMap(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<bool> confirmSale(int saleId) async {
    try {
      // Actualizar el campo 'confirmed' a true
      await _supabaseClient
          .from('sales')
          .update({'confirmed': true}).eq('id', saleId);

      // Obtener los detalles de la venta
      final saleDetails = await getSaleDetailBySaleId(saleId);

      // Descontar los productos
      for (var detail in saleDetails) {
        await discontProductQuantity(
          id: detail.soldProductId!,
          quantity: detail.quantity!,
        );
      }

      return true;
    } catch (e) {
      print('Error al confirmar la venta: $e');
      return false;
    }
  }
}
