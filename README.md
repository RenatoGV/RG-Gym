# 🏋️ RG Gym

[![Flutter](https://img.shields.io/badge/Flutter-3.13.0-blue.svg)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.11.5-blue.svg)](https://dart.dev/)

Aplicación de entrenamiento personal para Android e iOS construida con Flutter.

RG Gym permite crear rutinas propias, elegir ejercicios por grupo muscular, gestionar el historial y controlar sesiones de entrenamiento con notificaciones y tareas en segundo plano.

## ✨ Características principales

### 🏃 Rutinas personalizadas
- Crear, editar, duplicar y eliminar rutinas.
- Agregar comentarios a cada rutina.
- Importar y exportar rutinas desde el menú de configuración.

### 🧠 Ejercicios por músculo
- Mapa corporal frontal/trasero para seleccionar músculos.
- Búsqueda de ejercicios por grupo muscular.
- Pantalla de información detallada de cada ejercicio.

### 📊 Estadísticas y seguimiento
- Historial de entrenamientos.
- Seguimiento de fatiga muscular.
- Gráficos y vistas por actividades en la pestaña de estadísticas.

### ⏱️ Ejecución y notificaciones
- Entrenamientos con temporizador y sesiones persistentes.
- Soporte de notificaciones con acciones.
- Servicio en primer plano para continuar el entrenamiento mientras la app está en segundo plano.

## 🧱 Estructura del proyecto

- `lib/main.dart` - inicialización de la app y providers.
- `lib/screens/home.dart` - pantalla principal con navegación inferior.
- `lib/screens/tabs/routines/` - gestión de rutinas.
- `lib/screens/tabs/exercises/` - selección de ejercicios por músculo.
- `lib/screens/tabs/stats/` - estadísticas, actividades e historial.
- `lib/service/` - almacenamiento local, notificaciones y tareas en primer plano.
- `lib/providers/` - lógica de estado con Provider.

## 🛠️ Tecnologías

- Flutter
- Dart
- Provider
- Awesome Notifications
- Flutter Foreground Task
- Shared Preferences
- UUID
- Flutter SVG
- FL Chart
- Table Calendar
- File Picker
- Audio Players
- Intl

## 📋 Requisitos previos

- Flutter SDK
- Android Studio o Xcode
- Dispositivo o emulador Android/iOS

## 🚀 Instalación

1. Clona el repositorio:
```bash
git clone https://github.com/<TU-USUARIO>/rg_gym.git
cd rg_gym
```
2. Instala dependencias:
```bash
flutter pub get
```
3. Ejecuta la app:
```bash
flutter run
```

## 📱 Uso

- Navega entre las pestañas de `Rutinas`, `Estadísticas` y `Ejercicios`.
- Crea una nueva rutina desde `Rutinas` y agrega ejercicios.
- Usa el mapa corporal para encontrar ejercicios por músculo.
- Accede al historial y revisa la fatiga muscular en `Estadísticas`.
- Exporta o importa rutinas desde el botón de `Configuración`.

## 📁 Assets

- `assets/images/` - imágenes e ilustraciones del cuerpo.
- `assets/gifs/exercises/` - animaciones de ejercicios.
- `assets/icons/` - iconos de la app.
- `assets/sounds/` - sonidos y notificaciones.

## ✅ Notas

- La app está configurada para orientación de pantalla vertical.
- El idioma por defecto es español (`es_ES`).
- Las rutinas y el historial se guardan localmente usando `Shared Preferences`.

---

> Proyecto encargado de gestionar entrenamientos con foco en rutinas personalizadas, seguimiento y experiencia móvil fluida.
