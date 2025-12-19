import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/mahasiswa/mahasiswa_viewmodel.dart';
import 'tabs/beranda_page.dart';
import 'tabs/kursus_page.dart';
import 'tabs/notifikasi_page.dart';
import 'tabs/profile_page.dart';

import '../../widgets/custom_user_appbar.dart';
import '../../widgets/custom_settings_drawer.dart';

class MahasiswaPage
    extends
        StatefulWidget {
  const MahasiswaPage({
    super.key,
  });

  @override
  State<
    MahasiswaPage
  >
  createState() => _MahasiswaPageState();
}

class _MahasiswaPageState
    extends
        State<
          MahasiswaPage
        > {
  bool isDarkMode = false;

  void toggleTheme() {
    setState(
      () => isDarkMode = !isDarkMode,
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return ChangeNotifierProvider(
      create:
          (
            _,
          ) => MahasiswaViewModel(),
      child:
          Consumer<
            MahasiswaViewModel
          >(
            builder:
                (
                  context,
                  vm,
                  _,
                ) {
                  final pages = const [
                    BerandaMahasiswaPage(),
                    KursusPage(),
                    NotifikasiPage(),
                    ProfilPage(),
                  ];

                  return Scaffold(
                    backgroundColor: const Color(
                      0xFFF4F7FF,
                    ),

                    // ✅ Drawer
                    drawer: CustomSettingsDrawer(
                      isDarkMode: isDarkMode,
                      onToggleTheme: toggleTheme,
                    ),

                    // ✅ AppBar custom
                    appBar: const CustomUserAppBar(
                      userName: "Mahasiswa", // nanti bisa dari session / auth
                      subtitle: "Program / Kelas",
                      avatarAssetPath: "assets/images/alvian.jpg", // sesuaikan
                    ),

                    body: pages[vm.selectedIndex],

                    // bottom nav floating kamu tetap
                    bottomNavigationBar: Container(
                      margin: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        bottom: 16,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(
                          0xFF002F6C,
                        ),
                        borderRadius: BorderRadius.circular(
                          24,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(
                              0.2,
                            ),
                            blurRadius: 12,
                            offset: const Offset(
                              0,
                              6,
                            ),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                          24,
                        ),
                        child: BottomNavigationBar(
                          currentIndex: vm.selectedIndex,
                          onTap: vm.changeTab,
                          type: BottomNavigationBarType.fixed,
                          backgroundColor: const Color(
                            0xFF002F6C,
                          ),
                          selectedItemColor: Colors.white,
                          unselectedItemColor: Colors.white70,
                          showSelectedLabels: false,
                          showUnselectedLabels: false,
                          items: const [
                            BottomNavigationBarItem(
                              icon: Icon(
                                Icons.home_outlined,
                              ),
                              activeIcon: Icon(
                                Icons.home,
                              ),
                              label: 'Beranda',
                            ),
                            BottomNavigationBarItem(
                              icon: Icon(
                                Icons.book_outlined,
                              ),
                              activeIcon: Icon(
                                Icons.book,
                              ),
                              label: 'Kursus',
                            ),
                            BottomNavigationBarItem(
                              icon: Icon(
                                Icons.notifications_outlined,
                              ),
                              activeIcon: Icon(
                                Icons.notifications,
                              ),
                              label: 'Notif',
                            ),
                            BottomNavigationBarItem(
                              icon: Icon(
                                Icons.person_outline,
                              ),
                              activeIcon: Icon(
                                Icons.person,
                              ),
                              label: 'Profil',
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
          ),
    );
  }
}
