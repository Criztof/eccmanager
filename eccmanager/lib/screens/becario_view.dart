import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'formulario_rondin_screen.dart';
import '../services/becario_service.dart'; // Importamos el servicio

class PantallaBecario extends StatelessWidget {
  PantallaBecario({super.key});

  // Instancia del servicio separado
  final BecarioService _becarioService = BecarioService();

  @override
  Widget build(BuildContext context) {
    // Obtenemos el nombre del usuario usando el servicio
    final String userName = _becarioService.obtenerNombreUsuario();

    // Colores institucionales definidos en Figma
    const Color verdeUANL = Color(0xFF1B5E20);
    const Color fondoGrisaceo = Color(0xFFF5F9F5);
    const Color textoNegroFigma = Color(0xFF1D261D); // Color exacto de los títulos

    return Scaffold(
      backgroundColor: fondoGrisaceo,

      // 1. BARRA SUPERIOR (Customizable)
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Mis Tareas de Hoy',
                style: TextStyle(
                  color: textoNegroFigma,
                  fontWeight: FontWeight.bold,
                  fontSize: 26,
                ),
              ),
              CircleAvatar(
                radius: 24,
                backgroundColor: verdeUANL.withOpacity(0.1),
                child: Text(
                  userName.isNotEmpty
                      ? userName.substring(0, 1).toUpperCase()
                      : 'U',
                  style: const TextStyle(
                    color: verdeUANL,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // 2. CONTENIDO PRINCIPAL SCROLLEABLE
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // A. Tarjeta de Progreso Diario
            _buildProgressCard(context, verdeUANL),
            const SizedBox(height: 25),

            // B. Botones de Acceso Rápido
            Row(
              children: [
                _buildQuickAccessButton(
                  'Material',
                  'INVENTARIO',
                  Icons.inventory_2_outlined,
                  context,
                ),
                const SizedBox(width: 15),
                _buildQuickAccessButton(
                  'Software',
                  'SALONES',
                  Icons.computer_outlined,
                  context,
                ),
              ],
            ),
            const SizedBox(height: 30),

            // C. Sección: PENDIENTES
            const Text(
              'PENDIENTES',
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 15),

            // Tarjetas de tareas pendientes (Simuladas de Figma)
            _buildPendingTaskCard(
              context,
              horario: '10:00 AM',
              titulo: 'Rondín Salón 2-103',
              ubicacion: 'Edificio 2, Piso 1',
            ),
            _buildPendingTaskCard(
              context,
              horario: '11:30 AM',
              titulo: 'Rondín Salón 2-104',
              ubicacion: 'Edificio 2, Piso 1',
            ),
            _buildPendingTaskCard(
              context,
              horario: '01:00 PM',
              titulo: 'Revisión Lab B',
              ubicacion: 'Edificio 3, Planta Baja',
              statusLabel: 'Programado', // Cambiamos la etiqueta como en Figma
            ),
            const SizedBox(height: 30),

            // D. Sección: COMPLETADAS HOY
            const Text(
              'COMPLETADAS HOY',
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 15),

            // Tarjeta de tarea completada (Simulada de Figma)
            _buildCompletedTaskCard(
              context,
              titulo: 'Rondín Salón 2-102',
              horarioCompleto: 'Completado a las 09:15 AM',
            ),

            const SizedBox(
              height: 100,
            ), // Espacio para que no lo tape el menú inferior
          ],
        ),
      ),

      // 3. MENÚ INFERIOR
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: verdeUANL,
        shape: const CircleBorder(),
        elevation: 5,
        child: const Text(
          'ECC',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    Icons.home_filled,
                    color: verdeUANL,
                  ), // Icono relleno como en Figma
                  Text(
                    'Inicio',
                    style: TextStyle(color: verdeUANL, fontSize: 10),
                  ),
                ],
              ),
              const SizedBox(width: 48), // Espacio central
              GestureDetector(
                onTap: () async {
                  // Llamamos al servicio para cerrar sesión
                  await _becarioService.cerrarSesion();
                  if (context.mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  }
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.logout_outlined, color: Colors.grey),
                    Text(
                      'Salir',
                      style: TextStyle(color: Colors.grey, fontSize: 10),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // === WIDGETS AUXILIARES DE DISEÑO ===

  Widget _buildProgressCard(BuildContext context, Color verdeUANL) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: verdeUANL,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: verdeUANL.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PROGRESO SEMANAL',
            style: TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w600,
              fontSize: 13,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              const Text(
                '1/4',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 44,
                ),
              ),
              const SizedBox(width: 15),
              const Text(
                'Completadas',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Container(
            height: 10,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
                const Spacer(flex: 3),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessButton(
    String titulo,
    String subtitulo,
    IconData icono,
    BuildContext context,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Color(0xFFF3F7F3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icono,
                color: const Color(0xFF65AE69),
                size: 22,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    subtitulo,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingTaskCard(
    BuildContext context, {
    required String horario,
    required String titulo,
    required String ubicacion,
    String statusLabel = 'Pendiente',
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            // Extraemos el salón del título (ej. "Rondín Salón 2-103" -> "Salón 2-103")
            String numSalon = titulo.replaceAll('Rondín ', '');
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FormularioRondinScreen(salon: numSalon),
              ),
            );
          },
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F4F1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      horario,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7F1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          color: Color(0xFFEF9E4E),
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          statusLabel,
                          style: const TextStyle(
                            color: Color(0xFFEF9E4E),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            subtitle: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          color: Colors.grey,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          ubicacion,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFF1F4F1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.keyboard_arrow_right,
                    color: Colors.grey,
                    size: 28,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompletedTaskCard(
    BuildContext context, {
    required String titulo,
    required String horarioCompleto,
  }) {
    const Color verdeUANL = Color(0xFF1B5E20);
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FCF8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: verdeUANL.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle_outlined,
            color: Color(0xFF65AE69),
            size: 24,
          ),
        ),
        title: Text(
          titulo,
          style: const TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.bold,
            fontSize: 16,
            decoration: TextDecoration.lineThrough,
          ),
        ),
        subtitle: Text(
          horarioCompleto,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ),
    );
  }
}