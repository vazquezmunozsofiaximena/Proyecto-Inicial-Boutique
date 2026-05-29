import 'package:flutter/material.dart';

class AdminPanelView extends StatelessWidget {
  const AdminPanelView({super.key});

  @override
  Widget build(BuildContext context) {
    const Color lilacColor = Color(0xFFC8A2C8);
    const Color indigoText = Color(0xFF4B0082);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Administración'),
        backgroundColor: lilacColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'INVENTARIO DE PRODUCTOS',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: indigoText,
                    letterSpacing: 1.1,
                  ),
            ),
            const SizedBox(height: 16),
            _buildAdminTable(
              headerColor: lilacColor,
              columns: ['ID', 'Producto', 'Precio', 'Stock'],
              rows: [
                ['001', 'Vestido Seda Moon', '\$120.00', '15'],
                ['002', 'Blusa Sweet Rose', '\$45.00', '22'],
                ['003', 'Falda Pastel Plisada', '\$65.00', '10'],
                ['004', 'Accesorio Perlas Night', '\$20.00', '30'],
              ],
            ),
            const SizedBox(height: 40),
            Text(
              'GESTIÓN DE PEDIDOS',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: indigoText,
                    letterSpacing: 1.1,
                  ),
            ),
            const SizedBox(height: 16),
            _buildAdminTable(
              headerColor: lilacColor,
              columns: ['Orden', 'Cliente', 'Total', 'Estado'],
              rows: [
                ['#ORD-7721', 'Camila Rivas', '\$185.00', 'Enviado'],
                ['#ORD-7722', 'Elena Torres', '\$45.00', 'Pagado'],
                ['#ORD-7723', 'Jimena Solís', '\$210.00', 'Pendiente'],
                ['#ORD-7724', 'Lucía Mndz', '\$120.00', 'En Proceso'],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminTable({
    required Color headerColor,
    required List<String> columns,
    required List<List<String>> rows,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(headerColor),
            headingTextStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            dataRowMinHeight: 56, // ¡CORREGIDO!
            dataRowMaxHeight: 56, // ¡CORREGIDO!
            columns: columns
                .map((col) => DataColumn(label: Expanded(child: Text(col))))
                .toList(),
            rows: rows
                .map(
                  (row) => DataRow(
                    cells: row.map((cell) => DataCell(Text(cell))).toList(),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}