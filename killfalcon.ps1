# Executar o comando reg query e capturar a saída
$regOutput = & reg query HKLM\System\CurrentControlSet\services\CSAgent\Sim\ /f AG

# Verificar se houve saída do comando reg query
if (-not $regOutput) {
    Write-Error "Falha ao consultar o registro. Saída vazia."
    exit
}

# Converter a saída em uma lista de linhas
$lines = $regOutput -split "`r`n"

# Inicializar a variável $device_id
$device_id = $null

# Encontrar a linha que contém o valor desejado
foreach ($line in $lines) {
    if ($line -match "AG\s+REG_BINARY\s+(.+)$") {
        $device_id = $matches[1].Trim()
        Write-Output $device_id
        break
    }
}

# Verificar se o device_id foi encontrado
if (-not $device_id) {
    Write-Error "Falha ao encontrar o Device ID."
    exit
}

# Definir variáveis para obter o token de autorização
$clientID = "CLIENTID" # Substitua <====================== 
$clientSecret = "SECRET" # Substitua <======================
$tokenURL = "https://api.crowdstrike.com/oauth2/token"

# Definir o corpo da requisição para obter o token
$tokenBody = "client_id=$clientID&client_secret=$clientSecret"

# Fazer a requisição POST para obter o token de autorização
try {
    $tokenResponse = Invoke-RestMethod -Uri $tokenURL -Method Post -Headers @{
        "Accept" = "application/json"
        "Content-Type" = "application/x-www-form-urlencoded"
    } -Body $tokenBody
} catch {
    Write-Error "Falha ao obter o token de autorização: $_"
    exit
}

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
    audit_message = "Seu audit_message aqui"  # Substitua <======================
    device_id = $device_id  # Substitua pelo ID do dispositivo
} | ConvertTo-Json

# Definir os cabeçalhos, incluindo o token de autorização
$requestHeaders = @{
    "Authorization" = "Bearer $authToken"
    "Content-Type"  = "application/json"
}

# Fazer a requisição POST para revelar o token de desinstalação
try {
    $response = Invoke-RestMethod -Uri $URL -Method Post -Headers $requestHeaders -Body $requestBody
} catch {
    Write-Error "Falha ao obter o token de desinstalação: $_"
    exit
}

# Exibir a resposta
$response | ConvertTo-Json -Depth 4

# Extrair o token de desinstalação do campo "uninstall_token" dentro do array "resources"
$uninstallToken = $response.resources[0].uninstall_token

# Verificar se o token de desinstalação foi obtido
if (-not $uninstallToken) {
    Write-Error "Falha ao extrair o token de desinstalação."
    exit
}

# Exibir o token de desinstalação
Write-Output "Uninstall Token: $uninstallToken"

# Download do pacote de remoção do Falcon
$downloadPath = "C:\Windows\temp\CsUninstallTool.exe"
Invoke-WebRequest -Uri "REPOSITÓRIO PÚBLICO" -OutFile $downloadPath # Substitua o REPOSITÓRIO PÚBLICO <======================

# Definir o caminho para o executável e os parâmetros
$arguments = "MAINTENANCE_TOKEN=$uninstallToken /quiet"

# Executar o comando
Start-Process -FilePath $downloadPath -ArgumentList $arguments -NoNewWindow -Wait
