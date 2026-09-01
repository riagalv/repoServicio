import 'package:flutter/material.dart';
import '../../database/database.dart';
import '../../models/orden.dart';
import 'editar_orden_dialog.dart';
import '../../services/pdf_service.dart';

class OrdenesPage extends StatefulWidget {
  final String filtroInicial;

  const OrdenesPage({
    super.key,
    this.filtroInicial = 'Todas',
  });

  @override
  State<OrdenesPage> createState() => _OrdenesPageState();
}

class _OrdenesPageState extends State<OrdenesPage> {
  List<Orden> ordenes = [];
  bool cargando = true;
  late String filtroEstado;
  final TextEditingController busquedaController = TextEditingController();
  String busqueda = '';

  @override
  void initState() {
    super.initState();
    filtroEstado = widget.filtroInicial;
    cargarOrdenes();
  }

  @override
  void didUpdateWidget(covariant OrdenesPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.filtroInicial != widget.filtroInicial) {
      setState(() {
        filtroEstado = widget.filtroInicial;
      });
    }
  }

  @override
  void dispose() {
    busquedaController.dispose();
    super.dispose();
  }

  List<Orden> get ordenesFiltradas {
    return ordenes.where((orden) {
      final coincideEstado = filtroEstado == 'Todas' ||
          orden.estado.toLowerCase() == filtroEstado.toLowerCase();

      final texto = busqueda.trim().toLowerCase();
      final coincideBusqueda = texto.isEmpty ||
          orden.folio.toLowerCase().contains(texto) ||
          (orden.equipo?.toLowerCase().contains(texto) ?? false) ||
          (orden.problema?.toLowerCase().contains(texto) ?? false);

      return coincideEstado && coincideBusqueda;
    }).toList();
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
    //Actualizar fichas
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

  Widget _badgeEstado(String estado) {
    Color colorFondo;
    Color colorTexto;
    IconData icono;

    switch (estado) {
      case 'Pendiente':
        colorFondo = Colors.amber.shade100;
        colorTexto = Colors.amber.shade900;
        icono = Icons.schedule;
        break;
      case 'En proceso':
        colorFondo = Colors.blue.shade100;
        colorTexto = Colors.blue.shade900;
        icono = Icons.build_outlined;
        break;
      case 'Finalizada':
        colorFondo = Colors.green.shade100;
        colorTexto = Colors.green.shade900;
        icono = Icons.check_circle_outline;
        break;
      default:
        colorFondo = Colors.grey.shade200;
        colorTexto = Colors.grey.shade800;
        icono = Icons.info_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colorFondo,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 14, color: colorTexto),
          const SizedBox(width: 4),
          Text(
            estado,
            style: TextStyle(
              color: colorTexto,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtradas = ordenesFiltradas;
    final totalPendientes = ordenes.where((o) => o.estado == 'Pendiente').length;
    final totalEnProceso = ordenes.where((o) => o.estado == 'En proceso').length;
    final totalFinalizadas = ordenes.where((o) => o.estado == 'Finalizada').length;

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

          const SizedBox(height: 20),

          // BARRA DE FILTROS Y BÚSQUEDA
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: WrapAlignment.spaceBetween,
            children: [
              SegmentedButton<String>(
                segments: [
                  ButtonSegment<String>(
                    value: 'Todas',
                    label: Text('Todas (${ordenes.length})'),
                    icon: const Icon(Icons.all_inbox),
                  ),
                  ButtonSegment<String>(
                    value: 'Pendiente',
                    label: Text('Pendientes ($totalPendientes)'),
                    icon: const Icon(Icons.schedule),
                  ),
                  ButtonSegment<String>(
                    value: 'En proceso',
                    label: Text('En proceso ($totalEnProceso)'),
                    icon: const Icon(Icons.build_outlined),
                  ),
                  ButtonSegment<String>(
                    value: 'Finalizada',
                    label: Text('Finalizadas ($totalFinalizadas)'),
                    icon: const Icon(Icons.check_circle_outline),
                  ),
                ],
                selected: {filtroEstado},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    filtroEstado = newSelection.first;
                  });
                },
              ),

              SizedBox(
                width: 270,
                height: 40,
                child: TextField(
                  controller: busquedaController,
                  decoration: InputDecoration(
                    hintText: 'Buscar folio, equipo, problema...',
                    hintStyle: const TextStyle(fontSize: 12),
                    prefixIcon: const Icon(Icons.search, size: 18),
                    suffixIcon: busqueda.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 16),
                            onPressed: () {
                              busquedaController.clear();
                              setState(() {
                                busqueda = '';
                              });
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 0,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (valor) {
                    setState(() {
                      busqueda = valor;
                    });
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

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
                      : filtradas.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.filter_alt_off_outlined,
                                    size: 60,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No se encontraron órdenes con el filtro "$filtroEstado"${busqueda.isNotEmpty ? ' y búsqueda "$busqueda"' : ''}.',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  OutlinedButton.icon(
                                    onPressed: () {
                                      busquedaController.clear();
                                      setState(() {
                                        filtroEstado = 'Todas';
                                        busqueda = '';
                                      });
                                    },
                                    icon: const Icon(Icons.refresh),
                                    label: const Text('Restablecer filtros'),
                                  ),
                                ],
                              ),
                            )
                          : SingleChildScrollView(
                              child: SizedBox(
                                width: double.infinity,
                                child: DataTable(
                                  headingRowColor: WidgetStateProperty.all(
                                    Colors.blue.shade50,
                                  ),
                                  columns: const [
                                    DataColumn(
                                      label: Text(
                                        'Folio',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'Fecha',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'Equipo',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'Estado',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'Acciones',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                  rows: filtradas.map((orden) {
                                    final fechaDisplay = orden.fecha.contains('T')
                                        ? orden.fecha.split('T').first
                                        : orden.fecha;

                                    return DataRow(
                                      cells: [
                                        DataCell(
                                          Text(
                                            orden.folio,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Text(fechaDisplay),
                                        ),
                                        DataCell(
                                          Text(orden.equipo ?? '-'),
                                        ),
                                        DataCell(
                                          _badgeEstado(orden.estado),
                                        ),
                                        DataCell(
                                          FilledButton.tonal(
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