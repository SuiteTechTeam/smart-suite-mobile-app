# Sistema de Reservaciones - Smart Suite

## Descripción General

El sistema de reservaciones de Smart Suite ha sido completamente reescrito para integrarse correctamente con la API del backend. El nuevo flujo maneja todo el proceso de reservación desde la selección de fechas hasta la confirmación final.

## Arquitectura del Sistema

### Servicios Principales

1. **BookingFlowService** - Servicio principal que coordina todo el flujo de reservaciones
2. **PaymentCustomerService** - Maneja la creación y gestión de clientes de pago
3. **ReservationService** - Gestiona las operaciones CRUD de reservaciones
4. **RoomService** - Obtiene información de habitaciones disponibles

### Modelos

1. **Reservation** - Modelo principal de reservación
2. **AvailableRoom** - Modelo combinado de habitación con información de tipo y precio
3. **PaymentCustomer** - Modelo para clientes de pago

## Flujo de Reservación

### 1. Inicialización
- Carga información del usuario desde JWT token
- Obtiene hotelId (desde token, argumentos o almacenamiento)
- Pre-llena información básica del usuario

### 2. Selección de Fechas
- Usuario selecciona fecha de llegada
- Usuario selecciona fecha de salida
- Validación automática de fechas

### 3. Carga de Habitaciones Disponibles
- Llama a la API para obtener habitaciones disponibles
- Enriquece datos con información de tipos de habitación
- Muestra habitaciones con precios y disponibilidad

### 4. Selección de Habitación
- Usuario selecciona habitación deseada
- Muestra resumen detallado de la reservación
- Calcula precio total automáticamente

### 5. Creación de Reservación
- Valida todos los datos
- Crea o obtiene PaymentCustomer
- Crea la reservación en la API
- Actualiza PaymentCustomer con monto final

## Endpoints de API Utilizados

### Booking
- `POST /api/v1/booking/create-booking` - Crear reservación
- `GET /api/v1/booking/get-booking-by-id` - Obtener reservación por ID
- `GET /api/v1/booking/get-all-bookings` - Obtener todas las reservaciones
- `PUT /api/v1/booking/update-booking-state` - Actualizar estado

### Payment Customer
- `POST /api/v1/payment-customer` - Crear cliente de pago
- `GET /api/v1/payment-customer/{id}` - Obtener cliente de pago
- `GET /api/v1/payment-customer/by-customer/{customerId}` - Obtener por cliente
- `PUT /api/v1/payment-customer/{id}` - Actualizar cliente de pago

### Room
- `GET /api/v1/room/get-room-by-booking-availability` - Habitaciones disponibles
- `GET /api/v1/room/get-all-rooms` - Todas las habitaciones
- `GET /api/v1/room/get-room-by-id` - Habitación por ID

### Type Room
- `GET /api/v1/type-room/get-all-type-rooms` - Tipos de habitación

## Características del Nuevo Sistema

### ✅ Funcionalidades Implementadas

1. **Integración Completa con API**
   - Todos los endpoints utilizan la API real
   - Manejo correcto de errores y respuestas

2. **Flujo de PaymentCustomer**
   - Creación automática de clientes de pago
   - Actualización de montos finales
   - Reutilización de clientes existentes

3. **Validación de Fechas**
   - Validación de fechas de llegada y salida
   - Prevención de reservaciones en el pasado
   - Cálculo automático de noches

4. **Carga de Habitaciones Reales**
   - Integración con servicio de habitaciones
   - Información completa de tipos y precios
   - Filtrado por disponibilidad

5. **Interfaz de Usuario Mejorada**
   - Selección intuitiva de fechas
   - Visualización clara de habitaciones disponibles
   - Resumen detallado antes de confirmar

6. **Manejo de Estados**
   - Estados de carga apropiados
   - Mensajes de error informativos
   - Validación en tiempo real

### 🔧 Componentes Reutilizables

1. **AvailableRoomSelection** - Widget para seleccionar habitaciones
2. **BookingSummaryCard** - Widget para mostrar resumen
3. **SectionTitle** - Widget para títulos de sección
4. **CustomTextField** - Campo de texto personalizado

## Uso del Sistema

### Crear una Nueva Reservación

```dart
// Navegar a la pantalla de nueva reservación
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => AddReservationScreen(hotelId: hotelId),
  ),
);
```

### Obtener Habitaciones Disponibles

```dart
BookingFlowService bookingService = BookingFlowService();

List<AvailableRoom> rooms = await bookingService.getAvailableRooms(
  startDate: DateTime.now(),
  finalDate: DateTime.now().add(Duration(days: 2)),
  hotelId: 1,
);
```

### Crear una Reservación Completa

```dart
Reservation reservation = await bookingService.createBooking(
  guestId: userId,
  roomId: selectedRoom.id,
  description: "Reservación de prueba",
  startDate: startDate,
  finalDate: endDate,
  pricePerNight: 100.0,
);
```

## Manejo de Errores

El sistema incluye manejo robusto de errores:

1. **Validación de Datos** - Validación en frontend antes de enviar a API
2. **Errores de API** - Captura y muestra errores del backend
3. **Errores de Red** - Manejo de problemas de conectividad
4. **Errores de Autenticación** - Redirección a login si es necesario

## Configuración

### Variables de Entorno
- `hotelId` - ID del hotel (obtenido de JWT token o configuración)
- `baseUrl` - URL base de la API (configurada en BaseService)

### Almacenamiento
- Tokens JWT en FlutterSecureStorage
- Hotel ID en preferencias seguras
- Configuraciones de usuario en SharedPreferences

## Próximas Mejoras

1. **Confirmación por Email** - Envío de confirmación automática
2. **Cancelación de Reservaciones** - Interfaz para cancelar reservaciones
3. **Modificación de Reservaciones** - Edición de reservaciones existentes
4. **Historial de Reservaciones** - Vista de reservaciones pasadas
5. **Notificaciones Push** - Recordatorios de reservaciones
6. **Pagos Integrados** - Integración con sistema de pagos

## Troubleshooting

### Problemas Comunes

1. **Error de Hotel ID**
   - Verificar que el hotel ID esté configurado correctamente
   - Revisar el token JWT para locality

2. **No se cargan habitaciones**
   - Verificar conectividad con la API
   - Revisar que las fechas sean válidas
   - Confirmar que el hotel tenga habitaciones configuradas

3. **Error al crear reservación**
   - Verificar que el usuario esté autenticado
   - Confirmar que la habitación esté disponible
   - Revisar que todos los campos requeridos estén completos

### Logs y Debugging

El sistema incluye logs detallados para debugging:
- Logs de API calls
- Logs de validación
- Logs de errores de usuario
- Logs de estado de la aplicación 