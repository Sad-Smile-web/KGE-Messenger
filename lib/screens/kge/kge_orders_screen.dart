import 'package:flutter/material.dart';

import '../../services/kge_store.dart';
import '../../widgets/kge/kge_panel.dart';
import '../../widgets/l10n_text.dart';

class KgeOrdersScreen extends StatefulWidget {
  const KgeOrdersScreen({super.key});

  @override
  State<KgeOrdersScreen> createState() => _KgeOrdersScreenState();
}

class _KgeOrdersScreenState extends State<KgeOrdersScreen> {
  bool _orderExpanded = false;

  Future<void> _showEvidenceFullscreen() async {
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black,
      builder: (dialogContext) => Dialog.fullscreen(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            Positioned.fill(
              child: InteractiveViewer(
                minScale: 0.8,
                maxScale: 4,
                child: Center(
                  child: Image.asset(
                    'assets/kge/Grab1.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Text(
                      'Не удалось загрузить изображение.',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: SafeArea(
                child: IconButton.filledTonal(
                  tooltip: 'Закрыть изображение',
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  icon: const Icon(Icons.close_rounded),
                  style: IconButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color(0xCC20172A),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: KgeStore.instance,
      builder: (context, _) {
        final store = KgeStore.instance;
        final theme = store.colorTheme;
        final orderAvailable = store.newbiePackInstalled;

        return Scaffold(
          backgroundColor: const Color(0xFF020107),
          appBar: AppBar(
            backgroundColor: const Color(0xD006040B),
            foregroundColor: theme.brightText,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            title: const L10nText(
              'Заказы',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w900,
                decoration: TextDecoration.none,
              ),
            ),
          ),
          body: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(14, 16, 14, 28),
            children: [
              if (!orderAvailable)
                KgePanel(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.primary.withOpacity(0.08),
                          border: Border.all(color: theme.panelBorder),
                        ),
                        child: Icon(Icons.lock_outline_rounded, color: theme.primary, size: 32),
                      ),
                      const SizedBox(height: 16),
                      L10nText(
                        'ЗАКАЗЫ ЗАБЛОКИРОВАНЫ',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: theme.brightText,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 8),
                      L10nText(
                        'Чтобы получить первый заказ, приобретите и установите набор «Новичок» в магазине KGE.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: theme.subtitle, fontSize: 12, height: 1.5),
                      ),
                    ],
                  ),
                )
              else ...[
                Text(
                  'ВХОДЯЩИЕ ЗАКАЗЫ // 01',
                  style: TextStyle(
                    color: theme.subtitle,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.6,
                  ),
                ),
                const SizedBox(height: 12),
                KgePanel(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () => setState(() => _orderExpanded = !_orderExpanded),
                        borderRadius: BorderRadius.circular(18),
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Row(
                            children: [
                              Container(
                                width: 54,
                                height: 54,
                                decoration: BoxDecoration(
                                  color: theme.primary.withOpacity(0.10),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: theme.panelBorder),
                                ),
                                child: Icon(Icons.terminal_rounded, color: theme.primary, size: 27),
                              ),
                              const SizedBox(width: 13),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'LIVEN',
                                      style: TextStyle(
                                        color: theme.brightText,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      'Первый заказ // 13lenen',
                                      style: TextStyle(color: theme.subtitle, fontSize: 11),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'ОЖИДАЕТ ВЫПОЛНЕНИЯ',
                                      style: TextStyle(
                                        color: theme.primary,
                                        fontSize: 8,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                _orderExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                                color: theme.primary,
                              ),
                            ],
                          ),
                        ),
                      ),
                      AnimatedCrossFade(
                        firstChild: const SizedBox(width: double.infinity),
                        secondChild: _buildHackerInterface(theme),
                        crossFadeState: _orderExpanded
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                        duration: const Duration(milliseconds: 280),
                        sizeCurve: Curves.easeOutCubic,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildHackerInterface(KgeColorTheme theme) {
    final labels = <String, String>{
      'ЗАДАНИЕ': 'JOB // LIVEN-001',
      'ОБЪЕКТ': '13LENEN',
      'ИСТОЧНИК': 'КАМЕРА ВИДЕОНАБЛЮДЕНИЯ',
      'СТАТУС': 'ОЖИДАЕТ АНАЛИЗА',
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xCC070611),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: theme.primary.withOpacity(0.4)),
          boxShadow: [
            BoxShadow(color: theme.panelGlow, blurRadius: 18, spreadRadius: 1),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.memory_rounded, color: theme.primary, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'KGE // ИНТЕРФЕЙС АНАЛИЗА',
                    style: TextStyle(
                      color: theme.brightText,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(color: theme.primary, shape: BoxShape.circle),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(height: 1, color: theme.panelBorder),
            const SizedBox(height: 12),
            for (final entry in labels.entries) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 86,
                    child: Text(
                      entry.key,
                      style: TextStyle(
                        color: theme.mutedText,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.7,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      entry.value,
                      style: TextStyle(
                        color: entry.key == 'СТАТУС' ? theme.primary : theme.bodyText,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
            const SizedBox(height: 2),
            Text(
              'МАТЕРИАЛЫ ДЕЛА',
              style: TextStyle(
                color: theme.brightText,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _showEvidenceFullscreen,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Image.asset(
                      'assets/kge/Grab1.png',
                      width: double.infinity,
                      height: 185,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 100,
                        alignment: Alignment.center,
                        color: const Color(0xFF100D18),
                        child: Text('Изображение недоступно', style: TextStyle(color: theme.subtitle)),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.all(8),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.78),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.fullscreen_rounded, color: Colors.white, size: 15),
                          SizedBox(width: 4),
                          Text('ОТКРЫТЬ', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w800)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '> Аналитическая система готова к запуску.\n> Ожидается изучение материалов оператором.',
              style: TextStyle(
                color: theme.primary.withOpacity(0.9),
                fontFamily: 'monospace',
                fontSize: 10,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
