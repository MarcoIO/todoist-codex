# Arquitectura del Proyecto

Este repositorio debe seguir una arquitectura basada en MVVM con una separación estricta en tres capas principales: **data**, **domain** y **presentation**. Cada capa es responsable de un conjunto definido de tareas y depende únicamente de la capa inmediatamente inferior.

Tiene que ser compatible con iOS 14 y XCODE 14

## Estructura recomendada
```
src/
  data/
    entities/
    datasources/
    repositories/
  domain/
    models/
    repositories/
    usecases/
  presentation/
    viewmodels/
    views/
    navigation/
```

## Capa `data`
- Contiene las **entities** utilizadas para la persistencia, comunicación con APIs u otras fuentes de datos.
- Implementa las **fuentes de datos** (datasources) locales y remotas, encapsulando detalles de infraestructura.
- Define las implementaciones concretas de los repositorios que delegan en los datasources.
- Realiza solo transformaciones simples de datos (mapeos DTO <-> entity) sin incluir lógica de negocio.
- Expone únicamente contratos necesarios al dominio, evitando filtrar detalles de infraestructura.

## Capa `domain`
- Declara las **interfaces de los repositorios** consumidas por los casos de uso y la presentación.
- Define los **modelos de dominio** con las invariantes de negocio.
- Implementa los **use cases** (interactors) que orquestan la lógica de negocio y coordinan repositorios.
- No depende de frameworks ni detalles concretos; debe ser fácilmente testeable y reusable.
- Gestiona validaciones de negocio, reglas y políticas de la aplicación.

## Capa `presentation`
- Implementa el patrón **MVVM**: Views, ViewModels, estados de UI y controladores de navegación.
- Orquesta los flujos de UI consumiendo únicamente use cases e interfaces de dominio.
- Gestiona el ciclo de vida de la interfaz, estados, eventos de usuario y binding de datos.
- No accede directamente a datasources ni contiene lógica de negocio; delega decisiones al dominio.

## Principios generales
- Mantener dependencias unidireccionales: `presentation -> domain -> data`.
- Definir contratos claros (interfaces) entre capas y compartir datos mediante mapeadores específicos.
- Utilizar inyección de dependencias para componer capas y facilitar pruebas.
- Escribir pruebas unitarias independientes por capa (p. ej., mocks para domain en presentación).
- Documentar cualquier desviación de estas reglas con su justificación.

Cumplir estas directrices garantiza un código modular, mantenible y escalable.

# Codestyle intermedio de Swifty

Estas pautas describen un estilo de codificación inspirado en prácticas intermedias de Swift:

- Utiliza `camelCase` para nombres de variables, funciones y propiedades.
- Prefiere `let` para valores inmutables y `var` solo cuando la mutabilidad sea necesaria.
- Mantén las funciones concisas, con responsabilidades claras y una longitud máxima aproximada de 40 líneas.
- Organiza las importaciones de forma alfabética y evita las no utilizadas.
- Documenta las clases, estructuras y funciones públicas con comentarios en formato Markdown.
- Aplica sangría de cuatro espacios y alinea los cierres de llaves con la declaración correspondiente.
- Agrupa las extensiones por protocolo o funcionalidad, añadiendo un comentario de encabezado que describa su propósito.
