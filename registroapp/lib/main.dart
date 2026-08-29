import 'package:flutter/material.dart';
import 'database/database.dart';
import 'screens/clientes/clientes_page.dart';
import 'screens/ordenes/ordenes_page.dart';
import 'screens/ordenes/nueva_orden_dialog.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await DatabaseHelper.database;

  runApp(const SistemaTecnicoApp());
}

class SistemaTecnicoApp extends StatelessWidget {
  const SistemaTecnicoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sistema de Servicio Técnico',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
      ),
      home: const InicioPage(),
    );
  }
}

class InicioPage extends StatefulWidget {
  const InicioPage({super.key});

  @override
  State<InicioPage> createState() => _InicioPageState();
}

class _InicioPageState extends State<InicioPage> {
  int paginaSeleccionada = 0;

  final List<String> paginas = [
    'Inicio',
    'Clientes',
    'Ordenes',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 250,
            color: Colors.blue.shade900,
            child: Column(
              children: [
                const SizedBox(height: 35),

                const Icon(
                  Icons.build_circle,
                  size: 55,
                  color: Colors.white,
                ),

                const SizedBox(height: 12),

                const Text(
                  'SERVICIO TÉCNICO',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 35),

                Expanded(
                  child: ListView.builder(
                    itemCount: paginas.length,
                    itemBuilder: (context, index) {
                      return _crearOpcionMenu(
                        icono: _obtenerIcono(index),
                        texto: paginas[index],
                        seleccionado: paginaSeleccionada == index,
                        onTap: () {
                          setState(() {
                            paginaSeleccionada = index;
                          });
                        },
                      );
                    },
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'Sistema de gestión',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: Column(
              children: [
                Container(
                  height: 70,
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Text(
                        paginas[paginaSeleccionada],
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const Spacer(),

                      const CircleAvatar(
                        child: Icon(Icons.person),
                      ),

                      const SizedBox(width: 12),

                      const Text(
                        'Técnico',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: _crearContenido(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _crearOpcionMenu({
    required IconData icono,
    required String texto,
    required bool seleccionado,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: seleccionado
            ? Colors.blue.shade700
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(
          icono,
          color: Colors.white,
        ),
        title: Text(
          texto,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  IconData _obtenerIcono(int index) {
    switch (index) {
      case 0:
        return Icons.home;
      case 1:
        return Icons.people;
      case 2:
        return Icons.assignment;
      case 3:
        return Icons.computer;
      case 4:
        return Icons.search;
      case 5:
        return Icons.build;
      default:
        return Icons.circle;
    }
  }

  Widget _crearContenido() {
    switch (paginaSeleccionada) {
      case 0:
        return _inicio();

      case 1:
        return const ClientesPage();

      case 2: 
        return const OrdenesPage();

      default:
        return Center(
          child: Text(
            paginas[paginaSeleccionada],
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
    }
  }

  Widget _inicio() {
    Future<void> _mostrarNuevaOrden() async {
  final resultado = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return const NuevaOrdenDialog();
    },
  );

  if (resultado == true && mounted) {
    setState(() {
      paginaSeleccionada = 2;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Orden creada correctamente'),
      ),
    );
  }
}

    return SingleChildScrollView(
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
              'Bienvenido',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Administra la información de tus servicios técnicos.',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),

        const Spacer(),

        FilledButton.icon(
          onPressed: _mostrarNuevaOrden,
          icon: const Icon(Icons.add),
          label: const Text('Nueva orden'),
        ),
      ],
    ),

    const SizedBox(height: 30),


  /*        Row(
            children: [
              _tarjetaResumen(
                titulo: 'Clientes',
                valor: '0',
                icono: Icons.people,
              ),
              const SizedBox(width: 20),
              _tarjetaResumen(
                titulo: 'Equipos',
                valor: '0',
                icono: Icons.computer,
              ),
              const SizedBox(width: 20),
              _tarjetaResumen(
                titulo: 'Diagnósticos',
                valor: '0',
                icono: Icons.search,
              ),
              const SizedBox(width: 20),
              _tarjetaResumen(
                titulo: 'Actividades',
                valor: '0',
                icono: Icons.build,
              ),
            ],
          ),*/
        ],
      ),
    );
  }

  Widget _tarjetaResumen({
    required String titulo,
    required String valor,
    required IconData icono,
  }) {
    return Expanded(
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Row(
            children: [
              Icon(
                icono,
                size: 40,
                color: Colors.blue,
              ),

              const SizedBox(width: 15),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    valor,
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}