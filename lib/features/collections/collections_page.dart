import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/api_config.dart';
import '../../core/brand_text_styles.dart';
import '../../core/user_friendly_messages.dart';
import '../../models/collection.dart';
import '../../services/collection_service.dart';
import '../../widgets/scroll_reveal.dart';
import '../../widgets/shop_shell.dart';

class CollectionsPage extends StatefulWidget {
  const CollectionsPage({super.key});

  @override
  State<CollectionsPage> createState() => _CollectionsPageState();
}

class _CollectionsPageState extends State<CollectionsPage> {
  final service = CollectionService();

  static const Map<String, List<String>> _collectionImageBaseBySlug = {
    'kurtis': ['kurta1'],
    'dress': ['dress1'],
    'shirts': ['shirt1'],
    'tshirts': ['tshirt1'],
  };

  List<String> _collectionImageCandidates(String slug) {
    final bases = _collectionImageBaseBySlug[slug];
    if (bases == null) return const [];
    final urls = <String>[];
    for (final base in bases) {
      urls.add('${ApiConfig.baseUrl}/static/collections/$base.png');
    }
    return urls;
  }

  _CollectionStyle _styleFor(String slug) {
    switch (slug) {
      case 'tshirts':
        return const _CollectionStyle(
          icon: Icons.checkroom_outlined,
          start: Color(0xFFFFFBF5),
          end: Color(0xFFF6EFE6),
        );
      case 'shirts':
        return const _CollectionStyle(
          icon: Icons.dry_cleaning_outlined,
          start: Color(0xFFF9FBFF),
          end: Color(0xFFEEF3FA),
        );
      case 'dress':
        return const _CollectionStyle(
          icon: Icons.auto_awesome_outlined,
          start: Color(0xFFFFF9FC),
          end: Color(0xFFF7ECF2),
        );
      case 'kurtis':
      default:
        return const _CollectionStyle(
          icon: Icons.local_florist_outlined,
          start: Color(0xFFFFFFFF),
          end: Color(0xFFF6F4F1),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ShopShell(
        child: FutureBuilder<List<dynamic>>(
          future: service.listCollections(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) {
              return const Center(child: Text(kMaintenanceMessage));
            }

            final collections = (snap.data ?? [])
                .map((e) => Collection.fromJson(e as Map<String, dynamic>))
                .toList();

            if (collections.isEmpty) {
              return const Center(child: Text('No collections found'));
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Collections',
                  style: formalHeadingStyle(size: 30, weight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  'Discover curated styles from Elegant Way.',
                  style: inlineAccentStyle(),
                ),
                const SizedBox(height: 14),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 280,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 1.08,
                  ),
                  itemCount: collections.length,
                  itemBuilder: (context, i) {
                    final c = collections[i];
                    final style = _styleFor(c.slug);
                    return ScrollReveal(
                      delayMs: 35 * i,
                      child: InkWell(
                        onTap: () => context.go('/c/${c.slug}'),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [style.start, style.end],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFEDEDED)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.white.withValues(alpha: 0.7),
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: _CollectionPreviewImage(
                                    candidates: _collectionImageCandidates(c.slug),
                                    fallbackIcon: style.icon,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: const Text(
                                  'SHOP',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                c.name,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                c.slug.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CollectionStyle {
  final IconData icon;
  final Color start;
  final Color end;

  const _CollectionStyle({
    required this.icon,
    required this.start,
    required this.end,
  });
}

class _CollectionPreviewImage extends StatefulWidget {
  final List<String> candidates;
  final IconData fallbackIcon;

  const _CollectionPreviewImage({
    required this.candidates,
    required this.fallbackIcon,
  });

  @override
  State<_CollectionPreviewImage> createState() => _CollectionPreviewImageState();
}

class _CollectionPreviewImageState extends State<_CollectionPreviewImage> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.candidates.isEmpty || _index >= widget.candidates.length) {
      return Center(
        child: Icon(widget.fallbackIcon, size: 34, color: Colors.black45),
      );
    }

    return Image.network(
      widget.candidates[_index],
      fit: BoxFit.contain,
      alignment: Alignment.center,
      errorBuilder: (context, error, stackTrace) {
        if (_index < widget.candidates.length - 1) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            setState(() => _index += 1);
          });
          return const SizedBox.shrink();
        }
        return Center(
          child: Icon(widget.fallbackIcon, size: 34, color: Colors.black45),
        );
      },
    );
  }
}
