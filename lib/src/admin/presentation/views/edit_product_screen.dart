import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/src/products/data/models/product_model.dart';
import 'package:myapp/src/products/data/repository/product_repository.dart';
import 'package:go_router/go_router.dart';

class EditProductScreen extends StatefulWidget {
  final Product product;

  const EditProductScreen({super.key, required this.product});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _description;
  late double _price;
  late String _imageUrl;
  late String _category;
  late int _stock;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _name = widget.product.name;
    _description = widget.product.description;
    _price = widget.product.price;
    _imageUrl = widget.product.imageUrl;
    _category = widget.product.category;
    _stock = widget.product.stock;
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => _isLoading = true);

      final updatedProduct = Product(
        id: widget.product.id,
        name: _name,
        description: _description,
        price: _price,
        imageUrl: _imageUrl,
        category: _category,
        stock: _stock,
      );

      try {
        await Provider.of<ProductRepository>(context, listen: false)
            .updateProduct(updatedProduct);
        if (mounted) {
          context.go('/admin');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Producto actualizado con éxito')),
          );
        }
      } catch (error) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al actualizar el producto: $error')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Editar ${widget.product.name}')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: <Widget>[
                    TextFormField(
                      initialValue: _name,
                      decoration:
                          const InputDecoration(labelText: 'Nombre del Producto'),
                      textInputAction: TextInputAction.next,
                      onSaved: (value) => _name = value!,
                      validator: (value) =>
                          value!.isEmpty ? 'Este campo es requerido' : null,
                    ),
                    TextFormField(
                      initialValue: _description,
                      decoration:
                          const InputDecoration(labelText: 'Descripción'),
                      textInputAction: TextInputAction.next,
                      onSaved: (value) => _description = value!,
                      validator: (value) =>
                          value!.isEmpty ? 'Este campo es requerido' : null,
                    ),
                    TextFormField(
                      initialValue: _price.toString(),
                      decoration: const InputDecoration(labelText: 'Precio'),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      textInputAction: TextInputAction.next,
                      onSaved: (value) => _price = double.parse(value!),
                      validator: (value) =>
                          value!.isEmpty ||
                                  double.tryParse(value) == null ||
                                  double.parse(value) <= 0
                              ? 'Por favor ingrese un precio válido'
                              : null,
                    ),
                    TextFormField(
                      initialValue: _category,
                      decoration: const InputDecoration(labelText: 'Categoría'),
                      textInputAction: TextInputAction.next,
                      onSaved: (value) => _category = value!,
                      validator: (value) =>
                          value!.isEmpty ? 'Este campo es requerido' : null,
                    ),
                    TextFormField(
                      initialValue: _stock.toString(),
                      decoration: const InputDecoration(labelText: 'Stock'),
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      onSaved: (value) => _stock = int.parse(value!),
                      validator: (value) =>
                          value!.isEmpty ||
                                  int.tryParse(value) == null ||
                                  int.parse(value) < 0
                              ? 'Por favor ingrese un stock válido'
                              : null,
                    ),
                    TextFormField(
                      initialValue: _imageUrl,
                      decoration:
                          const InputDecoration(labelText: 'URL de la Imagen'),
                      keyboardType: TextInputType.url,
                      textInputAction: TextInputAction.done,
                      onSaved: (value) => _imageUrl = value!,
                      validator: (value) {
                        if (value!.isEmpty) return 'Este campo es requerido';
                        if (!value.startsWith('http'))
                          return 'Por favor ingrese una URL válida';
                        return null;
                      },
                      onFieldSubmitted: (_) => _submit(),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _submit,
                      child: const Text('Guardar Cambios'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
