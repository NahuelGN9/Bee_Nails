#!/bin/bash

# Script de inicio rápido para Nail Studio
# Uso: ./start.sh

set -e

# Colores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Función para verificar Docker
check_docker() {
    if ! command -v docker &> /dev/null; then
        print_error "Docker no está instalado. Por favor instala Docker primero."
        exit 1
    fi
    
    # Verificar Docker Compose (versión moderna como plugin)
    if ! docker compose version &> /dev/null; then
        print_error "Docker Compose no está disponible. Por favor instala Docker Compose primero."
        exit 1
    fi
    
    print_success "Docker y Docker Compose están instalados"
}

# Función para iniciar servicios
start_services() {
    print_status "Iniciando servicios de Nail Studio..."
    
    # Detener servicios existentes si los hay
    docker compose down 2>/dev/null || true
    
    # Construir e iniciar servicios
    docker compose up -d --build
    
    print_success "Servicios iniciados correctamente"
}

# Función para verificar estado
check_status() {
    print_status "Verificando estado de los servicios..."
    
    sleep 5  # Esperar a que los servicios se inicien
    
    # Verificar contenedores
    if docker compose ps | grep -q "Up"; then
        print_success "Todos los contenedores están ejecutándose"
    else
        print_warning "Algunos contenedores pueden no estar funcionando correctamente"
        docker compose ps
    fi
    
    # Verificar conectividad
    if curl -s http://localhost:8091/health > /dev/null; then
        print_success "Nginx está respondiendo correctamente"
    else
        print_warning "Nginx puede no estar respondiendo aún"
    fi
}

# Función para mostrar información de acceso
show_access_info() {
    echo ""
    print_success "¡Nail Studio está listo!"
    echo ""
    echo "🌐 Accesos disponibles:"
    echo "   Página web:     http://localhost:8091"
    echo "   phpMyAdmin:     http://localhost:8090"
    echo ""
    echo "📊 Credenciales de base de datos:"
    echo "   Usuario:        nailstudio_user"
    echo "   Contraseña:     nailstudio_pass"
    echo "   Base de datos:  nailstudio"
    echo ""
    echo "🔧 Comandos útiles:"
    echo "   Ver logs:       docker compose logs -f"
    echo "   Detener:        docker compose down"
    echo "   Reiniciar:      docker compose restart"
    echo "   Estado:         docker compose ps"
    echo ""
    echo "📱 Páginas disponibles:"
    echo "   Inicio:         http://localhost:8091"
    echo "   Proceso:        http://localhost:8091/proceso.html"
    echo "   Reservas:       http://localhost:8091/turnos.html"
    echo ""
}

# Función para mostrar ayuda
show_help() {
    echo "Script de inicio para Nail Studio"
    echo ""
    echo "Uso: $0 [comando]"
    echo ""
    echo "Comandos:"
    echo "  start     - Iniciar todos los servicios (por defecto)"
    echo "  stop      - Detener todos los servicios"
    echo "  restart   - Reiniciar todos los servicios"
    echo "  status    - Mostrar estado de los servicios"
    echo "  logs      - Mostrar logs de los servicios"
    echo "  help      - Mostrar esta ayuda"
    echo ""
}

# Función para detener servicios
stop_services() {
    print_status "Deteniendo servicios de Nail Studio..."
    docker compose down
    print_success "Servicios detenidos"
}

# Función para reiniciar servicios
restart_services() {
    print_status "Reiniciando servicios de Nail Studio..."
    docker compose restart
    print_success "Servicios reiniciados"
}

# Función para mostrar estado
show_status() {
    print_status "Estado de los servicios:"
    docker compose ps
}

# Función para mostrar logs
show_logs() {
    print_status "Mostrando logs de los servicios (Ctrl+C para salir):"
    docker compose logs -f
}

# Función principal
main() {
    case "${1:-start}" in
        "start")
            check_docker
            start_services
            check_status
            show_access_info
            ;;
        "stop")
            stop_services
            ;;
        "restart")
            restart_services
            ;;
        "status")
            show_status
            ;;
        "logs")
            show_logs
            ;;
        "help"|*)
            show_help
            ;;
    esac
}

# Ejecutar función principal
main "$@"
