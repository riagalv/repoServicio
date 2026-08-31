import 'package:flutter/material.dart';

import '../../database/database.dart';
import '../../models/cliente.dart';
import '../../models/orden.dart';

class NuevaOrdenDialog extends StatefulWidget {
  const NuevaOrdenDialog({super.key});

  @override
  State<NuevaOrdenDialog> createState() => _NuevaOrdenDialogState();
}

class _NuevaOrdenDialogState extends State<NuevaOrdenDialog> {
  final _formKey = GlobalKey<FormState>();

  // DATOS DEL CLIENTE
  final nombreController = TextEditingController();
  final telefonoController = TextEditingController();
  final correoController = TextEditingController();

  // DATOS DEL SERVICIO
  final equipoController = TextEditingController();
  final problemaController = TextEditingController();
  final diagnosticoController = TextEditingController();
  final observacionesController = TextEditingController();

  String estado = 'Pendiente';

  bool guardando = false;

  String generarFolio() {
    final ahora = DateTime.now();

    return 'ORD-${ahora.year}'
        '${ahora.month.toString().padLeft(2, '0')}'
        '${ahora.day.toString().padLeft(2, '0')}'
        '-${ahora.millisecondsSinceEpoch}';
  }

  Future<void> guardarOrden() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      guardando = true;
    });

    try {
      final telefono = telefonoController.text.trim();

      // BUSCAR SI EL CLIENTE YA EXISTE
      final datosClientes =
          await DatabaseHelper.obtenerClientes();

      final clientes = datosClientes
          .map((dato) => Cliente.fromMap(dato))
          .toList();

      Cliente? clienteExistente;

      for (final cliente in clientes) {
        if (cliente.telefono == telefono) {
          clienteExistente = cliente;
          break;
        }
      }

      int clienteId;

      // SI EL CLIENTE YA EXISTE
      if (clienteExistente != null) {
        clienteId = clienteExistente.id!;
      } else {
        // CREAR NUEVO CLIENTE
        final nuevoCliente = Cliente(
          nombre: nombreController.text.trim(),
          telefono: telefono,
          correo: correoController.text.trim().isEmpty
              ? null
              : correoController.text.trim(),
        );

        clienteId = await DatabaseHelper.insertarCliente(
          nuevoCliente.toMap(),
        );
      }

      // CREAR LA ORDEN
      final orden = Orden(
        folio: generarFolio(),
        clienteId: clienteId,
        fecha: DateTime.now().toIso8601String(),
        equipo: equipoController.text.trim().isEmpty
            ? null
            : equipoController.text.trim(),
        problema: problemaController.text.trim().isEmpty
            ? null
            : problemaController.text.trim(),
        estado: estado,
        diagnostico: diagnosticoController.text.trim().isEmpty
            ? null
            : diagnosticoController.text.trim(),
        observaciones: observacionesController.text.trim().isEmpty
            ? null
            : observacionesController.text.trim(),
      );

      await DatabaseHelper.insertarOrden(
        orden.toMap(),
      );

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          guardando = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Error al guardar la orden',
            ),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    nombreController.dispose();
    telefonoController.dispose();
    correoController.dispose();
    equipoController.dispose();
    problemaController.dispose();
    diagnosticoController.dispose();
    observacionesController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nueva orden de servicio'),
      content: SizedBox(
        width: 650,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // =========================
                // DATOS DEL CLIENTE
                // =========================

                const Text(
                  'Datos del cliente',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 15),

                TextFormField(
                  controller: nombreController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El nombre es obligatorio';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 15),

                TextFormField(
                  controller: telefonoController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Teléfono *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El teléfono es obligatorio';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 15),

                TextFormField(
                  controller: correoController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Correo electrónico',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                ),

                const SizedBox(height: 25),

                const Divider(),

                const SizedBox(height: 15),

                // =========================
                // DATOS DEL SERVICIO
                // =========================

                const Text(
                  'Datos del servicio',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 15),

                TextFormField(
                  controller: equipoController,
                  decoration: const InputDecoration(
                    labelText: 'Equipo *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.computer),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El equipo es obligatorio';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 15),

                TextFormField(
                  controller: problemaController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Problema reportado *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.report_problem),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Describe el problema';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 15),

                DropdownButtonFormField<String>(
                  value: estado,
                  decoration: const InputDecoration(
                    labelText: 'Estado',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.assignment),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'Pendiente',
                      child: Text('Pendiente'),
                    ),
                    DropdownMenuItem(
                      value: 'En proceso',
                      child: Text('En proceso'),
                    ),
                    DropdownMenuItem(
                      value: 'Finalizada',
                      child: Text('Finalizada'),
                    ),
                  ],
                  onChanged: (valor) {
                    if (valor != null) {
                      setState(() {
                        estado = valor;
                      });
                    }
                  },
                ),

                const SizedBox(height: 15),

                TextFormField(
                  controller: diagnosticoController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Diagnóstico',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.search),
                  ),
                ),

                const SizedBox(height: 15),

                TextFormField(
                  controller: observacionesController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Observaciones',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.notes),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: guardando
              ? null
              : () {
                  Navigator.pop(context, false);
                },
          child: const Text('Cancelar'),
        ),
        FilledButton.icon(
          onPressed: guardando ? null : guardarOrden,
          icon: guardando
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : const Icon(Icons.save),
          label: const Text('Guardar orden'),
        ),
      ],
    );
  }
}


/*import 'package:flutter/material.dart';

import '../../database/database.dart';
import '../../models/cliente.dart';
import '../../models/orden.dart';

class NuevaOrdenDialog extends StatefulWidget {
  const NuevaOrdenDialog({super.key});

  @override
  State<NuevaOrdenDialog> createState() => _NuevaOrdenDialogState();
}

class _NuevaOrdenDialogState extends State<NuevaOrdenDialog> {
  final _formKey = GlobalKey<FormState>();

  List<Cliente> clientes = [];
  Cliente? clienteSeleccionado;

  final equipoController = TextEditingController();
  final problemaController = TextEditingController();
  final diagnosticoController = TextEditingController();
  final observacionesController = TextEditingController();

  String estado = 'Pendiente';

  bool cargandoClientes = true;
  bool guardando = false;

  @override
  void initState() {
    super.initState();
    cargarClientes();
  }

  Future<void> cargarClientes() async {
    final datos = await DatabaseHelper.obtenerClientes();

    setState(() {
      clientes = datos.map((dato) => Cliente.fromMap(dato)).toList();
      cargandoClientes = false;
    });
  }

  String generarFolio() {
    final ahora = DateTime.now();

    return 'ORD-${ahora.year}${ahora.month.toString().padLeft(2, '0')}${ahora.day.toString().padLeft(2, '0')}-${ahora.millisecond}';
  }

  Future<void> guardarOrden() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (clienteSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona un cliente'),
        ),
      );
      return;
    }

    setState(() {
      guardando = true;
    });

    final orden = Orden(
      folio: generarFolio(),
      clienteId: clienteSeleccionado!.id!,
      fecha: DateTime.now().toIso8601String(),
      equipo: equipoController.text.trim().isEmpty
          ? null
          : equipoController.text.trim(),
      problema: problemaController.text.trim().isEmpty
          ? null
          : problemaController.text.trim(),
      estado: estado,
      diagnostico: diagnosticoController.text.trim().isEmpty
          ? null
          : diagnosticoController.text.trim(),
      observaciones: observacionesController.text.trim().isEmpty
          ? null
          : observacionesController.text.trim(),
    );

    await DatabaseHelper.insertarOrden(
      orden.toMap(),
    );

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  void dispose() {
    equipoController.dispose();
    problemaController.dispose();
    diagnosticoController.dispose();
    observacionesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nueva orden de servicio'),
      content: SizedBox(
        width: 550,
        child: cargandoClientes
            ? const SizedBox(
                height: 200,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            : clientes.isEmpty
                ? const SizedBox(
                    height: 150,
                    child: Center(
                      child: Text(
                        'Primero debes registrar un cliente.',
                      ),
                    ),
                  )
                : Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          DropdownButtonFormField<Cliente>(
                            value: clienteSeleccionado,
                            decoration: const InputDecoration(
                              labelText: 'Cliente *',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.person),
                            ),
                            items: clientes.map((cliente) {
                              return DropdownMenuItem(
                                value: cliente,
                                child: Text(
                                  cliente.nombre,
                                ),
                              );
                            }).toList(),
                            onChanged: (cliente) {
                              setState(() {
                                clienteSeleccionado = cliente;
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Selecciona un cliente';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 15),

                          TextFormField(
                            controller: equipoController,
                            decoration: const InputDecoration(
                              labelText: 'Equipo',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.computer),
                            ),
                          ),

                          const SizedBox(height: 15),

                          TextFormField(
                            controller: problemaController,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              labelText: 'Problema reportado',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.report_problem),
                            ),
                          ),

                          const SizedBox(height: 15),

                          DropdownButtonFormField<String>(
                            value: estado,
                            decoration: const InputDecoration(
                              labelText: 'Estado',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.assignment),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'Pendiente',
                                child: Text('Pendiente'),
                              ),
                              DropdownMenuItem(
                                value: 'En proceso',
                                child: Text('En proceso'),
                              ),
                              DropdownMenuItem(
                                value: 'Finalizada',
                                child: Text('Finalizada'),
                              ),
                            ],
                            onChanged: (valor) {
                              setState(() {
                                estado = valor!;
                              });
                            },
                          ),

                          const SizedBox(height: 15),

                          TextFormField(
                            controller: diagnosticoController,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              labelText: 'Diagnóstico',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.search),
                            ),
                          ),

                          const SizedBox(height: 15),

                          TextFormField(
                            controller: observacionesController,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              labelText: 'Observaciones',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.notes),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
      ),
      actions: [
        TextButton(
          onPressed: guardando
              ? null
              : () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        FilledButton.icon(
          onPressed: clientes.isEmpty || guardando
              ? null
              : guardarOrden,
          icon: guardando
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : const Icon(Icons.save),
          label: const Text('Guardar orden'),
        ),
      ],
    );
  }
}*/