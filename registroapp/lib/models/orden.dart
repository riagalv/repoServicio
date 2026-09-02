class Orden {
  final int? id;
  final String folio;
  final int clienteId;
  final String fecha;
  final String? equipo;
  final String? problema;
  final String estado;
  final String? diagnostico;
  final String? observaciones;
  final String? clienteNombre;
  final String? clienteTelefono;
  final String? clienteCorreo;

  Orden({
    this.id,
    required this.folio,
    required this.clienteId,
    required this.fecha,
    this.equipo,
    this.problema,
    required this.estado,
    this.diagnostico,
    this.observaciones,
    this.clienteNombre,
    this.clienteTelefono,
    this.clienteCorreo,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'folio': folio,
      'cliente_id': clienteId,
      'fecha': fecha,
      'equipo': equipo,
      'problema': problema,
      'estado': estado,
      'diagnostico': diagnostico,
      'observaciones': observaciones,
    };
  }

  factory Orden.fromMap(Map<String, dynamic> map) {
    return Orden(
      id: map['id'],
      folio: map['folio'],
      clienteId: (map['cliente_id'] ?? map['clienteid'] ?? 0) as int,
      fecha: map['fecha'],
      equipo: map['equipo'],
      problema: map['problema'],
      estado: map['estado'],
      diagnostico: map['diagnostico'],
      observaciones: map['observaciones'],
      clienteNombre: map['cliente_nombre'] ?? map['nombre'],
      clienteTelefono: map['cliente_telefono'] ?? map['telefono'],
      clienteCorreo: map['cliente_correo'] ?? map['correo'],
    );
  }
}

