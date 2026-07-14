// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MockToken {
    string public name;
    string public symbol;
    uint8 public decimals = 18;
    uint public totalSupply;

    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;

    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
    }

    function mint(address to, uint amount) public {
        balanceOf[to] += amount;
        totalSupply += amount;
    }

    function approve(address spender, uint amount) public returns (bool) {
        allowance[msg.sender][spender] = amount;
        return true;
    }

    function transfer(address to, uint amount) public returns (bool) {
        require(balanceOf[msg.sender] >= amount, "Saldo insuficiente");
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        return true;
    }

    function transferFrom(address from, address to, uint amount) public returns (bool) {
        require(balanceOf[from] >= amount, "Saldo insuficiente");
        require(allowance[from][msg.sender] >= amount, "Sin aprobacion");
        allowance[from][msg.sender] -= amount;
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        return true;
    }
}

contract MockOracle {
    uint public precioColateral;

    constructor(uint _precioInicial) {
        precioColateral = _precioInicial;
    }

    function actualizarPrecio(uint _nuevoPrecio) public {
        precioColateral = _nuevoPrecio;
    }

    function obtenerPrecio() public view returns (uint) {
        return precioColateral;
    }
}

contract MicroDeFiCredit {
    MockToken public colateralToken;
    MockToken public stableToken;
    MockOracle public oracle;

    uint public constant PORCENTAJE_PRESTAMO = 50;
    uint public constant LIMITE_LIQUIDACION = 75;
    uint public constant INTERES = 5;

    struct Prestamo {
        uint colateral;
        uint deuda;
        bool activo;
    }

    mapping(address => Prestamo) public prestamos;

    event ColateralDepositado(address usuario, uint monto);
    event PrestamoSolicitado(address usuario, uint monto);
    event PrestamoPagado(address usuario, uint monto);
    event PrestamoLiquidado(address usuario, uint colateral);

    constructor(address _colateralToken, address _stableToken, address _oracle) {
        colateralToken = MockToken(_colateralToken);
        stableToken = MockToken(_stableToken);
        oracle = MockOracle(_oracle);
    }

    function depositarColateral(uint monto) public {
        require(monto > 0, "Monto invalido");
        colateralToken.transferFrom(msg.sender, address(this), monto);
        prestamos[msg.sender].colateral += monto;
        emit ColateralDepositado(msg.sender, monto);
    }

    function valorColateral(address usuario) public view returns (uint) {
        uint precio = oracle.obtenerPrecio();
        return (prestamos[usuario].colateral * precio) / 1 ether;
    }

    function maximoPrestamo(address usuario) public view returns (uint) {
        return (valorColateral(usuario) * PORCENTAJE_PRESTAMO) / 100;
    }

    function solicitarPrestamo(uint monto) public {
        Prestamo storage p = prestamos[msg.sender];
        require(p.colateral > 0, "Debe depositar colateral");
        require(!p.activo, "Ya tiene prestamo activo");
        require(monto <= maximoPrestamo(msg.sender), "Monto supera limite permitido");

        uint deudaConInteres = monto + ((monto * INTERES) / 100);
        p.deuda = deudaConInteres;
        p.activo = true;

        stableToken.mint(msg.sender, monto);
        emit PrestamoSolicitado(msg.sender, monto);
    }

    function pagarPrestamo() public {
        Prestamo storage p = prestamos[msg.sender];
        require(p.activo, "No hay prestamo activo");

        stableToken.transferFrom(msg.sender, address(this), p.deuda);

        uint colateralADevolver = p.colateral;
        p.colateral = 0;
        p.deuda = 0;
        p.activo = false;

        colateralToken.transfer(msg.sender, colateralADevolver);
        emit PrestamoPagado(msg.sender, colateralADevolver);
    }

    function esLiquidable(address usuario) public view returns (bool) {
        Prestamo memory p = prestamos[usuario];
        if (!p.activo) {
            return false;
        }

        uint valor = valorColateral(usuario);
        uint minimoSeguro = (p.deuda * 100) / LIMITE_LIQUIDACION;

        return valor < minimoSeguro;
    }

    function liquidar(address usuario) public {
        require(esLiquidable(usuario), "Prestamo aun es saludable");

        Prestamo storage p = prestamos[usuario];
        uint colateralLiquidado = p.colateral;

        p.colateral = 0;
        p.deuda = 0;
        p.activo = false;

        emit PrestamoLiquidado(usuario, colateralLiquidado);
    }

    function verPrestamo(address usuario) public view returns (
        uint colateral,
        uint deuda,
        uint valorActualColateral,
        bool activo,
        bool liquidable
    ) {
        Prestamo memory p = prestamos[usuario];
        return (
            p.colateral,
            p.deuda,
            valorColateral(usuario),
            p.activo,
            esLiquidable(usuario)
        );
    }
}
