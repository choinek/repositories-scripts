<?php

// ! Run this script from directory containing script groups
// ! e.g. ./.ach-repository-workflow/actions/action_gh_pages_prepare_zip_script_groups.sh

$directories = array_filter(glob('./*-scripts'), 'is_dir');
$downloadItems = [];
$repositoryDocs = '';

foreach ($directories as $dir) {
    $zipPath = "./public/download/$dir.zip";
    if (!is_file($zipPath)) {
        continue;
    }
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
        'checksum' => hash_file('sha256', $zipPath),
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
        body {
            max-width:900px;
        }
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

        .code-container {
            padding: 0;
            position: relative;
            margin: 1em 0;
        }

        .code-header {
            background: #1c1c1c;
            color: #ffffff;
            padding: 0.7em;
            font-family: "Fira Code", monospace;
            font-weight: bold;
            font-size: 0.7em;
            text-align: left;
            margin: 0;
            border-radius: 8px 8px 0 0;
        }

        .code-block {
            background: #2d2d2d;
            color: #ffffff;
            padding: 1.5em;
            font-family: "Fira Code", monospace;
            font-size: 0.6em;
            overflow-x: auto;
            white-space: pre-wrap;
            word-wrap: break-word;
            margin: 0;
            border-radius: 0 0 8px 8px;
        }

        .copy-btn {
            position: absolute;
            top: 4px;
            right: 1px;
            background: #007bff;
            color: #ffffff;
            border: none;
            padding: 0.5em 1em;
            font-size: 0.7em;
            border-radius: 4px;
            cursor: pointer;
        }

        .copy-btn:active {
            background: #0056b3;
        }

        .copy-btn:disabled {
            background: #6c757d;
            cursor: not-allowed;
        }
    </style>

    <script>
        function initScripts() {
            fetch('https://choinek.github.io/scripts/index.json')
                .then(response => response.json())
                .then(data => {
                    const container = document.querySelector('body > div');
                    container.innerHTML = '';

                    data.forEach(group => {
                        const details = document.createElement('details');
                        details.setAttribute('open', '');

                        const summary = document.createElement('summary');
                        summary.style.width = '100%';
                        summary.textContent = group.name;
                        details.appendChild(summary);

                        const table = document.createElement('table');
                        const tbody = document.createElement('tbody');

                        // File row for ZIP
                        const fileRow = document.createElement('tr');
                        const fileHeader = document.createElement('th');
                        fileHeader.scope = 'row';
                        fileHeader.style.width = '15%';
                        fileHeader.textContent = 'File';
                        const fileData = document.createElement('td');
                        const fileLink = document.createElement('a');
                        fileLink.href = group.url;
                        fileLink.textContent = `${group.name}.zip [Download]`;
                        fileData.appendChild(fileLink);
                        fileRow.appendChild(fileHeader);
                        fileRow.appendChild(fileData);
                        tbody.appendChild(fileRow);

                        // Checksum row for ZIP
                        const zipChecksumRow = document.createElement('tr');
                        const zipChecksumHeader = document.createElement('th');
                        zipChecksumHeader.scope = 'row';
                        zipChecksumHeader.style.width = '15%';
                        zipChecksumHeader.textContent = 'Checksum';
                        const zipChecksumData = document.createElement('td');
                        zipChecksumData.textContent = group.checksum || 'N/A'; // Add checksum for ZIP if available
                        zipChecksumRow.appendChild(zipChecksumHeader);
                        zipChecksumRow.appendChild(zipChecksumData);
                        tbody.appendChild(zipChecksumRow);

                        const filesRow = document.createElement('tr');
                        const filesHeader = document.createElement('th');
                        filesHeader.scope = 'row';
                        filesHeader.style.width = '15%';
                        filesHeader.textContent = 'Files';
                        const filesData = document.createElement('td');
                        const fileList = document.createElement('ul');
                        group.files.forEach(file => {
                            const listItem = document.createElement('li');
                            listItem.innerHTML = `
    ${file.name} (${(file.size / 1024).toFixed(2)} KB)
    <br>
    <code>sha256:${file.checksum}</code>
    <div class="code-container">
        <div class="code-header">Bash Script</div>
        <pre class="code-block" id="copy-${file.checksum}">
curl -f -o script.sh https://raw.githubusercontent.com/choinek/script/${file.path} && \\
echo "${file.checksum}" | sha256sum -c \\
&& echo "checksum checked" || echo "checksum verification failed"</pre>
        <button class="copy-btn" onclick="copyCode('copy-${file.checksum}')">Copy</button>
    </div>
    `;
                            fileList.appendChild(listItem);
                        });
                        filesData.appendChild(fileList);
                        filesRow.appendChild(filesHeader);
                        filesRow.appendChild(filesData);
                        tbody.appendChild(filesRow);

                        // Description row
                        const descriptionRow = document.createElement('tr');
                        const descriptionHeader = document.createElement('th');
                        descriptionHeader.scope = 'row';
                        descriptionHeader.style.width = '15%';
                        descriptionHeader.textContent = 'Description';
                        const descriptionData = document.createElement('td');
                        const descriptionBox = document.createElement('pre');
                        descriptionBox.className = 'description-box';
                        const descriptionCode = document.createElement('code');
                        descriptionCode.innerHTML = group.description.replace(/\n/g, '<br>');
                        descriptionBox.appendChild(descriptionCode);
                        descriptionData.appendChild(descriptionBox);
                        descriptionRow.appendChild(descriptionHeader);
                        descriptionRow.appendChild(descriptionData);
                        tbody.appendChild(descriptionRow);

                        table.appendChild(tbody);
                        details.appendChild(table);
                        container.appendChild(details);
                    });
                })
                .catch(error => console.error('Error loading scripts:', error));

        }

        function copyCode(elementId) {
            const code = document.getElementById(elementId).innerText;
            navigator.clipboard.writeText(code).then(() => {
                alert('Code copied to clipboard!');
            }).catch(err => {
                console.error('Error copying code:', err);
                alert('Failed to copy code. Please try again.');
            });
        }

        initScripts();

    </script>

</head>
<body>
<header>
    <h1>choinek/scripts</h1>
    <p>Build Date: <?= $buildDate ?></p>
</header>

<p>This is a collection of useful scripts programmers working like Choinek. :-) Use the command below to install some of
    them:</p>

<h2>Available Script Groups</h2>
<div>
    <?php foreach ($downloadItems as $item): ?>
        <details>
            <summary style="width:100%"><?= basename($item['name']) ?></summary>
            <div>
                <table>
                    <tbody>
                    <tr>
                        <th scope="row" style="width: 15%">File</th>
                        <td><a href="<?= $item['url'] ?>"><?= basename($item['name']) ?>.zip [Download]</a></td>
                    </tr>
                    <tr>
                        <th scope="row" style="width: 15%">Size</th>
                        <td><?= number_format($item['totalSize'] / 1024, 2) ?> KB</td>
                    </tr>
                    <tr>
                        <th scope="row" style="width: 15%">Files</th>
                        <td>
                            <ul>
                                <?php foreach ($item['files'] as $file): ?>
                                    <li><?= htmlspecialchars($file['name']) ?>
                                        (<?= number_format($file['size'] / 1024, 2) ?> KB)
                                    </li>
                                <?php endforeach; ?>
                            </ul>
                        </td>
                    </tr>
                    <tr>
                        <th scope="row" style="width: 15%">Description</th>
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
