# Ejercicio 2 - Mapas y permisos

Proyecto independiente de SwiftUI con MapKit y Core Location. Sigue los conceptos y pasos del documento Ejercicio2.pdf y adapta el LocationManager.swift del profesor. No reutiliza la aplicación ni las evidencias de otro alumno.

## Qué incluye

- MapasYPermisos.xcodeproj: proyecto completo para Xcode.
- MapasYPermisos/: código Swift, Info.plist y entitlements de macOS.
- .github/workflows/appetize.yml: compilación en GitHub Actions con macOS.
- scripts/build_appetize.sh: genera una app para iOS Simulator y su ZIP.
- RecorridoCampeche.gpx: tres posiciones de prueba para Xcode.

Este ZIP contiene el PROYECTO y el código. Todavía no es una app compilada para Appetize. La compilación se realizará en tu Xcode o al ejecutar el flujo en GitHub Actions.

## Funciones del ejercicio

1. Mapa real de MapKit, con centro CLLocationCoordinate2D, zoom MKCoordinateSpan y MKCoordinateRegion.
2. Picker para Imí, Centro de Campeche y Ciudad de México. Ver lugar y Siguiente cambian la región.
3. Controles para mover y acercar el mapa, y selector de mapa normal o satélite.
4. Botón Mi ubicación: solicita autorización solo al pulsarlo, muestra el estado del permiso y recibe actualizaciones mediante CLLocationManagerDelegate.
5. UserAnnotation y centrado del mapa en la posición recibida. Muestra coordenadas, precisión, hora y contador de actualizaciones.
6. Manejo de permiso denegado, restringido o posición aún no disponible. Detener interrumpe el seguimiento.
7. Info.plist incluye la explicación del permiso. En Mac también se configura acceso de ubicación y red en los entitlements.

Se utiliza la API moderna Map(position:) de iOS 17, manteniendo MKCoordinateRegion y MKCoordinateSpan como pide el ejercicio. La vista conserva LocationManager mediante @StateObject.

## Ruta A - Ejecutar con tu Xcode

1. Descomprime y abre MapasYPermisos.xcodeproj.
2. Selecciona el esquema MapasYPermisos y un iPhone Simulator con iOS 17 o posterior. Usa Xcode 15 o posterior. My Mac también está configurado para macOS 14 o posterior.
3. Pulsa Run. El esquema está configurado sin depurador para reducir las demoras que aparecieron en la VM en los ejercicios anteriores.
4. Cambia de lugar y confirma que cargan las calles del mapa.
5. Pulsa Mi ubicación y elige Permitir mientras se usa la app. En el simulador, utiliza Features > Location > Custom Location para introducir coordenadas de prueba. Xcode también permite simular una ubicación desde su menú Debug.
6. Introduce 19.8439, -90.5360. Luego cambia a 19.8450, -90.5350. Con el seguimiento activo deberían cambiar las coordenadas y el centro del mapa.

Un mapa sin calles no demuestra un error de GPS: los mosaicos del mapa y las actualizaciones de ubicación son servicios distintos. Si la VM no dibuja el mapa, prueba la ruta B sin sustituir el mapa por una imagen.

## Ruta B - GitHub Actions y Appetize

GitHub compila el código en una máquina macOS. Appetize ejecuta la app compilada en un simulador accesible desde el navegador. No se utiliza GitHub Pages ni se sube el ZIP del código a Appetize.

### 1. Subir el proyecto a GitHub

1. Crea un repositorio para esta práctica. No subas datos personales, capturas ni documentos de otros alumnos.
2. Sube EL CONTENIDO de esta carpeta a la raíz del repositorio. Ahí deben quedar MapasYPermisos.xcodeproj, MapasYPermisos, scripts y la carpeta oculta .github.
3. Comprueba en GitHub que exista .github/workflows/appetize.yml. Si el explorador no muestra .github, activa la visualización de archivos ocultos o crea ese archivo con Add file > Create new file y pega el contenido incluido.
4. El flujo se inicia al subir los archivos; también puedes abrir Actions > Compilar Mapas para Appetize > Run workflow.
5. Espera el resultado. La primera ejecución puede tardar varios minutos. Si falla, abre el paso rojo y comparte el mensaje de error; no generes evidencia de una compilación que no terminó.

No se requiere un certificado de Apple para este build de simulador. La disponibilidad y el consumo de minutos dependen de la cuenta y de la configuración del repositorio; revisa lo que indique GitHub antes de habilitar servicios de pago.

### 2. Descargar la app compilada

Al finalizar correctamente, abre la ejecución y descarga el archivo MapasYPermisos-Appetize.zip en Artifacts. El flujo usa subida directa del archivo ZIP. Si GitHub lo entrega dentro de otro ZIP, extrae solo el contenedor exterior: el archivo que subirás a Appetize debe contener MapasYPermisos.app en su raíz.

También puedes generar ese archivo en la Terminal de la Mac, desde esta carpeta:

    bash scripts/build_appetize.sh

El resultado queda en salida/MapasYPermisos-Appetize.zip. Este comando compila para ARM64 y x86_64 del simulador. No es un .ipa de distribución ni un archivo .xcodeproj.

### 3. Abrirlo en Appetize

1. Entra a tu cuenta de Appetize y abre Upload / Add app.
2. Elige iOS y sube MapasYPermisos-Appetize.zip, EL COMPILADO obtenido en el paso anterior.
3. Abre la aplicación con un dispositivo y versión iOS 17 o posterior disponibles en tu cuenta.
4. Confirma primero el mapa de Imí y el cambio a Campeche/CDMX.
5. Pulsa Mi ubicación. Mantén la autorización automática desactivada en Appetize si quieres capturar la solicitud del permiso del sistema.

No se configuró una subida automática a Appetize ni se necesitan sus claves en este proyecto. No compartas tokens o contraseñas en el repositorio.

### 4. Probar la ubicación en Appetize

La posición de Appetize es SIMULADA; no equivale al GPS físico de tu computadora o teléfono.

- Usa el control Change Location de la página de ejecución si está disponible en tu cuenta. Introduce primero latitud 19.8439 y longitud -90.5360, y después 19.8450 y -90.5350.
- La documentación permite incluir location en la URL de la sesión: agrega ?location=19.8439,-90.5360 si no hay otros parámetros, o &location=19.8439,-90.5360 si ya existen. Para probar cambios continuos sin reiniciar la sesión, usa Change Location o el SDK.
- El SDK oficial expone session.setLocation(latitud, longitud). Para un cambio en la MISMA sesión: await session.setLocation(19.8450, -90.5350). Esto se utiliza desde una integración de ese SDK, no pegándolo dentro de la app Swift.

Deja la app con seguimiento activo. La prueba consiste en comprobar que Core Location recibe el cambio y que la interfaz actualiza sus coordenadas y región. En el reporte se explicará que son coordenadas simuladas.

Appetize evita depender del renderizado de tu VM, pero no garantiza por sí solo que MapKit cargue todos los mosaicos. Comprobaremos el resultado de la ejecución antes de obtener las capturas.

## Capturas para reunir después

1. Flujo de GitHub Actions terminado correctamente, si se usa esa ruta.
2. Mapa visible en Imí o Campeche y otro lugar seleccionado.
3. Solicitud de permiso al pulsar Mi ubicación.
4. Permiso permitido y coordenadas recibidas.
5. Cambio de coordenadas durante el seguimiento (dos posiciones diferentes).
6. Info.plist, LocationManager y fragmento de ContentView con el Picker y Map.

Todavía no se incluyen capturas ni un reporte de ejecución. Se elaborarán a partir de tus pruebas. A diferencia del ejercicio 3, aquí la evidencia solicitada es una síntesis de los conceptos nuevos, no seis preguntas de reflexión.

## Verificación del paquete

Se revisaron la estructura del proyecto, las referencias de archivos, el esquema compartido, los permisos de Info.plist y la integridad del ZIP. La compilación y las pruebas de mapas/ubicación deben realizarse en Xcode o GitHub Actions. No se ha creado un repositorio ni subido la app a ninguna cuenta desde este entorno.

## Documentación

- Appetize iOS: https://docs.appetize.io/platform/app-management/uploading-apps/ios
- Ubicación simulada: https://docs.appetize.io/features/mock-location
- Ejecución y Change Location: https://docs.appetize.io/platform/app-management/running-apps
- Apple MapKit: https://developer.apple.com/documentation/mapkit/mapkit-for-swiftui
- Permiso de ubicación: https://developer.apple.com/documentation/corelocation/cllocationmanager/requestwheninuseauthorization()
- Runners de GitHub: https://docs.github.com/en/actions/reference/runners/github-hosted-runners
