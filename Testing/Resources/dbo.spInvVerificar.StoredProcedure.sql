SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[spInvVerificar]
@ID               		int,
@Accion			char(20),
@Base			char(20),
@Empresa          		char(5),
@Usuario			char(10),
@Autorizacion		char(10) 	OUTPUT,
@Mensaje			int,
@Modulo	      		char(5),
@Mov              		char(20),
@MovID			varchar(20),
@MovTipo	      		char(20),
@MovMoneda			char(10),
@MovTipoCambio		float,
@FechaEmision		datetime,
@Ejercicio	      		int,
@Periodo	      		int,
@Almacen          		char(10),
@AlmacenTipo		char(15),
@AlmacenDestino   		char(10),
@AlmacenDestinoTipo		char(15),
@VoltearAlmacen		bit,
@AlmacenEspecifico		char(10),
@Condicion			varchar(50),
@Vencimiento		datetime,
@ClienteProv		char(10),
@EnviarA			int,
@DescuentoGlobal		float,
@SobrePrecio		float,
@ConCredito			bit,
@ConLimiteCredito		bit,
@LimiteCredito		money,
@ConLimitePedidos		bit,
@LimitePedidos		money,
@MonedaCredito		char(10),
@TipoCambioCredito		float,
@DiasCredito		int,
@CondicionesValidas		varchar(255),
@PedidosParciales		bit,
@VtasConsignacion		bit,
@AlmacenVtasConsignacion	char(10),
@AnticiposFacturados	money,
@Estatus			char(15),
@EstatusNuevo		char(15),
@AfectarMatando		bit,
@AfectarMatandoOpcional	bit,
@AfectarConsignacion	bit,
@AfectarAlmacenRenglon	bit,
@OrigenTipo			varchar(10),
@Origen			varchar(20),
@OrigenID			varchar(20),
@OrigenMovTipo		varchar(20),
@FacturarVtasMostrador	bit,
@EsTransferencia		bit,
@ServicioGarantia		bit,
@ServicioArticulo		char(20),
@ServicioSerie		char(20),
@FechaRequerida		datetime,
@AutoCorrida		char(8),
@CfgCosteoNivelSubCuenta	bit,
@CfgDecimalesCantidades	int,
@CfgSeriesLotesMayoreo	bit,
@CfgSeriesLotesAutoOrden	char(20),
@CfgValidarPrecios		char(20),
@CfgPrecioMinimoSucursal	bit,
@CfgValidarMargenMinimo	char(20),
@CfgVentaSurtirDemas	bit,
@CfgCompraRecibirDemas	bit,
@CfgCompraRecibirDemasTolerancia float,
@CfgTransferirDemas		bit,
@CfgVentaChecarCredito	char(20),
@CfgVentaPedidosDisminuyenCredito bit,
@CfgVentaBloquearMorosos	char(20),
@CfgVentaLiquidaIntegral	bit,
@CfgFacturaCobroIntegrado	bit,
@CfgInvPrestamosGarantias	bit,
@CfgInvEntradasSinCosto	bit,
@CfgServiciosRequiereTareas bit,
@CfgServiciosValidarID	bit,
@CfgImpInc			bit,
@CfgLimiteRenFacturas	int,
@CfgNotasBorrador		bit,
@CfgAnticiposFacturados	bit,
@CfgMultiUnidades		bit,
@CfgMultiUnidadesNivel	char(20),
@CfgCompraFactorDinamico 	bit,
@CfgInvFactorDinamico   	bit,
@CfgProdFactorDinamico  	bit,
@CfgVentaFactorDinamico 	bit,
@CfgToleranciaCosto		money,
@CfgToleranciaTipoCosto	char(20),
@CfgFormaPagoRequerida	bit,
@CfgBloquearNotasNegativas	bit,
@CfgBloquearFacturacionDirecta bit,
@SeguimientoMatriz		bit,
@CobroIntegrado		bit,
@CobroIntegradoCxc		bit,
@CobroIntegradoParcial      bit,
@CobrarPedido		bit,
@CfgCompraValidarArtProv	bit,
@CfgValidarCC		bit,
@CfgVentaRestringida	bit,
@CfgLimiteCreditoNivelGrupo bit,
@CfgLimiteCreditoNivelUEN   bit,
@CfgRestringirArtBloqueados bit,
@CfgValidarFechaRequerida	bit,
@FacturacionRapidaAgrupada	bit,
@Utilizar			bit,
@UtilizarID			int,
@UtilizarMovTipo		char(20),
@Generar			bit,
@GenerarMov                 char(20),
@GenerarAfectado		bit,
@Conexion			bit,
@SincroFinal		bit,
@Sucursal			int,
@SucursalDestino		int,
@AccionEspecial		varchar(20),
@AnexoID			int,
@Autorizar			bit		OUTPUT,
@AfectarConsecutivo 	bit           	OUTPUT,
@Ok               		int           	OUTPUT,
@OkRef            		varchar(255)  	OUTPUT,
@CfgPrecioMoneda		bit = 0

AS BEGIN
DECLARE
@EnLinea			bit,
@Renglon 			float,
@RenglonSub			int,
@RenglonID			int,
@RenglonTipo		char(1),
@Conteo			int,
@AutoGenerado		bit,
@AfectarAlmacen     	char(10),
@AfectarAlmacenTipo		char(20),
@Articulo	        	char(20),
@ArticuloDestino        	char(20),
@SubCuentaDestino        	varchar(20),
@ArtTipo	        	char(20),
@ArtSerieLoteInfo		bit,
@ArtTipoOpcion		char(20),
@ArtTipoCompra		varchar(20),
@ArtSeProduce		bit,
@ArtSeCompra		bit,
@ArtEsFormula		bit,
@ArtUnidad	        	varchar(50),
@ArtMargenMinimoBorrar	bit,
@ArtMargenMinimo		money,
@ArtMonedaVenta		char(10),
@ArtFactorVenta		float,
@ArtTipoCambioVenta		float,
@ArtPrecioMinimo		money,
@ArtMonedaCosto		char(10),
@ArtFactorCosto		float,
@ArtTipoCambioCosto		float,
@ArtCaducidadMinima		int,
@FechaCaducidad		datetime,
@Subcuenta	        	varchar(50),
@SustitutoArticulo	        varchar(20),
@SustitutoSubcuenta	        varchar(50),
@Cantidad	        	float,
@CantidadObsequio        	float,
@CantidadSugerida        	float,
@CantidadCalcularImporte	float,
@MovUnidad			varchar(50),
@Factor			float,
@CantidadOriginal		float,
@CantidadInventario		float,
@CantidadPendiente  	float,
@CantidadReservada		float,
@CantidadOrdenada		float,
@CantidadA	        	float,
@CantidadSeries		int,
@IDAplica			int,
@AplicaMov	       		char(20),
@AplicaMovID		varchar(20),
@AplicaOrdenado		float,
@AplicaPendiente		float,
@AplicaReservada		float,
@AplicaClienteProv		char(10),
@AplicaCondicion		varchar(50),
@AplicaMovTipo		char(20),
@AplicaControlAnticipos	char(20),
@AplicaAutorizacion		char(10),
@AlmacenRenglon		char(10),
@ArticuloMatar		char(20),
@SubCuentaMatar		varchar(50),
@Costo	        	money,
@ArtCosto			money,
@Saldo			money,
@VentasPendientes		money,
@RemisionesAplicadas	money,
@PedidosPendientes		money,
@Disponible	        	float,
@EsEntrada          	bit,
@EsSalida			bit,
@AfectarPiezas      	bit,
@AfectarCostos      	bit,
@AfectarUnidades    	bit,
@AfectarAlgo        	bit,
@Precio	         	float,
@PrecioUnitarioNeto		money,
@PrecioTipoCambio		float,
@DescuentoTipo	 	char(1),
@DescuentoLinea	 	money,
@Impuesto1		 	float,
@Impuesto2		 	float,
@Impuesto3		 	money,
@Importe             	money,
@ImporteNeto             	money,
@Impuestos		 	money,
@ImpuestosNetos	 	money,
@ImporteTotal		money,
@ValesCobrados		money,
@TarjetasCobradas		money, 	
@Importe1			money,
@Importe2			money,
@Importe3			money,
@Importe4			money,
@Importe5			money,
@FormaCobro1		varchar(50),
@FormaCobro2		varchar(50),
@FormaCobro3		varchar(50),
@FormaCobro4		varchar(50),
@FormaCobro5		varchar(50),
@FormaCobroVales		varchar(50),
@FormaCobroTarjetas		varchar(50), 	
@CobroDesglosado		money,
@CobroCambio		money,
@CobroRedondeo		money,
@CobroDelEfectivo		money,
@Efectivo			money,
@DescuentoLineaImporte	money,
@DescuentoGlobalImporte	money,
@SobrePrecioImporte		money,
@SumaCantidadOriginal	float,
@SumaCantidadPendiente	float,
@ImporteTotalSinAutorizar	money,
@SumaImporteNeto		money,
@SumaImpuestosNetos		money,
@UtilizarEstatus		char(15),
@ServicioArticuloTipo	char(20),
@DiasVencimiento		int,
@MaxDiasMoratorios		int,
@DiasTolerancia		int,
@ChecarCredito		bit,
@SerieLote			char(50),
@EstatusCuenta		char(15),
@Descripcion		varchar(100),
@TareaOmision		varchar(50),
@TareaOmisionEstado		varchar(30),
@DetalleTipo		varchar(20),
@NoValidarDisponible	bit,
@ValidarDisponible		bit,
@ValidarCobroIntegrado	bit,
@CANTSaldo			money,
@Minimo			money,
@Maximo			money,
@AlmacenTemp		char(10),
@AlmacenOriginal		char(10),
@AlmacenDestinoOriginal	char(10),
@CfgControlAlmacenes	bit,
@CfgLimitarCompraLocal	bit,
@ProdSerieLote		varchar(50),
@ProdRuta			varchar(20),
@ProdOrden			int,
@ProdOrdenDestino		int,
@ProdOrdenFinal		int,
@ProdOrdenSiguiente		int,
@ProdCentro			char(10),
@ProdCentroDestino		char(10),
@ProdCentroSiguiente	char(10),
@ProdEstacion		char(10),
@ProdEstacionDestino	char(10),
@DifCredito			money,
@ImporteAutorizar		money,
@AlmacenSucursal		int,
@AlmacenDestinoSucursal	int,
@CfgVentaCobroRedondeoDecimales	int,
@CfgVentaLimiteRenFacturasVMOS	bit,
@CfgAutoAutorizacionFacturas    	bit,
@SumaImporteNetoSinAutorizar    	money,
@SumaImpuestosNetosSinAutorizar 	money,
@CantidadMinimaVenta	    	float,
@CantidadMaximaVenta	    	float,
@CfgVentaDevSinAntecedente	    	bit,
@CfgVentaDevSeriesSinAntecedente	bit,
@CfgCompraCaducidad			bit,
@ContUso				varchar(20),
@Flotante			        float,
@Identificador			varchar(20),
@EmpresaGrupo			varchar(50),
@ArtActividades			bit,
@RedondeoMonetarios			int,
@ValidarFechaRequerida		bit,
@FechaRequeridaD			datetime,
@ExcendeteDemas			float,
@SeriesLotesAutoOrden		char(20),
@UltimoCosto			money,
@CostoPromedio			money,
@CostoEstandar			money,
@CostoReposicion			money,
@VentaUEN				int,
@CategoriaActivoFijo		varchar(50),
@Paquete				int,
@PPTO				bit,
@PPTOVentas				bit,
@FEA				bit,
@EsActivoF bit,
@EsEstadistica	bit
SELECT @EsActivoF = 0
SELECT @RedondeoMonetarios = dbo.fnRedondeoMonetarios()
SELECT @ChecarCredito 	 = 0,
@NoValidarDisponible	 = 0,
@CfgControlAlmacenes	 = 0,
@SerieLote     	 = NULL,
@ProdSerieLote	 	 = NULL,
@ProdOrden		 = NULL,
@ProdOrdenDestino	 = NULL,
@ProdCentro		 = NULL,
@ProdCentroDestino	 = NULL,
@ProdRuta		 = NULL,
@Descripcion   	 = NULL,
@IDAplica		 = NULL,
@AplicaAutorizacion     = NULL,
@AlmacenOriginal	 = @Almacen,
@AlmacenDestinoOriginal = @AlmacenDestino,
@Autorizar		 = 0,
@ValidarFechaRequerida  = 0,
@VentaUEN		 = NULL,
@PPTO			 = 0
IF @CfgLimiteCreditoNivelGrupo = 1
SELECT @EmpresaGrupo = NULLIF(RTRIM(Grupo), '') FROM Empresa WITH (NOLOCK) WHERE Empresa = @Empresa
IF @CfgLimiteCreditoNivelUEN = 1 AND @Modulo = 'VTAS'
BEGIN
SELECT @VentaUEN = UEN FROM Venta WITH (NOLOCK) WHERE ID = @ID
SELECT @LimiteCredito = CreditoLimite FROM CteUEN WITH (NOLOCK) WHERE Cliente = @ClienteProv AND UEN = @VentaUEN
END
SELECT @PPTO = PPTO,
@PPTOVentas = PPTOVentas,
@FEA = FEA
FROM EmpresaGral WITH (NOLOCK)
WHERE Empresa = @Empresa
SELECT @CfgVentaCobroRedondeoDecimales = VentaCobroRedondeoDecimales,
@CfgVentaLimiteRenFacturasVMOS = ISNULL(VentaLimiteRenFacturasVMOS, 0),
@FormaCobroVales = CxcFormaCobroVales, 
@FormaCobroTarjetas = CxcFormaCobroTarjetas 
FROM EmpresaCfg WITH (NOLOCK)
WHERE Empresa = @Empresa
SELECT @CfgAutoAutorizacionFacturas     = AutoAutorizacionFacturas,
@CfgVentaDevSinAntecedente       = VentaDevSinAntecedente,
@CfgVentaDevSeriesSinAntecedente = VentaDevSeriesSinAntecedente,
@CfgCompraCaducidad              = ISNULL(CompraCaducidad, 0)
FROM EmpresaCfg2 WITH (NOLOCK)
WHERE Empresa = @Empresa
SELECT @CfgControlAlmacenes = ISNULL(ControlAlmacenes, 0),
@CfgLimitarCompraLocal = ISNULL(LimitarCompraLocal, 0)
FROM UsuarioCfg2 WITH (NOLOCK)
WHERE Usuario = @Usuario
/* Aqui estaba la validacion del error 60070 */
IF NULLIF(RTRIM(@Almacen), '') IS NULL AND @Modulo IN ('VTAS', 'COMS', 'INV') AND @Accion NOT IN ('CANCELAR', 'GENERAR')
SELECT @Ok = 20390
IF NULLIF(RTRIM(@AlmacenDestino), '') IS NULL AND @MovTipo = 'INV.DTI' AND @Accion NOT IN ('CANCELAR', 'GENERAR')
SELECT @Ok = 20390
IF @Estatus IN ('SINAFECTAR', 'BORRADOR', 'CONFIRMAR') AND @CobroIntegrado = 0 AND ((@MovTipo IN ('VTAS.C', 'VTAS.CS')) OR (@MovTipo IN ('VTAS.P','VTAS.S') AND @EstatusNuevo = 'PENDIENTE') OR (@MovTipo IN ('VTAS.F','VTAS.FAR','VTAS.FC', 'VTAS.FG', /*'VTAS.FX', */'VTAS.FB','VTAS.R') AND @Utilizar = 0))
SELECT @ChecarCredito = 1
IF @MovTipo IN ('VTAS.N', 'VTAS.NO', 'VTAS.NR', 'VTAS.FM') AND @CfgNotasBorrador = 1 AND (@Estatus IN ('SINAFECTAR', 'BORRADOR', 'CONFIRMAR')  OR @Accion = 'CANCELAR')
SELECT @NoValidarDisponible = 1
IF @Accion IN ('RESERVAR', 'DESRESERVAR', 'RESERVARPARCIAL', 'ASIGNAR', 'DESASIGNAR') AND @MovTipo NOT IN ('VTAS.P', 'VTAS.F','VTAS.FAR', 'VTAS.FC', 'VTAS.FG', 'VTAS.FX', 'VTAS.S', 'INV.SOL', 'INV.SM', 'INV.OT', 'INV.OI')
SELECT @Ok = 60040
IF @Modulo = 'COMS' AND @MovTipo IN ('COMS.O', 'COMS.OP', 'COMS.F', 'COMS.FL', 'COMS.EG', 'COMS.EI', 'COMS.CC', 'COMS.OG', 'COMS.OD', 'COMS.OI', 'COMS.IG') AND @Accion NOT IN ('CANCELAR', 'GENERAR') AND @Ok IS NULL
BEGIN
SELECT @EstatusCuenta = Estatus FROM Prov WITH (NOLOCK) WHERE Proveedor = @ClienteProv
IF @EstatusCuenta = 'BLOQUEADO'
BEGIN
SELECT @Ok = 65032, @OkRef = @ClienteProv
EXEC xpOk_65032 @Empresa, @Usuario, @Accion, @Modulo, @ID, @Ok OUTPUT, @OkRef OUTPUT
END
END
IF @Modulo IN ('VTAS', 'COMS') AND @MovTipo <> 'COMS.R' AND NULLIF(RTRIM(@ClienteProv), '') IS NULL AND @Accion NOT IN ('CANCELAR', 'GENERAR')
BEGIN
IF @Modulo = 'VTAS' SELECT @Ok = 40010 ELSE
IF @Modulo = 'COMS' SELECT @Ok = 40020
END
IF @CfgValidarFechaRequerida = 1
BEGIN
IF (@Modulo = 'VTAS' AND @MovTipo IN ('VTAS.C','VTAS.CS','VTAS.P','VTAS.VP','VTAS.S','VTAS.PR','VTAS.EST','VTAS.F','VTAS.FAR','VTAS.FC','VTAS.DFC','VTAS.FB','VTAS.R','VTAS.SG','VTAS.EG','VTAS.VC','VTAS.VCR','VTAS.SD')) OR
(@Modulo = 'COMS' AND @MovTipo NOT IN ('COMS.D', 'COMS.DG', 'COMS.B', 'COMS.DC'))
SELECT @ValidarFechaRequerida = 1
END
IF @ValidarFechaRequerida = 1
IF @FechaRequerida IS NULL SELECT @Ok = 25120 ELSE
IF @FechaRequerida < @FechaEmision SELECT @Ok = 25121
IF @Modulo = 'VTAS' AND @MovTipo NOT IN ('VTAS.PR', 'VTAS.EST', 'VTAS.SD', 'VTAS.D', 'VTAS.DF', 'VTAS.DFC', 'VTAS.B', 'VTAS.DR', 'VTAS.DC', 'VTAS.DCR', 'VTAS.VP') AND @Accion NOT IN ('CANCELAR', 'DESRESERVAR', 'GENERAR') AND (@Autorizacion IS NULL OR @Mensaje NOT IN (65010, 65020, 65040, 20310, 65030, 65035)) AND @Ok IS NULL
BEGIN
SELECT @EstatusCuenta = Estatus FROM Cte WITH (NOLOCK) WHERE Cliente = @ClienteProv
IF @EstatusCuenta <> 'BLOQUEADO'
SELECT @EstatusCuenta = Estatus, @Descripcion = Descripcion FROM Bloqueo WITH (NOLOCK) WHERE Bloqueo = @EstatusCuenta
IF @EstatusCuenta = 'BLOQUEADO'
SELECT @Ok = 65030, @OkRef = @Descripcion
IF ISNULL(@EnviarA, 0) > 0 AND @Ok IS NULL
BEGIN
SELECT @EstatusCuenta = Estatus FROM CteEnviarA WITH (NOLOCK) WHERE Cliente = @ClienteProv AND ID = @EnviarA
IF @EstatusCuenta <> 'BLOQUEADO'
SELECT @EstatusCuenta = Estatus, @Descripcion = Descripcion FROM Bloqueo WITH (NOLOCK) WHERE Bloqueo = @EstatusCuenta
IF @EstatusCuenta = 'BLOQUEADO'
SELECT @Ok = 65035, @OkRef = @Descripcion
END
IF @Ok IS NOT NULL SELECT @Autorizar = 1
END
IF @AnticiposFacturados <> 0.0 AND @Ok IS NULL AND @Estatus = 'SINAFECTAR'
BEGIN
IF @MovTipo IN ('VTAS.F','VTAS.FAR', 'VTAS.FB') AND @CfgAnticiposFacturados = 1
BEGIN
IF @AnticiposFacturados < 0.0 SELECT @Ok = 30100 ELSE
IF @Accion <> 'CANCELAR'
BEGIN
SELECT @CANTSaldo = 0.0
/*SELECT @CANTSaldo = ROUND(ISNULL(SUM(Saldo), 0.0), 2) FROM Saldo WHERE Rama = 'CANT' AND Empresa = @Empresa AND Moneda = @MovMoneda AND Cuenta = @ClienteProv*/
SELECT @CANTSaldo = ROUND(ISNULL(SUM(AnticipoSaldo * (CASE WHEN Cxc.ClienteMoneda <> @MovMoneda THEN Cxc.ClienteTipoCambio / @MovTipoCambio ELSE 1.0 END)), 0.0), 2) FROM Cxc WITH (NOLOCK) WHERE Empresa = @Empresa AND AnticipoAplicaModulo = @Modulo AND AnticipoAplicaID = @ID
IF ROUND(@AnticiposFacturados, 2) > @CANTSaldo SELECT @Ok = 30400
END
END ELSE SELECT @Ok = 70070
IF @Ok IS NOT NULL SELECT @OkRef = 'Anticipos Facturados'
END
IF @MovTipo = 'INV.TC' SELECT @Ok = 60120
IF @Accion <> 'CANCELAR' AND @Ok IS NULL
BEGIN
IF @MovTipo IN ('VTAS.C', 'VTAS.CS', 'VTAS.P', 'VTAS.S', 'VTAS.F','VTAS.FAR', 'VTAS.FB', 'COMS.C', 'COMS.O', 'COMS.OP', 'COMS.F', 'COMS.FL', 'COMS.EG', 'COMS.EI', 'INV.P')
EXEC spVerificarVencimiento @Condicion, @Vencimiento, @FechaEmision, @Ok OUTPUT
IF @Modulo = 'VTAS' AND @Estatus IN ('SINAFECTAR', 'BORRADOR', 'CONFIRMAR') AND (@Base IN ('SELECCION', 'RESERVADO')) AND @PedidosParciales = 0
IF (@Utilizar = 1 AND @UtilizarMovTipo ='VTAS.P') OR (@Generar = 1 AND @MovTipo = 'VTAS.P')
SELECT @Ok = 20300
IF @MovTipo IN ('VTAS.VC', 'VTAS.DC')
IF @VtasConsignacion = 0 OR @AlmacenVtasConsignacion = NULL SELECT @Ok = 20270
END
IF @MovTipo IN ('INV.OI', 'INV.TI', 'INV.SI', 'INV.EI') AND @Accion <> 'GENERAR'
BEGIN
IF @AlmacenDestino = @Almacen OR @AlmacenDestino IS NULL SELECT @Ok = 20120 /*ELSE
IF EXISTS(SELECT * FROM Alm a, Alm d WHERE a.Sucursal = d.Sucursal AND a.Almacen = @Almacen AND d.Almacen = @AlmacenDestino) SELECT @Ok = 20800*/
END
IF @Estatus = 'PENDIENTE' AND @Accion = 'CANCELAR' AND @Base IN ('SELECCION','PENDIENTE') AND @MovTipo NOT IN ('VTAS.P', 'VTAS.S', 'COMS.R', 'COMS.O', 'COMS.OP', 'COMS.OG', 'COMS.OD', 'COMS.OI', 'INV.SOL', 'INV.OT', 'INV.OI', 'INV.TI', 'INV.SM', 'PROD.O', 'VTAS.VCR') SELECT @Ok = 60240
IF @MovTipo IN ('VTAS.S', 'VTAS.SG', 'VTAS.EG') AND @Ok IS NULL
BEGIN
SELECT @ServicioArticuloTipo = NULL
SELECT @ServicioArticuloTipo = UPPER(Tipo) FROM Art WITH (NOLOCK) WHERE Articulo = @ServicioArticulo
IF @ServicioArticuloTipo IS NULL SELECT @Ok = 20450 ELSE
IF @ServicioArticuloTipo IN ('SERIE','LOTE','VIN','PARTIDA') AND @ServicioSerie IS NULL SELECT @Ok = 20460
END
IF @MovTipo IN ('VTAS.N', 'VTAS.NO', 'VTAS.NR') AND @Accion = 'CANCELAR'
IF EXISTS(SELECT * FROM Venta WITH (NOLOCK) WHERE ID = (SELECT ID FROM VentaOrigen WITH (NOLOCK) WHERE OrigenID = @ID) AND Estatus = 'BORRADOR')
SELECT @Ok = 30370
IF @Accion NOT IN ('GENERAR', 'CANCELAR') AND @Ok IS NULL
EXEC spValidarMovImporteMaximo @Usuario, @Modulo, @Mov, @ID, @Ok OUTPUT, @OkRef OUTPUT
IF @FEA = 1
IF (SELECT NULLIF(RTRIM(ConsecutivoFEA), '') FROM MovTipo WITH (NOLOCK) WHERE Modulo = @Modulo AND Mov = @Mov) IS NOT NULL
EXEC spPreValidarFEA @ID, 1, @Ok OUTPUT, @OkRef OUTPUT
IF @Ok IS NULL
EXEC xpInvVerificar @ID, @Accion, @Base, @Empresa, @Usuario, @Modulo,
@Mov, @MovID, @MovTipo, @MovMoneda, @MovTipoCambio, @Estatus, @EstatusNuevo,
@FechaEmision,
@Ok OUTPUT, @OkRef OUTPUT
IF @Ok IS NOT NULL RETURN
IF @Modulo = 'VTAS'
DECLARE crVerificarDetalle CURSOR
FOR SELECT 0, d.Renglon, d.RenglonSub, d.RenglonID, d.RenglonTipo, (ISNULL(d.Cantidad, 0.0)-ISNULL(d.CantidadCancelada, 0.0)), d.CantidadObsequio, d.CantidadInventario, ISNULL(d.CantidadReservada, 0.0), ISNULL(d.CantidadOrdenada, 0.0), ISNULL(d.CantidadPendiente, 0.0), ISNULL(d.CantidadA, 0.0), NULLIF(RTRIM(d.Unidad), ''), ISNULL(d.Factor, 0.0), NULLIF(RTRIM(d.Articulo), ''), NULLIF(RTRIM(d.Subcuenta), ''), CONVERT(varchar(20), NULL), CONVERT(varchar(20), NULL), NULLIF(RTRIM(d.SustitutoArticulo), ''), NULLIF(RTRIM(d.SustitutoSubcuenta), ''), ISNULL(d.Costo, 0.0), ISNULL(d.Precio, 0.0), NULLIF(RTRIM(d.DescuentoTipo), ''), ISNULL(d.DescuentoLinea, 0.0), ISNULL(d.Impuesto1, 0.0), ISNULL(d.Impuesto2, 0.0), ISNULL(d.Impuesto3, 0.0), NULLIF(RTRIM(d.Aplica), ''), d.AplicaID, NULLIF(RTRIM(d.Almacen), ''), RTRIM(UPPER(a.Tipo)), a.SerieLoteInfo, ISNULL(NULLIF(RTRIM(UPPER(a.TipoOpcion)), ''), 'NO'), RTRIM(UPPER(a.TipoCompra)), a.SeProduce, a.SeCompra, a.EsFormula, NULLIF(RTRIM(a.Unidad), ''), ISNULL(a.PrecioMinimo, 0.0), NULLIF(RTRIM(a.MonedaPrecio), ''), ISNULL(a.MargenMinimo, 0.0), NULLIF(RTRIM(a.MonedaCosto), ''), CONVERT(char, NULL), CONVERT(char, NULL), CONVERT(int, NULL), CONVERT(int, NULL), CONVERT(char, NULL), CONVERT(char, NULL), CONVERT(char, NULL), NULLIF(a.CantidadMinimaVenta, 0), NULLIF(a.CantidadMaximaVenta, 0), CONVERT(int, NULL), CONVERT(datetime, NULL), a.Actividades, d.FechaRequerida, d.Paquete, 0, d.PrecioTipoCambio
FROM VentaD d WITH (NOLOCK), Art a WITH (NOLOCK)
WHERE d.ID = @ID
AND d.Articulo = a.Articulo
ELSE
IF @Modulo = 'COMS'
DECLARE crVerificarDetalle CURSOR
FOR SELECT 0, d.Renglon, d.RenglonSub, d.RenglonID, d.RenglonTipo, (ISNULL(d.Cantidad, 0.0)-ISNULL(d.CantidadCancelada, 0.0)), CONVERT(float, NULL), d.CantidadInventario, d.Cantidad, d.Cantidad, ISNULL(d.CantidadPendiente, 0.0), ISNULL(d.CantidadA, 0.0), NULLIF(RTRIM(d.Unidad), ''), d.Factor, NULLIF(RTRIM(d.Articulo), ''), NULLIF(RTRIM(d.Subcuenta), ''), CONVERT(varchar(20), NULL), CONVERT(varchar(20), NULL), convert(char(20), NULL), convert(char(20), NULL), ISNULL(d.Costo, 0.0), ISNULL(d.Costo, 0.0), NULLIF(RTRIM(d.DescuentoTipo), ''), ISNULL(d.DescuentoLinea, 0.0), ISNULL(d.Impuesto1, 0.0), ISNULL(d.Impuesto2, 0.0), ISNULL(d.Impuesto3, 0.0), NULLIF(RTRIM(d.Aplica), ''), d.AplicaID, NULLIF(RTRIM(d.Almacen), ''), NULLIF(RTRIM(UPPER(a.Tipo)), ''), a.SerieLoteInfo, ISNULL(NULLIF(RTRIM(UPPER(a.TipoOpcion)), ''), 'NO'), RTRIM(UPPER(a.TipoCompra)), a.SeProduce, a.SeCompra, a.EsFormula, NULLIF(RTRIM(a.Unidad), ''), ISNULL(a.PrecioMinimo, 0.0), NULLIF(RTRIM(a.MonedaPrecio), ''), ISNULL(a.MargenMinimo, 0.0), NULLIF(RTRIM(a.MonedaCosto), ''), CONVERT(char, NULL), CONVERT(char, NULL), CONVERT(int, NULL), CONVERT(int, NULL), CONVERT(char, NULL), CONVERT(char, NULL), CONVERT(char, NULL), CONVERT(float, NULL), CONVERT(float, NULL), CASE WHEN a.TieneCaducidad=1 THEN NULLIF(a.CaducidadMinima, 0) ELSE CONVERT(int, NULL) END, d.FechaCaducidad, a.Actividades, d.FechaRequerida, d.Paquete, d.EsEstadistica, CONVERT(float, NULL)
FROM CompraD d WITH (NOLOCK), Art a WITH (NOLOCK)
WHERE d.ID = @ID
AND d.Articulo = a.Articulo
ELSE
IF @Modulo = 'INV'
DECLARE crVerificarDetalle CURSOR
FOR SELECT 0, d.Renglon, d.RenglonSub, d.RenglonID, d.RenglonTipo, (ISNULL(d.Cantidad, 0.0)-ISNULL(d.CantidadCancelada, 0.0)), CONVERT(float, NULL), d.CantidadInventario, ISNULL(d.CantidadReservada, 0.0), ISNULL(d.CantidadOrdenada, 0.0), ISNULL(d.CantidadPendiente, 0.0), ISNULL(d.CantidadA, 0.0), NULLIF(RTRIM(d.Unidad), ''), d.Factor, NULLIF(RTRIM(d.Articulo), ''), NULLIF(RTRIM(d.Subcuenta), ''), NULLIF(RTRIM(d.ArticuloDestino), ''), NULLIF(RTRIM(d.SubCuentaDestino), ''), convert(char(20), NULL), convert(char(20), NULL), ISNULL(d.Costo, 0.0), CONVERT(money, NULL), '$', CONVERT(money, NULL), CONVERT(float, NULL), CONVERT(float, NULL), CONVERT(money, NULL), NULLIF(RTRIM(d.Aplica), ''), d.AplicaID, NULLIF(RTRIM(d.Almacen), ''), NULLIF(RTRIM(UPPER(a.Tipo)), ''), a.SerieLoteInfo, ISNULL(NULLIF(RTRIM(UPPER(a.TipoOpcion)), ''), 'NO'), RTRIM(UPPER(a.TipoCompra)), a.SeProduce, a.SeCompra, a.EsFormula, NULLIF(RTRIM(a.Unidad), ''), ISNULL(a.PrecioMinimo, 0.0), NULLIF(RTRIM(a.MonedaPrecio), ''), ISNULL(a.MargenMinimo, 0.0), NULLIF(RTRIM(a.MonedaCosto), ''), NULLIF(RTRIM(d.ProdSerieLote), ''), CONVERT(char, NULL), CONVERT(int, NULL), CONVERT(int, NULL), CONVERT(char, NULL), CONVERT(char, NULL), d.Tipo, CONVERT(float, NULL), CONVERT(float, NULL), CONVERT(int, NULL), CONVERT(datetime, NULL), a.Actividades, CONVERT(datetime, NULL), d.Paquete, 0, CONVERT(float, NULL)
FROM InvD d WITH (NOLOCK), Art a WITH (NOLOCK)
WHERE d.ID = @ID
AND d.Articulo = a.Articulo
ELSE
IF @Modulo = 'PROD'
DECLARE crVerificarDetalle CURSOR
FOR SELECT d.AutoGenerado, d.Renglon, d.RenglonSub, d.RenglonID, d.RenglonTipo, (ISNULL(d.Cantidad, 0.0)-ISNULL(d.CantidadCancelada, 0.0)), CONVERT(float, NULL), d.CantidadInventario, ISNULL(d.CantidadReservada, 0.0), ISNULL(d.CantidadOrdenada, 0.0), ISNULL(d.CantidadPendiente, 0.0), ISNULL(d.CantidadA, 0.0), NULLIF(RTRIM(d.Unidad), ''), d.Factor, NULLIF(RTRIM(d.Articulo), ''), NULLIF(RTRIM(d.Subcuenta), ''), convert(varchar(20), NULL), convert(varchar(20), NULL), convert(char(20), NULL), convert(char(20), NULL), ISNULL(d.Costo, 0.0), CONVERT(money, NULL), '$', CONVERT(money, NULL), CONVERT(float, NULL), CONVERT(float, NULL), CONVERT(money, NULL), NULLIF(RTRIM(d.Aplica), ''), d.AplicaID, NULLIF(RTRIM(d.Almacen), ''), NULLIF(RTRIM(UPPER(a.Tipo)), ''), a.SerieLoteInfo, ISNULL(NULLIF(RTRIM(UPPER(a.TipoOpcion)), ''), 'NO'), RTRIM(UPPER(a.TipoCompra)), a.SeProduce, a.SeCompra, a.EsFormula, NULLIF(RTRIM(a.Unidad), ''), ISNULL(a.PrecioMinimo, 0.0), NULLIF(RTRIM(a.MonedaPrecio), ''), ISNULL(a.MargenMinimo, 0.0), NULLIF(RTRIM(a.MonedaCosto), ''), NULLIF(RTRIM(d.ProdSerieLote), ''), NULLIF(RTRIM(d.Ruta), ''), d.Orden, d.OrdenDestino, NULLIF(RTRIM(d.Centro), ''), NULLIF(RTRIM(d.CentroDestino), ''), d.Tipo, CONVERT(float, NULL), CONVERT(float, NULL), CONVERT(int, NULL), CONVERT(datetime, NULL), a.Actividades, CONVERT(datetime, NULL), d.Paquete, 0, CONVERT(float, NULL)
FROM ProdD d WITH (NOLOCK), Art a WITH (NOLOCK)
WHERE d.ID = @ID
AND d.Articulo = a.Articulo
SELECT @AfectarAlgo   	      = 0,
@SumaCantidadOriginal	      = 0,
@SumaCantidadPendiente	      = 0,
@SumaImporteNeto             = 0.0,
@SumaImpuestosNetos          = 0.0,
@SumaImporteNetoSinAutorizar    = 0.0,
@SumaImpuestosNetosSinAutorizar = 0.0
IF @OK IS NULL
BEGIN
OPEN crVerificarDetalle
FETCH NEXT FROM crVerificarDetalle INTO @AutoGenerado, @Renglon, @RenglonSub, @RenglonID, @RenglonTipo, @CantidadOriginal, @CantidadObsequio, @CantidadInventario, @CantidadReservada, @CantidadOrdenada, @CantidadPendiente, @CantidadA, @MovUnidad, @Factor, @Articulo, @Subcuenta, @ArticuloDestino, @SubCuentaDestino, @SustitutoArticulo, @SustitutoSubCuenta, @Costo, @Precio, @DescuentoTipo, @DescuentoLinea, @Impuesto1, @Impuesto2, @Impuesto3, @AplicaMov, @AplicaMovID, @AlmacenRenglon, @ArtTipo, @ArtSerieLoteInfo, @ArtTipoOpcion, @ArtTipoCompra, @ArtSeProduce, @ArtSeCompra, @ArtEsFormula, @ArtUnidad, @ArtPrecioMinimo, @ArtMonedaVenta, @ArtMargenMinimo, @ArtMonedaCosto, @ProdSerieLote, @ProdRuta, @ProdOrden, @ProdOrdenDestino, @ProdCentro, @ProdCentroDestino, @DetalleTipo, @CantidadMinimaVenta, @CantidadMaximaVenta, @ArtCaducidadMinima, @FechaCaducidad, @ArtActividades, @FechaRequeridaD, @Paquete, @EsEstadistica, @PrecioTipoCambio
IF @@ERROR <> 0 SELECT @Ok = 1
WHILE @@FETCH_STATUS <> -1 AND @Ok IS NULL
BEGIN
SELECT @SeriesLotesAutoOrden = ISNULL(NULLIF(NULLIF(RTRIM(UPPER(SeriesLotesAutoOrden)), ''), '(EMPRESA)'), @CfgSeriesLotesAutoOrden)
FROM Art WITH (NOLOCK)
WHERE Articulo = @Articulo
IF @PPTO = 1 AND @Accion <> 'CANCELAR' AND (@Modulo = 'COMS' OR (@Modulo = 'VTAS' AND @PPTOVentas = 1))
IF (SELECT NULLIF(RTRIM(CuentaPresupuesto), '') FROM Art WITH (NOLOCK) WHERE Articulo = @Articulo) IS NULL
BEGIN
SELECT @Ok = 40035, @OkRef = @Articulo
EXEC xpOk_40035 @Empresa, @Usuario, @Accion, @Modulo, @ID, @Ok OUTPUT, @OkRef OUTPUT
END
SELECT @Importe		     = 0.0,
@ImporteNeto	     = 0.0,
@Impuestos 	     = 0.0,
@ImpuestosNetos	     = 0.0,
@DescuentoLineaImporte  = 0.0,
@DescuentoGlobalImporte = 0.0,
@SobrePrecioImporte     = 0.0,
@IDAplica		     = NULL,
@AplicaAutorizacion     = NULL,
@AplicaCondicion	     = NULL,
@AplicaMovTipo 	     = NULL,
@AplicaControlAnticipos = NULL
IF @ValidarFechaRequerida = 1
IF @FechaRequeridaD IS NULL SELECT @Ok = 25120 ELSE
IF @FechaRequeridaD < @FechaEmision SELECT @Ok = 25121
IF @CfgCompraValidarArtProv = 1 AND @Modulo = 'COMS' AND @MovTipo NOT IN ('COMS.R')
IF NOT EXISTS(SELECT * FROM ArtProv WITH (NOLOCK) WHERE Articulo = @Articulo AND ISNULL(NULLIF(RTRIM(SubCuenta), ''), '') = ISNULL(NULLIF(RTRIM(@SubCuenta), ''), '') AND Proveedor = @ClienteProv)
SELECT @Ok = 26040, @OkRef = RTRIM(@Articulo)+' '+RTRIM(@SubCuenta)
IF @MovTipo = 'INV.EP'
BEGIN
EXEC spMovGastoIndirectoSugerir @Empresa, @Modulo, @ID
IF @ArtSeProduce = 0 OR @ArtTipo NOT IN ('SERIE', 'VIN', 'LOTE', 'PARTIDA') SELECT @Ok = 20076, @OkRef = @Articulo
END
IF @ArtTipoOpcion IN ('NO', NULL) AND @Subcuenta IS NOT NULL SELECT @Ok = 20740, @OkRef = @Articulo
EXEC xpOk_20740 @Empresa, @Usuario, @Accion, @Modulo, @ID, @Ok OUTPUT, @OkRef OUTPUT
IF @AplicaMov IS NOT NULL AND @AplicaMovID IS NOT NULL
BEGIN
IF @Modulo = 'VTAS' SELECT @IDAplica = ID, @AplicaAutorizacion = NULLIF(RTRIM(Autorizacion), ''), @AplicaCondicion = Condicion FROM Venta WITH (NOLOCK) WHERE Empresa = @Empresa AND Mov = @AplicaMov AND MovID = @AplicaMovID AND Estatus NOT IN ('SINAFECTAR', 'BORRADOR', 'CONFIRMAR', 'CANCELADO') ELSE
IF @Modulo = 'COMS' SELECT @IDAplica = ID, @AplicaAutorizacion = NULLIF(RTRIM(Autorizacion), '') FROM Compra WITH (NOLOCK) WHERE Empresa = @Empresa AND Mov = @AplicaMov AND MovID = @AplicaMovID AND Estatus NOT IN ('SINAFECTAR', 'BORRADOR', 'CONFIRMAR', 'CANCELADO') ELSE
IF @Modulo = 'INV'  SELECT @IDAplica = ID, @AplicaAutorizacion = NULLIF(RTRIM(Autorizacion), '') FROM Inv WITH (NOLOCK)   WHERE Empresa = @Empresa AND Mov = @AplicaMov AND MovID = @AplicaMovID AND Estatus NOT IN ('SINAFECTAR', 'BORRADOR', 'CONFIRMAR', 'CANCELADO') ELSE
IF @Modulo = 'PROD' SELECT @IDAplica = ID, @AplicaAutorizacion = NULLIF(RTRIM(Autorizacion), '') FROM Prod WITH (NOLOCK)  WHERE Empresa = @Empresa AND Mov = @AplicaMov AND MovID = @AplicaMovID AND Estatus NOT IN ('SINAFECTAR', 'BORRADOR', 'CONFIRMAR', 'CANCELADO')
EXEC spAplicaOk @Empresa, @Usuario, @Modulo, @IDAplica, @Ok OUTPUT, @OkRef OUTPUT
IF @AplicaAutorizacion IS NOT NULL AND @Autorizacion IS NULL AND @CfgAutoAutorizacionFacturas = 1 SELECT @Autorizacion = @AplicaAutorizacion
END ELSE
BEGIN
IF @MovTipo = 'INV.DTI' AND @Accion <> 'GENERAR' SELECT @Ok = 25410
END
IF @AplicaMov <> NULL
BEGIN
SELECT @AplicaMovTipo = NULL
SELECT @AplicaMovTipo = MIN(Clave) FROM MovTipo WITH (NOLOCK) WHERE Modulo = @Modulo AND Mov = @AplicaMov
IF @Modulo = 'VTAS' AND @AplicaMovTipo IS NULL SELECT @AplicaMovTipo = MIN(Clave) FROM MovTipo WITH (NOLOCK) WHERE Modulo = 'CXC' AND Mov = @AplicaMov ELSE
IF @Modulo = 'COMS' AND @AplicaMovTipo IS NULL SELECT @AplicaMovTipo = MIN(Clave) FROM MovTipo WITH (NOLOCK) WHERE Modulo = 'CXP' AND Mov = @AplicaMov
IF @AplicaMovTipo IN ('VTAS.P', 'VTAS.S', 'VTAS.SD')
SELECT @AplicaControlAnticipos = ISNULL(NULLIF(RTRIM(UPPER(ControlAnticipos)), ''), 'NO') FROM Condicion WHERE Condicion = @AplicaCondicion
END
IF @MovTipo IN ('VTAS.F','VTAS.FAR', 'VTAS.FC', 'VTAS.FG', /*'VTAS.FX',*/'VTAS.FB') AND @CfgBloquearFacturacionDirecta = 1 AND @AplicaMovTipo IS NULL AND @Accion NOT IN ('GENERAR', 'CANCELAR')
SELECT @Ok = 25415
IF @Accion <> 'GENERAR'
BEGIN
IF @Modulo = 'VTAS' AND @Accion <> 'CANCELAR' AND @MovTipo NOT IN ('VTAS.PR', 'VTAS.D', 'VTAS.DF', 'VTAS.DFC', 'VTAS.B', 'VTAS.CO', 'VTAS.VP')
BEGIN
IF @CantidadMinimaVenta IS NOT NULL AND @CantidadOriginal < @CantidadMinimaVenta SELECT @Ok = 20011, @OkRef = @Articulo ELSE
IF @CantidadMaximaVenta IS NOT NULL AND @CantidadOriginal > @CantidadMaximaVenta SELECT @Ok = 20013, @OkRef = @Articulo
END
IF @CobrarPedido = 1
BEGIN
IF @MovTipo IN ('VTAS.C', 'VTAS.CS', 'VTAS.P', 'VTAS.P', 'VTAS.SD', 'VTAS.B')
BEGIN
IF @AplicaMovTipo IS NOT NULL AND @AplicaControlAnticipos = 'COBRAR PEDIDO'
SELECT @Ok = 20880
END ELSE
IF @MovTipo IN ('VTAS.F','VTAS.FAR', 'VTAS.FB', 'VTAS.VP', 'VTAS.D', 'VTAS.DF', 'VTAS.DFC', 'VTAS.N', 'VTAS.NO', 'VTAS.NR', 'VTAS.FM')
BEGIN
IF @AplicaMovTipo NOT IN ('VTAS.P', 'VTAS.S', 'VTAS.SD') OR @AplicaControlAnticipos <> 'COBRAR PEDIDO'
SELECT @Ok = 20880
END ELSE SELECT @Ok = 20880
END ELSE
IF @AplicaControlAnticipos = 'COBRAR PEDIDO' SELECT @Ok = 20880
IF @Ok = 20880
EXEC xpOk_20880 @Empresa, @Usuario, @Accion, @Modulo, @ID, @Ok OUTPUT, @OkRef OUTPUT
END
IF @Modulo = 'PROD' AND @MovTipo <> 'PROD.O' AND @Accion NOT IN ('CANCELAR', 'GENERAR') AND @ProdSerieLote IS NOT NULL
BEGIN
SELECT @AplicaMovTipo = 'PROD.O', @AplicaMov = Mov, @AplicaMovID = MovID, @ProdRuta = Ruta
FROM ProdSerieLotePendiente WITH (NOLOCK)
WHERE Empresa = @Empresa AND ProdSerieLote = @ProdSerieLote AND Articulo = @Articulo AND SubCuenta = @SubCuenta
UPDATE ProdD WITH (ROWLOCK)
SET Aplica   = @AplicaMov,
AplicaID = @AplicaMovID,
Ruta     = @ProdRuta
WHERE CURRENT OF crVerificarDetalle
END
IF @AutoGenerado = 1 AND @Accion = 'AFECTAR' SELECT @Ok = 60270
IF @Utilizar = 1 AND @Base <> 'TODO' SELECT @UtilizarEstatus = 'PENDIENTE' ELSE SELECT @UtilizarEstatus = @Estatus
IF @ArtEsFormula = 1 SELECT @Ok = 20750
IF @Modulo = 'COMS' AND @CfgLimitarCompraLocal = 1 AND (@ArtSeCompra = 0 OR @ArtTipoCompra <> 'LOCAL') SELECT @Ok = 20760
IF @ArtTipoOpcion = 'SI' AND @Estatus IN ('SINAFECTAR', 'BORRADOR', 'CONFIRMAR') AND @Accion <> 'CANCELAR' AND @Ok IS NULL
EXEC spOpcionValidar @Articulo, @SubCuenta, @Accion, @Ok OUTPUT, @OkRef
SELECT @Almacen = @AlmacenOriginal, @AlmacenDestino = @AlmacenDestinoOriginal
IF @AfectarAlmacenRenglon = 1 SELECT @Almacen = NULLIF(RTRIM(@AlmacenRenglon), '')
IF @AlmacenEspecifico IS NOT NULL SELECT @Almacen = @AlmacenEspecifico
IF @VoltearAlmacen = 1 SELECT @AlmacenTemp = @Almacen, @Almacen = @AlmacenDestino, @AlmacenDestino = @AlmacenTemp
IF @EsTransferencia = 0 AND @MovTipo NOT IN ('INV.OT', 'INV.TI') SELECT @AlmacenDestino = NULL
IF @MovTipo = 'INV.EI' SELECT @AlmacenDestino = @AlmacenOriginal /** JH 28.07.2006 **/
IF @Almacen IS NOT NULL
BEGIN
SELECT @AlmacenTipo = UPPER(Tipo), @AlmacenSucursal = Sucursal FROM Alm WITH (NOLOCK) WHERE Almacen = @Almacen
IF @AlmacenTipo = 'ESTRUCTURA' SELECT @Ok = 20680, @OkRef = @Almacen
IF @CfgControlAlmacenes = 1 AND @Accion <> 'CANCELAR' AND @MovTipo NOT IN ('INV.TI', 'INV.DTI')
IF NOT EXISTS(SELECT * FROM UsuarioAlm WITH (NOLOCK) WHERE Usuario = @Usuario AND Almacen = @Almacen)
SELECT @Ok = 20660, @OkRef = @Almacen
IF @AlmacenSucursal <> ISNULL(@SucursalDestino, @Sucursal) AND @Accion <> 'SINCRO' AND @MovTipo NOT IN ('INV.TI', 'INV.DTI', 'INV.TIF', 'INV.TIS', 'VTAS.PR', 'COMS.PR', 'VTAS.EST', 'COMS.EST') AND @SeguimientoMatriz = 0
BEGIN
EXEC spSucursalEnLinea @AlmacenSucursal, @EnLinea OUTPUT
IF @EnLinea = 0
SELECT @Ok = 20780, @OkRef = @Almacen
END
END
IF @AlmacenDestino IS NOT NULL AND @MovTipo <> 'INV.EI' /** JH 06.09.2006 **/
BEGIN
SELECT @AlmacenDestinoTipo = UPPER(Tipo), @AlmacenDestinoSucursal = Sucursal FROM Alm WITH (NOLOCK) WHERE Almacen = @AlmacenDestino
IF @AlmacenDestinoTipo = 'ESTRUCTURA' SELECT @Ok = 20680, @OkRef = @AlmacenDestino
IF @CfgControlAlmacenes = 1 AND @Accion <> 'CANCELAR' AND @MovTipo NOT IN ('INV.TI', 'INV.DTI')
IF NOT EXISTS(SELECT * FROM UsuarioAlm WITH (NOLOCK) WHERE Usuario = @Usuario AND Almacen = @AlmacenDestino)
SELECT @Ok = 20660, @OkRef = @AlmacenDestino
IF @AlmacenDestinoSucursal <> ISNULL(@SucursalDestino, @Sucursal) AND @Accion NOT IN ('SINCRO', 'CANCELAR', 'GENERAR')
BEGIN
SELECT @Ok = 20790, @OkRef = @AlmacenDestino
END
END
IF @Accion IN ('AFECTAR', 'VERIFICAR') AND @MovTipo = 'INV.EI' AND @Almacen <> @AlmacenDestinoOriginal SELECT @Ok = 20120
IF @Accion IN ('AFECTAR', 'VERIFICAR') AND @MovTipo = 'INV.EI' AND @AplicaMovTipo <> 'INV.TI' SELECT @Ok = 25410
IF @Accion IN ('AFECTAR', 'VERIFICAR') AND @MovTipo IN ('PROD.A', 'PROD.R', 'PROD.E') AND @AplicaMovTipo <> 'PROD.O' AND UPPER(@DetalleTipo) NOT IN ('MERMA', 'DESPERDICIO') SELECT @Ok = 25280
IF @Accion = 'AFECTAR' AND @MovTipo = 'VTAS.VP' AND @AplicaMovTipo NOT IN (NULL, 'VTAS.P', 'VTAS.S') SELECT @Ok = 20197
IF @Accion = 'AFECTAR' AND @MovTipo IN ('INV.TIF', 'INV.TIS') AND @AplicaMovTipo <> 'INV.TI' SELECT @Ok = 20180
IF @EsTransferencia = 1 AND @Accion <> 'GENERAR' AND @Ok IS NULL
BEGIN
IF @AlmacenDestino = @Almacen OR @AlmacenDestino IS NULL SELECT @Ok = 20120
ELSE
IF @AlmacenTipo <> @AlmacenDestinoTipo AND NOT (@AlmacenTipo IN ('NORMAL','PROCESO') AND @AlmacenDestinoTipo IN ('NORMAL','PROCESO'))
IF (@AlmacenTipo IN ('NORMAL','PROCESO','GARANTIAS') OR @AlmacenDestinoTipo IN ('NORMAL','PROCESO','GARANTIAS'))
BEGIN
IF @CfgInvPrestamosGarantias = 0 OR @MovTipo NOT IN ('INV.P', 'INV.R')
SELECT @Ok = 40130
END ELSE SELECT @Ok = 40130
END
IF @Modulo = 'VTAS' AND @ServicioGarantia = 1 AND (@AlmacenTipo <> 'GARANTIAS' OR @MovTipo NOT IN ('VTAS.S','VTAS.SG','VTAS.EG')) AND @Ok IS NULL
SELECT @Ok = 20440
IF @ArtActividades = 1 AND @MovTipo IN ('VTAS.F','VTAS.FAR', 'VTAS.FC', 'VTAS.FG', 'VTAS.FX','VTAS.FB') AND @Accion NOT IN ('CANCELAR', 'GENERAR') AND @CantidadOriginal > 0.0
IF EXISTS(SELECT * FROM VentaDAgente WITH (NOLOCK) WHERE ID = @ID AND Renglon = @Renglon AND RenglonSub = @RenglonSub AND UPPER(Estado) NOT IN ('COMPLETADA', 'CANCELADA', 'CONCLUIDA'))
SELECT @Ok = 20496
EXEC spInvInitRenglon @Empresa, @CfgDecimalesCantidades, @CfgMultiUnidades, @CfgMultiUnidadesNivel, @CfgCompraFactorDinamico, @CfgInvFactorDinamico, @CfgProdFactorDinamico, @CfgVentaFactorDinamico, @CfgBloquearNotasNegativas,
1, 0, @Accion, @Base, @Modulo, @ID, @Renglon, @RenglonSub, @UtilizarEstatus, @EstatusNuevo, @MovTipo, @FacturarVtasMostrador, @EsTransferencia, @AfectarConsignacion, 0, @AlmacenTipo, @AlmacenDestinoTipo,
@Articulo, @MovUnidad, @ArtUnidad, @ArtTipo, @RenglonTipo,
@AplicaMovTipo, @CantidadOriginal, @CantidadInventario, @CantidadPendiente, @CantidadA, @DetalleTipo,
@Cantidad OUTPUT, @CantidadCalcularImporte OUTPUT, @CantidadReservada OUTPUT, @CantidadOrdenada OUTPUT, @EsEntrada OUTPUT, @EsSalida OUTPUT, @SubCuenta OUTPUT,
@AfectarPiezas OUTPUT, @AfectarCostos OUTPUT, @AfectarUnidades OUTPUT, @Factor OUTPUT,
@Ok OUTPUT, @OkRef OUTPUT
IF @AplicaMovTipo IN ('VTAS.F','VTAS.FAR', 'VTAS.FC', 'VTAS.FG', 'VTAS.FX','VTAS.FB') SELECT @Ok = 20180 ELSE
IF @Almacen IS NULL AND @Accion <> 'GENERAR' SELECT @Ok = 20390 ELSE
IF @Articulo IS NULL SELECT @Ok = 20400 ELSE
IF @Cantidad = 0.0 AND @Base = 'TODO' AND @AutoCorrida IS NULL AND @MovTipo <> 'INV.IF' SELECT @Ok = 20015 ELSE
IF @Cantidad < 0.0 AND @ArtTipo <> 'SERVICIO' AND @FacturarVtasMostrador = 0 AND @Accion <> 'CANCELAR' AND @MovTipo NOT IN ('VTAS.EST', 'INV.EST') SELECT @OK = 20010 ELSE
IF @Accion = 'CANCELAR' AND @Base = 'SELECCION' AND ROUND(@Cantidad, 4) > ROUND(@CantidadPendiente + @CantidadReservada, 4) SELECT @Ok = 20010
IF @CfgMultiUnidades = 1 AND @MovUnidad IS NULL AND @Accion <> 'CANCELAR' SELECT @Ok = 20150 ELSE
IF @AplicaMov IS NOT NULL AND @FacturarVtasMostrador = 1 SELECT @Ok = 20102 ELSE
IF @Accion IN ('RESERVAR','ASIGNAR') AND @Cantidad > @CantidadPendiente SELECT @Ok = 20160 ELSE
IF @Accion = 'DESRESERVAR' AND @Cantidad > @CantidadReservada SELECT @Ok = 20165 ELSE
IF @Accion = 'DESASIGNAR'  AND @Cantidad > @CantidadOrdenada  SELECT @Ok = 20167
IF @FacturarVtasMostrador = 1 AND (@AplicaMov IS NOT NULL OR @AplicaMovID IS NOT NULL) SELECT @Ok = 20180
IF @ArtTipo = 'PARTIDA' AND @ArtTipoOpcion = 'MATRIZ'
IF NOT EXISTS(SELECT * FROM ArtRenglon WITH (NOLOCK) WHERE Renglon = @SubCuenta) SELECT @Ok = 20045
/** JH 06.09.2006 **/
IF ((@Modulo = 'PROD' OR (@MovTipo IN ('INV.SM', 'INV.CM'))) AND @Accion NOT IN ('CANCELAR', 'GENERAR') AND @OrigenTipo <> 'INV/EP')
BEGIN
IF @MovTipo IN ('PROD.O', 'PROD.A', 'PROD.R') AND @ProdRuta IS NULL SELECT @Ok = 25300 
IF @MovTipo = 'PROD.E'
BEGIN
IF @ProdCentro IS NULL /*OR @ProdOrden IS NULL */SELECT @Ok = 25040
ELSE BEGIN
EXEC spProdUltimoCentro @Empresa, @Articulo, @SubCuenta, @ProdSerieLote, @ProdRuta, @ProdOrdenFinal OUTPUT
IF @ProdOrden IS NULL SELECT @ProdOrden = @ProdOrdenFinal  
IF @ProdOrden <> @ProdOrdenFinal
SELECT @Ok = 25350, @OkRef = @ProdCentro
END
END
IF @MovTipo IN ('PROD.A', 'PROD.R')
BEGIN
IF @ProdCentro IS NULL OR @ProdOrden IS NULL SELECT @Ok = 25040 ELSE
IF (@ProdCentroDestino IS NULL) OR (@ProdCentro = @ProdCentroDestino) SELECT @Ok = 25330
ELSE
BEGIN
EXEC spProdAvanceAlCentro @Empresa, @MovTipo, @Articulo, @SubCuenta, @ProdSerieLote, @ProdRuta, @ProdOrden, @ProdOrdenSiguiente OUTPUT, @ProdCentro, @ProdCentroSiguiente OUTPUT, @ProdEstacion, @ProdEstacionDestino OUTPUT, @Verificar = 1
IF @ProdCentroDestino <> @ProdCentroSiguiente
SELECT @Ok = 25340, @OkRef = @ProdCentroDestino
END
IF @Ok IS NULL
IF NOT EXISTS(SELECT * FROM ProdSerieLotePendiente WITH (NOLOCK) WHERE Empresa = @Empresa AND ProdSerieLote = @ProdSerieLote AND Articulo = @Articulo AND SubCuenta = @SubCuenta AND Orden = @ProdOrden AND Centro = @ProdCentro)
SELECT @Ok = 25350, @OkRef = @ProdCentro
END
IF @ProdSerieLote IS NULL
SELECT @Ok = 25230 
IF @MovTipo = 'INV.CM' AND NOT EXISTS(SELECT * FROM ProdSerieLotePendiente WITH (NOLOCK) WHERE Empresa = @Empresa AND ProdSerieLote = @ProdSerieLote)
SELECT @Ok = 25250, @OkRef = @ProdSerieLote
IF @Ok IS NULL
BEGIN
IF @MovTipo = 'PROD.O'
BEGIN
IF EXISTS(SELECT * FROM ProdSerieLotePendiente WITH (NOLOCK) WHERE Empresa = @Empresa AND ProdSerieLote = @ProdSerieLote AND CantidadPendiente > 0.0 AND ID <> @ID)
SELECT @Ok = 25245
END ELSE
BEGIN
IF NOT EXISTS (SELECT * FROM ProdSerieLote WITH (NOLOCK) WHERE Empresa = @Empresa AND ProdSerieLote = @ProdSerieLote AND CantidadOrdenada > 0.0)
SELECT @Ok = 25250
END
END
/*IF @Ok IS NULL
BEGIN
SELECT @ProdOrdenID = NULL
SELECT @ProdOrdenID = MIN(ID) FROM ProdSerieLotePendiente WHERE Empresa = @Empresa AND ProdSerieLote = @ProdSerieLote
IF @ProdOrdenID IS NULL
BEGIN
IF @MovTipo <> 'PROD.O' SELECT @Ok = 25250
END ELSE
BEGIN
IF @MovTipo = 'PROD.O'
SELECT @Ok = 25240
ELSE
BEGIN
IF @Modulo = 'PROD' UPDATE ProdD SET OPID = @ProdOrdenID WHERE CURRENT OF crVerificarDetalle ELSE
IF @Modulo = 'INV'  UPDATE InvD  SET OPID = @ProdOrdenID WHERE CURRENT OF crVerificarDetalle
END
END
END
IF @MovTipo IN ('INV.SM', 'INV.CM') AND @Ok IS NULL
BEGIN
IF NOT EXISTS(SELECT * FROM ProdSerieLoteMaterialPendiente WHERE Empresa = @Empresa AND ProdSerieLote = @ProdSerieLote AND Articulo = @Articulo AND SubCuenta = @SubCuenta)
SELECT @Ok = 25260
END*/
IF @Ok IS NOT NULL AND @OkRef IS NULL SELECT @OkRef = @ProdSerieLote
END
IF @MovTipo = 'PROD.O' AND @Accion = 'CANCELAR' AND @Ok IS NULL
IF ROUND((SELECT SUM(ISNULL(Cargo, 0.0) - ISNULL(Abono, 0.0)) FROM ProdSerieLoteCosto WITH (NOLOCK) WHERE Empresa = @Empresa AND ProdSerieLote = @ProdSerieLote), @RedondeoMonetarios) <> 0.0
SELECT @Ok = 25370, @OkRef = @ProdSerieLote
IF @Estatus IN ('SINAFECTAR', 'BORRADOR', 'CONFIRMAR') AND @Accion NOT IN ('CANCELAR', 'GENERAR') AND @OrigenTipo <> 'VMOS'
BEGIN
IF @RenglonTipo = 'J'
EXEC spInvValidarJuego @Empresa, @Modulo, @ID, @Almacen, @RenglonID, @Articulo, @Cantidad, @Ok OUTPUT, @OkRef OUTPUT
IF @RenglonTipo IN ('C', 'E')
BEGIN
IF @Modulo = 'VTAS' IF NOT EXISTS(SELECT * FROM VentaD  WITH (NOLOCK) WHERE ID = @ID AND RenglonID = @RenglonID AND RenglonTipo = 'J') SELECT @Ok = 20620 ELSE
IF @Modulo = 'COMS' IF NOT EXISTS(SELECT * FROM CompraD WITH (NOLOCK) WHERE ID = @ID AND RenglonID = @RenglonID AND RenglonTipo = 'J') SELECT @Ok = 20620 ELSE
IF @Modulo = 'INV'  IF NOT EXISTS(SELECT * FROM InvD    WITH (NOLOCK) WHERE ID = @ID AND RenglonID = @RenglonID AND RenglonTipo = 'J') SELECT @Ok = 20620 ELSE
IF @Modulo = 'PROD' IF NOT EXISTS(SELECT * FROM ProdD   WITH (NOLOCK) WHERE ID = @ID AND RenglonID = @RenglonID AND RenglonTipo = 'J') SELECT @Ok = 20620
END
IF @Ok = 20620
EXEC xpOk_20620 @Empresa, @Usuario, @Accion, @Modulo, @ID, @Renglon, @RenglonSub, @Ok OUTPUT, @OkRef OUTPUT
END
IF @@FETCH_STATUS <> -2 AND @Cantidad <> 0.0 AND @Ok IS NULL
BEGIN
IF @AlmacenTipo = 'ACTIVOS FIJOS'
BEGIN
SELECT @CategoriaActivoFijo = NULL
SELECT @CategoriaActivoFijo = NULLIF(RTRIM(CategoriaActivoFijo), '') FROM Art WITH (NOLOCK) WHERE Articulo = @Articulo
--Cambio Por isgarcia
IF (@ArtTipo NOT IN ('SERIE','VIN','SERVICIO') OR @CfgSeriesLotesMayoreo = 0) SELECT @Ok = 44010 ELSE
IF @CategoriaActivoFijo IS NULL AND @ArtTipo <> 'SERVICIO' SELECT @Ok = 44110 ELSE
IF @Modulo IN ('VTAS', 'COMS') AND (SELECT UPPER(Propietario) FROM ActivoFCat WITH (NOLOCK) WHERE Categoria = @CategoriaActivoFijo) <> 'EMPRESA' SELECT @Ok = 44180
END
IF @Modulo IN ('VTAS', 'COMS')
BEGIN
EXEC spCalculaImporte @Accion, @Modulo, @CfgImpInc, @MovTipo, @EsEntrada, @CantidadCalcularImporte, @Precio, @DescuentoTipo, @DescuentoLinea, @DescuentoGlobal, @SobrePrecio, @Impuesto1, @Impuesto2, @Impuesto3,
@Importe OUTPUT, @ImporteNeto OUTPUT, @DescuentoLineaImporte OUTPUT, @DescuentoGlobalImporte OUTPUT, @SobrePrecioImporte OUTPUT,
@Impuestos OUTPUT, @ImpuestosNetos OUTPUT,
@Articulo = @Articulo, @CantidadObsequio = @CantidadObsequio, @CfgPrecioMoneda = @CfgPrecioMoneda, @MovTipoCambio = @MovTipoCambio, @PrecioTipoCambio = @PrecioTipoCambio
IF @Modulo = 'VTAS' AND ROUND(ISNULL(@Precio, 0.0), 0) < 0.0 AND @AutoCorrida IS NULL SELECT @Ok = 20305
IF @Modulo = 'COMS' SELECT @Costo = @ImporteNeto / @Cantidad
IF @@ERROR <> 0 SELECT @Ok = 1
END
IF @AfectarCostos = 1 AND @EsEntrada = 1 AND @Accion NOT IN ('GENERAR', 'CANCELAR') AND @CfgToleranciaTipoCosto IN ('PROMEDIO', 'ESTANDAR', 'ULTIMO COSTO')
BEGIN
SELECT @ArtCosto = NULL
IF @CfgCosteoNivelSubCuenta = 1 AND NULLIF(RTRIM(@SubCuenta), '') IS NOT NULL
BEGIN
IF @CfgToleranciaTipoCosto = 'ULTIMO COSTO' SELECT @ArtCosto = UltimoCosto     FROM ArtSubCosto WITH (NOLOCK) WHERE Sucursal = @Sucursal AND Empresa = @Empresa AND Articulo = @Articulo AND SubCuenta = @SubCuenta ELSE
IF @CfgToleranciaTipoCosto = 'PROMEDIO'     SELECT @ArtCosto = CostoPromedio   FROM ArtSubCosto WITH (NOLOCK) WHERE Sucursal = @Sucursal AND Empresa = @Empresa AND Articulo = @Articulo AND SubCuenta = @SubCuenta ELSE
IF @CfgToleranciaTipoCosto = 'ESTANDAR'     SELECT @ArtCosto = CostoEstandar   FROM Art WITH (NOLOCK) WHERE Articulo = @Articulo ELSE
IF @CfgToleranciaTipoCosto = 'REPOSICION'   SELECT @ArtCosto = CostoReposicion FROM Art WITH (NOLOCK) WHERE Articulo = @Articulo
END ELSE
BEGIN
IF @CfgToleranciaTipoCosto = 'ULTIMO COSTO' SELECT @ArtCosto = UltimoCosto     FROM ArtCosto WITH (NOLOCK) WHERE Sucursal = @Sucursal AND Empresa = @Empresa AND Articulo = @Articulo ELSE
IF @CfgToleranciaTipoCosto = 'PROMEDIO'     SELECT @ArtCosto = CostoPromedio   FROM ArtCosto WITH (NOLOCK) WHERE Sucursal = @Sucursal AND Empresa = @Empresa AND Articulo = @Articulo ELSE
IF @CfgToleranciaTipoCosto = 'ESTANDAR'     SELECT @ArtCosto = CostoEstandar   FROM Art WITH (NOLOCK) WHERE Articulo = @Articulo ELSE
IF @CfgToleranciaTipoCosto = 'REPOSICION'   SELECT @ArtCosto = CostoReposicion FROM Art WITH (NOLOCK) WHERE Articulo = @Articulo
END
IF @ArtCosto IS NOT NULL
BEGIN
EXEC spMoneda NULL, @MovMoneda, @MovTipoCambio, @ArtMonedaCosto, @ArtFactorCosto OUTPUT, @ArtTipoCambioCosto OUTPUT, @Ok OUTPUT
SELECT @ArtCosto = @ArtCosto * @ArtFactorCosto
SELECT @Minimo = @ArtCosto * (1 - (@CfgToleranciaCosto/100)),
@Maximo = @ArtCosto * (1 + (@CfgToleranciaCosto/100))
IF @Costo/@Factor < @Minimo
BEGIN
SELECT @Ok = 20600
EXEC xpOk_20600 @Empresa, @Usuario, @Accion, @Modulo, @ID, @Renglon, @RenglonSub, @Ok OUTPUT, @OkRef OUTPUT
END ELSE
IF @Costo/@Factor > @Maximo
BEGIN
SELECT @Ok = 20610
EXEC xpOk_20610 @Empresa, @Usuario, @Accion, @Modulo, @ID, @Renglon, @RenglonSub, @Ok OUTPUT, @OkRef OUTPUT
END
END
END
IF @CfgValidarPrecios <> 'NO' AND @FacturarVtasMostrador = 0 AND @MovTipo IN ('VTAS.C', 'VTAS.CS', 'VTAS.P', 'VTAS.S', 'VTAS.R', 'VTAS.F','VTAS.FAR', 'VTAS.FC', 'VTAS.FB', 'VTAS.VC','VTAS.VCR', 'VTAS.N', 'VTAS.NO', 'VTAS.NR', 'VTAS.FM') AND @RenglonTipo NOT IN ('C', 'E') AND @AlmacenTipo <> 'GARANTIAS' AND @Accion NOT IN ('CANCELAR', 'GENERAR') AND (@Autorizacion IS NULL OR @Mensaje NOT IN (65010, 65020, 65040, 20310)) AND @Ok IS NULL
BEGIN
IF @CfgPrecioMinimoSucursal = 1
SELECT @ArtPrecioMinimo = ISNULL(PrecioMinimo, @ArtPrecioMinimo) FROM ArtSucursal WITH (NOLOCK) WHERE Articulo = @Articulo AND Sucursal = @AlmacenSucursal
SELECT @PrecioUnitarioNeto = ABS((@ImporteNeto / @Cantidad) / @Factor), @ArtCosto = NULL
IF @CfgValidarPrecios = 'PRECIO MINIMO'
BEGIN
EXEC spMoneda NULL, @MovMoneda, @MovTipoCambio, @ArtMonedaVenta, @ArtFactorVenta OUTPUT, @ArtTipoCambioVenta OUTPUT, @Ok OUTPUT
IF ROUND(@PrecioUnitarioNeto, 2) < ROUND(@ArtPrecioMinimo * @ArtFactorVenta, @RedondeoMonetarios)
SELECT @Ok = 20310
END
IF @CfgValidarPrecios IN ('ULTIMO COSTO', 'COSTO PROMEDIO', 'COSTO ESTANDAR', 'COSTO REPOSICION') AND @ArtTipo NOT IN ('JUEGO', 'SERVICIO')
SELECT @CfgValidarMargenMinimo = @CfgValidarPrecios,
@CfgValidarPrecios = 'MARGEN MINIMO',
@ArtMargenMinimoBorrar = 1
IF @ArtMargenMinimoBorrar = 1 SELECT @ArtMargenMinimo = 0.0
IF @CfgValidarPrecios = 'MARGEN MINIMO' AND @CfgValidarMargenMinimo <> 'NO'
BEGIN
SELECT @CostoEstandar = ISNULL(CostoEstandar, 0), @CostoReposicion = ISNULL(CostoReposicion, 0)
FROM Art WITH (NOLOCK)
WHERE Articulo = @Articulo
IF @CfgCosteoNivelSubCuenta = 1 AND NULLIF(RTRIM(@SubCuenta), '') IS NOT NULL
SELECT @UltimoCosto = ISNULL(UltimoCosto, 0), @CostoPromedio = ISNULL(CostoPromedio, 0)
FROM ArtSubCosto WITH (NOLOCK)
WHERE Sucursal = @Sucursal AND Empresa = @Empresa AND Articulo = @Articulo AND SubCuenta = @SubCuenta
ELSE
SELECT @UltimoCosto = ISNULL(UltimoCosto, 0), @CostoPromedio = ISNULL(CostoPromedio, 0)
FROM ArtCosto WITH (NOLOCK)
WHERE Sucursal = @Sucursal AND Empresa = @Empresa AND Articulo = @Articulo
IF @CfgValidarMargenMinimo = 'ULTIMO COSTO'     SELECT @ArtCosto = @UltimoCosto     ELSE
IF @CfgValidarMargenMinimo = 'COSTO PROMEDIO'   SELECT @ArtCosto = @CostoPromedio   ELSE
IF @CfgValidarMargenMinimo = 'COSTO ESTANDAR'   SELECT @ArtCosto = @CostoEstandar   ELSE
IF @CfgValidarMargenMinimo = 'COSTO REPOSICION' SELECT @ArtCosto = @CostoReposicion ELSE
IF @CfgValidarMargenMinimo = '(MAYOR COSTO)'
BEGIN
SELECT @ArtCosto = @UltimoCosto
IF @CostoPromedio   > @ArtCosto SELECT @ArtCosto = @CostoPromedio ELSE
IF @CostoEstandar   > @ArtCosto SELECT @ArtCosto = @CostoEstandar ELSE
IF @CostoReposicion > @ArtCosto SELECT @ArtCosto = @CostoReposicion
END
IF @ArtCosto IS NOT NULL
BEGIN
EXEC spMoneda NULL, @MovMoneda, @MovTipoCambio, @ArtMonedaCosto, @ArtFactorCosto OUTPUT, @ArtTipoCambioCosto OUTPUT, @Ok OUTPUT
SELECT @ArtCosto = @ArtCosto * @ArtFactorCosto
IF ROUND(@PrecioUnitarioNeto-(@PrecioUnitarioNeto * (@ArtMargenMinimo/100)), @RedondeoMonetarios) < ROUND(@ArtCosto, @RedondeoMonetarios)
SELECT @Ok = 20310
END
END
IF @Ok = 20310
IF EXISTS(SELECT * FROM Cte WITH (NOLOCK) WHERE Cliente = @ClienteProv AND PreciosInferioresMinimo = 1)
SELECT @Ok = NULL
EXEC xpValidarPrecios @Empresa, @Modulo, @ID, @Accion, @Articulo, @SubCuenta, @CfgValidarPrecios, @Ok OUTPUT, @OkRef OUTPUT
IF @Ok IS NOT NULL SELECT @Autorizar = 1
END
IF (@Estatus IN ('SINAFECTAR', 'BORRADOR', 'CONFIRMAR') OR @Accion IN ('RESERVAR', 'CANCELAR')) AND @Ok IS NULL AND (@Generar = 0 OR @MovTipo = 'INV.IF') AND
(@Utilizar = 0 OR (@Utilizar = 1 AND @MovTipo IN ('VTAS.R','VTAS.F','VTAS.FAR', 'VTAS.FC', 'VTAS.FG', 'VTAS.FX','VTAS.FB','VTAS.SG','VTAS.EG','VTAS.VC','VTAS.VCR','COMS.F','COMS.FL','COMS.EG', 'COMS.EI','COMS.IG','COMS.CC') AND @Accion NOT IN ('CANCELAR', 'GENERAR')))
BEGIN
SELECT @AplicaOrdenado = 0.0, @AplicaPendiente = 0.0, @AplicaReservada = 0.0
IF @AfectarMatando = 1 AND @Estatus IN ('SINAFECTAR', 'BORRADOR', 'CONFIRMAR') AND @Ok IS NULL
BEGIN
IF @Utilizar = 0
BEGIN
IF (@AplicaMov IS NULL) OR (NULLIF(RTRIM(@AplicaMovID), '') IS NULL)
BEGIN
IF @AfectarMatandoOpcional = 0 SELECT @Ok = 20170					
END ELSE
BEGIN
IF @SustitutoArticulo  IS NOT NULL AND @Articulo  <> @SustitutoArticulo  SELECT @ArticuloMatar  = @SustitutoArticulo  ELSE SELECT @ArticuloMatar  = @Articulo
IF @SustitutoSubCuenta IS NOT NULL AND @SubCuenta <> @SustitutoSubCuenta SELECT @SubCuentaMatar = @SustitutoSubCuenta ELSE SELECT @SubCuentaMatar = @SubCuenta
EXEC spInvPendiente @ID, @Modulo, @Empresa, @MovTipo, @Almacen, @AlmacenDestino, @AplicaMov, @AplicaMovID, @AplicaMovTipo, @ArticuloMatar, @SubCuentaMatar, @MovUnidad,
@AplicaOrdenado OUTPUT, @AplicaPendiente OUTPUT, @AplicaReservada OUTPUT, @AplicaClienteProv OUTPUT,
@Ok OUTPUT, @OkRef OUTPUT
IF @OK IS NULL
BEGIN
IF ROUND(@CantidadCalcularImporte, 4) > ROUND(@AplicaPendiente + @AplicaReservada, 4)
BEGIN
SELECT @ExcendeteDemas = ROUND((((ROUND(@CantidadCalcularImporte, 4)+@AplicaOrdenado-ROUND(@AplicaPendiente + @AplicaReservada, 4))/@AplicaOrdenado)-1)*100, 4)
IF (@AplicaMovTipo IN ('VTAS.P','VTAS.S')   AND @CfgVentaSurtirDemas   = 1) OR
(@AplicaMovTipo IN ('CXC.CA', 'CXC.CAP') AND @Modulo = 'VTAS') OR 		
(@AplicaMovTipo IN ('COMS.R') AND @CfgCompraRecibirDemas = 1) OR
(@AplicaMovTipo IN ('COMS.O', 'COMS.OP', 'COMS.OG','COMS.OI') AND (@CfgCompraRecibirDemas = 1 AND (@CfgCompraRecibirDemasTolerancia IS NULL OR @ExcendeteDemas<=@CfgCompraRecibirDemasTolerancia))) OR
(@AplicaMovTipo IN ('INV.OT', 'INV.OI')  AND @CfgTransferirDemas    = 1) OR
(@AplicaMovTipo = 'INV.SM' AND @MovTipo = 'INV.CM') /*OR
(@AplicaMovTipo = 'PROD.O')*/
SELECT @Ok = NULL
ELSE
BEGIN
SELECT @Ok = 20180, @OkRef = 'Articulo: '+RTRIM(@Articulo)+'<BR><BR>Ordenado: '+Convert(varchar, @AplicaOrdenado)+'<BR>Pendiente: '+Convert(varchar, (@AplicaPendiente + @AplicaReservada))+'<BR><BR>Aplicar: '+Convert(varchar, @cantidad)+'<BR>Excedente: '+Convert(varchar, @ExcendeteDemas)+'%'
IF @MovTipo = 'PROD.E' AND UPPER(@DetalleTipo) = 'EXCEDENTE' SELECT @Ok = NULL, @OkRef = NULL
END
END ELSE
IF @ClienteProv <> @AplicaClienteProv AND NULLIF(RTRIM(@AplicaClienteProv), '') IS NOT NULL
BEGIN
IF @Modulo = 'VTAS'
BEGIN
IF NOT EXISTS(SELECT * FROM CteRelacion WITH (NOLOCK) WHERE (Cliente = @ClienteProv AND Relacion = @AplicaClienteProv) OR (Cliente = @AplicaClienteProv AND Relacion = @ClienteProv))
SELECT @Ok = 20191
END ELSE
IF @Modulo = 'COMS' AND @MovTipo <> 'COMS.EI'
BEGIN
IF NOT EXISTS(SELECT * FROM ProvRelacion WITH (NOLOCK) WHERE (Proveedor = @ClienteProv AND Relacion = @AplicaClienteProv) OR (Proveedor = @AplicaClienteProv AND Relacion = @ClienteProv))
SELECT @Ok = 20192
END ELSE
IF @Modulo IN ('INV','PROD') SELECT @Ok = 20190
IF @Ok IS NOT NULL SELECT @OkRef = @AplicaClienteProv
END
END
END
END ELSE
IF @UtilizarMovTipo IN ('VTAS.P','VTAS.S','INV.SOL','INV.OT','INV.OI','INV.SM') SELECT @AplicaReservada = @CantidadReservada
END
IF @MovTipo = 'INV.CP' AND @Estatus IN ('SINAFECTAR', 'BORRADOR', 'CONFIRMAR')
BEGIN
IF @ArticuloDestino IS NULL SELECT @Ok = 20220 ELSE 								  
IF @Articulo = @ArticuloDestino AND ISNULL(@SubCuenta, '') = ISNULL(@SubCuentaDestino, '') SELECT @Ok = 20250 ELSE    
IF @ArtTipo NOT IN ('NORMAL', 'SERIE', 'VIN', 'LOTE', 'PARTIDA') /*OR @ArtTipoOpcion <> 'NO' */SELECT @Ok = 20235 ELSE
IF @ArtTipo <> (SELECT Tipo FROM Art WITH (NOLOCK) WHERE Articulo = @ArticuloDestino) SELECT @Ok = 20236 ELSE
IF NULLIF(@SubCuentaDestino, '') IS NOT NULL
EXEC spOpcionValidar @ArticuloDestino, @SubCuentaDestino, @Accion, @Ok OUTPUT, @OkRef
END
SELECT @AfectarAlmacen = @Almacen, @AfectarAlmacenTipo = @AlmacenTipo
IF (@EsSalida = 1 OR @EsTransferencia = 1 OR @Accion = 'RESERVAR') AND @ArtTipo NOT IN ('JUEGO','SERVICIO') AND @FacturarVtasMostrador = 0 AND @Ok IS NULL
BEGIN
IF (@AplicaMovTipo = 'VTAS.R' AND @MovTipo IN ('VTAS.F','VTAS.FAR', 'VTAS.FC', 'VTAS.FG', 'VTAS.FX'))
SELECT @Ok = @Ok
ELSE BEGIN
IF @Subcuenta IS NULL
BEGIN
IF @ArtTipoOpcion = 'MATRIZ' SELECT @Ok = 20070 
SELECT @ValidarDisponible = ~@NoValidarDisponible
/*IF @ValidarDisponible = 0 AND @MovTipo = 'VTAS.FM' AND @ArtTipo IN ('SERIE','LOTE','VIN','PARTIDA')
SELECT @ValidarDisponible = 1*/
IF @Cantidad > @AplicaReservada AND @ValidarDisponible = 1
BEGIN
EXEC spArtDisponible @Empresa, @AfectarAlmacen, @Articulo, @AfectarConsignacion, @AfectarAlmacenTipo, @Factor, @Disponible OUTPUT, @Ok OUTPUT
SELECT @Disponible = @Disponible + @AplicaReservada
IF ROUND(@Disponible, 4) < ROUND(@Cantidad, 4) SELECT @OK = 20020              	   
END
END ELSE
BEGIN
IF @Cantidad > @AplicaReservada AND @ValidarDisponible = 1
BEGIN
EXEC spArtSubDisponible @Empresa, @AfectarAlmacen, @Articulo, @ArtTipo, @SubCuenta, @AfectarConsignacion, @AfectarAlmacenTipo, @Factor, @Disponible OUTPUT, @Ok OUTPUT
SELECT @Disponible = @Disponible + @AplicaReservada
IF ROUND(@Disponible, 4) = 0.0
BEGIN
IF @ArtTipoOpcion <> 'NO' SELECT @Ok = 20040   
ELSE SELECT @Ok = 20020
END ELSE IF ROUND(@Disponible, 4) < ROUND(@Cantidad, 4) SELECT @OK = 20020
END
END
END
END
IF @MovTipo IN ('COMS.B', 'COMS.CA', 'COMS.GX') AND @AfectarCostos = 1 AND @Costo = 0.0 AND @ArtTipo NOT IN ('JUEGO', 'SERVICIO') SELECT @Ok = 20100		
IF @EsTransferencia = 1 SELECT @AfectarAlmacen = @AlmacenDestino, @AfectarAlmacenTipo = @AlmacenDestinoTipo
IF (@EsEntrada = 1 OR @EsTransferencia = 1 OR @MovTipo='COMS.O') AND @EsSalida = 0 AND @Ok IS NULL AND @EstatusNuevo <> 'BORRADOR'
BEGIN
IF @AfectarPiezas = 1
BEGIN
IF @Costo <> 0.0
SELECT @OK = 20140  								
END ELSE
IF (@AfectarCostos = 1 OR @MovTipo = 'COMS.O') AND @AlmacenTipo <> 'GARANTIAS' AND @Accion <> 'CANCELAR' AND @ArtTipo NOT IN ('JUEGO', 'SERVICIO')
BEGIN
IF EXISTS(SELECT Articulo FROM ActivoF WITH (NOLOCK) WHERE Empresa = @Empresa AND Articulo = @Articulo AND Serie IN (SELECT SerieLote FROM SerieLoteMov WITH (NOLOCK) WHERE /*Sucursal = @Sucursal AND */Empresa = @Empresa AND Modulo = @Modulo AND ID = @ID AND RenglonID = @RenglonID AND Articulo = @Articulo))
SELECT @EsActivoF = 1
ELSE SELECT @EsActivoF = 0
IF @Costo = 0.0 AND @MovTipo NOT IN ('VTAS.N', 'VTAS.NO', 'VTAS.NR', 'VTAS.FM', 'PROD.E', 'INV.CM') AND @CfgInvEntradasSinCosto = 0 AND @EsActivoF <> 1 SELECT @OK = 20100 ELSE	
IF @Costo < 0.0 AND @MovTipo <> 'INV.TC' SELECT @Ok = 20101									
END
END
IF (@EsEntrada = 1 OR @EsTransferencia = 1) AND @EsSalida = 0 AND @Ok IS NULL
BEGIN
IF @SubCuenta IS NULL AND @ArtTipoOpcion = 'MATRIZ' SELECT @Ok = 20070 
END
IF @MovTipo IN ('VTAS.D', 'VTAS.DF', 'VTAS.DFC', 'VTAS.B') AND @ArtTipo NOT IN ('JUEGO','SERVICIO')
BEGIN
IF @CfgVentaDevSinAntecedente = 0
BEGIN
IF NOT EXISTS(SELECT *
FROM Venta e WITH (NOLOCK), VentaD d WITH (NOLOCK), MovTipo mt WITH (NOLOCK)
WHERE e.id=d.ID and e.Empresa = @Empresa AND e.Cliente = @ClienteProv AND e.Estatus NOT IN ('SINAFECTAR', 'BORRADOR', 'CONFIRMAR', 'CANCELADO')
AND mt.Modulo = 'VTAS' AND mt.Mov = e.Mov AND mt.Clave IN ('VTAS.F','VTAS.FAR', 'VTAS.N', 'VTAS.NO', 'VTAS.NR', 'VTAS.FM', 'VTAS.FC', 'VTAS.FG', 'VTAS.FX')
AND d.Articulo = @Articulo AND ISNULL(d.SubCuenta, '') = ISNULL(@SubCuenta, ''))
BEGIN
SELECT @Ok = 20670, @OkRef = @Articulo
EXEC xpOk_20670 @Empresa, @Usuario, @Accion, @Modulo, @ID, @Renglon, @RenglonSub, @Ok OUTPUT, @OkRef OUTPUT
END
END
IF @ArtTipo IN ('SERIE','LOTE','VIN','PARTIDA') AND @Ok IS NULL
BEGIN
IF @CfgVentaDevSeriesSinAntecedente = 0
BEGIN
SELECT @OkRef = NULL
SELECT @OkRef = MIN(SerieLote)
FROM SerieLoteMov WITH (NOLOCK)
WHERE ID = @ID
AND SerieLote NOT IN (SELECT SerieLote FROM SerieLoteMov WITH (NOLOCK) WHERE ID IN
(SELECT e.ID
FROM Venta e WITH (NOLOCK), VentaD d WITH (NOLOCK), MovTipo mt WITH (NOLOCK)
WHERE e.id=d.ID and e.Empresa = @Empresa AND e.Cliente = @ClienteProv AND e.Estatus NOT IN ('SINAFECTAR', 'BORRADOR', 'CONFIRMAR', 'CANCELADO')
AND mt.Modulo = 'VTAS' AND mt.Mov = e.Mov AND mt.Clave IN ('VTAS.F','VTAS.FAR', 'VTAS.N', 'VTAS.NO', 'VTAS.NR', 'VTAS.FM', 'VTAS.FC', 'VTAS.FG', 'VTAS.FX')
AND d.Articulo = @Articulo AND ISNULL(d.SubCuenta, '') = ISNULL(@SubCuenta, '')))
IF @OkRef IS NOT NULL
SELECT @Ok = 20670, @OkRef = RTRIM(@Articulo)+' / '+RTRIM(@OkRef)
END
END
END
IF @MovTipo = 'INV.IF'
BEGIN
IF EXISTS(SELECT * FROM InvD WITH (NOLOCK) WHERE ID = @ID AND Articulo = @Articulo AND ISNULL(SubCuenta, '') = ISNULL(@SubCuenta, '') AND (Renglon <> @Renglon OR RenglonSub <> @RenglonSub))
SELECT @Ok = 10245, @OkRef = @Articulo
IF @SubCuenta IS NULL AND @ArtTipoOpcion = 'MATRIZ' SELECT @Ok = 20070 
END
END ELSE 
BEGIN
IF @AfectarPiezas = 0 AND @MovTipo <> 'INV.IF' AND @Ok IS NULL AND @Estatus = 'PENDIENTE'
BEGIN
IF @Base = 'SELECCION' AND @Cantidad > @CantidadPendiente + @CantidadReservada AND @Accion <> 'DESASIGNAR'
BEGIN
IF @Utilizar = 1 AND
((@UtilizarMovTipo IN ('VTAS.P','VTAS.S')  AND @CfgVentaSurtirDemas   = 1) OR
(@UtilizarMovTipo IN ('COMS.O','COMS.OP','COMS.OG','COMS.OI') AND @CfgCompraRecibirDemas = 1) OR
(@UtilizarMovTipo IN ('INV.OT', 'INV.OI') AND @CfgTransferirDemas    = 1) OR
@UtilizarMovTipo IN ('INV.SM'))
SELECT @Ok = NULL
ELSE
SELECT @OK = 20160
END ELSE IF @Base = 'SELECCION' AND @Accion = 'RESERVAR' AND @Cantidad > @CantidadPendiente
SELECT @OK = 20160								   	
ELSE IF @Base = 'RESERVADO' AND @Accion <> 'GENERAR' AND @Cantidad > @CantidadReservada
SELECT @Ok = 20165
ELSE IF @Base = 'ORDENADO' AND @Cantidad > @CantidadOrdenada
SELECT @Ok = 20167
END
END
IF @ArtTipo IN ('SERIE', 'VIN', 'LOTE', 'PARTIDA') AND (@Generar = 0 OR @MovTipo IN ('INV.IF')) AND @Utilizar = 0 AND @CfgSeriesLotesMayoreo = 1 AND (@EsEntrada = 1 OR @MovTipo IN ('COMS.B', 'COMS.CA', 'COMS.GX', 'INV.IF','VTAS.CO') OR @EsSalida = 1 OR @EsTransferencia = 1) AND @AfectarUnidades = 1 AND @Ok IS NULL
BEGIN
IF /*(@AplicaMovTipo = 'COMS.CC' AND @MovTipo IN ('COMS.F','COMS.FL','COMS.EG', 'COMS.EI')) OR */ /*@FacturarVtasMostrador = 1 OR */(@AplicaMovTipo = 'VTAS.R' AND @MovTipo IN ('VTAS.F','VTAS.FAR', 'VTAS.FC', 'VTAS.FG', 'VTAS.FX'))
BEGIN
IF @MovTipo <> 'VTAS.FM'
IF EXISTS(SELECT * FROM SerieLoteMov WITH (NOLOCK) WHERE Empresa = @Empresa AND Modulo = @Modulo AND ID = @ID AND Articulo = @Articulo AND ISNULL(SubCuenta, '') = ISNULL(@SubCuenta, '') AND RenglonID = @RenglonID)
SELECT @Ok = 20095
END ELSE
BEGIN
IF @ArtTipo = 'VIN'
IF EXISTS(SELECT * FROM SerieLoteMov s WITH (NOLOCK), VIN v WITH (NOLOCK)
WHERE s.Empresa = @Empresa AND s.Modulo = @Modulo AND s.ID = @ID AND s.Articulo = @Articulo AND ISNULL(s.SubCuenta, '') = ISNULL(@SubCuenta, '') AND s.RenglonID = @RenglonID
AND s.SerieLote = v.VIN AND v.Articulo <> @Articulo)
SELECT @Ok = 20690
IF Round(ABS(@Cantidad*@Factor), @CfgDecimalesCantidades) <> Round((SELECT ISNULL(SUM(ABS(Cantidad)), 0.0) FROM SerieLoteMov WITH (NOLOCK) WHERE Empresa = @Empresa AND Modulo = @Modulo AND ID = @ID AND Articulo = @Articulo AND ISNULL(SubCuenta, '') = ISNULL(@SubCuenta, '') AND RenglonID = @RenglonID), @CfgDecimalesCantidades)
BEGIN
IF NOT EXISTS(SELECT * FROM SerieLoteMov WITH (NOLOCK) WHERE Empresa = @Empresa AND Modulo = @Modulo AND ID = @ID AND Articulo = @Articulo AND ISNULL(SubCuenta, '') = ISNULL(@SubCuenta, '') AND RenglonID = @RenglonID)
BEGIN
IF (@EsEntrada = 1 OR @MovTipo IN (/*'INV.IF',*/'COMS.B','COMS.CA', 'COMS.GX','VTAS.CO'/** JH 31.10.2006 **/,'INV.CP'/**/) OR @SeriesLotesAutoOrden = 'NO') AND (@ArtSerieLoteInfo = 0 OR (@EsSalida = 1 AND @Accion <> 'CANCELAR')) AND @Ok IS NULL AND @EsEstadistica = 0 AND @AplicaMovTipo <> 'COMS.CC'  /** JH 13.2.2007 **/
BEGIN
SELECT @CantidadSugerida = ABS(@Cantidad*@Factor)
EXEC spSugerirSerieLoteMov @Empresa, @Modulo, @ID, @MovTipo, @Almacen, @RenglonID, @Articulo, @SubCuenta, @Sucursal, @Cantidad, @Paquete, @EnSilencio = 1
IF NOT EXISTS(SELECT * FROM SerieLoteMov WITH (NOLOCK) WHERE Empresa = @Empresa AND Modulo = @Modulo AND ID = @ID AND Articulo = @Articulo AND ISNULL(SubCuenta, '') = ISNULL(@SubCuenta, '') AND RenglonID = @RenglonID)
BEGIN
IF @ArtTipo = 'VIN' SELECT @Ok = 20325 ELSE SELECT @Ok = 20320   
IF @Ok IS NOT NULL
BEGIN
IF @Modulo = 'VTAS' AND @OrigenTipo = 'VMOS' SELECT @Ok = NULL
IF @MovTipo IN ('VTAS.N', 'VTAS.NR', 'VTAS.NO', 'VTAS.FM') AND @CfgNotasBorrador = 1 SELECT @Ok = NULL
END
END
END
END ELSE SELECT @Ok = 20330
END ELSE BEGIN
IF @EsEntrada = 1 AND @ArtTipo IN ('SERIE', 'VIN')
BEGIN
SELECT @SerieLote = MIN(s.SerieLote)
FROM SerieLoteMov sm WITH (NOLOCK), SerieLote s WITH (NOLOCK)
WHERE s.Sucursal = @Sucursal AND s.empresa = sm.Empresa AND s.Articulo = sm.Articulo AND s.SubCuenta = sm.SubCuenta AND s.SerieLote = sm.SerieLote AND (ISNULL(s.Existencia, 0) > 0 OR ISNULL(s.ExistenciaActivoFijo, 0) > 0)
AND sm.Empresa = @Empresa AND sm.Modulo = @Modulo AND sm.ID = @ID AND sm.Articulo = @Articulo AND sm.RenglonID = @RenglonID
IF @SerieLote IS NOT NULL SELECT @Ok = 20080
/** JH 31.10.2006 **/
IF @Ok = 20080 AND @Accion = 'CANCELAR' AND @MovTipo = 'INV.CP' AND @Cantidad > 0.0 SELECT @Ok = NULL
/**/
END ELSE
IF (@EsSalida = 1 OR @EsTransferencia = 1 OR @MovTipo IN ('COMS.B', 'COMS.CA', 'COMS.GX'/*,'INV.IF'*/)) AND @ArtSerieLoteInfo = 0
BEGIN
SELECT @SerieLote = MIN(SerieLote)
FROM SerieLoteMov WITH (NOLOCK)
WHERE Empresa = @Empresa AND Modulo = @Modulo AND ID = @ID AND Articulo = @Articulo AND SubCuenta = ISNULL(@SubCuenta, '') AND RenglonID = @RenglonID AND ISNULL(Cantidad, 0) > 0
AND SerieLote NOT IN (SELECT SerieLote FROM SerieLote WITH (NOLOCK) WHERE Empresa = @Empresa /*AND Modulo = @Modulo */AND Articulo = @Articulo AND SubCuenta = ISNULL(@SubCuenta, '') AND Almacen = @Almacen AND (ISNULL(Existencia, 0) > 0 OR ISNULL(ExistenciaActivoFijo, 0) > 0))
IF @SerieLote IS NOT NULL SELECT @Ok = 20090
IF @Ok IS NOT NULL AND @Modulo = 'VTAS' AND (@OrigenTipo = 'VMOS' OR @MovTipo = 'VTAS.FM') SELECT @Ok = NULL
END
IF @Ok IS NULL AND @MovTipo IN ('COMS.DC','COMS.DG') AND @ArtSerieLoteInfo = 0
BEGIN
SELECT @CantidadSeries = COUNT(*)
FROM SerieLoteMov WITH (NOLOCK)
WHERE Empresa = @Empresa AND Modulo = @Modulo AND Articulo = @Articulo AND ID = @IDAplica
AND SerieLote IN (SELECT SerieLote FROM SerieLoteMov WITH (NOLOCK) WHERE Empresa = @Empresa AND Modulo = @Modulo AND ID = @ID AND Articulo = @Articulo AND RenglonID = @RenglonID)
IF @CantidadSeries <> @Cantidad SELECT @Ok = 20090
END
END
END
END
IF @MovTipo = 'COMS.CA'
IF (SELECT ROUND(SUM(ISNULL(Inventario, 0)), 4) FROM ArtSubExistenciaInv WITH (NOLOCK) WHERE Empresa = @Empresa AND Almacen = @Almacen AND Articulo = @Articulo AND ISNULL(SubCUenta, '') = ISNULL(@SubCuenta, '')) <= 0.0
SELECT @OK = 20810
IF @MovTipo IN ('COMS.OG','COMS.IG','COMS.DG') AND @AlmacenTipo <> 'GARANTIAS' AND @Ok IS NULL
SELECT @Ok = 20440
IF @MovTipo IN ('COMS.F','COMS.FL','COMS.EG','COMS.EI','COMS.CC') AND @Accion <> 'GENERAR' AND @CfgCompraCaducidad = 1 AND @ArtCaducidadMinima IS NOT NULL AND @Ok IS NULL
BEGIN
IF @FechaCaducidad IS NULL SELECT @Ok = 25125 ELSE
IF @FechaCaducidad < DATEADD(day, @ArtCaducidadMinima, @FechaEmision) SELECT @Ok = 25126
END
IF @Modulo = 'VTAS' AND @Accion <> 'CANCELAR' AND @Estatus IN ('SINAFECTAR', 'BORRADOR', 'CONFIRMAR') AND @Ok IS NULL
EXEC xpInvVerificarCteArtBloqueo @Empresa, @ID, @Usuario, @ClienteProv, @Articulo, @Ok OUTPUT, @OkRef OUTPUT
IF @Ok IS NULL
EXEC xpInvVerificarDetalle @ID, @Accion, @Base, @Empresa, @Usuario, @Modulo,
@Mov, @MovID, @MovTipo, @MovMoneda, @MovTipoCambio, @Estatus, @EstatusNuevo,
@FechaEmision, @Renglon, @RenglonSub, @Articulo, @Cantidad, @Importe,
@ImporteNeto, @Impuestos, @ImpuestosNetos,
@Ok OUTPUT, @OkRef OUTPUT
IF @Ok IS NOT NULL AND @OkRef IS NULL
BEGIN
SELECT @OkRef = 'Articulo: '+RTRIM(@Articulo)
IF NULLIF(RTRIM(@SubCuenta), '') IS NOT NULL
SELECT @OkRef = @OkRef + ' ('+RTRIM(@SubCuenta)+')'
IF NULLIF(RTRIM(@SerieLote), '') IS NOT NULL
SELECT @OkRef = @OkRef + ' - '+RTRIM(@SerieLote)
END
SELECT @AfectarAlgo = 1
IF @Modulo = 'VTAS'
BEGIN
SELECT @SumaImporteNeto    = @SumaImporteNeto    + @ImporteNeto,
@SumaImpuestosNetos = @SumaImpuestosNetos + @ImpuestosNetos
IF (@AplicaAutorizacion IS NULL OR @CfgAutoAutorizacionFacturas = 0)
SELECT @SumaImporteNetoSinAutorizar    = @SumaImporteNetoSinAutorizar    + @ImporteNeto,
@SumaImpuestosNetosSinAutorizar = @SumaImpuestosNetosSinAutorizar + @ImpuestosNetos
END
IF @Accion = 'CANCELAR'
SELECT @SumaCantidadOriginal  = @SumaCantidadOriginal + @CantidadOriginal,
@SumaCantidadPendiente = @SumaCantidadPendiente + @CantidadPendiente + @CantidadReservada
END  
IF @Ok IS NULL
BEGIN
FETCH NEXT FROM crVerificarDetalle INTO @AutoGenerado, @Renglon, @RenglonSub, @RenglonID, @RenglonTipo, @CantidadOriginal, @CantidadObsequio, @CantidadInventario, @CantidadReservada, @CantidadOrdenada, @CantidadPendiente, @CantidadA, @MovUnidad, @Factor, @Articulo, @Subcuenta, @ArticuloDestino, @SubCuentaDestino, @SustitutoArticulo, @SustitutoSubCuenta, @Costo, @Precio, @DescuentoTipo, @DescuentoLinea, @Impuesto1, @Impuesto2, @Impuesto3, @AplicaMov, @AplicaMovID, @AlmacenRenglon, @ArtTipo, @ArtSerieLoteInfo, @ArtTipoOpcion, @ArtTipoCompra, @ArtSeProduce, @ArtSeCompra, @ArtEsFormula, @ArtUnidad, @ArtPrecioMinimo, @ArtMonedaVenta, @ArtMargenMinimo, @ArtMonedaCosto, @ProdSerieLote, @ProdRuta, @ProdOrden, @ProdOrdenDestino, @ProdCentro, @ProdCentroDestino, @DetalleTipo, @CantidadMinimaVenta, @CantidadMaximaVenta, @ArtCaducidadMinima, @FechaCaducidad, @ArtActividades, @FechaRequeridaD, @Paquete, @EsEstadistica, @PrecioTipoCambio
IF @@ERROR <> 0 SELECT @Ok = 1
END ELSE
IF @OkRef IS NULL
BEGIN
SELECT @OkRef = 'Articulo: '+@Articulo
IF @SubCuenta IS NOT NULL SELECT @OkRef = @OkRef+ ' ('+@SubCuenta+')'
END
END  
CLOSE crVerificarDetalle
END
DEALLOCATE crVerificarDetalle
IF @Ok IS NULL
BEGIN
IF @Modulo = 'VTAS'
BEGIN
SELECT @ImporteTotalSinAutorizar = @SumaImporteNetoSinAutorizar + @SumaImpuestosNetosSinAutorizar - @AnticiposFacturados,
@ImporteTotal             = @SumaImporteNeto             + @SumaImpuestosNetos             - @AnticiposFacturados
IF @CfgAutoAutorizacionFacturas = 1 AND ISNULL(@ImporteTotalSinAutorizar, 0) <> 0.0
BEGIN
IF @AnexoID IS NOT NULL
SELECT @ImporteTotalSinAutorizar = 0.0
ELSE
IF @OrigenTipo = @Modulo
IF (SELECT NULLIF(RTRIM(Autorizacion), '') FROM Venta WHERE Empresa = @Empresa AND Mov = @Origen AND MovID = @OrigenID AND Estatus IN ('PENDIENTE', 'CONCLUIDO')) IS NOT NULL
SELECT @ImporteTotalSinAutorizar = 0.0
END
END
IF @Modulo = 'VTAS' AND @CfgImpInc = 1
BEGIN
SELECT @SumaImporteNeto = @SumaImporteNeto - (@SumaImporteNeto + @SumaImpuestosNetos - @ImporteTotal)
END
IF @AfectarAlgo = 0 AND @EstatusNuevo <> 'CONFIRMAR' AND @MovTipo <> 'INV.IF'
IF @Accion = 'CANCELAR' SELECT @Ok = 60015 ELSE SELECT @Ok = 60010				
IF @Accion = 'CANCELAR'
BEGIN
IF @Estatus = 'PENDIENTE' AND ROUND(@SumaCantidadOriginal, 4) <> ROUND(@SumaCantidadPendiente, 4) AND @Base = 'TODO'
SELECT @Ok = 60080
END ELSE
IF @Modulo = 'VTAS' AND @Accion NOT IN ('GENERAR', 'CANCELAR') AND @Estatus <> 'PENDIENTE'
BEGIN
IF @CfgVentaBloquearMorosos <> 'NO' AND @MovTipo NOT IN ('VTAS.PR', 'VTAS.EST', 'VTAS.SD', 'VTAS.D', 'VTAS.DF', 'VTAS.DFC', 'VTAS.B', 'VTAS.DR', 'VTAS.DC', 'VTAS.DCR', 'VTAS.VP') AND (@Autorizacion IS NULL OR @Mensaje NOT IN (65010, 65020, 65040)) AND @CobroIntegrado = 0 AND @ImporteTotalSinAutorizar <> 0.0 AND @Ok IS NULL
BEGIN
SELECT @DiasTolerancia = 0
IF SUBSTRING(@CfgVentaBloquearMorosos,1,1) <> 'S'
BEGIN
IF ISNUMERIC(@CfgVentaBloquearMorosos) = 1
SELECT @DiasTolerancia = CONVERT(int, @CfgVentaBloquearMorosos)
ELSE BEGIN
IF ISNUMERIC(RTRIM(SUBSTRING(@CfgVentaBloquearMorosos, 1, 2))) = 1
SELECT @DiasTolerancia = Convert(int, RTRIM(SUBSTRING(@CfgVentaBloquearMorosos, 1, 2)))
END
END
SELECT @MaxDiasMoratorios = ISNULL(MAX(p.DiasMoratorios), 0)
FROM CxcPendiente p WITH (NOLOCK), MovTipo  mt WITH (NOLOCK)
WHERE p.Empresa = @Empresa
AND p.Cliente = @ClienteProv
AND mt.Modulo = 'CXC' AND mt.Mov = p.Mov AND mt.Clave NOT IN ('CXC.A', 'CXC.AR', 'CXC.NC', 'CXC.DAC', 'CXC.NCD','CXC.NCF')
IF @MaxDiasMoratorios > @DiasTolerancia
BEGIN
SELECT @Ok = 65040
EXEC xpValidacionMorosos @Empresa, @Accion, @Modulo, @ID, @MovTipo, @ServicioGarantia, @Ok OUTPUT
END
IF @Ok IS NOT NULL SELECT @Autorizar = 1
END
IF @ChecarCredito = 1 AND @MovTipo NOT IN ('VTAS.PR', 'VTAS.EST', 'VTAS.SD', 'VTAS.D', 'VTAS.DF', 'VTAS.DFC', 'VTAS.B', 'VTAS.DR', 'VTAS.DC', 'VTAS.DCR', 'VTAS.VP') AND (@Autorizacion IS NULL OR @Mensaje NOT IN (65010, 65020)) AND @Accion <> 'GENERAR' AND @Ok IS NULL
BEGIN
SELECT @DiasVencimiento = 0
IF @Condicion IS NOT NULL
BEGIN
SELECT @DiasVencimiento = NULL
SELECT @DiasVencimiento = DiasVencimiento FROM Condicion WHERE Condicion = @Condicion
IF @DiasVencimiento IS NULL
SELECT @DiasVencimiento = DATEDIFF(day, @FechaEmision, @Vencimiento)
ELSE
BEGIN
IF @DiasCredito IS NOT NULL
IF @DiasVencimiento > @DiasCredito SELECT @Ok = 65020
IF @CondicionesValidas IS NOT NULL
IF CHARINDEX(UPPER(@Condicion), @CondicionesValidas) = 0 SELECT @Ok = 65020
END
END
IF @ConCredito = 0 AND @DiasVencimiento > 0 SELECT @Ok = 65020
IF @ConCredito = 1 AND @ConLimiteCredito = 1 AND @MovTipo NOT IN ('VTAS.D','VTAS.DF','VTAS.DFC','VTAS.B','VTAS.DR') AND @ImporteTotalSinAutorizar <> 0.0 AND @Ok IS NULL
BEGIN
IF (@CfgVentaChecarCredito = 'COTIZACION') OR
(@CfgVentaChecarCredito = 'PEDIDO'      AND @MovTipo NOT IN ('VTAS.C', 'VTAS.CS')) OR
(@MovTipo NOT IN ('VTAS.C','VTAS.CS','VTAS.P','VTAS.S'))
BEGIN
SELECT @Saldo = 0.0, @VentasPendientes = 0.0, @PedidosPendientes = 0.0
IF @CfgLimiteCreditoNivelUEN = 1
BEGIN
IF @CfgLimiteCreditoNivelGrupo = 1
SELECT @Saldo = ISNULL(SUM(s.Saldo * m.TipoCambio), 0.0)
FROM Cxc s WITH (NOLOCK), Mon m WITH (NOLOCK), Empresa e WITH (NOLOCK)
WHERE e.Grupo = @EmpresaGrupo AND s.Empresa = e.Empresa AND s.Cliente = @ClienteProv AND s.Moneda = m.Moneda
AND s.UEN = @VentaUEN AND s.Estatus = 'PENDIENTE'
ELSE
SELECT @Saldo = ISNULL(SUM(s.Saldo * m.TipoCambio), 0.0)
FROM Cxc s WITH (NOLOCK), Mon m WITH (NOLOCK)
WHERE s.Empresa = @Empresa AND s.Cliente = @ClienteProv AND s.Moneda = m.Moneda
AND s.UEN = @VentaUEN AND s.Estatus = 'PENDIENTE'
END ELSE
BEGIN
IF @CfgLimiteCreditoNivelGrupo = 1
SELECT @Saldo = ISNULL(SUM(s.Saldo * m.TipoCambio), 0.0)
FROM CxcSaldo s WITH (NOLOCK), Mon m WITH (NOLOCK), Empresa e WITH (NOLOCK)
WHERE e.Grupo = @EmpresaGrupo AND s.Empresa = e.Empresa AND s.Cliente = @ClienteProv AND s.Moneda = m.Moneda
ELSE
SELECT @Saldo = ISNULL(SUM(s.Saldo * m.TipoCambio), 0.0)
FROM CxcSaldo s WITH (NOLOCK), Mon m WITH (NOLOCK)
WHERE s.Empresa = @Empresa AND s.Cliente = @ClienteProv AND s.Moneda = m.Moneda
END
IF @MovTipo IN ('VTAS.P', 'VTAS.S') AND @ConLimitePedidos = 1
BEGIN
IF @CfgLimiteCreditoNivelUEN = 1
BEGIN
IF @CfgLimiteCreditoNivelGrupo = 1
SELECT @PedidosPendientes = ISNULL(SUM(ISNULL(v.Saldo, 0) * Mon.TipoCambio), 0)
FROM VentaPendiente v WITH (NOLOCK), MovTipo mt WITH (NOLOCK), Mon WITH (NOLOCK)
WHERE mt.Modulo = 'VTAS' AND mt.Mov = v.Mov AND mt.Clave IN ('VTAS.P', 'VTAS.S') AND v.Estatus = 'PENDIENTE' AND /**/v.Empresa = @Empresa AND v.Cliente = @ClienteProv AND v.Moneda = Mon.Moneda
AND v.UEN = @VentaUEN
ELSE
SELECT @PedidosPendientes = ISNULL(SUM(ISNULL(v.Saldo, 0) * Mon.TipoCambio), 0)
FROM VentaPendiente v WITH (NOLOCK), MovTipo mt WITH (NOLOCK), Mon WITH (NOLOCK), Empresa e WITH (NOLOCK)
WHERE mt.Modulo = 'VTAS' AND mt.Mov = v.Mov AND mt.Clave IN ('VTAS.P', 'VTAS.S') AND v.Estatus = 'PENDIENTE' AND e.Grupo = @EmpresaGrupo AND v.Empresa = e.Empresa AND v.Cliente = @ClienteProv AND v.Moneda = Mon.Moneda
AND v.UEN = @VentaUEN
END ELSE
BEGIN
IF @CfgLimiteCreditoNivelGrupo = 1
SELECT @PedidosPendientes = ISNULL(SUM(ISNULL(v.Saldo, 0) * Mon.TipoCambio), 0)
FROM VentaPendiente v WITH (NOLOCK), MovTipo mt WITH (NOLOCK), Mon WITH (NOLOCK)
WHERE mt.Modulo = 'VTAS' AND mt.Mov = v.Mov AND mt.Clave IN ('VTAS.P', 'VTAS.S') AND v.Estatus = 'PENDIENTE' AND /**/v.Empresa = @Empresa AND v.Cliente = @ClienteProv AND v.Moneda = Mon.Moneda
ELSE
SELECT @PedidosPendientes = ISNULL(SUM(ISNULL(v.Saldo, 0) * Mon.TipoCambio), 0)
FROM VentaPendiente v WITH (NOLOCK), MovTipo mt WITH (NOLOCK), Mon WITH (NOLOCK), Empresa e WITH (NOLOCK)
WHERE mt.Modulo = 'VTAS' AND mt.Mov = v.Mov AND mt.Clave IN ('VTAS.P', 'VTAS.S') AND v.Estatus = 'PENDIENTE' AND e.Grupo = @EmpresaGrupo AND v.Empresa = e.Empresa AND v.Cliente = @ClienteProv AND v.Moneda = Mon.Moneda
END
SELECT @DifCredito = (@LimitePedidos*@TipoCambioCredito) - @PedidosPendientes - (@SumaImporteNetoSinAutorizar*@MovTipoCambio)
IF ROUND(@DifCredito, 0) < 0.0
BEGIN
SELECT @ImporteAutorizar = -@DifCredito
SELECT @Ok = 65010,
@OkRef = 'Limite Pedidos: '+CONVERT(char, @LimitePedidos * @TipoCambioCredito) +
'<BR>Pedidos Pendientes: '+LTRIM(CONVERT(char, @PedidosPendientes)) +
'<BR>Importe Movimiento: '+LTRIM(CONVERT(char, @SumaImporteNetoSinAutorizar*@MovTipoCambio)) +
'<BR><BR>Diferencia: '+LTRIM(CONVERT(char, -@DifCredito)) +
'<BR>Importe Autorizar: '+LTRIM(CONVERT(char, @ImporteAutorizar))
IF @ImporteAutorizar > @SumaImporteNetoSinAutorizar*@MovTipoCambio SELECT @ImporteAutorizar = @SumaImporteNetoSinAutorizar*@MovTipoCambio
UPDATE Venta WITH (ROWLOCK) SET DifCredito = @ImporteAutorizar WHERE ID = @ID
END
END ELSE
BEGIN
IF @CfgVentaPedidosDisminuyenCredito = 1
SELECT @Saldo = @Saldo + ISNULL(SUM(ISNULL(v.Saldo, 0) * Mon.TipoCambio), 0)
FROM VentaPendiente v WITH (NOLOCK), MovTipo mt WITH (NOLOCK), Mon WITH (NOLOCK), Empresa e WITH (NOLOCK)
WHERE mt.Modulo = 'VTAS' AND mt.Mov = v.Mov AND mt.Clave IN ('VTAS.P', 'VTAS.S') AND v.Estatus = 'PENDIENTE' AND e.Grupo = @EmpresaGrupo AND v.Empresa = e.Empresa AND v.Cliente = @ClienteProv AND v.Moneda = Mon.Moneda
IF @CfgLimiteCreditoNivelUEN = 1
BEGIN
IF @CfgLimiteCreditoNivelGrupo = 1
SELECT @VentasPendientes = ISNULL(SUM((ISNULL(v.Saldo, 0) /*+ ISNULL(v.SaldoImpuestos, 0)*/) * Mon.TipoCambio), 0)
FROM VentaPendiente v WITH (NOLOCK), MovTipo mt WITH (NOLOCK), Mon WITH (NOLOCK), Empresa e WITH (NOLOCK)
WHERE mt.Modulo = 'VTAS' AND mt.Mov = v.Mov AND mt.Clave IN ('VTAS.R', /*'VTAS.F','VTAS.FAR', 'VTAS.FC', 'VTAS.FG', 'VTAS.FX', */'VTAS.VC', 'VTAS.VCR') AND v.Estatus = 'PENDIENTE' AND e.Grupo = @EmpresaGrupo AND v.Empresa = e.Empresa AND v.Cliente = @ClienteProv AND v.Moneda = Mon.Moneda
AND v.UEN = @VentaUEN
ELSE
SELECT @VentasPendientes = ISNULL(SUM((ISNULL(v.Saldo, 0) /*+ ISNULL(v.SaldoImpuestos, 0)*/) * Mon.TipoCambio), 0)
FROM VentaPendiente v WITH (NOLOCK), MovTipo mt WITH (NOLOCK), Mon WITH (NOLOCK)
WHERE mt.Modulo = 'VTAS' AND mt.Mov = v.Mov AND mt.Clave IN ('VTAS.R', /*'VTAS.F','VTAS.FAR', 'VTAS.FC', 'VTAS.FG', 'VTAS.FX', */'VTAS.VC', 'VTAS.VCR') AND v.Estatus = 'PENDIENTE' AND v.Empresa = @Empresa AND v.Cliente = @ClienteProv AND v.Moneda = Mon.Moneda
AND v.UEN = @VentaUEN
END ELSE
BEGIN
IF @CfgLimiteCreditoNivelGrupo = 1
SELECT @VentasPendientes = ISNULL(SUM((ISNULL(v.Saldo, 0) /*+ ISNULL(v.SaldoImpuestos, 0)*/) * Mon.TipoCambio), 0)
FROM VentaPendiente v WITH (NOLOCK), MovTipo mt WITH (NOLOCK), Mon WITH (NOLOCK), Empresa e WITH (NOLOCK)
WHERE mt.Modulo = 'VTAS' AND mt.Mov = v.Mov AND mt.Clave IN ('VTAS.R', /*'VTAS.F','VTAS.FAR', 'VTAS.FC', 'VTAS.FG', 'VTAS.FX', */'VTAS.VC', 'VTAS.VCR') AND v.Estatus = 'PENDIENTE' AND e.Grupo = @EmpresaGrupo AND v.Empresa = e.Empresa AND v.Cliente = @ClienteProv AND v.Moneda = Mon.Moneda
ELSE
SELECT @VentasPendientes = ISNULL(SUM((ISNULL(v.Saldo, 0) /*+ ISNULL(v.SaldoImpuestos, 0)*/) * Mon.TipoCambio), 0)
FROM VentaPendiente v WITH (NOLOCK), MovTipo mt WITH (NOLOCK), Mon WITH (NOLOCK)
WHERE mt.Modulo = 'VTAS' AND mt.Mov = v.Mov AND mt.Clave IN ('VTAS.R', /*'VTAS.F','VTAS.FAR', 'VTAS.FC', 'VTAS.FG', 'VTAS.FX', */'VTAS.VC', 'VTAS.VCR') AND v.Estatus = 'PENDIENTE' AND v.Empresa = @Empresa AND v.Cliente = @ClienteProv AND v.Moneda = Mon.Moneda
END
SELECT @RemisionesAplicadas = 0.0
SELECT @RemisionesAplicadas = ISNULL(SUM(d.ImporteTotal*m.TipoCambio), 0.0)
FROM VentaTCalc d WITH (NOLOCK), MovTipo mt WITH (NOLOCK), Mon m WITH (NOLOCK)
WHERE d.ID = @ID
AND mt.Mov = d.Aplica AND mt.Modulo = 'VTAS' AND mt.Clave IN ('VTAS.R', 'VTAS.VCR') AND d.Moneda = m.Moneda
IF @RemisionesAplicadas IS NOT NULL
SELECT @VentasPendientes = @VentasPendientes - @RemisionesAplicadas
SELECT @DifCredito = (@LimiteCredito*@TipoCambioCredito) - @Saldo - @VentasPendientes - (@ImporteTotalSinAutorizar*@MovTipoCambio)
IF ROUND(@DifCredito, 0) < 0.0
BEGIN
SELECT @ImporteAutorizar = -@DifCredito
SELECT @Ok = 65010,
@OkRef = 'Limite Credito: '+CONVERT(char, @LimiteCredito * @TipoCambioCredito) +
'<BR><BR>Saldo Actual: '+LTRIM(CONVERT(char, @Saldo)) +
'<BR>Remisiones Pendientes: '+LTRIM(CONVERT(char, @VentasPendientes)) +
'<BR>Importe Movimiento: '+LTRIM(CONVERT(char, @ImporteTotalSinAutorizar*@MovTipoCambio)) +
'<BR><BR>Diferencia: '+LTRIM(CONVERT(char, -@DifCredito)) +
'<BR>Importe Autorizar: '+LTRIM(CONVERT(char, @ImporteAutorizar))
IF @ImporteAutorizar > @SumaImporteNetoSinAutorizar*@MovTipoCambio SELECT @ImporteAutorizar = @SumaImporteNetoSinAutorizar*@MovTipoCambio
UPDATE Venta WITH (ROWLOCK) SET DifCredito = @ImporteAutorizar WHERE ID = @ID
END
END
END
END
IF @Ok IS NOT NULL SELECT @Autorizar = 1
END
IF @MovTipo IN ('VTAS.F','VTAS.FAR', 'VTAS.FB', 'VTAS.FM') AND @Estatus IN ('SINAFECTAR', 'CONFIRMAR', 'BORRADOR') AND @Accion NOT IN ('CANCELAR', 'GENERAR') AND @Ok IS NULL AND @AutoCorrida IS NULL
IF ROUND(@ImporteTotal, 0) < 0.0 SELECT @Ok = 20410
IF @MovTipo = 'VTAS.S' AND @CfgServiciosRequiereTareas = 1 AND @Estatus IN ('SINAFECTAR', 'BORRADOR', 'CONFIRMAR') AND @Accion NOT IN ('CANCELAR', 'GENERAR')
IF NOT EXISTS (SELECT * FROM ServicioTarea WITH (NOLOCK) WHERE ID = @ID)
BEGIN
SELECT @TareaOmision = NULLIF(RTRIM(VentaServiciosTareaOmision), '') FROM EmpresaCfg WITH (NOLOCK) WHERE Empresa = @Empresa
IF @TareaOmision IS NULL
SELECT @Ok = 20490
ELSE BEGIN
SELECT @TareaOmisionEstado = NULL
SELECT @TareaOmisionEstado = Estado FROM TareaEstado WITH (NOLOCK) WHERE Orden = 1
INSERT ServicioTarea (Sucursal, ID, Tarea, Estado) VALUES (@Sucursal, @ID, @TareaOmision, @TareaOmisionEstado)
END
END
IF @MovTipo = 'VTAS.S' AND @CfgServiciosValidarID = 1 AND @Estatus IN ('SINAFECTAR', 'BORRADOR', 'CONFIRMAR') AND @Accion NOT IN ('CANCELAR', 'GENERAR') AND @AnexoID IS NULL
BEGIN
SELECT @Flotante = NULLIF(ServicioNumero, 0), @Identificador = NULLIF(RTRIM(ServicioIdentificador), '') FROM Venta WITH (NOLOCK) WHERE ID = @ID
IF @Flotante IS NOT NULL OR @Identificador IS NOT NULL
IF EXISTS(SELECT ID FROM Venta WITH (NOLOCK) WHERE Empresa = @Empresa AND Estatus = 'PENDIENTE' AND ServicioNumero = @Flotante AND ServicioIdentificador = @Identificador AND ServicioSerie<>@ServicioSerie)
SELECT @Ok = 26120, @OkRef = ISNULL(@Identificador, '')+' '+CONVERT(varchar, @Flotante)
END
IF @MovTipo IN ('VTAS.SG','VTAS.EG') AND @ImporteTotal > 0.0 AND @Ok IS NULL SELECT @Ok = 20420
IF @MovTipo IN ('VTAS.F','VTAS.FAR','VTAS.FB')
AND @CfgLimiteRenFacturas > 0
AND (@FacturarVtasMostrador = 0 OR @CfgVentaLimiteRenFacturasVMOS = 1)
AND @Accion <> 'GENERAR'
AND @Ok IS NULL
AND @FacturacionRapidaAgrupada = 0
BEGIN
SELECT @Conteo = ISNULL(COUNT(*), 0) FROM VentaD WITH (NOLOCK) WHERE ID = @ID
IF @CfgLimiteRenFacturas < @Conteo SELECT @Ok = 60210, @OkRef = 'Limite: '+LTRIM(CONVERT(char, @CfgLimiteRenFacturas))+', Renglones: '+LTRIM(CONVERT(char, @Conteo))
END
IF @Estatus IN ('SINAFECTAR', 'BORRADOR', 'CONFIRMAR') AND @CobroIntegrado = 1 AND @OrigenTipo <> 'VMOS' AND @Ok IS NULL
BEGIN
SELECT @Importe1 = 0.0, @Importe2 = 0.0, @Importe3 = 0.0, @Importe4 = 0.0, @Importe5 = 0.0,
@CobroDesglosado  = 0.0, @CobroCambio = 0.0, @CobroDelEfectivo = 0.0, @ValesCobrados = 0.0, @CobroRedondeo = 0.0, @TarjetasCobradas = 0.0 	
SELECT @Importe1 = ISNULL(Importe1, 0.0), @Importe2 = ISNULL(Importe2, 0.0), @Importe3 = ISNULL(Importe3, 0.0), @Importe4 = ISNULL(Importe4, 0.0), @Importe5 = ISNULL(Importe5, 0.0),
@FormaCobro1 = NULLIF(RTRIM(FormaCobro1), ''), @FormaCobro2 = NULLIF(RTRIM(FormaCobro2), ''), @FormaCobro3 = NULLIF(RTRIM(FormaCobro3), ''), @FormaCobro4 = NULLIF(RTRIM(FormaCobro4), ''), @FormaCobro5 = NULLIF(RTRIM(FormaCobro5), ''),
@CobroDelEfectivo = ROUND(ISNULL(DelEfectivo, 0.0), @RedondeoMonetarios),
@CobroRedondeo = ISNULL(Redondeo, 0)
FROM VentaCobro WITH (NOLOCK)
WHERE ID = @ID
EXEC spVentaCobroTotal @FormaCobro1, @FormaCobro2, @FormaCobro3, @FormaCobro4, @FormaCobro5,
@Importe1, @Importe2, @Importe3, @Importe4, @Importe5, @CobroDesglosado OUTPUT, @Moneda = @MovMoneda, @TipoCambio = @MovTipoCambio
IF @FormaCobro1 = @FormaCobroVales SELECT @ValesCobrados = @ValesCobrados + @Importe1
IF @FormaCobro2 = @FormaCobroVales SELECT @ValesCobrados = @ValesCobrados + @Importe2
IF @FormaCobro3 = @FormaCobroVales SELECT @ValesCobrados = @ValesCobrados + @Importe3
IF @FormaCobro4 = @FormaCobroVales SELECT @ValesCobrados = @ValesCobrados + @Importe4
IF @FormaCobro5 = @FormaCobroVales SELECT @ValesCobrados = @ValesCobrados + @Importe5
IF @FormaCobro1 = @FormaCobroTarjetas SELECT @TarjetasCobradas = @TarjetasCobradas + @Importe1
IF @FormaCobro2 = @FormaCobroTarjetas SELECT @TarjetasCobradas = @TarjetasCobradas + @Importe2
IF @FormaCobro3 = @FormaCobroTarjetas SELECT @TarjetasCobradas = @TarjetasCobradas + @Importe3
IF @FormaCobro4 = @FormaCobroTarjetas SELECT @TarjetasCobradas = @TarjetasCobradas + @Importe4
IF @FormaCobro5 = @FormaCobroTarjetas SELECT @TarjetasCobradas = @TarjetasCobradas + @Importe5
IF @CfgFormaPagoRequerida = 1
IF (@Importe1 > 0.0 AND @FormaCobro1 IS NULL) OR (@Importe2 > 0.0 AND @FormaCobro2 IS NULL) OR (@Importe3 > 0.0 AND @FormaCobro3 IS NULL) OR (@Importe4 > 0.0 AND @FormaCobro4 IS NULL) OR (@Importe5 > 0.0 AND @FormaCobro5 IS NULL)
SELECT @Ok = 30530
IF @ImporteTotal < @CobroDesglosado + @CobroDelEfectivo
SELECT @CobroCambio = @CobroDesglosado + @CobroDelEfectivo - @ImporteTotal - @CobroRedondeo
IF @ImporteTotal = @CobroDelEfectivo AND @CobroDesglosado <> 0
SELECT @Ok = 30100
IF @ValesCobrados > 0.0 OR @TarjetasCobradas <> 0.0 	
BEGIN
EXEC spValeValidarCobro @Empresa, @Modulo, @ID, @Accion, @FechaEmision, @ValesCobrados, @TarjetasCobradas, @MovMoneda, @Ok OUTPUT, @OkRef OUTPUT
IF @TarjetasCobradas = 0 AND Exists(SELECT * FROM TarjetaSerieMov WITH (NOLOCK) WHERE Empresa = @Empresa AND Modulo = @Modulo AND ID = @ID AND ISNULL(Importe,0) <> 0)
SELECT @Ok = 36171
IF @ValesCobrados = 0 AND Exists(SELECT * FROM ValeSerieMov WITH (NOLOCK) WHERE Empresa = @Empresa AND Modulo = @Modulo AND ID = @ID)
SELECT @Ok = 36170
END
IF (@MovTipo IN ('VTAS.N', 'VTAS.FM') AND @CfgVentaLiquidaIntegral = 1) OR
(@MovTipo IN ('VTAS.F','VTAS.FAR') AND @CfgFacturaCobroIntegrado = 1) OR
@MovTipo IN ('VTAS.P', 'VTAS.S', 'VTAS.SD', 'VTAS.VP')
SELECT @ValidarCobroIntegrado = 1
ELSE
SELECT @ValidarCobroIntegrado = 0
IF @CobroDesglosado + @CobroDelEfectivo = 0.0 AND @ValidarCobroIntegrado = 0 AND @MovID IS NULL
SELECT @AfectarConsecutivo = 1
ELSE
BEGIN
IF ROUND(@CobroDesglosado + @CobroDelEfectivo, 2) < ROUND(ROUND(@ImporteTotal, @CfgVentaCobroRedondeoDecimales) + @CobroRedondeo, 2) AND @Ok IS NULL
BEGIN
IF ABS(@ImporteTotal + @CobroRedondeo - (@CobroDesglosado + @CobroDelEfectivo)) > 0.01
BEGIN
SELECT @Ok = 20370, @OkRef = 'Diferencia: '+LTRIM(Convert(varchar, @ImporteTotal + @CobroRedondeo - (@CobroDesglosado + @CobroDelEfectivo)))
IF @CobroIntegradoParcial = 1
SELECT @Ok = NULL, @OkRef = NULL
END
END
IF @ImporteTotal>=0.0 AND ROUND(@CobroCambio, 1) > ROUND(@CobroDesglosado, 1) AND @Ok IS NULL
SELECT @Ok = 30250
IF @CobroDelEfectivo > 0.0 AND @MovTipo NOT IN ('VTAS.SD', 'VTAS.VP') AND @Ok IS NULL
BEGIN
SELECT @Efectivo = 0.0
SELECT @Efectivo = ISNULL(Saldo, 0.0) FROM CxcEfectivo WITH (NOLOCK) WHERE Empresa = @Empresa AND Cliente = @ClienteProv AND Moneda = @MovMoneda
IF ROUND(@CobroDelEfectivo, 0) > ROUND(-@Efectivo, 0)
SELECT @Ok = 30090
END ELSE
IF @CobroDelEfectivo < 0.0 SELECT @Ok = 30100
END
END
END
END
IF @Estatus IN ('SINAFECTAR', 'BORRADOR', 'CONFIRMAR') AND @Accion NOT IN ('CANCELAR', 'GENERAR') AND @Ok IS NULL
BEGIN
IF @CfgValidarCC = 1 AND @Modulo IN ('VTAS', 'COMS', 'INV')
BEGIN
SELECT @ContUso = NULL
IF @Modulo = 'VTAS'
BEGIN
IF @ContUso IS NULL SELECT @ContUso = MIN(d.ContUso) FROM VentaD d WITH (NOLOCK) WHERE d.ID = @ID AND NULLIF(RTRIM(d.ContUso), '') IS NOT NULL AND d.ContUso NOT IN (SELECT v.CentroCostos FROM CentroCostosEmpresa v  WITH (NOLOCK) WHERE v.Empresa  = @Empresa)
IF @ContUso IS NULL SELECT @ContUso = MIN(d.ContUso) FROM VentaD d WITH (NOLOCK) WHERE d.ID = @ID AND NULLIF(RTRIM(d.ContUso), '') IS NOT NULL AND d.ContUso NOT IN (SELECT v.CentroCostos FROM CentroCostosSucursal v WITH (NOLOCK) WHERE v.Sucursal = @Sucursal)
IF @ContUso IS NULL SELECT @ContUso = MIN(d.ContUso) FROM VentaD d WITH (NOLOCK) WHERE d.ID = @ID AND NULLIF(RTRIM(d.ContUso), '') IS NOT NULL AND d.ContUso NOT IN (SELECT v.CentroCostos FROM CentroCostosUsuario v  WITH (NOLOCK) WHERE v.Usuario  = @Usuario)
END ELSE
IF @Modulo = 'COMS'
BEGIN
IF @ContUso IS NULL SELECT @ContUso = MIN(d.ContUso) FROM CompraD d WITH (NOLOCK) WHERE d.ID = @ID AND NULLIF(RTRIM(d.ContUso), '') IS NOT NULL AND d.ContUso NOT IN (SELECT v.CentroCostos FROM CentroCostosEmpresa v  WITH (NOLOCK) WHERE v.Empresa  = @Empresa)
IF @ContUso IS NULL SELECT @ContUso = MIN(d.ContUso) FROM CompraD d WITH (NOLOCK) WHERE d.ID = @ID AND NULLIF(RTRIM(d.ContUso), '') IS NOT NULL AND d.ContUso NOT IN (SELECT v.CentroCostos FROM CentroCostosSucursal v WITH (NOLOCK) WHERE v.Sucursal = @Sucursal)
IF @ContUso IS NULL SELECT @ContUso = MIN(d.ContUso) FROM CompraD d WITH (NOLOCK) WHERE d.ID = @ID AND NULLIF(RTRIM(d.ContUso), '') IS NOT NULL AND d.ContUso NOT IN (SELECT v.CentroCostos FROM CentroCostosUsuario v  WITH (NOLOCK) WHERE v.Usuario  = @Usuario)
END ELSE
IF @Modulo = 'INV'
BEGIN
IF @ContUso IS NULL SELECT @ContUso = MIN(d.ContUso) FROM InvD d WITH (NOLOCK) WHERE d.ID = @ID AND NULLIF(RTRIM(d.ContUso), '') IS NOT NULL AND d.ContUso NOT IN (SELECT v.CentroCostos FROM CentroCostosEmpresa v  WITH (NOLOCK) WHERE v.Empresa  = @Empresa)
IF @ContUso IS NULL SELECT @ContUso = MIN(d.ContUso) FROM InvD d WITH (NOLOCK) WHERE d.ID = @ID AND NULLIF(RTRIM(d.ContUso), '') IS NOT NULL AND d.ContUso NOT IN (SELECT v.CentroCostos FROM CentroCostosSucursal v WITH (NOLOCK) WHERE v.Sucursal = @Sucursal)
IF @ContUso IS NULL SELECT @ContUso = MIN(d.ContUso) FROM InvD d WITH (NOLOCK) WHERE d.ID = @ID AND NULLIF(RTRIM(d.ContUso), '') IS NOT NULL AND d.ContUso NOT IN (SELECT v.CentroCostos FROM CentroCostosUsuario v  WITH (NOLOCK) WHERE v.Usuario  = @Usuario)
END
IF @ContUso IS NOT NULL SELECT @Ok = 20765, @OkRef = @ContUso
END
IF @CfgVentaRestringida = 1 AND @MovTipo IN ('VTAS.F','VTAS.FAR', 'VTAS.FB', 'VTAS.FM', 'VTAS.N') AND @Ok IS NULL AND @Accion NOT IN ('GENERAR', 'CANCELAR')
EXEC spVentaRestringida @ID, @Accion, @Empresa, @Ok OUTPUT, @OkRef OUTPUT
IF @CfgRestringirArtBloqueados = 1 AND @Modulo IN ('VTAS', 'COMS') AND @Ok IS NULL
BEGIN
SELECT @OkRef = NULL
IF @Modulo = 'VTAS' SELECT @OkRef = MIN(d.Articulo) FROM VentaD d WITH (NOLOCK), Art a WITH (NOLOCK)  WHERE d.ID = @ID AND d.Articulo = a.Articulo AND a.Estatus = 'BLOQUEADO' ELSE
IF @Modulo = 'COMS' SELECT @OkRef = MIN(d.Articulo) FROM CompraD d WITH (NOLOCK), Art a WITH (NOLOCK) WHERE d.ID = @ID AND d.Articulo = a.Articulo AND a.Estatus = 'BLOQUEADO'
IF @OkRef IS NOT NULL SELECT @Ok = 26110
END
END
IF @MovTipo = 'VTAS.CTO'
IF EXISTS(SELECT * FROM Venta WITH (NOLOCK) WHERE ID = @ID AND (ConVigencia=0 OR VigenciaDesde IS NULL OR VigenciaHasta IS NULL OR VigenciaHasta < VigenciaDesde))
SELECT @Ok = 10095
IF @MovTipo = 'PROD.E' AND @Accion NOT IN ('GENERAR', 'CANCELAR') AND @Ok IS NULL
IF EXISTS(SELECT * FROM ProdD WITH (NOLOCK) WHERE ID = @ID AND NULLIF(RTRIM(Tipo), '') IS NULL) SELECT @Ok = 25390
IF @MovTipo IN ('COMS.F', 'COMS.FL', 'COMS.EG', 'COMS.EI') AND @Accion NOT IN ('GENERAR', 'CANCELAR') AND @Ok IS NULL
AND (@Autorizacion IS NULL OR @Mensaje NOT IN (20900, 20901))
BEGIN
EXEC spCompraValidarPresupuesto @Empresa, @ID, @FechaEmision, @Ok OUTPUT, @OkRef OUTPUT
IF @Ok IS NOT NULL SELECT @Autorizar = 1
END
RETURN
END



GO
