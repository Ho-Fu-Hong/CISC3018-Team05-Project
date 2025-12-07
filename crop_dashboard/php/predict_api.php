<?php
// /var/www/html/crop_dashboard/php/predict_api.php

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');


$python_executable = '../.venv/bin/python3'; 

$python_script = '../crop_yield_prediction.py'; 

// 1. Check for required parameters
$required_params = ['year', 'rainfall', 'pesticides', 'temp', 'country', 'crop'];
foreach ($required_params as $param) {
    if (!isset($_GET[$param])) {
        http_response_code(400);
        echo json_encode(['error' => "Missing parameter: $param"]);
        exit;
    }
}

// 2. Sanitize and prepare arguments for the command line
$year = escapeshellarg($_GET['year']);
$rainfall = escapeshellarg($_GET['rainfall']);
$pesticides = escapeshellarg($_GET['pesticides']);
$temp = escapeshellarg($_GET['temp']);
$country = escapeshellarg($_GET['country']);
$crop = escapeshellarg($_GET['crop']);

// 3. Construct the full command
$command = "{$python_executable} {$python_script} {$year} {$rainfall} {$pesticides} {$temp} {$country} {$crop} 2>&1";

// 4. Execute the command and capture output
$output = shell_exec($command);

// 5. Validate and return the JSON response
if ($output) {
    $result = json_decode($output, true);
    
    // Check if the Python script returned an internal error
    if ($result === null || isset($result['error'])) {
        http_response_code(500);
        // If Python failed, return the raw output or the internal error message
        echo json_encode(['error' => 'Prediction failed. Check Python script or model files.', 'details' => $output]);
    } else {
        // Success
        echo $output;
    }
} else {
    http_response_code(500);
    echo json_encode(['error' => 'Failed to execute Python script or empty output.']);
}
?>


