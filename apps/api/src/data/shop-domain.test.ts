import assert from "node:assert/strict";
import test from "node:test";

import {
  buildShopOrderDraft,
  filterShopOrdersForScope,
  filterShopProductsForScope,
  normalizeShopProductOwnership,
  type ShopViewerScope,
} from "./shop-domain.js";
import type { ShopOrder, ShopProduct } from "./mock-store.js";

function buildProduct(
  id: string,
  specialistId: string,
  specialistName: string,
  overrides: Partial<ShopProduct> = {},
): ShopProduct {
  return normalizeShopProductOwnership(
    {
      id,
      name: `Producto ${id}`,
      category: "Tarot",
      specialistId,
      specialistName,
      storeId: "",
      storeName: "",
      shortDescription: "Producto de prueba",
      description: "Producto de prueba para shop",
      price: {
        amount: 40,
        currency: "USD",
      },
      imageUrl: "",
      artwork: "tarot",
      badge: "Nuevo",
      featured: false,
      stockLabel: "Disponible",
      stockQuantity: 8,
      madeToOrder: false,
      tags: ["test"],
      ...overrides,
    },
    specialistId,
    specialistName,
  );
}

function buildOrder(
  id: string,
  userId: string,
  specialistId: string,
  specialistName: string,
): ShopOrder {
  const product = buildProduct(`product-${id}`, specialistId, specialistName);

  return {
    id,
    userId,
    orderCode: `LR-2026-${id}`,
    status: "pending",
    createdAt: "2026-04-18T10:00:00.000Z",
    specialistId: product.specialistId,
    specialistName: product.specialistName,
    storeId: product.storeId,
    storeName: product.storeName,
    deliveryAddress: "Lima",
    notes: "",
    subtotal: {
      amount: 40,
      currency: "USD",
    },
    shipping: {
      amount: 9,
      currency: "USD",
    },
    total: {
      amount: 49,
      currency: "USD",
    },
    itemCount: 1,
    items: [
      {
        productId: product.id,
        productName: product.name,
        category: product.category,
        quantity: 1,
        imageUrl: product.imageUrl,
        unitPrice: product.price,
        lineTotal: product.price,
      },
    ],
  };
}

test("filterShopProductsForScope segments catalog by specialist and admin", () => {
  const amaya = buildProduct("amaya-deck", "spec-amaya", "Amaya Rivas");
  const mila = buildProduct("mila-candle", "spec-mila", "Mila Sol");
  const products = [amaya, mila];

  const specialistScope: ShopViewerScope = {
    userId: "user-spec",
    accountType: "specialist",
    specialistProfileId: "spec-amaya",
    isAdmin: false,
  };
  const adminScope: ShopViewerScope = {
    userId: "user-admin",
    accountType: "specialist",
    specialistProfileId: "spec-amaya",
    isAdmin: true,
  };
  const clientScope: ShopViewerScope = {
    userId: "user-client",
    accountType: "client",
    isAdmin: false,
  };

  assert.deepEqual(
    filterShopProductsForScope(products, specialistScope).map((product) => product.id),
    ["amaya-deck"],
  );
  assert.deepEqual(
    filterShopProductsForScope(products, adminScope).map((product) => product.id),
    ["amaya-deck", "mila-candle"],
  );
  assert.deepEqual(
    filterShopProductsForScope(products, clientScope).map((product) => product.id),
    ["amaya-deck", "mila-candle"],
  );
});

test("filterShopOrdersForScope keeps mother user global and specialist scoped", () => {
  const orders = [
    buildOrder("001", "user-client-a", "spec-amaya", "Amaya Rivas"),
    buildOrder("002", "user-client-b", "spec-mila", "Mila Sol"),
    buildOrder("003", "user-client-a", "spec-amaya", "Amaya Rivas"),
  ];

  const adminScope: ShopViewerScope = {
    userId: "user-admin",
    accountType: "client",
    isAdmin: true,
  };
  const specialistScope: ShopViewerScope = {
    userId: "user-spec",
    accountType: "specialist",
    specialistProfileId: "spec-amaya",
    isAdmin: false,
  };
  const clientScope: ShopViewerScope = {
    userId: "user-client-a",
    accountType: "client",
    isAdmin: false,
  };

  assert.equal(filterShopOrdersForScope(orders, adminScope).length, 3);
  assert.deepEqual(
    filterShopOrdersForScope(orders, specialistScope).map((order) => order.id),
    ["001", "003"],
  );
  assert.deepEqual(
    filterShopOrdersForScope(orders, clientScope).map((order) => order.id),
    ["001", "003"],
  );
});

test("buildShopOrderDraft associates the order to one store and decrements stock", () => {
  const deck = buildProduct("deck", "spec-amaya", "Amaya Rivas", {
    name: "Tarot lunar",
    stockQuantity: 5,
  });
  const candle = buildProduct("candle", "spec-amaya", "Amaya Rivas", {
    name: "Vela portal",
    stockQuantity: 4,
  });

  const result = buildShopOrderDraft({
    input: {
      deliveryAddress: "Miraflores",
      notes: "Entregar por la tarde",
      items: [
        { productId: deck.id, quantity: 2 },
        { productId: candle.id, quantity: 1 },
      ],
    },
    products: [deck, candle],
    viewer: {
      userId: "user-client",
      accountType: "client",
      isAdmin: false,
    },
    orderId: "order-001",
    orderCode: "LR-2026-101",
    createdAt: "2026-04-18T12:00:00.000Z",
    deliveryAddressFallback: "Lima",
  });

  assert.equal(result.order.specialistId, "spec-amaya");
  assert.equal(result.order.storeId, "store-spec-amaya");
  assert.equal(result.order.itemCount, 3);
  assert.equal(result.order.subtotal.amount, 120);
  assert.equal(result.order.shipping.amount, 0);
  assert.equal(result.order.total.amount, 120);

  const updatedDeck = result.updatedProducts.find((product) => product.id == deck.id);
  const updatedCandle = result.updatedProducts.find(
    (product) => product.id == candle.id,
  );
  assert.equal(updatedDeck?.stockQuantity, 3);
  assert.equal(updatedDeck?.stockLabel, "Pocas unidades");
  assert.equal(updatedCandle?.stockQuantity, 3);
});

test("buildShopOrderDraft rejects mixed specialist stores in one order", () => {
  const amaya = buildProduct("deck", "spec-amaya", "Amaya Rivas");
  const mila = buildProduct("candle", "spec-mila", "Mila Sol");

  assert.throws(
    () =>
      buildShopOrderDraft({
        input: {
          deliveryAddress: "Lima",
          notes: "",
          items: [
            { productId: amaya.id, quantity: 1 },
            { productId: mila.id, quantity: 1 },
          ],
        },
        products: [amaya, mila],
        viewer: {
          userId: "user-client",
          accountType: "client",
          isAdmin: false,
        },
        orderId: "order-002",
        orderCode: "LR-2026-102",
        createdAt: "2026-04-18T12:00:00.000Z",
        deliveryAddressFallback: "Lima",
      }),
    /una sola tienda especialista/,
  );
});

test("buildShopOrderDraft rejects insufficient stock and preserves made-to-order inventory", () => {
  const inStock = buildProduct("rare-deck", "spec-amaya", "Amaya Rivas", {
    name: "Rare deck",
    stockQuantity: 1,
  });
  const custom = buildProduct("custom-art", "spec-amaya", "Amaya Rivas", {
    name: "Cuadro astral",
    stockQuantity: 0,
    madeToOrder: true,
  });

  assert.throws(
    () =>
      buildShopOrderDraft({
        input: {
          deliveryAddress: "Barranco",
          notes: "",
          items: [{ productId: inStock.id, quantity: 2 }],
        },
        products: [inStock],
        viewer: {
          userId: "user-client",
          accountType: "client",
          isAdmin: false,
        },
        orderId: "order-003",
        orderCode: "LR-2026-103",
        createdAt: "2026-04-18T12:00:00.000Z",
        deliveryAddressFallback: "Lima",
      }),
    /No hay stock suficiente/,
  );

  const result = buildShopOrderDraft({
    input: {
      deliveryAddress: "",
      notes: "",
      items: [{ productId: custom.id, quantity: 2 }],
    },
    products: [custom],
    viewer: {
      userId: "user-client",
      accountType: "client",
      isAdmin: false,
    },
    orderId: "order-004",
    orderCode: "LR-2026-104",
    createdAt: "2026-04-18T12:00:00.000Z",
    deliveryAddressFallback: "Cusco",
  });

  assert.equal(result.order.deliveryAddress, "Cusco");
  assert.equal(result.updatedProducts[0]?.stockQuantity, 0);
  assert.equal(result.updatedProducts[0]?.madeToOrder, true);
});
