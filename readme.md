# Redfish API Bash 腳本與 BusyBox httpd CGI 配置

這個 Bash 腳本旨在調用 Redfish API 並對返回的 JSON 數據進行處理，將其中的 `@odata.id` 轉換為可點擊的 HTML 鏈接。此外，本文還將介紹如何使用 BusyBox 的 httpd 作為 CGI 伺服器。

## 環境需求

- Bash
- awk
- sed
- BusyBox

## 安裝Busybox
```bash

apt install busybox

```
### Bash 腳本

1. 確保你的系統已經安裝了上述環境需求。
2. 建立資料夾: /var/www/cgi-bin/
    ```bash
    mkdir -p /var/www/cgi-bin/
    ```
3. 下載 `libRedfish.sh` 和 `index.sh` 到 `/var/www/cgi-bin`。
4. 為 `/var/www/cgi-bin/index.sh` 添加執行權限：

   ```bash
   chmod +x /var/www/cgi-bin/index.sh
   ```
### BusyBox httpd CGI
安裝 BusyBox 並確保 httpd 功能可用。
#### 方法一
在當前配置目錄中創建一個 httpd.conf 檔案（如果尚未存在）。

在 httpd.conf 中添加以下行以啟用 CGI：
這會將 /cgi-bin 映射到 /var/www/cgi-bin 目錄。

啟動或重新啟動 BusyBox httpd：

```bash
busybox httpd -p 8081
```
這會在端口 8081 啟動 httpd 服務。
#### 方法二
執行命令如下
```bash
busybox httpd -f -p 8080 -h /var/www/
```
### 如何使用
打開瀏覽器並訪問以下網址（替換 localhost 和 8081 為實際的主機和端口）：
```bash
http://localhost:8081/cgi-bin/index.sh?BMC_IP=<Your_BMC_IP>&API_PATH=<Your_API_PATH>
# example: http://localhost:8081/cgi-bin/index.sh?BMC_IP=172.70.8.127
```

* 您可能會需要先設置ssh tunnel以便在本機(localhost)訪問
![image](https://user-images.githubusercontent.com/7022841/271929963-b96ef093-65fb-44cd-8c35-8a8fbf37d4b1.png)

* URL參數說明
- BMC_IP: 目標 BMC 的 IP 地址。
- API_PATH: 要訪問的 Redfish API 路徑（不含 /redfish/v1）。
- 瀏覽器將顯示處理過的 JSON 數據，其中的 @odata.id 已轉換為可點擊的 HTML 鏈接。


