// JavaScript para manejo del formulario de reservas
document.addEventListener('DOMContentLoaded', function() {

    const updateHeaderHeight = () => {
        const header = document.querySelector('.header');
        if (!header) return;
        const height = Math.ceil(header.getBoundingClientRect().height);
        document.documentElement.style.setProperty('--header-height', `${height}px`);
    };

    updateHeaderHeight();
    window.addEventListener('resize', updateHeaderHeight);

    const modelPhotos = document.querySelectorAll('.model-photo');
    if (modelPhotos.length) {
        const lightbox = document.createElement('div');
        lightbox.className = 'lightbox';
        lightbox.setAttribute('role', 'dialog');
        lightbox.setAttribute('aria-modal', 'true');

        const img = document.createElement('img');
        img.className = 'lightbox-img';
        img.alt = '';

        const closeBtn = document.createElement('button');
        closeBtn.className = 'lightbox-close';
        closeBtn.type = 'button';
        closeBtn.setAttribute('aria-label', 'Cerrar');
        closeBtn.textContent = '×';

        lightbox.appendChild(img);
        lightbox.appendChild(closeBtn);
        document.body.appendChild(lightbox);

        const open = (src, alt) => {
            img.src = src;
            img.alt = alt || '';
            lightbox.classList.add('is-open');
            document.body.style.overflow = 'hidden';
        };

        const close = () => {
            lightbox.classList.remove('is-open');
            document.body.style.overflow = '';
            img.src = '';
        };

        modelPhotos.forEach(p => {
            p.addEventListener('click', () => open(p.src, p.alt));
        });

        closeBtn.addEventListener('click', close);
        lightbox.addEventListener('click', (e) => {
            if (e.target === lightbox) close();
        });

        document.addEventListener('keydown', (e) => {
            if (e.key === 'Escape' && lightbox.classList.contains('is-open')) {
                close();
            }
        });
    }
    
    // Elementos del formulario
    const bookingForm = document.getElementById('bookingForm');
    const successMessage = document.getElementById('successMessage');
    
    // Configurar fecha mínima (hoy) si existe el input
    const fechaInput = document.getElementById('fecha');
    const today = new Date().toISOString().split('T')[0];
    if (fechaInput) {
        fechaInput.setAttribute('min', today);
    }
    
    // Manejar envío del formulario
    if (bookingForm) {
        bookingForm.addEventListener('submit', function(e) {
            e.preventDefault();
            
            // Validar formulario
            if (validateForm()) {
                submitBooking();
            }
        });
    }
    
    // Validación del formulario
    function validateForm() {
        const nombre = document.getElementById('nombre').value.trim();
        const telefono = document.getElementById('telefono').value.trim();
        const servicio = document.querySelector('input[name="servicio"]:checked');
        const fecha = document.getElementById('fecha').value;
        const hora = document.getElementById('hora').value;
        
        let isValid = true;
        let errorMessage = '';
        
        // Validar campos requeridos
        if (!nombre) {
            errorMessage += 'El nombre es requerido.\n';
            isValid = false;
        }
        
        if (!telefono) {
            errorMessage += 'El teléfono es requerido.\n';
            isValid = false;
        }
        
        if (!servicio) {
            errorMessage += 'Debe seleccionar un servicio.\n';
            isValid = false;
        }
        
        if (!fecha) {
            errorMessage += 'La fecha es requerida.\n';
            isValid = false;
        }
        
        if (!hora) {
            errorMessage += 'La hora es requerida.\n';
            isValid = false;
        }
        
        // Validar fecha
        if (fecha && new Date(fecha) < new Date(today)) {
            errorMessage += 'La fecha no puede ser anterior a hoy.\n';
            isValid = false;
        }
        
        // Validar teléfono (formato básico)
        if (telefono && !/^[\d\s\-\+\(\)]+$/.test(telefono)) {
            errorMessage += 'El formato del teléfono no es válido.\n';
            isValid = false;
        }
        
        if (!isValid) {
            alert('Por favor corrija los siguientes errores:\n\n' + errorMessage);
        }
        
        return isValid;
    }
    
    // Enviar reserva
    function submitBooking() {
        const formData = new FormData(bookingForm);
        const submitButton = bookingForm.querySelector('button[type="submit"]');
        
        // Deshabilitar botón y mostrar loading
        submitButton.disabled = true;
        submitButton.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Procesando...';
        
        // Enviar datos
        fetch('https://formspree.io/f/xeovqnrq', {
            method: 'POST',
            body: formData,
            headers: { 'Accept': 'application/json' }
        })
        .then(async response => {
            if (response.ok) {
                showSuccessMessage();
                return;
            }
            let message = 'Error al procesar la reserva';
            try {
                const data = await response.json();
                if (data && data.errors) {
                    message = data.errors.map(e => e.message).join(', ');
                }
            } catch (e) {
                // ignore parse error, keep default message
            }
            showErrorMessage(message);
        })
        .catch(error => {
            console.error('Error:', error);
            showErrorMessage('Error de conexión. Por favor intente nuevamente.');
        })
        .finally(() => {
            // Restaurar botón
            submitButton.disabled = false;
            submitButton.innerHTML = '<i class="fas fa-calendar-check"></i> Reservar Turno';
        });
    }
    
    // Mostrar mensaje de éxito
    function showSuccessMessage(data) {
        if (successMessage) {
            successMessage.style.display = 'flex';
            
            // Scroll to top
            window.scrollTo({ top: 0, behavior: 'smooth' });
            
            // Limpiar formulario después de 3 segundos
            setTimeout(() => {
                bookingForm.reset();
            }, 3000);
        }
    }
    
    // Mostrar mensaje de error
    function showErrorMessage(message) {
        alert('Error: ' + message);
    }
    
    // Ocultar mensaje de éxito
    window.hideSuccessMessage = function() {
        if (successMessage) {
            successMessage.style.display = 'none';
        }
    };
    
    // Actualizar horarios disponibles según la fecha seleccionada (si existe)
    if (fechaInput) {
        fechaInput.addEventListener('change', function() {
            updateAvailableHours(this.value);
        });
    }
    
    // Función para actualizar horarios disponibles
    function updateAvailableHours(fecha) {
        // Esta función podría hacer una llamada AJAX para obtener horarios disponibles
        // Por ahora, simplemente habilitamos todos los horarios
        const horaSelect = document.getElementById('hora');
        if (!horaSelect) return;
        const options = horaSelect.querySelectorAll('option');
        
        options.forEach(option => {
            if (option.value) {
                option.disabled = false;
                option.style.color = '';
            }
        });
    }
    
    // Calcular precio dinámicamente
    const serviceRadios = document.querySelectorAll('input[name="servicio"]');
    const manosPiesCheckbox = document.getElementById('manos_pies');
    
    function updatePrice() {
        const selectedService = document.querySelector('input[name="servicio"]:checked');
        const manosPies = manosPiesCheckbox.checked;
        
        if (selectedService) {
            const prices = {
                'manicura': 25000,
                'pedicura': 30000,
                'nailart': 35000,
                'gel': 40000
            };
            
            let price = prices[selectedService.value];
            
            // Aplicar descuento si selecciona manos + pies
            if (manosPies && (selectedService.value === 'manicura' || selectedService.value === 'pedicura')) {
                price = price * 0.9; // 10% de descuento
            }
            
            // Mostrar precio (si hay un elemento para mostrarlo)
            const priceElement = document.getElementById('precio-total');
            if (priceElement) {
                priceElement.textContent = '$' + price.toLocaleString();
            }
        }
    }
    
    // Agregar listeners para actualizar precio
    serviceRadios.forEach(radio => {
        radio.addEventListener('change', updatePrice);
    });
    
    if (manosPiesCheckbox) {
        manosPiesCheckbox.addEventListener('change', updatePrice);
    }
    
    // Smooth scrolling para enlaces internos
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function (e) {
            e.preventDefault();
            const target = document.querySelector(this.getAttribute('href'));
            if (target) {
                target.scrollIntoView({
                    behavior: 'smooth',
                    block: 'start'
                });
            }
        });
    });
    
    // Animaciones al hacer scroll
    const observerOptions = {
        threshold: 0.1,
        rootMargin: '0px 0px -50px 0px'
    };
    
    const observer = new IntersectionObserver(function(entries) {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.style.opacity = '1';
                entry.target.style.transform = 'translateY(0)';
            }
        });
    }, observerOptions);
    
    // Observar elementos para animaciones
    document.querySelectorAll('.service-card, .technique-card, .info-card').forEach(card => {
        card.style.opacity = '0';
        card.style.transform = 'translateY(20px)';
        card.style.transition = 'opacity 0.6s ease, transform 0.6s ease';
        observer.observe(card);
    });

    // Price selector and calculator (página de precios)
    const priceCards = document.querySelectorAll('.price-card');
    const totalElement = document.getElementById('total-calculado');
    const countElement = document.getElementById('items-seleccionados');
    const clearButton = document.getElementById('limpiar-seleccion');

    if (priceCards.length && totalElement && countElement) {
        const formatCurrency = (n) => '$' + Number(n).toLocaleString('es-AR');

        const recalc = () => {
            let total = 0;
            let count = 0;
            document.querySelectorAll('.price-card.selected').forEach(c => {
                const price = Number(c.getAttribute('data-price')) || 0;
                total += price;
                count += 1;
            });
            totalElement.textContent = formatCurrency(total);
            countElement.textContent = `${count} seleccionados`;
        };

        priceCards.forEach(card => {
            card.addEventListener('click', () => {
                card.classList.toggle('selected');
                recalc();
            });
        });

        if (clearButton) {
            clearButton.addEventListener('click', () => {
                document.querySelectorAll('.price-card.selected').forEach(c => c.classList.remove('selected'));
                recalc();
            });
        }

        // Initial calc
        recalc();
    }
});

// Funciones globales
function hideSuccessMessage() {
    const successMessage = document.getElementById('successMessage');
    if (successMessage) {
        successMessage.style.display = 'none';
    }
}
