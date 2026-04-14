# iPhone fisico

Para reinstalar y abrir la app en el iPhone sin caer otra vez en pantalla blanca o app que se cierra:

```bash
npm run dev:api
npm run mobile:ios:device
```

## Por que este flujo

- En iPhone fisico no sirve `127.0.0.1`; el telefono necesita la IP LAN de la Mac.
- Un build `debug` de Flutter en iPhone puede abrir solo mientras esta colgado de Flutter tooling. Si lo instalas y luego lo abres como app normal, puede cerrarse o no lanzar.
- Por eso el script fuerza `release` en dispositivo fisico y pasa `API_BASE_URL` automaticamente.

## Problemas que ya quedaron cubiertos en codigo

- Se fijo `path_provider_foundation` en `2.5.1` porque la rama nueva metia `objective_c.framework` y genero problemas de firma en iOS.
- Se corrigio la inicializacion de Flutter para evitar `zone mismatch`.
- Se corrigieron layouts y componentes interactivos que estaban rompiendo la pantalla inicial.

## Limite que sigue siendo de iOS

Si iOS bloquea una build nueva por confianza del certificado, eso no se resuelve con codigo.
Debes confiar una sola vez en el desarrollador desde:

`Configuracion > General > VPN y gestion de dispositivos > Developer App`

Despues de eso, el flujo de arriba es el que debes repetir cuando cambie la app.
