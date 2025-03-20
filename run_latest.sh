#!/bin/bash

sudo touch /home/gor/f.txt
sudo chmod 777 /home/gor/f.txt

echo "Content-type: text/html"
echo ""

erts_version=$(grep 'ERTS_VSN' /opt/butler_server/bin/butler_server | head -n 1 | cut -d '"' -f2)

# Run the script
sudo /opt/butler_server/erts-"$erts_version"/bin/escript /home/gor/SystemIdle/data.escript > /home/gor/f.txt 2>&1

# Define Groups
declare -A groups
groups["PICK"]="Pick-Instructions Pick-Bins"
groups["PUT"]="Put-Bins Put-Outputs"
groups["AUDIT"]="Active-Audits Pending-Approval Paused-Audits Created-Audits Active-Audit Audit-Tasks"
groups["ORDERS"]="Orders-Data Created-Orders"
groups["DATA_SANITY"]="DataSanity-MHS DataSanity-Domain"
groups["TASKS"]="PPS-Tasks Move-Tasks Post-Pick Rack-Storable"

# Generate Grouped Data
DIR="/home/gor/SystemIdle/texts/"
echo "<div class='group-container'>"

for group in "${!groups[@]}"; do
    echo "<details class='group'>"
    echo "  <summary class='group-summary'>$group</summary>"
    echo "  <div id='$group' class='group-content'>"
    echo "    <table><tr><th>CHECKLIST</th><th>STATUS</th><th>DETAILS</th></tr>"

    for file in ${groups[$group]}; do
        filepath="$DIR/$file"
        [[ -f "$filepath" ]] || continue
        content=$(cat "$filepath" 2>/dev/null)
        first_line=$(head -n1 "$filepath")

        # Determine Status
        if [[ ! -s "$filepath" ]] || [[ "$first_line" == "Count = 0" ]] || [[ "$content" == "Data = true" ]] || [[ "$content" == "Data = [{data_domain,{result,true}},{data_sanity,{result,true}}]" ]]; then
            status="<span class='tick'>&#10004;</span>"
            info=""
        else
            escaped_content=$(cat "$filepath" | sed ':a;N;$!ba;s/\n/\\n/g; s/"/\\"/g; s/'\''/\\'\''/g')
            status="<span class='cross'>&#10008;</span>"
            info="<button class='info-btn' onclick='showPopup(\"$file\", \"$escaped_content\")'>Info</button>"
        fi

        echo "<tr><td>$file</td><td>$status</td><td>$info</td></tr>"
    done

    echo "    </table>"
    echo "  </div>"
    echo "</details>"
done


echo "</div>"
