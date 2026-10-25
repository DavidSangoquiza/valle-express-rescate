// PASO 2 de la venta distribuida: catálogo polimórfico + detalle del pedido en MongoDB
db = db.getSiblingDB("distribuidora");

// Catálogo POLIMÓRFICO: un televisor y un arroz conviven en la misma colección
const catalogo = [
  { _id: "TV-SAMS-55", tipo: "electrodomestico", nombre: "Televisor Samsung 55\" 4K", precio: 549.00,
    atributos: { pulgadas: 55, resolucion: "4K", smart_tv: true, garantia_meses: 24 } },
  { _id: "ARROZ-5KG", tipo: "abarrote", nombre: "Arroz Superior 5 kg", precio: 12.25,
    atributos: { peso_kg: 5, marca: "Gustadina", fecha_caducidad: new Date("2027-06-30") } },
  { _id: "REFRI-LG-14", tipo: "electrodomestico", nombre: "Refrigeradora LG 14 pies", precio: 789.90,
    atributos: { capacidad_pies: 14, no_frost: true, color: "inox", garantia_meses: 36 } }
];
catalogo.forEach(p => db.productos.replaceOne({ _id: p._id }, p, { upsert: true }));
db.productos.createIndex({ nombre: "text" });   // búsqueda de texto sin bloquear las ventas

// Detalle del pedido, enlazado con la factura de PostgreSQL
db.pedidos.replaceOne(
  { factura_numero: "FAC-2026-0001" },
  {
    factura_numero: "FAC-2026-0001",
    cliente: { cedula: "1712345678", nombre: "María Pérez" },
    canal: "web",
    fecha: new Date(),
    items: [
      { sku: "TV-SAMS-55", nombre: "Televisor Samsung 55\" 4K", cantidad: 1, precio: 549.00,
        atributos: { pulgadas: 55, resolucion: "4K" } },
      { sku: "ARROZ-5KG", nombre: "Arroz Superior 5 kg", cantidad: 1, precio: 12.25,
        atributos: { peso_kg: 5, marca: "Gustadina" } }
    ],
    total: 645.44,
    estado: "pagado"
  },
  { upsert: true, writeConcern: { w: "majority", wtimeout: 5000 } }
);

print("Productos en catálogo: " + db.productos.countDocuments());
printjson(db.pedidos.findOne({ factura_numero: "FAC-2026-0001" }));
