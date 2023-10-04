#!/bin/bash
source /var/www/cgi-bin/libRedfish.sh

# 顯示內容類型（這裏是 HTML）
echo "Content-type: text/html"
echo ""

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
echo "$redfish_output_with_links"
