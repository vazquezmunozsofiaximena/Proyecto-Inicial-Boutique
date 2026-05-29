import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/src/products/presentation/viewmodels/product_viewmodel.dart';
import 'package:myapp/src/products/data/models/product_model.dart';
import 'package:myapp/src/auth/data/repository/auth_repository.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Console (Estructura Total)'),
          backgroundColor: Colors.purple[100],
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Cerrar sesión',
              onPressed: () async {
                await context.read<AuthRepository>().signOut();
              },
            ),
          ],
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(icon: Icon(Icons.shopping_bag), text: 'Productos'),
              Tab(icon: Icon(Icons.category), text: 'Categorías'),
              Tab(icon: Icon(Icons.local_shipping), text: 'Proveedores'),
              Tab(icon: Icon(Icons.badge), text: 'Empleados'),
              Tab(icon: Icon(Icons.receipt_long), text: 'Pedidos y Pagos'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _ProductsTab(),
            _GenericCrudTab(collectionName: 'categories', labelSingular: 'Categoría', fields: ['nombre', 'descripcion']),
            _GenericCrudTab(collectionName: 'providers', labelSingular: 'Proveedor', fields: ['nombre', 'contacto', 'telefono', 'email', 'pais']),
            _GenericCrudTab(collectionName: 'employees', labelSingular: 'Empleado', fields: ['nombre', 'apellido', 'cargo', 'email', 'telefono']),
            _OrdersAndPaymentsTab(), // Pestaña unificada de Pedidos + Detalles + Pagos
          ],
        ),
      ),
    );
  }
}

// ======================== TAB DE PRODUCTOS ========================
class _ProductsTab extends StatelessWidget {
  const _ProductsTab();

  void _openProductForm(BuildContext context, {Product? product}) {
    final vm = context.read<ProductViewModel>();
    final nameCtrl = TextEditingController(text: product?.name ?? '');
    final descCtrl = TextEditingController(text: product?.description ?? '');
    final priceCtrl = TextEditingController(text: product?.price != null ? product!.price.toString() : '');
    final stockCtrl = TextEditingController(text: product?.stock != null ? product!.stock.toString() : '');
    final imgCtrl = TextEditingController(text: product?.imageUrl ?? '');
    final catCtrl = TextEditingController(text: product?.category ?? 'General');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(top: 20, left: 20, right: 20, bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(product == null ? 'Nuevo Producto' : 'Editar Producto', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nombre', border: OutlineInputBorder())),
              const SizedBox(height: 8),
              TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Descripción', border: OutlineInputBorder())),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: TextField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Precio', border: OutlineInputBorder()))),
                  const SizedBox(width: 8),
                  Expanded(child: TextField(controller: stockCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Stock', border: OutlineInputBorder()))),
                ],
              ),
              const SizedBox(height: 8),
              TextField(controller: imgCtrl, decoration: const InputDecoration(labelText: 'URL Imagen', border: OutlineInputBorder())),
              const SizedBox(height: 8),
              TextField(controller: catCtrl, decoration: const InputDecoration(labelText: 'Categoría', border: OutlineInputBorder())),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final p = Product(
                    id: product?.id ?? '',
                    name: nameCtrl.text,
                    description: descCtrl.text,
                    price: double.tryParse(priceCtrl.text) ?? 0.0,
                    stock: int.tryParse(stockCtrl.text) ?? 0,
                    imageUrl: imgCtrl.text.isNotEmpty ? imgCtrl.text : 'https://placehold.co/100',
                    category: catCtrl.text,
                  );
                  if (product == null) {
                    await vm.addProduct(p);
                  } else {
                    await vm.updateProduct(p);
                  }
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: const Text('GUARDAR'),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<ProductViewModel>(context);
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _openProductForm(context),
      ),
      body: StreamBuilder<List<Product>>(
        stream: vm.getAllProducts(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final list = snapshot.data!;
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, i) {
              final prod = list[i];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(prod.name),
                  subtitle: Text('Precio: \$${prod.price} | Stock: ${prod.stock}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _openProductForm(context, product: prod)),
                      IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => vm.deleteProduct(prod.id)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ======================== CRUD DINÁMICO Y GENÉRICO (Categorías, Proveedores, Empleados) ========================
class _GenericCrudTab extends StatelessWidget {
  final String collectionName;
  final String labelSingular;
  final List<String> fields;

  const _GenericCrudTab({required this.collectionName, required this.labelSingular, required this.fields});

  void _openForm(BuildContext context, {String? docId, Map<String, dynamic>? currentData}) {
    final controllers = <String, TextEditingController>{};
    for (var field in fields) {
      controllers[field] = TextEditingController(text: currentData != null ? currentData[field]?.toString() : '');
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(top: 20, left: 20, right: 20, bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(docId == null ? 'Añadir $labelSingular' : 'Editar $labelSingular', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ...fields.map((field) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: TextField(controller: controllers[field], decoration: InputDecoration(labelText: field.toUpperCase(), border: const OutlineInputBorder())),
              )),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final data = <String, dynamic>{};
                  for (var field in fields) {
                    data[field] = controllers[field]!.text;
                  }
                  if (docId == null) {
                    await FirebaseFirestore.instance.collection(collectionName).add(data);
                  } else {
                    await FirebaseFirestore.instance.collection(collectionName).doc(docId).update(data);
                  }
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: const Text('GUARDAR REGISTRO'),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(context),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection(collectionName).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) return Center(child: Text('No hay registros en la tabla $collectionName.'));
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final doc = docs[i];
              final data = doc.data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: ListTile(
                  title: Text(data[fields.first]?.toString() ?? 'Sin nombre'),
                  subtitle: Text(fields.skip(1).map((f) => '$f: ${data[f]}').join(' | ')),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _openForm(context, docId: doc.id, currentData: data)),
                      IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => FirebaseFirestore.instance.collection(collectionName).doc(doc.id).delete()),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ======================== TAB UNIFICADA: PEDIDOS + DETALLE PEDIDO + PAGO ========================
class _OrdersAndPaymentsTab extends StatelessWidget {
  const _OrdersAndPaymentsTab();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('orders').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) return const Center(child: Text('No hay registros de pedidos o transacciones.'));
        
        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, i) {
            final doc = docs[i];
            final data = doc.data() as Map<String, dynamic>;
            final items = (data['items'] as List?) ?? [];
            
            // Datos extraídos dinámicamente mapeando la estructura relacional
            final String orderId = doc.id.substring(0, 6).toUpperCase();
            final double total = (data['totalAmount'] ?? data['total'] ?? 0.0).toDouble();
            final String estadoPago = data['paymentStatus'] ?? 'COMPLETADO';
            final String metodoPago = data['paymentMethod'] ?? 'Tarjeta de Crédito/Débito';

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              elevation: 3,
              child: ExpansionTile(
                iconColor: Colors.purple,
                title: Text('Pedido #$orderId — Total: \$${total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Cliente ID: ${data['userId']}\nEstado de la Orden: Procesado con éxito'),
                children: [
                  const Divider(height: 1),
                  // --- SECCIÓN: DATOS DE LA TABLA PAGO ---
                  Container(
                    color: Colors.purple[50],
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.monetization_on, color: Colors.green, size: 20),
                            const SizedBox(width: 6),
                            Text('TABLA PAGO:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purple[900])),
                          ],
                        ),
                        Text('Método: $metodoPago | Estado: $estadoPago', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  // --- SECCIÓN: DATOS DE LA TABLA DETALLE PEDIDO ---
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      children: [
                        const Icon(Icons.list_alt, color: Colors.grey, size: 18),
                        const SizedBox(width: 6),
                        Text('DETALLE PEDIDO (Productos Solicitados):', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey[700])),
                      ],
                    ),
                  ),
                  ...items.map((item) {
                    final map = item as Map<String, dynamic>;
                    final String prodName = map['name'] ?? map['productName'] ?? 'Artículo de Boutique';
                    final int quantity = map['quantity'] ?? 1;
                    final double price = (map['price'] ?? 0.0).toDouble();
                    
                    return ListTile(
                      dense: true,
                      leading: const Icon(Icons.arrow_right, color: Colors.purple),
                      title: Text(prodName, style: const TextStyle(fontWeight: FontWeight.w500)),
                      subtitle: Text('Precio Unitario: \$${price.toStringAsFixed(2)}'),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
                        child: Text('Cant: $quantity', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 8)
                ],
              ),
            );
          },
        );
      },
    );
  }
}