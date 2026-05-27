<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

include_once '../config/database.php';

$database = new Database();
$db = $database->getConnection();

$method = $_SERVER['REQUEST_METHOD'];
$id = isset($_GET['id']) ? intval($_GET['id']) : null;

if ($method === 'OPTIONS') { http_response_code(200); exit(); }

switch ($method) {
    case 'GET':
        if ($id) {
            $stmt = $db->prepare("SELECT * FROM items WHERE id = ?");
            $stmt->execute([$id]);
            $item = $stmt->fetch(PDO::FETCH_ASSOC);
            echo json_encode($item ?: ["message" => "Not found"]);
        } else {
            $stmt = $db->query("SELECT * FROM items ORDER BY id DESC");
            echo json_encode($stmt->fetchAll(PDO::FETCH_ASSOC));
        }
        break;

    case 'POST':
        $data = json_decode(file_get_contents("php://input"), true);
        $stmt = $db->prepare("INSERT INTO items (name, description) VALUES (?, ?)");
        if ($stmt->execute([$data['name'], $data['description']])) {
            http_response_code(201);
            echo json_encode(["message" => "Item created", "id" => $db->lastInsertId()]);
        }
        break;

    case 'PUT':
        $data = json_decode(file_get_contents("php://input"), true);
        $stmt = $db->prepare("UPDATE items SET name=?, description=? WHERE id=?");
        if ($stmt->execute([$data['name'], $data['description'], $id])) {
            echo json_encode(["message" => "Item updated"]);
        }
        break;

    case 'DELETE':
        $stmt = $db->prepare("DELETE FROM items WHERE id=?");
        if ($stmt->execute([$id])) {
            echo json_encode(["message" => "Item deleted"]);
        }
        break;
}
?>