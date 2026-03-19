import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ==========================================
// 1. EL ENRUTADOR (El "Pasillo" que decide a dónde vas)
// ==========================================
class HomeScreen extends StatelessWidget {
  final String rol;

  const HomeScreen({super.key, required this.rol});

  @override
  Widget build(BuildContext context) {
    // Dependiendo del rol, te manda a tu diseño correspondiente
    if (rol == 'admin') {
      return const PantallaAdmin();
    } else if (rol == 'supervisor') {
      return const PantallaSupervisor();
    } else {
      return const PantallaBecario();
    }
  }
}

// ==========================================
// 2. LA PUERTA DEL ADMIN (¡Este es TU código exacto!)
// ==========================================
class PantallaAdmin extends StatelessWidget {
  const PantallaAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userName = user?.displayName ?? 'Juan';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.menu, color: Colors.black87),
        ),
        title: const Text(
          'eccmanager',
          style: TextStyle(
            color: Color(0xFF1B5E20),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: const Color(0xFF1B5E20),
              child: Text(
                userName.isNotEmpty
                    ? userName.substring(0, 1).toUpperCase()
                    : 'A',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF1B5E20),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Hero Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hola, $userName',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tienes 3 tickets pendientes hoy.',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Ver Tickets',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // 2. Stats Cards
            Row(
              children: [
                _buildStatCard(
                  '12',
                  'Tickets Abiertos',
                  Icons.confirmation_number_outlined,
                  Colors.orange,
                ),
                const SizedBox(width: 16),
                _buildStatCard(
                  '85',
                  'Artículos Stock',
                  Icons.inventory_2_outlined,
                  Colors.blue,
                ),
              ],
            ),
            const SizedBox(height: 25),

            // 3. Gestión Rápida
            const Text(
              'Gestión Rápida',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B5E20),
              ),
            ),
            const SizedBox(height: 15),
            _buildActionTile(
              Icons.add,
              'Nuevo Ticket',
              'Crear reporte de soporte',
            ),
            _buildActionTile(
              Icons.handyman_outlined,
              'Herramientas',
              'Inventario de equipo',
            ),
            _buildActionTile(
              Icons.search,
              'Buscar Inventario',
              'Localizar componentes',
            ),

            const SizedBox(height: 25),

            // 4. Tickets Recientes
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tickets Recientes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B5E20),
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Ver todo',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildTicketItem(
              '#2024 - Error de Impresora',
              'Hace 15 min • Sala de Juntas',
              'Alta',
              Colors.red,
            ),
            _buildTicketItem(
              '#2023 - Actualización Adobe',
              'Hace 45 min • Diseño',
              'Media',
              Colors.orange,
            ),
            _buildTicketItem(
              '#2022 - Mantenimiento PC',
              'Hace 2 horas • Recepción',
              'Baja',
              Colors.green,
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  // (Funciones de diseño de tus tarjetas)
  Widget _buildStatCard(
    String count,
    String label,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 15),
            Text(
              count,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile(IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF1B5E20)),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey)),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildTicketItem(
    String title,
    String subtitle,
    String priority,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              priority,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 3. LA PUERTA DEL SUPERVISOR (La que armamos con pestañas)
// ==========================================
class PantallaSupervisor extends StatelessWidget {
  const PantallaSupervisor({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final String userName = user?.displayName ?? 'Supervisor';
    const Color verdeUANL = Color(0xFF1B5E20);
    const Color fondoGrisaceo = Color(0xFFF5F9F5);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: fondoGrisaceo,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: const Text(
            'eccmanager',
            style: TextStyle(
              color: verdeUANL,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: CircleAvatar(
                backgroundColor: verdeUANL.withOpacity(0.1),
                child: Text(
                  userName.isNotEmpty
                      ? userName.substring(0, 1).toUpperCase()
                      : 'S',
                  style: const TextStyle(
                    color: verdeUANL,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
          bottom: const TabBar(
            labelColor: verdeUANL,
            unselectedLabelColor: Colors.grey,
            indicatorColor: verdeUANL,
            indicatorWeight: 3,
            tabs: [
              Tab(text: 'Resumen'),
              Tab(text: 'Gestión de Usuarios'),
            ],
          ),
        ),

        body: TabBarView(
          children: [
            // === PESTAÑA 1: RESUMEN ===
            SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '¡Hola, $userName! 👋',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Aquí tienes el resumen de operaciones de hoy.',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 25),

                  Row(
                    children: [
                      _buildStatCard(
                        '4',
                        'Bajos',
                        Icons.check_circle_outline,
                        Colors.green,
                      ),
                      const SizedBox(width: 12),
                      _buildStatCard(
                        '1',
                        'Rondines',
                        Icons.timer_outlined,
                        Colors.orange,
                      ),
                      const SizedBox(width: 12),
                      _buildStatCard(
                        '0',
                        'Por Vencer',
                        Icons.error_outline,
                        Colors.red,
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),

                  const Text(
                    'Evidencias Recientes',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: verdeUANL,
                    ),
                  ),
                  const SizedBox(height: 15),

                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: 3,
                    itemBuilder: (context, index) {
                      final titulos = [
                        'Salón 2-103',
                        'Salón 11-301',
                        'Salón 2-101',
                      ];
                      final fechas = [
                        'Hace 5 min • Cristof',
                        'Hace 2 horas • Juan',
                        'Hace 1 día • María',
                      ];
                      const urlImagenPrueba = 'https://picsum.photos/400/200';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(20),
                              ),
                              child: Image.network(
                                urlImagenPrueba,
                                height: 160,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    titulos[index],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    fechas[index],
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),

            // === PESTAÑA 2: GESTIÓN DE USUARIOS (Conectada a Firebase) ===
            SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Becarios Registrados',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: verdeUANL,
                    ),
                  ),
                  const SizedBox(height: 15),

                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('usuarios')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(color: verdeUANL),
                        );
                      }
                      if (snapshot.hasError) {
                        return const Center(
                          child: Text(
                            'Error al cargar usuarios',
                            style: TextStyle(color: Colors.red),
                          ),
                        );
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: Text('No hay becarios registrados aún.'),
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          var userDoc = snapshot.data!.docs[index];
                          var data = userDoc.data() as Map<String, dynamic>;

                          // PRIMERO sacamos los datos de Firebase
                          String nombre =
                              data['nombre'] ?? 'Usuario sin nombre';
                          String correo = data['correo'] ?? 'Sin correo';
                          String rol = data['rol'] ?? 'becario';
                          String uid = userDoc.id;

                          // SEGUNDO: AHORA SÍ, como ya sabemos qué es "rol", ya podemos evaluarlo 🛡️
                          bool esIntocable = (rol == 'supervisor');

                          IconData icono = rol == 'admin'
                              ? Icons.keyboard_arrow_down
                              : Icons.keyboard_arrow_up;
                          String nuevoRol = rol == 'admin'
                              ? 'becario'
                              : 'admin';

                          return _buildUserCardReal(
                            nombre,
                            correo,
                            rol,
                            icono,
                            nuevoRol,
                            uid,
                            esIntocable,
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ],
        ),

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
                    Icon(Icons.home_outlined, color: verdeUANL),
                    Text(
                      'Inicio',
                      style: TextStyle(color: verdeUANL, fontSize: 10),
                    ),
                  ],
                ),
                const SizedBox(width: 48),
                GestureDetector(
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();
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
                      Icon(Icons.logout, color: Colors.grey),
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
      ),
    );
  }

  // === WIDGETS DENTRO DE LA CLASE ===
  Widget _buildStatCard(
    String count,
    String label,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  count,
                  style: TextStyle(
                    color: color,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCardReal(
    String nombre,
    String correo,
    String rolActual,
    IconData iconoBoton,
    String nuevoRol,
    String uid,
    bool esIntocable,
  ) {
    const Color verdeUANL = Color(0xFF1B5E20);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: verdeUANL.withOpacity(0.1),
          radius: 25,
          child: Text(
            nombre.isNotEmpty ? nombre.substring(0, 1).toUpperCase() : 'U',
            style: const TextStyle(
              color: verdeUANL,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        title: Text(
          nombre,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '$correo\nRol: $rolActual',
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),

        // 🛡️ EL CANDADO VISUAL: Si es intocable, mostramos un escudo/candado. Si no, mostramos el botón.
        trailing: esIntocable
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Icon(Icons.security, color: Colors.grey, size: 28)],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFE8F5E9),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(iconoBoton, color: verdeUANL, size: 20),
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(8),
                      onPressed: () {
                        FirebaseFirestore.instance
                            .collection('usuarios')
                            .doc(uid)
                            .update({'rol': nuevoRol});
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// ==========================================
// 4. LA PUERTA DEL BECARIO (Por hacer)
// ==========================================
class PantallaBecario extends StatelessWidget {
  const PantallaBecario({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis Tareas')),
      body: const Center(child: Text('Aquí va el diseño del Becario')),
    );
  }
}
