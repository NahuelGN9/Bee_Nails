# Nail Studio - Página Web

Una página web elegante y minimalista para un negocio de manicura y pedicura, desarrollada con HTML, CSS, JavaScript, PHP y MySQL, todo containerizado con Docker.

## 🎨 Características

- **Diseño minimalista y elegante** con colores dorados y tonos suaves
- **Responsive design** que se adapta a todos los dispositivos
- **Sistema de reservas** completo con base de datos
- **Páginas informativas** sobre el proceso y servicios
- **Galería de imágenes** de uñas con diseños atractivos
- **Formulario de contacto** funcional

## 🚀 Tecnologías Utilizadas

- **Frontend**: HTML5, CSS3, JavaScript (ES6+)
- **Backend**: PHP 8.2
- **Base de datos**: MySQL 8.0
- **Servidor web**: Nginx
- **Containerización**: Docker & Docker Compose
- **Administración**: phpMyAdmin

## 📁 Estructura del Proyecto

```
pagina_web/
├── html/                    # Páginas HTML
│   ├── index.html          # Página principal
│   ├── proceso.html        # Información del proceso
│   └── turnos.html         # Formulario de reservas
├── css/                     # Estilos CSS
│   └── style.css           # Estilos principales
├── js/                      # JavaScript
│   └── script.js           # Funcionalidad del frontend
├── php/                     # Scripts PHP
│   └── process_booking.php # Procesamiento de reservas
├── images/                  # Imágenes SVG
│   ├── nail1.svg          # Uñas rosa elegante
│   ├── nail2.svg          # Uñas azul océano
│   ├── nail3.svg          # Uñas dorado clásico
│   ├── nail4.svg          # Uñas rosa floral
│   ├── process1.svg       # Consulta inicial
│   └── process2.svg       # Preparación
├── database/                # Scripts de base de datos
│   └── init.sql           # Inicialización de MySQL
├── nginx/                   # Configuración de Nginx
│   ├── nginx.conf         # Configuración principal
│   └── default.conf       # Configuración del sitio
└── docker-compose.yml      # Orquestación de contenedores
```

## 🛠️ Instalación y Uso

### Prerrequisitos

- Docker
- Docker Compose

### Pasos de Instalación

1. **Clonar o descargar el proyecto**
   ```bash
   cd /home/nahuel/Documentos/cloneGIT/cursor/pagina_web
   ```

2. **Levantar los contenedores**
   ```bash
   docker-compose up -d
   ```

3. **Verificar que todos los servicios estén funcionando**
   ```bash
   docker-compose ps
   ```

4. **Acceder a la aplicación**
   - **Página web**: http://localhost:8091
   - **phpMyAdmin**: http://localhost:8090

### Credenciales de Base de Datos

- **Usuario**: nailstudio_user
- **Contraseña**: nailstudio_pass
- **Base de datos**: nailstudio

## 🌐 Páginas Disponibles

### 1. Página Principal (`index.html`)
- Hero section con galería de uñas
- Servicios disponibles con precios
- Características del negocio
- Call-to-action para reservas

### 2. Nuestro Proceso (`proceso.html`)
- 5 pasos detallados del proceso
- Técnicas utilizadas
- Compromiso con la calidad
- Información sobre productos

### 3. Reservar Turno (`turnos.html`)
- Formulario completo de reserva
- Selección de servicios
- Calendario y horarios
- Opciones adicionales
- Información de contacto

## 🎯 Funcionalidades

### Sistema de Reservas
- **Validación frontend** con JavaScript
- **Procesamiento backend** con PHP
- **Almacenamiento** en MySQL
- **Confirmación** automática
- **Cálculo de precios** dinámico

### Servicios Disponibles
- **Manicura**: $25.000
- **Pedicura**: $30.000
- **Nail Art**: $35.000
- **Gel & Acrílico**: $40.000

### Opciones Adicionales
- Descuento 10% para manicura + pedicura
- Diseño especial para ocasiones
- Primera vez (información adicional)

## 🗄️ Base de Datos

### Tablas Principales

1. **turnos**: Almacena todas las reservas
2. **servicios**: Catálogo de servicios disponibles
3. **horarios_disponibles**: Horarios de atención
4. **configuracion**: Configuración del sistema

### Funciones y Procedimientos
- `CalcularPrecio()`: Calcula precios con descuentos
- `GetAvailableSlots()`: Obtiene horarios disponibles

## 🎨 Diseño

### Paleta de Colores
- **Primario**: #d4af37 (Dorado)
- **Secundario**: #f8f4f0 (Beige claro)
- **Acento**: #e8b4b8 (Rosa suave)
- **Texto**: #2c2c2c (Gris oscuro)

### Tipografías
- **Títulos**: Playfair Display (serif elegante)
- **Texto**: Inter (sans-serif moderna)

### Características del Diseño
- Minimalista y elegante
- Responsive design
- Animaciones suaves
- Iconos Font Awesome
- Gradientes sutiles

## 🔧 Configuración

### Variables de Entorno
Las credenciales de la base de datos se configuran en `docker-compose.yml`:

```yaml
environment:
  MYSQL_ROOT_PASSWORD: root_password
  MYSQL_DATABASE: nailstudio
  MYSQL_USER: nailstudio_user
  MYSQL_PASSWORD: nailstudio_pass
```

### Personalización
Para personalizar la página:

1. **Colores**: Modificar variables CSS en `css/style.css`
2. **Contenido**: Editar archivos HTML
3. **Servicios**: Actualizar tabla `servicios` en MySQL
4. **Precios**: Modificar array en `php/process_booking.php`

## 📱 Responsive Design

La página está optimizada para:
- **Desktop**: 1200px+
- **Tablet**: 768px - 1199px
- **Mobile**: 320px - 767px

## 🚀 Despliegue

### Producción
Para desplegar en producción:

1. **Configurar dominio** en `nginx/default.conf`
2. **Configurar SSL** para HTTPS
3. **Backup de base de datos** regular
4. **Monitoreo** de contenedores

### Backup
```bash
# Backup de base de datos
docker exec nailstudio_mysql mysqldump -u nailstudio_user -p nailstudio > backup.sql

# Backup de archivos
tar -czf pagina_web_backup.tar.gz pagina_web/
```

## 🐛 Troubleshooting

### Problemas Comunes

1. **Contenedores no inician**
   ```bash
   docker-compose logs
   docker-compose down && docker-compose up -d
   ```

2. **Base de datos no conecta**
   ```bash
   docker-compose restart mysql
   ```

3. **PHP no procesa**
   ```bash
   docker-compose restart php-fpm nginx
   ```

### Logs
```bash
# Ver logs de todos los servicios
docker-compose logs -f

# Logs específicos
docker-compose logs nginx
docker-compose logs mysql
docker-compose logs php-fpm
```

## 📞 Soporte

Para soporte técnico o preguntas sobre el proyecto, contactar al desarrollador.

## 📄 Licencia

Este proyecto es de código abierto y está disponible bajo la licencia MIT.

---

**Nail Studio** - Transformando uñas en obras de arte desde 2020 ✨
