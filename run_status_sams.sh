#!/bin/bash

sudo touch /home/gor/f.text

chmod 777 /home/gor/f.text

echo "Content-type: text/html"
echo ""

erts_version=$(grep 'ERTS_VSN' /opt/butler_server/bin/butler_server | head -n 1 | cut -d '"' -f2)

# Run the script
sudo /opt/butler_server/erts-"$erts_version"/bin/escript /home/gor/SystemIdle/data.escript > /home/gor/f.txt 2>&1

# Generate table content
DIR="/home/gor/SystemIdle/texts/"
echo "<table><tr><th>CHECKLIST</th><th>STATUS</th><th>DETAILS</th></tr>"
for file in "$DIR"/*; do
    [[ -f "$file" ]] || continue
    filename=$(basename "$file")
    content=$(cat "$file" 2>/dev/null)

    # Special handling for Data files
    if [[ "$filename" == "Data-Sanity-MHS" && "$content" == "[{data_domain,{result,true}},{data_sanity,{result,true}}]" ]]; then
        status="<span class='tick'>&#10004;</span>"
        info=""
    elif [[ "$filename" == "Data-Sanity-Validate" && "$content" == "true" ]]; then
        status="<span class='tick'>&#10004;</span>"
        info=""
    elif [[ ! -s "$file" ]]; then
        status="<span class='tick'>&#10004;</span>"
        info=""
    else
        first_line=$(head -n1 "$file")
        if [[ "$first_line" == "0" ]]; then
            status="<span class='tick'>&#10004;</span>"
            info=""
        else
            status="<span class='cross'>&#10008;</span>"
            escaped_content=$(cat "$file" | sed ':a;N;$!ba;s/\n/\\n/g; s/"/\\"/g')
            info="<button class='info-btn' onclick='showPopup(\"$filename\", \"$escaped_content\")'>Info</button>"
        fi
    fi

    echo "<tr><td>$filename</td><td>$status</td><td>$info</td></tr>"
done
echo "</table>"


sudo chmod -R 777 SystemIdle
sudo mkdir /home/gor/SystemIdle/back_data
sudo chmod 777 /home/gor/SystemIdle/back_data
sudo tar -cf "/home/gor/SystemIdle/back_data/$(date +"%Y-%m-%d_%H-%M-%S")_backup_data.tar" -C /home/gor/SystemIdle/texts .
rm /home/gor/SystemIdle/texts/*
