/ SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title MicroCreditoColateral
 * @dev Contrato pedagogico para la EFT de Fundamentos de Blockchain.
 * Permite depositar Ether como colateral, recibir tokens ERC20 como credito,
 * pagar el prestamo dentro del plazo o liquidar la garantia si vence.
 */
contract MicroCreditoColateral is ReentrancyGuard {
    address public owner;
    address public borrower;

    enum EstadoPrestamo { INACTIVO, ACTIVO, PAGADO, LIQUIDADO }
    EstadoPrestamo public estadoPrestamo;

    IERC20 public tokenCredito;
    uint256 public montoColateral;
    uint256 public montoCredito;
    uint256 public timestampLimite;

    event ColateralDepositado(
        address indexed prestatario,
        uint256 cantidadEth,
        uint256 cantidadCredito,
        uint256 limiteTiempo
    );

    event PrestamoPagado(
        address indexed prestatario,
        uint256 cantidadReembolsadaEth
    );

    event GarantiaLiquidada(
        address indexed liquidador,
        uint256 cantidadEthLiquidada
    );

    modifier onlyOwner() {
        require(msg.sender == owner, "Error: Solo el administrador puede realizar esta accion");
        _;
    }

    constructor(address _tokenCredito) {
        owner = msg.sender;
        tokenCredito = IERC20(_tokenCredito);
        estadoPrestamo = EstadoPrestamo.INACTIVO;
    }

    function depositarColateralYTomarCredito(
        uint256 _montoCredito,
        uint256 _duracionSegundos
    ) external payable nonReentrant {
        require(estadoPrestamo == EstadoPrestamo.INACTIVO, "Prestamo activo");
        require(msg.value > 0, "Debe enviar colateral");
        require(
            _montoCredito > 0 && _montoCredito <= tokenCredito.balanceOf(address(this)),
            "Monto de credito invalido"
        );
        require(_duracionSegundos > 0, "Duracion invalida");

        borrower = msg.sender;
        montoColateral = msg.value;
        montoCredito = _montoCredito;
        timestampLimite = block.timestamp + _duracionSegundos;
        estadoPrestamo = EstadoPrestamo.ACTIVO;

        require(
            tokenCredito.transfer(borrower, montoCredito),
            "Transferencia de credito fallida"
        );

        emit ColateralDepositado(
            borrower,
            msg.value,
            _montoCredito,
            timestampLimite
        );
    }

    function pagarPrestamo() external nonReentrant {
        require(estadoPrestamo == EstadoPrestamo.ACTIVO, "No hay prestamo activo");
        require(msg.sender == borrower, "Solo el prestatario puede pagar");
        require(block.timestamp <= timestampLimite, "Plazo vencido");

        estadoPrestamo = EstadoPrestamo.PAGADO;

        require(
            tokenCredito.transferFrom(msg.sender, address(this), montoCredito),
            "Pago de tokens fallido"
        );

        uint256 colateralADevolver = montoColateral;
        payable(borrower).transfer(colateralADevolver);

        emit PrestamoPagado(borrower, colateralADevolver);

        _resetPrestamo();
    }

    function liquidarGarantia() external onlyOwner nonReentrant {
        require(estadoPrestamo == EstadoPrestamo.ACTIVO, "No hay prestamo activo");
        require(block.timestamp > timestampLimite, "El plazo aun no vence");

        estadoPrestamo = EstadoPrestamo.LIQUIDADO;
        uint256 colateralALiquidar = montoColateral;

        payable(owner).transfer(colateralALiquidar);

        emit GarantiaLiquidada(msg.sender, colateralALiquidar);

        _resetPrestamo();
    }

    function _resetPrestamo() internal {
        borrower = address(0);
        montoColateral = 0;
        montoCredito = 0;
        timestampLimite = 0;
        estadoPrestamo = EstadoPrestamo.INACTIVO;
    }
}
