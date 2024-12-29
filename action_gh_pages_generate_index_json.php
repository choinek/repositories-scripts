<?php

$directories = array_filter(glob('./*-scripts'), 'is_dir');
$output = [];

foreach ($directories as $dir) {
    $readmePath = "$dir/README.md";
    $description = is_file($readmePath) ? file_get_contents($readmePath) : 'No description available';

    $iterator = new RecursiveIteratorIterator(
        new RecursiveDirectoryIterator($dir, FilesystemIterator::SKIP_DOTS)
    );

    $files = [];
    $totalSize = 0;
    foreach ($iterator as $file) {
        $size = filesize($file->getPathname());
        $totalSize += $size;
        $files[] = [
            'name' => $file->getFilename(),
            'size' => $size,
        ];
    }

    $output[] = [
        'file' => "https://choinek.github.io/repositories-scripts/download/$dir.zip",
        'name' => $dir,
        'description' => trim($description),
        'totalSize' => $totalSize,
        'files' => $files,
    ];
}


echo json_encode($output, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES);
