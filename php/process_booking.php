<?php
// Configuración de la base de datos
$host = 'mysql';
$dbname = 'nailstudio';
$username = 'nailstudio_user';
$password = 'nailstudio_pass';

try {
    // Conexión a la base de datos
    $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    // Verificar si es una solicitud POST
    if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        
        // Validar y sanitizar datos
        $nombre = filter_input(INPUT_POST, 'nombre', FILTER_SANITIZE_STRING);
        $telefono = filter_input(INPUT_POST, 'telefono', FILTER_SANITIZE_STRING);
        $email = filter_input(INPUT_POST, 'email', FILTER_VALIDATE_EMAIL);
        $edad = filter_input(INPUT_POST, 'edad', FILTER_VALIDATE_INT);
        $servicio = filter_input(INPUT_POST, 'servicio', FILTER_SANITIZE_STRING);
        $fecha = filter_input(INPUT_POST, 'fecha', FILTER_SANITIZE_STRING);
        $hora = filter_input(INPUT_POST, 'hora', FILTER_SANITIZE_STRING);
        $comentarios = filter_input(INPUT_POST, 'comentarios', FILTER_SANITIZE_STRING);
        
        // Opciones adicionales
        $manos_pies = isset($_POST['manos_pies']) ? 1 : 0;
        $diseño_especial = isset($_POST['diseño_especial']) ? 1 : 0;
        $primera_vez = isset($_POST['primera_vez']) ? 1 : 0;
        
        // Validaciones básicas
        $errors = [];
        
        if (empty($nombre)) {
            $errors[] = "El nombre es requerido";
        }
        
        if (empty($telefono)) {
            $errors[] = "El teléfono es requerido";
        }
        
        if (empty($servicio)) {
            $errors[] = "Debe seleccionar un servicio";
        }
        
        if (empty($fecha)) {
            $errors[] = "La fecha es requerida";
        }
        
        if (empty($hora)) {
            $errors[] = "La hora es requerida";
        }
        
        // Validar fecha (no puede ser anterior a hoy)
        if (!empty($fecha) && strtotime($fecha) < strtotime('today')) {
            $errors[] = "La fecha no puede ser anterior a hoy";
        }
        
        // Si hay errores, devolverlos
        if (!empty($errors)) {
            http_response_code(400);
            echo json_encode(['success' => false, 'errors' => $errors]);
            exit;
        }
        
        // Calcular precio
        $precios = [
            'manicura' => 25000,
            'pedicura' => 30000,
            'nailart' => 35000,
            'gel' => 40000
        ];
        
        $precio_base = $precios[$servicio] ?? 0;
        
        // Aplicar descuento si selecciona manos + pies
        if ($manos_pies && ($servicio === 'manicura' || $servicio === 'pedicura')) {
            $precio_base = $precio_base * 0.9; // 10% de descuento
        }
        
        // Insertar en la base de datos
        $sql = "INSERT INTO turnos (
            nombre, telefono, email, edad, servicio, fecha, hora, 
            manos_pies, diseño_especial, primera_vez, comentarios, precio, 
            fecha_creacion, estado
        ) VALUES (
            :nombre, :telefono, :email, :edad, :servicio, :fecha, :hora,
            :manos_pies, :diseño_especial, :primera_vez, :comentarios, :precio,
            NOW(), 'pendiente'
        )";
        
        $stmt = $pdo->prepare($sql);
        $result = $stmt->execute([
            ':nombre' => $nombre,
            ':telefono' => $telefono,
            ':email' => $email,
            ':edad' => $edad,
            ':servicio' => $servicio,
            ':fecha' => $fecha,
            ':hora' => $hora,
            ':manos_pies' => $manos_pies,
            ':diseño_especial' => $diseño_especial,
            ':primera_vez' => $primera_vez,
            ':comentarios' => $comentarios,
            ':precio' => $precio_base
        ]);
        
        if ($result) {
            $turno_id = $pdo->lastInsertId();
            
            // Preparar datos para respuesta
            $response = [
                'success' => true,
                'message' => 'Turno reservado exitosamente',
                'turno_id' => $turno_id,
                'datos' => [
                    'nombre' => $nombre,
                    'telefono' => $telefono,
                    'servicio' => $servicio,
                    'fecha' => $fecha,
                    'hora' => $hora,
                    'precio' => $precio_base
                ]
            ];
            
            // Enviar respuesta JSON
            header('Content-Type: application/json');
            echo json_encode($response);
            
        } else {
            throw new Exception('Error al insertar el turno en la base de datos');
        }
        
    } else {
        // Si no es POST, devolver error
        http_response_code(405);
        echo json_encode(['success' => false, 'message' => 'Método no permitido']);
    }
    
} catch (PDOException $e) {
    // Error de base de datos
    http_response_code(500);
    echo json_encode([
        'success' => false, 
        'message' => 'Error de base de datos: ' . $e->getMessage()
    ]);
} catch (Exception $e) {
    // Otros errores
    http_response_code(500);
    echo json_encode([
        'success' => false, 
        'message' => 'Error: ' . $e->getMessage()
    ]);
}
?>
