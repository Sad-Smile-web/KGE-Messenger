import 'package:flutter/material.dart';

import '../../services/app_localization.dart';
import '../../screens/kge/kge_home_screen.dart';
import '../l10n_text.dart';

class KgeShell extends StatefulWidget {
  const KgeShell({
    super.key,
  });

  @override
  State<KgeShell> createState() =>
      _KgeShellState();
}

class _KgeShellState
    extends State<KgeShell> {
  int _selectedIndex = 0;

  final List<String> _titles = const [
    'Главная',
    'Операции',
    'Новости',
  ];

  void _selectPage(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
      const Color(0xFF030107),
      appBar: _buildAppBar(),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          const KgeHomeScreen(),
          _PlaceholderPage(
            title: 'Операции',
            description:
            'Этот раздел будет настроен позже.',
          ),
          _PlaceholderPage(
            title: 'Новости',
            description:
            'Новостей нет',
          ),
        ],
      ),
      bottomNavigationBar:
      _buildNavigationBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor:
      const Color(0xF2060409),
      surfaceTintColor:
      Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: IconButton(
        tooltip: L10n.t('Назад'),
        onPressed: () {
          Navigator.pop(context);
        },
        icon: const Icon(
          Icons.arrow_back_rounded,
          color: Color(
            0xFFDCCBE8,
          ),
        ),
      ),
      titleSpacing: 0,
      title: Row(
        children: [
          _KgeMiniLogo(),
          const SizedBox(
            width: 10,
          ),
          Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              const Text(
                'KGE',
                style: TextStyle(
                  color: Color(
                    0xFFF3E8FF,
                  ),
                  fontSize: 20,
                  fontWeight:
                  FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
              L10nText(
                _titles[_selectedIndex],
                style: const TextStyle(
                  color: Color(
                    0xFF957CA7,
                  ),
                  fontSize: 9,
                  fontWeight:
                  FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        Container(
          margin:
          const EdgeInsets.only(
            right: 10,
          ),
          padding:
          const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 6,
          ),
          decoration:
          BoxDecoration(
            color: const Color(
              0x141C002E,
            ),
            borderRadius:
            BorderRadius.circular(
              10,
            ),
            border: Border.all(
              color: const Color(
                0x383B1460,
              ),
            ),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.circle,
                color: Color(
                  0xFFB45CFF,
                ),
                size: 7,
              ),
              SizedBox(
                width: 6,
              ),
              L10nText(
                'ONLINE',
                style: TextStyle(
                  color: Color(
                    0xFFAB91BC,
                  ),
                  fontSize: 8,
                  fontWeight:
                  FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(
          0xF0060409,
        ),
        border: Border(
          top: BorderSide(
            color: Color(
              0x302F1546,
            ),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding:
          const EdgeInsets.fromLTRB(
            10,
            8,
            10,
            8,
          ),
          child: Row(
            children: [
              Expanded(
                child: _NavItem(
                  icon:
                  Icons.home_rounded,
                  label: 'Главная',
                  selected:
                  _selectedIndex == 0,
                  onTap: () =>
                      _selectPage(0),
                ),
              ),
              Expanded(
                child: _NavItem(
                  icon:
                  Icons.hub_rounded,
                  label: 'Операции',
                  selected:
                  _selectedIndex == 1,
                  onTap: () =>
                      _selectPage(1),
                ),
              ),
              Expanded(
                child: _NavItem(
                  icon:
                  Icons.newspaper_rounded,
                  label: 'Новости',
                  selected:
                  _selectedIndex == 2,
                  onTap: () =>
                      _selectPage(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius:
      BorderRadius.circular(15),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(
          milliseconds: 180,
        ),
        padding:
        const EdgeInsets.symmetric(
          vertical: 8,
        ),
        decoration:
        BoxDecoration(
          color: selected
              ? const Color(
            0x141A0030,
          )
              : Colors.transparent,
          borderRadius:
          BorderRadius.circular(
            15,
          ),
        ),
        child: Column(
          mainAxisSize:
          MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 21,
              color: selected
                  ? const Color(
                0xFFC26EFF,
              )
                  : const Color(
                0xFF695777,
              ),
            ),
            const SizedBox(
              height: 4,
            ),
            L10nText(
              label,
              style: TextStyle(
                color: selected
                    ? const Color(
                  0xFFCAA5E1,
                )
                    : const Color(
                  0xFF675572,
                ),
                fontSize: 9,
                fontWeight: selected
                    ? FontWeight.w800
                    : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KgeMiniLogo
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration:
      BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(
            0xFF9F42E8,
          ),
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(
              0x553F00FF,
            ),
            blurRadius: 12,
          ),
        ],
      ),
      child: const Center(
        child: Text(
          'K',
          style: TextStyle(
            color: Color(
              0xFFD3A0FF,
            ),
            fontSize: 16,
            fontWeight:
            FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _PlaceholderPage
    extends StatelessWidget {
  final String title;
  final String description;

  const _PlaceholderPage({
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding:
        const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration:
              BoxDecoration(
                shape:
                BoxShape.circle,
                color: const Color(
                  0x141A0030,
                ),
                border: Border.all(
                  color: const Color(
                    0x663F146D,
                  ),
                ),
              ),
              child: const Icon(
                Icons.code_rounded,
                color: Color(
                  0xFF9F42E8,
                ),
                size: 30,
              ),
            ),
            const SizedBox(
              height: 18,
            ),
            L10nText(
              title,
              style: const TextStyle(
                color: Color(
                  0xFFEEDFFF,
                ),
                fontSize: 20,
                fontWeight:
                FontWeight.w800,
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            L10nText(
              description,
              textAlign:
              TextAlign.center,
              style: const TextStyle(
                color: Color(
                  0xFF917D9F,
                ),
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}