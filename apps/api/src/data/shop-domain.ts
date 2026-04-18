import type {
  CreateShopOrderInput,
  Money,
  ShopOrder,
  ShopOrderItem,
  ShopProduct,
  UserProfile,
} from "./mock-store.js";

export interface ShopViewerScope {
  userId: string;
  accountType: string;
  specialistProfileId?: string;
  isAdmin: boolean;
}

export interface ShopManagerScope extends ShopViewerScope {}

export interface BuildShopOrderDraftInput {
  input: CreateShopOrderInput;
  products: ShopProduct[];
  viewer: ShopViewerScope;
  orderId: string;
  orderCode: string;
  createdAt: string;
  deliveryAddressFallback: string;
}

export interface BuildShopOrderDraftResult {
  order: ShopOrder;
  updatedProducts: ShopProduct[];
}

export function buildShopStoreId(specialistId: string): string {
  return `store-${specialistId.trim()}`;
}

export function buildShopStoreName(specialistName: string): string {
  const trimmed = specialistName.trim();
  return trimmed.length === 0 ? "Tienda Renaciente" : `Tienda de ${trimmed}`;
}

export function buildShopStockLabel(
  stockQuantity: number,
  madeToOrder: boolean,
): string {
  if (madeToOrder) {
    return "Hecho a pedido";
  }
  if (stockQuantity <= 0) {
    return "Agotado";
  }
  if (stockQuantity <= 3) {
    return "Pocas unidades";
  }
  if (stockQuantity <= 8) {
    return "Disponible";
  }
  return "Disponible";
}

export function normalizeShopProductOwnership(
  product: ShopProduct,
  specialistId: string,
  specialistName: string,
): ShopProduct {
  const normalizedSpecialistId = specialistId.trim();
  const normalizedSpecialistName = specialistName.trim();
  const madeToOrder = Boolean(product.madeToOrder);
  const stockQuantity = madeToOrder
    ? 0
    : Math.max(0, Math.round(Number(product.stockQuantity ?? 0)));

  return {
    ...product,
    specialistId: normalizedSpecialistId,
    specialistName: normalizedSpecialistName,
    storeId: buildShopStoreId(normalizedSpecialistId),
    storeName: buildShopStoreName(normalizedSpecialistName),
    madeToOrder,
    stockQuantity,
    stockLabel: buildShopStockLabel(stockQuantity, madeToOrder),
  };
}

export function filterShopProductsForScope(
  products: ShopProduct[],
  scope: ShopViewerScope,
): ShopProduct[] {
  if (scope.isAdmin || scope.accountType !== "specialist") {
    return [...products];
  }

  const specialistProfileId = scope.specialistProfileId?.trim() ?? "";
  if (specialistProfileId.length === 0) {
    return [];
  }

  return products.filter((product) => product.specialistId === specialistProfileId);
}

export function filterShopOrdersForScope(
  orders: ShopOrder[],
  scope: ShopViewerScope,
): ShopOrder[] {
  if (scope.isAdmin) {
    return [...orders];
  }

  if (scope.accountType === "specialist") {
    const specialistProfileId = scope.specialistProfileId?.trim() ?? "";
    if (specialistProfileId.length === 0) {
      return [];
    }

    return orders.filter((order) => order.specialistId === specialistProfileId);
  }

  return orders.filter((order) => order.userId === scope.userId);
}

export function canManageShopProduct(
  product: ShopProduct,
  scope: ShopManagerScope,
): boolean {
  if (scope.isAdmin) {
    return true;
  }

  const specialistProfileId = scope.specialistProfileId?.trim() ?? "";
  return specialistProfileId.length > 0 && product.specialistId === specialistProfileId;
}

export function canManageShopOrder(
  order: ShopOrder,
  scope: ShopManagerScope,
): boolean {
  if (scope.isAdmin) {
    return true;
  }

  const specialistProfileId = scope.specialistProfileId?.trim() ?? "";
  return specialistProfileId.length > 0 && order.specialistId === specialistProfileId;
}

export function buildShopViewerScope(
  user: UserProfile,
  isAdmin: boolean,
): ShopViewerScope {
  return {
    userId: user.id,
    accountType: user.accountType,
    specialistProfileId: user.specialistProfileId,
    isAdmin,
  };
}

export function buildShopOrderDraft({
  input,
  products,
  viewer,
  orderId,
  orderCode,
  createdAt,
  deliveryAddressFallback,
}: BuildShopOrderDraftInput): BuildShopOrderDraftResult {
  const requestedItems = input.items ?? [];
  if (requestedItems.length === 0) {
    throw new Error("Agrega al menos un producto al carrito.");
  }

  const inventoryByProductId = new Map(products.map((product) => [product.id, product]));
  const touchedProducts = new Map<string, ShopProduct>();
  const items: ShopOrderItem[] = [];

  let specialistId = "";
  let specialistName = "";
  let storeId = "";
  let storeName = "";

  for (const entry of requestedItems) {
    const productId = entry.productId?.trim() ?? "";
    const quantity = Math.max(0, entry.quantity ?? 0);
    if (productId.length === 0 || quantity < 1) {
      throw new Error("El carrito contiene un producto inválido.");
    }

    const sourceProduct = touchedProducts.get(productId) ?? inventoryByProductId.get(productId);
    if (!sourceProduct) {
      throw new Error("Uno de los productos ya no está disponible.");
    }

    if (!specialistId) {
      specialistId = sourceProduct.specialistId;
      specialistName = sourceProduct.specialistName;
      storeId = sourceProduct.storeId;
      storeName = sourceProduct.storeName;
    } else if (
      sourceProduct.specialistId !== specialistId ||
      sourceProduct.storeId !== storeId
    ) {
      throw new Error(
        "Cada pedido debe agrupar productos de una sola tienda especialista.",
      );
    }

    if (!sourceProduct.madeToOrder && quantity > sourceProduct.stockQuantity) {
      throw new Error(
        `No hay stock suficiente para ${sourceProduct.name}. Disponible: ${sourceProduct.stockQuantity}.`,
      );
    }

    const nextProduct =
      sourceProduct.madeToOrder
        ? sourceProduct
        : {
            ...sourceProduct,
            stockQuantity: sourceProduct.stockQuantity - quantity,
            stockLabel: buildShopStockLabel(
              sourceProduct.stockQuantity - quantity,
              sourceProduct.madeToOrder,
            ),
          };

    touchedProducts.set(productId, nextProduct);

    items.push({
      productId: sourceProduct.id,
      productName: sourceProduct.name,
      category: sourceProduct.category,
      quantity,
      imageUrl: sourceProduct.imageUrl,
      unitPrice: cloneMoney(sourceProduct.price),
      lineTotal: {
        amount: Number((sourceProduct.price.amount * quantity).toFixed(2)),
        currency: sourceProduct.price.currency,
      },
    });
  }

  const subtotalAmount = items.reduce((sum, item) => sum + item.lineTotal.amount, 0);
  const shippingAmount = subtotalAmount >= 120 ? 0 : 9;
  const subtotal = buildMoney(subtotalAmount);
  const shipping = buildMoney(shippingAmount);
  const total = buildMoney(subtotal.amount + shipping.amount);

  const order: ShopOrder = {
    id: orderId,
    userId: viewer.userId,
    orderCode,
    status: "pending",
    createdAt,
    deliveryAddress:
      (input.deliveryAddress?.trim().length ?? 0) > 0
        ? input.deliveryAddress!.trim()
        : deliveryAddressFallback,
    notes: input.notes?.trim() ?? "",
    subtotal,
    shipping,
    total,
    itemCount: items.reduce((sum, item) => sum + item.quantity, 0),
    items,
    specialistId,
    specialistName,
    storeId,
    storeName,
  };

  return {
    order,
    updatedProducts: products.map(
      (product) => touchedProducts.get(product.id) ?? product,
    ),
  };
}

function buildMoney(amount: number): Money {
  return {
    amount: Number(amount.toFixed(2)),
    currency: "USD",
  };
}

function cloneMoney(value: Money): Money {
  return {
    amount: value.amount,
    currency: value.currency,
  };
}
