import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> adminTables = [
      {'title': 'PRODUCTOS', 'icon': Icons.inventory_2_outlined, 'collection': 'products'},
      {'title': 'CLIENTES', 'icon': Icons.people_alt_outlined, 'collection': 'users'},
      {'title': 'PEDIDOS', 'icon': Icons.shopping_bag_outlined, 'collection': 'orders'},
      {'title': 'CATEGORÍAS', 'icon': Icons.category_outlined, 'collection': 'categories'},
      {'title': 'EMPLEADOS', 'icon': Icons.badge_outlined, 'collection': 'employees'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión Boutique'),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFDF7FF), Colors.white],
          ),
        ),
        child: GridView.builder(
          padding: const EdgeInsets.all(20),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 1,
          ),
          itemCount: adminTables.length,
          itemBuilder: (context, index) {
            final table = adminTables[index];
            return Card(
              elevation: 4,
              shadowColor: const Color(0xFFC8A2C8).withAlpha(77), // ¡¡CORREGIDO!!
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              color: Colors.white,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TableDetailView(
                        title: table['title'],
                        collection: table['collection'],
                      ),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFE4E1), // Pastel Pink
                        shape: BoxShape.circle, // ¡CORREGIDO!
                      ),
                      child: Icon(
                        table['icon'],
                        size: 32,
                        color: const Color(0xFFC8A2C8), // Lilac
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      table['title'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        letterSpacing: 1.1,
                        color: Color(0xFF4B0082),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class TableDetailView extends StatelessWidget {
  final String title;
  final String collection;

  const TableDetailView({
    super.key,
    required this.title,
    required this.collection,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color(0xFFC8A2C8),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection(collection).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar datos'));
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(child: Text('No hay registros en esta tabla'));
          }

          // Obtener las columnas dinámicamente del primer documento
          final List<String> columns = (docs.first.data() as Map<String, dynamic>).keys.toList();

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(const Color(0xFFFFE4E1)), // ¡CORREGIDO!
                columns: columns.map((col) => DataColumn(label: Text(col.toUpperCase()))).toList(),
                rows: docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return DataRow(
                    cells: columns.map((col) => DataCell(Text(data[col]?.toString() ?? ''))).toList(),
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Lógica para añadir nuevo registro
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Función de inserción en desarrollo')),
          );
        },
        backgroundColor: const Color(0xFFC8A2C8),
        child: const Icon(Icons.add),
      ),
    );
  }
}
