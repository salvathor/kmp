Este es un proyecto Kotlin Multiplatform (KMP) con apps para Android e iOS.

La app es una lista de tareas sencilla: permite agregar tareas y marcarlas como completadas.
La lógica de datos está escrita una sola vez en Kotlin y se comparte entre ambas plataformas.

## Estructura del proyecto

* [/sharedLogic](./sharedLogic/src) contiene la lógica compartida entre Android e iOS.
  La carpeta más importante es [commonMain](./sharedLogic/src/commonMain/kotlin), donde está
  [Tarea.kt](./sharedLogic/src/commonMain/kotlin/com/example/my_application/Tarea.kt):
  - `Tarea`: modelo con `id`, `titulo` y `completada`.
  - `TareasRepositorio`: interfaz con `obtenerTodas()`, `agregar(titulo)` y `alternarCompletada(id)`.
  - `TareasEnMemoria`: implementación que guarda las tareas en memoria (se pierden al cerrar la app).

  Las carpetas [androidMain](./sharedLogic/src/androidMain/kotlin) e [iosMain](./sharedLogic/src/iosMain/kotlin)
  son para código específico de cada plataforma.

* [/iosApp](./iosApp/iosApp) contiene la app de iOS, hecha en SwiftUI.
  - [iOSApp.swift](./iosApp/iosApp/iOSApp.swift) es el punto de entrada y muestra `TareasView`.
  - [TareasView.swift](./iosApp/iosApp/TareasView.swift) es la pantalla de tareas; usa `TareasEnMemoria`
    desde el framework `SharedLogic`.

* [/sharedUI](./sharedUI/src) contiene la interfaz en Compose Multiplatform. Por ahora solo tiene target
  Android y el código está en [commonMain](./sharedUI/src/commonMain/kotlin). La app de iOS no lo usa.

* [/androidApp](./androidApp/src) contiene la app de Android, que muestra la UI de `sharedUI`.
  Por ahora es la pantalla de ejemplo de la plantilla y todavía no muestra las tareas.

## Cómo usa iOS la lógica compartida

El módulo `sharedLogic` se compila como un framework estático llamado `SharedLogic`
(`baseName = "SharedLogic"` en [sharedLogic/build.gradle.kts](./sharedLogic/build.gradle.kts)).
El target de iOS tiene una fase "Run Script" que ejecuta:

```
./gradlew :sharedLogic:embedAndSignAppleFrameworkForXcode
```

Por eso, al compilar en Xcode, cualquier cambio en el código Kotlin se recompila y queda disponible en
Swift con `import SharedLogic`.

## Cómo ejecutar las apps

Usa las configuraciones de ejecución de la barra de herramientas de tu IDE, o estos comandos y opciones:

- App de Android: `./gradlew :androidApp:assembleDebug`
- App de iOS: abre la carpeta [/iosApp](./iosApp) en Xcode y ejecútala desde ahí.

---

Más información sobre [Kotlin Multiplatform](https://www.jetbrains.com/help/kotlin-multiplatform-dev/get-started.html).
