# 📋 Manual de Usuario — Sistema de Soporte Técnico

**Versión:** 1.0.0  
**Fecha:** Octubre 2026  
**Sistema:** Sistema de Gestión de Órdenes de Servicio Técnico

---

## Tabla de Contenidos

1. [Introducción](#introducción)
2. [Inicio de la Aplicación](#inicio-de-la-aplicación)
3. [Pantalla Principal (Dashboard)](#pantalla-principal-dashboard)
4. [Gestión de Órdenes](#gestión-de-órdenes)
   - [Crear una Nueva Orden](#crear-una-nueva-orden)
   - [Ver Lista de Órdenes](#ver-lista-de-órdenes)
   - [Ver Detalle de una Orden](#ver-detalle-de-una-orden)
   - [Editar una Orden](#editar-una-orden)
   - [Eliminar una Orden](#eliminar-una-orden)
   - [Exportar Orden a PDF](#exportar-orden-a-pdf)
5. [Estados de una Orden](#estados-de-una-orden)
6. [Búsqueda y Filtros](#búsqueda-y-filtros)
7. [Base de Datos — Respaldo e Importación](#base-de-datos--respaldo-e-importación)
   - [Exportar / Descargar Base de Datos](#exportar--descargar-base-de-datos)
   - [Importar / Cargar Base de Datos](#importar--cargar-base-de-datos)
8. [Configuración del Servidor](#configuración-del-servidor)
   - [Modo Local](#modo-local)
   - [Modo Servidor Remoto](#modo-servidor-remoto)
9. [Uso Multi-Computadora](#uso-multi-computadora)
   - [Misma Red (Wi-Fi u Oficina)](#misma-red-wi-fi-u-oficina)
   - [Acceso por Internet (Cloudflare Tunnel)](#acceso-por-internet-cloudflare-tunnel)
10. [Preguntas Frecuentes (FAQ)](#preguntas-frecuentes-faq)

---

## Introducción

El **Sistema de Soporte Técnico** es una aplicación de escritorio diseñada para que talleres y negocios de reparación puedan registrar, consultar y administrar órdenes de servicio de manera sencilla y eficiente.

### ¿Qué puedes hacer con esta aplicación?

- Registrar órdenes de servicio con datos del cliente y del equipo
- Seguir el estado de cada reparación (Pendiente, En proceso, Finalizada)
- Buscar órdenes por nombre, teléfono, folio o equipo
- Exportar órdenes en formato PDF para entregar al cliente
- Respaldar y restaurar la base de datos
- Usar la aplicación en múltiples computadoras al mismo tiempo (modo servidor)

---

## Inicio de la Aplicación

Al abrir la aplicación, verás automáticamente el **Dashboard** o pantalla principal. No se requiere inicio de sesión.

> **Nota:** Si la aplicación está configurada en **Modo Servidor Remoto**, al iniciar se conectará automáticamente al servidor configurado previamente.

---

## Pantalla Principal (Dashboard)

La pantalla está dividida en dos áreas:

### Menú lateral izquierdo (azul)

| Elemento | Descripción |
|---|---|
| Icono de herramienta | Logo del sistema |
| **SERVICIO TÉCNICO** | Nombre del sistema |
| **Inicio** | Lleva de regreso al Dashboard |

### Barra superior (header)

En la parte superior derecha encontrarás los siguientes botones:

| Botón / Elemento | Función |
|---|---|
| Ícono Descargar | Exportar / respaldar la base de datos |
| Ícono Subir | Importar / cargar una base de datos |
| Indicador de modo | Muestra si estás en **Modo Local** o **Servidor Remoto**. Haz clic para cambiar la configuración. |
| Técnico | Usuario activo |

### Fichas de resumen (tarjetas)

El Dashboard muestra 4 fichas con contadores en tiempo real:

| Ficha | Color | Descripción |
|---|---|---|
| **Órdenes** | Azul | Total de órdenes registradas |
| **Pendientes** | Naranja | Órdenes aún sin atender |
| **En proceso** | Índigo | Órdenes en reparación activa |
| **Finalizadas** | Verde | Órdenes completadas |

> **Tip:** Haz clic sobre cualquier ficha para ir directamente a la lista de órdenes filtrada por ese estado.

---

## Gestión de Órdenes

### Crear una Nueva Orden

1. En el Dashboard, haz clic en el botón **`+ Nueva orden`** (esquina superior derecha del área de contenido).
2. Se abrirá un formulario con dos secciones:

#### Sección: Datos del Cliente

| Campo | Obligatorio | Descripción |
|---|---|---|
| **Nombre** | Sí | Nombre completo del cliente |
| **Teléfono** | Sí | Número de contacto (se usa para identificar clientes repetidos) |
| **Correo electrónico** | No | Correo del cliente |

> **Importante:** Si el teléfono ya existe en el sistema, la orden se asociará automáticamente al cliente existente, sin crear uno nuevo.

#### Sección: Datos del Servicio

| Campo | Obligatorio | Descripción |
|---|---|---|
| **Equipo** | Sí | Descripción del aparato (ej: "Laptop HP Pavilion") |
| **Problema reportado** | Sí | Descripción del fallo o queja del cliente |
| **Estado** | — | Estado inicial de la orden (por defecto: Pendiente) |
| **Diagnóstico** | No | Resultado del diagnóstico técnico |
| **Observaciones** | No | Notas internas o detalles adicionales |

3. Haz clic en **`Guardar orden`**.
4. Aparecerá una ventana de confirmación con el **folio generado** y los detalles de la orden.
5. Desde esa ventana puedes opcionalmente **Exportar a PDF** o hacer clic en **Aceptar** para cerrar.

---

### Ver Lista de Órdenes

Para acceder a la lista completa de órdenes:
- Haz clic en cualquiera de las **fichas del Dashboard**, o
- Usa el botón **(Atrás)** que aparece cuando estás en la vista de órdenes para regresar.

La vista muestra una **tabla** con las columnas:

| Columna | Descripción |
|---|---|
| **Folio** | Identificador único generado automáticamente |
| **Fecha** | Fecha en que se registró la orden |
| **Equipo** | Nombre o descripción del equipo |
| **Estado** | Etiqueta visual de color según el estado |
| **Acciones** | Botón `Ver detalle` para abrir la ficha completa |

---

### Ver Detalle de una Orden

Haz clic en **`Ver detalle`** en cualquier fila de la tabla. Se abrirá una ventana con toda la información organizada en secciones:

- **Información General:** Folio, Fecha, Estado
- **Datos del Cliente:** Nombre, Teléfono, Correo
- **Detalles del Servicio y Equipo:** Equipo, Problema, Diagnóstico, Observaciones

Desde esta ventana también puedes:
- **Editar** la orden
- **Exportar a PDF**
- **Eliminar** la orden
- **Cerrar** sin hacer cambios

---

### Editar una Orden

1. Abre el detalle de la orden y haz clic en **`Editar`**.

El formulario de edición permite modificar:

| Campo editable | Descripción |
|---|---|
| **Cliente** | Cambiar el cliente asociado (selección de la lista existente) |
| **Equipo** | Actualizar la descripción del equipo |
| **Problema reportado** | Modificar la descripción del problema |
| **Estado** | Actualizar el estado de la orden |
| **Diagnóstico** | Agregar o modificar el diagnóstico técnico |
| **Observaciones** | Agregar o modificar notas adicionales |

> **Nota:** El **folio** y la **fecha** de creación no pueden modificarse.

2. Haz clic en **`Guardar cambios`** para aplicar.

---

### Eliminar una Orden

1. Abre el detalle de la orden.
2. Haz clic en **`Eliminar`** (botón rojo).
3. El sistema mostrará una confirmación.
4. Confirma haciendo clic en **`Eliminar`**, o cancela con **`Cancelar`**.

> **Advertencia:** La eliminación de órdenes es permanente y no se puede deshacer.

---

### Exportar Orden a PDF

Puedes exportar cualquier orden a un archivo PDF:

1. **Opción 1:** Al crear una orden, desde la ventana de confirmación, haz clic en **`Exportar a PDF`**.
2. **Opción 2:** Desde el detalle de una orden existente, haz clic en **`Exportar a PDF`**.

Se abrirá el explorador de archivos para elegir dónde guardar el PDF. Al finalizar, aparecerá un mensaje de confirmación.

---

## Estados de una Orden

Cada orden tiene uno de los siguientes estados:

| Estado | Color | Significado |
|---|---|---|
| **Pendiente** | Amarillo/Ámbar | La orden fue registrada pero aún no se ha iniciado la reparación |
| **En proceso** | Azul | El técnico está trabajando activamente en la reparación |
| **Finalizada** | Verde | La reparación fue completada |

El estado puede cambiarse en cualquier momento desde el formulario de edición.

---

## Búsqueda y Filtros

En la pantalla de **Órdenes** encontrarás herramientas para encontrar rápidamente lo que buscas:

### Filtros por estado (botones segmentados)

| Filtro | Descripción |
|---|---|
| **Todas (N)** | Muestra todas las órdenes |
| **Pendientes (N)** | Solo órdenes pendientes |
| **En proceso (N)** | Solo órdenes en proceso |
| **Finalizadas (N)** | Solo órdenes finalizadas |

> El número entre paréntesis indica la cantidad de órdenes en ese estado.

### Buscador de texto

Escribe en el campo de búsqueda para filtrar por:
- Folio de la orden
- Nombre del cliente
- Teléfono
- Equipo
- Descripción del problema
- Diagnóstico

> Para limpiar la búsqueda, haz clic en el ícono **X** que aparece dentro del campo.

Si ninguna orden coincide con el filtro o búsqueda aplicado, aparecerá el botón **`Restablecer filtros`** para limpiar los criterios.

---

## Base de Datos — Respaldo e Importación

La aplicación guarda todos los datos localmente. Para proteger tu información, puedes hacer respaldos manuales.

### Exportar / Descargar Base de Datos

1. Haz clic en el ícono de **descarga** en la barra superior.
2. Se abrirá el explorador de archivos para elegir dónde guardar el archivo de respaldo (`.db`).
3. Al finalizar, aparecerá el mensaje: *"Base de datos exportada correctamente"*.

> **Recomendación:** Realiza un respaldo periódico y guárdalo en una unidad externa o en la nube.

### Importar / Cargar Base de Datos

> **Precaución:** Esta acción **reemplaza TODOS los datos actuales** con los del archivo que selecciones. Se creará un respaldo automático antes de hacer el reemplazo.

1. Haz clic en el ícono de **subida** en la barra superior.
2. El sistema mostrará una confirmación de advertencia.
3. Haz clic en **`Sí, cargar`** para continuar o **`Cancelar`** para abortar.
4. Selecciona el archivo `.db` de respaldo en el explorador de archivos.
5. Al finalizar, los datos se actualizarán y aparecerá un mensaje de confirmación.

---

## Configuración del Servidor

La aplicación puede funcionar en dos modos. El indicador en la barra superior muestra el modo activo:

### Modo Local

- **Indicador:** `Modo Local`
- La información se guarda únicamente en la computadora donde está instalada la app.
- Ideal para uso individual o cuando no se necesita compartir información entre equipos.

### Modo Servidor Remoto

- **Indicador:** `Servidor Remoto`
- La aplicación se conecta a un servidor central para sincronizar datos en tiempo real.
- Permite que varias computadoras accedan a los mismos datos simultáneamente.

#### Cómo cambiar la configuración del servidor

1. Haz clic en el indicador de modo en la barra superior.
2. Se abrirá el diálogo de **Configuración del Servidor**.
3. Selecciona el modo deseado y, en caso de Servidor Remoto, ingresa la dirección URL.
4. Haz clic en **`Probar Conexión`** para verificar que sea correcta.
5. Guarda los cambios.

---

## Uso Multi-Computadora

Puedes usar la misma base de datos desde múltiples computadoras al mismo tiempo configurando la aplicación en **Modo Servidor Remoto**.

### Requisito previo: Iniciar el Servidor

En la **PC principal (servidor)**:

1. Abre la carpeta `server/` dentro de la instalación de la aplicación.
2. Haz doble clic en el archivo **`iniciar_servidor.bat`**.
   - La primera vez instalará automáticamente los paquetes necesarios (requiere Node.js instalado).
3. Verás una ventana negra con el mensaje:
   ```
   SERVIDOR DE SERVICIO TÉCNICO INICIADO
   Puerto: 3000
   Acceso local: http://localhost:3000
   ```
4. **Deja esa ventana abierta** mientras quieras mantener el servidor activo.

---

### Misma Red (Wi-Fi u Oficina)

Si las demás computadoras están en la misma red local:

1. En la **PC servidor**, obtén la IP local:
   - Abre el **CMD** (símbolo del sistema) y escribe: `ipconfig`
   - Anota la dirección **IPv4** (ejemplo: `192.168.1.50`).
2. En cada **computadora cliente**:
   - Abre la aplicación.
   - Haz clic en el indicador de modo (esquina superior derecha).
   - Selecciona **Modo Servidor Remoto**.
   - Escribe la dirección: `http://192.168.1.50:3000` *(reemplaza con tu IP real)*.
   - Haz clic en **`Probar Conexión`** y luego en **`Guardar`**.

---

### Acceso por Internet (Cloudflare Tunnel)

Para conectar computadoras fuera de la red local, de forma **gratuita y sin abrir puertos** en el módem:

1. Descarga **cloudflared** en la PC servidor:
   https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-windows-amd64.exe
2. Guarda el archivo `cloudflared.exe` en tu computadora.
3. Abre una terminal (CMD o PowerShell) en la carpeta donde guardaste el archivo y ejecuta:
   ```cmd
   cloudflared tunnel --url http://localhost:3000
   ```
4. Cloudflare generará una dirección pública segura (HTTPS) similar a:
   ```
   https://tu-nombre-aleatorio.trycloudflare.com
   ```
5. En cada computadora remota, configura la app con esa dirección HTTPS como URL del servidor.

> **Nota:** La dirección generada por Cloudflare cambia cada vez que reinicias el túnel.

---

## Preguntas Frecuentes (FAQ)

### ¿Se pueden perder los datos si la aplicación se cierra?

No. Los datos se guardan inmediatamente en la base de datos local al guardar cada orden. No es necesario cerrar la aplicación para que los cambios persistan.

---

### ¿Qué hago si la conexión al servidor falla?

1. Verifica que la **ventana del servidor** (`iniciar_servidor.bat`) siga abierta en la PC principal.
2. Comprueba que ambas computadoras estén en la misma red (o que el túnel de Cloudflare esté activo).
3. Haz clic en **`Probar Conexión`** en la configuración del servidor para diagnosticar el problema.
4. Si el problema persiste, cambia temporalmente a **Modo Local** para seguir trabajando.

---

### ¿Cómo recupero datos después de un error?

Si tienes un archivo de respaldo (`.db`), puedes restaurarlo usando la función **Importar / Cargar Base de Datos** (ícono de subida en la barra superior).

---

### ¿El folio se genera automáticamente?

Sí. El sistema genera el folio de manera automática y única al crear cada orden. **No puedes modificarlo** una vez creada la orden.

---

### ¿Puedo tener varios técnicos usando la app al mismo tiempo?

Sí, siempre que configures la aplicación en **Modo Servidor Remoto**. Todos los técnicos deben apuntar al mismo servidor y verán los mismos datos en tiempo real.

---

### ¿Qué campos son obligatorios al crear una orden?

Los campos obligatorios son:
- **Nombre del cliente**
- **Teléfono del cliente**
- **Equipo**
- **Problema reportado**

---

*Manual generado para el Sistema de Soporte Técnico v1.0.0*
