@echo off

set "FOLDER_ID=1X6qsnvEuWLQZjOnLCN3ycqRan_2YphmK"
set "FOLDER_PATH=C:\Sinerji\Program"

set "CLIENT_JSON={\"installed\":{\"client_id\":\"1088244761912_	r315r7funp8ka5flfc26pihp7ronf5o0.apps.googleusercontent.com\",\"project_id\":\"groovy-bay-387819\",\"auth_uri\":\"https://accounts.google.com/o/oauth2/auth\",\"token_uri\":\"https://oauth2.googleapis.com/token\",\"auth_provider_x509_cert_url\":\"https://www.googleapis.com/oauth2/v1/certs\",\"client_secret\":\"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\",\"redirect_uris\":[\"http://localhost\"]}}"

:: Step 1: Authenticate and obtain an access token
powershell -Command "$secrets = $env:CLIENT_JSON | ConvertFrom-Json; $clientId = $secrets.installed.client_id; $clientSecret = $secrets.installed.client_secret; $redirectUri = 'urn:ietf:wg:oauth:2.0:oob'; $url = 'https://accounts.google.com/o/oauth2/auth?client_id=' + $clientId + '&redirect_uri=' + $redirectUri + '&scope=https://www.googleapis.com/auth/drive&response_type=code&access_type=offline'; Start-Process -NoNewWindow -FilePath $url; $code = Read-Host -Prompt 'Enter the authorization code:'; $tokenUrl = 'https://oauth2.googleapis.com/token'; $params = @{ code = $code; client_id = $clientId; client_secret = $clientSecret; redirect_uri = $redirectUri; grant_type = 'authorization_code' }; $tokenResponse = Invoke-RestMethod -Uri $tokenUrl -Method POST -Body $params; $accessToken = $tokenResponse.access_token; $refreshToken = $tokenResponse.refresh_token; $accessToken, $refreshToken | Out-File -Encoding ascii -FilePath 'tokens.txt'"

:: Step 2: Upload the folder
powershell -Command "$headers = @{ 'Authorization' = 'Bearer ' + (Get-Content -Raw -Path 'tokens.txt')[0]; 'Content-Type' = 'application/json' }; $uploadUrl = 'https://www.googleapis.com/upload/drive/v3/files?uploadType=multipart'; $body = '{ ''name'': ''%FOLDER_NAME%'', ''mimeType'': ''application/vnd.google-apps.folder'', ''parents'': [ ''%FOLDER_ID%'' ] }' -replace '%FOLDER_NAME%', $env:FOLDER_PATH.Substring($env:FOLDER_PATH.LastIndexOf('\') + 1); $response = Invoke-RestMethod -Uri $uploadUrl -Method POST -Headers $headers -Body $body; if ($response.id) { Write-Host 'Folder uploaded successfully!' } else { Write-Host 'Failed to upload folder' }"
