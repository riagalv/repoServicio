# 🌐 Guía de Uso: Servidor y Acceso Multi-Computadora

Esta guía te explica cómo poner a funcionar tu PC como Servidor y conectar otras computadoras, ya sea en la misma oficina/taller o por Internet.

---

## 🚀 Paso 1: Iniciar el Servidor en tu PC Principal

1. Entra a la carpeta `server/`.
2. Haz doble clic en el archivo **`iniciar_servidor.bat`**.
   - *(La primera vez instalará automáticamente los paquetes necesarios si tienes Node.js instalado)*.
3. Verás una ventana negra que indica:
   ```
   🚀 SERVIDOR DE SERVICIO TÉCNICO INICIADO
   📡 Puerto: 3000
   🌐 Acceso local: http://localhost:3000
   ```
4. **¡Listo! Deja esa ventana abierta mientras quieras que el servidor esté activo.**

---

## 🏠 Paso 2: Conectar computadoras en la Misma Red Local (Mismo Wi-Fi)

Si las otras computadoras están en la misma casa, taller u oficina:

1. **Obtén la IP de la PC Servidor**:
   - En la PC Servidor, abre una terminal (CMD) y escribe `ipconfig`.
   - Busca la línea **`Dirección IPv4`** (ejemplo: `192.168.1.50`).
2. **En las otras computadoras**:
   - Abre la aplicación de Registro de Órdenes.
   - Haz clic en el botón de **⚙️ Servidor** (en la esquina superior derecha).
   - Selecciona **Modo Servidor Remoto**.
   - Escribe la dirección con el puerto: `http://192.168.1.50:3000` (reemplaza con tu IP).
   - Haz clic en **Probar Conexión** y luego en **Guardar**.

---

## 🌍 Paso 3: Conectar computadoras por Internet (Desde cualquier lugar del mundo)

Para conectar computadoras fuera de tu red local de forma **gratuita, segura y sin abrir puertos en el módem**, usamos **Cloudflare Tunnel**:

1. Descarga la herramienta gratuita **cloudflared** en la PC Servidor:
   - [Descargar Cloudflared para Windows](https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-windows-amd64.exe)
2. Guarda el archivo `cloudflared.exe` en tu PC.
3. Abre una terminal (CMD o PowerShell) en esa carpeta y ejecuta:
   ```cmd
   cloudflared tunnel --url http://localhost:3000
   ```
4. Cloudflare te dará una dirección pública segura HTTPS como:
   `https://tu-nombre-aleatorio.trycloudflare.com`
5. **¡Listo!** En cualquier computadora en cualquier parte del mundo, pones esa dirección HTTPS en la configuración de la app y se conectará en tiempo real.

---

## ⚙️ Modos de la Aplicación

- **Modo Local**: Usa la base de datos interna de la computadora (ideal para trabajar sin red).
- **Modo Servidor Remoto**: Se conecta a la PC Servidor o a la dirección de Internet para compartir toda la información en tiempo real.
