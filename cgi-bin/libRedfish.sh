#!/bin/bash

# 設置基本環境變量
USERNAME="root"
PASSWORD="0penBmc"
VALID_OPERATIONS=("GET" "POST" "PUT" "DELETE" "PATCH")

# 將 JSON 字串解包以獲取特定字段
unpack_json() {
  local json_content="$1"

  # 判斷是否包含 'Members' 鍵並且該鍵的值為陣列
  if echo "$json_content" | jq -e '.Members | type=="array"' &>/dev/null; then
    echo "$json_content" | jq -r '.Members[]["@odata.id"]' | sed 's#/redfish/v1/##g'
  # 增加更多的條件來處理其他類型的 JSON 結構
  elif echo "$json_content" | jq -e '.data | type=="object"' &>/dev/null; then
    echo "$json_content" | jq -r '.data.id'
  else
    # 如果不符合以上條件，則原封不動地返回 JSON 內容
    echo "$json_content"
  fi
}

# 檢查指定的操作是否合法
is_valid_operation() {
  local operation=$1
  for valid in "${VALID_OPERATIONS[@]}"; do
    if [[ $operation == $valid ]]; then
      return 0
    fi
  done
  return 1
}

# 使用 curl 執行 Redfish 操作
perform_redfish_operation() {
  local operation=$1
  local ip=$2
  local url_path=$3
  local data=$4

  if ! is_valid_operation "$operation"; then
    echo "不合法的操作：$operation"
    return 1
  fi

  local url="https://${ip}/redfish/v1/${url_path}"
  local cmd="curl -s -k -u \"$USERNAME:$PASSWORD\" -X $operation"

  [[ ! -z "$data" ]] && cmd="$cmd -d \"$data\""

  eval "$cmd \"$url\""
}

# 獲取內容並根據需要解包 JSON
fetch_and_unpack() {
  local result=$( "$@" )
  unpack_json "$result"
}

