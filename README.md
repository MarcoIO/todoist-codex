# Todoist Codex

Aplicación de lista de tareas desarrollada en SwiftUI siguiendo arquitectura MVVM en capas (data, domain, presentation) y compatible con Xcode 14.

## Características

- Persistencia local con Core Data sin dependencias de terceros.
- Flujo de lista y detalle de tareas con icono, título, descripción, fecha y estado.
- Internacionalización en español e inglés con selector desde la interfaz.
- Iconografía basada en SF Symbols (gratuitas) y catálogo de assets incluido.
- Inyección de dependencias mediante un contenedor central en la capa de presentación.

## Arquitectura

```
src/
  data/        // Core Data stack, datasources y repositorios concretos
  domain/      // Modelos de dominio, contratos y casos de uso
  presentation// Views, ViewModels y navegación SwiftUI
```

Las capas mantienen la dirección de dependencias `presentation -> domain -> data`. El contenedor `AppDependencyContainer` crea los objetos necesarios y los expone a las vistas SwiftUI.

## Requisitos

- Xcode 14 con soporte para iOS 15 o superior.
- Swift 5.7.

## Ejecución

1. Abrir `TodoistCodex.xcodeproj` en Xcode 14.
2. Seleccionar el esquema **TodoistCodex**.
3. Ejecutar en un simulador o dispositivo con iOS 15+.

La aplicación carga las tareas desde Core Data. Si no hay datos, muestra un estado vacío con acceso directo para crear nuevas tareas.

## Tests

El target **TodoistCodexTests** incluye pruebas unitarias para dominio, datos y presentación:

- `CreateTaskUseCaseTests` valida reglas de negocio y creación de tareas.
- `TaskRepositoryImplementationTests` ejercita la persistencia Core Data en memoria.
- `TaskListViewModelTests` verifica el comportamiento del ViewModel principal.

Ejecuta las pruebas desde Xcode (Product > Test) con el esquema **TodoistCodexTests**.

## Localización

El idioma se controla mediante el `LanguageSelectionViewModel`. El menú de la barra de navegación permite alternar entre español e inglés en tiempo real.

## Iconografía

Los iconos de tareas utilizan SF Symbols, garantizando un recurso gratuito y disponible en todas las plataformas Apple.
