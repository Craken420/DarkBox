SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[spEmbarqueAfectar]  
@ID                  int,  
@Accion   char(20),  
@Empresa         char(5),  
@Modulo         char(5),  
@Mov            char(20),  
@MovID               varchar(20)  OUTPUT,  
@MovTipo       char(20),  
@FechaEmision        datetime,  
@FechaAfectacion       datetime,  
@FechaConclusion  datetime,  
@Proyecto         varchar(50),  
@Usuario         char(10),  
@Autorizacion        char(10),  
@DocFuente         int,  
@Observaciones       varchar(255),  
@Referencia   varchar(50),  
@Concepto   varchar(50),  
@Estatus             char(15),  
@EstatusNuevo        char(15),  
@FechaRegistro       datetime,  
@Ejercicio         int,  
@Periodo         int,  
@FechaSalida   datetime,  
@FechaRetorno  datetime,  
@Vehiculo   char(10),  
@PersonalCobrador  varchar(10),  
@Conexion   bit,  
@SincroFinal   bit,  
@Sucursal   int,  
@SucursalDestino  int,  
@SucursalOrigen  int,  
@AntecedenteID   int,  
@AntecedenteMovTipo  char(20),  
@CtaDinero   char(10),  
@CfgAfectarCobros  bit,  
@CfgModificarVencimiento bit,  
@CfgEstadoTransito  varchar(50),  
@CfgEstadoPendiente  varchar(50),  
@CfgGastoTarifa  bit,  
@CfgAfectarGastoTarifa bit,  
@CfgBaseProrrateo  varchar(20),  
@CfgDesembarquesParciales bit,  
@CfgContX   bit,  
@CfgContXGenerar  char(20),  
@GenerarPoliza  bit,  
@GenerarMov   char(20),  
@IDGenerar   int      OUTPUT,  
@GenerarMovID    varchar(20)  OUTPUT,  
@Ok                  int          OUTPUT,  
@OkRef               varchar(255) OUTPUT  
  
AS BEGIN  
DECLARE  
@Generar   bit,  
@GenerarAfectado  bit,  
@GenerarModulo  char(5),  
@GenerarMovTipo  char(20),  
@GenerarEstatus  char(15),  
@GenerarPeriodo   int,  
@GenerarEjercicio   int,  
@EmbarqueMov  int,  
@EmbarqueMovID  int,  
@Estado   char(30),  
@EstadoTipo   char(20),  
@FechaHora   datetime,  
@Importe   money,  
@Forma   varchar(50),  
@DetalleReferencia  varchar(50),  
@DetalleObservaciones varchar(100),  
@MovModulo   char(5),  
@MovModuloID  int,  
@MovMov   char(20),  
@MovMovID   varchar(20),  
@MovMovTipo   char(20),  
@MovEstatus   char(15),  
@MovMoneda   char(10),  
@MovCondicion  varchar(50),  
@MovVencimiento  datetime,  
@MovImporte   money,  
@MovImpuestos  money,  
@MovTipoCambio  float,  
@MovPorcentaje  float,  
@Peso   float,  
@AplicaImporte  money,  
@Volumen   float,  
@Paquetes   int,  
@Cliente   char(10),  
@Proveedor   char(10),  
@ClienteProveedor  char(10),  
@ClienteEnviarA  int,  
@Agente   char(10),  
@SumaPeso   float,  
@SumaVolumen  float,  
@SumaPaquetes  int,  
@SumaImportePesos  money,  
@SumaImpuestosPesos  money,  
@SumaImporteEmbarque money,  
@FechaCancelacion  datetime,  
@AntecedenteEstatus  char(15),  
@GenerarAccion  char(20),  
/*@CxpConcepto  varchar(50),*/  
@Dias   int,  
@CxModulo   char(5),  
@CxMov    char(20),  
@CxMovID    varchar(20),  
@CteModificarVencimiento varchar(20),  
@EnviarAModificarVencimiento varchar(20),  
@ModificarVencimiento bit,  
@GastoAnexoTotalPesos money,  
@DiaRetorno   datetime,  
@TienePendientes  bit  
SELECT @Generar   = 0,  
@GenerarAfectado = 0,  
@IDGenerar  = NULL,  
@GenerarModulo  = NULL,  
@GenerarMovID         = NULL,  
@GenerarMovTipo        = NULL,  
@GenerarEstatus  = 'SINAFECTAR',  
@TienePendientes       = 0  
IF @CfgDesembarquesParciales = 1 AND @MovTipo IN ('EMB.E', 'EMB.OC') AND @EstatusNuevo = 'CONCLUIDO'  
BEGIN  
--IF EXISTS(SELECT * FROM EmbarqueD d, EmbarqueMov m, EmbarqueEstado e WHERE d.EmbarqueMov=m.ID AND d.ID = @ID AND d.Estado=e.Estado AND UPPER(e.Tipo)='PENDIENTE' AND d.DesembarqueParcial = 0)  
IF EXISTS(SELECT d.id FROM EmbarqueD d WITH(NOLOCK) JOIN EmbarqueMov m WITH(NOLOCK) ON d.EmbarqueMov=m.ID JOIN EmbarqueEstado e WITH(NOLOCK) ON d.Estado=e.Estado WHERE d.ID = @ID AND UPPER(e.Tipo)='PENDIENTE' AND d.DesembarqueParcial = 0)  
SELECT @TienePendientes = 1, @EstatusNuevo = 'PENDIENTE'  
END  
EXEC spMovConsecutivo @Sucursal, @SucursalOrigen, @SucursalDestino, @Empresa, @Usuario, @Modulo, @Ejercicio, @Periodo, @ID, @Mov, NULL, @Estatus, @Concepto, @Accion, @Conexion, @SincroFinal, @MovID OUTPUT, @Ok OUTPUT, @OkRef OUTPUT  
IF @Estatus IN ('SINAFECTAR', 'BORRADOR', 'CONFIRMAR') AND @Accion <> 'CANCELAR' AND @Ok IS NULL  
BEGIN  
EXEC spMovChecarConsecutivo @Empresa, @Modulo, @Mov, @MovID, NULL, @Ejercicio, @Periodo, @Ok OUTPUT, @OkRef OUTPUT  
END  
IF @Accion IN ('CONSECUTIVO', 'SINCRO') AND @Ok IS NULL  
BEGIN  
IF @Accion = 'SINCRO' EXEC spAsignarSucursalEstatus @ID, @Modulo, @SucursalDestino, @Accion  
SELECT @Ok = 80060, @OkRef = @MovID  
RETURN  
END  
IF @Accion = 'GENERAR' AND @Ok IS NULL  
BEGIN  
EXEC spMovGenerar @Sucursal, @Empresa, @Modulo, @Ejercicio, @Periodo, @Usuario, @FechaRegistro, @GenerarEstatus,  
NULL, NULL,  
@Mov, @MovID, 0,  
@GenerarMov, NULL, @GenerarMovID OUTPUT, @IDGenerar OUTPUT, @Ok OUTPUT, @OkRef OUTPUT  
EXEC spMovTipo @Modulo, @GenerarMov, @FechaAfectacion, @Empresa, NULL, NULL, @GenerarMovTipo OUTPUT, @GenerarPeriodo OUTPUT, @GenerarEjercicio OUTPUT, @Ok OUTPUT  
IF @@ERROR <> 0 SELECT @Ok = 1  
IF @Ok IS NULL SELECT @Ok = 80030  
RETURN  
END  
IF @OK IS NOT NULL RETURN  
IF @Conexion = 0  
BEGIN TRANSACTION  
EXEC spMovEstatus @Modulo, 'AFECTANDO', @ID, @Generar, @IDGenerar, @GenerarAfectado, @Ok OUTPUT  
IF @Accion = 'AFECTAR' AND @Estatus IN ('SINAFECTAR', 'BORRADOR', 'CONFIRMAR')  
IF (SELECT Sincro FROM Version WITH(NOLOCK)) = 1  
EXEC sp_executesql N'UPDATE EmbarqueD WITH(ROWLOCK) SET Sucursal = @Sucursal, SincroC = 1 WHERE ID = @ID AND (Sucursal <> @Sucursal OR SincroC <> 1)', N'@Sucursal int, @ID int', @Sucursal, @ID  
IF @Accion <> 'CANCELAR'  
EXEC spRegistrarMovimiento @Sucursal, @Empresa, @Modulo, @Mov, @MovID, @ID, @Ejercicio, @Periodo, @FechaRegistro, @FechaEmision,  
NULL, @Proyecto, NULL, NULL,  
@Usuario, @Autorizacion, NULL, @DocFuente, @Observaciones,  
@Generar, @GenerarMov, @GenerarMovID, @IDGenerar,  
@Ok OUTPUT  
SELECT @SumaPeso         = 0.0,  
@SumaVolumen        = 0.0,  
@SumaPaquetes       = 0.0,  
@SumaImportePesos   = 0.0,  
@SumaImpuestosPesos = 0.0,  
@SumaImporteEmbarque= 0.0  
DECLARE crEmbarque CURSOR FOR  
SELECT NULLIF(d.EmbarqueMov, 0), d.Estado, d.FechaHora, NULLIF(RTRIM(d.Forma), ''), ISNULL(d.Importe, 0.0), NULLIF(RTRIM(d.Referencia), ''), NULLIF(RTRIM(d.Observaciones), ''),  
m.ID, m.Modulo, m.ModuloID, m.Mov, m.MovID, m.Importe, m.Impuestos, m.Moneda, m.TipoCambio, ISNULL(m.Peso, 0.0), ISNULL(m.Volumen, 0.0), ISNULL(d.Paquetes, 0),  
NULLIF(RTRIM(m.Cliente), ''), NULLIF(RTRIM(m.Proveedor), ''), m.ClienteEnviarA, UPPER(e.Tipo), ISNULL(d.MovPorcentaje, 0)  
FROM EmbarqueD d  
JOIN EmbarqueMov m ON d.EmbarqueMov = m.ID  
LEFT OUTER JOIN EmbarqueEstado e WITH(NOLOCK) ON d.Estado = e.Estado  
WHERE d.ID = @ID AND d.DesembarqueParcial = 0  
OPEN crEmbarque  
FETCH NEXT FROM crEmbarque INTO @EmbarqueMov, @Estado, @FechaHora, @Forma, @Importe, @DetalleReferencia, @DetalleObservaciones, @EmbarqueMovID, @MovModulo, @MovModuloID, @MovMov, @MovMovID, @MovImporte, @MovImpuestos, @MovMoneda, @MovTipoCambio, @Peso, @Volumen, @Paquetes, @Cliente, @Proveedor, @ClienteEnviarA, @EstadoTipo, @MovPorcentaje  
IF @@ERROR <> 0 SELECT @Ok = 1  
IF @@FETCH_STATUS = -1 SELECT @Ok = 60010  
WHILE @@FETCH_STATUS <> -1 AND @Ok IS NULL  
BEGIN  
IF @Accion = 'AFECTAR' AND @MovTipo = 'EMB.OC' AND @MovModulo = 'CXC' AND @EstadoTipo = 'COBRADO'  
IF @Importe < ISNULL((SELECT Saldo FROM Cxc WITH(NOLOCK) WHERE ID = @MovModuloID), 0)  
SELECT @EstadoTipo = 'COBRO PARCIAL'  
IF @@FETCH_STATUS <> -2 AND @EmbarqueMov IS NOT NULL AND @Ok IS NULL  
BEGIN  
IF @MovTipo IN ('EMB.E', 'EMB.OC')  
BEGIN  
IF @Accion = 'AFECTAR' AND @Estatus = 'SINAFECTAR'  
BEGIN  
IF @MovTipo = 'EMB.OC' AND @MovModulo = 'CXC'  
UPDATE Cxc WITH(ROWLOCK) SET PersonalCobrador = @PersonalCobrador WHERE ID = @MovModuloID AND ISNULL(PersonalCobrador, '') <> @PersonalCobrador  
UPDATE EmbarqueD WITH(ROWLOCK) SET Estado = @CfgEstadoTransito WHERE CURRENT OF crEmbarque  
UPDATE EmbarqueMov WITH(ROWLOCK) SET MovPorcentaje = ISNULL(MovPorcentaje, 0) + @MovPorcentaje WHERE ID = @EmbarqueMovID  
END  
IF @Accion = 'CANCELAR'  
BEGIN  
UPDATE EmbarqueD WITH(ROWLOCK) SET Estado = @CfgEstadoPendiente WHERE CURRENT OF crEmbarque  
UPDATE EmbarqueMov WITH(ROWLOCK) SET MovPorcentaje = ISNULL(MovPorcentaje, 0) - @MovPorcentaje WHERE ID = @EmbarqueMovID  
END  
IF @MovModulo = 'VTAS' AND @MovTipo = 'EMB.E' AND ((@Accion = 'AFECTAR' AND @Estatus = 'SINAFECTAR') OR (@Accion = 'CANCELAR' AND (@Estatus = 'PENDIENTE' OR @EstadoTipo <> 'DESEMBARCAR')) OR (@EstadoTipo = 'DESEMBARCAR' AND @Accion = 'AFECTAR'))  
BEGIN  
UPDATE VentaD WITH(ROWLOCK)  
SET CantidadEmbarcada = CASE WHEN @Accion = 'CANCELAR' OR @EstadoTipo = 'DESEMBARCAR' THEN ISNULL(d.CantidadEmbarcada, 0) - ISNULL(e.Cantidad, 0) ELSE ISNULL(d.CantidadEmbarcada, 0) + ISNULL(e.Cantidad , 0) END  
FROM EmbarqueDArt e WITH(NOLOCK), VentaD d   
WHERE e.ID = @ID AND e.EmbarqueMov = @EmbarqueMov AND e.Modulo = 'VTAS' AND e.ModuloID = d.ID AND e.Renglon = d.Renglon AND e.RenglonSub = d.RenglonSub  
--IF EXISTS(SELECT * FROM EmbarqueDArt e, VentaD d WHERE e.ID = @ID AND e.EmbarqueMov = @EmbarqueMov AND e.Modulo = 'VTAS' AND e.ModuloID = d.ID AND d.CantidadEmbarcada <> d.Cantidad-ISNULL(d.CantidadCancelada, 0))  
IF EXISTS(SELECT e.id FROM EmbarqueDArt e WITH(NOLOCK) JOIN VentaD d WITH(NOLOCK) ON e.ModuloID = d.ID  WHERE e.ID = @ID AND e.EmbarqueMov = @EmbarqueMov AND e.Modulo = 'VTAS' AND d.CantidadEmbarcada <> d.Cantidad-ISNULL(d.CantidadCancelada, 0))  
UPDATE EmbarqueMov WITH(ROWLOCK) SET AsignadoID = NULL WHERE ID = @EmbarqueMov  
END  
IF (@Accion = 'AFECTAR' AND @Estatus = 'PENDIENTE') OR (@Accion = 'CANCELAR' AND @Estatus = 'CONCLUIDO')  
BEGIN  
SELECT @GenerarAccion = @Accion  
SELECT @MovMovTipo = NULL, @MovEstatus = NULL, @Agente = NULL  
SELECT @MovMovTipo = Clave FROM MovTipo WITH(NOLOCK) WHERE Modulo = @MovModulo AND Mov = @MovMov  
IF @MovModulo = 'VTAS'  
BEGIN  
SELECT @MovEstatus = Estatus, @Agente = Agente, @MovCondicion = Condicion, @MovVencimiento = Vencimiento FROM Venta WITH(NOLOCK) WHERE ID = @MovModuloID  
IF @EstadoTipo IN ('ENTREGADO', 'COBRADO') AND @FechaHora IS NOT NULL AND @Accion <> 'CANCELAR' AND @Ok IS NULL  
BEGIN  
SELECT @ModificarVencimiento = @CfgModificarVencimiento  
SELECT @CteModificarVencimiento = ISNULL(UPPER(ModificarVencimiento), '(EMPRESA)')  
FROM Cte WITH(NOLOCK)  
WHERE Cliente = @Cliente  
IF @CteModificarVencimiento = 'SI' SELECT @ModificarVencimiento = 1 ELSE  
IF @CteModificarVencimiento = 'NO' SELECT @ModificarVencimiento = 0  
IF NULLIF(@ClienteEnviarA, 0) IS NOT NULL  
BEGIN  
SELECT @EnviarAModificarVencimiento = RTRIM(UPPER(ModificarVencimiento))  
FROM CteEnviarA WITH(NOLOCK)  
WHERE Cliente = @Cliente AND ID = @ClienteEnviarA  
IF @EnviarAModificarVencimiento = 'SI' SELECT @ModificarVencimiento = 1 ELSE  
IF @EnviarAModificarVencimiento = 'NO' SELECT @ModificarVencimiento = 0  
END  
IF @ModificarVencimiento = 1  
EXEC spEmbarqueModificarVencimiento @FechaHora, @Empresa, @MovModuloID, @MovMov, @MovMovID, @MovCondicion, @MovVencimiento, @Ok OUTPUT  
END  
END ELSE  
IF @MovModulo = 'INV'  SELECT @MovEstatus = Estatus FROM Inv    WHERE ID = @MovModuloID ELSE  
IF @MovModulo = 'COMS' SELECT @MovEstatus = Estatus FROM Compra WHERE ID = @MovModuloID ELSE  
IF @MovModulo = 'CXC'  SELECT @MovEstatus = Estatus FROM Cxc    WHERE ID = @MovModuloID ELSE  
IF @MovModulo = 'DIN'  SELECT @MovEstatus = Estatus FROM Dinero WHERE ID = @MovModuloID  
IF ((@Accion <> 'CANCELAR' AND (@EstadoTipo = 'DESEMBARCAR')) OR (@EstadoTipo = 'COBRO PARCIAL' AND @MovTipo = 'EMB.OC')) OR (@Accion = 'CANCELAR' AND @Estatus = 'CONCLUIDO' AND @EstadoTipo <> 'DESEMBARCAR')  
/*IF (@EstadoTipo = 'DESEMBARCAR') OR (@EstadoTipo = 'COBRO PARCIAL' AND @MovTipo = 'EMB.OC') OR (@Accion = 'CANCELAR' AND @Estatus = 'CONCLUIDO')*/  
BEGIN  
UPDATE EmbarqueMov WITH(ROWLOCK) SET AsignadoID = NULL WHERE ID = @EmbarqueMov  
END  
IF @EstadoTipo = 'ENTREGADO'  
BEGIN  
IF @MovMovTipo IN ('DIN.CH', 'DIN.CHE') AND @MovEstatus = 'PENDIENTE'  
EXEC spDinero @MovModuloID, @MovModulo, 'AFECTAR', 'TODO', @FechaRegistro, NULL, @Usuario, 1, 0,  
@GenerarMov, @GenerarMovID, @IDGenerar,  
@Ok OUTPUT, @OkRef OUTPUT  
END  
IF @EstadoTipo IN ('COBRADO', 'COBRO PARCIAL', 'PAGADO')  
BEGIN  
SELECT @ClienteProveedor = NULL  
IF @EstadoTipo IN ('COBRADO', 'COBRO PARCIAL')  
BEGIN  
SELECT @ClienteProveedor = @Cliente  
IF @CfgAfectarCobros = 0 AND @Accion <> 'CANCELAR' SELECT @GenerarAccion = 'GENERAR'  
END ELSE  
IF @EstadoTipo = 'PAGADO' SELECT @ClienteProveedor = @Proveedor  
IF @ClienteProveedor IS NOT NULL  
BEGIN  
IF @Importe>@MovImporte SELECT @AplicaImporte = ISNULL(@MovImporte, 0.0) + ISNULL(@MovImpuestos, 0.0) ELSE SELECT @AplicaImporte = @Importe  
EXEC spGenerarCx @Sucursal, @SucursalOrigen, @SucursalDestino, @GenerarAccion, NULL, @Empresa, @Modulo, @ID, @Mov, @MovID, NULL, @MovMoneda, @MovTipoCambio,  
@FechaEmision, NULL, @Proyecto, @Usuario, NULL,  
@DetalleReferencia, NULL, NULL, @FechaRegistro, @Ejercicio, @Periodo,  
NULL, NULL, @ClienteProveedor, @ClienteEnviarA, @Agente, @Estado, @CtaDinero, @Forma,  
@Importe, NULL, NULL, NULL,  
NULL, @MovMov, @MovMovID, @AplicaImporte, NULL, NULL,  
@GenerarModulo, @GenerarMov, @GenerarMovID,  
@Ok OUTPUT, @OkRef OUTPUT, @PersonalCobrador = @PersonalCobrador  
END  
END  
IF @Ok = 80030 SELECT @Ok = NULL, @OkRef = NULL  
IF @EstadoTipo IN ('ENTREGADO', 'COBRADO') AND @Accion <> 'CANCELAR'  
BEGIN  
IF @MovModulo = 'VTAS' UPDATE Venta  WITH(ROWLOCK) SET FechaEntrega = @FechaHora WHERE ID = @MovModuloID ELSE  
IF @MovModulo = 'COMS' UPDATE Compra WITH(ROWLOCK) SET FechaEntrega = @FechaHora WHERE ID = @MovModuloID ELSE  
IF @MovModulo = 'INV'  UPDATE Inv    WITH(ROWLOCK) SET FechaEntrega = @FechaHora WHERE ID = @MovModuloID ELSE  
IF @MovModulo = 'CXC'  UPDATE Cxc    WITH(ROWLOCK) SET FechaEntrega = @FechaHora WHERE ID = @MovModuloID ELSE  
IF @MovModulo = 'DIN'  UPDATE Dinero WITH(ROWLOCK) SET FechaEntrega = @FechaHora WHERE ID = @MovModuloID  
END  
END ELSE  
BEGIN  
EXEC spMovFlujo @Sucursal, @Accion, @Empresa, @MovModulo, @MovModuloID, @MovMov, @MovMovID, @Modulo, @ID, @Mov, @MovID, @Ok OUTPUT  
IF @Accion = 'CANCELAR'  
UPDATE EmbarqueMov WITH(ROWLOCK) SET AsignadoID = @AntecedenteID WHERE ID = @EmbarqueMov  
END  
END  
IF @TienePendientes = 1 AND @EstadoTipo NOT IN ('PENDIENTE', NULL, '')  
UPDATE EmbarqueD WITH(ROWLOCK)  
SET DesembarqueParcial = 1  
WHERE CURRENT OF crEmbarque  
SELECT @SumaPeso           = @SumaPeso           + @Peso,  
@SumaVolumen        = @SumaVolumen        + @Volumen,  
@SumaPaquetes       = @SumaPaquetes       + @Paquetes,  
@SumaImportePesos   = @SumaImportePesos   + (@MovImporte * @MovTipoCambio),  
@SumaImpuestosPesos = @SumaImpuestosPesos + (@MovImpuestos * @MovTipoCambio),  
@SumaImporteEmbarque= @SumaImporteEmbarque+ (((ISNULL(@MovImporte, 0)+ISNULL(@MovImpuestos, 0))*@MovTipoCambio))*(@MovPorcentaje/100)  
END  
FETCH NEXT FROM crEmbarque INTO @EmbarqueMov, @Estado, @FechaHora, @Forma, @Importe, @DetalleReferencia, @DetalleObservaciones, @EmbarqueMovID, @MovModulo, @MovModuloID, @MovMov, @MovMovID, @MovImporte, @MovImpuestos, @MovMoneda, @MovTipoCambio, @Peso, @Volumen, @Paquetes, @Cliente, @Proveedor, @ClienteEnviarA, @EstadoTipo, @MovPorcentaje  
IF @@ERROR <> 0 SELECT @Ok = 1  
END    
CLOSE crEmbarque  
DEALLOCATE crEmbarque  
IF @CfgGastoTarifa = 1 AND @EstatusNuevo = 'CONCLUIDO' AND @Accion <> 'CANCELAR' AND @Ok IS NULL  
BEGIN  
EXEC spGastoAnexoTarifa @Sucursal, @Empresa, @Modulo, @ID, @Mov, @MovID, @FechaEmision, @FechaRegistro, @Usuario, @CfgAfectarGastoTarifa, @Ok OUTPUT, @OkRef OUTPUT  
END  
IF (@EstatusNuevo = 'CONCLUIDO' OR @Accion = 'CANCELAR') AND @Ok IS NULL  
BEGIN  
EXEC spGastoAnexo @Empresa, @Modulo, @ID, @Accion, @FechaRegistro, @Usuario, @GastoAnexoTotalPesos OUTPUT, @Ok OUTPUT, @OkRef OUTPUT  
EXEC spGastoAnexoEliminar @Empresa, @Modulo, @ID  
END  
IF @Ok IS NULL  
BEGIN  
IF @TienePendientes = 1  
UPDATE Embarque WITH(ROWLOCK)  
SET Estatus = @EstatusNuevo,  
UltimoCambio = @FechaRegistro  
WHERE ID = @ID  
ELSE BEGIN  
IF @EstatusNuevo = 'CANCELADO' SELECT @FechaCancelacion = @FechaRegistro ELSE SELECT @FechaCancelacion = NULL  
IF @EstatusNuevo = 'CONCLUIDO' SELECT @FechaConclusion  = @FechaRegistro ELSE IF @EstatusNuevo <> 'CANCELADO' SELECT @FechaConclusion  = NULL  
IF @EstatusNuevo = 'CONCLUIDO' AND @FechaRetorno IS NULL SELECT @FechaRetorno = @FechaRegistro  
SELECT @DiaRetorno = @FechaRetorno  
EXEC spExtraerFecha @DiaRetorno OUTPUT  
IF @CfgContX = 1 AND @CfgContXGenerar <> 'NO'  
BEGIN  
IF @Estatus =  'SINAFECTAR' AND @EstatusNuevo <> 'CANCELADO' SELECT @GenerarPoliza = 1 ELSE  
IF @Estatus <> 'SINAFECTAR' AND @EstatusNuevo =  'CANCELADO' IF @GenerarPoliza = 1 SELECT @GenerarPoliza = 0 ELSE SELECT @GenerarPoliza = 1  
END  
EXEC spValidarTareas @Empresa, @Modulo, @ID, @EstatusNuevo, @Ok OUTPUT, @OkRef OUTPUT  
UPDATE Embarque WITH(ROWLOCK)  
SET Peso       = NULLIF(@SumaPeso, 0.0),  
Volumen       = NULLIF(@SumaVolumen, 0.0),  
Paquetes       = NULLIF(@SumaPaquetes, 0.0),  
Importe       = NULLIF(@SumaImportePesos, 0.0),  
Impuestos        = NULLIF(@SumaImpuestosPesos, 0.0),  
ImporteEmbarque  = NULLIF(@SumaImporteEmbarque, 0.0),  
Gastos           = NULLIF(@GastoAnexoTotalPesos, 0.0),  
FechaSalida      = @FechaSalida,  
FechaRetorno     = @FechaRetorno,  
DiaRetorno       = @DiaRetorno,  
FechaConclusion  = @FechaConclusion,  
FechaCancelacion = @FechaCancelacion,  
UltimoCambio     = /*CASE WHEN UltimoCambio IS NULL THEN */@FechaRegistro /*ELSE UltimoCambio END*/,  
Estatus          = @EstatusNuevo,  
Situacion        = CASE WHEN @Estatus<>@EstatusNuevo THEN NULL ELSE Situacion END,  
GenerarPoliza    = @GenerarPoliza  
WHERE ID = @ID  
IF @@ERROR <> 0 SELECT @Ok = 1  
END  
IF @EstatusNuevo = 'CONCLUIDO'  
BEGIN  
UPDATE EmbarqueD WITH(ROWLOCK) SET DesembarqueParcial = 0 WHERE ID = @ID AND DesembarqueParcial = 1  
UPDATE EmbarqueMov WITH(ROWLOCK)  
SET Gastos = ISNULL(Gastos, 0) + (((e.Importe+e.Impuestos)*e.TipoCambio) * @GastoAnexoTotalPesos) / (@SumaImportePesos + @SumaImpuestosPesos)  
FROM EmbarqueMov e, EmbarqueD d  WITH(NOLOCK) 
WHERE d.ID = @ID AND d.EmbarqueMov = e.ID  
UPDATE EmbarqueMov WITH(ROWLOCK)  
SET Concluido = 1  
WHERE AsignadoID = @ID  
IF @CfgBaseProrrateo = 'IMPORTE'  
UPDATE Venta WITH(ROWLOCK)  
SET EmbarqueGastos = ISNULL(EmbarqueGastos, 0) + (((e.Importe+e.Impuestos)*e.TipoCambio) * @GastoAnexoTotalPesos) / (@SumaImportePesos + @SumaImpuestosPesos)  
FROM EmbarqueMov e WITH(NOLOCK), EmbarqueD d WITH(NOLOCK), Venta v  
WHERE d.ID = @ID AND d.EmbarqueMov = e.ID AND e.Modulo = 'VTAS' AND e.ModuloID = v.ID  
ELSE  
IF @CfgBaseProrrateo = 'PAQUETES'  
UPDATE Venta WITH(ROWLOCK)  
SET EmbarqueGastos = ISNULL(EmbarqueGastos, 0) + (e.Paquetes * @GastoAnexoTotalPesos) / @SumaPaquetes  
FROM EmbarqueMov e WITH(NOLOCK), EmbarqueD d WITH(NOLOCK), Venta v  
WHERE d.ID = @ID AND d.EmbarqueMov = e.ID AND e.Modulo = 'VTAS' AND e.ModuloID = v.ID  
ELSE  
IF @CfgBaseProrrateo = 'PESO'  
UPDATE Venta WITH(ROWLOCK)  
SET EmbarqueGastos = ISNULL(EmbarqueGastos, 0) + (e.Peso * @GastoAnexoTotalPesos) / @SumaPeso  
FROM EmbarqueMov e WITH(NOLOCK), EmbarqueD d WITH(NOLOCK), Venta v  
WHERE d.ID = @ID AND d.EmbarqueMov = e.ID AND e.Modulo = 'VTAS' AND e.ModuloID = v.ID  
ELSE  
IF @CfgBaseProrrateo = 'VOLUMEN'  
UPDATE Venta WITH(ROWLOCK)  
SET EmbarqueGastos = ISNULL(EmbarqueGastos, 0) + (e.Volumen * @GastoAnexoTotalPesos) / @SumaVolumen  
FROM EmbarqueMov e WITH(NOLOCK), EmbarqueD d WITH(NOLOCK), Venta v  
WHERE d.ID = @ID AND d.EmbarqueMov = e.ID AND e.Modulo = 'VTAS' AND e.ModuloID = v.ID  
ELSE  
IF @CfgBaseProrrateo = 'PESO/VOLUMEN'  
UPDATE Venta WITH(ROWLOCK)  
SET EmbarqueGastos = ISNULL(EmbarqueGastos, 0) + (((ISNULL(e.Peso, 0)*ISNULL(e.Volumen, 0))*e.TipoCambio) * @GastoAnexoTotalPesos) / (@SumaPeso * @SumaVolumen)  
FROM EmbarqueMov e WITH(NOLOCK), EmbarqueD d WITH(NOLOCK), Venta v  
WHERE d.ID = @ID AND d.EmbarqueMov = e.ID AND e.Modulo = 'VTAS' AND e.ModuloID = v.ID  
END  
UPDATE Vehiculo WITH(ROWLOCK)  
SET Estatus = CASE WHEN @EstatusNuevo = 'PENDIENTE' THEN 'ENTRANSITO' ELSE 'DISPONIBLE' END  
WHERE Vehiculo = @Vehiculo  
IF @@ERROR <> 0 SELECT @Ok = 1  
END  
/*IF @Cxp = 1 AND @EstatusNuevo = 'CONCLUIDO' AND @Ok IS NULL  
BEGIN  
SELECT @CxpConcepto = Concepto FROM Vehiculo WHERE Vehiculo = @Vehiculo  
EXEC spGenerarCx @Sucursal, @SucursalOrigen, @SucursalDestino, @Accion, NULL, @Empresa, @Modulo, @ID, @Mov, @MovID, @MovTipo, @CxpMoneda, @CxpTipoCambio,  
@FechaEmision, @CxpConcepto, @Proyecto, @Usuario, @Autorizacion, @CxpReferencia, @DocFuente, @Observaciones,  
@FechaRegistro, @Ejercicio, @Periodo,  
@CxpCondicion, @CxpVencimiento, @CxpProveedor, NULL, NULL, 'CXP', NULL, NULL,  
@CxpImporte, @CxpImpuestos, NULL, NULL,  
NULL, NULL, NULL, NULL, NULL, NULL,  
@CxModulo OUTPUT, @CxMov OUTPUT, @CxMovID OUTPUT,  
@Ok OUTPUT, @OkRef OUTPUT  
END*/  
IF @Vehiculo IS NOT NULL  
BEGIN  
IF (SELECT TieneMovimientos FROM Vehiculo WITH(NOLOCK) WHERE Vehiculo = @Vehiculo) = 0  
UPDATE Vehiculo WITH(ROWLOCK) SET TieneMovimientos = 1 WHERE Vehiculo = @Vehiculo  
END  
IF @Ok IS NULL OR @Ok BETWEEN 80030 AND 81000  
EXEC spMovFinal @Empresa, @Sucursal, @Modulo, @ID, @Estatus, @EstatusNuevo, @Usuario, @FechaEmision, @FechaRegistro, @Mov, @MovID, @MovTipo, @IDGenerar, @Ok OUTPUT, @OkRef OUTPUT  
IF @Accion = 'CANCELAR' AND @EstatusNuevo = 'CANCELADO' AND @Ok IS NULL  
EXEC spCancelarFlujo @Empresa, @Modulo, @ID, @Ok OUTPUT  
IF @Conexion = 0  
IF @Ok IS NULL OR @Ok BETWEEN 80030 AND 81000  
COMMIT TRANSACTION  
ELSE  
ROLLBACK TRANSACTION  
RETURN  
END  
  
  
GO
