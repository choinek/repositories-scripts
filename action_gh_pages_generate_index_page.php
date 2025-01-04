<?php

$directories = array_filter(glob('./*-scripts'), 'is_dir');
$downloadItems = [];
$repositoryDocs = '';

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

    $downloadItems[] = [
        'url' => "https://choinek.github.io/repositories-scripts/download/$dir.zip",
        'name' => $dir,
        'description' => trim($description),
        'totalSize' => $totalSize,
        'files' => $files,
    ];
}

if (is_file('README.md')) {
    $repositoryDocs .= "<h3>README.md</h3><pre><code>" . htmlspecialchars(file_get_contents('README.md')) . "</code></pre>";
}

if (is_file('LICENSE')) {
    $repositoryDocs .= "<h3>LICENSE</h3><pre><code>" . htmlspecialchars(file_get_contents('LICENSE')) . "</code></pre>";
}

$buildDate = date('Y-m-d H:i:s');
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>choinek/scripts</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/water.css@2/out/water.min.css">
    <style>
        header {
            background-color: var(--background-alt);
            color: var(--text-bright);
            padding: 1.5em;
            text-align: center;
            border-bottom: 2px solid var(--border);
        }
        header h1 {
            margin: 0;
            font-size: 2.5em;
            font-weight: bold;
        }
        header p {
            margin: 0.5em 0;
            font-size: 1em;
            color: var(--text-muted);
        }
        details {
            margin-bottom: 1em;
        }
        summary {
            font-weight: bold;
        }
        pre code {
            display: block;
            padding: 1em;
            border-radius: 4px;
            font-family: monospace;
        }
        .description-box {
            max-height: 200px;
            overflow-y: auto;
            position: relative;
        }

        .description-box::after {
            content: '⬆ Scroll for more ⬇';
            position: absolute;
            bottom: 5px;
            right: 10px;
            font-size: 0.8em;
            color: #888;
        }

        footer {
            background-color: var(--background-alt);
            color: var(--text-main);
            margin-top: 2em;
            padding: 1em;
            text-align: center;
            border-top: 2px solid var(--border);
        }
        footer .footer-container {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 1em;
        }
        footer .footer-container img {
            width: 50px;
            height: 50px;
            border-radius: 50%;
        }
    </style>
</head>
<body>
<header>
    <h1>choinek/scripts</h1>
    <p>Build Date: <?= $buildDate ?></p>
</header>

<p>This is a collection of useful scripts programmers working like Choinek. :-) Use the command below to install some of them:</p>
<pre><code>curl -sL https://choinek.github.io/scripts/download/install.sh | bash</code></pre>

<h2>Available Script Groups</h2>
<div>
    <?php foreach ($downloadItems as $item): ?>
        <details>
            <summary style="width:100%"><?= basename($item['name']) ?></summary>
            <div>
                <table>
                    <tbody>
                    <tr>
                        <th scope="row" style="width: 20%">File</th>
                        <td><a href="<?= $item['url'] ?>"><?= basename($item['name']) ?>.zip [Download]</a></td>
                    </tr>
                    <tr>
                        <th scope="row" style="width: 20%">Size</th>
                        <td><?= number_format($item['totalSize'] / 1024, 2) ?> KB</td>
                    </tr>
                    <tr>
                        <th scope="row" style="width: 20%">Files</th>
                        <td>
                            <ul>
                                <?php foreach ($item['files'] as $file): ?>
                                    <li><?= htmlspecialchars($file['name']) ?> (<?= number_format($file['size'] / 1024, 2) ?> KB)</li>
                                <?php endforeach; ?>
                            </ul>
                        </td>
                    </tr>
                    <tr>
                        <th scope="row" style="width: 20%">Description</th>
                        <td>
                                    <pre class="description-box">
                                        <code><?= nl2br(htmlspecialchars($item['description'])) ?></code>
                                    </pre>
                        </td>
                    </tr>
                    </tbody>
                </table>
            </div>
        </details>
    <?php endforeach; ?>
</div>
<h2>Repository Information</h2>
<?= $repositoryDocs ?>
<footer>
    <div class="footer-container">
        <img src="https://github.com/choinek.png" alt="GitHub Avatar">
        <div>
            <p style="margin: 0; font-weight: bold;">Adrian Chojnicki</p>
            <p style="margin: 0;">
                <a href="https://github.com/choinek" target="_blank">GitHub</a>
                <span>|</span>
                <a href="https://www.linkedin.com/in/adrian-chojnicki-82438583/" target="_blank">LinkedIn</a>
            </p>
        </div>
    </div>
</footer>
</body>
</html>
