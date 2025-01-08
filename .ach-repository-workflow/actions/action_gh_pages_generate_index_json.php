<?php

// ! Run this script from directory containing script groups
// ! e.g. ./.ach-repository-workflow/actions/action_gh_pages_prepare_zip_script_groups.sh

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

    // check if zip was builded in public/download
    $zipPath = "./public/download/$basename.zip";
    $zipMissing = !is_file($zipPath);

    $output[] = [
        'name' => $basename,
        'url' => "https://choinek.github.io/repositories-scripts/download/$basename.zip",
        'zipMissing' => $zipMissing,
        'checksum' => $zipMissing ? '' : hash_file('sha256', $zipPath),
        'description' => trim($description),
        'totalSize' => $totalSize,
        'files' => $files,
    ];
}


echo json_encode($output, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES);
