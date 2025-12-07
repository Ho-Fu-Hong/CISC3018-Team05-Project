<?php



header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *'); 



$dataType = isset($_GET['type']) ? $_GET['type'] : '';



$dataPath = '../assets/data_all_records_new.json';



if ($dataType === 'all_new') {

    $dataPath = '../assets/data_all_records_new.json'; 
} else {

    http_response_code(400);
    echo json_encode(['error' => 'Invalid data type requested or unsupported type. Only "all_new" is supported.']);
    exit;
}



if (!file_exists($dataPath)) {
    http_response_code(404);
    echo json_encode(['error' => 'Data file not found at: ' . $dataPath]); 
    exit;
}



$jsonContent = file_get_contents($dataPath);


if ($jsonContent === false) {
    http_response_code(500);

    echo json_encode(['error' => 'Failed to read data file (permissions or path error). Check Apache error logs: /var/log/apache2/error.log']);
    exit;
}

$data = json_decode($jsonContent, true);


if ($data === null && json_last_error() !== JSON_ERROR_NONE) {

    http_response_code(500);
    echo json_encode(['error' => 'Error parsing JSON data.']);
    exit;
}



echo json_encode($data);
?>



