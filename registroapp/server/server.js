const express = require('express');
const cors = require('cors');
const path = require('path');
const fs = require('fs');

const app = express();
const PORT = process.env.PORT || 3000;

// Configuración de Middlewares
app.use(cors());
app.use(express.json());

// Directorio y Base de Datos SQLite
const dbDir = path.join(__dirname, 'data');
if (!fs.existsSync(dbDir)) {
  fs.mkdirSync(dbDir, { recursive: true });
}

const dbPath = path.join(dbDir, 'registroapp.db');

// Inicializar SQLite nativo de Node.js (Node 22+) o compatible
let db;
try {
  const { DatabaseSync } = require('node:sqlite');
  db = new DatabaseSync(dbPath);
} catch (err) {
  try {
    const Database = require('better-sqlite3');
    db = new Database(dbPath);
  } catch (err2) {
    console.error('Error al inicializar SQLite:', err.message);
    process.exit(1);
  }
}

// Configurar pragmas
try {
  db.exec('PRAGMA journal_mode = WAL;');
  db.exec('PRAGMA foreign_keys = ON;');
} catch (_) {}

// Crear tablas si no existen
db.exec(`
  CREATE TABLE IF NOT EXISTS clientes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nombre TEXT NOT NULL,
    telefono TEXT NOT NULL UNIQUE,
    correo TEXT
  );

  CREATE TABLE IF NOT EXISTS ordenes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    folio TEXT NOT NULL UNIQUE,
    cliente_id INTEGER NOT NULL,
    fecha TEXT NOT NULL,
    equipo TEXT,
    problema TEXT,
    estado TEXT NOT NULL,
    diagnostico TEXT,
    observaciones TEXT,
    FOREIGN KEY (cliente_id) REFERENCES clientes (id)
  );
`);

// ==========================================
// 1. ENDPOINTS DE SALUD Y ESTADO
// ==========================================

// Página de inicio (cuando abren http://localhost:3000 en el navegador)
app.get('/', (req, res) => {
  let totalOrdenes = 0;
  let totalClientes = 0;
  try {
    totalOrdenes = db.prepare('SELECT COUNT(*) AS count FROM ordenes').get().count;
    totalClientes = db.prepare('SELECT COUNT(*) AS count FROM clientes').get().count;
  } catch (_) {}

  res.send(`<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Servidor - Servicio Técnico</title>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; background: #0f172a; color: #f8fafc; display: flex; align-items: center; justify-content: center; min-height: 100vh; }
    .card { background: #1e293b; border-radius: 16px; padding: 40px; max-width: 480px; width: 90%; text-align: center; border: 1px solid #334155; }
    .icon { font-size: 56px; margin-bottom: 16px; }
    h1 { font-size: 22px; font-weight: 700; margin-bottom: 8px; color: #f1f5f9; }
    .status { display: inline-flex; align-items: center; gap: 8px; background: #064e3b; color: #34d399; padding: 6px 16px; border-radius: 20px; font-size: 13px; font-weight: 600; margin: 14px 0 24px; }
    .dot { width: 8px; height: 8px; background: #34d399; border-radius: 50%; animation: pulse 1.5s infinite; }
    @keyframes pulse { 0%, 100% { opacity: 1; } 50% { opacity: 0.3; } }
    .stats { display: flex; gap: 12px; margin-bottom: 24px; }
    .stat { flex: 1; background: #0f172a; border-radius: 10px; padding: 16px; }
    .stat-num { font-size: 28px; font-weight: 800; color: #60a5fa; }
    .stat-label { font-size: 12px; color: #94a3b8; margin-top: 4px; }
    .info { background: #0f172a; border-radius: 10px; padding: 16px; text-align: left; }
    .info-row { display: flex; justify-content: space-between; padding: 6px 0; border-bottom: 1px solid #1e293b; font-size: 13px; }
    .info-row:last-child { border-bottom: none; }
    .info-label { color: #94a3b8; }
    .info-val { color: #60a5fa; font-weight: 600; font-family: monospace; }
    p { color: #64748b; font-size: 13px; margin-top: 18px; }
  </style>
</head>
<body>
  <div class="card">
    <div class="icon">🔧</div>
    <h1>Servidor de Servicio Técnico</h1>
    <div class="status"><div class="dot"></div> EN LÍNEA</div>
    <div class="stats">
      <div class="stat">
        <div class="stat-num">${totalOrdenes}</div>
        <div class="stat-label">Órdenes</div>
      </div>
      <div class="stat">
        <div class="stat-num">${totalClientes}</div>
        <div class="stat-label">Clientes</div>
      </div>
    </div>
    <div class="info">
      <div class="info-row"><span class="info-label">Puerto</span><span class="info-val">:3000</span></div>
      <div class="info-row"><span class="info-label">Estado</span><span class="info-val">OK</span></div>
      <div class="info-row"><span class="info-label">Hora del servidor</span><span class="info-val">${new Date().toLocaleTimeString('es-MX')}</span></div>
    </div>
    <p>Este es el servidor backend de la app. Conéctate desde la aplicación usando la IP de esta PC.</p>
  </div>
</body>
</html>`);
});

app.get('/api/health', (req, res) => {
  res.json({
    status: 'ok',
    message: 'Servidor de Servicio Técnico en funcionamiento',
    serverTime: new Date().toISOString()
  });
});

app.get('/api/stats', (req, res) => {
  try {
    const totalClientes = db.prepare('SELECT COUNT(*) AS count FROM clientes').get().count;
    const totalOrdenes = db.prepare('SELECT COUNT(*) AS count FROM ordenes').get().count;

    const pendientes = db.prepare('SELECT COUNT(*) AS count FROM ordenes WHERE estado = ?').get('Pendiente').count;
    const enProceso = db.prepare('SELECT COUNT(*) AS count FROM ordenes WHERE estado = ?').get('En proceso').count;
    const terminadas = db.prepare('SELECT COUNT(*) AS count FROM ordenes WHERE estado = ?').get('Terminada').count;
    const canceladas = db.prepare('SELECT COUNT(*) AS count FROM ordenes WHERE estado = ?').get('Cancelada').count;

    res.json({
      totalClientes: Number(totalClientes),
      totalOrdenes: Number(totalOrdenes),
      pendientes: Number(pendientes),
      enProceso: Number(enProceso),
      terminadas: Number(terminadas),
      canceladas: Number(canceladas)
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ==========================================
// 2. ENDPOINTS DE CLIENTES
// ==========================================
app.get('/api/clientes', (req, res) => {
  try {
    const clientes = db.prepare('SELECT * FROM clientes ORDER BY nombre ASC').all();
    res.json(clientes);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/clientes/existe-telefono', (req, res) => {
  try {
    const { telefono, excluirId } = req.query;
    if (!telefono) {
      return res.status(400).json({ error: 'Parámetro telefono requerido' });
    }

    let query = 'SELECT id FROM clientes WHERE telefono = ?';
    const params = [telefono];

    if (excluirId) {
      query += ' AND id != ?';
      params.push(Number(excluirId));
    }

    const row = db.prepare(query).get(...params);
    res.json({ exists: !!row });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post('/api/clientes', (req, res) => {
  try {
    const { nombre, telefono, correo } = req.body;
    if (!nombre || !telefono) {
      return res.status(400).json({ error: 'Nombre y teléfono son obligatorios' });
    }

    const stmt = db.prepare('INSERT INTO clientes (nombre, telefono, correo) VALUES (?, ?, ?)');
    const result = stmt.run(nombre, telefono, correo || null);

    res.status(201).json({ id: Number(result.lastInsertRowid) });
  } catch (error) {
    if (error.message && error.message.includes('UNIQUE constraint failed: clientes.telefono')) {
      return res.status(409).json({ error: 'El teléfono ya está registrado' });
    }
    res.status(500).json({ error: error.message });
  }
});

app.put('/api/clientes/:id', (req, res) => {
  try {
    const { id } = req.params;
    const { nombre, telefono, correo } = req.body;

    const stmt = db.prepare('UPDATE clientes SET nombre = ?, telefono = ?, correo = ? WHERE id = ?');
    const result = stmt.run(nombre, telefono, correo || null, Number(id));

    res.json({ changes: Number(result.changes) });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.delete('/api/clientes/:id', (req, res) => {
  try {
    const { id } = req.params;
    const stmt = db.prepare('DELETE FROM clientes WHERE id = ?');
    const result = stmt.run(Number(id));

    res.json({ changes: Number(result.changes) });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ==========================================
// 3. ENDPOINTS DE ÓRDENES
// ==========================================
app.get('/api/ordenes', (req, res) => {
  try {
    const stmt = db.prepare(`
      SELECT ordenes.*, 
             clientes.nombre AS cliente_nombre, 
             clientes.telefono AS cliente_telefono, 
             clientes.correo AS cliente_correo
      FROM ordenes
      LEFT JOIN clientes ON ordenes.cliente_id = clientes.id
      ORDER BY ordenes.id DESC
    `);
    const ordenes = stmt.all();
    res.json(ordenes);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/ordenes/siguiente-folio', (req, res) => {
  try {
    const fechaParam = req.query.fecha;
    const date = fechaParam ? new Date(fechaParam) : new Date();

    const anio = date.getFullYear().toString();
    const mes = String(date.getMonth() + 1).padStart(2, '0');
    const dia = String(date.getDate()).padStart(2, '0');
    const prefijo = `${anio}${mes}${dia}-`;

    const filas = db.prepare("SELECT folio FROM ordenes WHERE folio LIKE ?").all(`${prefijo}%`);

    let maxNumero = 0;
    for (const fila of filas) {
      if (fila.folio && fila.folio.startsWith(prefijo)) {
        const numeroStr = fila.folio.substring(prefijo.length);
        const numero = parseInt(numeroStr, 10);
        if (!isNaN(numero) && numero > maxNumero) {
          maxNumero = numero;
        }
      }
    }

    const siguienteNumero = maxNumero + 1;
    const numeroFormateado = String(siguienteNumero).padStart(4, '0');
    const folioGenerado = `${prefijo}${numeroFormateado}`;

    res.json({ folio: folioGenerado });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/ordenes/:id', (req, res) => {
  try {
    const { id } = req.params;
    const stmt = db.prepare(`
      SELECT ordenes.*, 
             clientes.nombre AS cliente_nombre, 
             clientes.telefono AS cliente_telefono, 
             clientes.correo AS cliente_correo
      FROM ordenes
      LEFT JOIN clientes ON ordenes.cliente_id = clientes.id
      WHERE ordenes.id = ?
    `);
    const orden = stmt.get(Number(id));

    if (!orden) {
      return res.status(404).json({ error: 'Orden no encontrada' });
    }

    res.json(orden);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post('/api/ordenes', (req, res) => {
  try {
    const {
      folio,
      cliente_id,
      clienteid,
      fecha,
      equipo,
      problema,
      estado,
      diagnostico,
      observaciones
    } = req.body;

    const cId = Number(cliente_id || clienteid);
    if (!folio || !cId || !fecha || !estado) {
      return res.status(400).json({ error: 'Folio, cliente_id, fecha y estado son obligatorios' });
    }

    const stmt = db.prepare(`
      INSERT INTO ordenes (
        folio, cliente_id, fecha, equipo, problema, estado, diagnostico, observaciones
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    `);

    const result = stmt.run(
      folio,
      cId,
      fecha,
      equipo || null,
      problema || null,
      estado,
      diagnostico || null,
      observaciones || null
    );

    res.status(201).json({ id: Number(result.lastInsertRowid) });
  } catch (error) {
    if (error.message && error.message.includes('UNIQUE constraint failed: ordenes.folio')) {
      return res.status(409).json({ error: 'El folio ya existe' });
    }
    res.status(500).json({ error: error.message });
  }
});

app.put('/api/ordenes/:id', (req, res) => {
  try {
    const { id } = req.params;
    const {
      cliente_id,
      clienteid,
      fecha,
      equipo,
      problema,
      estado,
      diagnostico,
      observaciones
    } = req.body;

    const cId = (cliente_id || clienteid) ? Number(cliente_id || clienteid) : null;

    const stmt = db.prepare(`
      UPDATE ordenes SET 
        cliente_id = COALESCE(?, cliente_id),
        fecha = COALESCE(?, fecha),
        equipo = ?,
        problema = ?,
        estado = COALESCE(?, estado),
        diagnostico = ?,
        observaciones = ?
      WHERE id = ?
    `);

    const result = stmt.run(
      cId,
      fecha || null,
      equipo || null,
      problema || null,
      estado || null,
      diagnostico || null,
      observaciones || null,
      Number(id)
    );

    res.json({ changes: Number(result.changes) });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.delete('/api/ordenes/:id', (req, res) => {
  try {
    const { id } = req.params;

    // Buscar la orden antes de eliminarla
    const orden = db.prepare('SELECT cliente_id FROM ordenes WHERE id = ?').get(Number(id));
    if (!orden) {
      return res.status(404).json({ error: 'Orden no encontrada' });
    }

    const clienteId = orden.cliente_id;

    // Eliminar la orden
    const deleteOrdenStmt = db.prepare('DELETE FROM ordenes WHERE id = ?');
    const result = deleteOrdenStmt.run(Number(id));

    // Verificar si el cliente tiene otras órdenes
    if (clienteId) {
      const otras = db.prepare('SELECT COUNT(*) AS count FROM ordenes WHERE cliente_id = ?').get(clienteId);
      if (otras.count === 0) {
        db.prepare('DELETE FROM clientes WHERE id = ?').run(clienteId);
      }
    }

    res.json({ changes: Number(result.changes) });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ==========================================
// INICIO DEL SERVIDOR
// ==========================================
app.listen(PORT, '0.0.0.0', () => {
  console.log('====================================================');
  console.log(`🚀 SERVIDOR DE SERVICIO TÉCNICO INICIADO`);
  console.log(`📡 Puerto: ${PORT}`);
  console.log(`💾 Base de datos: ${dbPath}`);
  console.log(`🌐 Acceso local: http://localhost:${PORT}`);
  console.log(`📱 En tu red local: http://<IP_DE_ESTA_PC>:${PORT}`);
  console.log('====================================================');
});
