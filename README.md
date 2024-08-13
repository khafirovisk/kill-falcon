# kill-falcon

# PowerShell Script para Manipulação de Registros e Automação de Comandos em APIs

Este script PowerShell foi desenvolvido para realizar consultas em registros do Windows, obter um token de autorização via API, revelar um token de desinstalação e, em seguida, executar um processo automatizado para desinstalar um agente específico usando o token obtido.

## Funcionalidades

- **Consulta de Registro**: Executa uma consulta no registro do Windows para buscar um valor específico.
- **Autenticação via API**: Obtém um token de autorização a partir de uma API usando `client_id` e `client_secret`.
- **Revelação de Token de Desinstalação**: Faz uma requisição POST para obter um token de desinstalação para um dispositivo específico.
- **Download e Execução de Ferramenta**: Baixa uma ferramenta de desinstalação e a executa silenciosamente usando o token de desinstalação obtido.

## Requisitos

- **Windows PowerShell 5.1** ou **PowerShell Core 7.x**
- Acesso à internet para realizar requisições API e download da ferramenta de desinstalação
- Permissões para executar scripts PowerShell no sistema

## Uso

1. **Baixe o script .ps1**:

https://github.com/khafirovisk/kill-falcon/archive/refs/heads/main.zip

3. **Configurar o Script**:
    - Atualize as variáveis `clientID` e `clientSecret` com os valores corretos.
    - Substitua `"REPOSITÓRIO PÚBLICO"` para seu reposítório público de instaladores.

4. **Executar o Script**:
    Abra uma sessão do PowerShell como Administrador e execute:
    ```powershell
    .\killfalcon.ps1
    ```

5. **Verificar Saída**:
    - O script exibirá o `device_id` encontrado no registro e o `uninstall_token` obtido.
    - O script baixará e executará a ferramenta de desinstalação no sistema.

## Notas de Segurança

- **Variáveis Sensíveis**: Certifique-se de que o `clientSecret` seja armazenado de maneira segura e não seja exposto publicamente.
- **Execução de Scripts**: Verifique se a política de execução de scripts (`ExecutionPolicy`) do PowerShell permite a execução do script de maneira segura.

## Contribuições

Contribuições são bem-vindas! Sinta-se à vontade para abrir issues ou pull requests.

## Licença
