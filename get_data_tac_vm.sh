#!/bin/bash

echo "Content-type: text/html"
echo ""

# HTML Structure
cat <<EOL
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>System Idle Checklist</title>
<style>
  * {
    box-sizing: border-box;
    margin: 0;
    padding: 0;
}

body {
    font-family: 'Arial', sans-serif;
    background: linear-gradient(135deg, #2c2c2c, #3d3d3d);
    color: white;
    text-align: center;
    display: flex;
    flex-direction: column;
    align-items: center;
    height: 100vh;
    overflow: hidden;
}

.header {
    position: fixed;
    top: 0;
    width: 100%;
    background: rgba(51, 51, 51, 0.9);
    padding: 20px 0;
    text-align: center;
    box-shadow: 0 4px 10px rgba(0, 0, 0, 0.2);
    backdrop-filter: blur(10px);
    z-index: 1000;
}

h1 {
    font-size: 24px;
    font-weight: bold;
    color: #ff8c00;
    letter-spacing: 1px;
}

.search-box {
    margin-top: 10px;
}

.search-box input {
    padding: 12px;
    width: 320px;
    border: none;
    border-radius: 25px;
    font-size: 16px;
    text-align: center;
    outline: none;
    background: rgba(255, 140, 0, 0.2);
    color: white;
    backdrop-filter: blur(5px);
    border: 1px solid rgba(255, 140, 0, 0.5);
}

.search-box input::placeholder {
    color: #bbb;
}

.scroll-container {
    margin-top: 120px; /* Space below fixed header */
    height: calc(100vh - 130px); /* Adjust height to fit remaining screen */
    overflow-y: auto;
    width: 100%;
    display: flex;
    justify-content: center;
    padding-top: 10px;
}

.container {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(180px, 1fr));
    gap: 15px;
    max-width: 1000px;
    justify-content: center;
    width: 90%;
    grid-auto-rows: min-content;
    padding-bottom: 20px;
}

.tile {
    background: #444;
    padding: 20px;
    border-radius: 12px;
    text-decoration: none;
    color: white;
    height: 140px; 
    font-size: 18px;
    font-weight: bold;
    box-shadow: 0 5px 15px rgba(0, 0, 0, 0.2);
    transition: all 0.3s ease-in-out;
    display: flex;
    flex-direction: column;
    align-items: center;
    border: 2px solid transparent;
}

.tile:hover {
    transform: translateY(-5px);
    box-shadow: 0 10px 25px rgba(255, 140, 0, 0.5);
    background: rgba(70, 70, 70, 0.95);
    border-color: rgba(255, 140, 0, 0.7);
}

.tile img {
    width: 60px;
    height: auto;
    margin-bottom: 10px;
    border: 1px solid rgba(255, 140, 0, 0.3);
    background: rgba(255, 255, 255, 0.1);
}
</style>
</head>
<body>

<div class="header">
    <h1>System Idle Checklist</h1>
    <div class="search-box">
        <input type="text" id="search" placeholder="Search sites..." onkeyup="filterSites()">
    </div>
</div>

<div class="scroll-container">
    <div class="container" id="site-container">
EOL

# Read and sort sites alphabetically by site name (2nd column)
sort -t '|' -k2 /usr/lib/cgi-bin/SystemIdle/sites.txt | while IFS='|' read -r url name icon; do
    echo "<a href=\"$url\" class=\"tile\" target=\"_blank\" data-name=\"$name\">"
    echo "  <img src=\"$icon\" alt=\"$name Icon\">"
    echo "  $name"
    echo "</a>"
done

# Close HTML
cat <<EOL
    </div>
</div>

<script>
function filterSites() {
    let input = document.getElementById("search").value.toLowerCase();
    let tiles = document.getElementsByClassName("tile");
    for (let i = 0; i < tiles.length; i++) {
        let name = tiles[i].getAttribute("data-name").toLowerCase();
        tiles[i].style.display = name.includes(input) ? "flex" : "none"; // Remove element entirely
    }
}
</script>

</body>
</html>
EOL
