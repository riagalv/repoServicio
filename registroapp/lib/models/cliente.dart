class Cliente {
  final int? id;
  final String nombre;
  final String telefono;
  final String? correo;

  Cliente({
    this.id,
    required this.nombre,
    required this.telefono,
    this.correo,
  });

  // Convertir Cliente a un mapa para SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'telefono': telefono,
      'correo': correo,
    };
  }

  // Crear un Cliente a partir de los datos de SQLite
  factory Cliente.fromMap(Map<String, dynamic> map) {
    return Cliente(
      id: map['id'],
      nombre: map['nombre'],
      telefono: map['telefono'],
      correo: map['correo'],
    );
  }
}
