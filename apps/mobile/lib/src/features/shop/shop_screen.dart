import 'package:flutter/material.dart';

import '../../core/utils/formatters.dart';
import '../../core/widgets/mystic_ui.dart';
import '../../models/app_models.dart';
import '../../models/shop_models.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({
    super.key,
    required this.data,
    required this.onRefresh,
    required this.onCreateOrder,
    required this.onCreateProduct,
    required this.onUpdateProduct,
    required this.onUpdateOrderStatus,
    this.canManageShop = false,
  });

  final AppBootstrap data;
  final Future<void> Function() onRefresh;
  final Future<ShopOrder> Function(CreateShopOrderInput input) onCreateOrder;
  final Future<ShopProduct> Function(CreateShopProductInput input)
      onCreateProduct;
  final Future<ShopProduct> Function({
    required String productId,
    required UpdateShopProductInput input,
  }) onUpdateProduct;
  final Future<ShopOrder> Function({
    required String orderId,
    required String status,
  }) onUpdateOrderStatus;
  final bool canManageShop;

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  static const _allCategory = 'Todos';

  String _selectedCategory = _allCategory;
  _ShopSection _selectedSection = _ShopSection.home;
  final Map<String, int> _cart = <String, int>{};

  @override
  void initState() {
    super.initState();
    if (widget.canManageShop) {
      _selectedSection = _ShopSection.admin;
    }
  }

  @override
  void didUpdateWidget(covariant ShopScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    final validIds = widget.data.shop.products.map((item) => item.id).toSet();
    _cart.removeWhere((productId, _) => !validIds.contains(productId));

    if (widget.canManageShop) {
      _cart.clear();
      if (!oldWidget.canManageShop ||
          (_selectedSection != _ShopSection.admin &&
              _selectedSection != _ShopSection.orders)) {
        _selectedSection = _ShopSection.admin;
      }
    } else if (oldWidget.canManageShop &&
        _selectedSection == _ShopSection.admin) {
      _selectedSection = _ShopSection.home;
    }
  }

  @override
  Widget build(BuildContext context) {
    final products = widget.data.shop.products;
    final categories = <String>{
      _allCategory,
      ...products.map((item) => item.category),
    }.toList();
    final featured = products.where((item) => item.featured).toList();
    final visibleProducts = _selectedCategory == _allCategory
        ? products
        : products
            .where((item) => item.category == _selectedCategory)
            .toList(growable: false);
    final cartLines =
        widget.canManageShop ? <_CartLine>[] : _cartLines(products);
    final cartItemCount = cartLines.fold<int>(
      0,
      (sum, line) => sum + line.quantity,
    );
    final cartSubtotal = cartLines.fold<double>(
      0,
      (sum, line) => sum + (line.product.price.amount * line.quantity),
    );
    final cartShipping = cartSubtotal >= 120 || cartSubtotal == 0 ? 0.0 : 9.0;
    final cartTotal = cartSubtotal + cartShipping;
    final pendingOrders = widget.data.shop.orders
        .where(
            (order) => order.status == 'pending' || order.status == 'confirmed')
        .length;
    final lowStockProducts = products.where(_isLowStockProduct).toList();
    final customizableProducts =
        products.where(_isCustomizableProduct).toList(growable: false);
    final visibleSections = widget.canManageShop
        ? const [_ShopSection.admin]
        : _ShopSection.values
            .where((section) => section != _ShopSection.admin)
            .toList(growable: false);
    final effectiveSection = visibleSections.contains(_selectedSection)
        ? _selectedSection
        : widget.canManageShop
            ? _ShopSection.admin
            : _ShopSection.home;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFFF8F1),
            Color(0xFFF6EFE8),
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            RefreshIndicator(
              onRefresh: widget.onRefresh,
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  20,
                  14,
                  20,
                  widget.canManageShop || cartLines.isEmpty ? 28 : 126,
                ),
                children: [
                  MysticBannerCard(
                    eyebrow: widget.data.shop.title,
                    title: widget.canManageShop
                        ? 'Productos y órdenes'
                        : 'Objetos, mazos y piezas para tu ritual',
                    subtitle: widget.canManageShop
                        ? 'Gestiona catálogo, fotos, stock, destacados y órdenes sin flujo de compra.'
                        : widget.data.shop.subtitle,
                    glyphKind: MysticGlyphKind.ritual,
                    gradient: const [
                      Color(0xFF1F1820),
                      Color(0xFF5F3B4E),
                      Color(0xFFB97B5A),
                    ],
                    tags: [
                      '${products.length} productos',
                      '$pendingOrders pendientes',
                      '${lowStockProducts.length} bajo stock',
                      '${customizableProducts.length} personalizables',
                    ],
                    primaryLabel: widget.canManageShop
                        ? 'Nuevo producto'
                        : cartLines.isEmpty
                            ? 'Ir al catálogo'
                            : 'Revisar pedido · ${_formatUsd(cartTotal)}',
                    onPrimaryTap: widget.canManageShop
                        ? _openCreateProductSheet
                        : cartLines.isEmpty
                            ? () {
                                setState(() {
                                  _selectedSection = _ShopSection.catalog;
                                });
                              }
                            : _openCheckoutSheet,
                    secondaryLabel: widget.canManageShop ? null : 'Órdenes',
                    onSecondaryTap: widget.canManageShop
                        ? null
                        : () {
                            setState(() {
                              _selectedSection = _ShopSection.orders;
                            });
                          },
                  ),
                  const SizedBox(height: 18),
                  _ShopMetricsGrid(
                    productCount: products.length,
                    featuredCount: featured.length,
                    pendingOrderCount: pendingOrders,
                    lowStockCount: lowStockProducts.length,
                  ),
                  const SizedBox(height: 18),
                  _ShopSectionTabs(
                    sections: visibleSections,
                    selected: effectiveSection,
                    onSelected: (section) {
                      setState(() {
                        _selectedSection = section;
                      });
                    },
                  ),
                  const SizedBox(height: 18),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    child: KeyedSubtree(
                      key: ValueKey(effectiveSection),
                      child: switch (effectiveSection) {
                        _ShopSection.home => _ShopHomeView(
                            featured: featured,
                            categories: categories,
                            products: products,
                            cart: _cart,
                            onAdd: _incrementProduct,
                            onRemove: _decrementProduct,
                            onOpenCatalog: () {
                              setState(() {
                                _selectedSection = _ShopSection.catalog;
                              });
                            },
                          ),
                        _ShopSection.catalog => _ShopCatalogView(
                            categories: categories,
                            selectedCategory: _selectedCategory,
                            visibleProducts: visibleProducts,
                            cart: _cart,
                            onSelectCategory: (category) {
                              setState(() {
                                _selectedCategory = category;
                              });
                            },
                            onAdd: _incrementProduct,
                            onRemove: _decrementProduct,
                          ),
                        _ShopSection.orders => _ShopOrdersView(
                            orders: widget.data.shop.orders,
                            supportNote: widget.data.shop.supportNote,
                          ),
                        _ShopSection.admin => _ShopAdminView(
                            products: products,
                            orders: widget.data.shop.orders,
                            lowStockProducts: lowStockProducts,
                            customizableProducts: customizableProducts,
                            onCreateProduct: _openCreateProductSheet,
                            onEditStock: _openStockManagerSheet,
                            onEditFeatured: _openFeaturedManagerSheet,
                            onOpenOrders: () {
                              setState(() {
                                _selectedSection = _ShopSection.admin;
                              });
                            },
                            onUpdateOrderStatus: _updateOrderStatus,
                          ),
                      },
                    ),
                  ),
                ],
              ),
            ),
            if (!widget.canManageShop && cartLines.isNotEmpty)
              Positioned(
                left: 20,
                right: 20,
                bottom: 18,
                child: _FloatingCartBar(
                  itemCount: cartItemCount,
                  total: cartTotal,
                  onTap: _openCheckoutSheet,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _openCheckoutSheet() async {
    if (widget.canManageShop) {
      return;
    }

    final cartLines = _cartLines(widget.data.shop.products);
    if (cartLines.isEmpty) {
      return;
    }

    final order = await showModalBottomSheet<ShopOrder>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _CheckoutSheet(
          lines: cartLines,
          suggestedAddress: widget.data.user.location,
          onSubmit: (deliveryAddress, notes) async {
            return widget.onCreateOrder(
              CreateShopOrderInput(
                items: cartLines
                    .map(
                      (line) => CreateShopOrderItemInput(
                        productId: line.product.id,
                        quantity: line.quantity,
                      ),
                    )
                    .toList(),
                deliveryAddress: deliveryAddress,
                notes: notes,
              ),
            );
          },
        );
      },
    );

    if (!mounted || order == null) {
      return;
    }

    setState(() {
      _cart.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Orden ${order.orderCode} creada por ${formatMoney(order.total)}.',
        ),
      ),
    );
  }

  List<_CartLine> _cartLines(List<ShopProduct> products) {
    final byId = {
      for (final product in products) product.id: product,
    };
    return _cart.entries
        .where((entry) => entry.value > 0 && byId.containsKey(entry.key))
        .map(
          (entry) => _CartLine(
            product: byId[entry.key]!,
            quantity: entry.value,
          ),
        )
        .toList(growable: false);
  }

  void _incrementProduct(String productId) {
    if (widget.canManageShop) {
      return;
    }

    setState(() {
      _cart.update(productId, (value) => value + 1, ifAbsent: () => 1);
    });
  }

  void _decrementProduct(String productId) {
    if (widget.canManageShop) {
      return;
    }

    final current = _cart[productId] ?? 0;
    if (current <= 1) {
      setState(() {
        _cart.remove(productId);
      });
      return;
    }

    setState(() {
      _cart[productId] = current - 1;
    });
  }

  Future<void> _openCreateProductSheet() async {
    final product = await showModalBottomSheet<ShopProduct>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _ProductEditorSheet(
          categories: widget.data.shop.products
              .map((product) => product.category)
              .toSet()
              .toList(),
          onSubmit: widget.onCreateProduct,
        );
      },
    );

    if (!mounted || product == null) {
      return;
    }

    setState(() {
      _selectedSection =
          widget.canManageShop ? _ShopSection.admin : _ShopSection.catalog;
      _selectedCategory = product.category;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${product.name} agregado al catálogo.')),
    );
  }

  Future<void> _openStockManagerSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _StockManagerSheet(
          products: widget.data.shop.products,
          onUpdateStock: (product, stockLabel) {
            return widget.onUpdateProduct(
              productId: product.id,
              input: UpdateShopProductInput(stockLabel: stockLabel),
            );
          },
        );
      },
    );
  }

  Future<void> _openFeaturedManagerSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _FeaturedManagerSheet(
          products: widget.data.shop.products,
          onUpdateFeatured: (product, featured) {
            return widget.onUpdateProduct(
              productId: product.id,
              input: UpdateShopProductInput(featured: featured),
            );
          },
        );
      },
    );
  }

  Future<void> _updateOrderStatus(ShopOrder order, String status) async {
    try {
      final updated = await widget.onUpdateOrderStatus(
        orderId: order.id,
        status: status,
      );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${updated.orderCode} actualizado a ${_statusCopy(updated.status).label}.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    }
  }
}

enum _ShopSection { home, catalog, orders, admin }

class _ShopMetricsGrid extends StatelessWidget {
  const _ShopMetricsGrid({
    required this.productCount,
    required this.featuredCount,
    required this.pendingOrderCount,
    required this.lowStockCount,
  });

  final int productCount;
  final int featuredCount;
  final int pendingOrderCount;
  final int lowStockCount;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tileWidth = (constraints.maxWidth - 12) / 2;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _MetricTile(
              width: tileWidth,
              icon: Icons.inventory_2_outlined,
              label: 'Productos',
              value: '$productCount',
              tone: const Color(0xFF5C3B52),
            ),
            _MetricTile(
              width: tileWidth,
              icon: Icons.auto_awesome_rounded,
              label: 'Destacados',
              value: '$featuredCount',
              tone: const Color(0xFFB47658),
            ),
            _MetricTile(
              width: tileWidth,
              icon: Icons.receipt_long_rounded,
              label: 'Pendientes',
              value: '$pendingOrderCount',
              tone: const Color(0xFF7C5A2D),
            ),
            _MetricTile(
              width: tileWidth,
              icon: Icons.warning_amber_rounded,
              label: 'Bajo stock',
              value: '$lowStockCount',
              tone: const Color(0xFF8C4C43),
            ),
          ],
        );
      },
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.width,
    required this.icon,
    required this.label,
    required this.value,
    required this.tone,
  });

  final double width;
  final IconData icon;
  final String label;
  final String value;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE7DED3)),
          boxShadow: [
            BoxShadow(
              color: tone.withValues(alpha: 0.08),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: tone.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: tone, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF1E1A1A),
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: const Color(0xFF6E625B),
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShopSectionTabs extends StatelessWidget {
  const _ShopSectionTabs({
    required this.sections,
    required this.selected,
    required this.onSelected,
  });

  final List<_ShopSection> sections;
  final _ShopSection selected;
  final ValueChanged<_ShopSection> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: sections.map((section) {
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: _ShopSectionButton(
              section: section,
              selected: section == selected,
              onTap: () => onSelected(section),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ShopSectionButton extends StatelessWidget {
  const _ShopSectionButton({
    required this.section,
    required this.selected,
    required this.onTap,
  });

  final _ShopSection section;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = selected ? const Color(0xFF5C3B52) : const Color(0xFF7A6B60);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
          decoration: BoxDecoration(
            color: selected ? accent.withValues(alpha: 0.13) : Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected
                  ? accent.withValues(alpha: 0.32)
                  : const Color(0xFFE7DED3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_sectionIcon(section), color: accent, size: 18),
              const SizedBox(width: 8),
              Text(
                _sectionLabel(section),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: accent,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShopHomeView extends StatelessWidget {
  const _ShopHomeView({
    required this.featured,
    required this.categories,
    required this.products,
    required this.cart,
    required this.onAdd,
    required this.onRemove,
    required this.onOpenCatalog,
  });

  final List<ShopProduct> featured;
  final List<String> categories;
  final List<ShopProduct> products;
  final Map<String, int> cart;
  final ValueChanged<String> onAdd;
  final ValueChanged<String> onRemove;
  final VoidCallback onOpenCatalog;

  @override
  Widget build(BuildContext context) {
    final catalogCategories = categories
        .where((category) => category != _ShopScreenState._allCategory);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(
          title: 'Selección destacada',
          subtitle:
              'Piezas con más intención visual para abrir la tienda como una boutique ritual.',
        ),
        const SizedBox(height: 12),
        if (featured.isEmpty)
          const _EmptyState(
            title: 'Todavía no hay destacados',
            subtitle:
                'Cuando el catálogo tenga piezas marcadas como favoritas aparecerán aquí.',
          )
        else
          SizedBox(
            height: 292,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: featured.length,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                final product = featured[index];
                return SizedBox(
                  width: 238,
                  child: _FeaturedProductCard(
                    product: product,
                    quantity: cart[product.id] ?? 0,
                    onAdd: () => onAdd(product.id),
                    onRemove: () => onRemove(product.id),
                  ),
                );
              },
            ),
          ),
        const SizedBox(height: 24),
        _SectionTitle(
          title: 'Colecciones',
          subtitle:
              'Agrupa la tienda por familias para ubicar stock, destacados y piezas personalizadas más rápido.',
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: catalogCategories.map((category) {
            final count = products
                .where((product) => product.category == category)
                .length;
            return _CollectionTile(
              label: category,
              count: count,
              onTap: onOpenCatalog,
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onOpenCatalog,
            icon: const Icon(Icons.grid_view_rounded),
            label: const Text('Ver catálogo completo'),
          ),
        ),
      ],
    );
  }
}

class _CollectionTile extends StatelessWidget {
  const _CollectionTile({
    required this.label,
    required this.count,
    required this.onTap,
  });

  final String label;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 158,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFFFFFF),
                  Color(0xFFFFF5EA),
                ],
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFE7DED3)),
            ),
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  _categoryIcon(label),
                  color: const Color(0xFF8C6239),
                ),
                const SizedBox(height: 14),
                Text(
                  label,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$count productos',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF6E625B),
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ShopCatalogView extends StatelessWidget {
  const _ShopCatalogView({
    required this.categories,
    required this.selectedCategory,
    required this.visibleProducts,
    required this.cart,
    required this.onSelectCategory,
    required this.onAdd,
    required this.onRemove,
  });

  final List<String> categories;
  final String selectedCategory;
  final List<ShopProduct> visibleProducts;
  final Map<String, int> cart;
  final ValueChanged<String> onSelectCategory;
  final ValueChanged<String> onAdd;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(
          title: 'Catálogo visual',
          subtitle:
              'Vista tipo boutique: imagen primero, precio claro, stock visible y acción rápida para agregar.',
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: categories
              .map(
                (category) => _CategoryChip(
                  label: category,
                  selected: category == selectedCategory,
                  onTap: () => onSelectCategory(category),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 18),
        if (visibleProducts.isEmpty)
          const _EmptyState(
            title: 'No hay artículos en esta categoría',
            subtitle:
                'Prueba otro filtro o vuelve a Todos para ver el catálogo completo.',
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final tileWidth = (constraints.maxWidth - 12) / 2;

              return Wrap(
                spacing: 12,
                runSpacing: 14,
                children: visibleProducts.map((product) {
                  return SizedBox(
                    width: tileWidth,
                    child: _CatalogProductTile(
                      product: product,
                      quantity: cart[product.id] ?? 0,
                      onAdd: () => onAdd(product.id),
                      onRemove: () => onRemove(product.id),
                    ),
                  );
                }).toList(),
              );
            },
          ),
      ],
    );
  }
}

class _CatalogProductTile extends StatelessWidget {
  const _CatalogProductTile({
    required this.product,
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
  });

  final ShopProduct product;
  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFE7DED3)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF946244).withValues(alpha: 0.07),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 0.92,
            child: Stack(
              fit: StackFit.expand,
              children: [
                _ProductArtwork(product: product),
                Positioned(
                  left: 10,
                  top: 10,
                  child: _MiniPill(
                    label: product.badge,
                    color: const Color(0xFF2A1D23),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(13, 12, 13, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        height: 1.08,
                      ),
                ),
                const SizedBox(height: 7),
                Text(
                  product.stockLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: _stockColor(product.stockLabel),
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 10),
                Text(
                  formatMoney(product.price),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 12),
                _CompactQuantityControl(
                  quantity: quantity,
                  onAdd: onAdd,
                  onRemove: onRemove,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactQuantityControl extends StatelessWidget {
  const _CompactQuantityControl({
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
  });

  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    if (quantity == 0) {
      return SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: onAdd,
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            visualDensity: VisualDensity.compact,
          ),
          child: const Text('Agregar'),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F2EA),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: onRemove,
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.remove_rounded),
          ),
          Text(
            '$quantity',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          IconButton(
            onPressed: onAdd,
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
    );
  }
}

class _ShopOrdersView extends StatelessWidget {
  const _ShopOrdersView({
    required this.orders,
    required this.supportNote,
  });

  final List<ShopOrder> orders;
  final String supportNote;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(
          title: 'Órdenes',
          subtitle: supportNote,
        ),
        const SizedBox(height: 12),
        _OrderPipeline(orders: orders),
        const SizedBox(height: 16),
        if (orders.isEmpty)
          const _EmptyState(
            title: 'Aún no hay órdenes',
            subtitle:
                'Cuando generes tu primer checkout aparecerá aquí con código y total.',
          )
        else
          ...orders.map(
            (order) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _OrderCard(order: order),
            ),
          ),
      ],
    );
  }
}

class _OrderPipeline extends StatelessWidget {
  const _OrderPipeline({
    required this.orders,
  });

  final List<ShopOrder> orders;

  @override
  Widget build(BuildContext context) {
    final stages = [
      _PipelineStage('Pendiente', 'pending', const Color(0xFF8C4C43)),
      _PipelineStage('Confirmada', 'confirmed', const Color(0xFF4F7B67)),
      _PipelineStage('Preparando', 'preparing', const Color(0xFF8C6239)),
      _PipelineStage('Enviada', 'shipped', const Color(0xFF3E6381)),
    ];

    return SizedBox(
      height: 104,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: stages.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final stage = stages[index];
          final count =
              orders.where((order) => order.status == stage.status).length;
          return _PipelineTile(stage: stage, count: count);
        },
      ),
    );
  }
}

class _PipelineTile extends StatelessWidget {
  const _PipelineTile({
    required this.stage,
    required this.count,
  });

  final _PipelineStage stage;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 142,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: stage.color.withValues(alpha: 0.2)),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: stage.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(Icons.local_shipping_outlined, color: stage.color),
          ),
          const Spacer(),
          Text(
            '$count',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          Text(
            stage.label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: const Color(0xFF6E625B),
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}

class _ShopAdminView extends StatelessWidget {
  const _ShopAdminView({
    required this.products,
    required this.orders,
    required this.lowStockProducts,
    required this.customizableProducts,
    required this.onCreateProduct,
    required this.onEditStock,
    required this.onEditFeatured,
    required this.onOpenOrders,
    required this.onUpdateOrderStatus,
  });

  final List<ShopProduct> products;
  final List<ShopOrder> orders;
  final List<ShopProduct> lowStockProducts;
  final List<ShopProduct> customizableProducts;
  final VoidCallback onCreateProduct;
  final VoidCallback onEditStock;
  final VoidCallback onEditFeatured;
  final VoidCallback onOpenOrders;
  final Future<void> Function(ShopOrder order, String status)
      onUpdateOrderStatus;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(
          title: 'Administrar tienda',
          subtitle:
              'Centro visual para preparar gestión de productos, stock, destacados y seguimiento de órdenes.',
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final tileWidth = (constraints.maxWidth - 12) / 2;

            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _AdminActionCard(
                  width: tileWidth,
                  title: 'Nuevo producto',
                  subtitle: '${products.length} en catálogo',
                  icon: Icons.add_box_outlined,
                  color: const Color(0xFF5C3B52),
                  onTap: onCreateProduct,
                ),
                _AdminActionCard(
                  width: tileWidth,
                  title: 'Editar stock',
                  subtitle: '${lowStockProducts.length} alertas',
                  icon: Icons.inventory_outlined,
                  color: const Color(0xFF8C4C43),
                  onTap: onEditStock,
                ),
                _AdminActionCard(
                  width: tileWidth,
                  title: 'Destacados',
                  subtitle:
                      '${products.where((product) => product.featured).length} activos',
                  icon: Icons.auto_awesome_rounded,
                  color: const Color(0xFFB47658),
                  onTap: onEditFeatured,
                ),
                _AdminActionCard(
                  width: tileWidth,
                  title: 'Órdenes',
                  subtitle: '${orders.length} recientes',
                  icon: Icons.receipt_long_rounded,
                  color: const Color(0xFF4F7B67),
                  onTap: onOpenOrders,
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 22),
        _SectionTitle(
          title: 'Alertas de inventario',
          subtitle: lowStockProducts.isEmpty
              ? 'No hay productos marcados con bajo stock en este momento.'
              : 'Prioriza estas piezas antes de empujar campañas o destacados.',
        ),
        const SizedBox(height: 12),
        if (lowStockProducts.isEmpty)
          const _EmptyState(
            title: 'Stock estable',
            subtitle:
                'Cuando un producto indique pocas unidades aparecerá en este bloque.',
          )
        else
          ...lowStockProducts.map(
            (product) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _InventoryRow(product: product),
            ),
          ),
        const SizedBox(height: 14),
        _SectionTitle(
          title: 'Personalizables',
          subtitle:
              'Productos que requieren coordinación extra antes de preparar la orden.',
        ),
        const SizedBox(height: 12),
        if (customizableProducts.isEmpty)
          const _EmptyState(
            title: 'Sin piezas personalizables',
            subtitle:
                'Los cuadros o pedidos hechos a medida aparecerán aquí cuando el catálogo los marque.',
          )
        else
          ...customizableProducts.map(
            (product) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _InventoryRow(product: product),
            ),
          ),
        const SizedBox(height: 14),
        const _SectionTitle(
          title: 'Gestión de órdenes',
          subtitle:
              'Cambia el estado operativo de cada orden sin salir de la tienda.',
        ),
        const SizedBox(height: 12),
        if (orders.isEmpty)
          const _EmptyState(
            title: 'Sin órdenes para gestionar',
            subtitle:
                'Cuando existan pedidos, podrás moverlos entre pendiente, confirmada, preparando y enviada.',
          )
        else
          ...orders.take(6).map(
                (order) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _AdminOrderRow(
                    order: order,
                    onUpdateStatus: (status) =>
                        onUpdateOrderStatus(order, status),
                  ),
                ),
              ),
      ],
    );
  }
}

class _AdminActionCard extends StatelessWidget {
  const _AdminActionCard({
    required this.width,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final double width;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: color.withValues(alpha: 0.2)),
            ),
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(height: 18),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF6E625B),
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductEditorSheet extends StatefulWidget {
  const _ProductEditorSheet({
    required this.categories,
    required this.onSubmit,
  });

  final List<String> categories;
  final Future<ShopProduct> Function(CreateShopProductInput input) onSubmit;

  @override
  State<_ProductEditorSheet> createState() => _ProductEditorSheetState();
}

class _ProductEditorSheetState extends State<_ProductEditorSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _categoryController;
  late final TextEditingController _shortDescriptionController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _imageUrlController;
  late final TextEditingController _badgeController;
  late final TextEditingController _stockController;
  late final TextEditingController _tagsController;
  bool _featured = false;
  bool _isSubmitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final category = widget.categories.isEmpty ? 'Tarot' : widget.categories[0];
    _nameController = TextEditingController();
    _categoryController = TextEditingController(text: category);
    _shortDescriptionController = TextEditingController();
    _descriptionController = TextEditingController();
    _priceController = TextEditingController();
    _imageUrlController = TextEditingController();
    _badgeController = TextEditingController(text: 'Nuevo');
    _stockController = TextEditingController(text: 'Disponible');
    _tagsController = TextEditingController(text: 'nuevo, tienda');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _shortDescriptionController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    _badgeController.dispose();
    _stockController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _ShopSheetShell(
      title: 'Nuevo producto',
      subtitle:
          'Crea una ficha inicial para que aparezca al instante en el catálogo.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Nombre',
              hintText: 'Ej. Tarot Lunar Vision',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _categoryController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Categoría',
              hintText: 'Tarot, Velas, Cuadros',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _priceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Precio USD',
              hintText: '39.00',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _shortDescriptionController,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Descripción corta',
              hintText: 'Una línea para la tarjeta del catálogo',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descriptionController,
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Descripción completa',
              hintText: 'Detalles del producto, intención o uso',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _imageUrlController,
            keyboardType: TextInputType.url,
            decoration: const InputDecoration(
              labelText: 'Foto del producto',
              hintText: 'https://.../producto.jpg',
              helperText: 'Usa imagen vertical, nítida y bien iluminada.',
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _badgeController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Badge',
                    hintText: 'Nuevo',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _stockController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Stock',
                    hintText: 'Disponible',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _tagsController,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Tags',
              hintText: 'Separados por coma',
            ),
          ),
          const SizedBox(height: 8),
          SwitchListTile.adaptive(
            value: _featured,
            onChanged: (value) {
              setState(() {
                _featured = value;
              });
            },
            contentPadding: EdgeInsets.zero,
            title: const Text('Marcar como destacado'),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(
              _error!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF9B3B2F),
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _isSubmitting ? null : _submit,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.add_box_outlined),
              label: Text(
                _isSubmitting ? 'Guardando...' : 'Crear producto',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final category = _categoryController.text.trim();
    final shortDescription = _shortDescriptionController.text.trim();
    final description = _descriptionController.text.trim();
    final price = double.tryParse(_priceController.text.trim());
    final imageUrl = _imageUrlController.text.trim();
    final badge = _badgeController.text.trim();
    final stockLabel = _stockController.text.trim();
    final tags = _tagsController.text
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();

    if (name.length < 3 || category.length < 3 || price == null || price <= 0) {
      setState(() {
        _error = 'Completa nombre, categoría y precio válido.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    try {
      final product = await widget.onSubmit(
        CreateShopProductInput(
          name: name,
          category: category,
          shortDescription: shortDescription.isEmpty
              ? 'Producto agregado desde administración.'
              : shortDescription,
          description: description.isEmpty ? shortDescription : description,
          priceAmount: price,
          imageUrl: imageUrl,
          badge: badge.isEmpty ? 'Nuevo' : badge,
          stockLabel: stockLabel.isEmpty ? 'Disponible' : stockLabel,
          featured: _featured,
          tags: tags.isEmpty ? ['nuevo'] : tags,
        ),
      );
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(product);
    } catch (error) {
      setState(() {
        _error = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}

class _StockManagerSheet extends StatefulWidget {
  const _StockManagerSheet({
    required this.products,
    required this.onUpdateStock,
  });

  final List<ShopProduct> products;
  final Future<ShopProduct> Function(ShopProduct product, String stockLabel)
      onUpdateStock;

  @override
  State<_StockManagerSheet> createState() => _StockManagerSheetState();
}

class _StockManagerSheetState extends State<_StockManagerSheet> {
  static const _options = [
    'Disponible',
    'Pocas unidades',
    'Nueva llegada',
    'Hecho a pedido',
  ];

  late final Map<String, String> _stockByProductId;
  final Set<String> _updatingIds = <String>{};
  String? _error;

  @override
  void initState() {
    super.initState();
    _stockByProductId = {
      for (final product in widget.products) product.id: product.stockLabel,
    };
  }

  @override
  Widget build(BuildContext context) {
    return _ShopSheetShell(
      title: 'Editar stock',
      subtitle: 'Actualiza etiquetas operativas para ordenar mejor la tienda.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_error != null) ...[
            Text(
              _error!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF9B3B2F),
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 12),
          ],
          ...widget.products.map(
            (product) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _StockEditorRow(
                product: product,
                selectedLabel:
                    _stockByProductId[product.id] ?? product.stockLabel,
                updating: _updatingIds.contains(product.id),
                options: _options,
                onSelected: (label) => _update(product, label),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _update(ShopProduct product, String stockLabel) async {
    if (_updatingIds.contains(product.id)) {
      return;
    }

    setState(() {
      _updatingIds.add(product.id);
      _error = null;
    });

    try {
      final updated = await widget.onUpdateStock(product, stockLabel);
      if (!mounted) {
        return;
      }
      setState(() {
        _stockByProductId[product.id] = updated.stockLabel;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _updatingIds.remove(product.id);
        });
      }
    }
  }
}

class _StockEditorRow extends StatelessWidget {
  const _StockEditorRow({
    required this.product,
    required this.selectedLabel,
    required this.updating,
    required this.options,
    required this.onSelected,
  });

  final ShopProduct product;
  final String selectedLabel;
  final bool updating;
  final List<String> options;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE7DED3)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ),
              if (updating)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options.map((option) {
              return ChoiceChip(
                label: Text(option),
                selected: selectedLabel == option,
                onSelected: updating ? null : (_) => onSelected(option),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _FeaturedManagerSheet extends StatefulWidget {
  const _FeaturedManagerSheet({
    required this.products,
    required this.onUpdateFeatured,
  });

  final List<ShopProduct> products;
  final Future<ShopProduct> Function(ShopProduct product, bool featured)
      onUpdateFeatured;

  @override
  State<_FeaturedManagerSheet> createState() => _FeaturedManagerSheetState();
}

class _FeaturedManagerSheetState extends State<_FeaturedManagerSheet> {
  late final Map<String, bool> _featuredByProductId;
  final Set<String> _updatingIds = <String>{};
  String? _error;

  @override
  void initState() {
    super.initState();
    _featuredByProductId = {
      for (final product in widget.products) product.id: product.featured,
    };
  }

  @override
  Widget build(BuildContext context) {
    return _ShopSheetShell(
      title: 'Destacados',
      subtitle:
          'Controla qué productos aparecen en la vitrina principal de Shop.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_error != null) ...[
            Text(
              _error!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF9B3B2F),
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 12),
          ],
          ...widget.products.map(
            (product) {
              final updating = _updatingIds.contains(product.id);
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SwitchListTile.adaptive(
                  value: _featuredByProductId[product.id] ?? product.featured,
                  onChanged:
                      updating ? null : (value) => _update(product, value),
                  title: Text(
                    product.name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  subtitle: Text('${product.category} · ${product.stockLabel}'),
                  secondary: updating
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.auto_awesome_rounded),
                  tileColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: const BorderSide(color: Color(0xFFE7DED3)),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _update(ShopProduct product, bool featured) async {
    if (_updatingIds.contains(product.id)) {
      return;
    }

    setState(() {
      _updatingIds.add(product.id);
      _error = null;
    });

    try {
      final updated = await widget.onUpdateFeatured(product, featured);
      if (!mounted) {
        return;
      }
      setState(() {
        _featuredByProductId[product.id] = updated.featured;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _updatingIds.remove(product.id);
        });
      }
    }
  }
}

class _AdminOrderRow extends StatelessWidget {
  const _AdminOrderRow({
    required this.order,
    required this.onUpdateStatus,
  });

  final ShopOrder order;
  final Future<void> Function(String status) onUpdateStatus;

  @override
  Widget build(BuildContext context) {
    final status = _statusCopy(order.status);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE7DED3)),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: status.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(Icons.receipt_long_rounded, color: status.color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.orderCode,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${order.itemCount} artículos · ${formatMoney(order.total)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF6E625B),
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: onUpdateStatus,
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'pending', child: Text('Pendiente')),
              PopupMenuItem(value: 'confirmed', child: Text('Confirmada')),
              PopupMenuItem(value: 'preparing', child: Text('Preparando')),
              PopupMenuItem(value: 'shipped', child: Text('Enviada')),
            ],
            child: _MiniPill(
              label: status.label,
              color: status.color,
            ),
          ),
        ],
      ),
    );
  }
}

class _ShopSheetShell extends StatelessWidget {
  const _ShopSheetShell({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFFFCF8),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 18,
            bottom: 20 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 54,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD8CFC4),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF5E676E),
                        height: 1.45,
                      ),
                ),
                const SizedBox(height: 18),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InventoryRow extends StatelessWidget {
  const _InventoryRow({
    required this.product,
  });

  final ShopProduct product;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE7DED3)),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          SizedBox(
            width: 58,
            height: 66,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: _ProductArtwork(product: product),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${product.category} · ${product.stockLabel}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _stockColor(product.stockLabel),
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            formatMoney(product.price),
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
        ],
      ),
    );
  }
}

class _MiniPill extends StatelessWidget {
  const _MiniPill({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 128),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF5E676E),
                height: 1.45,
              ),
        ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = selected ? const Color(0xFF5C3B52) : const Color(0xFF8A7669);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? accent.withValues(alpha: 0.12) : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? accent.withValues(alpha: 0.28)
                : const Color(0xFFE7DED3),
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: accent,
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
    );
  }
}

class _FeaturedProductCard extends StatelessWidget {
  const _FeaturedProductCard({
    required this.product,
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
  });

  final ShopProduct product;
  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE7DED3)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF946244).withValues(alpha: 0.08),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(28)),
              child: _ProductArtwork(product: product),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _BadgeRow(
                  badge: product.badge,
                  stockLabel: product.stockLabel,
                ),
                const SizedBox(height: 8),
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  product.shortDescription,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF5E676E),
                        height: 1.35,
                      ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      formatMoney(product.price),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1E1A1A),
                          ),
                    ),
                    const Spacer(),
                    _QuantityControl(
                      quantity: quantity,
                      onAdd: onAdd,
                      onRemove: onRemove,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgeRow extends StatelessWidget {
  const _BadgeRow({
    required this.badge,
    required this.stockLabel,
  });

  final String badge;
  final String stockLabel;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF6EFE8),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            badge,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: const Color(0xFF6E5041),
                  fontWeight: FontWeight.w800,
                ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFEAF3EE),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            stockLabel,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: const Color(0xFF456658),
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
      ],
    );
  }
}

class _QuantityControl extends StatelessWidget {
  const _QuantityControl({
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
  });

  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    if (quantity == 0) {
      return FilledButton.icon(
        onPressed: onAdd,
        icon: const Icon(Icons.add_shopping_cart_rounded, size: 18),
        label: const Text('Agregar'),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F2EA),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: onRemove,
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.remove_rounded),
          ),
          Text(
            '$quantity',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          IconButton(
            onPressed: onAdd,
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
    );
  }
}

class _FloatingCartBar extends StatelessWidget {
  const _FloatingCartBar({
    required this.itemCount,
    required this.total,
    required this.onTap,
  });

  final int itemCount;
  final double total;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            gradient: const LinearGradient(
              colors: [
                Color(0xFF23161B),
                Color(0xFF5C3B52),
                Color(0xFFB47658),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF5C3B52).withValues(alpha: 0.28),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Row(
            children: [
              const Icon(
                Icons.shopping_bag_outlined,
                color: Colors.white,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '$itemCount artículos en carrito',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              Text(
                _formatUsd(total),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.order,
  });

  final ShopOrder order;

  @override
  Widget build(BuildContext context) {
    final status = _statusCopy(order.status);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE7DED3)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  order.orderCode,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: status.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  status.label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: status.color,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${formatSchedule(order.createdAt)} · ${order.itemCount} artículos',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF5E676E),
                ),
          ),
          const SizedBox(height: 10),
          ...order.items.take(3).map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    '• ${item.productName} x${item.quantity}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF3B3432),
                        ),
                  ),
                ),
              ),
          const SizedBox(height: 6),
          Text(
            'Entrega: ${order.deliveryAddress}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF5E676E),
                ),
          ),
          const SizedBox(height: 10),
          _SummaryRow(
            label: 'Total',
            value: formatMoney(order.total),
            highlight: true,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final color = highlight ? const Color(0xFF1E1A1A) : const Color(0xFF5E676E);

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: color,
                  fontWeight: highlight ? FontWeight.w700 : FontWeight.w500,
                ),
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
              ),
        ),
      ],
    );
  }
}

class _CheckoutSheet extends StatefulWidget {
  const _CheckoutSheet({
    required this.lines,
    required this.suggestedAddress,
    required this.onSubmit,
  });

  final List<_CartLine> lines;
  final String suggestedAddress;
  final Future<ShopOrder> Function(String deliveryAddress, String notes)
      onSubmit;

  @override
  State<_CheckoutSheet> createState() => _CheckoutSheetState();
}

class _CheckoutSheetState extends State<_CheckoutSheet> {
  late final TextEditingController _addressController;
  late final TextEditingController _notesController;
  bool _isSubmitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _addressController = TextEditingController(text: widget.suggestedAddress);
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final subtotal = widget.lines.fold<double>(
      0,
      (sum, line) => sum + (line.product.price.amount * line.quantity),
    );
    final shipping = subtotal >= 120 ? 0.0 : 9.0;
    final total = subtotal + shipping;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFFFCF8),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 18,
            bottom: 20 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 54,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD8CFC4),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Generar orden de compra',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Confirma dirección, revisa el resumen y deja notas si quieres coordinar detalles del pedido.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF5E676E),
                        height: 1.45,
                      ),
                ),
                const SizedBox(height: 18),
                ...widget.lines.map(
                  (line) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _CheckoutLine(line: line),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _addressController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Dirección de entrega',
                    hintText: 'Distrito, ciudad, referencia',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _notesController,
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Notas para la orden',
                    hintText: 'Horario, referencia, pedido especial',
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF9B3B2F),
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
                const SizedBox(height: 18),
                _SummaryRow(label: 'Subtotal', value: _formatUsd(subtotal)),
                const SizedBox(height: 6),
                _SummaryRow(label: 'Envío', value: _formatUsd(shipping)),
                const SizedBox(height: 8),
                const Divider(height: 1),
                const SizedBox(height: 10),
                _SummaryRow(
                  label: 'Total',
                  value: _formatUsd(total),
                  highlight: true,
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _isSubmitting ? null : _submit,
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.shopping_bag_rounded),
                    label: Text(
                      _isSubmitting ? 'Generando orden...' : 'Confirmar orden',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final deliveryAddress = _addressController.text.trim();
    if (deliveryAddress.isEmpty) {
      setState(() {
        _error = 'Ingresa una dirección o referencia de entrega.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    try {
      final order = await widget.onSubmit(
        deliveryAddress,
        _notesController.text.trim(),
      );
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(order);
    } catch (error) {
      setState(() {
        _error = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}

class _CheckoutLine extends StatelessWidget {
  const _CheckoutLine({
    required this.line,
  });

  final _CartLine line;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE7DED3)),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          SizedBox(
            width: 66,
            height: 82,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: _ProductArtwork(product: line.product),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  line.product.name,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${line.quantity} x ${formatMoney(line.product.price)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF5E676E),
                      ),
                ),
              ],
            ),
          ),
          Text(
            _formatUsd(line.product.price.amount * line.quantity),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}

class _ProductArtwork extends StatelessWidget {
  const _ProductArtwork({
    required this.product,
  });

  final ShopProduct product;

  @override
  Widget build(BuildContext context) {
    if (product.imageUrl.trim().isNotEmpty) {
      return Image.network(
        product.imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _FallbackArtwork(product: product),
      );
    }

    return _FallbackArtwork(product: product);
  }
}

class _FallbackArtwork extends StatelessWidget {
  const _FallbackArtwork({
    required this.product,
  });

  final ShopProduct product;

  @override
  Widget build(BuildContext context) {
    final style = _artworkStyle(product.artwork);

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: style.colors,
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: -18,
            right: -12,
            child: Icon(
              style.icon,
              size: 84,
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.16),
                ),
              ),
              child: Row(
                children: [
                  Icon(style.icon, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      product.category,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE7DED3)),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF5E676E),
                  height: 1.45,
                ),
          ),
        ],
      ),
    );
  }
}

class _CartLine {
  const _CartLine({
    required this.product,
    required this.quantity,
  });

  final ShopProduct product;
  final int quantity;
}

class _PipelineStage {
  const _PipelineStage(this.label, this.status, this.color);

  final String label;
  final String status;
  final Color color;
}

class _OrderStatusCopy {
  const _OrderStatusCopy({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;
}

class _ArtworkStyle {
  const _ArtworkStyle({
    required this.icon,
    required this.colors,
  });

  final IconData icon;
  final List<Color> colors;
}

String _sectionLabel(_ShopSection section) {
  switch (section) {
    case _ShopSection.home:
      return 'Inicio';
    case _ShopSection.catalog:
      return 'Catálogo';
    case _ShopSection.orders:
      return 'Órdenes';
    case _ShopSection.admin:
      return 'Admin';
  }
}

IconData _sectionIcon(_ShopSection section) {
  switch (section) {
    case _ShopSection.home:
      return Icons.storefront_rounded;
    case _ShopSection.catalog:
      return Icons.grid_view_rounded;
    case _ShopSection.orders:
      return Icons.receipt_long_rounded;
    case _ShopSection.admin:
      return Icons.admin_panel_settings_outlined;
  }
}

IconData _categoryIcon(String category) {
  switch (category) {
    case 'Velas':
      return Icons.local_fire_department_rounded;
    case 'Cuadros':
      return Icons.track_changes_rounded;
    case 'Estatuas':
      return Icons.self_improvement_rounded;
    case 'Símbolos':
      return Icons.auto_awesome_rounded;
    case 'Tarot':
      return Icons.style_rounded;
    default:
      return Icons.category_rounded;
  }
}

bool _isLowStockProduct(ShopProduct product) {
  final stock = product.stockLabel.toLowerCase();
  return stock.contains('pocas') ||
      stock.contains('bajo') ||
      stock.contains('últimas');
}

bool _isCustomizableProduct(ShopProduct product) {
  final badge = product.badge.toLowerCase();
  final stock = product.stockLabel.toLowerCase();
  final tags = product.tags.join(' ').toLowerCase();

  return badge.contains('personal') ||
      stock.contains('pedido') ||
      tags.contains('carta natal') ||
      tags.contains('foil');
}

Color _stockColor(String stockLabel) {
  final stock = stockLabel.toLowerCase();
  if (stock.contains('pocas') ||
      stock.contains('bajo') ||
      stock.contains('últimas')) {
    return const Color(0xFF8C4C43);
  }
  if (stock.contains('pedido')) {
    return const Color(0xFF8C6239);
  }
  if (stock.contains('nueva')) {
    return const Color(0xFF5C3B52);
  }
  return const Color(0xFF456658);
}

_OrderStatusCopy _statusCopy(String status) {
  switch (status) {
    case 'confirmed':
      return const _OrderStatusCopy(
        label: 'Confirmada',
        color: Color(0xFF4F7B67),
      );
    case 'preparing':
      return const _OrderStatusCopy(
        label: 'Preparando',
        color: Color(0xFF8C6239),
      );
    case 'shipped':
      return const _OrderStatusCopy(
        label: 'Enviada',
        color: Color(0xFF3E6381),
      );
    default:
      return const _OrderStatusCopy(
        label: 'Pendiente',
        color: Color(0xFF8C4C43),
      );
  }
}

_ArtworkStyle _artworkStyle(String artwork) {
  switch (artwork) {
    case 'candle-moon':
    case 'candle-obsidian':
      return const _ArtworkStyle(
        icon: Icons.local_fire_department_rounded,
        colors: [
          Color(0xFF2D1A1A),
          Color(0xFF6A3A2A),
          Color(0xFFD1914D),
        ],
      );
    case 'natal-gold':
    case 'natal-night':
      return const _ArtworkStyle(
        icon: Icons.track_changes_rounded,
        colors: [
          Color(0xFF182133),
          Color(0xFF335069),
          Color(0xFFD3A969),
        ],
      );
    case 'statue-moon':
    case 'statue-buddha':
      return const _ArtworkStyle(
        icon: Icons.self_improvement_rounded,
        colors: [
          Color(0xFF1C2422),
          Color(0xFF49645D),
          Color(0xFFC9A372),
        ],
      );
    case 'symbol-flower':
    case 'symbol-pentacle':
      return const _ArtworkStyle(
        icon: Icons.auto_awesome_rounded,
        colors: [
          Color(0xFF231823),
          Color(0xFF5D4363),
          Color(0xFFD1A56E),
        ],
      );
    default:
      return const _ArtworkStyle(
        icon: Icons.style_rounded,
        colors: [
          Color(0xFF1F1820),
          Color(0xFF5F3B4E),
          Color(0xFFC99E6A),
        ],
      );
  }
}

String _formatUsd(double amount) {
  return formatMoney(
    Money(
      amount: amount,
      currency: 'USD',
    ),
  );
}
