#!/bin/bash
set -x
source /var/www/cgi-bin/libRedfish.sh
set -x
# 顯示內容類型（這裏是 HTML）
#echo "Content-type: application/json"
echo "Content-type: text/html"
echo ""
echo "<html><head>"
echo "<link rel=\"stylesheet\" type=\"text/css\" href=\"../static/css/jquery.json-viewer.css\" />"
echo "<script src=\"https://code.jquery.com/jquery-3.5.1.min.js\"></script>"
echo "<script src=\"../static/js/jquery.json-viewer.js\"></script>"
echo "</head><body>"
# 解析 QUERY_STRING 以獲取 BMC_IP 和 API_PATH
query_string="$QUERY_STRING"

# 使用 awk 或其他文本處理工具解析查詢字符串
bmc_ip=$(echo "$query_string" | awk -F'[=&]' '{for(i=1;i<=NF;i++) if ($i=="BMC_IP") print $(i+1)}')
api_path=$(echo "$query_string" | awk -F'[=&]' '{for(i=1;i<=NF;i++) if ($i=="API_PATH") print $(i+1)}')

# 如果 bmc_ip 為空，返回錯誤信息
if [ -z "$bmc_ip" ]; then
  echo "Error: BMC_IP is not provided."
  exit 1
fi

# 調用您的 perform_redfish_operation 函數，並使用 sed 進行替換
redfish_output=$(perform_redfish_operation "GET" "$bmc_ip" "$api_path")

# 使用 sed 將 @odata.id 的值替換為包含 <a> 標籤的形式，並移除 "redfish/v1/"
redfish_output_with_links=$(echo "$redfish_output" | sed -E "s#(@odata\.id\": \")(/redfish/v1)?(/)([^\"]+)#\1<a href=\"index.sh?BMC_IP=${bmc_ip}\&API_PATH=\4\">\4</a>#g")

# 輸出
if [ ! -z "$$redfish_output_with_links" ];then
#    echo "$redfish_output_with_links"
    echo "<div id='json-renderer'></div>"
    echo "<script>"
    echo "var data=$redfish_output"
    echo "  \$('#json-renderer').jsonViewer(data);"
    echo "</script>"
    echo "<script>"
    echo "\$(document).ready(function(){"
    echo "  // 假設 bmc_ip 已經被設定"
    echo "  var bmc_ip = \"your_bmc_ip_here\";"
    echo ""
    echo "  \$(\".json-string\").each(function() {"
    echo "    var originalText = \$(this).text();"
    echo "    console.log(originalText);"
    echo "    // 如果原文本是 \\\"N/A\\\"，則跳過此次迴圈"
    echo "    if (originalText === \"N/A\") {"
    echo "      return true; // 繼續下一次迴圈"
    echo "    }"
    echo ""
    echo "    var match = originalText.match(/(\\/redfish\\/v1)?(\\/)([^\"]+)/);"
    echo ""
    echo "    if(match) {"
    echo "      var link = \`<a href=\\\"index.sh?BMC_IP=\${bmc_ip}&API_PATH=\${match[3]}\\\">\${match[3]}</a>\`;"
    echo "      var newText = originalText.replace(match[0], link);"
    echo "      \$(this).html(newText);"
    echo "    }"
    echo "  });"
    echo "});"
    echo "</script>"

    echo "<pre id=\"json-renderer\"></pre>"
   # 結束 HTML
    echo "</body></html>"
else
   echo "[Error] unexpected error occurred"
   echo "Debug: redfish_output = $redfish_output"
   echo "Debug: bmc_ip = $bmc_ip"
   echo "Debug: api_path = $api_path"

fi

