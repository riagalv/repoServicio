import 'package:flutter/material.dart';
import '../../database/database.dart';
import '../../models/orden.dart';
import 'editar_orden_dialog.dart';
import '../../services/pdf_service.dart';

class OrdenesPage extends StatefulWidget {
  const OrdenesPage({super.key});

  @override
  State<OrdenesPage> createState() => _OrdenesPageState();
}

class _OrdenesPageState extends State<OrdenesPage> {
  List<Orden> ordenes = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargarOrdenes();
  }

  Future<void> editarOrden(Orden orden) async {
  final resultado = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return EditarOrdenDialog(
        orden: orden,
      );
    },
  );

  if (resultado == true) {
    await cargarOrdenes();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Orden actualizada correctamente',
          ),
        ),
      );
    }
  }
}

  Future<void> cargarOrdenes() async {
    setState(() {
      cargando = true;
    });

    final datos = await DatabaseHelper.obtenerOrdenes();

    setState(() {
      ordenes = datos.map((dato) => Orden.fromMap(dato)).toList();
      cargando = false;
    });
  }

  Future<void> eliminarOrden(Orden orden) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar orden'),
          content: Text(
            '¿Estás segura de eliminar la orden ${orden.folio}?\n\n'
            'Esta acción no se puede deshacer.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancelar'),
            ),
            FilledButton.icon(
              onPressed: () {
                Navigator.pop(context, true);
              },
              icon: const Icon(Icons.delete),
              label: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirmar != true) return;

    await DatabaseHelper.eliminarOrden(orden.id!);

    await cargarOrdenes();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Orden eliminada correctamente'),
        ),
      );
    }
  }

  Future<void> exportarPDF(Orden orden) async {
  final resultado = await PdfService.exportarOrden(orden);

  if (!mounted) return;

  if (resultado== 'correcto') {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'PDF guardado correctamente',
        ),
      ),
    );
  } else if (resultado == 'error'){
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Error al generar el PDF'),
        ),
    );
  }
}

  void verDetalle(Orden orden) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Orden ${orden.folio}'),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _detalle('Folio', orden.folio),
                  _detalle('Fecha', orden.fecha),
                  _detalle('Estado', orden.estado),
                  _detalle('Equipo', orden.equipo ?? '-'),
                  _detalle('Problema', orden.problema ?? '-'),
                  _detalle(
                    'Diagnóstico',
                    orden.diagnostico ?? '-',
                  ),
                  _detalle(
                    'Observaciones',
                    orden.observaciones ?? '-',
                  ),
                ],
              ),
            ),
          ),
        actions: [
            OutlinedButton.icon(
                onPressed: () async {
                Navigator.pop(context);

                await editarOrden(orden);
            },
            icon: const Icon(Icons.edit),
            label: const Text('Editar'),
        ),
        FilledButton.icon(
            onPressed: () async {
            final navigator = Navigator.of(context);

            navigator.pop();

            await exportarPDF(orden);
            },
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text('Exportar a PDF'),
        ),
        OutlinedButton.icon(
          onPressed: () async {
            Navigator.pop(context);
            await eliminarOrden(orden);
          },
          icon: const Icon(Icons.delete_outline),
          label: const Text('Eliminar'),
        ),

        TextButton(
              onPressed: () {
                  Navigator.pop(context);
              },
              child: const Text('Cerrar'),
              ),
          ],
        );
      },
    );
  }

  Widget _detalle(String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(valor),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Órdenes',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 5),

          const Text(
            'Visualiza y administra las órdenes de servicio',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 15,
            ),
          ),

          const SizedBox(height: 25),

          Expanded(
            child: Card(
              elevation: 2,
              child: cargando
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : ordenes.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.assignment_outlined,
                                size: 70,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 15),
                              Text(
                                'No hay órdenes registradas.',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'Cree una nueva desde el dashboard.',
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
                              columns: const [
                                DataColumn(
                                  label: Text('Folio'),
                                ),
                                DataColumn(
                                  label: Text('Fecha'),
                                ),
                                DataColumn(
                                  label: Text('Estado'),
                                ),
                                DataColumn(
                                  label: Text('Acciones'),
                                ),
                              ],
                              rows: ordenes.map((orden) {
                                return DataRow(
                                  cells: [
                                    DataCell(
                                      Text(orden.folio),
                                    ),
                                    DataCell(
                                      Text(orden.fecha),
                                    ),
                                    DataCell(
                                      Text(orden.estado),
                                    ),
                                    DataCell(
                                      FilledButton(
                                        onPressed: () {
                                          verDetalle(orden);
                                        },
                                        child: const Text(
                                          'Ver detalle',
                                        ),
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