<?php

$directories = array_filter(glob('*'), 'is_dir');
$output = [];

foreach ($directories as $dir) {
    if ($dir === 'public') {
        continue;
    }

    $readmePath = "$dir/README.md";
    $description = is_file($readmePath) ? fgets(fopen($readmePath, 'r')) : 'No description available';
    $files = array_map('basename', glob("$dir/**/*"));

    $output[] = [
        'file' => "download/$dir.zip",
        'name' => $dir,
        'description' => trim($description),
        'files' => $files,
    ];
}


echo json_encode($output, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES);
