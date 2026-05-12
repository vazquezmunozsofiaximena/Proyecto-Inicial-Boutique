Este es el plan de implementación detallado para **Antigravity**, la plataforma de gestión integral para tu boutique. El diseño se centrará en una estética "Soft Glam" con tonos lilas y rosas pasteles, optimizado para ser responsivo en móviles (Android/iOS), navegadores web y escritorio (Windows).

---

## 1. Configuración del Ecosistema y Dependencias

Antes de construir la interfaz, es vital preparar el archivo `pubspec.yaml` con las dependencias necesarias para la persistencia de datos y el diseño moderno.

### Dependencias Clave

* **Firebase Core & Auth:** Gestión de usuarios.
* **Cloud Firestore:** Base de datos en tiempo real para las 8 tablas.
* **Provider o Riverpod:** Para la gestión de estados (vital para que el CRUD se actualice instantáneamente).
* **Google Fonts:** Para usar tipografías elegantes (ej. *Poppins* o *Montserrat*).
* **Font Awesome:** Para iconos de moda y retail.

---

## 2. Arquitectura de Archivos y Carpetas (Estructura `/lib`)

Para un proyecto multiplataforma escalable, organizaremos el código en la carpeta `lib` (en Flutter, la lógica principal reside en `lib`, no en `bin`).

* **`/models`:** Clases Dart para cada tabla (Categoría, Producto, etc.).
* **`/services`:** Conexión con Firebase (`firebase_service.dart`).
* **`/providers`:** Lógica de negocio y manejo de datos.
* **`/ui`:**
* **`/auth`:** Pantallas de Login, Registro y Recuperación.
* **`/shared`:** Widgets reutilizables (Botones rosas, inputs decorados).
* **`/views`:** Pantallas de inicio y los 8 módulos CRUD.
* **`/layout`:** Adaptabilidad para Web/Desktop (Sidebar) vs Móvil (BottomNav).



---

## 3. Estrategia de Diseño (UI/UX Boutique)

El layout utilizará un esquema de color **Pastel Dream**:

* **Primario:** Lila suave (`#E0BBE4`)
* **Secundario:** Rosa pastel (`#FFDFD3`)
* **Acento:** Oro rosa o Blanco seda para contrastes.
* **Widgets:** Uso de `Card` con elevación mínima, bordes muy redondeados (`BorderRadius.circular(20)`) y efectos de desenfoque (*Glassmorphism*) en la versión Web/Windows.

---

## 4. Plan de Implementación por Módulos

### Módulo A: Autenticación (Firebase Auth)

1. **Login:** Formulario centralizado con validación de email.
2. **Registro:** Vinculación directa con la creación de un perfil en la tabla "Empleado" si es necesario.
3. **Recuperación:** Envío de correo electrónico automático vía Firebase.

### Módulo B: Dashboard Principal

* **Versión Web/Windows:** Un panel lateral (Sidebar) fijo a la izquierda con íconos elegantes para navegar entre Categorías, Productos, Pedidos, etc.
* **Versión Móvil:** Un menú tipo cuadrícula (Grid) en el inicio con tarjetas de colores pasteles para acceso rápido.

### Módulo C: Gestión de Datos (CRUD en Firestore)

Se implementará una vista estandarizada para las 8 tablas con las siguientes funciones:

1. **Listado:** `StreamBuilder` para ver cambios en tiempo real.
2. **Creación/Edición:** Modales (BottomSheets en móvil, Dialogs en Web) que respeten la paleta de colores lila.
3. **Eliminación:** Alertas de confirmación estilizadas.

---

## 5. Diccionario de Datos (Estructura en Firestore)

Cada tabla se mapeará como una colección en el proyecto **BDcrudboutique**:

| Colección | Campos Principales | Relación (Foreign Key) |
| --- | --- | --- |
| **Categorias** | nombre, descripción | - |
| **Proveedor** | nombre, contacto, email | - |
| **Producto** | nombre, precio, stock | idcategoria, idproveedor |
| **Cliente** | nombre, email, dirección | - |
| **Pedido** | fecha, estado, total | idcliente, idempleado |
| **DetallePedido** | cantidad, precioUnitario | idpedido, idproducto |
| **Pago** | monto, método, fecha | idpedido |

---

## 6. Pasos para la Integración con Firebase

1. **Consola Firebase:** Crear el proyecto `BDcrudboutique`.
2. **Flutterfire CLI:** Ejecutar la configuración para generar el archivo `firebase_options.dart` que vincula las 4 plataformas.
3. **Habilitar Servicios:** Activar *Email/Password Authentication* y *Firestore* en modo producción con reglas de seguridad básicas.
4. **Inicialización:** Configurar el `main.dart` para asegurar que Firebase cargue antes de lanzar la interfaz de la boutique.

---

## 7. Optimización Multiplataforma

* **Web/Windows:** Las tablas de datos utilizarán `DataTable` o `PaginatedDataTable` para aprovechar el ancho de pantalla.
* **Android/iOS:** Se utilizarán `ListView.builder` con gestos de deslizamiento (swiping) para editar o eliminar registros de forma intuitiva.

Este plan garantiza una aplicación cohesiva, visualmente atractiva y técnicamente robusta para la administración de la boutique **Antigravity**.
