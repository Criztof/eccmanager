import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';

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

            // === PESTAÑA 2: GESTIÓN DE USUARIOS ===
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

                          String nombre =
                              data['nombre'] ?? 'Usuario sin nombre';
                          String correo = data['correo'] ?? 'Sin correo';
                          String rol = data['rol'] ?? 'becario';
                          String uid = userDoc.id;

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