# QueueFlow

QueueFlow es una aplicación móvil desarrollada en Flutter que utiliza Firebase para autenticación, base de datos en tiempo real y notificaciones.

## 📋 Requisitos Previos

Antes de comenzar, asegúrate de tener instalado lo siguiente en tu sistema:

*   **Flutter SDK**: [Guía de instalación](https://docs.flutter.dev/get-started/install)
*   **Dart SDK**: Incluido con Flutter.
*   **Editor de Código**: VS Code o Android Studio (con los plugins de Flutter y Dart instalados).
*   **Cuenta de Firebase**: Necesaria si planeas configurar tu propio proyecto de backend.
*   **Firebase CLI**: Para configurar los servicios de Firebase (`npm install -g firebase-tools`).

## 🚀 Instalación

Sigue estos pasos para configurar el proyecto localmente:

1.  **Clonar el repositorio**:
    ```bash
    git clone https://github.com/ErickMendoza117/queueflow.git
    cd queueflow
    ```

2.  **Instalar dependencias**:
    Ejecuta el siguiente comando para descargar las librerías necesarias listadas en `pubspec.yaml`:
    ```bash
    flutter pub get
    ```

## ⚙️ Configuración de Firebase

Este proyecto utiliza Firebase. Si estás configurando el proyecto desde cero o conectándolo a tu propia instancia de Firebase:

1.  Asegúrate de tener **Firebase CLI** instalado y logueado:
    ```bash
    firebase login
    ```

2.  Activa **FlutterFire CLI** (si no lo tienes):
    ```bash
    dart pub global activate flutterfire_cli
    ```

3.  Configura el proyecto (esto generará `firebase_options.dart` y los archivos de configuración nativos como `google-services.json`):
    ```bash
    flutterfire configure
    ```
    Sigue las instrucciones en pantalla para seleccionar tu proyecto de Firebase y las plataformas (Android, iOS, etc.).

> **Nota**: Si ya tienes los archivos de configuración (`lib/firebase_options.dart`, `android/app/google-services.json`, etc.), puedes omitir el paso de configuración.

## ▶️ Ejecución

Para correr la aplicación en un emulador o dispositivo físico conectado:

1.  Verifica que tienes un dispositivo conectado:
    ```bash
    flutter devices
    ```

2.  Ejecuta la aplicación:
    ```bash
    flutter run
    ```

## 📦 Dependencias Principales

El proyecto utiliza las siguientes librerías clave:

*   `firebase_core`: Núcleo de Firebase.
*   `firebase_auth`: Gestión de usuarios y autenticación.
*   `cloud_firestore`: Base de datos NoSQL en la nube.
*   `firebase_messaging`: Notificaciones push.
*   `flutter_local_notifications`: Notificaciones locales.
*   `shared_preferences`: Almacenamiento de datos simples en el dispositivo.

## 📂 Estructura del Proyecto

*   `lib/`: Contiene el código fuente Dart de la aplicación.
*   `android/`: Configuración específica para Android.
*   `ios/`: Configuración específica para iOS.
*   `pubspec.yaml`: Archivo de gestión de dependencias.
