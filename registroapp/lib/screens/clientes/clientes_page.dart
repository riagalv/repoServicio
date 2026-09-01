import 'package:flutter/material.dart';
import '../../database/database.dart';
import '../../models/cliente.dart';

class ClientesPage extends StatefulWidget {
  const ClientesPage({super.key});

  @override
  State<ClientesPage> createState() => _ClientesPageState();
}

class _ClientesPageState extends State<ClientesPage> {
  List<Cliente> clientes = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargarClientes();
  }

  Future<void> cargarClientes() async {
    setState(() {
      cargando = true;
    });

    final datos = await DatabaseHelper.obtenerClientes();

    setState(() {
      clientes = datos.map((dato) => Cliente.fromMap(dato)).toList();
      cargando = false;
    });
  }

  Future<void> mostrarFormulario({Cliente? cliente}) async {
    final resultado = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return FormularioClienteDialog(
          cliente: cliente,
        );
      },
    );

    if (resultado == true) {
      await cargarClientes();
    }
  }

  Future<void> eliminarCliente(Cliente cliente) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar cliente'),
          content: Text(
            '¿Está seguro de eliminar a ${cliente.nombre}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirmar == true && cliente.id != null) {
      await DatabaseHelper.eliminarCliente(cliente.id!);
      await cargarClientes();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cliente eliminado correctamente'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Clientes',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Administra los clientes registrados',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: () => mostrarFormulario(),
                icon: const Icon(Icons.person_add),
                label: const Text('Nuevo cliente'),
              ),
            ],
          ),

          const SizedBox(height: 25),

          Expanded(
            child: Card(
              elevation: 2,
              child: cargando
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : clientes.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.people_outline,
                                size: 70,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 15),
                              Text(
                                'No hay clientes registrados',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'Presiona "Nuevo cliente" para registrar uno.',
                                style: TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        )
                      : SingleChildScrollView(
                          child: SizedBox(
                            width: double.infinity,
                            child: DataTable(
                              headingRowColor:
                                  WidgetStateProperty.all(
                                Colors.blue.shade50,
                              ),
                              columns: const [
                                DataColumn(
                                  label: Text('Nombre'),
                                ),
                                DataColumn(
                                  label: Text('Teléfono'),
                                ),
                                DataColumn(
                                  label: Text('Correo'),
                                ),
                                DataColumn(
                                  label: Text('Dirección'),
                                ),
                                DataColumn(
                                  label: Text('Acciones'),
                                ),
                              ],
                              rows: clientes.map((cliente) {
                                return DataRow(
                                  cells: [
                                    DataCell(
                                      Text(cliente.nombre),
                                    ),
                                    DataCell(
                                      Text(cliente.telefono),
                                    ),
                                    DataCell(
                                      Text(
                                        cliente.correo?.isNotEmpty == true
                                            ? cliente.correo!
                                            : '-',
                                      ),
                                    ),
                                  
                                    DataCell(
                                      Row(
                                        children: [
                                          IconButton(
                                            tooltip: 'Editar',
                                            icon: const Icon(
                                              Icons.edit,
                                            ),
                                            onPressed: () {
                                              mostrarFormulario(
                                                cliente: cliente,
                                              );
                                            },
                                          ),
                                          IconButton(
                                            tooltip: 'Eliminar',
                                            icon: const Icon(
                                              Icons.delete,
                                            ),
                                            onPressed: () {
                                              eliminarCliente(cliente);
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
            ),
          ),
        ],
      ),
    );
  }
}

class FormularioClienteDialog extends StatefulWidget {
  final Cliente? cliente;

  const FormularioClienteDialog({
    super.key,
    this.cliente,
  });

  @override
  State<FormularioClienteDialog> createState() =>
      _FormularioClienteDialogState();
}

class _FormularioClienteDialogState
    extends State<FormularioClienteDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController nombreController;
  late final TextEditingController telefonoController;
  late final TextEditingController correoController;
 

  bool guardando = false;

  bool get editando => widget.cliente != null;

  @override
  void initState() {
    super.initState();

    nombreController = TextEditingController(
      text: widget.cliente?.nombre ?? '',
    );

    telefonoController = TextEditingController(
      text: widget.cliente?.telefono ?? '',
    );

    correoController = TextEditingController(
      text: widget.cliente?.correo ?? '',
    );

  }

  @override
  void dispose() {
    nombreController.dispose();
    telefonoController.dispose();
    correoController.dispose();
    super.dispose();
  }

  Future<void> guardar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      guardando = true;
    });

    final nombre = nombreController.text.trim();
    final telefono = telefonoController.text.trim();
    final correo = correoController.text.trim();


    final telefonoExiste = await DatabaseHelper.existeTelefono(
      telefono,
      excluirId: widget.cliente?.id,
    );

    if (telefonoExiste) {
      setState(() {
        guardando = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Ya existe un cliente con este teléfono',
            ),
          ),
        );
      }

      return;
    }

    final cliente = Cliente(
      id: widget.cliente?.id,
      nombre: nombre,
      telefono: telefono,
      correo: correo.isEmpty ? null : correo,

    );

    if (editando) {
      await DatabaseHelper.actualizarCliente(
        cliente.id!,
        cliente.toMap(),
      );
    } else {
      await DatabaseHelper.insertarCliente(
        cliente.toMap(),
      );
    }

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        editando ? 'Editar cliente' : 'Nuevo cliente',
      ),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nombreController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'El nombre es obligatorio';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 15),

                TextFormField(
                  controller: telefonoController,
                  decoration: const InputDecoration(
                    labelText: 'Teléfono *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'El teléfono es obligatorio';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 15),

                TextFormField(
                  controller: correoController,
                  decoration: const InputDecoration(
                    labelText: 'Correo',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
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
          onPressed: guardando ? null : guardar,
          icon: guardando
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : const Icon(Icons.save),
          label: Text(
            editando ? 'Actualizar' : 'Guardar',
          ),
        ),
      ],
    );
  }
}
//problematica
//antecedentes
//justifucacion