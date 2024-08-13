# Executar o comando reg query e capturar a saída
$regOutput = & reg query HKLM\System\CurrentControlSet\services\CSAgent\Sim\ /f AG

# Converter a saída em uma lista de linhas
$lines = $regOutput -split "`r`n"

# Encontrar a linha que contém o valor desejado
foreach ($line in $lines) {
    if ($line -match "AG\s+REG_BINARY\s+(.+)$") {
        $device_id = $matches[1].Trim()
        Write-Output $device_id
        break
    }
}

# Definir variáveis para obter o token de autorização
$clientID = "ClientID" # Substitua por sua ClientID <===================================================
$clientSecret = "ClientSecret" # Substitua por sua ClientSecret <===================================================
$tokenURL = "https://api.crowdstrike.com/oauth2/token"

# Definir o corpo da requisição para obter o token
$tokenBody = "client_id=$clientID&client_secret=$clientSecret"

# Fazer a requisição POST para obter o token de autorização
$tokenResponse = Invoke-RestMethod -Uri $tokenURL -Method Post -Headers @{
    "Accept" = "application/json"
    "Content-Type" = "application/x-www-form-urlencoded"
} -Body $tokenBody

# Extrair o token de autorização da resposta
$authToken = $tokenResponse.access_token

# Verificar se o token foi obtido com sucesso
if (-not $authToken) {
    Write-Error "Falha ao obter o token de autorização."
    exit
}

# Definir a URL para a segunda requisição
$URL = "https://api.crowdstrike.com/policy/combined/reveal-uninstall-token/v1"

# Definir o corpo da requisição para a segunda requisição
$requestBody = @{
    audit_message = "Seu audit_message aqui"  # Substitua por sua mensagem de auditoria <===================================================
    device_id = $device_id 
} | ConvertTo-Json

# Definir os cabeçalhos, incluindo o token de autorização
$requestHeaders = @{
    "Authorization" = "Bearer $authToken"
    "Content-Type"  = "application/json"
}

# Fazer a requisição POST para revelar o token de desinstalação
$response = Invoke-RestMethod -Uri $URL -Method Post -Headers $requestHeaders -Body $requestBody

# Exibir a resposta
$response | ConvertTo-Json -Depth 4

# Extrair o token de desinstalação do campo "uninstall_token" dentro do array "resources"
$uninstallToken = $response.resources[0].uninstall_token

# Exibir o token de desinstalação
Write-Output "Uninstall Token: $uninstallToken"

# Download do pacote de remoção do Falcon
Invoke-WebRequest -Uri "Repositorio" -OutFile "CsUninstallTool.exe" # Substitua o valor da "-Uri" para a URL do seu repositório público <===================================================

# Definir o caminho para o executável e os parâmetros
$exePath = "C:\Windows\temp\CsUninstallTool.exe"
$arguments = "MAINTENANCE_TOKEN=$uninstallToken /quiet"

# Executar o comando
Start-Process -FilePath $exePath -ArgumentList $arguments -NoNewWindow -Wait
