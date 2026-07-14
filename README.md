
# MicroDeFi Credit - EFT

Proyecto académico para la Evaluación Final Transversal de Fundamentos de Blockchain (BCY0010).

## Caso

Microcréditos colateralizados en Finanzas Descentralizadas (DeFi).

## Descripción

La implementación final se desarrolla sobre el boilerplate oficial del caso Microcréditos Colateralizados en DeFi. El sistema permite que un usuario deposite Ether como colateral, reciba tokens ERC-20 simulados como crédito, pague el préstamo dentro del plazo o pierda la garantía si el plazo vence.

## Contratos principales

- `MockERC20.sol`: token ERC-20 de prueba usado como token de crédito.
- `MicroCreditoColateral.sol`: contrato principal de préstamo colateralizado.

## Flujo probado en Remix

1. Despliegue de `MockERC20`.
2. Despliegue de `MicroCreditoColateral`.
3. Transferencia de tokens al contrato de préstamo para entregar liquidez.
4. Usuario prestatario deposita 5 ETH como colateral.
5. Usuario recibe 100 tokens de crédito.
6. Si el plazo vence, el pago queda bloqueado.
7. El administrador liquida la garantía.

## Tecnologías

- Solidity
- Remix IDE
- Remix VM
- OpenZeppelin
- ERC-20
- Smart contracts

## Consideración sobre oráculos

El boilerplate oficial aborda el rol de los oráculos de forma conceptual. En una implementación DeFi real, se podría integrar Chainlink para consultar el precio del colateral y liquidar no solo por vencimiento, sino también por caída del valor de la garantía.

## Advertencia

Este proyecto es una simulación académica. No utiliza dinero real ni constituye asesoría financiera.
