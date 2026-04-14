# Astro Engine V1

Motor astrologico propio para `Lo Renaciente`.

## Estado actual

- calculo de Sol, Luna, Ascendente y Medio Cielo
- posiciones geocentricas de planetas principales
- casas en sistema `whole sign` y `equal`
- aspectos mayores
- resumen e interpretacion base
- transitos personales contra la carta natal
- proxima revolucion solar
- proxima revolucion lunar
- sinastria base entre dos cartas
- eventos proximos: fases lunares, eclipses solares globales, eclipses lunares y proximo eclipse solar local

## Endpoint carta natal

`POST /api/astro/natal`

### Body

```json
{
  "birthDate": "1992-10-13",
  "birthTime": "08:45",
  "utcOffset": "-03:00",
  "latitude": -34.9011,
  "longitude": -56.1645,
  "locationLabel": "Montevideo, Uruguay",
  "houseSystem": "equal"
}
```

### Respuesta principal

- `bigThree`
- `angles`
- `planets`
- `houses`
- `aspects`
- `summary`
- `interpretation`

## Endpoint eventos

`GET /api/astro/events`

### Query params

- `from`: fecha ISO opcional
- `latitude`: opcional
- `longitude`: opcional

Ejemplo:

```text
/api/astro/events?from=2026-03-21T00:00:00Z&latitude=-34.9011&longitude=-56.1645
```

## Endpoint transitos

`POST /api/astro/transits`

### Body base

```json
{
  "birthDate": "1992-10-13",
  "birthTime": "08:45",
  "utcOffset": "-03:00",
  "latitude": -34.9011,
  "longitude": -56.1645,
  "locationLabel": "Montevideo, Uruguay",
  "houseSystem": "equal",
  "targetDate": "2026-03-22T12:00:00Z"
}
```

### Respuesta principal

- `transits`
- `aspectsToNatal`
- `highlights`

## Endpoint revoluciones

`POST /api/astro/returns`

### Respuesta principal

- `solarReturn`
- `lunarReturn`

## Endpoint sinastria

`POST /api/astro/synastry`

### Respuesta principal

- `left`
- `right`
- `crossAspects`
- `highlights`

## Limitaciones actuales

- no hay `Placidus`, `Koch` ni otros sistemas avanzados
- el motor requiere `utcOffset`, no resuelve automaticamente huso historico
- no hay geocodificacion todavia
- no hay progresiones secundarias
- no hay arco solar
- no hay direcciones primarias ni simbolicas
- no hay carta compuesta
- no hay partes arabigas, puntos medios, draconica, heliocentrica ni armonicos
- no esta conectado aun al perfil del usuario en la app

## Siguiente fase recomendada

- guardar `latitud`, `longitud` y `utcOffset` en el perfil natal
- conectar la app movil a estos endpoints
- agregar progresiones, arco solar y carta compuesta
- agregar lunaciones, retrogradaciones y panel de opciones de aspectos/orbes
- agregar geocodificacion controlada para ciudades
