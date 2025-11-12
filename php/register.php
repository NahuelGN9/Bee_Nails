<?php
// Configuración de la base de datos
$host = 'mysql';
$dbname = 'nailstudio';
$username = 'nailstudio_user';
$password = 'nailstudio_pass';

header('Content-Type: application/json');

try {
    // Conexión a la base de datos
    $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    // Verificar si es una solicitud POST
    if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        
        // Validar y sanitizar datos
        $nombre = filter_input(INPUT_POST, 'nombre', FILTER_SANITIZE_STRING);
        $apellido = filter_input(INPUT_POST, 'apellido', FILTER_SANITIZE_STRING);
        $celular = filter_input(INPUT_POST, 'celular', FILTER_SANITIZE_STRING);
        $usuario = filter_input(INPUT_POST, 'usuario', FILTER_SANITIZE_STRING);
        $password = $_POST['password']; // No sanitizar contraseñas
        
        // Validaciones
        $errors = [];
        
        if (empty($nombre)) {
            $errors[] = "El nombre es requerido";
        }
        
        if (empty($apellido)) {
            $errors[] = "El apellido es requerido";
        }
        
        if (empty($celular)) {
            $errors[] = "El celular es requerido";
        } elseif (!preg_match('/^[0-9]{10}$/', $celular)) {
            $errors[] = "El celular debe tener 10 dígitos";
        }
        
        if (empty($usuario)) {
            $errors[] = "El usuario es requerido";
        }
        
        if (empty($password)) {
            $errors[] = "La contraseña es requerida";
        } elseif (strlen($password) < 6) {
            $errors[] = "La contraseña debe tener al menos 6 caracteres";
        }
        
        // Si hay errores, devolverlos
        if (!empty($errors)) {
            http_response_code(400);
            echo json_encode(['success' => false, 'message' => implode(', ', $errors)]);
            exit;
        }
        
        // Verificar si el usuario ya existe
        $stmt = $pdo->prepare("SELECT id FROM usuarios WHERE usuario = :usuario");
        $stmt->execute(['usuario' => $usuario]);
        
        if ($stmt->fetch()) {
            http_response_code(400);
            echo json_encode(['success' => false, 'message' => 'El nombre de usuario ya existe']);
            exit;
        }
        
        // Verificar si el celular ya existe
        $stmt = $pdo->prepare("SELECT id FROM usuarios WHERE celular = :celular");
        $stmt->execute(['celular' => $celular]);
        
        if ($stmt->fetch()) {
            http_response_code(400);
            echo json_encode(['success' => false, 'message' => 'Este número de celular ya está registrado']);
            exit;
        }
        
        // Hash de la contraseña
        $password_hash = password_hash($password, PASSWORD_DEFAULT);
        
        // Insertar usuario en la base de datos
        $sql = "INSERT INTO usuarios (
            nombre, apellido, celular, usuario, password, fecha_registro, activo
        ) VALUES (
            :nombre, :apellido, :celular, :usuario, :password, NOW(), 1
        )";
        
        $stmt = $pdo->prepare($sql);
        $result = $stmt->execute([
            ':nombre' => $nombre,
            ':apellido' => $apellido,
            ':celular' => $celular,
            ':usuario' => $usuario,
            ':password' => $password_hash
        ]);
        
        if ($result) {
            $user_id = $pdo->lastInsertId();
            
            $response = [
                'success' => true,
                'message' => 'Cuenta creada exitosamente',
                'user_id' => $user_id,
                'usuario' => $usuario
            ];
            
            echo json_encode($response);
            
        } else {
            throw new Exception('Error al insertar el usuario en la base de datos');
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
