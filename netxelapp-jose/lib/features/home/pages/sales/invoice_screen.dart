import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:netxelapp/features/home/Entities/sales.dart';

class InvoiceScreen extends StatelessWidget {
  final Sale sale;
  final List<SaleDetail> saleDetails;
  final List<Product> products;
  final Function? onConfirm;

  const InvoiceScreen({
    super.key,
    required this.sale,
    required this.saleDetails,
    required this.products,
    this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final numberFormat = NumberFormat("#,##0.00", "es_ES");
    return Scaffold(
      appBar: AppBar(
        title: const Text('Factura'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Factura #${sale.numeroFactura}',
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Cliente: ${sale.client ?? ''}',
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Text(
              'Fecha: ${sale.createdAt?.toString().split(' ')[0]}',
              style: const TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: saleDetails.length,
                itemBuilder: (context, index) {
                  SaleDetail saleDetail = saleDetails[index];

                  Product product = products.firstWhere(
                    (p) => p.id == saleDetail.soldProductId,
                    orElse: () => Product(),
                  );
                  double subtotal =
                      product.salePrice != null && saleDetail.quantity != null
                          ? product.salePrice! * saleDetail.quantity!
                          : 0.0;
                  return ListTile(
                      title: Text(product.name ?? ''),
                      subtitle: Text('Cantidad: ${saleDetail.quantity}'),
                      trailing: Text(
                          '\$${(subtotal as num?) != null ? numberFormat.format(subtotal) : 'N/A'}'));
                },
              ),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total:',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '\$${(sale.total as num?) != null ? numberFormat.format(sale.total) : 'N/A'}',
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (onConfirm != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      onConfirm!();
                      Navigator.pop(context);
                    },
                    child: const Text('Confirmar Venta'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
