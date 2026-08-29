import 'dart:typed_data';
import 'package:file_selector/file_selector.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/orden.dart';

class PdfService {
  static Future<String> exportarOrden(Orden orden) async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (context) {
            return [
              pw.Header(
                level: 0,
                child: pw.Text(
                  'ORDEN DE SERVICIO',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),

              pw.SizedBox(height: 20),

              pw.Text(
                'Folio: ${orden.folio}',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),

              pw.SizedBox(height: 15),

              pw.Table(
                border: pw.TableBorder.all(),
                columnWidths: {
                  0: const pw.FixedColumnWidth(150),
                  1: const pw.FlexColumnWidth(),
                },
                children: [
                  _fila('Fecha', orden.fecha),
                  _fila('Estado', orden.estado),
                  _fila('Equipo', orden.equipo ?? '-'),
                  _fila(
                    'Problema reportado',
                    orden.problema ?? '-',
                  ),
                  _fila(
                    'Diagnóstico',
                    orden.diagnostico ?? '-',
                  ),
                  _fila(
                    'Observaciones',
                    orden.observaciones ?? '-',
                  ),
                ],
              ),

              pw.SizedBox(height: 40),

              pw.Divider(),

              pw.Text(
                'Documento generado por Sistema de Servicio Técnico',
                style: const pw.TextStyle(
                  fontSize: 10,
                ),
              ),
            ];
          },
        ),
      );

      final Uint8List datosPdf = await pdf.save();

      final nombreArchivo =
          'Orden_${orden.folio.replaceAll('/', '-')}.pdf';

      final FileSaveLocation? ubicacion =
          await getSaveLocation(
        suggestedName: nombreArchivo,
        confirmButtonText: 'Guardar',
      );

      if (ubicacion == null) {
        return 'cancelado';
      }

      final XFile archivo = XFile.fromData(
        datosPdf,
        mimeType: 'application/pdf',
        name: nombreArchivo,
      );

      await archivo.saveTo(ubicacion.path);

      return 'correcto';
    } catch (e) {
      return 'error';
    }
  }

  static pw.TableRow _fila(
    String titulo,
    String valor,
  ) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(
            titulo,
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),

        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(valor),
        ),
      ],
    );
  }
}