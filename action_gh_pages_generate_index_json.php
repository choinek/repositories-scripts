<?php

$directories = array_filter(glob('./*-scripts'), 'is_dir');
$output = [];

foreach ($directories as $dir) {
    $basename = basename($dir);
    $readmePath = "$dir/README.md";
    $description = is_file($readmePath) ? file_get_contents($readmePath) : "Missing $dir/README.md file.";

    $iterator = new RecursiveIteratorIterator(
        new RecursiveDirectoryIterator($dir, FilesystemIterator::SKIP_DOTS)
    );

    $files = [];
    $totalSize = 0;
    /** @var SplFileInfo $file */
    foreach ($iterator as $file) {
        $size = filesize($file->getPathname());
        $totalSize += $size;
        $files[] = [
            'name' => $file->getFilename(),
            'size' => $size,
            'checksum' => hash_file('sha256', $file->getPathname())
        ];
    }

    $output[] = [
        'name' => $basename,
        'url' => "https://choinek.github.io/repositories-scripts/download/$basename.zip",
        'description' => trim($description),
        'totalSize' => $totalSize,
        'files' => $files,
    ];
}


echo json_encode($output, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES);
