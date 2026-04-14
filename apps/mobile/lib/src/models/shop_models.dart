class CreateShopOrderInput {
  CreateShopOrderInput({
    required this.items,
    required this.deliveryAddress,
    required this.notes,
  });

  final List<CreateShopOrderItemInput> items;
  final String deliveryAddress;
  final String notes;

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      'deliveryAddress': deliveryAddress,
      'notes': notes,
    };
  }
}

class CreateShopOrderItemInput {
  CreateShopOrderItemInput({
    required this.productId,
    required this.quantity,
  });

  final String productId;
  final int quantity;

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'quantity': quantity,
    };
  }
}

class CreateShopProductInput {
  CreateShopProductInput({
    required this.name,
    required this.category,
    required this.shortDescription,
    required this.description,
    required this.priceAmount,
    required this.imageUrl,
    required this.badge,
    required this.stockLabel,
    required this.featured,
    required this.tags,
  });

  final String name;
  final String category;
  final String shortDescription;
  final String description;
  final double priceAmount;
  final String imageUrl;
  final String badge;
  final String stockLabel;
  final bool featured;
  final List<String> tags;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category,
      'shortDescription': shortDescription,
      'description': description,
      'imageUrl': imageUrl,
      'price': {
        'amount': priceAmount,
        'currency': 'USD',
      },
      'badge': badge,
      'stockLabel': stockLabel,
      'featured': featured,
      'tags': tags,
    };
  }
}

class UpdateShopProductInput {
  UpdateShopProductInput({
    this.name,
    this.category,
    this.shortDescription,
    this.description,
    this.priceAmount,
    this.imageUrl,
    this.badge,
    this.stockLabel,
    this.featured,
    this.tags,
  });

  final String? name;
  final String? category;
  final String? shortDescription;
  final String? description;
  final double? priceAmount;
  final String? imageUrl;
  final String? badge;
  final String? stockLabel;
  final bool? featured;
  final List<String>? tags;

  Map<String, dynamic> toJson() {
    return {
      if (name != null) 'name': name,
      if (category != null) 'category': category,
      if (shortDescription != null) 'shortDescription': shortDescription,
      if (description != null) 'description': description,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (priceAmount != null)
        'price': {
          'amount': priceAmount,
          'currency': 'USD',
        },
      if (badge != null) 'badge': badge,
      if (stockLabel != null) 'stockLabel': stockLabel,
      if (featured != null) 'featured': featured,
      if (tags != null) 'tags': tags,
    };
  }
}

class UpdateShopOrderStatusInput {
  UpdateShopOrderStatusInput({
    required this.status,
  });

  final String status;

  Map<String, dynamic> toJson() {
    return {
      'status': status,
    };
  }
}
