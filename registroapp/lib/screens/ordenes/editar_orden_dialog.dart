import 'package:flutter/material.dart';
import '../../database/database.dart';
import '../../models/cliente.dart';
import '../../models/orden.dart';

class EditarOrdenDialog extends StatefulWidget {
  final Orden orden;

  const EditarOrdenDialog({
    super.key,
    required this.orden,
  });

  @override
  State<EditarOrdenDialog> createState() =>
      _EditarOrdenDialogState();
}

class _EditarOrdenDialogState
    extends State<EditarOrdenDialog> {
  final _formKey = GlobalKey<FormState>();

  List<Cliente> clientes = [];
  Cliente? clienteSeleccionado;

  late TextEditingController equipoController;
  late TextEditingController problemaController;
  late TextEditingController diagnosticoController;
  late TextEditingController observacionesController;

  late String estado;

  bool cargandoClientes = true;
  bool guardando = false;

  @override
  void initState() {
    super.initState();

    equipoController = TextEditingController(
      text: widget.orden.equipo ?? '',
    );

    problemaController = TextEditingController(
      text: widget.orden.problema ?? '',
    );

    diagnosticoController = TextEditingController(
      text: widget.orden.diagnostico ?? '',
    );

    observacionesController = TextEditingController(
      text: widget.orden.observaciones ?? '',
    );

    estado = widget.orden.estado;

    cargarClientes();
  }

  Future<void> cargarClientes() async {
    final datos = await DatabaseHelper.obtenerClientes();

    final listaClientes = datos
        .map((dato) => Cliente.fromMap(dato))
        .toList();

    Cliente? clienteActual;

    for (final cliente in listaClientes) {
      if (cliente.id == widget.orden.clienteId) {
        clienteActual = cliente;
        break;
      }
    }

    setState(() {
      clientes = listaClientes;
      clienteSeleccionado = clienteActual;
      cargandoClientes = false;
    });
  }

  Future<void> guardarCambios() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (clienteSeleccionado == null) {
      return;
    }

    setState(() {
      guardando = true;
    });

    final ordenActualizada = Orden(
      id: widget.orden.id,
      folio: widget.orden.folio,
      clienteId: clienteSeleccionado!.id!,
      fecha: widget.orden.fecha,
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

    await DatabaseHelper.actualizarOrden(
      widget.orden.id!,
      ordenActualizada.toMap(),
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
      title: Text(
        'Editar orden ${widget.orden.folio}',
      ),
      content: SizedBox(
        width: 550,
        child: cargandoClientes
            ? const SizedBox(
                height: 200,
                child: Center(
                  child: CircularProgressIndicator(),
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
                          labelText: 'Cliente',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        items: clientes.map((cliente) {
                          return DropdownMenuItem(
                            value: cliente,
                            child: Text(cliente.nombre),
                          );
                        }).toList(),
                        onChanged: (cliente) {
                          setState(() {
                            clienteSeleccionado = cliente;
                          });
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
                          prefixIcon:
                              Icon(Icons.report_problem),
                        ),
                      ),

                      const SizedBox(height: 15),

                      DropdownButtonFormField<String>(
                        value: estado,
                        decoration: const InputDecoration(
                          labelText: 'Estado',
                          border: OutlineInputBorder(),
                          prefixIcon:
                              Icon(Icons.assignment),
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
                        controller:
                            observacionesController,
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
          onPressed: guardando
              ? null
              : guardarCambios,
          icon: const Icon(Icons.save),
          label: const Text('Guardar cambios'),
        ),
      ],
    );
  }
}