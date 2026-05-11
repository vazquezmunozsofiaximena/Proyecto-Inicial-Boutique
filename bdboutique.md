## Actúa como un administrador de base de datos proyecto boutique, que entidades se necesitan para su gestion

Para una boutique, las entidades clave se pueden agrupar así:

<img width="781" height="653" alt="image" src="https://github.com/user-attachments/assets/dc0de255-e25c-44a1-a152-4ff0a7852e07" />

**Núcleo del negocio**
- `PRODUCTO` — el catálogo de prendas/accesorios con precio y stock
- `CATEGORIA` — agrupa productos (vestidos, accesorios, calzado, etc.)
- `PROVEEDOR` — quién surte la mercancía

**Ventas y clientes**
- `CLIENTE` — datos del comprador y su historial
- `PEDIDO` — cada transacción con su estado (pendiente, enviado, entregado)
- `DETALLE_PEDIDO` — tabla intermedia que desglosa qué productos y cantidades lleva cada pedido
- `PAGO` — método y fecha de cobro por pedido

**Operación interna**
- `EMPLEADO` — vendedoras, encargadas, personal que gestiona pedidos

**Relaciones clave a destacar:**
- Un cliente puede tener muchos pedidos, pero cada pedido pertenece a un solo cliente.
- Un pedido contiene uno o más productos a través de `DETALLE_PEDIDO` (relación muchos a muchos resuelta con tabla intermedia).
- Un producto pertenece a una categoría y tiene un proveedor.

## las entidades con sus atributos y tipo en forma de tabla para cada una de las entidades

## Tablas
<img width="1440" height="2890" alt="image" src="https://github.com/user-attachments/assets/a5e83718-9bcc-4230-b1f3-ef7fc8a074fe" />

## de acuerdo con su respusta anterior puedes generar un script en sql para descargar con el nombre de bdboutique.sql para las entidades con sus relaciones

El script incluye todo lo siguiente:

**Estructura (DDL)**
- Creación de la base de datos `bdboutique` con charset `utf8mb4`
- Las 8 tablas en orden correcto para respetar las dependencias entre llaves foráneas
- Restricciones `CHECK` en campos numéricos (precios, cantidades, descuentos)
- Campos `UNIQUE` en emails de cliente y empleado
- Valores `DEFAULT` en fechas, estado del pedido y totales
- Índices adicionales en columnas de búsqueda frecuente

**Datos de prueba (DML)**
- 5 categorías, 3 proveedores, 5 productos
- 2 empleados, 3 clientes
- 3 pedidos con sus detalles y pagos correspondientes

Para ejecutarlo: `mysql -u root -p < bdboutique.sql` o importarlo desde MySQL Workbench / phpMyAdmin.
