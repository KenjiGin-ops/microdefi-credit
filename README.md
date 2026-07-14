# microdefi-credit
Proyecto académico de microcréditos colateralizados en DeFi con Solidity, oráculo simulado y liquidación automática.
# MicroDeFi Credit

Proyecto académico de microcréditos colateralizados en DeFi.

## Descripción
Smart contract de préstamo automatizado donde un usuario deposita tokens como colateral, solicita un préstamo menor al valor de su garantía y puede ser liquidado si el precio del colateral baja.

## Tecnologías
- Solidity
- Remix IDE
- Remix VM
- Token ERC-20 simulado
- Oráculo simulado

## Demo
Se probó en Remix:
1. Mint de token colateral.
2. Approve al contrato.
3. Depósito de colateral.
4. Solicitud de préstamo.
5. Cambio de precio en oráculo.
6. Liquidación automática.

## Contratos
- MockToken
- MockOracle
- MicroDeFiCredit
