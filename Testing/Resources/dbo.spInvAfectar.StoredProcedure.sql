SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].[spInvAfectar]
@ID                		int,
@Accion			char(20),
@Base			char(20),
@Empresa	      		char(5),
@Modulo	      		char(5),
@Mov	  	      		char(20),
@MovID             		varchar(20)	OUTPUT,
@MovTipo     		char(20),
@MovMoneda	      		char(10),
@MovTipoCambio	 	float,
@FechaEmision		datetime,
@FechaAfectacion    		datetime,
@FechaConclusion	 	datetime,
@Concepto	      		varchar(50),
@Proyecto	      		varchar(50),
@Usuario	      		char(10),
@Autorizacion      		char(10),
@Referencia	      		varchar(50),
@DocFuente	      		int,
@Observaciones     		varchar(255),
@Estatus           		char(15),
@EstatusNuevo		char(15),
@FechaRegistro     		datetime,
@Ejercicio	      		int,
@Periodo	      		int,
@Almacen        		char(10),
@AlmacenTipo			char(15),
@AlmacenDestino    		char(10),
@AlmacenDestinoTipo		char(15),
@VoltearAlmacen		bit,
@AlmacenEspecifico		char(10),
@Largo			bit,
@Condicion			varchar(50),
@Vencimiento			datetime,
@Periodicidad		varchar(20),
@EndosarA			varchar(10),
@ClienteProv			char(10),
@EnviarA			int,
@DescuentoGlobal		float,
@SobrePrecio			float,
@Agente			char(10),
@AnticiposFacturados		money,
@ServicioArticulo		char(20),
@ServicioSerie		char(20),
@FechaRequerida		datetime,
@ZonaImpuesto		varchar(50),
@OrigenTipo			varchar(10),
@Origen			varchar(20),
@OrigenID			varchar(20),
@OrigenMovTipo		varchar(20),
@CfgFormaCosteo    		char(20),
@CfgTipoCosteo     		char(20),
@CfgCosteoActividades	varchar(20),
@CfgCosteoNivelSubCuenta	bit,
@CfgCosteoMultipleSimultaneo bit,
@CfgPosiciones		bit,
@CfgExistenciaAlterna	bit,
@CfgExistenciaAlternaSerieLote bit,
@CfgSeriesLotesMayoreo	bit,
@CfgSeriesLotesAutoCampo	char(20),
@CfgSeriesLotesAutoOrden	char(20),
@CfgCosteoSeries		bit,
@CfgCosteoLotes		bit,
@CfgValidarLotesCostoDif	bit,
@CfgVentaSurtirDemas		bit,
@CfgCompraRecibirDemas	bit,
@CfgTransferirDemas		bit,
@CfgBackOrders		bit,
@CfgContX			bit,
@CfgContXGenerar		char(20),
@CfgContXFacturasPendientes  bit,
@CfgEmbarcar			bit,
@CfgImpInc			bit,
@CfgVentaContratosArticulo	char(20),
@CfgVentaContratosImpuesto	float,
@CfgVentaComisionesCobradas	bit,
@CfgAnticiposFacturados	bit,
@CfgMultiUnidades		bit,
@CfgMultiUnidadesNivel	char(20),
@CfgCompraFactorDinamico 	bit,
@CfgInvFactorDinamico   	bit,
@CfgProdFactorDinamico  	bit,
@CfgVentaFactorDinamico 	bit,
@CfgCompraAutoCargos		bit,
@CfgVentaAutoBonif		bit,
@CfgVINAccesorioArt 		bit,
@CfgVINCostoSumaAccesorios	bit,
@SeguimientoMatriz		bit,
@CobroIntegrado		bit,
@CobroIntegradoCxc		bit,
@CobroIntegradoParcial       bit,
@CobrarPedido		bit,
@AfectarDetalle              bit,
@AfectarMatando		bit,
@AfectarVtasMostrador	bit,
@FacturarVtasMostrador	bit,
@AfectarConsignacion		bit,
@AfectarAlmacenRenglon	bit,
@CfgVentaMultiAgente		bit,
@CfgVentaMultiAlmacen	bit,
@CfgVentaArtAlmacenEspecifico bit,
@CfgTipoMerma		char(1),
@CfgComisionBase		char(20),
@CfgLimiteRenFacturas	int,
@CfgVentaRedondeoDecimales	int,
@CfgCompraCostosImpuestoIncluido bit,
@AfectarConsecutivo		bit,
@EsTransferencia		bit,
@Conexion			bit,
@SincroFinal			bit,
@Sucursal			int,
@SucursalDestino		int,
@SucursalOrigen		int,
@Utilizar			bit,
@UtilizarID			int,
@UtilizarMov			char(20),
@UtilizarSerie		char(20),
@UtilizarMovTipo		char(20),
@UtilizarMovID		varchar(20),
@Generar                     bit,
@GenerarMov                  char(20),
@GenerarSerie		char(20),
@GenerarAfectado		bit,
@GenerarCopia		bit,
@GenerarPoliza		bit,
@GenerarOP			bit,
@GenerarGasto		bit,
@FacturacionRapidaAgrupada	bit,
@IDTransito			int	     OUTPUT,
@IDGenerar		 	int	     OUTPUT,
@GenerarMovID	  	varchar(20)  OUTPUT,
@ContID			int	     OUTPUT,
@Ok                		int          OUTPUT,
@OkRef             		varchar(255) OUTPUT,
@CfgPrecioMoneda		bit = 0


AS BEGIN
DECLARE
@Dias			int,
@Renglon             	float,
@RenglonSub		 	int,
@RenglonID			int,
@RenglonTipo		char(1),
@Articulo	         	char(20),
@Posicion			char(10),
@AuxiliarAlternoSucursal	int,
@AuxiliarAlternoAlmacen	char(10),
@AuxiliarAlternoFactorEntrada float,
@AuxiliarAlternoFactorSalida  float,
@ArtTipo	         	varchar(20),
@ArtSerieLoteInfo		bit,
@ArtTipoOpcion		varchar(20),
@ArtComision		varchar(50),
@Peso			float,
@Volumen			float,
@Subcuenta	         	varchar(50),
@AcumularSinDetalles	bit,
@AcumCantidad		float,
@Cantidad	         	float,
@Factor			float,
@MovUnidad			varchar(50),
@CantidadOriginal		float,
@CantidadObsequio		float,
@CantidadInventario		float,
@CantidadReservada	 	float,
@CantidadOrdenada		float,
@CantidadOrdenadaA		float,
@CantidadPendiente   	float,
@CantidadPendienteA		float,
@CantidadA	       	 	float,
@IDSalidaTraspaso		int,
@IDAplica			int,
@AplicaMov              	char(20),
@AplicaMovID            	varchar(20),
@AplicaMovTipo		char(20),
@AlmacenRenglon		char(10),
@AgenteRenglon		char(10),
@AlmacenOrigen		char(10),
@Costo	         	float,		
@CostoInv			float,		
@CostoInvTotal          	money,
@Precio	         	float,
@PrecioN	         	float,
@PrecioTipoCambio		float,
@DescuentoTipo	 	char(1),
@DescuentoLinea	 	float,
@Impuesto1		 	float,
@Impuesto1N		 	float,
@Impuesto2		 	float,
@Impuesto2N		 	float,
@Impuesto3		 	money,
@Impuesto3N		 	money,
@Importe             	money,
@ImporteNeto             	money,
@Impuestos		 	money,
@ImpuestosNetos		money,
@Impuesto1Neto 		money,
@Impuesto2Neto 		money,
@Impuesto3Neto 		money,
@ImporteComision		money,
@DescuentoLineaImporte	money,
@DescuentoGlobalImporte	money,
@SobrePrecioImporte		money,
@AnticipoImporte		money,
@AnticipoImpuestos		money,
@ImporteCx			money,
@ImpuestosCx		money,
@RetencionCx		money,
@Retencion2Cx		money,
@Retencion3Cx		money,
@ImporteTotalCx		money,
@CondicionCx		varchar(50),
@VencimientoCx		datetime,
@FacturandoRemision         bit,
@TienePendientes		bit,
@SumaPendiente       	float,
@SumaReservada		float,
@SumaOrdenada		float,
@SumaImporte		money,
@SumaImporteNeto	 	money,
@SumaImpuestos	 	money,
@SumaImpuestosNetos	 	money,
@SumaImpuesto1Neto 	 	money,
@SumaImpuesto2Neto 	 	money,
@SumaImpuesto3Neto 	 	money,
@SumaDescuentoLinea		money,
@SumaPrecioLinea		money,
@SumaCostoLinea		money,
@SumaPeso			float,
@SumaVolumen		float,
@SumaComision		money,
@SumaRetencion		money,
@SumaRetencion2		money,
@SumaRetencion3		money,
@SumaRetenciones		money,
@SumaAnticiposFacturados	money,
@Retencion			money,
@Retencion2			money,
@Retencion3			money,
@Paquetes			int,
@ImporteTotal		money,
@MovImpuesoSubTotal		money,
@ImporteMatar		money,
@FechaCancelacion		datetime,
@ArtUnidad			varchar(50),
@ArtCantidad		float,
@ArtCosto	         	float,		
@ArtCostoInv		float,		
@ArtAjusteCosteo		float,
@ArtCostoUEPS		float,
@ArtCostoPEPS		float,
@ArtUltimoCosto		float,
@ArtPrecioLista		float,
@ArtDepartamentoDetallista	int,
@ArtMoneda			char(10),
@ArtFactor	 	 	float,
@ArtTipoCambio		float,
@ArtCostoIdentificado	bit,
@AjustePrecioLista		money,
@MovRetencion1		float,
@MovRetencion2		float,
@MovRetencion3		float,
@ReservadoParcial		float,
@ExplotandoRenglon		float,
@ExplotandoSubCuenta	bit,
@EsEntrada           	bit,
@EsSalida		 	bit,
@EsCargo			bit,
@AfectarCantidad		float,
@AfectarAlmacen		char(10),
@AfectarAlmacenDestino	char(10),
@AfectarSerieLote		bit,
@AfectarCostos       	bit,
@AfectarUnidades     	bit,
@AfectarPiezas       	bit,
@AfectarRama		char(5),
@UtilizarBase		char(20),
@UtilizarEstatus		char(15),
@GenerarAlmacen		char(10),
@GenerarAlmacenDestino	char(10),
@GenerarEstatus		char(15),
@GenerarDirecto		bit,
@GenerarMovTipo 	 	char(20),
@GenerarPeriodo 	 	int,
@GenerarEjercicio 	 	int,
@GenerarPolizaTemp		bit,
@YaGeneroConsecutivo	bit,
@CxModulo			char(5),
@CxID			int,
@CxMov			char(20),
@CxMovID			varchar(20),
@CxMovEspecifico		varchar(20),
@CxAgente			char(10),
@CxMovTipo			varchar(20),
@CxImporte			money,
@CxAjusteID			int,
@CxAjusteMov		char(20),
@CxAjusteMovID		varchar(20),
@CxAjusteImporte		money,
@CxConcepto			varchar(50),
@CompraID			int,
@Cliente			char(10),
@DetalleTipo		varchar(20),
@Merma			float,
@Desperdicio		float,
@CantidadCalcularImporte	float,
@DestinoTipo	  	varchar(10),
@Destino			varchar(20),
@DestinoID			varchar(20),
@CobroDesglosado		money,
@CobroCambio		money,
@CobroRedondeo		money,
@CobroSumaEfectivo		money,
@CobroDelEfectivo		money,
@ValesCobrados		money,
@TarjetasCobradas		money,		
@DineroImporte		money,
@DineroModulo		char(5),
@DineroMov			char(20),
@DineroMovID		varchar(20),
@MovImpuesto		bit,
@Importe1			money,
@Importe2			money,
@Importe3			money,
@Importe4			money,
@Importe5			money,
@ImporteCambio		money,
@FormaCobro1		varchar(50),
@FormaCobro2		varchar(50),
@FormaCobro3		varchar(50),
@FormaCobro4		varchar(50),
@FormaCobro5		varchar(50),
@FormaCobroVales		varchar(50),
@FormaCobroTarjetas		varchar(50), 	
@IncrementaSaldoTarjeta	bit,	     	
@FormaPagoCambio		varchar(50),
@Referencia1		varchar(50),
@Referencia2		varchar(50),
@Referencia3		varchar(50),
@Referencia4		varchar(50),
@Referencia5		varchar(50),
@CtaDinero			char(10),
@Cajero			char(10),
@FormaMoneda		char(10),
@FormaTipoCambio		float,
@AlmacenEspecificoVenta	char(10),
@MatarAntes			bit,
@UltRenglonIDJuego		int,
@CantidadJuego		float,
@CantidadMinimaJuego	int,
@AlmacenTemp		char(10),
@AlmacenOriginal		char(10),
@AlmacenDestinoOriginal	char(10),
@ProdSerieLote		varchar(50),
@VIN			varchar(20),
@UltReservadoCantidad	float,
@UltReservadoFecha		datetime,
@UltAgente			char(10),
@ComisionAcum		money,
@ComisionImporteNeto	float,
@ComisionFactor		float,
@Producto			varchar(20),
@SubProducto		varchar(50),
@IVAFiscal			float,
@IEPSFiscal			float,
@AfectandoNotasSinCobro	bit,
@Continuar			bit,
@ArtProvCosto		float,
@ProveedorRef 		varchar(10),
@CfgRetencionAlPago		bit,
@CfgRetencionMov		char(20),
@CfgRetencionAcreedor	char(10),
@CfgRetencionConcepto	varchar(50),
@CfgRetencion2Acreedor	char(10),
@CfgRetencion2Concepto	varchar(50),
@CfgRetencion3Acreedor	char(10),
@CfgRetencion3Concepto	varchar(50),
@CfgIngresoMov		char(20),
@CfgEstadisticaAjusteMerma	char(20),
@CfgInvAjusteCargoAgente	varchar(20),
@CfgVentaDMultiAgenteSugerir bit,
@CfgVentaMonedero		bit,
@CfgVentaPuntosEnVales	bit,
@EspacioD			varchar(10),
@EspacioDAnterior		varchar(10),
@Ruta			char(20),
@Orden			int,
@OrdenDestino		int,
@Centro			char(10),
@CentroDestino		char(10),
@Estacion			char(10),
@EstacionDestino		char(10),
@TiempoEstandarFijo		float,
@TiempoEstandarVariable 	float,
@DescuentoInverso		float,
@SucursalAlmacen        	int,
@SucursalAlmacenDestino 	int,
@ProrrateoAplicaID		int,
@ProrrateoAplicaIDMov	varchar(20),
@ProrrateoAplicaIDMovID	varchar(20),
@ArtLotesFijos		bit,
@ArtActividades		bit,
@SeriesLotesAutoOrden	varchar(50),
@CostoActividad		money,
@CotizacionID		int,
@CotizacionEstatusNuevo	char(15),
@Hoy			datetime,
@RedondeoMonetarios		int,
@CfgDiasHabiles		varchar(20),
@CfgABCDiasHabiles		bit,
@CostosImpuestoIncluido 	bit,
@BorrarRetencionCx		bit,
@MovImpuestoFactor		float,
@PrecioSinImpuestos		float,
@ModificarCosto 		float,
@ModificarPrecio 		float,
@CfgAC			bit,
@LCMetodo			int,
@LCPorcentajeResidual	float,
@PPTO			bit,
@PPTOVentas			bit,
@WMS			bit,
@WMSMov			varchar(20),
@TransitoSucursal		int,
@TransitoMov 		varchar(20),
@TransitoMovID 		varchar(20),
@TransitoEstatus 		varchar(15),
@TraspasoExpressMov		varchar(20),
@TraspasoExpressMovID	varchar(20),
@FEA			bit,
@FEAConsecutivo		varchar(20),
@FEAReferencia		varchar(50),
@FEASerie			varchar(20),
@FEAFolio			int,
@MovTipoConsecutivoFEA	varchar(20),
@CantidadDif		float,
@CfgArrastrarSerieLote	bit,
@CfgNotasBorrador		bit,
@NoValidarDisponible	bit,
@IDOrigen 			int,
@CfgVentaArtEstatus		bit,
@CfgVentaArtSituacion	bit,
@ArtEstatus			varchar(15),
@ArtSituacion		varchar(50),
@ArtExcento1		bit,
@ArtExcento2		bit,
@ArtExcento3		bit,
@Fiscal			bit,
@ReferenciaAplicacionAnticipo varchar(50),
@CxEndosoMov 		varchar(20),
@CxEndosoMovID 		varchar(20),
@CxEndosoID 		int,
@AutoEndosar 		varchar(20),
@Proveedor 			varchar(20),
@CfgMovCxpEndoso 		varchar(20),
@CfgCompraAutoEndosoAutoCargos bit,
@CorteDias int,
@MenosDias int,
@Dia int,
@EsQuince bit,
@DAPeriodo char(15)

SET @CorteDias = 2 -- FOX QUEMADO DIAS DESPUES DE LA QUINCENA DA DIAS 17 y 2 DE CORTE
SET @EsQuince = 0
--Select @DAPeriodo = DAPeriodo From Condicion With(NoLock) where Condicion = @Condicion


SELECT @RedondeoMonetarios = RedondeoMonetarios FROM Version With(NoLock)
SELECT @ArtMoneda		= NULL,
@SumaPendiente     	= 0.0,
@SumaReservada		= 0.0,
@SumaOrdenada		= 0.0,
@SumaImporte    	= 0.0,
@SumaImporteNeto    	= 0.0,
@SumaImpuestos	    	= 0.0,
@SumaImpuestosNetos   	= 0.0,
@SumaImpuesto1Neto    	= 0.0,
@SumaImpuesto2Neto    	= 0.0,
@SumaImpuesto3Neto    	= 0.0,
@SumaDescuentoLinea	= 0.0,
@SumaComision		= 0.0,
@SumaPrecioLinea	= 0.0,
@SumaCostoLinea	= 0.0,
@SumaPeso		= 0.0,
@SumaVolumen		= 0.0,
@SumaRetencion	 	= 0.0,
@SumaRetencion2 	= 0.0,
@SumaRetencion3 	= 0.0,
@ComisionAcum		= 0.0,
@ComisionImporteNeto	= 0.0,
@ExplotandoRenglon	= NULL,
@YaGeneroConsecutivo   = 0,
@MatarAntes 		= 0,
@UltRenglonIDJuego	= NULL,
@DetalleTipo		= NULL,
@Merma			= NULL,
@Desperdicio	        = NULL,
@VIN			= NULL,
@UltAgente		= NULL,
@Producto		= NULL,
@SubProducto		= NULL,
@ComisionFactor	= 1.0,
@IVAFiscal		 = NULL,
@IEPSFiscal		 = NULL,
@SucursalAlmacen        = NULL,
@SucursalAlmacenDestino = NULL,
@ArtLotesFijos		 = 0,
@ArtActividades	 = 0,
@MovImpuesto 		 = 0,
@CostosImpuestoIncluido = 0,
@BorrarRetencionCx	 = 0,
@FacturandoRemision     = 0,
@NoValidarDisponible	 = 0
SELECT @AlmacenOriginal = @Almacen, @AlmacenDestinoOriginal = @AlmacenDestino
SELECT @GenerarAlmacen = @Almacen, @GenerarAlmacenDestino = @AlmacenDestino
SELECT @Hoy = @FechaRegistro
EXEC spExtraerFecha @Hoy OUTPUT
SELECT @CfgDiasHabiles  = DiasHabiles,
@PPTO  = ISNULL(PPTO, 0),
@PPTOVentas = ISNULL(PPTOVentas, 0),
@WMS   = ISNULL(WMS, 0),
@CfgAC = ISNULL(AC, 0),
@FEA   = ISNULL(FEA, 0),
@Fiscal = ISNULL(Fiscal, 0)
FROM EmpresaGral With(NoLock)
WHERE Empresa = @Empresa
SELECT @CfgRetencionMov = CASE WHEN @MovTipo = 'COMS.D' THEN CxpDevRetencion ELSE CxpRetencion END,
@CfgIngresoMov   = VentaIngreso,
@CfgEstadisticaAjusteMerma = InvEstadisticaAjusteMerma
FROM EmpresaCfgMov With(NoLock)
WHERE Empresa = @Empresa
SELECT @CfgArrastrarSerieLote = ISNULL(VentaArrastrarSerieLote, 0),
@CfgNotasBorrador = NotasBorrador,
@CfgCompraAutoEndosoAutoCargos = ISNULL(CompraAutoEndosoAutoCargos, 0)
FROM EmpresaCfg With(NoLock)
WHERE Empresa = @Empresa
IF @MovTipo IN ('VTAS.N', 'VTAS.NO', 'VTAS.NR', 'VTAS.FM') AND @CfgNotasBorrador = 1 AND (@Estatus IN ('SINAFECTAR', 'BORRADOR', 'CONFIRMAR')  OR @Accion = 'CANCELAR')
SELECT @NoValidarDisponible = 1
SELECT @CfgRetencionAlPago      = ISNULL(RetencionAlPago, 0),
@CfgRetencionAcreedor    = NULLIF(RTRIM(GastoRetencionAcreedor), ''),
@CfgRetencionConcepto    = ISNULL(NULLIF(NULLIF(RTRIM(GastoRetencionConcepto), ''), '(Concepto Gasto)'), @Concepto),
@CfgRetencion2Acreedor   = NULLIF(RTRIM(GastoRetencion2Acreedor), ''),
@CfgRetencion2Concepto   = ISNULL(NULLIF(NULLIF(RTRIM(GastoRetencion2Concepto), ''), '(Concepto Gasto)'), @Concepto),
@CfgRetencion3Acreedor   = NULLIF(RTRIM(GastoRetencion3Acreedor), ''),
@CfgRetencion3Concepto   = ISNULL(NULLIF(NULLIF(RTRIM(GastoRetencion3Concepto), ''), '(Concepto Gasto)'), @Concepto),
@CfgABCDiasHabiles       = ISNULL(InvFrecuenciaABCDiasHabiles, 0),
@CfgInvAjusteCargoAgente = UPPER(InvAjusteCargoAgente),
@CfgVentaDMultiAgenteSugerir = ISNULL(VentaDMultiAgenteSugerir, 0),
@CfgVentaPuntosEnVales   = ISNULL(VentaPuntosEnVales, 0),
@CfgVentaMonedero        = ISNULL(VentaMonedero, 0), 	
@CfgVentaArtEstatus	  = ISNULL(VentaArtEstatus, 0),
@CfgVentaArtSituacion	  = ISNULL(VentaArtSituacion, 0)
FROM EmpresaCfg2 With(NoLock)
WHERE Empresa = @Empresa
IF @OrigenTipo = 'INV'
SELECT @IDOrigen = ID FROM Inv With(NoLock) WHERE Empresa = @Empresa AND Sucursal = @Sucursal AND Mov = @Origen AND MovID = @OrigenID AND Estatus IN ('PENDIENTE', 'CONCLUIDO')
IF @OrigenTipo = 'VTAS'
SELECT @IDOrigen = ID FROM Venta With(NoLock) WHERE Empresa = @Empresa AND Sucursal = @Sucursal AND Mov = @Origen AND MovID = @OrigenID AND Estatus IN ('PENDIENTE', 'CONCLUIDO')
IF @OrigenTipo = 'COMS'
SELECT @IDOrigen = ID FROM Compra With(NoLock) WHERE Empresa = @Empresa AND Sucursal = @Sucursal AND Mov = @Origen AND MovID = @OrigenID AND Estatus IN ('PENDIENTE', 'CONCLUIDO')
IF @OrigenTipo = 'PROD'
SELECT @IDOrigen = ID FROM Prod With(NoLock) WHERE Empresa = @Empresa AND Sucursal = @Sucursal AND Mov = @Origen AND MovID = @OrigenID AND Estatus IN ('PENDIENTE', 'CONCLUIDO')
IF @Accion IN ('RESERVAR', 'DESRESERVAR', 'RESERVARPARCIAL', 'ASIGNAR', 'DESASIGNAR') AND @MovTipo NOT IN ('VTAS.P', 'VTAS.F','VTAS.FAR', 'VTAS.FC', 'VTAS.FG', 'VTAS.FX', 'VTAS.S', 'INV.SOL', 'INV.SM', 'INV.OT', 'INV.OI')
SELECT @Ok = 60040
IF @Utilizar = 1
BEGIN
IF @Utilizar = 1 AND @MovTipo IN ('VTAS.DC', 'VTAS.DCR') SELECT @GenerarAlmacen = @AlmacenDestino, @GenerarAlmacenDestino = @Almacen
IF @Accion = 'GENERAR' SELECT @GenerarEstatus = 'SINAFECTAR' ELSE SELECT @GenerarEstatus = 'CANCELADO'
IF @UtilizarMovTipo IN ('VTAS.C','VTAS.CS','VTAS.FR','VTAS.CTO','COMS.C') SELECT @GenerarDirecto = 1 ELSE SELECT @GenerarDirecto = 0
IF @UtilizarMovTipo = 'VTAS.CO' AND @CfgVentaContratosArticulo IS NULL SELECT @Ok = 20470
IF @VoltearAlmacen = 1 SELECT @AlmacenTemp = @GenerarAlmacen, @GenerarAlmacen = @GenerarAlmacenDestino, @GenerarAlmacenDestino = @AlmacenTemp
IF @Ok IS NULL
BEGIN
EXEC spMovGenerar @Sucursal, @Empresa, @Modulo, @Ejercicio, @Periodo, @Usuario, @FechaRegistro, @GenerarEstatus,
@GenerarAlmacen, @GenerarAlmacenDestino,
@UtilizarMov, @UtilizarMovID, @GenerarDirecto,
@Mov, @UtilizarSerie, @MovID OUTPUT, @ID OUTPUT, @Ok OUTPUT, @OkRef OUTPUT
IF @Ok IS NULL AND (@MovTipo IN ('INV.EI', 'INV.DTI', 'INV.SI') OR (@UtilizarMovTipo IN ('VTAS.VCR', 'VTAS.P', 'VTAS.C') AND @CfgArrastrarSerieLote = 1))
EXEC spMovCopiarSerieLote @Sucursal, @Modulo, @UtilizarID, @ID, 1
END
IF @Ok IS NULL
SELECT @YaGeneroConsecutivo = 1
IF @Ok IS NULL
BEGIN
IF @MovTipo = 'VTAS.EG'
UPDATE Venta WITH (ROWLOCK) SET AlmacenDestino = (SELECT AlmacenDestinoEntregaGarantia FROM EmpresaCfg With(NoLock) WHERE Empresa = @Empresa) WHERE ID = @ID
IF @UtilizarMovTipo = 'VTAS.CO'
BEGIN
UPDATE Venta WITH (ROWLOCK) SET Condicion = NULL, Vencimiento = NULL, Referencia = RTRIM(@UtilizarMov)+' '+LTRIM(CONVERT(CHAR, @UtilizarMovID)) WHERE ID = @ID
SELECT @Precio = sum(Precio * (Cantidad-ISNULL(CantidadCancelada,0)) * (1-(case DescuentoTipo when '$' then (ISNULL(DescuentoLinea, 0.0)/precio)*100 else ISNULL(DescuentoLinea,0.0) end)/100))
FROM VentaD With(NoLock)
WHERE ID = @UtilizarID
INSERT INTO VentaD (Sucursal, ID, Renglon, Aplica, AplicaID, Articulo, Cantidad, Precio, Impuesto1, Almacen)
VALUES (@Sucursal, @ID, 2048, @UtilizarMov, @UtilizarMovID, @CfgVentaContratosArticulo, 1, @Precio, @CfgVentaContratosImpuesto, @Almacen)
END ELSE
BEGIN
EXEC spInvUtilizarTodoDetalle @Sucursal, @Modulo, @Base, @UtilizarID, @UtilizarMov, @UtilizarMovID, @UtilizarMovTipo, @ID, @GenerarDirecto, @Ok OUTPUT, @Empresa = @Empresa, @MovTipo = @MovTipo
IF @MovTipo IN ('COMS.EG', 'COMS.EI', 'COMS.OI', 'INV.EI')
EXEC spMovCopiarGastoDiverso @Modulo, @Sucursal, @UtilizarID, @ID
IF @MovTipo IN ('VTAS.F','VTAS.FAR') AND @CfgLimiteRenFacturas > 0
IF @FacturacionRapidaAgrupada = 1
EXEC spInvLimiteRenFacturasAgrupada @ID, @CfgLimiteRenFacturas
ELSE
EXEC spInvLimiteRenFacturas @ID, @CfgLimiteRenFacturas
IF @UtilizarMovTipo IN ('VTAS.VC', 'VTAS.VCR') AND @MovTipo NOT IN ('VTAS.DC', 'VTAS.DCR') UPDATE VentaD WITH (ROWLOCK) SET Almacen = @GenerarAlmacen WHERE ID = @ID ELSE
IF @UtilizarMovTipo = 'INV.P'   UPDATE InvD WITH (ROWLOCK) SET Almacen = @GenerarAlmacenDestino WHERE ID = @ID ELSE
IF @UtilizarMovTipo = 'INV.SM' AND @MovTipo = 'INV.CM' UPDATE InvD WITH (ROWLOCK) SET Tipo = 'Salida' WHERE ID = @ID ELSE
IF @UtilizarMovTipo = 'PROD.O' AND @MovTipo IN ('PROD.E', 'PROD.CO')
BEGIN
IF @CfgTipoMerma = '#'
UPDATE ProdD WITH (ROWLOCK)
SET Tipo = 'Entrada',
Cantidad = Cantidad - ISNULL(a.Merma, 0) - ISNULL(a.Desperdicio, 0),
Merma = a.Merma,
Desperdicio  = a.Desperdicio
FROM ProdD d, Art a With(NoLock)
WHERE d.Articulo = a.Articulo AND d.ID = @ID
ELSE
UPDATE ProdD WITH (ROWLOCK)
SET Tipo = 'Entrada',
Cantidad = Cantidad - ISNULL(ROUND(d.Cantidad*(a.Merma/100), 10), 0) - ISNULL(ROUND(d.Cantidad*(a.Desperdicio/100), 10), 0),
Merma = ROUND(d.Cantidad*(a.Merma/100), 10),
Desperdicio  = ROUND(d.Cantidad*(a.Desperdicio/100), 10)
FROM ProdD d, Art a With(NoLock)
WHERE d.Articulo = a.Articulo AND d.ID = @ID
UPDATE ProdD WITH (ROWLOCK) SET CantidadInventario = Cantidad * Factor WHERE ID = @ID
END
END
SELECT @UtilizarBase = @Base, @Base = 'TODO', @IDGenerar = @ID
END
END ELSE
IF @VoltearAlmacen = 1 SELECT @AlmacenTemp = @GenerarAlmacen, @GenerarAlmacen = @GenerarAlmacenDestino, @GenerarAlmacenDestino = @AlmacenTemp
/* Otras Afectaciones */
IF @Modulo = 'VTAS' AND @Accion <> 'CANCELAR' AND @Estatus = 'SINAFECTAR'
IF EXISTS(SELECT ConVigencia FROM Venta With(NoLock) WHERE ID = @ID AND ConVigencia = 1)
UPDATE Cte WITH (ROWLOCK)
SET VigenciaDesde = v.VigenciaDesde, VigenciaHasta = v.VigenciaHasta
FROM Venta v With(NoLock)
WHERE v.ID = @ID AND v.Cliente = Cte.Cliente
IF @Accion = 'GENERAR' AND @Ok IS NULL
BEGIN
IF @Utilizar = 1
BEGIN
EXEC spMovTipo @Modulo, @Mov, @FechaAfectacion, @Empresa, NULL, NULL, @GenerarMovTipo OUTPUT, @GenerarPeriodo OUTPUT, @GenerarEjercicio OUTPUT, @Ok OUTPUT
BEGIN TRANSACTION
IF @UtilizarMovTipo IN ('VTAS.C', 'VTAS.CS', 'COMS.C')
BEGIN
EXEC spValidarTareas @Empresa, @Modulo, @UtilizarID, 'CONCLUIDO', @Ok OUTPUT, @OkRef OUTPUT
IF @UtilizarMovTipo IN ('VTAS.C', 'VTAS.CS') UPDATE Venta WITH (ROWLOCK) SET Estatus = 'CONCLUIDO' WHERE ID = @UtilizarID ELSE
IF @UtilizarMovTipo = 'COMS.C' UPDATE Compra  WITH (ROWLOCK) SET Estatus = 'CONCLUIDO' WHERE ID = @UtilizarID
IF @@ERROR <> 0 SELECT @Ok = 1
EXEC spMovFlujo @Sucursal, @Accion, @Empresa, @Modulo, @UtilizarID, @UtilizarMov, @UtilizarMovID, @Modulo, @ID, @Mov, 0, @Ok OUTPUT
END
IF @UtilizarBase = 'SELECCION'
BEGIN
IF @Modulo = 'VTAS' UPDATE VentaD  WITH (ROWLOCK) SET CantidadA = NULL WHERE ID = @UtilizarID AND CantidadA IS NOT NULL ELSE
IF @Modulo = 'COMS' UPDATE CompraD WITH (ROWLOCK) SET CantidadA = NULL WHERE ID = @UtilizarID AND CantidadA IS NOT NULL ELSE
IF @Modulo = 'INV'  UPDATE InvD    WITH (ROWLOCK) SET CantidadA = NULL WHERE ID = @UtilizarID AND CantidadA IS NOT NULL ELSE
IF @Modulo = 'PROD' UPDATE ProdD   WITH (ROWLOCK) SET CantidadA = NULL WHERE ID = @UtilizarID AND CantidadA IS NOT NULL
IF @@ERROR <> 0 SELECT @Ok = 1
END
IF @CfgVentaArtAlmacenEspecifico = 1 AND @Modulo = 'VTAS'
BEGIN
IF @CfgVentaMultiAlmacen = 0
BEGIN
SELECT @AlmacenEspecificoVenta = NULL
SELECT @AlmacenEspecificoVenta = MIN(NULLIF(RTRIM(AlmacenEspecificoVenta), ''))
FROM Art a With(NoLock), VentaD d With(NoLock)
WHERE d.ID = @ID AND d.Articulo = a.Articulo AND a.AlmacenEspecificoVentaMov = @Mov AND NULLIF(RTRIM(a.AlmacenEspecificoVenta), '') IS NOT NULL
IF @AlmacenEspecificoVenta IS NOT NULL
UPDATE Venta WITH (ROWLOCK) SET Almacen = @AlmacenEspecificoVenta WHERE ID = @ID
END ELSE
UPDATE VentaD WITH (ROWLOCK)
SET Almacen = NULLIF(RTRIM(AlmacenEspecificoVenta), '')
FROM VentaD d, Art a With(NoLock)
WHERE d.ID = @ID AND d.Articulo = a.Articulo AND a.AlmacenEspecificoVentaMov = @Mov AND NULLIF(RTRIM(a.AlmacenEspecificoVenta), '') IS NOT NULL
END
IF @UtilizarMovTipo IN ('VTAS.N', 'VTAS.NO', 'VTAS.NR', 'VTAS.FM') AND @MovTipo IN ('VTAS.N', 'VTAS.NO', 'VTAS.NR', 'VTAS.FM')
BEGIN
UPDATE VentaD WITH (ROWLOCK) SET Cantidad = -ABS(Cantidad), CantidadInventario = -ABS(CantidadInventario), Aplica = NULL, AplicaID = NULL WHERE ID = @ID
UPDATE Venta  WITH (ROWLOCK) SET Directo = 1, Referencia = RTRIM(@UtilizarMov)+' '+RTRIM(@UtilizarMovID) WHERE ID = @ID
END
IF @UtilizarMovTipo IN ('VTAS.N', 'VTAS.NO', 'VTAS.NR', 'VTAS.FM') AND @MovTipo = 'VTAS.SD'
BEGIN
UPDATE VentaD WITH (ROWLOCK) SET Aplica = NULL, AplicaID = NULL WHERE ID = @ID
UPDATE Venta  WITH (ROWLOCK) SET Directo = 1, Referencia = RTRIM(@UtilizarMov)+' '+RTRIM(@UtilizarMovID) WHERE ID = @ID
END
IF @Modulo = 'VTAS'
BEGIN
IF @MovTipo IN ('VTAS.N', 'VTAS.FM')
UPDATE Venta WITH (ROWLOCK) SET Condicion = NULL, Vencimiento = NULL WHERE ID = @ID
ELSE
IF @MovTipo <> 'VTAS.FR'
BEGIN
EXEC spCalcularVencimiento @Modulo, @Empresa, @ClienteProv, @Condicion, @Hoy, @Vencimiento OUTPUT, NULL, @Ok OUTPUT
UPDATE Venta WITH (ROWLOCK) SET Vencimiento = @Vencimiento WHERE ID = @ID AND Vencimiento <> @Vencimiento
END
END
IF @UtilizarMovTipo = 'INV.P'
UPDATE Inv WITH (ROWLOCK) SET Almacen = AlmacenDestino, AlmacenDestino = Almacen WHERE ID = @ID
/*      IF @MovTipo = 'INV.DTI'
BEGIN
UPDATE Inv SET Almacen = @AlmacenDestinoOriginal, AlmacenDestino = @Almacen WHERE ID = @IDGenerar
UPDATE InvD SET Almacen = @AlmacenDestinoOriginal WHERE ID = @IDGenerar
END*/
IF @MovTipo IN ('PROD.A', 'PROD.R', 'PROD.E')
EXEC spProdAvanceTiempoCentro @ID, @MovTipo, @MovMoneda, @MovTipoCambio
IF @Ok IS NULL
EXEC xpInvAfectar @ID, @Accion, @Base, @Empresa, @Usuario, @Modulo, @Mov, @MovID, @MovTipo,
@MovMoneda, @MovTipoCambio, @Estatus, @EstatusNuevo, @FechaEmision, @FechaRegistro, @FechaAfectacion, @Conexion, @SincroFinal, @Sucursal,
@UtilizarID, @UtilizarMovTipo,
@Ok OUTPUT, @OkRef OUTPUT
IF @Ok IS NULL
COMMIT TRANSACTION
ELSE BEGIN
ROLLBACK TRANSACTION
EXEC spEliminarMov @Modulo, @ID
END
END
RETURN
END
IF @MovTipo IN ('VTAS.N', 'VTAS.NO', 'VTAS.NR') AND @Accion = 'CANCELAR' AND @Estatus = 'CONCLUIDO'
SELECT @Ok = 60060
IF (@EstatusNuevo IN ('PENDIENTE', 'CONCLUIDO') AND @Modulo IN ('VTAS', 'COMS') AND
@MovTipo IN ('VTAS.N', 'VTAS.NO', 'VTAS.NR', 'VTAS.FM', 'VTAS.F', 'VTAS.FAR', 'VTAS.FC', 'VTAS.FG', 'VTAS.FX', 'VTAS.FB', 'VTAS.D', 'VTAS.DF', 'VTAS.B', 'COMS.F', 'COMS.FL', 'COMS.EG', 'COMS.EI', 'COMS.D', 'COMS.B', 'COMS.CC', 'COMS.DC', 'COMS.CA') )
OR (@EstatusNuevo = 'PROCESAR' AND @MovTipo IN ('VTAS.N', 'VTAS.NO', 'VTAS.NR'))
BEGIN
SELECT @MovImpuesto = 1
CREATE TABLE #MovImpuesto (
Renglon		float		NOT NULL,
RenglonSub	int		NOT NULL,
Impuesto1	float		NULL,
Impuesto2	float		NULL,
Impuesto3	float		NULL,
Importe1	money		NULL,
Importe2	money		NULL,
Importe3	money		NULL,
Retencion1	float		NULL,
Retencion2	float		NULL,
Retencion3	float		NULL,
Excento1	bit		NULL	DEFAULT 0,
Excento2	bit		NULL	DEFAULT 0,
Excento3	bit		NULL	DEFAULT 0,
SubTotal	money		NULL,
LoteFijo	varchar(20)	COLLATE Database_Default NULL)
END
IF @CobroIntegrado = 1 AND @CfgVentaComisionesCobradas = 1 AND @CfgComisionBase = 'COBRO'
BEGIN
SELECT @ComisionFactor = 1-ABS(ISNULL(DelEfectivo / NULLIF((ISNULL(Importe1, 0) + ISNULL(Importe2, 0) + ISNULL(Importe3, 0) + ISNULL(Importe4, 0) + ISNULL(Importe5, 0) - ISNULL(Cambio, 0) + ISNULL(DelEfectivo, 0)), 0), 0.0))
FROM VentaCobro WITH (NOLOCK)
WHERE ID = @ID
END
IF @MovTipo = 'INV.CP' AND @Estatus IN ('SINAFECTAR', 'BORRADOR', 'CONFIRMAR') AND @Accion = 'AFECTAR'
EXEC spAfectarCambioPresentacion @Sucursal, @ID, @Empresa, @MovMoneda, @MovTipoCambio, @CfgMultiUnidades, @CfgMultiUnidadesNivel, @CfgFormaCosteo, @CfgTipoCosteo, @Ok OUTPUT, @OkRef OUTPUT
IF @Ok IS NULL AND @YaGeneroConsecutivo = 0
EXEC spMovConsecutivo @Sucursal, @SucursalOrigen, @SucursalDestino, @Empresa, @Usuario, @Modulo, @Ejercicio, @Periodo, @ID, @Mov, NULL, @Estatus, @Concepto, @Accion, @Conexion, @SincroFinal, @MovID OUTPUT, @Ok OUTPUT, @OkRef OUTPUT
IF @Estatus IN ('SINAFECTAR', 'BORRADOR', 'CONFIRMAR') AND @Accion <> 'CANCELAR' AND @Ok IS NULL
EXEC spMovChecarConsecutivo	@Empresa, @Modulo, @Mov, @MovID, NULL, @Ejercicio, @Periodo, @Ok OUTPUT, @OkRef OUTPUT
IF @EstatusNuevo = 'CONFIRMAR' AND @MovTipo IN ('VTAS.N', 'VTAS.NO', 'VTAS.NR', 'VTAS.FM') RETURN
IF @Accion IN ('CONSECUTIVO', 'SINCRO') AND @Ok IS NULL
BEGIN
IF @Accion = 'SINCRO' EXEC spAsignarSucursalEstatus @ID, @Modulo, @SucursalDestino, @Accion
SELECT @Ok = 80060, @OkRef = @MovID, @Sucursal = @SucursalDestino
RETURN
END
IF @Generar = 1 AND @Ok IS NULL  
BEGIN
IF @MovTipo = 'INV.IF' SELECT @GenerarEstatus = 'SINAFECTAR' ELSE SELECT @GenerarEstatus = 'CANCELADO'
IF @MovTipo IN ('VTAS.C','VTAS.CS','VTAS.FR') SELECT @GenerarDirecto = 1 ELSE SELECT @GenerarDirecto = 0
EXEC spMovGenerar @Sucursal, @Empresa, @Modulo, @Ejercicio, @Periodo, @Usuario, @FechaRegistro, @GenerarEstatus,
@Almacen, @AlmacenDestino,
@Mov, @MovID, @GenerarDirecto,
@GenerarMov, @GenerarSerie, @GenerarMovID OUTPUT, @IDGenerar OUTPUT, @Ok OUTPUT, @OkRef OUTPUT
END
IF @Ok IS NOT NULL OR @AfectarConsecutivo = 1 RETURN
IF @Conexion = 0
BEGIN TRANSACTION
EXEC spMovEstatus @Modulo, 'AFECTANDO', @ID, @Generar, @IDGenerar, @GenerarAfectado, @Ok OUTPUT
IF @Estatus IN ('SINAFECTAR', 'CONFIRMAR', 'BORRADOR')
BEGIN
IF (SELECT Sincro FROM Version WITH (NOLOCK)) = 1
BEGIN
IF @Modulo = 'INV'  EXEC sp_executesql N'UPDATE InvD    WITH (ROWLOCK) SET Sucursal = @Sucursal, SincroC = 1 WHERE ID = @ID AND (Sucursal <> @Sucursal OR SincroC <> 1)', N'@Sucursal int, @ID int', @Sucursal, @ID ELSE
IF @Modulo = 'VTAS' EXEC sp_executesql N'UPDATE VentaD  WITH (ROWLOCK) SET Sucursal = @Sucursal, SincroC = 1 WHERE ID = @ID AND (Sucursal <> @Sucursal OR SincroC <> 1)', N'@Sucursal int, @ID int', @Sucursal, @ID ELSE
IF @Modulo = 'COMS' EXEC sp_executesql N'UPDATE CompraD WITH (ROWLOCK) SET Sucursal = @Sucursal, SincroC = 1 WHERE ID = @ID AND (Sucursal <> @Sucursal OR SincroC <> 1)', N'@Sucursal int, @ID int', @Sucursal, @ID ELSE
IF @Modulo = 'PROD' EXEC sp_executesql N'UPDATE ProdD   WITH (ROWLOCK) SET Sucursal = @Sucursal, SincroC = 1 WHERE ID = @ID AND (Sucursal <> @Sucursal OR SincroC <> 1)', N'@Sucursal int, @ID int', @Sucursal, @ID
END
END
IF @Ok IS NULL OR @Ok BETWEEN 80030 AND 81000
EXEC xpInvAfectarAntes @ID, @Accion, @Base, @Empresa, @Usuario, @Modulo, @Mov, @MovID, @MovTipo,
@MovMoneda, @MovTipoCambio, @Estatus, @EstatusNuevo, @FechaEmision, @FechaRegistro, @FechaAfectacion, @Conexion, @SincroFinal, @Sucursal,
NULL, NULL,
@Ok OUTPUT, @OkRef OUTPUT
IF @Accion <> 'CANCELAR' AND @Estatus <> 'PENDIENTE'
BEGIN
EXEC spRegistrarMovimiento @Sucursal, @Empresa, @Modulo, @Mov, @MovID, @ID, @Ejercicio, @Periodo, @FechaRegistro, @FechaEmision,
@Concepto, @Proyecto, @MovMoneda, @MovTipoCambio,
@Usuario, @Autorizacion, @Referencia, @DocFuente, @Observaciones,
@Generar, @GenerarMov, @GenerarMovID, @IDGenerar,
@Ok OUTPUT
END
IF @MovTipo IN ('PROD.A', 'PROD.R', 'PROD.E') AND @Ok IS NULL
BEGIN
EXEC spProdCostearAvance @Sucursal, @Accion, @Empresa, @Modulo, @ID, @Mov, @MovID, @MovTipo, @MovMoneda, @MovTipoCambio,
@FechaEmision, @FechaRegistro, @Usuario, @Proyecto, @Ejercicio, @Periodo, @Referencia, @Observaciones,
@Ok OUTPUT, @OkRef OUTPUT
IF @Estatus = 'SINAFECTAR' OR @Accion = 'CANCELAR'
EXEC spProdAvance @Sucursal, @Accion, @Empresa, @FechaEmision, @FechaRegistro, @Usuario, @ID, @Mov, @MovID, @MovTipo, @Ok OUTPUT, @OkRef OUTPUT
END
IF @MovTipo = 'PROD.E' AND @EstatusNuevo = 'CONCLUIDO' AND @Accion <> 'CANCELAR' AND @Ok IS NULL
EXEC spProdCostearEntrada @Empresa, @ID, @MovMoneda, @MovTipoCambio, @Ok OUTPUT, @OkRef OUTPUT
IF @MovTipo IN ('VTAS.F','VTAS.FAR', 'VTAS.FC', 'VTAS.FG', 'VTAS.FX', 'VTAS.FB') AND @CobroIntegrado = 0 AND @FacturarVtasMostrador = 0 AND @Estatus IN ('SINAFECTAR', 'CONFIRMAR', 'BORRADOR') AND @Accion <> 'CANCELAR' AND @Ok IS NULL
EXEC xpOtrosCargos @Empresa, @ID, @ClienteProv, @MovMoneda, @MovTipoCambio, @Ok OUTPUT, @OkRef OUTPUT
IF @AfectarDetalle = 1 AND @Ok IS NULL
BEGIN
IF @Accion = 'CANCELAR' OR (@MovTipo IN ('VTAS.F','VTAS.FAR', 'VTAS.FC', 'VTAS.FG', 'VTAS.FX') AND @EstatusNuevo = 'PENDIENTE') SELECT @MatarAntes = 1 ELSE SELECT @MatarAntes = 0
IF @AfectarMatando = 1 AND @Utilizar = 0 AND @MatarAntes = 1 AND @Ok IS NULL
EXEC spInvMatar @Sucursal, @ID, @Accion, @Base, @Empresa, @Usuario, @Modulo, @Mov, @MovID, @MovTipo,
@Estatus, @EstatusNuevo, @FechaEmision, @FechaRegistro, @FechaAfectacion, @Ejercicio, @Periodo, @AfectarConsignacion, @AlmacenTipo, @AlmacenDestinoTipo,
@CfgVentaSurtirDemas, @CfgCompraRecibirDemas, @CfgTransferirDemas, @CfgBackOrders, @CfgContX, @CfgContXGenerar, @CfgEmbarcar, @CfgImpInc, @CfgMultiUnidades, @CfgMultiUnidadesNivel,
@Ok OUTPUT, @OkRef OUTPUT,
@CfgPrecioMoneda = @CfgPrecioMoneda
IF @Modulo = 'VTAS'
BEGIN
DECLARE crVentaDetalle CURSOR
FOR SELECT d.Renglon, d.RenglonSub, d.RenglonID, d.RenglonTipo, ISNULL(d.Cantidad, 0.0), ISNULL(d.CantidadObsequio, 0.0), ISNULL(d.CantidadInventario, 0.0), ISNULL(d.CantidadReservada, 0.0), ISNULL(d.CantidadOrdenada, 0.0), ISNULL(d.CantidadPendiente, 0.0), ISNULL(d.CantidadA, 0.0), ISNULL(d.Factor, 0.0), NULLIF(RTRIM(d.Unidad), ''), d.Articulo, NULLIF(RTRIM(d.Subcuenta), ''), ISNULL(d.Costo, 0.0), ISNULL(d.Precio, 0.0), NULLIF(RTRIM(d.DescuentoTipo), ''), ISNULL(d.DescuentoLinea, 0.0), ISNULL(d.Impuesto1, 0.0), ISNULL(d.Impuesto2, 0.0), ISNULL(d.Impuesto3, 0.0), NULLIF(RTRIM(d.Aplica), ''), NULLIF(RTRIM(d.AplicaID), ''), d.Almacen, d.Agente, NULLIF(RTRIM(UPPER(a.Tipo)), ''), a.SerieLoteInfo, NULLIF(RTRIM(UPPER(a.TipoOpcion)), ''), ISNULL(a.Peso, 0.0), ISNULL(a.Volumen, 0.0), a.Unidad, d.UltimoReservadoCantidad, d.UltimoReservadoFecha, NULLIF(RTRIM(a.Comision), ''), NULLIF(RTRIM(d.Espacio), ''), a.LotesFijos, a.Actividades, a.CostoIdentificado, d.CostoUEPS, d.CostoPEPS, d.UltimoCosto, d.PrecioLista, d.PrecioTipoCambio, NULLIF(RTRIM(d.Posicion), ''), a.DepartamentoDetallista, a.Estatus, a.Situacion, a.Impuesto1Excento, a.Excento2, a.Excento3
FROM VentaD d, Art a
WHERE d.ID = @ID
AND d.Articulo = a.Articulo
OPEN crVentaDetalle
FETCH NEXT FROM crVentaDetalle INTO @Renglon, @RenglonSub, @RenglonID, @RenglonTipo, @CantidadOriginal, @CantidadObsequio, @CantidadInventario, @CantidadReservada, @CantidadOrdenada, @CantidadPendiente, @CantidadA, @Factor, @MovUnidad, @Articulo, @Subcuenta, @Costo, @Precio, @DescuentoTipo, @DescuentoLinea, @Impuesto1, @Impuesto2, @Impuesto3, @AplicaMov, @AplicaMovID, @AlmacenRenglon, @AgenteRenglon, @ArtTipo, @ArtSerieLoteInfo, @ArtTipoOpcion, @Peso, @Volumen, @ArtUnidad, @UltReservadoCantidad, @UltReservadoFecha, @ArtComision, @EspacioD, @ArtLotesFijos, @ArtActividades, @ArtCostoIdentificado, @ArtCostoUEPS, @ArtCostoPEPS, @ArtUltimoCosto, @ArtPrecioLista, @PrecioTipoCambio, @Posicion, @ArtDepartamentoDetallista, @ArtEstatus, @ArtSituacion, @ArtExcento1, @ArtExcento2, @ArtExcento3
IF @@ERROR <> 0 SELECT @Ok = 1
END ELSE
IF @Modulo = 'COMS'
BEGIN
DECLARE crCompraDetalle CURSOR
FOR SELECT d.Renglon, d.RenglonSub, d.RenglonID, d.RenglonTipo, ISNULL(d.Cantidad, 0.0), ISNULL(d.CantidadInventario, 0.0), d.Cantidad, d.Cantidad, ISNULL(d.CantidadPendiente, 0.0), ISNULL(d.CantidadA, 0.0), d.Factor, NULLIF(RTRIM(d.Unidad), ''), d.Articulo, NULLIF(RTRIM(d.Subcuenta), ''), ISNULL(d.Costo, 0.0), ISNULL(d.Costo, 0.0), NULLIF(RTRIM(d.DescuentoTipo), ''), ISNULL(d.DescuentoLinea, 0.0), ISNULL(d.Impuesto1, 0.0), ISNULL(d.Impuesto2, 0.0), ISNULL(d.Impuesto3, 0.0), NULLIF(RTRIM(d.Aplica), ''), NULLIF(RTRIM(d.AplicaID), ''), d.Almacen, d.ServicioArticulo, d.ServicioSerie, NULLIF(RTRIM(UPPER(a.Tipo)), ''), a.SerieLoteInfo, NULLIF(RTRIM(UPPER(a.TipoOpcion)), ''), ISNULL(a.Peso, 0.0), ISNULL(a.Volumen, 0.0), a.Unidad, ISNULL(d.Retencion1, 0.0), ISNULL(d.Retencion2, 0.0), ISNULL(d.Retencion3, 0.0), a.LotesFijos, a.Actividades, a.CostoIdentificado, d.CostoUEPS, d.CostoPEPS, d.UltimoCosto, d.PrecioLista, NULLIF(RTRIM(d.Posicion), ''), a.DepartamentoDetallista, a.Estatus, a.Situacion, a.Impuesto1Excento, a.Excento2, a.Excento3
FROM CompraD d, Art a
WHERE d.ID = @ID
AND d.Articulo = a.Articulo
OPEN crCompraDetalle
FETCH NEXT FROM crCompraDetalle INTO @Renglon, @RenglonSub, @RenglonID, @RenglonTipo, @CantidadOriginal, @CantidadInventario, @CantidadReservada, @CantidadOrdenada, @CantidadPendiente, @CantidadA, @Factor, @MovUnidad, @Articulo, @Subcuenta, @Costo, @Precio, @DescuentoTipo, @DescuentoLinea, @Impuesto1, @Impuesto2, @Impuesto3, @AplicaMov, @AplicaMovID, @AlmacenRenglon, @ServicioArticulo, @ServicioSerie, @ArtTipo, @ArtSerieLoteInfo, @ArtTipoOpcion, @Peso, @Volumen, @ArtUnidad, @MovRetencion1, @MovRetencion2, @MovRetencion3, @ArtLotesFijos, @ArtActividades, @ArtCostoIdentificado, @ArtCostoUEPS, @ArtCostoPEPS, @ArtUltimoCosto, @ArtPrecioLista, @Posicion, @ArtDepartamentoDetallista, @ArtEstatus, @ArtSituacion, @ArtExcento1, @ArtExcento2, @ArtExcento3
IF @@ERROR <> 0 SELECT @Ok = 1
END ELSE
IF @Modulo = 'INV'
BEGIN
DECLARE crInvDetalle CURSOR
FOR SELECT d.Renglon, d.RenglonSub, d.RenglonID, d.RenglonTipo, ISNULL(d.Cantidad, 0.0), ISNULL(d.CantidadInventario, 0.0), ISNULL(d.CantidadReservada, 0.0), ISNULL(d.CantidadOrdenada, 0.0), ISNULL(d.CantidadPendiente, 0.0), ISNULL(d.CantidadA, 0.0), d.Factor, NULLIF(RTRIM(d.Unidad), ''), d.Articulo, NULLIF(RTRIM(d.Subcuenta), ''), ISNULL(d.Costo, 0.0), CONVERT(money, NULL), '$', CONVERT(money, NULL), CONVERT(float, NULL), CONVERT(float, NULL), CONVERT(money, NULL), NULLIF(RTRIM(d.Aplica), ''), NULLIF(RTRIM(d.AplicaID), ''), d.Almacen, d.ProdSerieLote, NULLIF(RTRIM(UPPER(a.Tipo)), ''), a.SerieLoteInfo, NULLIF(RTRIM(UPPER(a.TipoOpcion)), ''), ISNULL(a.Peso, 0.0), ISNULL(a.Volumen, 0.0), a.Unidad, d.UltimoReservadoCantidad, d.UltimoReservadoFecha, d.Tipo, d.Producto, d.SubProducto, a.LotesFijos, a.Actividades, a.CostoIdentificado, d.CostoUEPS, d.CostoPEPS, d.UltimoCosto, d.PrecioLista, NULLIF(RTRIM(d.Posicion), ''), a.DepartamentoDetallista, a.Estatus, a.Situacion, a.Impuesto1Excento, a.Excento2, a.Excento3
FROM InvD d, Art a
WHERE d.ID = @ID
AND d.Articulo = a.Articulo
OPEN crInvDetalle
FETCH NEXT FROM crInvDetalle INTO @Renglon, @RenglonSub, @RenglonID, @RenglonTipo, @CantidadOriginal, @CantidadInventario, @CantidadReservada, @CantidadOrdenada, @CantidadPendiente, @CantidadA, @Factor, @MovUnidad, @Articulo, @Subcuenta, @Costo, @Precio, @DescuentoTipo, @DescuentoLinea, @Impuesto1, @Impuesto2, @Impuesto3, @AplicaMov, @AplicaMovID, @AlmacenRenglon, @ProdSerieLote, @ArtTipo, @ArtSerieLoteInfo, @ArtTipoOpcion, @Peso, @Volumen, @ArtUnidad, @UltReservadoCantidad, @UltReservadoFecha, @DetalleTipo, @Producto, @SubProducto, @ArtLotesFijos, @ArtActividades, @ArtCostoIdentificado, @ArtCostoUEPS, @ArtCostoPEPS, @ArtUltimoCosto, @ArtPrecioLista, @Posicion, @ArtDepartamentoDetallista, @ArtEstatus, @ArtSituacion, @ArtExcento1, @ArtExcento2, @ArtExcento3
IF @@ERROR <> 0 SELECT @Ok = 1
END ELSE
IF @Modulo = 'PROD'
BEGIN
DECLARE crProdDetalle CURSOR
FOR SELECT d.Renglon, d.RenglonSub, d.RenglonID, d.RenglonTipo, ISNULL(d.Cantidad, 0.0), ISNULL(d.CantidadInventario, 0.0), ISNULL(d.CantidadReservada, 0.0), ISNULL(d.CantidadOrdenada, 0.0), ISNULL(d.CantidadPendiente, 0.0), ISNULL(d.CantidadA, 0.0), d.Factor, NULLIF(RTRIM(d.Unidad), ''), d.Articulo, NULLIF(RTRIM(d.Subcuenta), ''), ISNULL(d.Costo, 0.0), CONVERT(money, NULL), '$', CONVERT(money, NULL), CONVERT(float, NULL), CONVERT(float, NULL), CONVERT(money, NULL), NULLIF(RTRIM(d.Aplica), ''), NULLIF(RTRIM(d.AplicaID), ''), d.Almacen, NULLIF(RTRIM(d.ProdSerieLote), ''), NULLIF(RTRIM(UPPER(a.Tipo)), ''), a.SerieLoteInfo, NULLIF(RTRIM(UPPER(a.TipoOpcion)), ''), ISNULL(a.Peso, 0.0), ISNULL(a.Volumen, 0.0), a.Unidad, d.UltimoReservadoCantidad, d.UltimoReservadoFecha, d.Tipo, d.Merma, d.Desperdicio, d.Ruta, d.Orden, d.Centro, a.LotesFijos, a.Actividades, a.CostoIdentificado, d.CostoUEPS, d.CostoPEPS, d.UltimoCosto, d.PrecioLista, NULLIF(RTRIM(d.Posicion), ''), a.DepartamentoDetallista, a.Estatus, a.Situacion, a.Impuesto1Excento, a.Excento2, a.Excento3
FROM ProdD d, Art a
WHERE d.ID = @ID
AND d.Articulo = a.Articulo
OPEN crProdDetalle
FETCH NEXT FROM crProdDetalle INTO @Renglon, @RenglonSub, @RenglonID, @RenglonTipo, @CantidadOriginal, @CantidadInventario, @CantidadReservada, @CantidadOrdenada, @CantidadPendiente, @CantidadA, @Factor, @MovUnidad, @Articulo, @Subcuenta, @Costo, @Precio, @DescuentoTipo, @DescuentoLinea, @Impuesto1, @Impuesto2, @Impuesto3, @AplicaMov, @AplicaMovID, @AlmacenRenglon, @ProdSerieLote, @ArtTipo, @ArtSerieLoteInfo, @ArtTipoOpcion, @Peso, @Volumen, @ArtUnidad, @UltReservadoCantidad, @UltReservadoFecha, @DetalleTipo, @Merma, @Desperdicio, @Ruta, @Orden, @Centro, @ArtLotesFijos, @ArtActividades, @ArtCostoIdentificado, @ArtCostoUEPS, @ArtCostoPEPS, @ArtUltimoCosto, @ArtPrecioLista, @Posicion, @ArtDepartamentoDetallista, @ArtEstatus, @ArtSituacion, @ArtExcento1, @ArtExcento2, @ArtExcento3
IF @@ERROR <> 0 SELECT @Ok = 1
END
WHILE @@FETCH_STATUS <> -1 AND @Ok IS NULL
BEGIN
EXEC xpInvAfectarDetalleAntes @ID, @Accion, @Base, @Empresa, @Usuario, @Modulo, @Mov, @MovID, @MovTipo,
@MovMoneda, @MovTipoCambio, @Estatus, @EstatusNuevo, @FechaEmision, @FechaRegistro, @FechaAfectacion, @Conexion, @SincroFinal, @Sucursal,
@Renglon, @RenglonSub, @Articulo, @Cantidad, @Importe, @ImporteNeto, @Impuestos, @ImpuestosNetos,
@Ok OUTPUT, @OkRef OUTPUT
SELECT @CantidadPendienteA = @CantidadPendiente, @CantidadOrdenadaA  = @CantidadOrdenada
IF @CfgVentaMultiAgente = 1 AND @Modulo = 'VTAS' SELECT @Agente = @AgenteRenglon
IF @CfgMultiUnidades = 0
BEGIN
IF @Modulo = 'COMS'
SELECT @ArtUnidad = UnidadCompra FROM Art WITH (NOLOCK) WHERE Articulo = @Articulo
SELECT @MovUnidad = @ArtUnidad
END
IF @Agente <> @UltAgente AND @UltAgente IS NOT NULL AND @ComisionAcum <> 0.0 AND @Ok IS NULL AND
(((@MovTipo IN ('VTAS.F','VTAS.FAR', 'VTAS.FB', 'VTAS.D', 'VTAS.DF', 'VTAS.B') AND (@Estatus = 'SINAFECTAR' OR @EstatusNuevo = 'CANCELADO')) AND (@CfgVentaComisionesCobradas = 0 OR @CobroIntegrado = 1 OR @CobrarPedido = 1)) OR @MovTipo IN ('VTAS.FM', 'VTAS.N', 'VTAS.NO', 'VTAS.NR'))
BEGIN
EXEC spGenerarCx @Sucursal, @SucursalOrigen, @SucursalDestino, @Accion, 'AGENT', @Empresa, @Modulo, @ID, @Mov, @MovID, @MovTipo, @MovMoneda, @MovTipoCambio,
@FechaAfectacion, @Concepto, @Proyecto, @Usuario,  @Autorizacion, @Referencia, @DocFuente, @Observaciones,
@FechaRegistro, @Ejercicio, @Periodo,
NULL, NULL, @ClienteProv, NULL, @UltAgente, NULL, NULL, NULL,
@ComisionImporteNeto, NULL, NULL, @ComisionAcum,
NULL, NULL, NULL, NULL, NULL, NULL,
@CxModulo, @CxMov, @CxMovID, @Ok OUTPUT, @OkRef  OUTPUT
SELECT @ComisionAcum = 0.0, @ComisionImporteNeto = 0.0
END
SELECT @UltAgente = @Agente
IF @Renglon = @ExplotandoRenglon SELECT @ExplotandoSubCuenta = 1 ELSE SELECT @ExplotandoSubCuenta = 0
SELECT @Almacen = @AlmacenOriginal, @AlmacenDestino = @AlmacenDestinoOriginal
IF @AfectarAlmacenRenglon = 1 SELECT @Almacen = NULLIF(RTRIM(@AlmacenRenglon), '')
IF @AlmacenEspecifico IS NOT NULL SELECT @Almacen = @AlmacenEspecifico
IF @VoltearAlmacen = 1 SELECT @AlmacenTemp = @Almacen, @Almacen = @AlmacenDestino, @AlmacenDestino = @AlmacenTemp
IF @EsTransferencia = 0 /*AND @MovTipo NOT IN ('INV.SI', 'INV.DTI') */SELECT @AlmacenDestino = NULL
IF @Almacen        IS NOT NULL SELECT @AlmacenTipo        = UPPER(Tipo) FROM Alm WHERE Almacen = @AlmacenRenglon
IF @AlmacenDestino IS NOT NULL SELECT @AlmacenDestinoTipo = UPPER(Tipo) FROM Alm WHERE Almacen = @AlmacenDestino
SELECT @SucursalAlmacen = Sucursal FROM Alm WITH (NOLOCK) WHERE Almacen = @Almacen
IF @AlmacenDestino IS NOT NULL
SELECT @SucursalAlmacenDestino = Sucursal FROM Alm WITH (NOLOCK) WHERE Almacen = @AlmacenDestino
SELECT @AplicaMovTipo = NULL, @IDAplica = NULL
IF @AplicaMov <> NULL
BEGIN
SELECT @AplicaMovTipo = Clave FROM MovTipo WITH (NOLOCK) WHERE Modulo = @Modulo AND Mov = @AplicaMov
IF @Modulo = 'VTAS' SELECT @IDAplica = ID FROM Venta  WITH (NOLOCK) WHERE Empresa = @Empresa AND Mov = @AplicaMov AND MovID = @AplicaMovID AND Estatus NOT IN ('SINAFECTAR', 'BORRADOR', 'CONFIRMAR', 'CANCELADO') ELSE
IF @Modulo = 'COMS' SELECT @IDAplica = ID FROM Compra WITH (NOLOCK) WHERE Empresa = @Empresa AND Mov = @AplicaMov AND MovID = @AplicaMovID AND Estatus NOT IN ('SINAFECTAR', 'BORRADOR', 'CONFIRMAR', 'CANCELADO') ELSE
IF @Modulo = 'PROD' SELECT @IDAplica = ID FROM Prod   WITH (NOLOCK) WHERE Empresa = @Empresa AND Mov = @AplicaMov AND MovID = @AplicaMovID AND Estatus NOT IN ('SINAFECTAR', 'BORRADOR', 'CONFIRMAR', 'CANCELADO') ELSE
IF @Modulo = 'INV'  SELECT @IDAplica = ID FROM Inv    WITH (NOLOCK) WHERE Empresa = @Empresa AND Mov = @AplicaMov AND MovID = @AplicaMovID AND Estatus NOT IN ('SINAFECTAR', 'BORRADOR', 'CONFIRMAR', 'CANCELADO')
IF @MovTipo = 'INV.EI' AND @IDAplica IS NOT NULL
BEGIN
SELECT @IDSalidaTraspaso = o.ID
FROM Inv i WITH (NOLOCK)
JOIN Inv o WITH (NOLOCK) ON o.Empresa = i.Empresa AND o.Mov = i.Origen AND o.MovID = i.OrigenID AND o.Estatus IN ('PENDIENTE', 'CONCLUIDO')
WHERE i.ID = @IDAplica
END
END
EXEC spInvInitRenglon @Empresa, 0, @CfgMultiUnidades, @CfgMultiUnidadesNivel, @CfgCompraFactorDinamico, @CfgInvFactorDinamico, @CfgProdFactorDinamico, @CfgVentaFactorDinamico, 0,
0, 0, @Accion, @Base, @Modulo, @ID, @Renglon, @RenglonSub, @Estatus, @EstatusNuevo, @MovTipo, @FacturarVtasMostrador, @EsTransferencia, @AfectarConsignacion, @ExplotandoSubCuenta, @AlmacenTipo, @AlmacenDestinoTipo,
@Articulo, @MovUnidad, @ArtUnidad, @ArtTipo, @RenglonTipo,
@AplicaMovTipo, @CantidadOriginal, @CantidadInventario, @CantidadPendiente, @CantidadA, @DetalleTipo,
@Cantidad OUTPUT, @CantidadCalcularImporte OUTPUT, @CantidadReservada OUTPUT, @CantidadOrdenada OUTPUT, @EsEntrada OUTPUT, @EsSalida OUTPUT, @SubCuenta OUTPUT,
@AfectarPiezas OUTPUT, @AfectarCostos OUTPUT, @AfectarUnidades OUTPUT, @Factor OUTPUT,
@Ok OUTPUT, @OkRef OUTPUT
SELECT @Importe		 	= 0.0,
@ImporteNeto	 	= 0.0,
@Impuestos 		= 0.0,
@ImpuestosNetos		= 0.0,
@Impuesto1Neto 		= 0.0,
@Impuesto2Neto 		= 0.0,
@Impuesto3Neto 		= 0.0,
@DescuentoLineaImporte	= 0.0,
@DescuentoGlobalImporte 	= 0.0,
@SobrePrecioImporte 	= 0.0,
@ImporteComision		= 0.0,
@CostoInvTotal	        = 0.0
IF @@FETCH_STATUS <> -2 AND @Cantidad <> 0.0 AND @Ok IS NULL
BEGIN
SELECT @CostosImpuestoIncluido = 0
IF @CfgCompraCostosImpuestoIncluido = 1 AND @AlmacenTipo <> 'ACTIVOS FIJOS'
SELECT @CostosImpuestoIncluido = 1
SELECT @ArtMoneda = MonedaCosto, @SeriesLotesAutoOrden = ISNULL(NULLIF(NULLIF(RTRIM(UPPER(SeriesLotesAutoOrden)), ''), '(EMPRESA)'), @CfgSeriesLotesAutoOrden)
FROM Art WITH (NOLOCK)
WHERE Articulo = @Articulo
IF @Generar = 0 OR @GenerarAfectado = 1
BEGIN
IF @Modulo = 'COMS' AND @MovTipo IN ('COMS.OG', 'COMS.IG', 'COMS.DG')
BEGIN
SELECT @Costo = 0.0, @Precio = 0.0
UPDATE CompraD WITH (ROWLOCK) SET Costo = NULL WHERE CURRENT OF crCompraDetalle
END
SELECT @AfectarSerieLote = 0
IF @MovTipo IN ('VTAS.F','VTAS.FAR', 'VTAS.FC', 'VTAS.FG', 'VTAS.FX') AND @AplicaMovTipo = 'VTAS.R' SELECT @FacturandoRemision = 1 ELSE SELECT @FacturandoRemision = 0
IF @ArtTipo IN ('SERIE', 'LOTE', 'VIN', 'PARTIDA') AND @CfgSeriesLotesMayoreo = 1 AND (@EsEntrada = 1 OR @EsSalida = 1 OR @EsTransferencia = 1 OR @MovTipo IN ('COMS.B', 'COMS.CA', 'COMS.GX')) AND @FacturarVtasMostrador = 0 AND @FacturandoRemision = 0
BEGIN
SELECT @AfectarSerieLote = 1 
IF @ArtSerieLoteInfo = 0
EXEC spSeriesLotesSurtidoAuto @Sucursal, @Empresa, @Modulo, @EsSalida, @EsTransferencia,
@ID,  @RenglonID, @Almacen, @Articulo, @SubCuenta, @Cantidad, @Factor,
@AlmacenTipo, @SeriesLotesAutoOrden,
@Ok OUTPUT, @OkRef OUTPUT
END
SELECT @PrecioN = @Precio, @Impuesto1N = @Impuesto1, @Impuesto2N = @Impuesto2, @Impuesto3N = @Impuesto3
IF @Modulo IN ('VTAS', 'COMS') AND @Accion <> 'CANCELAR'
BEGIN
EXEC xpMovDPrecioImpuestos @Empresa, @Modulo, @ID, @Mov, @MovID, @MovTipo, @Renglon, @RenglonSub, @RenglonID, @ArtTipo, @Articulo, @SubCuenta, @Almacen, @CantidadOriginal, @PrecioN OUTPUT, @Impuesto1N OUTPUT, @Impuesto2N OUTPUT, @Impuesto3N OUTPUT, @Ok OUTPUT, @OkRef OUTPUT
IF @MovImpuesto = 1
BEGIN
IF @ArtTipo = 'LOTE' AND @ArtLotesFijos = 1 /*AR*/ AND @NoValidarDisponible = 0
EXEC spLotesFijos @Empresa, @Modulo, @ID, @Mov, @MovID, @MovTipo, @Renglon, @RenglonSub, @RenglonID, @ArtTipo, @Articulo, @SubCuenta, @Almacen, @ZonaImpuesto, @CantidadOriginal, @Factor,
@CfgImpInc, @EsEntrada, @Precio, @DescuentoTipo, @DescuentoLinea, @DescuentoGlobal, @SobrePrecio,
@Impuesto1N OUTPUT, @Impuesto2N OUTPUT, @Impuesto3N OUTPUT, @Ok OUTPUT, @OkRef OUTPUT,
@CfgPrecioMoneda = @CfgPrecioMoneda, @MovTipoCambio = @MovTipoCambio, @PrecioTipoCambio = @PrecioTipoCambio
END
END
IF @PrecioN <> @Precio OR @Impuesto1N <> @Impuesto1 OR @Impuesto2 <> @Impuesto2N OR @Impuesto3 <> @Impuesto3N
BEGIN
SELECT @Precio = @PrecioN, @Impuesto1 = @Impuesto1N, @Impuesto2 = @Impuesto2N, @Impuesto3 = @Impuesto3N
IF @Modulo = 'VTAS' UPDATE VentaD WITH (ROWLOCK) SET Precio = @Precio, Impuesto1 = @Impuesto1, Impuesto2 = @Impuesto2, Impuesto3 = @Impuesto3 WHERE CURRENT OF crVentaDetalle ELSE
IF @Modulo = 'COMS'
BEGIN
SELECT @Costo = @Precio
UPDATE CompraD WITH (ROWLOCK) SET Costo = @Costo, Impuesto1 = @Impuesto1, Impuesto2 = @Impuesto2, Impuesto3 = @Impuesto3 WHERE CURRENT OF crCompraDetalle
END
END
IF @ArtActividades = 1
BEGIN
IF @MovTipo IN ('VTAS.P', 'VTAS.S')
EXEC spSugerirArtActividad @Empresa, @Sucursal, @ID, @Renglon, @RenglonSub, @Articulo, @CantidadOriginal, @Agente
IF @MovTipo IN ('VTAS.F','VTAS.FAR', 'VTAS.FC', 'VTAS.FG', 'VTAS.FX','VTAS.FB')
BEGIN
UPDATE VentaDAgente WITH (ROWLOCK)
SET CostoActividad = a.Costo
FROM VentaDAgente d, Actividad a WITH (NOLOCK)
WHERE d.ID = @ID AND d.Renglon = @Renglon AND d.RenglonSub = @RenglonSub AND d.Actividad = a.Actividad
IF @CfgCosteoActividades = 'TIEMPO ESTANDAR'
SELECT @CostoActividad = SUM(CostoActividad*CantidadEstandar) FROM VentaDAgente WITH (NOLOCK) WHERE ID = @ID AND Renglon = @Renglon AND RenglonSub = @RenglonSub
ELSE
SELECT @CostoActividad = SUM(CostoActividad*(CONVERT(float, Minutos)/60)) FROM VentaDAgente WITH (NOLOCK) WHERE ID = @ID AND Renglon = @Renglon AND RenglonSub = @RenglonSub
UPDATE VentaD WITH (ROWLOCK) SET CostoActividad = @CostoActividad/NULLIF(@MovTipoCambio, 0)/NULLIF(@CantidadOriginal, 0) WHERE CURRENT OF crVentaDetalle
END
END
IF @Modulo IN ('VTAS', 'COMS')
BEGIN
EXEC spCalculaImporte @Accion, @Modulo, @CfgImpInc, @MovTipo, @EsEntrada, @CantidadCalcularImporte, @Precio, @DescuentoTipo, @DescuentoLinea, @DescuentoGlobal, @SobrePrecio, @Impuesto1, @Impuesto2, @Impuesto3,
@Importe OUTPUT, @ImporteNeto OUTPUT, @DescuentoLineaImporte OUTPUT, @DescuentoGlobalImporte OUTPUT, @SobrePrecioImporte OUTPUT,
@Impuestos OUTPUT, @ImpuestosNetos OUTPUT, @Impuesto1Neto OUTPUT, @Impuesto2Neto OUTPUT, @Impuesto3Neto OUTPUT,
@Articulo = @Articulo, @CantidadObsequio = @CantidadObsequio, @CfgPrecioMoneda = @CfgPrecioMoneda, @MovTipoCambio = @MovTipoCambio, @PrecioTipoCambio = @PrecioTipoCambio
IF @MovImpuesto = 1 AND NOT (@ArtTipo = 'LOTE' AND @ArtLotesFijos = 1)
BEGIN
IF @CantidadOriginal<0.0 SELECT @MovImpuestoFactor = -1.0 ELSE SELECT @MovImpuestoFactor = 1.0
INSERT #MovImpuesto (Renglon,  RenglonSub,  Retencion1,     Retencion2,     Retencion3,     Excento1,     Excento2,     Excento3,     Impuesto1,  Impuesto2,  Impuesto3,  Importe1,                          Importe2,                          Importe3,                          SubTotal)
SELECT @Renglon, @RenglonSub, @MovRetencion1, @MovRetencion2, @MovRetencion3, @ArtExcento1, @ArtExcento2, @ArtExcento3, @Impuesto1, @Impuesto2, @Impuesto3, @Impuesto1Neto*@MovImpuestoFactor, @Impuesto2Neto*@MovImpuestoFactor, @Impuesto3Neto*@MovImpuestoFactor, @ImporteNeto*@MovImpuestoFactor
END
IF @Modulo = 'COMS'
BEGIN
SELECT @Costo = @ImporteNeto / @Cantidad
END
IF @@ERROR <> 0 SELECT @Ok = 1
END
SELECT @AfectarCantidad = NULL
IF @AfectarUnidades = 1 AND @Ok IS NULL
BEGIN
EXEC spInvAfectarUnidades @SucursalAlmacen, @Accion, @Base, @Empresa, @Usuario, @Modulo, @ID, @Mov, @MovID, @MovTipo, @MovMoneda, @MovTipoCambio, @Estatus,
@Articulo, @ArtMoneda, @ArtTipoCambio, @ArtTipo, @SubCuenta, @Almacen, @AlmacenTipo, @AlmacenDestino, @AlmacenDestinoTipo, @EsEntrada, @CantidadOriginal, @Cantidad, @Factor,
@Renglon, @RenglonSub, @RenglonID, @RenglonTipo,
@FechaRegistro, @FechaAfectacion, @Ejercicio, @Periodo, @AplicaMov, @AplicaMovID, @OrigenTipo,
@AfectarCostos, @AfectarPiezas, @AfectarVtasMostrador, @FacturarVtasMostrador, @AfectarConsignacion, @EsTransferencia, @CfgSeriesLotesMayoreo, /*@CfgAutoConsig, */@CfgFormaCosteo, @CfgTipoCosteo,
@CantidadReservada, @ReservadoParcial OUTPUT, @UltRenglonIDJuego OUTPUT, @CantidadJuego OUTPUT, @CantidadMinimaJuego OUTPUT,
@UltReservadoCantidad OUTPUT, @UltReservadoFecha OUTPUT, @AfectarCantidad OUTPUT, @AfectarAlmacen OUTPUT, @AfectarAlmacenDestino OUTPUT,
@Ok OUTPUT, @OkRef OUTPUT
END
ELSE
SELECT @ReservadoParcial = 0.0
IF @FacturandoRemision = 1 AND @Accion <> 'CANCELAR' AND @ArtTipo NOT IN ('JUEGO', 'SERVICIO')
BEGIN
SELECT @Costo = ISNULL(SUM(Cantidad*Costo)/NULLIF(SUM(Cantidad), 0.0), 0.0)
FROM VentaD WITH (NOLOCK)
WHERE ID = @IDAplica AND Articulo = @Articulo AND ISNULL(SubCuenta,'') = ISNULL(@SubCuenta,'')
IF @Costo = 0.0
SELECT @AfectarCostos = 1
ELSE
UPDATE VentaD WITH (ROWLOCK) SET Costo = @Costo WHERE CURRENT OF crVentaDetalle
END
/** JH 25.10.2006 **/
IF @Modulo = 'VTAS' AND @AlmacenTipo = 'GARANTIAS' AND @Accion <> 'CANCELAR'
BEGIN
UPDATE VentaD WITH (ROWLOCK) SET Costo = NULL WHERE CURRENT OF crVentaDetalle
SELECT @Costo = 0.0
END
/** JH 25.10.2006 **/
IF @EsSalida = 1 AND @Modulo IN ('VTAS', 'INV') AND @EsTransferencia = 0 AND @AlmacenTipo <> 'ACTIVOS FIJOS' AND @Accion = 'AFECTAR' AND @FacturarVtasMostrador = 0 /*AR 11/09/07 */
EXEC spChecarConsignacion @Empresa, @SucursalAlmacen, @Usuario, @Modulo, @Mov, @MovID,
@FechaAfectacion, @Ejercicio, @Periodo, @ArtMoneda, @Almacen, @Articulo, @SubCuenta, @AfectarCantidad,
@Ok OUTPUT, @OkRef OUTPUT
IF @AfectarCostos = 1 OR @EsTransferencia = 1 OR @MovTipo IN ('COMS.CC', 'COMS.DC') AND @Ok IS NULL
BEGIN
IF @MovTipo IN ('COMS.EG', 'COMS.EI')
SELECT @CostoInv = CostoInv FROM CompraD WITH (NOLOCK) WHERE ID = @ID AND Renglon = @Renglon AND RenglonSub = @RenglonSub
ELSE IF @MovTipo IN ('INV.EI')
SELECT @CostoInv = CostoInv FROM InvD WITH (NOLOCK) WHERE ID = @ID AND Renglon = @Renglon AND RenglonSub = @RenglonSub
ELSE
SELECT @CostoInv = @Costo
IF @CostosImpuestoIncluido = 1
SELECT @CostoInv = @CostoInv + (@ImpuestosNetos / @Cantidad)
EXEC spArtCosto @SucursalAlmacen, @Accion, @Empresa, @Modulo, @AfectarCostos,
@EsEntrada, @EsSalida, @EsTransferencia, @AfectarSerieLote, @CfgFormaCosteo, @CfgTipoCosteo,
@ArtTipo, @Articulo, @SubCuenta, @Cantidad, @MovUnidad, @Factor, @CostoInv, @Costo,
@Mov, @MovID, @MovTipo, @AplicaMovTipo, @FechaAfectacion, @MovMoneda, @MovTipoCambio,
@ID, @RenglonID, @Almacen, @AlmacenTipo, 0, @CfgCosteoSeries, @CfgCosteoLotes, @CfgCosteoMultipleSimultaneo, @ArtCostoIdentificado,
@ArtCosto OUTPUT, @ArtAjusteCosteo OUTPUT, @ArtCostoUEPS OUTPUT, @ArtCostoPEPS OUTPUT, @ArtUltimoCosto OUTPUT, @ArtPrecioLista OUTPUT,
@ArtMoneda OUTPUT, @ArtFactor OUTPUT, @ArtTipoCambio OUTPUT, @Ok OUTPUT
IF @CfgCosteoNivelSubCuenta = 1 AND @ArtTipoOpcion <> 'NO'
EXEC spArtCosto @SucursalAlmacen, @Accion, @Empresa, @Modulo, @AfectarCostos,
@EsEntrada, @EsSalida, @EsTransferencia, @AfectarSerieLote, @CfgFormaCosteo, @CfgTipoCosteo,
@ArtTipo, @Articulo, @SubCuenta, @Cantidad, @MovUnidad, @Factor, @CostoInv, @Costo,
@Mov, @MovID, @MovTipo, @AplicaMovTipo, @FechaAfectacion, @MovMoneda, @MovTipoCambio,
@ID, @RenglonID, @Almacen, @AlmacenTipo, 1, @CfgCosteoSeries, @CfgCosteoLotes, @CfgCosteoMultipleSimultaneo, @ArtCostoIdentificado,
@ArtCosto OUTPUT, @ArtAjusteCosteo OUTPUT, @ArtCostoUEPS OUTPUT, @ArtCostoPEPS OUTPUT, @ArtUltimoCosto OUTPUT, @ArtPrecioLista OUTPUT,
@ArtMoneda OUTPUT, @ArtFactor OUTPUT, @ArtTipoCambio OUTPUT, @Ok OUTPUT
SELECT @ModificarCosto = @ArtCosto * @ArtFactor, @ModificarPrecio = @Precio
EXEC xpMovModificarCostoPrecio @Accion, @Empresa, @Modulo, @ID, @Mov, @MovID, @MovTipo, @AfectarCostos, @EsEntrada, @EsSalida, @EsTransferencia, @Renglon, @RenglonSub, @Articulo, @SubCuenta, @MovUnidad, @ArtCosto, @ArtFactor, @ModificarCosto OUTPUT, @ModificarPrecio OUTPUT, @Ok OUTPUT, @OkRef OUTPUT
IF @ModificarCosto <> @ArtCosto * @ArtFactor OR @ModificarPrecio <> @Precio
BEGIN
SELECT @ArtCosto = @ModificarCosto / @ArtFactor, @Precio = @ModificarPrecio
IF @Modulo = 'VTAS' UPDATE VentaD WITH (ROWLOCK) SET Precio = @Precio WHERE CURRENT OF crVentaDetalle ELSE
IF @Modulo = 'INV'  UPDATE InvD WITH (ROWLOCK)  SET Precio = @Precio WHERE CURRENT OF crInvDetalle
EXEC spCalculaImporte @Accion, @Modulo, @CfgImpInc, @MovTipo, @EsEntrada, @CantidadCalcularImporte, @Precio, @DescuentoTipo, @DescuentoLinea, @DescuentoGlobal, @SobrePrecio, @Impuesto1, @Impuesto2, @Impuesto3,
@Importe OUTPUT, @ImporteNeto OUTPUT, @DescuentoLineaImporte OUTPUT, @DescuentoGlobalImporte OUTPUT, @SobrePrecioImporte OUTPUT,
@Impuestos OUTPUT, @ImpuestosNetos OUTPUT, @Impuesto1Neto OUTPUT, @Impuesto2Neto OUTPUT, @Impuesto3Neto OUTPUT,
@Articulo = @Articulo, @CantidadObsequio = @CantidadObsequio, @CfgPrecioMoneda = @CfgPrecioMoneda, @MovTipoCambio = @MovTipoCambio, @PrecioTipoCambio = @PrecioTipoCambio
IF @MovImpuesto = 1 AND NOT (@ArtTipo = 'LOTE' AND @ArtLotesFijos = 1)
BEGIN
DELETE #MovImpuesto WHERE Renglon = @Renglon AND RenglonSub = @RenglonSub
IF @CantidadOriginal<0.0 SELECT @MovImpuestoFactor = -1.0 ELSE SELECT @MovImpuestoFactor = 1.0
INSERT #MovImpuesto (Renglon,  RenglonSub,  Retencion1,     Retencion2,     Retencion3,     Excento1,     Excento2,     Excento3,     Impuesto1,  Impuesto2,  Impuesto3,  Importe1,                          Importe2,                          Importe3,                          SubTotal)
SELECT @Renglon, @RenglonSub, @MovRetencion1, @MovRetencion2, @MovRetencion3, @ArtExcento1, @ArtExcento2, @ArtExcento3, @Impuesto1, @Impuesto2, @Impuesto3, @Impuesto1Neto*@MovImpuestoFactor, @Impuesto2Neto*@MovImpuestoFactor, @Impuesto3Neto*@MovImpuestoFactor, @ImporteNeto*@MovImpuestoFactor
END
END
SELECT @ArtCostoInv = @ArtCosto  
SELECT @CostoInvTotal = @ArtCosto * @Cantidad
SELECT @ArtCantidad = ISNULL(@Cantidad, 0.0)*ISNULL(@Factor, 1.0)
IF @MovTipo IN ('COMS.EG', 'COMS.EI', 'INV.EI') SELECT @ArtCosto = @Costo / @ArtFactor
/*IF @Accion <> 'CANCELAR'
BEGIN*/
SELECT @PrecioSinImpuestos = dbo.fnPrecioSinImpuestos (@Empresa, @Articulo, @ArtPrecioLista)
IF (@EsSalida = 1 OR @EsTransferencia = 1) AND @Accion <> 'CANCELAR' AND @Ok IS NULL
BEGIN
IF @Modulo = 'VTAS' UPDATE VentaD  WITH (ROwLOCK) SET Unidad = @MovUnidad, Costo = @ArtCosto * @ArtFactor, AjusteCosteo = @ArtAjusteCosteo * @ArtFactor, CostoUEPS = @ArtCostoUEPS * @ArtFactor, CostoPEPS = @ArtCostoPEPS * @ArtFactor, UltimoCosto = @ArtUltimoCosto * @ArtFactor, PrecioLista = @PrecioSinImpuestos, DepartamentoDetallista = @ArtDepartamentoDetallista WHERE CURRENT OF crVentaDetalle  ELSE
IF @Modulo = 'INV'  UPDATE InvD    WITH (ROwLOCK) SET Unidad = @MovUnidad, Costo = @ArtCosto * @ArtFactor, AjusteCosteo = @ArtAjusteCosteo * @ArtFactor, CostoUEPS = @ArtCostoUEPS * @ArtFactor, CostoPEPS = @ArtCostoPEPS * @ArtFactor, UltimoCosto = @ArtUltimoCosto * @ArtFactor, PrecioLista = @PrecioSinImpuestos, DepartamentoDetallista = @ArtDepartamentoDetallista WHERE CURRENT OF crInvDetalle    ELSE
IF @Modulo = 'PROD' UPDATE ProdD   WITH (ROwLOCK) SET Unidad = @MovUnidad, Costo = @ArtCosto * @ArtFactor, AjusteCosteo = @ArtAjusteCosteo * @ArtFactor, CostoUEPS = @ArtCostoUEPS * @ArtFactor, CostoPEPS = @ArtCostoPEPS * @ArtFactor, UltimoCosto = @ArtUltimoCosto * @ArtFactor, PrecioLista = @PrecioSinImpuestos, DepartamentoDetallista = @ArtDepartamentoDetallista WHERE CURRENT OF crProdDetalle   ELSE
IF @Modulo = 'COMS' UPDATE CompraD WITH (ROwLOCK) SET Unidad = @MovUnidad, /*Costo = @ArtCosto * @ArtFactor,*/ AjusteCosteo = @ArtAjusteCosteo * @ArtFactor, CostoUEPS = @ArtCostoUEPS * @ArtFactor, CostoPEPS = @ArtCostoPEPS * @ArtFactor, UltimoCosto = @ArtUltimoCosto * @ArtFactor, PrecioLista = @PrecioSinImpuestos, DepartamentoDetallista = @ArtDepartamentoDetallista WHERE CURRENT OF crCompraDetalle
IF @@ERROR <> 0 SELECT @Ok = 1
END ELSE
BEGIN
SELECT @AjustePrecioLista = NULL
IF @MovTipo = 'INV.EI' AND @IDSalidaTraspaso IS NOT NULL
SELECT @AjustePrecioLista = @PrecioSinImpuestos - (SELECT MIN(PrecioLista) FROM InvD WITH (NOLOCK) WHERE ID = @IDSalidaTraspaso AND Articulo = @Articulo AND ISNULL(SubCuenta, '') = ISNULL(@SubCuenta, '') AND ISNULL(Unidad, '') = ISNULL(@MovUnidad, ''))
IF @Modulo = 'VTAS' UPDATE VentaD  WITH (ROWLOCK) SET Unidad = @MovUnidad, AjusteCosteo = @ArtAjusteCosteo * @ArtFactor, CostoUEPS = @ArtCostoUEPS * @ArtFactor, CostoPEPS = @ArtCostoPEPS * @ArtFactor, UltimoCosto = @ArtUltimoCosto * @ArtFactor, PrecioLista = @PrecioSinImpuestos, DepartamentoDetallista = @ArtDepartamentoDetallista WHERE CURRENT OF crVentaDetalle  ELSE
IF @Modulo = 'INV'  UPDATE InvD    WITH (ROWLOCK) SET Unidad = @MovUnidad, AjusteCosteo = @ArtAjusteCosteo * @ArtFactor, CostoUEPS = @ArtCostoUEPS * @ArtFactor, CostoPEPS = @ArtCostoPEPS * @ArtFactor, UltimoCosto = @ArtUltimoCosto * @ArtFactor, PrecioLista = @PrecioSinImpuestos, DepartamentoDetallista = @ArtDepartamentoDetallista, AjustePrecioLista = @AjustePrecioLista WHERE CURRENT OF crInvDetalle ELSE
IF @Modulo = 'PROD' UPDATE ProdD   WITH (ROWLOCK) SET Unidad = @MovUnidad, AjusteCosteo = @ArtAjusteCosteo * @ArtFactor, CostoUEPS = @ArtCostoUEPS * @ArtFactor, CostoPEPS = @ArtCostoPEPS * @ArtFactor, UltimoCosto = @ArtUltimoCosto * @ArtFactor, PrecioLista = @PrecioSinImpuestos, DepartamentoDetallista = @ArtDepartamentoDetallista WHERE CURRENT OF crProdDetalle   ELSE
IF @Modulo = 'COMS' UPDATE CompraD WITH (ROWLOCK) SET Unidad = @MovUnidad, AjusteCosteo = @ArtAjusteCosteo * @ArtFactor, CostoUEPS = @ArtCostoUEPS * @ArtFactor, CostoPEPS = @ArtCostoPEPS * @ArtFactor, UltimoCosto = @ArtUltimoCosto * @ArtFactor, PrecioLista = @PrecioSinImpuestos, DepartamentoDetallista = @ArtDepartamentoDetallista WHERE CURRENT OF crCompraDetalle
END
/*END*/
IF @MovTipo = 'VTAS.FC' AND NULLIF(RTRIM(@ServicioSerie), '') IS NOT NULL AND @CfgVINAccesorioArt = 1 AND @CfgVINCostoSumaAccesorios = 1
INSERT VINAccesorio
(VIN,           Tipo, Accesorio, Descripcion,    PrecioDistribuidor,  PrecioPublico,           PrecioContado,       FechaAlta,     Estatus)
SELECT @ServicioSerie, @Mov, @Articulo, a.Descripcion1, @ArtCosto*@Cantidad, a.PrecioLista*@Cantidad, a.Precio2*@Cantidad, @FechaEmision, 'ALTA'
FROM Art a WITH (NOLOCK)
WHERE a.Articulo = @Articulo
IF @Modulo <> 'COMS' SELECT @Costo = @ArtCosto * @ArtFactor
/*IF @CostosImpuestoIncluido = 1 AND @MovTipo NOT IN ('COMS.EG', 'COMS.EI', 'INV.EI')
SELECT @Costo = @Costo - ROUND(@ImpuestosNetos / @Cantidad, @RedondeoMonetarios)*/
IF @AfectarCostos = 1 AND @ArtTipo NOT IN ('JUEGO', 'SERVICIO') /*AND NOT (@MovTipo IN ('VTAS.F','VTAS.FAR', 'VTAS.FC', 'VTAS.FG', 'VTAS.FX') AND @AplicaMovTipo='VTAS.R')*/ AND @Ok IS NULL
BEGIN
IF @EsEntrada = 1 OR (@EsSalida = 0 AND @EsTransferencia = 1 AND @Accion <> 'CANCELAR') SELECT @EsCargo = 1 ELSE SELECT @EsCargo = 0
IF @MovTipo = 'COMS.B'  IF @Accion <> 'CANCELAR' SELECT @EsCargo = 0 ELSE SELECT @EsCargo = 1
IF @MovTipo IN ('COMS.CA', 'COMS.GX') IF @Accion <> 'CANCELAR' SELECT @EsCargo = 1 ELSE SELECT @EsCargo = 0
/*IF @UsaCacheCostos = 1 AND (@Articulo <> @UltArticulo OR @EsCargo <> @UltEsCargo OR @AplicaMov <> @UltAplica OR @AplicaMovID <> @UltAplicaID)
BEGIN
SELECT @UsaCacheCostos = 0*/
IF @AlmacenTipo = 'ACTIVOS FIJOS' SELECT @AfectarRama = 'AF' ELSE SELECT @AfectarRama = 'INV'
EXEC spSaldo @SucursalAlmacen, @Accion, @Empresa, @Usuario, @AfectarRama, @ArtMoneda, @ArtTipoCambio, @Articulo, @SubCuenta, @AfectarAlmacen, @AfectarAlmacenDestino,
@Modulo, @ID, @Mov, @MovID, @EsCargo, @CostoInvTotal, @AfectarCantidad, @Factor,
@FechaAfectacion, @Ejercicio, @Periodo, @AplicaMov, @AplicaMovID, 0, 0, 0,
@Ok OUTPUT, @OkRef OUTPUT, @Renglon = @Renglon, @RenglonSub = @RenglonSub, @RenglonID = @RenglonID
/*END
IF @UsaCacheCostos = 0
SELECT @UsaCacheCostos   = 1,
@UltArticulo      = @Articulo,
@UltArtMoneda     = @ArtMoneda,
@UltArtTipoCambio = @ArtTipoCambio,
@UltEsCargo       = @EsCargo,
@UltAplica	     = @AplicaMov,
@UltAplicaID	     = @AplicaMovID,
@UltCostoInvTotal = @CostoInvTotal
ELSE
SELECT @UltCostoInvTotal = @UltCostoInvTotal + @CostoInvTotal*/
END
END  
IF @AfectarSerieLote = 1 AND @Ok IS NULL
BEGIN
EXEC spSeriesLotesMayoreo @Sucursal, @SucursalAlmacen, @SucursalAlmacenDestino, @Empresa, @Modulo, @Accion, @AfectarCostos, @EsEntrada, @EsSalida, @EsTransferencia,
@ID, @RenglonID, @Almacen, @AlmacenDestino, @Articulo, @SubCuenta, @ArtTipo, @ArtSerieLoteInfo, @ArtLotesFijos, @ArtCosto, @ArtCostoInv, @Cantidad, @Factor,
@MovTipo, @AplicaMovTipo, @AlmacenTipo, @FechaEmision, @CfgCosteoSeries, @CfgCosteoLotes, @ArtCostoIdentificado, @CfgValidarLotesCostoDif, @CfgVINAccesorioArt, @CfgVINCostoSumaAccesorios,
@Ok OUTPUT, @OkRef OUTPUT
IF @ArtTipo = 'VIN'
BEGIN
IF @Modulo = 'VTAS'
BEGIN
IF @VIN IS NOT NULL SELECT @Ok = 20630
SELECT @VIN = MIN(SerieLote) FROM SerieLoteMov WITH (NOLOCK) WHERE Empresa = @Empresa AND Modulo = @Modulo AND ID = @ID AND RenglonID = @RenglonID AND Articulo  = @Articulo
IF @MovTipo = 'VTAS.F'
UPDATE Venta WITH (ROWLOCK) SET ServicioArticulo = @Articulo, ServicioSerie = @VIN WHERE ID = @ID
END
IF @Accion = 'CANCELAR' AND @Ok IS NULL
UPDATE VIN WITH (ROWLOCK)
SET FechaMRS = NULL
FROM VIN v, SerieLoteMov s WITH (NOLOCK)
WHERE s.Empresa = @Empresa AND s.Modulo = @Modulo AND s.ID = @ID AND s.RenglonID = @RenglonID AND s.Articulo  = @Articulo
AND v.VIN = s.SerieLote AND v.TieneMovimientos = 0
ELSE BEGIN
IF EXISTS(
SELECT v.VIN
FROM VIN v WITH (NOLOCK), SerieLoteMov s WITH (NOLOCK)
WHERE s.Empresa = @Empresa AND s.Modulo = @Modulo AND s.ID = @ID AND s.RenglonID = @RenglonID AND s.Articulo  = @Articulo
AND v.VIN = s.SerieLote AND v.TieneMovimientos = 0)
UPDATE VIN WITH (ROWLOCK)
SET TieneMovimientos = 1
FROM VIN v, SerieLoteMov s WITH (NOLOCK)
WHERE s.Empresa = @Empresa AND s.Modulo = @Modulo AND s.ID = @ID AND s.RenglonID = @RenglonID AND s.Articulo  = @Articulo
AND v.VIN = s.SerieLote AND v.TieneMovimientos = 0
IF @MovTipo IN ('COMS.F', 'COMS.FL', 'COMS.EG', 'COMS.EI')
EXEC spVINEntrada @Empresa, @Modulo, @ID, @Mov, @RenglonID, @Articulo, @FechaEmision, @FechaRequerida, @ImporteNeto, @Impuesto1Neto, @VIN OUTPUT, @Ok OUTPUT, @OkRef OUTPUT
IF @MovTipo IN ('VTAS.F','VTAS.FAR', 'VTAS.FC', 'VTAS.FG', 'VTAS.FX', 'VTAS.FB')
UPDATE VIN WITH (ROWLOCK)
SET Cliente = @ClienteProv,
FechaSalida = @FechaEmision,
VentaID = @ID
FROM VIN v, SerieLoteMov s WITH (NOLOCK)
WHERE s.Empresa = @Empresa AND s.Modulo = @Modulo AND s.ID = @ID AND s.RenglonID = @RenglonID AND s.Articulo  = @Articulo
AND v.VIN = s.SerieLote
END
END
END
IF (@MovTipo = 'VTAS.FM' AND @FacturarVtasMostrador = 1 AND @ArtTipo IN ('SERIE', 'LOTE', 'VIN', 'PARTIDA') AND @Accion <> 'CANCELAR')
BEGIN
SELECT @CantidadDif = @Cantidad
SELECT @CantidadDif = @Cantidad - ISNULL(SUM(Cantidad) / @Factor, 0.0)
FROM SerieLoteMov WITH (NOLOCK)
WHERE Empresa   = @Empresa
AND Modulo    = @Modulo
AND ID        = @ID
AND RenglonID = @RenglonID
AND Articulo  = @Articulo
AND ISNULL(RTRIM(SubCuenta), '') = ISNULL(@SubCuenta, '')
IF @CantidadDif <> 0.0
BEGIN
DECLARE @SerieLoteMov TABLE (Sucursal int NULL, Empresa char(5) COLLATE Database_Default NULL, Modulo char(5) COLLATE Database_Default NULL, ID int NULL, RenglonID int NULL, Articulo varchar(20) COLLATE Database_Default NULL, SubCuenta varchar(50) COLLATE Database_Default NULL, SerieLote varchar(20) COLLATE Database_Default NULL, Cantidad float NULL, CantidadAlterna float NULL, Propiedades varchar(20) COLLATE Database_Default NULL, ArtCostoInv money NULL, Cliente varchar(10) COLLATE Database_Default NULL, Localizacion varchar(10) COLLATE Database_Default NULL)
EXEC spSeriesLotesSurtidoAuto @Sucursal, @Empresa, @Modulo, @EsSalida, @EsTransferencia,
@ID,  @RenglonID, @Almacen, @Articulo, @SubCuenta, @CantidadDif, @Factor,
@AlmacenTipo, @SeriesLotesAutoOrden,
@Ok OUTPUT, @OkRef OUTPUT, @Temp = 1
EXEC spSeriesLotesMayoreo @Sucursal, @SucursalAlmacen, @SucursalAlmacenDestino, @Empresa, @Modulo, @Accion, @AfectarCostos, @EsEntrada, @EsSalida, @EsTransferencia,
@ID, @RenglonID, @Almacen, @AlmacenDestino, @Articulo, @SubCuenta, @ArtTipo, @ArtSerieLoteInfo, @ArtLotesFijos, @ArtCosto, @ArtCostoInv, @CantidadDif, @Factor,
@MovTipo, @AplicaMovTipo, @AlmacenTipo, @FechaEmision, @CfgCosteoSeries, @CfgCosteoLotes, @ArtCostoIdentificado, @CfgValidarLotesCostoDif, @CfgVINAccesorioArt, @CfgVINCostoSumaAccesorios,
@Ok OUTPUT, @OkRef OUTPUT, @Temp = 1
EXEC spSeriesLotesFusionarTemp @Ok OUTPUT, @OkRef OUTPUT
SELECT @CantidadDif = @Cantidad
SELECT @CantidadDif = @Cantidad - ISNULL(SUM(Cantidad) / @Factor, 0.0)
FROM SerieLoteMov WITH (NOLOCK)
WHERE Empresa   = @Empresa
AND Modulo    = @Modulo
AND ID        = @ID
AND RenglonID = @RenglonID
AND Articulo  = @Articulo
AND ISNULL(RTRIM(SubCuenta), '') = ISNULL(@SubCuenta, '')
IF @CantidadDif <> 0.0 SELECT @Ok = 20330
END
END
IF @AfectarCostos = 1 AND @CfgMultiUnidades = 1 AND @CfgMultiUnidadesNivel = 'ARTICULO'
EXEC xpArtUnidadFactorRecalc @Empresa, @Accion,	@Modulo, @ID, @Renglon, @RenglonSub, @MovTipo, @AlmacenTipo,
@Articulo, @SubCuenta, @MovUnidad, @ArtTipo, @Factor,
@Almacen, @Cantidad, @CantidadInventario, @EsEntrada, @EsSalida,
@Ok OUTPUT, @OkRef OUTPUT
IF @Modulo IN ('COMS', 'PROD', 'INV')
BEGIN
IF (@CfgBackOrders = 1 AND @MovTipo IN ('COMS.F', 'COMS.FL', 'COMS.EG', 'COMS.EI', 'COMS.IG', 'INV.T', 'INV.T', 'INV.EI') OR (@MovTipo='PROD.E')) AND @Accion <> 'CANCELAR'
BEGIN
SELECT @Cliente = NULL
SELECT @DestinoTipo = NULL, @Destino = NULL, @DestinoID = NULL
IF @Modulo = 'COMS' SELECT @Cliente = Cliente FROM CompraD WITH (NOLOCK) WHERE ID = @ID AND Renglon = @Renglon AND RenglonSub = @RenglonSub ELSE
IF @Modulo = 'INV'  SELECT @Cliente = Cliente, @DestinoTipo = DestinoTipo, @Destino = Destino, @DestinoID = DestinoID FROM InvD WITH (NOLOCK) WHERE ID = @ID AND Renglon = @Renglon AND RenglonSub = @RenglonSub ELSE
IF @Modulo = 'PROD' SELECT @Cliente = Cliente FROM ProdD WITH (NOLOCK)  WHERE ID = @ID AND Renglon = @Renglon AND RenglonSub = @RenglonSub
IF @Modulo = 'INV' AND @Largo = 1 AND (@Cliente IS NOT NULL OR @DestinoTipo IS NOT NULL) SELECT @Ok = 20970
IF @Cliente IS NOT NULL
EXEC spInvBackOrderCliente @Sucursal, @Empresa, @Usuario, @Cliente, @Articulo, @SubCuenta, @Cantidad, @Factor,
@ArtMoneda, @Almacen, @FechaAfectacion, @FechaRegistro, @Ejercicio, @Periodo,
@Ok OUTPUT, @OkRef OUTPUT
END
IF @MovTipo IN ('COMS.D', 'COMS.B', 'COMS.CA', 'COMS.GX') AND @AfectarCostos = 1
BEGIN
/*SELECT @Costo = @ArtCosto * @ArtFactor
IF @CostosImpuestoIncluido = 1
SELECT @Costo = @Costo - ROUND(@ImpuestosNetos / @Cantidad, @RedondeoMonetarios)*/
SELECT @DescuentoInverso = 100-ISNULL(@DescuentoGlobal, 0)
EXEC spR3 @DescuentoInverso, @Costo, 100, @Precio OUTPUT
EXEC spCalculaImporte @Accion, @Modulo, @CfgImpInc, @MovTipo, @EsEntrada, @CantidadCalcularImporte, @Precio, NULL, NULL, @DescuentoGlobal, @SobrePrecio, @Impuesto1, @Impuesto2, @Impuesto3,
@Importe OUTPUT, @ImporteNeto OUTPUT, @DescuentoLineaImporte OUTPUT, @DescuentoGlobalImporte OUTPUT, @SobrePrecioImporte OUTPUT,
@Impuestos OUTPUT, @ImpuestosNetos OUTPUT, @Impuesto1Neto OUTPUT, @Impuesto2Neto OUTPUT, @Impuesto3Neto OUTPUT,
@Articulo = @Articulo, @CantidadObsequio = @CantidadObsequio, @CfgPrecioMoneda = @CfgPrecioMoneda, @MovTipoCambio = @MovTipoCambio, @PrecioTipoCambio = @PrecioTipoCambio
END ELSE BEGIN
SELECT @ImporteNeto = @Costo * @Cantidad
END
END
IF @Modulo = 'PROD' SELECT @Importe = @Cantidad * @Costo
IF @MovTipo = 'PROD.O' AND @Accion = 'AFECTAR'
BEGIN
EXEC spProdCentroInicial @ID, @Articulo, @SubCuenta, @ProdSerieLote, @Orden OUTPUT, @OrdenDestino OUTPUT, @Centro OUTPUT, @CentroDestino OUTPUT, @Estacion OUTPUT, @EstacionDestino OUTPUT
UPDATE ProdD WITH (ROWLOCK) SET Centro = @Centro, Orden = @Orden, CentroDestino = @CentroDestino, OrdenDestino = @OrdenDestino, Estacion = @Estacion, EstacionDestino = @EstacionDestino WHERE CURRENT OF crProdDetalle
END
IF @MovTipo IN ('PROD.O', 'PROD.CO', 'PROD.E')
EXEC spProdSerieLote @Sucursal, @Accion, @Empresa, @MovTipo, @FechaEmision, @DetalleTipo, @ProdSerieLote, @Articulo, @SubCuenta, @Cantidad, @Merma, @Desperdicio, @Factor, @Ok OUTPUT, @OkRef OUTPUT
IF @MovTipo = 'INV.CM'
EXEC spProdSerieLoteCosto @Sucursal, @Accion, @Empresa, @Modulo, @ID, @MovTipo, @DetalleTipo, @ProdSerieLote, @Producto, @SubProducto, @CostoInvTotal, @ArtMoneda, @Mov, 0
IF @MovTipo = 'PROD.E'
EXEC spProdSerieLoteCosto @Sucursal, @Accion, @Empresa, @Modulo, @ID, @MovTipo, @DetalleTipo, @ProdSerieLote, @Articulo, @SubCuenta, @CostoInvTotal, @ArtMoneda, @Mov, 0
IF @AlmacenTipo = 'ACTIVOS FIJOS' AND @ArtTipo IN ('SERIE', 'VIN') AND @CfgSeriesLotesMayoreo = 1 AND @Ok IS NULL AND
(@EsEntrada = 1 OR @EsSalida = 1 OR @EsTransferencia = 1) AND @OrigenMovTipo <> 'COMS.CC'
EXEC spActivoF @Sucursal, @Empresa, @Modulo, @Accion, @EsEntrada, @EsSalida, @EsTransferencia,
@ID, @RenglonID, @Almacen, @AlmacenDestino, @Articulo, @ArtTipo, @Cantidad,
@ArtCostoInv, @ArtMoneda, @FechaEmision,
@Ok OUTPUT, @OkRef OUTPUT
IF @Modulo = 'VTAS' AND
(@EstatusNuevo = 'CONCLUIDO' OR (@EstatusNuevo = 'CANCELADO' AND @Estatus <> 'PENDIENTE')) AND
(@MovTipo IN ('VTAS.F','VTAS.FAR','VTAS.FB', 'VTAS.D', 'VTAS.DF', 'VTAS.B') OR
(@MovTipo = 'VTAS.FM' AND @FacturarVtasMostrador = 1 AND @Accion <> 'CANCELAR')) AND @Ok IS NULL
BEGIN
IF @ArtTipo IN ('SERIE','LOTE','VIN') AND @CfgSeriesLotesMayoreo = 0
SELECT @AcumularSinDetalles = 1
ELSE SELECT @AcumularSinDetalles = 0
IF @MovTipo IN ('VTAS.F','VTAS.FAR','VTAS.FB','VTAS.FM') SELECT @EsCargo = 1 ELSE SELECT @EsCargo = 0
/** 02.08.2006 **/
/** 16.11.2006 **/
IF @CantidadOriginal<0.0 SELECT @EsCargo = ~@EsCargo
IF @Accion = 'CANCELAR' SELECT @EsCargo = ~@EsCargo
IF @MovTipo = 'VTAS.B' SELECT @AcumCantidad = NULL ELSE SELECT @AcumCantidad = @Cantidad
EXEC spSaldo @Sucursal, @Accion, @Empresa, @Usuario, 'VTAS', @MovMoneda, NULL, @Articulo, @SubCuenta, @ClienteProv,  NULL,
@Modulo, @ID, @Mov, @MovID, @EsCargo, @ImporteNeto, @AcumCantidad, @Factor,
@FechaAfectacion, @Ejercicio, @Periodo, NULL, NULL, 0, @AcumularSinDetalles, 0,
@Ok OUTPUT, @OkRef OUTPUT, @Renglon = @Renglon, @RenglonSub = @RenglonSub, @RenglonID = @RenglonID
END ELSE
IF @Modulo = 'COMS' AND (@EstatusNuevo = 'CONCLUIDO' OR (@EstatusNuevo = 'CANCELADO' AND @Estatus <> 'PENDIENTE')) AND @MovTipo IN ('COMS.F','COMS.FL','COMS.EG', 'COMS.EI','COMS.D','COMS.B','COMS.CA', 'COMS.GX') AND @Ok IS NULL
BEGIN
IF @ArtTipo IN ('SERIE','LOTE','VIN') AND @CfgSeriesLotesMayoreo = 0
SELECT @AcumularSinDetalles = 1
ELSE SELECT @AcumularSinDetalles = 0
IF @MovTipo IN ('COMS.F','COMS.FL','COMS.EG', 'COMS.EI','COMS.CA', 'COMS.GX') SELECT @EsCargo = 1 ELSE SELECT @EsCargo = 0
IF @Accion = 'CANCELAR' SELECT @EsCargo = ~@EsCargo
IF @MovTipo IN ('COMS.B', 'COMS.CA', 'COMS.GX') SELECT @AcumCantidad = NULL ELSE SELECT @AcumCantidad = @Cantidad
EXEC spSaldo @Sucursal, @Accion, @Empresa, @Usuario, 'COMS', @MovMoneda, NULL, @Articulo, @SubCuenta, @ClienteProv, NULL,
@Modulo, @ID, @Mov, @MovID, @EsCargo, @ImporteNeto, @AcumCantidad, @Factor,
@FechaAfectacion, @Ejercicio, @Periodo, NULL, NULL, 0, @AcumularSinDetalles, 0,
@Ok OUTPUT, @OkRef OUTPUT, @Renglon = @Renglon, @RenglonSub = @RenglonSub, @RenglonID = @RenglonID
IF @MovTipo IN ('COMS.F', 'COMS.FL', 'COMS.EG', 'COMS.EI') AND @Accion <> 'CANCELAR'
BEGIN
IF @MovTipo = 'COMS.EI'
SELECT @ProveedorRef = ISNULL(NULLIF(RTRIM(ImportacionProveedor), ''), @ClienteProv) FROM CompraD WITH (NOLOCK) WHERE ID = @ID AND Renglon = @Renglon AND RenglonSub = @RenglonSub
ELSE
SELECT @ProveedorRef = @ClienteProv
IF @CostosImpuestoIncluido = 1 SELECT @ArtProvCosto = @Costo ELSE SELECT @ArtProvCosto = @ArtCosto
EXEC xpArtProv @Empresa, @Accion, @Modulo, @ID, @Renglon, @RenglonSub, @MovTipo, @AlmacenTipo,
@Articulo, @SubCuenta, @MovUnidad, @ArtTipo, @Factor,
@Almacen, @Cantidad, @CantidadInventario, @EsEntrada, @EsSalida,
@ProveedorRef, @ArtProvCosto, @FechaEmision,
@Ok OUTPUT, @OkRef OUTPUT
END
END
IF (@CfgPosiciones = 1 OR @CfgExistenciaAlterna = 1) AND @OrigenTipo <> 'VMOS' AND @AlmacenTipo <> 'ACTIVOS FIJOS' AND @ArtTipo NOT IN ('JUEGO', 'SERVICIO') AND (@EsEntrada = 1 OR @EsSalida = 1 OR @EsTransferencia = 1 OR @MovTipo IN ('COMS.CC') OR @Mov = @CfgEstadisticaAjusteMerma) AND @Ok IS NULL
BEGIN
IF @CfgPosiciones = 1 AND @Posicion IS NULL
SELECT @Ok = 13050
ELSE BEGIN
IF @MovTipo NOT IN ('COMS.CC')
BEGIN
SELECT @AuxiliarAlternoSucursal = @SucursalAlmacen, @AuxiliarAlternoAlmacen = @Almacen
IF @Accion = 'CANCELAR'
SELECT @AuxiliarAlternoFactorEntrada = -1.0, @AuxiliarAlternoFactorSalida = NULL
ELSE
SELECT @AuxiliarAlternoFactorEntrada = NULL, @AuxiliarAlternoFactorSalida = 1.0
IF @EsSalida = 1 OR @EsTransferencia = 1
BEGIN
IF @CfgExistenciaAlternaSerieLote = 1 AND @ArtTipo IN ('SERIE', 'LOTE', 'VIN', 'PARTIDA')
INSERT AuxiliarAlterno
(Empresa,  Sucursal,                 Almacen,                 Posicion,  SerieLote, Modulo,  ID,  Renglon,  RenglonSub,  Articulo,  SubCuenta,  Unidad,     Factor,  Entrada,                                Salida)
SELECT @Empresa, @AuxiliarAlternoSucursal, @AuxiliarAlternoAlmacen, @Posicion, SerieLote, @Modulo, @ID, @Renglon, @RenglonSub, @Articulo, @SubCuenta, @MovUnidad, @Factor, Cantidad*@AuxiliarAlternoFactorEntrada, Cantidad*@AuxiliarAlternoFactorSalida
FROM SerieLoteMov WITH (NOLOCK)
WHERE Empresa = @Empresa AND Modulo = @Modulo AND ID = @ID AND RenglonID = @RenglonID AND Articulo = @Articulo AND ISNULL(SubCuenta, '') = ISNULL(@SubCuenta, '')
ELSE
INSERT AuxiliarAlterno
(Empresa,  Sucursal,                 Almacen,                 Posicion,  Modulo,  ID,  Renglon,  RenglonSub,  Articulo,  SubCuenta,  Unidad,     Factor,  Entrada,                                 Salida)
SELECT @Empresa, @AuxiliarAlternoSucursal, @AuxiliarAlternoAlmacen, @Posicion, @Modulo, @ID, @Renglon, @RenglonSub, @Articulo, @SubCuenta, @MovUnidad, @Factor, @Cantidad*@AuxiliarAlternoFactorEntrada, @Cantidad*@AuxiliarAlternoFactorSalida
END
IF @EsTransferencia = 1
SELECT @AuxiliarAlternoSucursal = @SucursalAlmacenDestino, @AuxiliarAlternoAlmacen = @AlmacenDestino
IF @Accion = 'CANCELAR'
SELECT @AuxiliarAlternoFactorEntrada = NULL, @AuxiliarAlternoFactorSalida = -1.0
ELSE
SELECT @AuxiliarAlternoFactorEntrada = 1.0, @AuxiliarAlternoFactorSalida = NULL
IF @EsEntrada = 1 OR @EsTransferencia = 1 OR @Mov = @CfgEstadisticaAjusteMerma
BEGIN
IF @CfgExistenciaAlternaSerieLote = 1 AND @ArtTipo IN ('SERIE', 'LOTE', 'VIN', 'PARTIDA')
INSERT AuxiliarAlterno
(Empresa,  Sucursal,                 Almacen,                 Posicion,  SerieLote, Modulo,  ID,  Renglon,  RenglonSub,  Articulo,  SubCuenta,  Unidad,     Factor,  Entrada,                                Salida)
SELECT @Empresa, @AuxiliarAlternoSucursal, @AuxiliarAlternoAlmacen, @Posicion, SerieLote, @Modulo, @ID, @Renglon, @RenglonSub, @Articulo, @SubCuenta, @MovUnidad, @Factor, Cantidad*@AuxiliarAlternoFactorEntrada, Cantidad*@AuxiliarAlternoFactorSalida
FROM SerieLoteMov WITH (NOLOCK)
WHERE Empresa = @Empresa AND Modulo = @Modulo AND ID = @ID AND RenglonID = @RenglonID AND Articulo = @Articulo AND ISNULL(SubCuenta, '') = ISNULL(@SubCuenta, '')
ELSE
INSERT AuxiliarAlterno
(Empresa,  Sucursal,                 Almacen,                 Posicion,  Modulo,  ID,  Renglon,  RenglonSub,  Articulo,  SubCuenta,  Unidad,     Factor,  Entrada,                                 Salida)
SELECT @Empresa, @AuxiliarAlternoSucursal, @AuxiliarAlternoAlmacen, @Posicion, @Modulo, @ID, @Renglon, @RenglonSub, @Articulo, @SubCuenta, @MovUnidad, @Factor, @Cantidad*@AuxiliarAlternoFactorEntrada, @Cantidad*@AuxiliarAlternoFactorSalida
END
END
END
END
IF @AfectarMatando = 1 AND @Utilizar = 1 AND @AplicaMov IS NOT NULL AND @AplicaMovID IS NOT NULL AND @Ok IS NULL
SELECT @Ok = 71050
IF (@Estatus = 'PENDIENTE' OR @EstatusNuevo = 'PENDIENTE') AND @Ok IS NULL
BEGIN
IF @EstatusNuevo = 'PENDIENTE'
BEGIN
IF @Accion IN ('ASIGNAR', 'DESASIGNAR')
EXEC spInvAsignar @Sucursal, @Accion, @Empresa, @Modulo, @ID, @Mov, @MovID, @Almacen, @Articulo, @SubCuenta, @MovUnidad, @Cantidad OUTPUT, @Ok OUTPUT, @OkRef OUTPUT
IF @Accion = 'RESERVARPARCIAL' SELECT @CantidadPendiente = @Cantidad - @ReservadoParcial,  @CantidadReservada = @CantidadReservada + @ReservadoParcial ELSE
IF @Accion = 'RESERVAR'        SELECT @CantidadPendiente = @CantidadPendiente - @Cantidad, @CantidadReservada = @CantidadReservada + @Cantidad ELSE
IF @Accion = 'DESRESERVAR'  	 SELECT @CantidadPendiente = @CantidadPendiente + @Cantidad, @CantidadReservada = @CantidadReservada - @Cantidad ELSE
IF @Accion = 'ASIGNAR'         SELECT @CantidadPendiente = @CantidadPendiente - @Cantidad, @CantidadOrdenada  = @CantidadOrdenada  + @Cantidad ELSE
IF @Accion = 'DESASIGNAR'      SELECT @CantidadPendiente = @CantidadPendiente + @Cantidad, @CantidadOrdenada  = @CantidadOrdenada  - @Cantidad ELSE
IF @Accion = 'CANCELAR'
BEGIN
SELECT @CantidadReservada = @CantidadReservada - @Cantidad
IF @CantidadReservada < 0
SELECT @CantidadPendiente = @CantidadPendiente + @CantidadReservada, @CantidadReservada = 0.0
/*  Cancelar Parcial, esto funciona bien en el movimiento, pero el problema es que en la rutina de
spInvAfectarUnidades, esta desreservando primero.
SELECT @CantidadPendiente = @CantidadPendiente - @Cantidad
IF @CantidadPendiente < 0
BEGIN
SELECT @Cantidad = -@CantidadPendiente, @CantidadPendiente = 0.0
SELECT @CantidadReservada = @CantidadReservada - @Cantidad
IF @CantidadReservada < 0
SELECT @CantidadPendiente = @CantidadPendiente + @CantidadReservada, @CantidadReservada = 0.0
END*/
END ELSE SELECT @CantidadPendiente = @Cantidad
END
ELSE
IF @EstatusNuevo = 'CANCELADO'
SELECT @CantidadReservada = 0.0, @CantidadPendiente = 0.0
ELSE
IF @Base IN ('SELECCION','PENDIENTE','TODO')
SELECT @CantidadPendiente = @CantidadPendiente - @Cantidad
IF @MovTipo IN ('VTAS.F','VTAS.FAR','VTAS.FC', 'VTAS.FG', 'VTAS.FX','VTAS.FB') AND @EstatusNuevo = 'CONCLUIDO' AND @Accion = 'AFECTAR' SELECT @CantidadPendiente = 0.0, @CantidadReservada = 0.0
IF @Modulo NOT IN ('VTAS', 'INV', 'PROD') SELECT @CantidadOrdenada = 0.0
IF @CantidadPendiente = 0.0 SELECT @CantidadPendiente = NULL
IF @CantidadReservada = 0.0 SELECT @CantidadReservada = NULL
IF @CantidadOrdenada  = 0.0 SELECT @CantidadOrdenada  = NULL
IF @Modulo = 'VTAS' UPDATE VentaD  WITH (ROWLOCK) SET CantidadCancelada = CASE WHEN @Accion = 'CANCELAR' AND @Base <> 'TODO' THEN ISNULL(CantidadCancelada, 0.0) + @Cantidad ELSE CantidadCancelada END, CantidadA = NULL, CantidadReservada = @CantidadReservada, UltimoReservadoCantidad = @UltReservadoCantidad, UltimoReservadoFecha = @UltReservadoFecha, CantidadOrdenada = @CantidadOrdenada, CantidadPendiente = @CantidadPendiente WHERE CURRENT OF crVentaDetalle ELSE
IF @Modulo = 'INV'  UPDATE InvD    WITH (ROWLOCK) SET CantidadCancelada = CASE WHEN @Accion = 'CANCELAR' AND @Base <> 'TODO' THEN ISNULL(CantidadCancelada, 0.0) + @Cantidad ELSE CantidadCancelada END, CantidadA = NULL, CantidadReservada = @CantidadReservada, UltimoReservadoCantidad = @UltReservadoCantidad, UltimoReservadoFecha = @UltReservadoFecha, CantidadOrdenada = @CantidadOrdenada, CantidadPendiente = @CantidadPendiente WHERE CURRENT OF crInvDetalle ELSE
IF @Modulo = 'PROD' UPDATE ProdD   WITH (ROWLOCK) SET CantidadCancelada = CASE WHEN @Accion = 'CANCELAR' AND @Base <> 'TODO' THEN ISNULL(CantidadCancelada, 0.0) + @Cantidad ELSE CantidadCancelada END, CantidadA = NULL, CantidadReservada = @CantidadReservada, UltimoReservadoCantidad = @UltReservadoCantidad, UltimoReservadoFecha = @UltReservadoFecha, CantidadOrdenada = @CantidadOrdenada, CantidadPendiente = @CantidadPendiente WHERE CURRENT OF crProdDetalle ELSE
IF @Modulo = 'COMS' UPDATE CompraD WITH (ROWLOCK) SET CantidadCancelada = CASE WHEN @Accion = 'CANCELAR' AND @Base <> 'TODO' THEN ISNULL(CantidadCancelada, 0.0) + @Cantidad ELSE CantidadCancelada END, CantidadA = NULL, CantidadPendiente = @CantidadPendiente WHERE CURRENT OF crCompraDetalle
IF @@ERROR <> 0 SELECT @Ok = 1
/*IF @Modulo = 'VTAS' AND @Accion = 'CANCELAR' AND @Base <> 'TODO'
BEGIN
IF (SELECT CantidadCancelada FROM VentaD WHERE ID = @ID AND Renglon = @Renglon AND RenglonSub = @RenglonSub) = @CantidadOriginal
UPDATE VentaDAgente SET Estado = 'Cancelada' WHERE ID = @ID AND Renglon = @Renglon AND RenglonSub = @RenglonSub
END*/
/*                IF @Accion = 'CANCELAR' AND @Base <> 'TODO'
BEGIN
IF @Modulo = 'VTAS' UPDATE VentaD  SET CantidadCancelada = ISNULL(CantidadCancelada, 0.0) + @Cantidad WHERE CURRENT OF crVentaDetalle ELSE
IF @Modulo = 'INV'  UPDATE InvD    SET CantidadCancelada = ISNULL(CantidadCancelada, 0.0) + @Cantidad WHERE CURRENT OF crInvDetalle ELSE
IF @Modulo = 'PROD' UPDATE ProdD   SET CantidadCancelada = ISNULL(CantidadCancelada, 0.0) + @Cantidad WHERE CURRENT OF crProdDetalle ELSE
IF @Modulo = 'COMS' UPDATE CompraD SET CantidadCancelada = ISNULL(CantidadCancelada, 0.0) + @Cantidad WHERE CURRENT OF crCompraDetalle
IF @@ERROR <> 0 SELECT @Ok = 1
END             */
EXEC spArtR @Empresa, @Modulo, @Articulo, @SubCuenta, @Almacen, @MovTipo, @Factor, NULL, @CantidadPendienteA, @CantidadPendiente, NULL, @CantidadOrdenadaA, @CantidadOrdenada
IF @CfgBackOrders = 1 AND @MovTipo IN ('COMS.O', 'COMS.OG', 'COMS.OI', 'PROD.O', 'INV.OT', 'INV.OI') AND @AplicaMovTipo IS NULL
BEGIN
SELECT @DestinoTipo = NULL, @Destino = NULL, @DestinoID = NULL
IF @Modulo = 'COMS' SELECT @DestinoTipo = DestinoTipo, @Destino = Destino, @DestinoID = DestinoID FROM CompraD WITH (NOLOCK) WHERE ID = @ID AND Renglon = @Renglon AND RenglonSub = @RenglonSub ELSE
IF @Modulo = 'INV'  SELECT @DestinoTipo = DestinoTipo, @Destino = Destino, @DestinoID = DestinoID FROM InvD    WITH (NOLOCK) WHERE ID = @ID AND Renglon = @Renglon AND RenglonSub = @RenglonSub ELSE
IF @Modulo = 'PROD' SELECT @DestinoTipo = DestinoTipo, @Destino = Destino, @DestinoID = DestinoID FROM ProdD   WITH (NOLOCK) WHERE ID = @ID AND Renglon = @Renglon AND RenglonSub = @RenglonSub
IF @DestinoTipo IN (SELECT Modulo FROM Modulo) AND @Destino IS NOT NULL AND @DestinoID IS NOT NULL
EXEC spInvBackOrder @Sucursal, @Accion, @Estatus, 0, @Empresa, @Usuario, @Modulo, @ID, @Mov, @MovID,
@DestinoTipo, @Destino, @DestinoID, @Articulo, @SubCuenta, @MovUnidad, @Cantidad, @Factor, @ArtMoneda,
@Almacen, @FechaAfectacion, @FechaRegistro, @Ejercicio, @Periodo,
@Ok OUTPUT, @OkRef OUTPUT, @MovTipo = @MovTipo
END
END
IF @CfgBackOrders = 1 AND @MovTipo = 'COMS.CP'
BEGIN
SELECT @DestinoTipo = NULL, @Destino = NULL, @DestinoID = NULL
IF @Modulo = 'COMS' SELECT @DestinoTipo = DestinoTipo, @Destino = Destino, @DestinoID = DestinoID FROM CompraD WITH (NOLOCK) WHERE ID = @ID AND Renglon = @Renglon AND RenglonSub = @RenglonSub
IF @DestinoTipo IN (SELECT Modulo FROM Modulo) AND @Destino IS NOT NULL AND @DestinoID IS NOT NULL
EXEC spInvBackOrder @Sucursal, @Accion, @Estatus, 0, @Empresa, @Usuario, @Modulo, @ID, @Mov, @MovID,
@DestinoTipo, @Destino, @DestinoID, @Articulo, @SubCuenta, @MovUnidad, @Cantidad, @Factor, @ArtMoneda,
@Almacen, @FechaAfectacion, @FechaRegistro, @Ejercicio, @Periodo,
@Ok OUTPUT, @OkRef OUTPUT, @MovTipo = @MovTipo
END
END 
IF @Generar = 1 AND @GenerarCopia = 1 AND @Ok IS NULL
BEGIN
IF @MovTipo IN ('VTAS.C', 'VTAS.CS', 'VTAS.FR') SELECT @GenerarDirecto = 1 ELSE SELECT @GenerarDirecto = 0
EXEC spInvGenerarDetalle @Sucursal, @Modulo, @ID, @Renglon, @RenglonSub, @IDGenerar, @GenerarDirecto, @Mov, @MovID, @Cantidad, @Ok OUTPUT
IF @Base = 'SELECCION'
BEGIN
IF @Modulo = 'VTAS' UPDATE VentaD  WITH (ROWLOCK) SET CantidadA = NULL WHERE CURRENT OF crVentaDetalle ELSE
IF @Modulo = 'COMS' UPDATE CompraD WITH (ROWLOCK) SET CantidadA = NULL WHERE CURRENT OF crCompraDetalle ELSE
IF @Modulo = 'INV'  UPDATE InvD    WITH (ROWLOCK) SET CantidadA = NULL WHERE CURRENT OF crInvDetalle ELSE
IF @Modulo = 'PROD' UPDATE ProdD   WITH (ROWLOCK) SET CantidadA = NULL WHERE CURRENT OF crProdDetalle
IF @@ERROR <> 0 SELECT @Ok = 1
END
END
IF @Estatus IN ('SINAFECTAR', 'CONFIRMAR', 'BORRADOR')
BEGIN
SELECT @TiempoEstandarFijo	   = NULL,
@TiempoEstandarVariable = NULL
IF @MovTipo IN ('PROD.A', 'PROD.E')
SELECT @TiempoEstandarFijo = ISNULL(TiempoFijo, 0), @TiempoEstandarVariable = ISNULL(TiempoVariable, 0)*@Cantidad
FROM ProdRutaD WITH (NOLOCK)
WHERE Ruta = @Ruta AND Orden = @Orden AND Centro = @Centro
IF @Modulo = 'VTAS' UPDATE VentaD  WITH (ROWLOCK) SET Unidad = @MovUnidad, Factor = @Factor, ArtEstatus = CASE WHEN @CfgVentaArtEstatus = 1 THEN @ArtEstatus ELSE NULL END, ArtSituacion = CASE WHEN @CfgVentaArtSituacion = 1 THEN @ArtSituacion ELSE NULL END  WHERE CURRENT OF crVentaDetalle ELSE
IF @Modulo = 'COMS' UPDATE CompraD WITH (ROWLOCK) SET Unidad = @MovUnidad, Factor = @Factor WHERE CURRENT OF crCompraDetalle ELSE
IF @Modulo = 'INV'  UPDATE InvD    WITH (ROWLOCK) SET Unidad = @MovUnidad, Factor = @Factor WHERE CURRENT OF crInvDetalle ELSE
IF @Modulo = 'PROD' UPDATE ProdD   WITH (ROWLOCK) SET Unidad = @MovUnidad, Factor = @Factor, TiempoEstandarFijo = @TiempoEstandarFijo, TiempoEstandarVariable = @TiempoEstandarVariable WHERE CURRENT OF crProdDetalle
END
IF @MovTipo = 'COMS.R'
BEGIN
SELECT @CompraID = NULL
SELECT @CompraID = MAX(c.ID)
FROM Compra c WITH (NOLOCK), CompraD d WITH (NOLOCK), MovTipo mt WITH (NOLOCK)
WHERE c.Empresa = @Empresa AND c.Estatus = 'CONCLUIDO'
AND mt.Modulo = @Modulo AND mt.Mov = c.Mov AND mt.Clave IN ('COMS.F', 'COMS.FL', 'COMS.EG', 'COMS.EI')
AND d.ID = c.ID AND d.Articulo = @Articulo AND ISNULL(d.SubCuenta, '') = ISNULL(@SubCuenta, '')
IF @CompraID IS NOT NULL
SELECT @ProveedorRef = Proveedor FROM Compra WITH (NOLOCK) WHERE ID = @CompraID
ELSE
BEGIN
SELECT @ProveedorRef = @ClienteProv
SELECT @ProveedorRef = ISNULL(p.Proveedor, @ClienteProv)
FROM Art a WITH (NOLOCK), Prov p WITH (NOLOCK)
WHERE a.Articulo = @Articulo AND p.Proveedor = a.Proveedor
END
UPDATE CompraD WITH (ROWLOCK) SET ProveedorRef = @ProveedorRef
WHERE CURRENT OF crCompraDetalle
END
IF @Modulo = 'COMS' AND @Accion IN ('AFECTAR', 'CANCELAR') AND NULLIF(RTRIM(@ServicioSerie), '') IS NOT NULL
EXEC spSerieLoteFlujo @Sucursal, @SucursalAlmacen, @SucursalAlmacenDestino, @Accion, @Empresa, @Modulo, @ID, @ServicioArticulo, NULL, @ServicioSerie, @Almacen, @RenglonID
IF @MovTipo IN ('VTAS.P', 'VTAS.S', 'VTAS.SD', 'VTAS.F','VTAS.FAR', 'VTAS.FB', 'VTAS.D', 'VTAS.DF', 'VTAS.B', 'VTAS.FM', 'VTAS.N', 'VTAS.NO', 'VTAS.NR', 'PROD.A', 'PROD.R', 'PROD.E') AND @FacturarVtasMostrador = 0 AND (@Estatus = 'SINAFECTAR' OR @Accion = 'CANCELAR') AND @Ok IS NULL
BEGIN
IF @Accion = 'CANCELAR'
BEGIN
IF @Modulo = 'VTAS' SELECT @ImporteComision = ISNULL(Comision, 0.0) FROM VentaD WITH (NOLOCK) WHERE ID = @ID AND Renglon = @Renglon AND RenglonSub = @RenglonSub ELSE
IF @Modulo = 'PROD' SELECT @ImporteComision = ISNULL(Comision, 0.0) FROM ProdD  WITH (NOLOCK) WHERE ID = @ID AND Renglon = @Renglon AND RenglonSub = @RenglonSub
END ELSE BEGIN
EXEC xpComisionCalcular @ID, @Accion, @Empresa, @Usuario, @Modulo, @Mov, @MovID, @MovTipo,
@MovMoneda, @MovTipoCambio, @FechaEmision, @FechaRegistro, @FechaAfectacion, @Agente, @Conexion, @SincroFinal, @Sucursal,
@Renglon, @RenglonSub, @Articulo, @Cantidad, @Importe, @ImporteNeto, @Impuestos, @ImpuestosNetos, @Costo, @ArtCosto, @ArtComision,
@ImporteComision OUTPUT, @Ok OUTPUT, @OkRef OUTPUT
IF ISNULL(@ImporteComision, 0.0) <> 0.0 AND @Ok IS NULL
BEGIN
IF @Modulo = 'VTAS' UPDATE VentaD WITH (ROWLOCK) SET Comision = @ImporteComision WHERE CURRENT OF crVentaDetalle ELSE
IF @Modulo = 'PROD' UPDATE ProdD  WITH (ROWLOCK) SET Comision = @ImporteComision WHERE CURRENT OF crProdDetalle
END
END
END
IF @MovTipo NOT IN ('COMS.R', 'COMS.C', 'COMS.O', 'COMS.OP')
BEGIN
IF (SELECT TieneMovimientos FROM Art WITH (NOLOCK) WHERE Articulo = @Articulo) = 0
UPDATE Art WITH (ROWLOCK) SET TieneMovimientos = 1 WHERE Articulo = @Articulo
IF NULLIF(RTRIM(@SubCuenta), '') IS NOT NULL
BEGIN
IF (SELECT TieneMovimientos FROM ArtSub WHERE Articulo = @Articulo AND SubCuenta = @SubCuenta) = 0
UPDATE ArtSub WITH (ROWLOCK) SET TieneMovimientos = 1 WHERE Articulo = @Articulo AND SubCuenta = @SubCuenta
END
IF @MovTipo IN ('VTAS.N', 'VTAS.NO', 'VTAS.NR', 'VTAS.FM', 'VTAS.F', 'COMS.F', 'COMS.FL', 'COMS.EG', 'COMS.EI')
EXEC spArtUlt @Articulo, @FechaEmision, @Modulo, @MovTipo, @ID
END
IF @EsEntrada = 1 OR @EsSalida = 1 OR @EsTransferencia = 1
BEGIN
EXEC spRegistrarArtAlm @Empresa, @Articulo, @SubCuenta, @Almacen, @FechaEmision
IF @AlmacenDestino IS NOT NULL
EXEC spRegistrarArtAlm @Empresa, @Articulo, @SubCuenta, @AlmacenDestino, @FechaEmision
END
IF @MovTipo = 'PROD.O' AND @Centro IS NOT NULL
BEGIN
IF (SELECT TieneMovimientos FROM Centro WITH (NOLOCK) WHERE Centro = @Centro) = 0
UPDATE Centro WITH (ROWLOCK) SET TieneMovimientos = 1 WHERE Centro = @Centro
END
IF @Modulo = 'VTAS' AND @Mov = @CfgIngresoMov
BEGIN
IF @Accion = 'CANCELAR'
BEGIN
SELECT @EspacioDAnterior = NULL
IF @AplicaMov = @CfgIngresoMov
SELECT @EspacioDAnterior = MIN(d.Espacio)
FROM VentaD d WITH (NOLOCK), Venta v WITH (NOLOCK)
WHERE v.Empresa = @Empresa AND v.Mov = @AplicaMov AND v.MovID = @AplicaMovID AND v.Estatus IN ('CONCLUIDO', 'PENDIENTE')
AND d.ID = v.ID AND d.Articulo = @Articulo AND d.SubCuenta = @SubCuenta AND d.Espacio IS NOT NULL
UPDATE Cte WITH (ROWLOCK) SET Espacio = NULLIF(RTRIM(@EspacioDAnterior), '') WHERE Cliente = @ClienteProv
END ELSE
IF @EspacioD IS NULL
SELECT @Ok = 10210
ELSE
UPDATE Cte WITH (ROWLOCK) SET Espacio = @EspacioD WHERE Cliente = @ClienteProv
END
IF @MovTipo = 'INV.IF' AND @Accion = 'AFECTAR' AND @Estatus IN ('SINAFECTAR', 'CONFIRMAR', 'BORRADOR')
EXEC spArtAlmABC @Articulo, @Almacen, @FechaEmision, @CfgDiasHabiles, @CfgABCDiasHabiles
IF @Ok IS NULL
EXEC xpInvAfectarDetalle @ID, @Accion, @Base, @Empresa, @Usuario, @Modulo, @Mov, @MovID, @MovTipo,
@MovMoneda, @MovTipoCambio, @Estatus, @EstatusNuevo, @FechaEmision, @FechaRegistro, @FechaAfectacion, @Conexion, @SincroFinal, @Sucursal,
@Renglon, @RenglonSub, @Articulo, @Cantidad, @Importe, @ImporteNeto, @Impuestos, @ImpuestosNetos,
@Ok OUTPUT, @OkRef OUTPUT
SELECT @Retencion = 0.0, @Retencion2 = 0.0, @Retencion3 = 0.0
IF @Modulo = 'VTAS' AND @Ok IS NULL
EXEC xpVentaRetencionCalcular @ID, @Accion, @Empresa, @Usuario, @Modulo, @Mov, @MovID, @MovTipo, @MovMoneda, @MovTipoCambio, @ClienteProv,
@Renglon, @RenglonSub, @Articulo, @Cantidad, @Importe, @ImporteNeto, @Impuestos, @ImpuestosNetos,
@Retencion OUTPUT, @BorrarRetencionCx OUTPUT, @Ok OUTPUT, @OkRef OUTPUT
IF @MovTipo IN ('COMS.F','COMS.FL','COMS.EG', 'COMS.EI', 'COMS.D')
SELECT @Retencion  = (@ImporteNeto * (@MovRetencion1 / 100.0)),
@Retencion2 = (@ImporteNeto * (@MovRetencion2 / 100.0)) ,
@Retencion3 = (@ImporteNeto * (@MovRetencion3 / 100.0))
/*          IF @MovImpuesto = 1
UPDATE #MovImpuesto
SET Importe1 = @Impuesto1Neto * Factor,
Importe2 = @Impuesto2Neto * Factor,
Importe3 = @Impuesto3Neto * Factor,
SubTotal = @ImporteNeto * Factor
WHERE Renglon = @Renglon AND RenglonSub = @RenglonSub */
SELECT @SumaPendiente       = @SumaPendiente 	     + ISNULL(@CantidadPendiente, 0.0),
@SumaReservada	      = @SumaReservada	     + ISNULL(@CantidadReservada, 0.0),
@SumaOrdenada	      = @SumaOrdenada	     + ISNULL(@CantidadOrdenada, 0.0),
@SumaImporte         = @SumaImporte         + @Importe,
@SumaImporteNeto     = @SumaImporteNeto     + @ImporteNeto,
@ComisionImporteNeto = @ComisionImporteNeto + @ImporteNeto,
@SumaImpuestos       = @SumaImpuestos 	     + @Impuestos,
@SumaImpuestosNetos  = @SumaImpuestosNetos  + @ImpuestosNetos,
@SumaImpuesto1Neto   = @SumaImpuesto1Neto   + @Impuesto1Neto,
@SumaImpuesto2Neto   = @SumaImpuesto2Neto   + @Impuesto2Neto,
@SumaImpuesto3Neto   = @SumaImpuesto3Neto   + @Impuesto3Neto,
@SumaCostoLinea      = @SumaCostoLinea      + ROUND(@Costo * @Cantidad, @RedondeoMonetarios),
@SumaPrecioLinea     = @SumaPrecioLinea     + ROUND(@Precio * @Cantidad, @RedondeoMonetarios),
@SumaDescuentoLinea  = @SumaDescuentoLinea  + @DescuentoLineaImporte,
@SumaPeso	      = @SumaPeso            + (@Cantidad * @Peso * @Factor),
@SumaVolumen	      = @SumaVolumen         + (@Cantidad * @Volumen * @Factor),
@SumaComision	      = @SumaComision        + ISNULL(@ImporteComision, 0.0),
@ComisionAcum	      = @ComisionAcum        + ISNULL(@ImporteComision, 0.0)*@ComisionFactor,
@SumaRetencion	      = @SumaRetencion	     + ISNULL(@Retencion, 0.0),
@SumaRetencion2      = @SumaRetencion2	     + ISNULL(@Retencion2, 0.0),
@SumaRetencion3      = @SumaRetencion3	     + ISNULL(@Retencion3, 0.0)
END 
IF @Ok IS NOT NULL AND @OkRef IS NULL
BEGIN
SELECT @OkRef = 'Articulo: '+@Articulo
IF @SubCuenta IS NOT NULL SELECT @OkRef = @OkRef+ ' ('+@SubCuenta+')'
END
IF @Ok IS NULL
BEGIN
IF @Modulo = 'VTAS' FETCH NEXT FROM crVentaDetalle  INTO @Renglon, @RenglonSub, @RenglonID, @RenglonTipo, @CantidadOriginal, @CantidadObsequio, @CantidadInventario, @CantidadReservada, @CantidadOrdenada, @CantidadPendiente, @CantidadA, @Factor, @MovUnidad, @Articulo, @Subcuenta, @Costo, @Precio, @DescuentoTipo, @DescuentoLinea, @Impuesto1, @Impuesto2, @Impuesto3, @AplicaMov, @AplicaMovID, @AlmacenRenglon, @AgenteRenglon, @ArtTipo, @ArtSerieLoteInfo, @ArtTipoOpcion, @Peso, @Volumen, @ArtUnidad, @UltReservadoCantidad, @UltReservadoFecha, @ArtComision, @EspacioD, @ArtLotesFijos, @ArtActividades, @ArtCostoIdentificado, @ArtCostoUEPS, @ArtCostoPEPS, @ArtUltimoCosto, @ArtPrecioLista, @PrecioTipoCambio, @Posicion, @ArtDepartamentoDetallista, @ArtEstatus, @ArtSituacion, @ArtExcento1, @ArtExcento2, @ArtExcento3  ELSE
IF @Modulo = 'COMS' FETCH NEXT FROM crCompraDetalle INTO @Renglon, @RenglonSub, @RenglonID, @RenglonTipo, @CantidadOriginal, @CantidadInventario, @CantidadReservada, @CantidadOrdenada, @CantidadPendiente, @CantidadA, @Factor, @MovUnidad, @Articulo, @Subcuenta, @Costo, @Precio, @DescuentoTipo, @DescuentoLinea, @Impuesto1, @Impuesto2, @Impuesto3, @AplicaMov, @AplicaMovID, @AlmacenRenglon, @ServicioArticulo, @ServicioSerie, @ArtTipo, @ArtSerieLoteInfo, @ArtTipoOpcion, @Peso, @Volumen, @ArtUnidad, @MovRetencion1, @MovRetencion2, @MovRetencion3, @ArtLotesFijos, @ArtActividades, @ArtCostoIdentificado, @ArtCostoUEPS, @ArtCostoPEPS, @ArtUltimoCosto, @ArtPrecioLista, @Posicion, @ArtDepartamentoDetallista, @ArtEstatus, @ArtSituacion, @ArtExcento1, @ArtExcento2, @ArtExcento3  ELSE
IF @Modulo = 'INV'  FETCH NEXT FROM crInvDetalle    INTO @Renglon, @RenglonSub, @RenglonID, @RenglonTipo, @CantidadOriginal, @CantidadInventario, @CantidadReservada, @CantidadOrdenada, @CantidadPendiente, @CantidadA, @Factor, @MovUnidad, @Articulo, @Subcuenta, @Costo, @Precio, @DescuentoTipo, @DescuentoLinea, @Impuesto1, @Impuesto2, @Impuesto3, @AplicaMov, @AplicaMovID, @AlmacenRenglon, @ProdSerieLote, @ArtTipo, @ArtSerieLoteInfo, @ArtTipoOpcion, @Peso, @Volumen, @ArtUnidad, @UltReservadoCantidad, @UltReservadoFecha, @DetalleTipo, @Producto, @SubProducto, @ArtLotesFijos, @ArtActividades, @ArtCostoIdentificado, @ArtCostoUEPS, @ArtCostoPEPS, @ArtUltimoCosto, @ArtPrecioLista, @Posicion, @ArtDepartamentoDetallista, @ArtEstatus, @ArtSituacion, @ArtExcento1, @ArtExcento2, @ArtExcento3  ELSE
IF @Modulo = 'PROD' FETCH NEXT FROM crProdDetalle   INTO @Renglon, @RenglonSub, @RenglonID, @RenglonTipo, @CantidadOriginal, @CantidadInventario, @CantidadReservada, @CantidadOrdenada, @CantidadPendiente, @CantidadA, @Factor, @MovUnidad, @Articulo, @Subcuenta, @Costo, @Precio, @DescuentoTipo, @DescuentoLinea, @Impuesto1, @Impuesto2, @Impuesto3, @AplicaMov, @AplicaMovID, @AlmacenRenglon, @ProdSerieLote, @ArtTipo, @ArtSerieLoteInfo, @ArtTipoOpcion, @Peso, @Volumen, @ArtUnidad, @UltReservadoCantidad, @UltReservadoFecha, @DetalleTipo, @Merma, @Desperdicio, @Ruta, @Orden, @Centro, @ArtLotesFijos, @ArtActividades, @ArtCostoIdentificado, @ArtCostoUEPS, @ArtCostoPEPS, @ArtUltimoCosto, @ArtPrecioLista, @Posicion, @ArtDepartamentoDetallista, @ArtEstatus, @ArtSituacion, @ArtExcento1, @ArtExcento2, @ArtExcento3
IF @@ERROR <> 0 SELECT @Ok = 1
END
END  
/*IF @UsaCacheCostos = 1 AND @Ok IS NULL
BEGIN
SELECT @UsaCacheCostos = 0
IF @AlmacenTipo = 'ACTIVOS FIJOS' SELECT @AfectarRama = 'AF' ELSE SELECT @AfectarRama = 'INV'
EXEC spSaldo @Sucursal, @Accion, @Empresa, @Usuario, @AfectarRama, @UltArtMoneda, @UltArtTipoCambio, @UltArticulo, NULL, NULL, NULL,
@Modulo, @ID, @Mov, @MovID, @UltEsCargo, @UltCostoInvTotal, NULL, NULL,
@FechaAfectacion, @Ejercicio, @Periodo, @UltAplica, @UltAplicaID, 0, 0, 0,
@Ok OUTPUT, @OkRef OUTPUT, @Renglon = @Renglon, @RenglonSub = @RenglonSub, @RenglonID = @RenglonID
END*/
IF @Modulo = 'VTAS' BEGIN CLOSE crVentaDetalle  DEALLOCATE crVentaDetalle  END ELSE
IF @Modulo = 'COMS' BEGIN CLOSE crCompraDetalle DEALLOCATE crCompraDetalle END ELSE
IF @Modulo = 'INV'  BEGIN CLOSE crInvDetalle    DEALLOCATE crInvDetalle    END ELSE
IF @Modulo = 'PROD' BEGIN CLOSE crProdDetalle   DEALLOCATE crProdDetalle   END
END 
IF @Modulo = 'VTAS' AND @Ok IS NULL
EXEC xpVentaRetencionTotalCalcular @ID, @Accion, @Empresa, @Usuario, @Modulo, @Mov, @MovID, @MovTipo, @MovMoneda, @MovTipoCambio, @ClienteProv,
@SumaImpuesto1Neto, @SumaImpuesto2Neto, @SumaImpuesto3Neto,
@SumaRetencion OUTPUT, @SumaRetencion2 OUTPUT, @Ok OUTPUT, @OkRef OUTPUT, @SumaRetencion3 = @SumaRetencion3 OUTPUT
IF @MovImpuesto = 1
BEGIN
DELETE MovImpuesto WHERE Modulo = @Modulo AND ModuloID = @ID
INSERT MovImpuesto (
Modulo,  ModuloID, OrigenModulo, OrigenModuloID, OrigenConcepto, OrigenFecha,   Retencion1, Retencion2, Retencion3, Excento1, Excento2, Excento3, Impuesto1, Impuesto2, Impuesto3, LoteFijo, Importe1,      Importe2,      Importe3,      SubTotal)
SELECT @Modulo, @ID,      @Modulo,      @ID,            @Concepto,      @FechaEmision, Retencion1, Retencion2, Retencion3, Excento1, Excento2, Excento3, Impuesto1, Impuesto2, Impuesto3, LoteFijo, SUM(Importe1), SUM(Importe2), SUM(Importe3), SUM(SubTotal)
FROM #MovImpuesto
GROUP BY Retencion1, Retencion2, Retencion3, Excento1, Excento2, Excento3, Impuesto1, Impuesto2, Impuesto3, LoteFijo
ORDER BY Retencion1, Retencion2, Retencion3, Excento1, Excento2, Excento3, Impuesto1, Impuesto2, Impuesto3, LoteFijo
END
IF @PPTO = 1 AND @Accion <> 'CANCELAR' AND (@Modulo = 'COMS' OR (@Modulo = 'VTAS' AND @PPTOVentas = 1))
EXEC spModuloAgregarMovPresupuesto @Modulo, @ID, @Ok OUTPUT, @OkRef OUTPUT
IF @AfectarMatando = 1 AND @Utilizar = 0 AND @MatarAntes = 0 AND @Ok IS NULL
EXEC spInvMatar @Sucursal, @ID, @Accion, @Base, @Empresa, @Usuario, @Modulo, @Mov, @MovID, @MovTipo,
@Estatus, @EstatusNuevo, @FechaEmision, @FechaRegistro, @FechaAfectacion, @Ejercicio, @Periodo, @AfectarConsignacion, @AlmacenTipo, @AlmacenDestinoTipo,
@CfgVentaSurtirDemas, @CfgCompraRecibirDemas, @CfgTransferirDemas, @CfgBackOrders, @CfgContX, @CfgContXGenerar, @CfgEmbarcar, @CfgImpInc, @CfgMultiUnidades, @CfgMultiUnidadesNivel,
@Ok OUTPUT, @OkRef OUTPUT,
@CfgPrecioMoneda = @CfgPrecioMoneda
IF @Ok IS NULL
BEGIN
SELECT @ImporteTotal = @SumaImporteNeto + @SumaImpuestosNetos
IF @Modulo = 'VTAS'
BEGIN
SELECT @ImporteTotal = ROUND(@ImporteTotal, @CfgVentaRedondeoDecimales)
SELECT @SumaImporteNeto = @SumaImporteNeto - (@SumaImporteNeto + @SumaImpuestosNetos - @ImporteTotal)
END
IF @AnticiposFacturados > 0.0
BEGIN
SELECT @AnticipoImporte    = @SumaImporteNeto * @AnticiposFacturados / @ImporteTotal
SELECT @AnticipoImpuestos  = @AnticiposFacturados - @AnticipoImporte
END ELSE
SELECT @AnticipoImporte = 0.0, @AnticipoImpuestos = 0.0
SELECT @ImporteCx      = @SumaImporteNeto    - @AnticipoImporte,
@ImpuestosCx    = @SumaImpuestosNetos - @AnticipoImpuestos,
@RetencionCx    = @SumaRetencion,
@Retencion2Cx   = @SumaRetencion2,
@Retencion3Cx   = @SumaRetencion3,
@ImporteTotalCx = @ImporteTotal       - @AnticiposFacturados
SELECT @SumaRetenciones = ISNULL(@SumaRetencion, 0.0) + ISNULL(@SumaRetencion2, 0.0) + ISNULL(@SumaRetencion3, 0.0)
IF @Utilizar = 1 AND @ImporteTotal > 0.0 AND @UtilizarMovTipo IN ('VTAS.P','VTAS.R','VTAS.S','VTAS.VC','VTAS.VCR', 'COMS.O', 'COMS.OP', 'COMS.CC')
BEGIN
IF @Modulo = 'VTAS' UPDATE  Venta  WITH (ROWLOCK) SET Saldo = Saldo - @ImporteTotal /*@ImporteCx*/      WHERE ID = @UtilizarID ELSE
IF @Modulo = 'COMS' UPDATE  Compra WITH (ROWLOCK) SET Saldo = Saldo - @ImporteTotal /*@SumaImporteNeto*/ WHERE ID = @UtilizarID
IF @@ERROR <> 0 SELECT @Ok = 1
END
IF (@Estatus IN ('SINAFECTAR','CONFIRMAR','BORRADOR') AND @AfectarDetalle = 1) OR (@MovTipo IN ('COMS.D', 'COMS.B', 'COMS.CA', 'COMS.GX'))
BEGIN
SELECT @Paquetes = NULL
IF @Modulo = 'VTAS' AND @MovTipo NOT IN ('VTAS.PR', 'VTAS.EST', 'VTAS.C', 'VTAS.CS', 'VTAS.P', 'VTAS.S', 'VTAS.SD')
BEGIN
SELECT @Paquetes = ISNULL(COUNT(DISTINCT Paquete), 0) FROM VentaD WITH (NOLOCK) WHERE ID = @ID
SELECT @Paquetes = @Paquetes + ISNULL(ROUND(SUM(Cantidad), 0), 0) FROM VentaD WITH (NOLOCK) WHERE ID = @ID AND NULLIF(Paquete, 0) IS NULL
END ELSE
IF @Modulo = 'INV'  AND @MovTipo NOT IN ('INV.SOL', 'INV.OT', 'INV.OT', 'INV.IF')
BEGIN
SELECT @Paquetes = ISNULL(COUNT(DISTINCT Paquete) ,0) FROM InvD WITH (NOLOCK) WHERE ID = @ID
SELECT @Paquetes = @Paquetes + ISNULL(ROUND(SUM(Cantidad), 0), 0) FROM InvD WITH (NOLOCK) WHERE ID = @ID AND NULLIF(Paquete, 0) IS NULL
END ELSE
IF @Modulo = 'COMS'  AND @MovTipo NOT IN ('COMS.R', 'COMS.C', 'COMS.O', 'COMS.OP', 'COMS.OG', 'COMS.OD', 'COMS.OI')
BEGIN
SELECT @Paquetes = ISNULL(COUNT(DISTINCT Paquete) ,0) FROM InvD WITH (NOLOCK) WHERE ID = @ID
SELECT @Paquetes = @Paquetes + ISNULL(ROUND(SUM(Cantidad), 0), 0) FROM CompraD WITH (NOLOCK) WHERE ID = @ID AND NULLIF(Paquete, 0) IS NULL
END
SELECT @IVAFiscal = CONVERT(float, @SumaImpuesto1Neto) / NULLIF(@ImporteTotal-@SumaRetenciones, 0),
@IEPSFiscal = CONVERT(float, @SumaImpuesto2Neto) / NULLIF(@ImporteTotal-@SumaRetenciones, 0)
IF @Modulo = 'VTAS' UPDATE Venta  WITH (ROWLOCK) SET Peso = @SumaPeso, Volumen = @SumaVolumen, Paquetes = @Paquetes, Importe = @SumaImporte, Impuestos = @SumaImpuestosNetos, IVAFiscal = @IVAFiscal, IEPSFiscal = @IEPSFiscal, Saldo = CASE WHEN @EstatusNuevo IN ('PENDIENTE', 'PROCESAR') THEN @ImporteTotal /*@ImporteCx*/ ELSE NULL END, DescuentoLineal = @SumaDescuentoLinea, ComisionTotal = @SumaComision, PrecioTotal = @SumaPrecioLinea, CostoTotal = @SumaCostoLinea, Retencion = NULLIF(@SumaRetenciones, 0.0) WHERE ID = @ID ELSE
IF @Modulo = 'COMS' UPDATE Compra WITH (ROWLOCK) SET Peso = @SumaPeso, Volumen = @SumaVolumen, Paquetes = @Paquetes, Importe = @SumaImporte, Impuestos = @SumaImpuestosNetos, IVAFiscal = @IVAFiscal, IEPSFiscal = @IEPSFiscal, Saldo = CASE WHEN @EstatusNuevo IN ('PENDIENTE', 'PROCESAR') THEN @ImporteTotal /*@SumaImporteNeto*/ ELSE NULL END, DescuentoLineal = @SumaDescuentoLinea WHERE ID = @ID ELSE
IF @Modulo = 'INV'  UPDATE Inv    WITH (ROWLOCK) SET Peso = @SumaPeso, Volumen = @SumaVolumen, Paquetes = @Paquetes, Importe = @SumaCostoLinea WHERE ID = @ID ELSE
IF @Modulo = 'PROD' UPDATE Prod   WITH (ROWLOCK) SET Peso = @SumaPeso, Volumen = @SumaVolumen, Paquetes = @Paquetes, Importe = @SumaCostoLinea WHERE ID = @ID
IF @@ERROR <> 0 SELECT @Ok = 1
END ELSE
EXEC spInvReCalcEncabezado @ID, @Modulo, @CfgImpInc, @CfgMultiUnidades, @DescuentoGlobal, @SobrePrecio,
@CfgPrecioMoneda = @CfgPrecioMoneda
/*IF @MovTipo = 'COMS.R' AND @Accion = 'AFECTAR'
UPDATE Compra SET Proveedor = NULL WHERE ID = @ID*/
IF @MovTipo = 'INV.IF' AND @EstatusNuevo = 'CONCLUIDO'
EXEC spInvInventarioFisico @Sucursal, @ID, @Empresa, @Almacen, @IDGenerar, @Base, @CfgSeriesLotesMayoreo, @Estatus, @Ok OUTPUT, @OkRef OUTPUT
IF @MovTipo = 'VTAS.S' AND @Estatus = 'CONFIRMAR' AND @EstatusNuevo IN ('PENDIENTE', 'CANCELADO')
BEGIN
SELECT @CotizacionID = ID FROM Venta WITH (NOLOCK) WHERE Empresa = @Empresa AND OrigenTipo = 'VTAS' AND Origen = @Mov AND OrigenID = @MovID AND Estatus NOT IN ('SINAFECTAR', 'CANCELADO')
SELECT @CotizacionEstatusNuevo = CASE WHEN @Accion = 'CANCELAR' THEN 'CANCELADO' ELSE 'CONCLUIDO' END
EXEC spValidarTareas @Empresa, @Modulo, @CotizacionID, @CotizacionEstatusNuevo, @Ok OUTPUT, @OkRef OUTPUT
UPDATE Venta WITH (ROWLOCK) SET Estatus = @CotizacionEstatusNuevo WHERE ID = @CotizacionID
END
IF @@ERROR <> 0 SELECT @Ok = 1
IF @Estatus IN ('SINAFECTAR','AUTORIZARE','CONFIRMAR','BORRADOR') OR @Accion = 'CANCELAR'
BEGIN
IF @Accion <> 'CANCELAR'
BEGIN
IF @MovTipo = 'VTAS.FR'
SELECT @Vencimiento = ISNULL(CASE WHEN ConVigencia = 1 THEN VigenciaDesde END, @FechaEmision) FROM Venta WITH (NOLOCK) WHERE ID = @ID
ELSE
EXEC spCalcularVencimiento @Modulo, @Empresa, @ClienteProv, @Condicion, @FechaEmision, @Vencimiento OUTPUT, @Dias OUTPUT, @Ok OUTPUT

--FOX
IF(@EnviarA = 76) --fox
BEGIN --fox
    Select @DAPeriodo = DAPeriodo From Condicion With(NoLock) where Condicion = @Condicion
	IF @DAPeriodo = 'QUINCENAL'
	BEGIN
		SET @Dia = DATEPART(dd, @Vencimiento)
		SET @MenosDias = DATEPART(dd, DATEADD(mm, 1, @Vencimiento)) 
		SET @MenosDias = (@Dia - @MenosDias) + 15
		IF @Dia <= 15 
		BEGIN
			SELECT @EsQuince = 1, @Vencimiento = DATEADD(dd, 15 - @Dia, @Vencimiento)
			SET @Vencimiento = DATEADD(dd, @CorteDias, @Vencimiento)
		END
		ELSE
		BEGIN
			IF @Dia >= 16 and @Dia <= 30
				BEGIN
					SELECT @EsQuince = 0, 
					@Vencimiento = DATEADD(dd, -DATEPART(dd, @Vencimiento), DATEADD(mm, 1, @Vencimiento))
					SET @Vencimiento = DATEADD(dd, @CorteDias, @Vencimiento)
				END
				ELSE
				BEGIN
					SELECT @EsQuince = 0, 
					@Vencimiento = DATEADD(dd, -DATEPART(dd, @Vencimiento), DATEADD(mm, 1, @Vencimiento))
					SET @Vencimiento = DATEADD(dd, @CorteDias +@MenosDias, @Vencimiento)
				END
		END -- else
	END --Periodo Quincenal
END--fox Canla 76


EXEC spExtraerFecha @Vencimiento OUTPUT
END
IF @MovTipo IN ('VTAS.P', 'VTAS.S', 'COMS.O') AND NULLIF(RTRIM(@Condicion), '') IS NOT NULL AND @EstatusNuevo <> 'CONFIRMAR'
IF (SELECT UPPER(ControlAnticipos) FROM Condicion WITH (NOLOCK) WHERE Condicion = @Condicion) IN ('ABIERTO', 'PLAZOS', 'FECHA REQUERIDA')
EXEC spGenerarAP @Sucursal, @Accion, @Empresa, @Modulo, @ID, @MovTipo, @FechaRegistro,
@Mov, @MovID, @MovMoneda, @MovTipoCambio, @Proyecto, @ClienteProv, @Referencia, @Condicion, @Vencimiento, @ImporteTotal,
@Ok OUTPUT, @OkRef OUTPUT
IF @MovTipo = 'VTAS.NO'
BEGIN
SELECT @EsCargo = 1
IF @Accion = 'CANCELAR' SELECT @EsCargo = ~@EsCargo
EXEC spSaldo @Sucursal, @Accion, @Empresa, @Usuario, 'CNO', @MovMoneda, @MovTipoCambio, @ClienteProv, NULL, NULL, NULL,
@Modulo, @ID, @Mov, @MovID, @EsCargo, @ImporteTotal, NULL, NULL,
@FechaAfectacion, @Ejercicio, @Periodo, 'Consumos', NULL, 0, 0, 0,
@Ok OUTPUT, @OkRef OUTPUT, @Renglon = @Renglon, @RenglonSub = @RenglonSub, @RenglonID = @RenglonID
END
END
IF (@Generar = 1 AND @GenerarAfectado = 1) OR (@Accion = 'CANCELAR' AND @Base <> 'TODO')
BEGIN
IF @Modulo = 'VTAS' SELECT @SumaPendiente = Sum(ROUND(ISNULL(CantidadPendiente, 0.0), 4)), @SumaReservada = Sum(ROUND(ISNULL(CantidadReservada, 0.0), 2)), @SumaOrdenada = Sum(ROUND(ISNULL(CantidadOrdenada, 0.0), 2)) FROM VentaD WITH (NOLOCK) WHERE ID = @ID ELSE
IF @Modulo = 'COMS' SELECT @SumaPendiente = Sum(ROUND(ISNULL(CantidadPendiente, 0.0), 4)) FROM CompraD WITH (NOLOCK) WHERE ID = @ID ELSE
IF @Modulo = 'INV'  SELECT @SumaPendiente = Sum(ROUND(ISNULL(CantidadPendiente, 0.0), 4)), @SumaReservada = Sum(ROUND(ISNULL(CantidadReservada, 0.0), 2)), @SumaOrdenada = Sum(ROUND(ISNULL(CantidadOrdenada, 0.0), 2)) FROM InvD   WITH (NOLOCK) WHERE ID = @ID ELSE
IF @Modulo = 'PROD' SELECT @SumaPendiente = Sum(ROUND(ISNULL(CantidadPendiente, 0.0), 4)), @SumaReservada = Sum(ROUND(ISNULL(CantidadReservada, 0.0), 2)), @SumaOrdenada = Sum(ROUND(ISNULL(CantidadOrdenada, 0.0), 2)) FROM ProdD  WITH (NOLOCK) WHERE ID = @ID
END
IF @MovTipo NOT IN ('INV.IF', 'PROD.A', 'PROD.R', 'PROD.E')
BEGIN
SELECT @TienePendientes = 0
IF @Modulo = 'VTAS' AND EXISTS(SELECT * FROM VentaD  WITH (NOLOCK) WHERE ID = @ID AND ((ISNULL(CantidadPendiente, 0.0) <> 0.0) OR (ISNULL(CantidadReservada, 0.0) <> 0.0) OR (ISNULL(CantidadOrdenada, 0.0) <> 0.0))) SELECT @TienePendientes = 1 ELSE
IF @Modulo = 'INV'  AND EXISTS(SELECT * FROM InvD    WITH (NOLOCK) WHERE ID = @ID AND ((ISNULL(CantidadPendiente, 0.0) <> 0.0) OR (ISNULL(CantidadReservada, 0.0) <> 0.0) OR (ISNULL(CantidadOrdenada, 0.0) <> 0.0))) SELECT @TienePendientes = 1 ELSE
IF @Modulo = 'PROD' AND EXISTS(SELECT * FROM ProdD   WITH (NOLOCK) WHERE ID = @ID AND ((ISNULL(CantidadPendiente, 0.0) <> 0.0) OR (ISNULL(CantidadReservada, 0.0) <> 0.0) OR (ISNULL(CantidadOrdenada, 0.0) <> 0.0))) SELECT @TienePendientes = 1 ELSE
IF @Modulo = 'COMS' AND EXISTS(SELECT * FROM CompraD WITH (NOLOCK) WHERE ID = @ID AND ISNULL(CantidadPendiente, 0.0) <> 0.0) SELECT @TienePendientes = 1
IF @EstatusNuevo <> 'PENDIENTE' AND @TienePendientes = 1 SELECT @EstatusNuevo = 'PENDIENTE'
IF @EstatusNuevo = 'PENDIENTE'  AND @TienePendientes = 0 SELECT @EstatusNuevo = 'CONCLUIDO'
END
IF @EstatusNuevo = 'CONCLUIDO' SELECT @FechaConclusion = @FechaEmision ELSE IF @EstatusNuevo <> 'CANCELADO' SELECT @FechaConclusion = NULL
IF @EstatusNuevo = 'CANCELADO' SELECT @FechaCancelacion = @FechaRegistro ELSE SELECT @FechaCancelacion = NULL
IF @CfgContX = 1 AND @CfgContXGenerar <> 'NO'
BEGIN
IF @Estatus NOT IN ('SINAFECTAR', 'BORRADOR', 'CONFIRMAR') AND @EstatusNuevo = 'CANCELADO'
BEGIN
IF @GenerarPoliza = 1 SELECT @GenerarPoliza = 0 ELSE SELECT @GenerarPoliza = 1
IF @MovTipo IN ('VTAS.F','VTAS.FAR', 'VTAS.FC', 'VTAS.FG', 'VTAS.FX') AND @Estatus = 'PENDIENTE' AND @CfgContXFacturasPendientes = 0
SELECT @GenerarPoliza = 0
END ELSE BEGIN
IF @MovTipo IN ('VTAS.F','VTAS.FAR', 'VTAS.FC', 'VTAS.FG', 'VTAS.FX') AND @CfgContXFacturasPendientes = 0
BEGIN
IF @EstatusNuevo = 'CONCLUIDO' SELECT @GenerarPoliza = 1
END ELSE
IF @Estatus IN ('SINAFECTAR', 'BORRADOR', 'CONFIRMAR') AND @EstatusNuevo <> 'CANCELADO' SELECT @GenerarPoliza = 1
END
END
EXEC spValidarTareas @Empresa, @Modulo, @ID, @EstatusNuevo, @Ok OUTPUT, @OkRef OUTPUT
IF @Modulo = 'VTAS' UPDATE Venta  WITH (ROWLOCK) SET Vencimiento = @Vencimiento,  Concepto = @Concepto, FechaConclusion = @FechaConclusion, FechaCancelacion = @FechaCancelacion, UltimoCambio = /*CASE WHEN UltimoCambio IS NULL THEN */@FechaRegistro /*ELSE UltimoCambio END*/, Estatus = @EstatusNuevo, Saldo = CASE WHEN @EstatusNuevo IN ('CONCLUIDO', 'CANCELADO') THEN NULL ELSE Saldo END, Situacion = CASE WHEN @Estatus<>@EstatusNuevo THEN NULL ELSE Situacion END, GenerarPoliza = @GenerarPoliza, Autorizacion = @Autorizacion, Mensaje = NULL WHERE ID = @ID ELSE
IF @Modulo = 'COMS' UPDATE Compra WITH (ROWLOCK) SET Vencimiento = @Vencimiento,  Concepto = @Concepto, FechaConclusion = @FechaConclusion, FechaCancelacion = @FechaCancelacion, UltimoCambio = /*CASE WHEN UltimoCambio IS NULL THEN */@FechaRegistro /*ELSE UltimoCambio END*/, Estatus = @EstatusNuevo, Saldo = CASE WHEN @EstatusNuevo IN ('CONCLUIDO', 'CANCELADO') THEN NULL ELSE Saldo END, Situacion = CASE WHEN @Estatus<>@EstatusNuevo THEN NULL ELSE Situacion END, GenerarPoliza = @GenerarPoliza, Autorizacion = @Autorizacion, Mensaje = NULL  WHERE ID = @ID ELSE
IF @Modulo = 'INV'  UPDATE Inv    WITH (ROWLOCK) SET Vencimiento = @Vencimiento,  Concepto = @Concepto, FechaConclusion = @FechaConclusion, FechaCancelacion = @FechaCancelacion, UltimoCambio = /*CASE WHEN UltimoCambio IS NULL THEN */@FechaRegistro /*ELSE UltimoCambio END*/, Estatus = @EstatusNuevo, Situacion = CASE WHEN @Estatus<>@EstatusNuevo THEN NULL ELSE Situacion END, GenerarPoliza = @GenerarPoliza, Autorizacion = @Autorizacion WHERE ID = @ID ELSE
IF @Modulo = 'PROD' UPDATE Prod   WITH (ROWLOCK) SET/*Vencimiento=@Vencimiento,*/ Concepto = @Concepto, FechaConclusion = @FechaConclusion, FechaCancelacion = @FechaCancelacion, UltimoCambio = /*CASE WHEN UltimoCambio IS NULL THEN */@FechaRegistro /*ELSE UltimoCambio END*/, Estatus = @EstatusNuevo, Situacion = CASE WHEN @Estatus<>@EstatusNuevo THEN NULL ELSE Situacion END, GenerarPoliza = @GenerarPoliza, Autorizacion = @Autorizacion WHERE ID = @ID
IF @@ERROR <> 0 SELECT @Ok = 1
EXEC spEmbarqueMov @Accion, @Empresa, @Modulo, @ID, @Mov, @MovID, @Estatus, @EstatusNuevo, @CfgEmbarcar, @Ok OUTPUT
IF @Accion = 'CANCELAR'
BEGIN
IF @EstatusNuevo = 'PENDIENTE'
BEGIN
IF @Modulo = 'VTAS' UPDATE Venta  WITH (ROWLOCK) SET Saldo = Saldo - @ImporteTotal /*@ImporteCx*/      WHERE ID = @ID ELSE
IF @Modulo = 'COMS' UPDATE Compra WITH (ROWLOCK) SET Saldo = Saldo - @ImporteTotal /*@SumaImporteNeto*/ WHERE ID = @ID
END ELSE
BEGIN
IF @Modulo = 'VTAS' UPDATE Venta  WITH (ROWLOCK) SET Saldo = NULL WHERE ID = @ID ELSE
IF @Modulo = 'COMS' UPDATE Compra WITH (ROWLOCK) SET Saldo = NULL WHERE ID = @ID
END
IF @@ERROR <> 0 SELECT @Ok = 1
END
IF @MovTipo IN ('VTAS.VC','VTAS.VCR','VTAS.DC','VTAS.DCR') AND @Accion <> 'CANCELAR'
BEGIN
UPDATE Venta WITH (ROWLOCK) SET AlmacenDestino = CASE WHEN @MovTipo IN ('VTAS.VC','VTAS.VCR') THEN @GenerarAlmacenDestino ELSE @GenerarAlmacen END WHERE ID = @ID
IF @@ERROR <> 0 SELECT @Ok = 1
END
IF @Utilizar = 1 AND @Ok IS NULL
BEGIN
SELECT @UtilizarEstatus = 'CONCLUIDO', @SumaPendiente = 0.0
IF @AfectarMatando = 1
BEGIN
IF @Modulo = 'VTAS' SELECT @SumaPendiente = Sum(ROUND(ISNULL(CantidadPendiente,0.0), 4)) + Sum(ROUND(ISNULL(CantidadReservada,0.0), 4)) FROM VentaD WITH (NOLOCK) WHERE ID = @UtilizarID ELSE
IF @Modulo = 'COMS' SELECT @SumaPendiente = Sum(ROUND(ISNULL(CantidadPendiente,0.0), 4)) FROM CompraD WITH (NOLOCK) WHERE ID = @UtilizarID ELSE
IF @Modulo = 'INV'  SELECT @SumaPendiente = Sum(ROUND(ISNULL(CantidadPendiente,0.0), 4)) + Sum(ROUND(ISNULL(CantidadReservada,0.0), 4)) FROM InvD   WITH (NOLOCK) WHERE ID = @UtilizarID ELSE
IF @Modulo = 'PROD' SELECT @SumaPendiente = Sum(ROUND(ISNULL(CantidadPendiente,0.0), 4)) + Sum(ROUND(ISNULL(CantidadReservada,0.0), 4)) FROM ProdD  WITH (NOLOCK) WHERE ID = @UtilizarID
IF @@ERROR <> 0 SELECT @Ok = 1
IF @SumaPendiente > 0.0 SELECT @UtilizarEstatus = 'PENDIENTE'
END
IF @UtilizarEstatus = 'CONCLUIDO' SELECT @FechaConclusion = @FechaEmision ELSE IF @UtilizarEstatus <> 'CANCELADO' SELECT @FechaConclusion = NULL
EXEC spValidarTareas @Empresa, @Modulo, @UtilizarID, @UtilizarEstatus, @Ok OUTPUT, @OkRef OUTPUT
IF @Modulo = 'VTAS' UPDATE Venta  WITH (ROWLOCK) SET FechaConclusion = @FechaConclusion, Estatus = @UtilizarEstatus WHERE ID = @UtilizarID ELSE
IF @Modulo = 'COMS' UPDATE Compra WITH (ROWLOCK) SET FechaConclusion = @FechaConclusion, Estatus = @UtilizarEstatus WHERE ID = @UtilizarID ELSE
IF @Modulo = 'INV'  UPDATE Inv    WITH (ROWLOCK) SET FechaConclusion = @FechaConclusion, Estatus = @UtilizarEstatus WHERE ID = @UtilizarID ELSE
IF @Modulo = 'PROD' UPDATE Prod   WITH (ROWLOCK) SET FechaConclusion = @FechaConclusion, Estatus = @UtilizarEstatus WHERE ID = @UtilizarID
IF @@ERROR <> 0 SELECT @Ok = 1
END
IF @Generar = 1 AND @Ok IS NULL
BEGIN
IF @GenerarAfectado = 1 SELECT @GenerarEstatus = 'CONCLUIDO' ELSE SELECT @GenerarEstatus = 'SINAFECTAR'
IF @GenerarEstatus = 'CONCLUIDO' SELECT @FechaConclusion = @FechaEmision ELSE IF @GenerarEstatus <> 'CANCELADO' SELECT @FechaConclusion = NULL
IF @UtilizarEstatus = 'CONCLUIDO' AND @CfgContX = 1 AND @CfgContXGenerar <> 'NO' SELECT @GenerarPolizaTemp = 1 ELSE SELECT @GenerarPolizaTemp = 0
EXEC spValidarTareas @Empresa, @Modulo, @IDGenerar, @GenerarEstatus, @Ok OUTPUT, @OkRef OUTPUT
IF @Modulo = 'VTAS' UPDATE Venta  WITH (ROWLOCK) SET FechaConclusion = @FechaConclusion, Estatus = @GenerarEstatus, GenerarPoliza = @GenerarPolizaTemp WHERE ID = @IDGenerar ELSE
IF @Modulo = 'COMS' UPDATE Compra WITH (ROWLOCK) SET FechaConclusion = @FechaConclusion, Estatus = @GenerarEstatus, GenerarPoliza = @GenerarPolizaTemp WHERE ID = @IDGenerar ELSE
IF @Modulo = 'INV'  UPDATE Inv    WITH (ROWLOCK) SET FechaConclusion = @FechaConclusion, Estatus = @GenerarEstatus, GenerarPoliza = @GenerarPolizaTemp WHERE ID = @IDGenerar ELSE
IF @Modulo = 'PROD' UPDATE Prod   WITH (ROWLOCK) SET FechaConclusion = @FechaConclusion, Estatus = @GenerarEstatus, GenerarPoliza = @GenerarPolizaTemp WHERE ID = @IDGenerar
IF @@ERROR <> 0 SELECT @Ok = 1
EXEC xpInvGenerarFinal @Empresa, @Usuario, @Accion, @Modulo, @ID, @IDGenerar, @GenerarEstatus, @Ok OUTPUT, @OkRef OUTPUT
END
IF @MovTipo = 'VTAS.S' AND NULLIF(RTRIM(@ServicioSerie), '') IS NOT NULL
BEGIN
EXEC spSerieLoteFlujo @Sucursal, @SucursalAlmacen, @SucursalAlmacenDestino, @Accion, @Empresa, @Modulo, @ID, @ServicioArticulo, NULL, @ServicioSerie, @Almacen, 0
END
SELECT @Continuar = 1, @CxID = NULL, @CxMovTipo = NULL
IF (@FacturarVtasMostrador = 1 AND @Accion <> 'CANCELAR') OR (@Accion ='CANCELAR' AND @MovTipo IN ('VTAS.F','VTAS.FAR','VTAS.FB') AND @OrigenTipo = 'VMOS')
BEGIN
SELECT @Continuar = 0
EXEC spInvReCalcEncabezado @ID, @Modulo, @CfgImpInc, @CfgMultiUnidades, @DescuentoGlobal, @SobrePrecio,
@CfgPrecioMoneda = @CfgPrecioMoneda
IF @MovTipo IN ('VTAS.F','VTAS.FAR','VTAS.FB')
BEGIN
EXEC spInvMatarNotas @Sucursal, @ID, @Accion, @Empresa, @Usuario, @Modulo, @Mov, @MovID, @FechaAfectacion, @Ejercicio, @Periodo, @Ok OUTPUT, @OkRef OUTPUT, @AfectandoNotasSinCobro OUTPUT
SELECT @Continuar = @AfectandoNotasSinCobro
END
END
IF @MovTipo = 'VTAS.FB' AND @Accion in ('AFECTAR', 'CANCELAR')
BEGIN
EXEC spMovTipoInstruccionBit @Modulo, @Mov, 'IncrementaSaldoTarjeta', @IncrementaSaldoTarjeta OUTPUT, @Ok OUTPUT, @OkRef OUTPUT
IF @IncrementaSaldoTarjeta = 1
EXEC spIncrementaSaldoTarjeta @Empresa, @ID, @Mov, @MovID, @Modulo, @Ejercicio, @Periodo, @Accion, @FechaEmision, @MovMoneda, @MovTipoCambio, @Ok OUTPUT, @OkRef OUTPUT
END
IF @Continuar = 1 AND (@Estatus IN ('SINAFECTAR', 'BORRADOR', 'CONFIRMAR') OR @EstatusNuevo = 'CANCELADO') AND @Ok IS NULL
BEGIN
IF @Accion = 'CANCELAR'
BEGIN
IF @CfgCompraAutoCargos = 1 AND @MovTipo IN ('COMS.F', 'COMS.FL', 'COMS.EG', 'COMS.EI', 'COMS.D', 'COMS.B') AND @Ok IS NULL
EXEC xpCompraAutoCargos @Sucursal, @SucursalOrigen, @SucursalDestino, @Accion, @Modulo, @Empresa, @ID, @Mov,
@MovID, @MovTipo, @MovMoneda, @MovTipoCambio, @FechaEmision , @Concepto, @Proyecto,
@Usuario, @Autorizacion, @Referencia, @DocFuente, @Observaciones, @FechaRegistro, @Ejercicio, @Periodo,
@Condicion, @Vencimiento, @ClienteProv, @SumaImporteNeto, @SumaImpuestosNetos, @VIN, @Ok OUTPUT, @OkRef OUTPUT
IF @CfgVentaAutoBonif = 1 AND @MovTipo IN ('VTAS.F','VTAS.FAR', 'VTAS.D', 'VTAS.DF', 'VTAS.B') AND @Ok IS NULL
EXEC xpVentaAutoBonif @Sucursal, @SucursalOrigen, @SucursalDestino, @Accion, @Modulo, @Empresa, @ID, @Mov,
@MovID, @MovTipo, @MovMoneda, @MovTipoCambio, @FechaEmision , @Concepto, @Proyecto,
@Usuario, @Autorizacion, @Referencia, @DocFuente, @Observaciones, @FechaRegistro, @Ejercicio, @Periodo,
@Condicion, @Vencimiento, @ClienteProv, @CobroIntegrado, @SumaImporteNeto, @SumaImpuestosNetos, @VIN, @Ok OUTPUT, @OkRef OUTPUT
IF @MovTipo IN ('VTAS.F','VTAS.FAR') AND (SELECT CxcAutoAplicarAnticiposPedidos FROM EmpresaCfg2 WITH (NOLOCK) WHERE Empresa = @Empresa) = 1
BEGIN
SELECT @ReferenciaAplicacionAnticipo = RTRIM(@Origen) + ' ' + RTRIM(@OrigenID)
EXEC xpVentaAutoAplicarAnticiposPedidos @Sucursal, @SucursalOrigen, @SucursalDestino, @Accion, @Modulo, @Empresa, @ID, @Mov,
@MovID, @MovTipo, @MovMoneda, @MovTipoCambio, @FechaEmision , @Concepto, @Proyecto,
@Usuario, @Autorizacion, @ReferenciaAplicacionAnticipo, @DocFuente, @Observaciones, @FechaRegistro, @Ejercicio, @Periodo,
@Condicion, @Vencimiento, @ClienteProv, @CobroIntegrado, @SumaImporteNeto, @SumaImpuestosNetos, @VIN, @Ok OUTPUT, @OkRef OUTPUT
END
END
IF @Modulo = 'VTAS' AND @CobroIntegrado = 0
EXEC spBorrarVentaCobro @ID
IF @CobroIntegrado = 1
BEGIN
SELECT @DineroImporte = 0.0, @CobroDesglosado = 0.0, @CobroDelEfectivo = 0.0, @CobroCambio = 0.0, @ValesCobrados = 0.0, @CobroRedondeo = 0.0, @TarjetasCobradas = 0.0 	
SELECT @Importe1 = ISNULL(Importe1, 0.0), @Importe2 = ISNULL(Importe2, 0.0), @Importe3 = ISNULL(Importe3, 0.0), @Importe4 = ISNULL(Importe4, 0.0), @Importe5 = ISNULL(Importe5, 0.0),
@FormaCobro1 = RTRIM(FormaCobro1), @FormaCobro2 = RTRIM(FormaCobro2), @FormaCobro3 = RTRIM(FormaCobro3), @FormaCobro4 = RTRIM(FormaCobro4), @FormaCobro5 = RTRIM(FormaCobro5),
@Referencia1 = RTRIM(Referencia1), @Referencia2 = RTRIM(Referencia2), @Referencia3 = RTRIM(Referencia3), @Referencia4 = RTRIM(Referencia4), @Referencia5 = RTRIM(Referencia5),
@CobroDelEfectivo = ISNULL(DelEfectivo, 0.0), @CtaDinero = NULLIF(RTRIM(CtaDinero), ''), @Cajero = NULLIF(RTRIM(Cajero), ''),
@CobroRedondeo = ISNULL(Redondeo, 0.0)
FROM VentaCobro WITH (NOLOCK)
WHERE ID = @ID
EXEC spVentaCobroTotal @FormaCobro1, @FormaCobro2, @FormaCobro3, @FormaCobro4, @FormaCobro5,
@Importe1, @Importe2, @Importe3, @Importe4, @Importe5, @CobroDesglosado OUTPUT, @Moneda = @MovMoneda, @TipoCambio = @MovTipoCambio
SELECT @FormaCobroVales = CxcFormaCobroVales, @FormaCobroTarjetas = CxcFormaCobroTarjetas FROM EmpresaCfg WHERE Empresa = @Empresa
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
IF @CobroDesglosado + @CobroDelEfectivo <> 0.0
BEGIN
SELECT @CobroCambio = @CobroDesglosado + @CobroDelEfectivo - @ImporteTotalCx - @CobroRedondeo
IF ROUND(ABS(@CobroCambio), @RedondeoMonetarios) = 0.01 SELECT @CobroCambio = 0.0
IF @Accion <> 'CANCELAR'
UPDATE VentaCobro  WITH (ROWLOCK) SET Actualizado = 1, Cambio = @CobroCambio WHERE ID = @ID
SELECT @DineroImporte = @CobroDesglosado - @CobroCambio
END
END
IF @CobroIntegrado = 1 AND @CobroIntegradoCxc = 0 AND @CobroIntegradoParcial = 0 AND @OrigenTipo <> 'CR' AND @ImporteTotalCx <> 0.0 AND (@Estatus IN ('SINAFECTAR', 'CONFIRMAR', 'BORRADOR') OR @EstatusNuevo = 'CANCELADO') AND @Ok IS NULL
BEGIN
IF @ValesCobrados > 0.0 OR @TarjetasCobradas <> 0 
EXEC spValeAplicarCobro @Empresa, @Modulo, @ID, @TarjetasCobradas, @Accion, @FechaEmision, @Ok OUTPUT, @OkRef OUTPUT
IF @OK is null AND @TarjetasCobradas <> 0
EXEC spValeGeneraAplicacionTarjeta @Empresa, @Modulo, @ID, @Mov, @MovID, @Accion, @FechaEmision, @Usuario, @Sucursal,
@TarjetasCobradas, @CtaDinero, @MovMoneda, @MovTipoCambio, @Ok OUTPUT, @OkRef OUTPUT
IF @OK is null AND @Modulo = 'VTAS' AND @CfgVentaMonedero = 1 AND Exists(SELECT * FROM TarjetaSeriemov WHERE Empresa = @Empresa AND Modulo = @Modulo AND ID = @ID)
EXEC spVentaMonedero @Empresa, @Modulo, @ID, @Mov, @MovID, @MovTipo, @Accion, @FechaEmision,
@Ejercicio, @Periodo, @Usuario, @Sucursal, @MovMoneda, @MovTipoCambio,
@Ok OUTPUT, @OkRef OUTPUT
IF @CobroDelEfectivo <> 0.0
BEGIN
IF @MovTipo IN ('VTAS.VP', 'VTAS.SD') SELECT @EsCargo = 0 ELSE SELECT @EsCargo = 1
IF @Accion = 'CANCELAR' SELECT @EsCargo = ~@EsCargo
EXEC spSaldo @SucursalOrigen /*@Sucursal*/, @Accion, @Empresa, @Usuario, 'CEFE', @MovMoneda, @MovTipoCambio, @ClienteProv, NULL, NULL, NULL,
@Modulo, @ID, @Mov, @MovID, @EsCargo, @CobroDelEfectivo, NULL, NULL,
@FechaAfectacion, @Ejercicio, @Periodo, 'Saldo a Favor', NULL, 0, 0, 0,
@Ok OUTPUT, @OkRef OUTPUT
END
IF @DineroImporte <> 0.0
BEGIN
SELECT @CobroSumaEfectivo = 0.0
IF @Importe1 <> 0.0
BEGIN
EXEC spFormaPagoMonTC @FormaCobro1, @Referencia1, @MovMoneda, @MovTipoCambio, @Importe1, @CobroSumaEfectivo OUTPUT, @FormaMoneda OUTPUT, @FormaTipoCambio OUTPUT, @Ok OUTPUT, @FormaCobroVales
/* @Sucursal, @SucursalOrigen, @SucursalDestino */
EXEC spGenerarDinero @SucursalOrigen, @SucursalOrigen, @SucursalOrigen, @Accion, @Empresa, @Modulo, @ID, @Mov, @MovID, @MovTipo, @FormaMoneda, @FormaTipoCambio,
@FechaAfectacion, @Concepto, @Proyecto, @Usuario, @Autorizacion, @Referencia1, @DocFuente, @Observaciones, 0, 0,
@FechaRegistro, @Ejercicio, @Periodo,
@FormaCobro1, NULL, NULL,
@ClienteProv, @CtaDinero, @Cajero, @Importe1, NULL,
NULL, NULL, NULL,
@DineroMov OUTPUT, @DineroMovID OUTPUT,
@Ok OUTPUT, @OkRef OUTPUT
END
IF @Importe2 <> 0.0
BEGIN
EXEC spFormaPagoMonTC @FormaCobro2, @Referencia2, @MovMoneda, @MovTipoCambio, @Importe2, @CobroSumaEfectivo OUTPUT, @FormaMoneda OUTPUT, @FormaTipoCambio OUTPUT, @Ok OUTPUT, @FormaCobroVales
/* @Sucursal, @SucursalOrigen, @SucursalDestino */
EXEC spGenerarDinero @SucursalOrigen, @SucursalOrigen, @SucursalOrigen, @Accion, @Empresa, @Modulo, @ID, @Mov, @MovID, @MovTipo, @FormaMoneda, @FormaTipoCambio,
@FechaAfectacion, @Concepto, @Proyecto, @Usuario, @Autorizacion, @Referencia2, @DocFuente, @Observaciones, 0, 0,
@FechaRegistro, @Ejercicio, @Periodo,
@FormaCobro2, NULL, NULL,
@ClienteProv, @CtaDinero, @Cajero, @Importe2, NULL,
NULL, NULL, NULL,
@DineroMov OUTPUT, @DineroMovID OUTPUT,
@Ok OUTPUT, @OkRef OUTPUT
END
IF @Importe3 <> 0.0
BEGIN
EXEC spFormaPagoMonTC @FormaCobro3, @Referencia3, @MovMoneda, @MovTipoCambio, @Importe3, @CobroSumaEfectivo OUTPUT, @FormaMoneda OUTPUT, @FormaTipoCambio OUTPUT, @Ok OUTPUT, @FormaCobroVales
/* @Sucursal, @SucursalOrigen, @SucursalDestino */
EXEC spGenerarDinero @SucursalOrigen, @SucursalOrigen, @SucursalOrigen, @Accion, @Empresa, @Modulo, @ID, @Mov, @MovID, @MovTipo, @FormaMoneda, @FormaTipoCambio,
@FechaAfectacion, @Concepto, @Proyecto, @Usuario, @Autorizacion, @Referencia3, @DocFuente, @Observaciones, 0, 0,
@FechaRegistro, @Ejercicio, @Periodo,
@FormaCobro3, NULL, NULL,
@ClienteProv, @CtaDinero, @Cajero, @Importe3, NULL,
NULL, NULL, NULL,
@DineroMov OUTPUT, @DineroMovID OUTPUT,
@Ok OUTPUT, @OkRef OUTPUT
END
IF @Importe4 <> 0.0
BEGIN
EXEC spFormaPagoMonTC @FormaCobro4, @Referencia4, @MovMoneda, @MovTipoCambio, @Importe4, @CobroSumaEfectivo OUTPUT, @FormaMoneda OUTPUT, @FormaTipoCambio OUTPUT, @Ok OUTPUT, @FormaCobroVales
/* @Sucursal, @SucursalOrigen, @SucursalDestino */
EXEC spGenerarDinero @SucursalOrigen, @SucursalOrigen, @SucursalOrigen, @Accion, @Empresa, @Modulo, @ID, @Mov, @MovID, @MovTipo, @FormaMoneda, @FormaTipoCambio,
@FechaAfectacion, @Concepto, @Proyecto, @Usuario, @Autorizacion, @Referencia4, @DocFuente, @Observaciones, 0, 0,
@FechaRegistro, @Ejercicio, @Periodo,
@FormaCobro4, NULL, NULL,
@ClienteProv, @CtaDinero, @Cajero, @Importe4, NULL,
NULL, NULL, NULL,
@DineroMov OUTPUT, @DineroMovID OUTPUT,
@Ok OUTPUT, @OkRef OUTPUT
END
IF @Importe5 <> 0.0
BEGIN
EXEC spFormaPagoMonTC @FormaCobro5, @Referencia5, @MovMoneda, @MovTipoCambio, @Importe5, @CobroSumaEfectivo OUTPUT, @FormaMoneda OUTPUT, @FormaTipoCambio OUTPUT, @Ok OUTPUT, @FormaCobroVales
/* @Sucursal, @SucursalOrigen, @SucursalDestino */
EXEC spGenerarDinero @SucursalOrigen, @SucursalOrigen, @SucursalOrigen, @Accion, @Empresa, @Modulo, @ID, @Mov, @MovID, @MovTipo, @FormaMoneda, @FormaTipoCambio,
@FechaAfectacion, @Concepto, @Proyecto, @Usuario, @Autorizacion, @Referencia5, @DocFuente, @Observaciones, 0, 0,
@FechaRegistro, @Ejercicio, @Periodo,
@FormaCobro5, NULL, NULL,
@ClienteProv, @CtaDinero, @Cajero, @Importe5, NULL,
NULL, NULL, NULL,
@DineroMov OUTPUT, @DineroMovID OUTPUT,
@Ok OUTPUT, @OkRef OUTPUT
END
IF ROUND(@CobroCambio, 2) <> 0.0
BEGIN
IF ABS(ROUND(@CobroSumaEfectivo, 2)) < ABS(ROUND(@CobroCambio, 2)) SELECT @Ok = 30590
IF @Ok IS NULL
BEGIN
SELECT @FormaPagoCambio = FormaPagoCambio FROM EmpresaCfg WITH (NOLOCK) WHERE Empresa = @Empresa
SELECT @ImporteCambio = -@CobroCambio
EXEC spFormaPagoMonTC @FormaPagoCambio, NULL, @MovMoneda, @MovTipoCambio, @ImporteCambio, NULL, @FormaMoneda OUTPUT, @FormaTipoCambio OUTPUT, @Ok OUTPUT, @FormaCobroVales
/* @Sucursal, @SucursalOrigen, @SucursalDestino */
EXEC spGenerarDinero @SucursalOrigen, @SucursalOrigen, @SucursalOrigen, @Accion, @Empresa, @Modulo, @ID, @Mov, @MovID, @MovTipo, @FormaMoneda, @FormaTipoCambio,
@FechaAfectacion, @Concepto, @Proyecto, @Usuario, @Autorizacion, 'Cambio', @DocFuente, @Observaciones, 0, 0,
@FechaRegistro, @Ejercicio, @Periodo,
@FormaPagoCambio, NULL, NULL,
NULL, @CtaDinero, @Cajero, @ImporteCambio, NULL,
NULL, NULL, NULL,
@DineroMov OUTPUT, @DineroMovID OUTPUT,
@Ok OUTPUT, @OkRef OUTPUT
END
END
END
END ELSE
IF @ImporteTotalCx > 0.0 AND @Ok IS NULL AND @OrigenTipo <> 'CR' AND
(@MovTipo IN ('VTAS.FM', 'VTAS.N', 'VTAS.NO', 'VTAS.NR') AND @CobroIntegradoCxc = 1) OR
(@MovTipo IN ('VTAS.F','VTAS.FX','VTAS.FAR', 'VTAS.FB','VTAS.D','VTAS.DF') AND @CobrarPedido = 0 AND (@Estatus IN ('SINAFECTAR', 'CONFIRMAR', 'BORRADOR') OR @EstatusNuevo = 'CANCELADO')) OR
(@MovTipo IN ('VTAS.B', 'COMS.F','COMS.FL','COMS.EG', 'COMS.EI','COMS.D','COMS.B','COMS.CA', 'COMS.GX') AND @EstatusNuevo IN ('CONCLUIDO','PROCESAR','CANCELADO'))
BEGIN
IF /*@CfgRetencionAlPago = 0 OR*/ @BorrarRetencionCx = 1 SELECT @RetencionCx = 0.0, @Retencion2Cx = 0.0, @Retencion3Cx = 0.0
IF @MovTipo = 'COMS.EI'
EXEC spGenerarCxImportacion @Sucursal, @SucursalOrigen, @SucursalDestino, @Accion, NULL, @Empresa, @Modulo, @ID, @Mov, @MovID, @MovTipo, @MovMoneda, @MovTipoCambio,
@FechaAfectacion, @Concepto, @Proyecto, @Usuario, @Autorizacion, @Referencia, @DocFuente, @Observaciones,
@FechaRegistro, @Ejercicio, @Periodo,
@Condicion, @Vencimiento, @ClienteProv, @EnviarA, @Agente, NULL, NULL, NULL,
@ImporteCx, @ImpuestosCx, @RetencionCx, @SumaComision,
NULL, NULL, NULL, NULL, @VIN, NULL,
@CxModulo OUTPUT, @CxMov OUTPUT, @CxMovID OUTPUT,
@Ok OUTPUT, @OkRef OUTPUT, @INSTRUCCIONES_ESP = 'SIN_DOCAUTO', @IVAFiscal = @IVAFiscal, @IEPSFiscal = @IEPSFiscal, @Retencion2 = @Retencion2Cx, @Retencion3 = @Retencion3Cx
ELSE BEGIN
IF (@CobroIntegradoCxc = 1 OR @CobroIntegradoParcial = 1) AND @Accion = 'CANCELAR'
EXEC spCobroIntegradoCxcCancelar @Sucursal, @Accion, @Modulo, @Empresa, @Usuario, @ID, @Mov, @MovID, @FechaRegistro, @Ok OUTPUT, @OkRef OUTPUT
SELECT @CondicionCx = @Condicion, @VencimientoCx = @Vencimiento
IF @CobroIntegradoParcial = 1
SELECT @CondicionCx = Condicion, @VencimientoCx = Vencimiento FROM VentaCobro WITH (NOLOCK) WHERE ID = @ID
IF @CfgAC = 1 AND @Modulo = 'VTAS'
BEGIN
SELECT @LCMetodo = ta.Metodo, @LCPorcentajeResidual = ISNULL(lc.PorcentajeResidual, 0)
FROM Venta v WITH (NOLOCK)
JOIN TipoAmortizacion ta WITH (NOLOCK) ON ta.TipoAmortizacion = v.TipoAmortizacion
JOIN LC WITH (NOLOCK) ON lc.LineaCredito = v.LineaCredito
WHERE v.ID = @ID
EXEC xpPorcentajeResidual @Modulo, @ID, @LCPorcentajeResidual OUTPUT
/*IF @Accion = 'CANCELAR'
BEGIN
Falta Buscar los Ajustes y Cancelarlos
END*/
END
EXEC @CxID = spGenerarCx @Sucursal, @SucursalOrigen, @SucursalDestino, @Accion, NULL, @Empresa, @Modulo, @ID, @Mov, @MovID, @MovTipo, @MovMoneda, @MovTipoCambio,
@FechaAfectacion, @Concepto, @Proyecto, @Usuario, @Autorizacion, @Referencia, @DocFuente, @Observaciones,
@FechaRegistro, @Ejercicio, @Periodo,
@CondicionCx, @VencimientoCx, @ClienteProv, @EnviarA, @Agente, NULL, NULL, NULL,
@ImporteCx, @ImpuestosCx, @RetencionCx, @SumaComision,
NULL, NULL, NULL, NULL, @VIN, NULL,
@CxModulo OUTPUT, @CxMov OUTPUT, @CxMovID OUTPUT,
@Ok OUTPUT, @OkRef OUTPUT, @INSTRUCCIONES_ESP = 'SIN_DOCAUTO', @IVAFiscal = @IVAFiscal, @IEPSFiscal = @IEPSFiscal, @Retencion2 = @Retencion2Cx, @Retencion3 = @Retencion3Cx, @EndosarA = @EndosarA, @CopiarMovImpuesto = 1
IF (@CobroIntegradoCxc = 1 OR @CobroIntegradoParcial = 1) AND @Accion <> 'CANCELAR'
EXEC spCobroIntegradoCxc @Sucursal, @SucursalOrigen, @SucursalDestino, @Accion, @Modulo,
@Empresa, @Usuario, @ID, @Mov, @MovID, @MovTipo, @MovMoneda, @MovTipoCambio, @FechaRegistro,
@DineroImporte, @CobroDelEfectivo, @CobroCambio,
@FormaCobro1, @FormaCobro2, @FormaCobro3, @FormaCobro4, @FormaCobro5,
@Importe1, @Importe2, @Importe3, @Importe4, @Importe5,
@Referencia1, @Referencia2, @Referencia3, @Referencia4, @Referencia5,
@CtaDinero, @Cajero, @CxID, @Ok OUTPUT, @OkRef OUTPUT
IF @CfgAC = 1 AND @LCMetodo = 50 AND @Accion <> 'CANCELAR'
BEGIN
SELECT @CxAjusteImporte = @ImporteCx * (@LCPorcentajeResidual/100.0)
IF @CxAjusteImporte > 0.0
BEGIN
SELECT @CxAjusteMov = ACAjusteValorResidual FROM EmpresaCfgMov WITH (NOLOCK) WHERE Empresa = @Empresa
SELECT @CxConcepto = ACAjusteConceptoValorResidual FROM EmpresaCfg WITH (NOLOCK) WHERE Empresa = @Empresa
EXEC @CxAjusteID = spAfectar 'CXC', @CxID, 'GENERAR', 'TODO', @CxAjusteMov, @Usuario, @EnSilencio = 1, @Conexion = 1, @Ok = @Ok OUTPUT, @OkRef = @OkRef OUTPUT
IF @Ok = 80030 SELECT @Ok = NULL, @OkRef = NULL
IF @Ok IS NULL AND @CxAjusteID IS NOT NULL
BEGIN
UPDATE Cxc WITH (ROWLOCK)  SET Concepto = @CxConcepto, Importe = @CxAjusteImporte, Impuestos = NULL, AplicaManual = 1 WHERE ID = @CxAjusteID
DELETE CxcD WHERE ID = @CxAjusteID
INSERT CxcD (ID, Renglon, Aplica, AplicaID, Importe) VALUES (@CxAjusteID, 2048.0, @Mov, @MovID, @CxAjusteImporte)
EXEC spAfectar 'CXC', @CxAjusteID, 'AFECTAR', 'TODO', NULL, @Usuario, @EnSilencio = 1, @Conexion = 1, @Ok = @Ok OUTPUT, @OkRef = @OkRef OUTPUT
END
END
SELECT @CxAjusteImporte = @ImpuestosCx
IF @CxAjusteImporte > 0.0
BEGIN
SELECT @CxAjusteMov = ACAjusteImpuestoAd FROM EmpresaCfgMov WITH (NOLOCK) WHERE Empresa = @Empresa
SELECT @CxConcepto = ACAjusteConceptoImpuestoAd FROM EmpresaCfg WITH (NOLOCK) WHERE Empresa = @Empresa
EXEC @CxAjusteID = spAfectar 'CXC', @CxID, 'GENERAR', 'TODO', @CxAjusteMov, @Usuario, @EnSilencio = 1, @Conexion = 1, @Ok = @Ok OUTPUT, @OkRef = @OkRef OUTPUT
IF @Ok = 80030 SELECT @Ok = NULL, @OkRef = NULL
IF @Ok IS NULL AND @CxAjusteID IS NOT NULL
BEGIN
UPDATE Cxc  WITH (ROWLOCK) SET Concepto = @CxConcepto, Importe = @CxAjusteImporte, Impuestos = NULL, AplicaManual = 1 WHERE ID = @CxAjusteID
DELETE CxcD WHERE ID = @CxAjusteID
INSERT CxcD (ID, Renglon, Aplica, AplicaID, Importe) VALUES (@CxAjusteID, 2048.0, @Mov, @MovID, @CxAjusteImporte)
EXEC spAfectar 'CXC', @CxAjusteID, 'AFECTAR', 'TODO', NULL, @Usuario, @EnSilencio = 1, @Conexion = 1, @Ok = @Ok OUTPUT, @OkRef = @OkRef OUTPUT
END
END
END
END
IF @CxID IS NOT NULL
SELECT @CxMovTipo = Clave FROM MovTipo WITH (NOLOCK) WHERE Modulo = @CxModulo AND Mov = @CxMov
END
IF @Fiscal = 0 AND @CfgRetencionAlPago = 0 AND @MovTipo IN ('COMS.F','COMS.FL','COMS.EG', 'COMS.EI', 'COMS.D') AND (@SumaRetencion <> 0.0 OR @SumaRetencion2 <> 0.0 OR @SumaRetencion3 <> 0.0)
BEGIN
IF @SumaRetencion <> 0.0
BEGIN
IF @CfgRetencionAcreedor IS NULL
SELECT @Ok = 70100
ELSE
EXEC spGenerarCx @Sucursal, @SucursalOrigen, @SucursalDestino, @Accion, NULL, @Empresa, @Modulo, @ID, @Mov, @MovID, @MovTipo, @MovMoneda, @MovTipoCambio,
@FechaEmision, @CfgRetencionConcepto, @Proyecto, @Usuario, @Autorizacion, NULL, @DocFuente, @Observaciones,
@FechaRegistro, @Ejercicio, @Periodo,
NULL, NULL, @CfgRetencionAcreedor, NULL, NULL, NULL, NULL, NULL,
@SumaRetencion, NULL, NULL, NULL,
NULL, NULL, NULL, NULL, NULL, @CfgRetencionMov,
@CxModulo OUTPUT, @CxMov OUTPUT, @CxMovID OUTPUT,
@Ok OUTPUT, @OkRef OUTPUT
END
IF @SumaRetencion2 <> 0.0
BEGIN
IF @CfgRetencion2Acreedor IS NULL
SELECT @Ok = 70100
ELSE
EXEC spGenerarCx @Sucursal, @SucursalOrigen, @SucursalDestino, @Accion, NULL, @Empresa, @Modulo, @ID, @Mov, @MovID, @MovTipo, @MovMoneda, @MovTipoCambio,
@FechaEmision, @CfgRetencion2Concepto, @Proyecto, @Usuario, @Autorizacion, NULL, @DocFuente, @Observaciones,
@FechaRegistro, @Ejercicio, @Periodo,
NULL, NULL, @CfgRetencion2Acreedor, NULL, NULL, NULL, NULL, NULL,
@SumaRetencion2, NULL, NULL, NULL,
NULL, NULL, NULL, NULL, NULL, @CfgRetencionMov,
@CxModulo OUTPUT, @CxMov OUTPUT, @CxMovID OUTPUT,
@Ok OUTPUT, @OkRef OUTPUT
END
IF @SumaRetencion3 <> 0.0
BEGIN
IF @CfgRetencion3Acreedor IS NULL
SELECT @Ok = 70100
ELSE
EXEC spGenerarCx @Sucursal, @SucursalOrigen, @SucursalDestino, @Accion, NULL, @Empresa, @Modulo, @ID, @Mov, @MovID, @MovTipo, @MovMoneda, @MovTipoCambio,
@FechaEmision, @CfgRetencion3Concepto, @Proyecto, @Usuario, @Autorizacion, NULL, @DocFuente, @Observaciones,
@FechaRegistro, @Ejercicio, @Periodo,
NULL, NULL, @CfgRetencion3Acreedor, NULL, NULL, NULL, NULL, NULL,
@SumaRetencion3, NULL, NULL, NULL,
NULL, NULL, NULL, NULL, NULL, @CfgRetencionMov,
@CxModulo OUTPUT, @CxMov OUTPUT, @CxMovID OUTPUT,
@Ok OUTPUT, @OkRef OUTPUT
END
END
IF @MovTipo IN ('VTAS.F','VTAS.FAR', 'VTAS.FB') AND (@Estatus = 'SINAFECTAR' OR @EstatusNuevo = 'CANCELADO') AND @CfgAnticiposFacturados = 1 AND @AnticiposFacturados > 0.0
BEGIN
IF @Accion = 'CANCELAR' SELECT @EsCargo = 1 ELSE SELECT @EsCargo = 0
IF @Accion = 'CANCELAR'
UPDATE Cxc WITH (ROWLOCK)
SET AnticipoSaldo = ISNULL(AnticipoSaldo, 0) + vfa.Importe
FROM Cxc c, VentaFacturaAnticipo vfa WITH (NOLOCK)
WHERE vfa.ID = @ID AND vfa.CxcID = c.ID
ELSE BEGIN
SELECT @SumaAnticiposFacturados = SUM(AnticipoAplicar) FROM Cxc WITH (NOLOCK) WHERE AnticipoAplicaModulo = @Modulo AND AnticipoAplicaID = @ID
EXEC xpSumaAnticiposFacturados @Empresa, @Usuario, @Accion, @Modulo, @ID, @MovMoneda, @MovTipoCambio, @SumaAnticiposFacturados OUTPUT, @Ok OUTPUT, @OkRef OUTPUT
IF ISNULL(@SumaAnticiposFacturados, 0)>0 AND @AnticiposFacturados <> @SumaAnticiposFacturados SELECT @Ok = 30405 ELSE
IF EXISTS(SELECT * FROM Cxc WITH (NOLOCK) WHERE AnticipoAplicaModulo = @Modulo AND AnticipoAplicaID = @ID AND (ISNULL(AnticipoAplicar, 0) < 0.0 OR ROUND(AnticipoAplicar, 0) > ROUND(AnticipoSaldo, 0))) SELECT @Ok = 30405
ELSE BEGIN
INSERT VentaFacturaAnticipo (ID, CxcID, Importe)
SELECT @ID, ID, AnticipoAplicar
FROM Cxc WITH (NOLOCK)
WHERE AnticipoAplicaModulo = @Modulo AND AnticipoAplicaID = @ID
UPDATE Cxc WITH (ROWLOCK)
SET AnticipoSaldo = ISNULL(AnticipoSaldo, 0) - ISNULL(AnticipoAplicar, 0),
AnticipoAplicar = NULL,
AnticipoAplicaModulo = NULL,
AnticipoAplicaID = NULL
WHERE AnticipoAplicaModulo = @Modulo AND AnticipoAplicaID = @ID
END
END
EXEC spSaldo @Sucursal, @Accion, @Empresa, @Usuario, 'CANT', @MovMoneda, @MovTipoCambio, @ClienteProv, NULL, NULL, NULL,
@Modulo, @ID, @Mov, @MovID, @EsCargo, @AnticiposFacturados, NULL, NULL,
@FechaAfectacion, @Ejercicio, @Periodo, @Mov, @MovID, 0, 0, 0,
@Ok OUTPUT, @OkRef OUTPUT
END
IF @MovTipo IN ('COMS.EG', 'COMS.EI', 'INV.EI') AND @EstatusNuevo IN ('CONCLUIDO','PROCESAR','CANCELADO')
EXEC spAfectarGastoDiverso @Sucursal, @SucursalOrigen, @SucursalDestino, @Accion, @Empresa, @Modulo, @ID, @Mov, @MovID, @MovTipo, @FechaRegistro,
@Proyecto, @Usuario, @Autorizacion, @Referencia, @DocFuente, @Observaciones, @Ejercicio, @Periodo, @VIN,
@Ok OUTPUT, @OkRef OUTPUT
IF @UltAgente IS NOT NULL AND @ComisionAcum <> 0.0 AND @Ok IS NULL AND
(((@MovTipo IN ('VTAS.F','VTAS.FAR', 'VTAS.FB', 'VTAS.D', 'VTAS.DF', 'VTAS.B') AND (@Estatus = 'SINAFECTAR' OR @EstatusNuevo = 'CANCELADO')) AND (@CfgVentaComisionesCobradas = 0 OR @CobroIntegrado = 1 OR @CobrarPedido = 1)) OR @MovTipo IN ('VTAS.FM', 'VTAS.N', 'VTAS.NO', 'VTAS.NR'))
BEGIN
EXEC spGenerarCx @Sucursal, @SucursalOrigen, @SucursalDestino, @Accion, 'AGENT', @Empresa, @Modulo, @ID, @Mov, @MovID, @MovTipo, @MovMoneda, @MovTipoCambio,
@FechaAfectacion, @Concepto, @Proyecto, @Usuario,  @Autorizacion, @Referencia, @DocFuente, @Observaciones,
@FechaRegistro, @Ejercicio, @Periodo,
NULL, NULL, @ClienteProv, NULL, @UltAgente, NULL, NULL, NULL,
@ComisionImporteNeto, NULL, NULL, @ComisionAcum,
NULL, NULL, NULL, NULL, NULL, NULL,
@CxModulo, @CxMov, @CxMovID, @Ok OUTPUT, @OkRef  OUTPUT
SELECT @ComisionAcum = 0.0, @ComisionImporteNeto = 0.0
END
IF @MovTipo = 'VTAS.DF' OR (@MovTipo = 'INV.A' AND @CfgInvAjusteCargoAgente <> 'NO') AND @Ok IS NULL
BEGIN
SELECT @CxImporte = NULL, @CxMovEspecifico = NULL, @CxAgente = @Agente
IF @MovTipo = 'VTAS.DF'
BEGIN
SELECT @CxImporte = -SUM(Cantidad*Costo) FROM VentaD  WITH (NOLOCK) WHERE ID = @ID
SELECT @CxMovEspecifico = @Mov
SELECT @CxAgente = AgenteServicio FROM Venta WITH (NOLOCK) WHERE ID = @ID
END ELSE BEGIN
IF @CfgInvAjusteCargoAgente = 'PRECIO'
SELECT @CxImporte = SUM(d.Cantidad*ISNULL(d.Precio, a.PrecioLista)) FROM InvD d WITH (NOLOCK), Art a WITH (NOLOCK) WHERE d.ID = @ID AND d.Articulo = a.Articulo
ELSE
SELECT @CxImporte = SUM(Cantidad*Costo) FROM InvD WITH (NOLOCK) WHERE ID = @ID
END
IF ISNULL(@CxImporte, 0.0) < 0.0
BEGIN
SELECT @CxImporte = -@CxImporte
EXEC spGenerarCx @Sucursal, @SucursalOrigen, @SucursalDestino, @Accion, 'AGENT', @Empresa, @Modulo, @ID, @Mov, @MovID, @MovTipo, @MovMoneda, @MovTipoCambio,
@FechaAfectacion, @Concepto, @Proyecto, @Usuario,  @Autorizacion, @Referencia, @DocFuente, @Observaciones,
@FechaRegistro, @Ejercicio, @Periodo,
NULL, NULL, @Agente, NULL, @CxAgente, NULL, NULL, NULL,
@CxImporte, NULL, NULL, @CxImporte,
NULL, NULL, NULL, NULL, NULL, @CxMovEspecifico,
@CxModulo, @CxMov, @CxMovID, @Ok OUTPUT, @OkRef  OUTPUT
IF @Ok = 80030 SELECT @Ok = NULL, @OkRef = NULL
END
END
IF @Accion <> 'CANCELAR'
BEGIN
IF @CfgCompraAutoCargos = 1 AND @MovTipo IN ('COMS.F', 'COMS.FL', 'COMS.EG', 'COMS.EI', 'COMS.D', 'COMS.B') AND @Ok IS NULL
EXEC xpCompraAutoCargos @Sucursal, @SucursalOrigen, @SucursalDestino, @Accion, @Modulo, @Empresa, @ID, @Mov,
@MovID, @MovTipo, @MovMoneda, @MovTipoCambio, @FechaEmision , @Concepto, @Proyecto,
@Usuario, @Autorizacion, @Referencia, @DocFuente, @Observaciones, @FechaRegistro, @Ejercicio, @Periodo,
@Condicion, @Vencimiento, @ClienteProv, @SumaImporteNeto, @SumaImpuestosNetos, @VIN, @Ok OUTPUT, @OkRef OUTPUT
IF @CfgVentaAutoBonif = 1 AND @MovTipo IN ('VTAS.F','VTAS.FAR', 'VTAS.D', 'VTAS.DF', 'VTAS.B') AND @Ok IS NULL
EXEC xpVentaAutoBonif @Sucursal, @SucursalOrigen, @SucursalDestino, @Accion, @Modulo, @Empresa, @ID, @Mov,
@MovID, @MovTipo, @MovMoneda, @MovTipoCambio, @FechaEmision , @Concepto, @Proyecto,
@Usuario, @Autorizacion, @Referencia, @DocFuente, @Observaciones, @FechaRegistro, @Ejercicio, @Periodo,
@Condicion, @Vencimiento, @ClienteProv, @CobroIntegrado, @SumaImporteNeto, @SumaImpuestosNetos, @VIN, @Ok OUTPUT, @OkRef OUTPUT
END
IF @Accion <> 'CANCELAR' AND @MovTipo IN ('VTAS.F','VTAS.FAR') AND (SELECT CxcAutoAplicarAnticiposPedidos FROM EmpresaCfg2 WITH (NOLOCK) WHERE Empresa = @Empresa) = 1
BEGIN
SELECT @ReferenciaAplicacionAnticipo = RTRIM(@Origen) + ' ' + RTRIM(@OrigenID)
EXEC xpVentaAutoAplicarAnticiposPedidos @Sucursal, @SucursalOrigen, @SucursalDestino, @Accion, @Modulo, @Empresa, @ID, @Mov,
@MovID, @MovTipo, @MovMoneda, @MovTipoCambio, @FechaEmision , @Concepto, @Proyecto,
@Usuario, @Autorizacion, @ReferenciaAplicacionAnticipo, @DocFuente, @Observaciones, @FechaRegistro, @Ejercicio, @Periodo,
@Condicion, @Vencimiento, @ClienteProv, @CobroIntegrado, @SumaImporteNeto, @SumaImpuestosNetos, @VIN, @Ok OUTPUT, @OkRef OUTPUT
END
IF @Ok IN (NULL, 80030) AND @CxID IS NOT NULL AND @CxMovTipo IN ('CXC.F', 'CXC.CA', 'CXC.CAP', 'CXC.CAD', 'CXC.D', 'CXP.F', 'CXP.CA', 'CXP.CAP', 'CXP.CAD', 'CXP.D') AND @Condicion IS NOT NULL AND @Accion <> 'CANCELAR'
BEGIN
SELECT @Ok = NULL, @OkRef = NULL
IF (SELECT AC FROM EmpresaGral WITH (NOLOCK) WHERE Empresa = @Empresa) = 0
IF EXISTS(SELECT * FROM Condicion WITH (NOLOCK) WHERE Condicion = @Condicion AND DA = 1)
EXEC spCxDocAuto @CxModulo, @CxID, @Usuario, @Ok OUTPUT, @OkRef OUTPUT
END
IF @CfgCompraAutoEndosoAutoCargos = 1 AND @Modulo = 'COMS' AND @MovTipo = 'COMS.F' AND @Accion = 'AFECTAR' AND @EstatusNuevo = 'CONCLUIDO' AND @CxModulo = 'CXP' and @CxmovTipo = 'CXP.F' AND @CxID IS NOT NULL AND @Ok IN (NULL, 80030)
BEGIN
SELECT @Proveedor = Proveedor FROM Compra WITH (NOLOCK) WHERE ID = @ID
SELECT @AutoEndosar = AutoEndoso FROM Prov WITH (NOLOCK) WHERE Proveedor = @Proveedor
IF @AutoEndosar IS NOT NULL
BEGIN
SELECT @Ok = NULL, @OkRef = NULL
SELECT @CxEndosoMov = CxpEndoso FROM EmpresaCfgMov WITH (NOLOCK) WHERE Empresa = @Empresa
EXEC spCx @CxID, @CxModulo, 'GENERAR', 'TODO', @FechaRegistro, @CxEndosoMov, @Usuario, 1, 0, @CxEndosoMov OUTPUT, @CxEndosoMovID OUTPUT, @CxEndosoID OUTPUT, @Ok OUTPUT, @OkRef OUTPUT
IF @Ok = 80030 SELECT @Ok = NULL, @OkRef = NULL
IF @Ok IS NULL
BEGIN
IF @CxModulo = 'CXP' UPDATE Cxp WITH (ROWLOCK) SET FechaEmision = @FechaEmision, Proveedor = @AutoEndosar WHERE ID = @CxEndosoID
EXEC spCx @CxEndosoID, @CxModulo, 'AFECTAR', 'TODO', @FechaRegistro, NULL, @Usuario, 1, 0, @CxEndosoMov OUTPUT, @CxEndosoMovID OUTPUT, NULL, @Ok OUTPUT, @OkRef OUTPUT
END
END
END
IF @MovTipo = 'COMS.OP' AND @Ok IS NULL
EXEC spCompraProrrateo @Sucursal, @Empresa, @Usuario, @Accion, @Modulo, @ID, @FechaRegistro,
@Mov, @MovID, @FechaEmision, @Ejercicio, @Periodo, @MovMoneda, @MovTipoCambio,
@Ok OUTPUT, @OkRef OUTPUT
IF @MovTipo = 'PROD.O' AND @Ok IS NULL
EXEC spProdExplotar @Sucursal, @Empresa, @Usuario, @Accion, @Modulo, @ID, @FechaRegistro, 0, @Ok OUTPUT, @OkRef OUTPUT
IF @MovTipo IN ('VTAS.FG'/*, 'VTAS.FX'*/) AND @Ok IS NULL
EXEC spGenerarGasto @Accion, @Empresa, @Sucursal, @Usuario, @Modulo, @ID, @Mov, @MovID, @FechaEmision, @FechaRegistro, @Ok OUTPUT, @OkRef OUTPUT, @MovTipo = @MovTipo
END  
END
IF @Modulo = 'VTAS'
BEGIN
IF (SELECT TieneMovimientos FROM Cte WITH (NOLOCK) WHERE Cliente = @ClienteProv) = 0
UPDATE Cte WITH (ROWLOCK) SET TieneMovimientos = 1 WHERE Cliente = @ClienteProv
END
IF @Modulo = 'VTAS' AND @EnviarA IS NOT NULL
BEGIN
IF (SELECT TieneMovimientos FROM CteEnviarA WITH (NOLOCK) WHERE Cliente = @ClienteProv  AND ID = @EnviarA) = 0
UPDATE CteEnviarA WITH (ROWLOCK) SET TieneMovimientos = 1 WHERE Cliente = @ClienteProv  AND ID = @EnviarA
END
IF @Almacen IS NOT NULL
BEGIN
IF (SELECT TieneMovimientos FROM Alm WITH (NOLOCK) WHERE Almacen = @Almacen) = 0
UPDATE Alm  WITH (ROWLOCK) SET TieneMovimientos = 1 WHERE Almacen = @Almacen
END
IF @AlmacenDestino IS NOT NULL
BEGIN
IF (SELECT TieneMovimientos FROM Alm WITH (NOLOCK) WHERE Almacen = @AlmacenDestino) = 0
UPDATE Alm WITH (ROWLOCK) SET TieneMovimientos = 1 WHERE Almacen = @AlmacenDestino
END
IF @Agente IS NOT NULL
BEGIN
IF (SELECT TieneMovimientos FROM Agente WITH (NOLOCK) WHERE Agente = @Agente) = 0
UPDATE Agente WITH (ROWLOCK) SET TieneMovimientos = 1 WHERE Agente = @Agente
END
IF @Modulo = 'COMS'
BEGIN
IF (SELECT TieneMovimientos FROM Prov WITH (NOLOCK) WHERE Proveedor = @ClienteProv) = 0
UPDATE Prov WITH (ROWLOCK) SET TieneMovimientos = 1 WHERE Proveedor = @ClienteProv
END
IF @OrigenMovTipo = 'VTAS.FR'
EXEC spAfectarMovRecurrente @Accion, @Empresa, @Modulo, @Origen, @OrigenID, @Ok OUTPUT, @OkRef OUTPUT
IF @MovTipo = 'VTAS.CTO'
EXEC spMovContratoGenerar @Accion, @Empresa, @Sucursal, @Usuario, @Modulo, @ID, @Mov, @MovID, @FechaRegistro, @Ok OUTPUT, @OkRef OUTPUT
IF @MovTipo IN ('COMS.CA', 'COMS.GX')
BEGIN
SELECT @ProrrateoAplicaID = p.ID, @ProrrateoAplicaIDMov = p.Mov, @ProrrateoAplicaIDMovID = p.MovID
FROM Compra c WITH (NOLOCK), Compra p WITH (NOLOCK)
WHERE c.ID = @ID
AND c.ProrrateoAplicaID = p.ID
IF @ProrrateoAplicaID IS NOT NULL
EXEC spMovFlujo @Sucursal, @Accion, @Empresa, @Modulo, @ID, @Mov, @MovID, @Modulo, @ProrrateoAplicaID, @ProrrateoAplicaIDMov, @ProrrateoAplicaIDMovID, @Ok OUTPUT
END
IF @Ok IS NULL OR @Ok BETWEEN 80030 AND 81000
BEGIN
IF @GenerarGasto = 1 AND @Modulo = 'INV'
EXEC spGenerarGasto @Accion, @Empresa, @Sucursal, @Usuario, @Modulo, @ID, @Mov, @MovID, @FechaEmision, @FechaRegistro, @Ok OUTPUT, @OkRef OUTPUT, @MovTipoGenerarGasto = 1
EXEC xpInvGenerarGasto @Sucursal, @Accion, @Modulo, @ID, @Mov, @MovID, @MovTipo, @Empresa, @Usuario, @FechaRegistro, @ClienteProv, @Ok OUTPUT, @OkRef OUTPUT
END
IF @MovTipo IN ('COMS.F', 'COMS.CC', 'VTAS.F') AND @Accion = 'AFECTAR' AND @EstatusNuevo = 'CONCLUIDO'
EXEC spEliminarOrdenesPendientes @ID, @Accion, @Base, @Empresa, @Usuario, @Modulo, @Mov, @MovID, @MovTipo,
@MovMoneda, @MovTipoCambio, @Estatus, @EstatusNuevo, @FechaEmision, @FechaRegistro, @FechaAfectacion, @Conexion, @SincroFinal, @Sucursal,
NULL, NULL,
@Ok OUTPUT, @OkRef OUTPUT
IF @MovTipo IN ('VTAS.P', 'VTAS.S') AND @CfgVentaDMultiAgenteSugerir = 1  AND @EstatusNuevo = 'PENDIENTE'
EXEC spSugerirVentaDAgenteFecha @ID, @EnSilencio = 1
/*    IF @Ok IN (NULL, 80030) AND @Modulo = 'VTAS'
BEGIN
IF @CfgAC = 1
BEGIN
IF (SELECT lc.Uso FROM Venta v JOIN LC ON lc.LineaCredito = v.LineaCredito WHERE v.ID = @ID) = 'Arrendamiento'
EXEC spTablaArrendamiento @Modulo, @ID, @Usuario, 1, @FechaRegistro, @Ok OUTPUT, @OkRef OUTPUT, @Accion = @Accion
END
END
*/
IF @WMS = 1 AND (SELECT WMS FROM Alm WITH (NOLOCK) WHERE Almacen = @Almacen) = 1 AND @Accion IN ('AFECTAR', 'CANCELAR', 'RESERVARPARCIAL')
BEGIN
SELECT @WMSMov = NULL
SELECT @WMSMov = NULLIF(RTRIM(WMSMov), '') FROM CfgWMSMov WITH (NOLOCK) WHERE Modulo = @Modulo AND Mov = @Mov
IF @WMSMov IS NOT NULL
EXEC spWMSGenerar @Empresa, @Sucursal, @Usuario, @Accion, @Modulo, @ID, @Mov, @MovID, @FechaEmision, @FechaRegistro, @Almacen, @WMSMov, @Ok OUTPUT, @OkRef OUTPUT
END
/* Generar Transito */
IF @MovTipo IN ('INV.SI', 'INV.DTI') AND @Ok IS NULL AND @Accion <> 'VERIFICAR'
BEGIN
IF @Accion <> 'CANCELAR'
BEGIN
EXEC @IDGenerar = spMovCopiar @Sucursal, @Modulo, @ID, @Usuario, @FechaRegistro, 1, @CopiarArtCostoInv = 1
IF @IDGenerar IS NOT NULL
BEGIN
IF @MovTipo = 'INV.DTI'
BEGIN
UPDATE Inv WITH (ROWLOCK) SET Almacen = @AlmacenDestinoOriginal, AlmacenDestino = @Almacen WHERE ID = @IDGenerar
UPDATE InvD  WITH (ROWLOCK) SET Almacen = @AlmacenDestinoOriginal WHERE ID = @IDGenerar
END
UPDATE Inv WITH (ROWLOCK)
SET Referencia      = RTRIM(@Mov)+ ' ' + RTRIM(@MovID),
SucursalDestino = (SELECT a.Sucursal  FROM Inv i WITH (NOLOCK), Alm a WITH (NOLOCK)  WHERE i.ID = @IDGenerar AND a.Almacen = i.AlmacenDestino),
Mov             = (SELECT InvTransito FROM EmpresaCfgMov WITH (NOLOCK) WHERE Empresa = @Empresa),
OrigenTipo = @Modulo,
Origen     = @Mov,
OrigenID   = @MovID
WHERE ID = @IDGenerar
UPDATE SerieLoteMov WITH (ROWLOCK)
SET Sucursal = (SELECT Sucursal  FROM Alm WITH (NOLOCK) WHERE Almacen = @AlmacenDestinoOriginal)
WHERE Empresa = @Empresa AND Modulo = @Modulo AND ID = @IDGenerar
EXEC xpGenerarTransito @Empresa, @Sucursal, @Usuario, @Modulo, @MovTipo, @Referencia, @ID, @IDGenerar
END
END ELSE
SELECT @IDGenerar = @IDTransito
IF @Ok IN (NULL, 80030)
BEGIN
SELECT @Ok = NULL, @OkRef = NULL
EXEC spInv @IDGenerar, @Modulo, @Accion, 'TODO', @FechaRegistro, NULL, @Usuario, 1, @SincroFinal, 'TRANSITO',
@Mov, @MovID, @IDGenerar, @ContID,
@Ok OUTPUT, @OkRef OUTPUT/*, @VolverAfectar*/
SELECT @TransitoSucursal = Sucursal, @TransitoMov = Mov, @TransitoMovID = MovID, @TransitoEstatus = Estatus FROM Inv WITH (NOLOCK) WHERE ID = @IDGenerar
IF @Ok IN (NULL, 80030)
BEGIN
EXEC spMovFlujo @Sucursal, @Accion, @Empresa, @Modulo, @ID, @Mov, @MovID, @Modulo, @IDGenerar, @TransitoMov, @TransitoMovID, @Ok OUTPUT
IF @Accion = 'CANCELAR' AND @Ok = 80030 SELECT @Ok = NULL, @OkRef = NULL
END ELSE SELECT @OkRef = @TransitoMov
END
/* Traspaso Express */
IF (SELECT TraspasoExpress FROM MovTipo WITH (NOLOCK) WHERE Modulo = @Modulo AND Mov = @Mov) = 1 AND @Ok IN (NULL, 80030) AND @Accion <> 'CANCELAR'  AND @TransitoEstatus = 'PENDIENTE'
BEGIN
SELECT @Ok = NULL, @OkRef = NULL
SELECT @IDTransito = @IDGenerar
EXEC @IDGenerar = spMovCopiar @Sucursal, @Modulo, @IDTransito, @Usuario, @FechaRegistro, 1, @CopiarArtCostoInv = 1
IF @IDGenerar IS NOT NULL
BEGIN
UPDATE Inv WITH (ROWLOCK)
SET Mov             = (SELECT InvReciboTraspaso FROM EmpresaCfgMov WITH (NOLOCK) WHERE Empresa = @Empresa),
OrigenTipo      = @Modulo,
Origen          = @TransitoMov,
OrigenID        = @TransitoMovID,
Directo         = 0
WHERE ID = @IDGenerar
UPDATE InvD WITH (ROWLOCK)
SET Aplica   = @TransitoMov,
AplicaID = @TransitoMovID
WHERE ID = @IDGenerar
EXEC spInv @IDGenerar, @Modulo, @Accion, 'TODO', @FechaRegistro, NULL, @Usuario, 1, @SincroFinal, NULL,
@Mov, @MovID, @IDGenerar, @ContID,
@Ok OUTPUT, @OkRef OUTPUT/*, @VolverAfectar*/
SELECT @TraspasoExpressMov = Mov, @TraspasoExpressMovID = MovID FROM Inv  WITH (NOLOCK) WHERE ID = @IDGenerar
IF @Ok IN (NULL, 80030)
EXEC spMovFlujo @Sucursal, @Accion, @Empresa, @Modulo, @IDTransito, @TransitoMov, @TransitoMovID, @Modulo, @IDGenerar, @TraspasoExpressMov, @TraspasoExpressMovID, @Ok OUTPUT
ELSE
SELECT @OkRef = @TraspasoExpressMov
END
END
END
/* TransferirA */
IF @MovTipo IN ('VTAS.D', 'VTAS.DCR') AND @Ok IN (NULL, 80030)
BEGIN
SELECT @Ok = NULL
IF EXISTS(SELECT * FROM VentaD WITH (NOLOCK) WHERE ID = @ID AND ISNULL(NULLIF(RTRIM(TransferirA), ''), Almacen) <> Almacen)
EXEC spInvTransferirA @Empresa, @Sucursal, @Usuario, @Accion, @Modulo, @ID, @Mov, @MovID, @FechaEmision, @FechaRegistro, @Ok OUTPUT, @OkRef OUTPUT
END
IF @FEA = 1
BEGIN
SELECT @MovTipoConsecutivoFEA = NULLIF(RTRIM(ConsecutivoFEA), '') FROM MovTipo WITH (NOLOCK) WHERE Modulo = @Modulo AND Mov = @Mov
IF @MovTipoConsecutivoFEA IS NOT NULL
BEGIN
IF @Accion = 'AFECTAR' AND @Estatus IN ('SINAFECTAR', 'BORRADOR', 'CONFIRMAR') AND NOT EXISTS(SELECT * FROM VentaFEA WITH (NOLOCK) WHERE ID = @ID)
BEGIN
EXEC spConsecutivo @MovTipoConsecutivoFEA, @Sucursal, @FEAConsecutivo OUTPUT, @Referencia = @FEAReferencia OUTPUT
EXEC spMovIDEnSerieConsecutivo @FEAConsecutivo, @FEASerie OUTPUT, @FEAFolio OUTPUT
INSERT VentaFEA (
ID,  Serie,     Folio,     Aprobacion,                   Procesar, Cancelada)
SELECT @ID, @FEASerie, @FEAFolio, CONVERT(int, @FEAReferencia), 1,        0
EXEC spPreValidarFEA @ID, 0, @Ok OUTPUT, @OkRef OUTPUT
END ELSE
IF @Accion = 'CANCELAR' AND @Estatus IN ('PENDIENTE', 'CONCLUIDO')
BEGIN
UPDATE VentaFEA WITH (ROWLOCK) SET Procesar = 1, Cancelada = 1 WHERE ID = @ID
END
END
END
IF @CfgVentaPuntosEnVales = 1 AND @Accion IN ('AFECTAR', 'RESERVARPARCIAL', 'CANCELAR') AND @Mov IN (SELECT Mov FROM EmpresaCfgPuntosEnValesMov WITH (NOLOCK) WHERE Empresa = @Empresa) AND (@Ok IS NULL OR @Ok BETWEEN 80030 AND 81000)
EXEC spVentaPuntosEnVales @Empresa, @Modulo, @ID, @Mov, @MovID, @MovTipo, @Accion, @FechaEmision, @Usuario, @Sucursal, @MovMoneda, @MovTipoCambio, @Ok OUTPUT, @OkRef OUTPUT
IF @Ok IS NULL AND @MovTipo = 'COMS.GX'
IF EXISTS(SELECT * FROM CompraD WITH (NOLOCK) WHERE ID = @ID AND EsEstadistica = 1)
EXEC spInvGenerarEstadistica @Empresa, @Sucursal, @Modulo, @ID, @Mov, @MovID, @Accion, @ClienteProv, @Ok OUTPUT, @OkRef OUTPUT
IF @MovTipo = 'INV.A' AND @OrigenMovTipo= 'INV.IF'
EXEC spMovFlujo @Sucursal, @Accion, @Empresa, 'INV', @IDOrigen, @Origen, @OrigenID, 'INV', @ID, @Mov, @MovID, @Ok OUTPUT
IF @Ok IS NULL OR @Ok BETWEEN 80030 AND 81000
EXEC spMovFinal @Empresa, @Sucursal, @Modulo, @ID, @Estatus, @EstatusNuevo, @Usuario, @FechaEmision, @FechaRegistro, @Mov, @MovID, @MovTipo, @IDGenerar, @Ok OUTPUT, @OkRef OUTPUT
IF @Ok IS NULL OR @Ok BETWEEN 80030 AND 81000
EXEC xpInvAfectar @ID, @Accion, @Base, @Empresa, @Usuario, @Modulo, @Mov, @MovID, @MovTipo,
@MovMoneda, @MovTipoCambio, @Estatus, @EstatusNuevo, @FechaEmision, @FechaRegistro, @FechaAfectacion, @Conexion, @SincroFinal, @Sucursal,
NULL, NULL,
@Ok OUTPUT, @OkRef OUTPUT
IF @MovTipo = 'VTAS.S' AND @GenerarOP = 1 AND @EstatusNuevo IN ('PENDIENTE', 'CANCELADO') AND @Estatus <> @EstatusNuevo
EXEC spAutoGenerarOP @Sucursal, @Accion, @Modulo, @ID, @Mov, @MovID, @MovTipo, @Empresa, @Usuario, @FechaRegistro, @ClienteProv, @ServicioSerie, @Ok OUTPUT, @OkRef OUTPUT
IF @Accion = 'CANCELAR' AND @EstatusNuevo = 'CANCELADO' AND @Ok IS NULL
BEGIN
EXEC spCancelarFlujo @Empresa, @Modulo, @ID, @Ok OUTPUT
IF @Modulo = 'VTAS' UPDATE VentaOrigen WITH (ROWLOCK) SET OrigenID = 0 WHERE ID = @ID
END
IF @Conexion = 0
BEGIN
IF @Ok IS NULL OR @Ok BETWEEN 80030 AND 81000
COMMIT TRANSACTION
ELSE BEGIN
DECLARE @PolizaDescuadrada TABLE (Cuenta varchar(20) NULL, SubCuenta varchar(50) NULL, Concepto varchar(50) NULL, Debe money NULL, Haber money NULL, SucursalContable int NULL)
IF EXISTS(SELECT * FROM PolizaDescuadrada WITH (NOLOCK) WHERE Modulo = @Modulo AND ID = @ID)
INSERT @PolizaDescuadrada (Cuenta, SubCuenta, Concepto, Debe, Haber, SucursalContable) SELECT Cuenta, SubCuenta, Concepto, Debe, Haber, SucursalContable FROM PolizaDescuadrada WHERE Modulo = @Modulo AND ID = @ID
ROLLBACK TRANSACTION
DELETE PolizaDescuadrada WHERE Modulo = @Modulo AND ID = @ID
INSERT PolizaDescuadrada (Modulo, ID, Cuenta, SubCuenta, Concepto, Debe, Haber, SucursalContable) SELECT @Modulo, @ID, Cuenta, SubCuenta, Concepto, Debe, Haber, SucursalContable FROM @PolizaDescuadrada
END
END
IF @Ok = 80070 AND @MovTipo = 'INV.IF' UPDATE Inv WITH (ROWLOCK) SET Estatus = 'CONCLUIDO', FechaConclusion = GETDATE() WHERE ID = @ID
RETURN
END


GO
