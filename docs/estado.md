# Gestión de estado — EcoTrack Meta

**Equipo:** Jose Leonardo Martinez Gomez · _(pareja)_  
**Fecha:** 26/10/2026  
**Biblioteca contrastada:** provider

## Problema

Tres pantallas dependen del mismo dato: **Registro** guarda un consumo, **Historial** lista los consumos con su total y **Meta** compara ese total con una meta que se sube y se baja. Si cada pantalla tuviera su propia lista, Historial y Meta no se enterarían de lo que guarda Registro. Por eso el estado tiene un solo dueño, `ConsumosViewModel`, y las pantallas se enteran cuando cambia.

## Capas (MVVM)

| Capa | Archivo | Qué conoce |
|---|---|---|
| Dominio | `lib/dominio/consumo.dart`, `lib/dominio/meta.dart` | Nada de Flutter. Reglas `validarLitros`, `ajustarMeta`, `avanceDeMeta`. |
| Datos | `lib/datos/consumo_repository.dart:8` (contrato), `lib/datos/memoria_consumo_repository.dart` | Solo el dominio. |
| ViewModel | `lib/presentacion/consumos_view_model.dart:16` | Dominio y el **contrato** `ConsumoRepository`; importa `foundation.dart`, no `material.dart`. |
| Vistas tontas | `lib/presentacion/vistas.dart` | Solo el dominio. Reciben datos y callbacks; no importan el ViewModel, ni `datos/`, ni provider. |
| Cableado | `lib/variantes/a_change_notifier.dart`, `lib/variantes/b_provider.dart` | Unen ViewModel y vistas. |
| Elección de la fuente | `lib/main.dart:16`, `lib/main_change_notifier.dart:11` | Únicos archivos que importan `MemoriaConsumoRepository`. |

## Tipos de estado (evidencia en nuestro código)

| Tipo | Dónde | Por qué es de ese tipo |
|---|---|---|
| **Efímero** (`setState`) | `vistas.dart:37` y `:70` — `_laboratorio` del formulario; `vistas.dart:217` y `:230` — `_indice` de la pestaña activa. | Solo le importa a un widget; nadie más lo lee. |
| **Compartido** (ViewModel) | `consumos_view_model.dart:24-30` — `consumos`, `error`, `guardando`, `meta`. | Lo leen las tres pantallas; vive en un solo dueño. |
| **Derivado** (getters) | `consumos_view_model.dart:33` `total`, `:35` `avance`, `:37` `metaSuperada`. | Se calcula de `consumos` y `meta`; no se guarda, así nunca queda desfasado. |
| **Persistido** (repositorio) | `memoria_consumo_repository.dart:12` — `_consumos`; `:20` devuelve `List.unmodifiable`. | Es la fuente de verdad; el ViewModel vuelve a leerla después de guardar. |

## Observer

- **Sujeto:** `ConsumosViewModel extends ChangeNotifier` (`consumos_view_model.dart:16`).
- **Avisa:** `notifyListeners()` en `cargar` (`:42`), `guardar` (`:54` error, `:61` "guardando", `:72` "listo"), `subirMeta` (`:79`) y `bajarMeta` (`:85`).
- **Escuchan (A):** `ListenableBuilder` en `a_change_notifier.dart:64`, `:83` y `:99`.
- **Escuchan (B):** `context.watch<ConsumosViewModel>()` en `b_provider.dart:47`, `:64` y `:75`.
- **Actúan sin escuchar (B):** `context.read<ConsumosViewModel>()` dentro de los callbacks en `b_provider.dart:51`, `:81` y `:82`.

## Criterios A02

| Criterio | A · ChangeNotifier | B · provider |
|---|---|---|
| Dato compartido | Un solo `_vm` (`a_change_notifier.dart:32`) pasado por constructor a `RegistroCN`, `HistorialCN` y `MetaCN` (`:48-50`). | `ChangeNotifierProvider` (`b_provider.dart:24-26`) cuelga un solo ViewModel; cada adaptador lo pide al árbol. |
| Capas | Las vistas no conocen el ViewModel; los adaptadores `*CN` hacen el puente. | Igual: las mismas vistas, adaptadores `*Provider`. El ViewModel no sabe que existe provider. |
| Sustitución | El repositorio entra por `AppChangeNotifier(repositorio:)`; se cambia en `main_change_notifier.dart:11`. | Entra por `AppProvider(repositorio:)`; se cambia en `main.dart:16`. |
| Costo | Cero dependencias, pero el `vm` se pasa a mano y hay que liberarlo en `dispose()` (`a_change_notifier.dart:38`). | Una dependencia y tres piezas (`ChangeNotifierProvider`, `watch`, `read`); provider libera el ViewModel solo. |

**Comprobación:** `test/etapa4_change_notifier_test.dart` y `test/etapa5_provider_test.dart` prueban Dato compartido, Sustitución (con `RepositorioEspia`), Capas (el error de `validarLitros` llega a la vista) y la Meta en las dos variantes. `bash verificar_estado.sh` revisa capas y cableado.

## Elección

Elegimos **provider** sobre el mismo `ConsumosViewModel`. Con tres pantallas el `vm` ya se pasa tres veces por constructor; con más pantallas o anidadas esa cadena se vuelve frágil. provider la elimina sin tocar el ViewModel, el repositorio ni las vistas: entre A y B solo cambió `lib/variantes/` y el `main`.  
Se mantiene: `ConsumosViewModel` y el contrato `ConsumoRepository`.  
Se podría sustituir después: `MemoriaConsumoRepository`, por un repositorio que persista en disco o en un servicio.
