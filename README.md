# Demostración Práctica de OSGi y Apache Karaf

Este repositorio contiene la solución completa para la tarea sobre patrones de arquitectura utilizando **OSGi (Open Services Gateway initiative)** y **Apache Karaf** en la asignatura de *Diseño y Arquitectura de Software*.

## Contenido del Proyecto
El proyecto está estructurado de la siguiente forma:

* **[Investigacion_OSGi.md](Investigacion_OSGi.md)**: Reporte teórico detallado que responde a las preguntas sobre el funcionamiento de OSGi, los patrones de arquitectura involucrados (Microkernel/Plugins, SOA in-VM, Service Registry) y sus aplicaciones prácticas en la industria.
* **`src/com/example/greeting/`**: Bundle del Proveedor de Servicios (`greeting-service`). Define la interfaz `GreetingService` y su implementación concreta `GreetingServiceImpl`. Registra dinámicamente el servicio al activarse.
* **`src/com/example/client/`**: Bundle del Consumidor de Servicios (`greeting-client`). Utiliza un `ServiceTracker` para buscar y consumir dinámicamente el `GreetingService` de forma reactiva desde un hilo en segundo plano.
* **`build_bundles.ps1`**: Script de automatización en PowerShell que compila y empaqueta las clases Java en bundles OSGi válidos (archivos JAR con metadatos específicos en su manifiesto) sin depender de Maven, utilizando el JDK instalado localmente.
* **`manifests/`**: Contiene las plantillas de manifiesto OSGi (`provider.mf` y `consumer.mf`) necesarias para declarar los imports/exports de paquetes y activadores de ciclo de vida.

---

## Requisitos Previos
* **Java Development Kit (JDK)**: Se requiere JDK 11 o superior instalado (el script utiliza la versión 21).
* **PowerShell**: Para ejecutar el script de compilación y empaquetado.

---

## Instrucciones para Compilar y Ejecutar

### 1. Compilar los Bundles
Abra una consola de PowerShell en la raíz del proyecto y ejecute:
```powershell
powershell -ExecutionPolicy Bypass -File .\build_bundles.ps1
```
Esto creará los siguientes archivos en la raíz del proyecto:
* `greeting-service.jar` (Bundle del proveedor)
* `greeting-client.jar` (Bundle del consumidor)

### 2. Iniciar Apache Karaf
Para iniciar el contenedor OSGi Apache Karaf, ejecute:
```powershell
.\tools\apache-karaf-4.4.6\bin\karaf.bat
```
*(Nota: Karaf requiere que la variable de entorno `JAVA_HOME` esté configurada correctamente apuntando a su instalación de JDK).*

### 3. Instalar y Desplegar los Bundles en Karaf
Puede copiar los archivos JAR generados directamente en la carpeta de despliegue en caliente de Karaf para instalarlos automáticamente:
* Copie `greeting-service.jar` y `greeting-client.jar` a la ruta `tools\apache-karaf-4.4.6\deploy\`

O ejecute los siguientes comandos en la consola interactiva de Karaf:
```shell
# Instalar e iniciar el proveedor
bundle:install file:C:/Users/jeanc/Desktop/Arquitectura%20de%20Software/greeting-service.jar
bundle:start <ID_PROVEEDOR>

# Instalar e iniciar el cliente
bundle:install file:C:/Users/jeanc/Desktop/Arquitectura%20de%20Software/greeting-client.jar
bundle:start <ID_CLIENTE>
```

### 4. Prueba del Ciclo de Vida Dinámico (Desacoplamiento)
El cliente cuenta con un hilo secundario que consulta la disponibilidad del servicio de saludos cada 3 segundos. Para demostrar que los bundles pueden arrancarse y pararse a demanda sin afectar la ejecución del sistema:

1. Busque los IDs de sus bundles con:
   ```shell
   bundle:list
   ```
2. Detenga el proveedor (ej. ID 53):
   ```shell
   bundle:stop 53
   ```
   *Observación:* La consola de Karaf mostrará de inmediato que el proveedor se detiene desregistrando el servicio. El cliente detectará dinámicamente la pérdida del servicio y mostrará logs de alerta en segundo plano:
   `[Greeting Client] WARNING: GreetingService is currently UNAVAILABLE.`
   El sistema no se detiene ni produce excepciones fatales.

3. Inicie el proveedor nuevamente:
   ```shell
   bundle:start 53
   ```
   *Observación:* El cliente detecta la reaparición del servicio de manera inmediata e inteligente y reanuda el saludo exitosamente:
   `[Greeting Client] SUCCESS: Hello, Jean Gomez! Welcome to the OSGi dynamic architecture demo.`
