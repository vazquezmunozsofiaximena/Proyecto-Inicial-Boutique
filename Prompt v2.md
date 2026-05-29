Antigravity 
Flutter para Android/web/windows/IOS 
Plan de Implementación, NO poner códigos
Crear una aplicación en base a flutter con dart con soporte de plataforma para administrar una boutique con todas las plataformas android/web/windows y el layout deberá estar basado para administrar una boutique. La aplicación inicia con login (iniciar sesión, registrarse, olvidó su contraseña) y dar acceso al crud de producto, firebase y firestore,
La página tendrá inicio y el crud de todas las tablas. Utilizar widgets atractivos y modernos, utilizar colores lilas y rosas pasteles. Usar firebase autenticación, Cloud Firestore, no se te olvide integrar las dependencias configuraciones necesarias actualizar pubspec.yaml, mi proyecto en console firebase es BDcrudboutique Integración de los archivos .dart necesarios en la carpeta bin y subcarpetas..
Las tablas serán Categorias (id, nombre, descripción) Proveedor (id, nombre, contacto, email) Cliente (id, nombre, apellido, email, teléfono, dirección, fecharegistro) Empleado (id, nombre, cargo, email) Producto (id, nombre, descripcion, precio, stock, idcategoria, idproveedor) Pedido (id, fecha, estado, total, idcliente, idempleado) DetallePedido (id, idpedido, idproducto, cantidad, preciounitario) Pago (id, idpedido, fecha, monto, método).
Proyecto totalmente funcional.
