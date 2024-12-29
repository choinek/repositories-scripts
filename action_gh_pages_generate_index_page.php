<?php

$directories = array_filter(glob('*'), 'is_dir');
$downloadItems = [];
$repositoryDocs = '';

foreach ($directories as $dir) {
    if ($dir === 'public') {
        continue;
    }

    $readmePath = "$dir/README.md";
    $description = is_file($readmePath) ? fgets(fopen($readmePath, 'r')) : 'No description available';
    $downloadItems[] = [
        'file' => "download/$dir.zip",
        'name' => $dir,
        'description' => trim($description),
    ];

    if (is_file($readmePath)) {
        $repositoryDocs .= "<h3>{$dir} README</h3>" . nl2br(file_get_contents($readmePath));
    }
}

if (is_file('README.md')) {
    $repositoryDocs .= "<h3>README</h3>" . nl2br(file_get_contents('README.md'));
}

if (is_file('LICENSE')) {
    $repositoryDocs .= "<h3>LICENSE</h3>" . nl2br(file_get_contents('LICENSE'));
}
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>choinek/repository-scripts</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/water.css/out/water.css">
</head>
<body>
<h1>choinek/repository-scripts</h1>
<p>This is a collection of useful scripts for managing repositories. Use the command below to install:</p>
<pre>
curl -sL https://choinek.github.io/repository-scripts/download/install.sh | bash
    </pre>
<h2>Available Downloads</h2>
<ul>
    <?php foreach ($downloadItems as $item): ?>
        <li>
            <a href="<?= $item['file'] ?>"><?= $item['name'] ?>.zip</a> - <?= htmlspecialchars($item['description']) ?>
        </li>
    <?php endforeach; ?>
</ul>
<h2>Repository Documentation</h2>
<?= $repositoryDocs ?>
</body>
</html>
