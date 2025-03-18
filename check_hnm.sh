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
<title>System Idle Status</title>
<style>
  * { box-sizing: border-box; margin: 0; padding: 0; }
  body { font-family: 'Arial', sans-serif; background: #1e1e1e; color: white; text-align: center; }
  .header { width: 100%; background: #333; padding: 20px; text-align: center; }
  h1 { font-size: 24px; font-weight: bold; color: #ff8c00; }

  /* Confirmation Box */
  .confirmation-box { margin-top: 20px; padding: 20px; background: #222; display: inline-block; border-radius: 8px; }
  .confirmation-box p { font-size: 18px; margin-bottom: 12px; }
  .confirm-btn { padding: 10px 15px; border: none; cursor: pointer; border-radius: 5px; font-size: 16px; }
  .yes-btn { background: green; color: white; }
  .no-btn { background: red; color: white; }

  /* Loading Bar */
  .loading-container { display: none; text-align: center; margin-top: 20px; }
  .loading-bar { width: 80%; height: 20px; background: #333; border-radius: 10px; margin: auto; position: relative; overflow: hidden; }
  .loading-bar span { display: block; height: 100%; width: 0%; background: #ff8c00; position: absolute; transition: width 0.5s; }

  /* Table Styling */
  .table-container { max-width: 900px; margin: 20px auto; overflow-x: auto; display: none; }
  table { width: 100%; border-collapse: collapse; margin-top: 10px; }
  th, td { padding: 12px; border: 1px solid #666; text-align: center; }
  th { background: #444; color: #ff8c00; }
  td { background: #222; color: white; }

  .tick { color: green; font-size: 20px; }
  .cross { color: red; font-size: 20px; }
  .info-btn { background: blue; color: white; padding: 5px 10px; border: none; cursor: pointer; border-radius: 5px; }

  /* Popup Modal */
  .popup { display: none; position: fixed; top: 50%; left: 50%;
           transform: translate(-50%, -50%); background: rgba(30, 30, 30, 0.95);
           color: white; padding: 20px; border-radius: 12px; box-shadow: 0px 5px 20px rgba(255, 165, 0, 0.3);
           min-width: 320px; max-width: 80vw; max-height: 70vh; overflow: auto; resize: both; }

  .popup-header { font-size: 20px; font-weight: bold; color: #ff9500; text-align: left;
                  border-bottom: 2px solid rgba(255, 165, 0, 0.5); padding-bottom: 5px; margin-bottom: 12px; }

  .popup-content { font-size: 15px; text-align: left; white-space: pre-wrap; word-wrap: break-word;
                   overflow-wrap: break-word; max-height: 50vh; overflow-y: auto; padding: 10px;
                   background: rgba(20, 20, 20, 0.9); border-radius: 8px; }

  .popup-close { display: block; width: 100%; background: linear-gradient(to right, #ff4500, #ff9500);
                 color: white; border: none; padding: 10px; margin-top: 12px; text-align: center;
                 font-weight: bold; cursor: pointer; border-radius: 8px; transition: all 0.3s ease-in-out; }

  .popup-close:hover { background: linear-gradient(to right, #ff6a00, #ffaa00); }

</style>
</head>
<body>

<div class="header">
    <h1>System Idle Status</h1>
</div>

<!-- Confirmation Box -->
<div class="confirmation-box" id="confirmation-box">
    <p>Do you want to check the system idle status?</p>
    <button class="confirm-btn yes-btn" onclick="startCheck()">Yes</button>
    <button class="confirm-btn no-btn" onclick="hideContent()">No</button>
</div>

<!-- Loading Bar -->
<div class="loading-container" id="loading-container">
    <p>Processing... Please wait</p>
    <div class="loading-bar"><span id="progress-bar"></span></div>
</div>

<!-- Table Container (Initially Hidden) -->
<div class="table-container" id="content"></div>

<!-- Popup Modal -->
<div id="popup" class="popup">
    <div class="popup-header" id="popup-title"></div>
    <div class="popup-content" id="popup-content"></div>
    <button class="popup-close" onclick="closePopup()">Close</button>
</div>

<script>
function startCheck() {
    document.getElementById("confirmation-box").style.display = "none";
    document.getElementById("loading-container").style.display = "block";

    let progress = 0;
    let interval = setInterval(() => {
        progress += 10;
        document.getElementById("progress-bar").style.width = progress + "%";
        if (progress >= 100) clearInterval(interval);
    }, 2000);

    fetch("/cgi-bin/run_status.sh")
        .then(response => response.text())
        .then(data => {
            clearInterval(interval);
            document.getElementById("loading-container").style.display = "none";
            document.getElementById("content").innerHTML = data;
            document.getElementById("content").style.display = "block";
        });
}

function hideContent() {
    document.getElementById("confirmation-box").innerHTML = "<p>You chose not to view the system status.</p>";
}

function showPopup(title, content) {
    document.getElementById("popup-title").innerText = title;
    document.getElementById("popup-content").innerHTML = content.replace(/\\n/g, "<br>");
    document.getElementById("popup").style.display = "block";
}

function closePopup() {
    document.getElementById("popup").style.display = "none";
}
</script>

</body>
</html>
EOL
