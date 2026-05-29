import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/src/products/data/repository/product_repository.dart';
import 'package:myapp/src/products/data/models/product_model.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _description = '';
  double _price = 0.0;
  String _imageUrl = '';
  String _category = ''; // Add category
  int _stock = 0; // Add stock
  bool _isLoading = false;

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => _isLoading = true);

      final newProduct = Product(
        id: '', // Firestore will generate an ID
        name: _name,
        description: _description,
        price: _price,
        imageUrl: _imageUrl,
        category: _category, // Pass category
        stock: _stock, // Pass stock
      );

      try {
        await Provider.of<ProductRepository>(context, listen: false).addProduct(newProduct);
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Producto añadido con éxito')),
          );
        }
      } catch (error) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al añadir el producto: $error')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Añadir Producto')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: <Widget>[
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Nombre del Producto'),
                      textInputAction: TextInputAction.next,
                      onSaved: (value) => _name = value!,
                      validator: (value) => value!.isEmpty ? 'Este campo es requerido' : null,
                    ),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Descripción'),
                      textInputAction: TextInputAction.next,
                      onSaved: (value) => _description = value!,
                       validator: (value) => value!.isEmpty ? 'Este campo es requerido' : null,
                    ),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Precio'),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      textInputAction: TextInputAction.next,
                      onSaved: (value) => _price = double.parse(value!),
                       validator: (value) => value!.isEmpty || double.tryParse(value) == null || double.parse(value) <= 0 ? 'Por favor ingrese un precio válido' : null,
                    ),
                     TextFormField(
                      decoration: const InputDecoration(labelText: 'Categoría'),
                      textInputAction: TextInputAction.next,
                      onSaved: (value) => _category = value!,
                       validator: (value) => value!.isEmpty ? 'Este campo es requerido' : null,
                    ),
                     TextFormField(
                      decoration: const InputDecoration(labelText: 'Stock'),
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      onSaved: (value) => _stock = int.parse(value!),
                       validator: (value) => value!.isEmpty || int.tryParse(value) == null || int.parse(value) < 0 ? 'Por favor ingrese un stock válido' : null,
                    ),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'URL de la Imagen'),
                      keyboardType: TextInputType.url,
                      textInputAction: TextInputAction.done,
                      onSaved: (value) => _imageUrl = value!,
                       validator: (value) {
                         if(value!.isEmpty) return 'Este campo es requerido';
                         if(!value.startsWith('http')) return 'Por favor ingrese una URL válida';
                         return null;
                       },
                       onFieldSubmitted: (_) => _submit(),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _submit,
                      child: const Text('Guardar Producto'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
