SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].[spCxVerificar]  
@ID                 int,  
@Accion   char(20),  
@Empresa            char(5),  
@Usuario   char(10),  
@Autorizacion  char(10),  
@Mensaje   int,  
@Modulo         char(5),  
@Mov                char(20),  
@MovID   varchar(20),  
@MovTipo         char(20),  
@MovMoneda   char(10),  
@MovTipoCambio  float,  
@FechaEmision  datetime,  
@Condicion   varchar(50) OUTPUT,  
@Vencimiento  datetime    OUTPUT,  
@FormaPago   varchar(50),  
@Referencia   varchar(50),  
@Contacto   char(10),  
@ContactoTipo  char(20),  
@ContactoEnviarA  int,  
@ContactoMoneda  char(10),  
@ContactoFactor  float,  
@ContactoTipoCambio  float,  
@Importe   money,  
@ValesCobrados  money,  
@Impuestos   money,  
@Retencion   money,  
@Retencion2   money,  
@Retencion3   money,  
@Saldo   money,  
@CtaDinero   char(10),  
@Agente   char(10),  
@AplicaManual               bit,  
@ConDesglose  bit,  
@CobroDesglosado  money,  
@CobroDelEfectivo  money,  
@CobroCambio  money,  
@Indirecto   bit,  
@Conexion   bit,  
@SincroFinal  bit,  
@Sucursal   int,  
@SucursalDestino  int,  
@SucursalOrigen  int,  
@EstatusNuevo        char(15),  
@AfectarCantidadPendiente   bit,  
@AfectarCantidadA    bit,  
@CfgContX   bit,  
@CfgContXGenerar  char(20),  
@CfgEmbarcar  bit,  
@AutoAjuste   money,  
@AutoAjusteMov  money,  
/*@CfgAplicaDif  bit,*/  
@CfgDescuentoRecargos bit,  
@CfgFormaCobroDA  varchar(50),  
@CfgRefinanciamientoTasa float,  
@CfgAnticiposFacturados bit,  
@CfgValidarPPMorosos bit,  
@CfgAC   bit,  
@Pagares   bit,  
@OrigenTipo   char(10),  
@OrigenMovTipo  char(20),  
@MovAplica   char(20),  
@MovAplicaID  varchar(20),  
@MovAplicaMovTipo  char(20),  
@AgenteNomina  bit,  
@RedondeoMonetarios  int,  
@Autorizar   bit      OUTPUT,  
@Ok                 int          OUTPUT,  
@OkRef              varchar(255) OUTPUT,  
@INSTRUCCIONES_ESP  varchar(20)  = NULL  
  
AS BEGIN  
DECLARE  
@DA    bit,  
@AplicaMov   char(20),  
@AplicaMovID  varchar(20),  
@AplicaSaldo  money,  
@AplicaImporteTotal  money,  
@AplicaContacto  char(10),  
@AplicaMoneda  char(10),  
@AplicaAforo  money,  
@MovAplicaEstatus  char(15),  
@ContactoImporte  money,  
@CANTSaldo   money,  
@ImporteTotal  money,  
@ImporteAplicado  money,  
@Efectivo   money,  
@Anticipos   money,  
@CtaDineroMoneda  char(10),  
@CtaDineroTipo  char(20),  
@TieneDescuentoRecargos bit,  
@AplicaPosfechado  bit,  
@ContactoEstatus  char(15),  
@ValeEstatus  char(15),  
@AforoImporte  money,  
@TarjetasCobradas  money,    
@FormaCobroTarjetas  varchar(50),  
@Importe1   money,  
@Importe2   money,  
@Importe3   money,  
@Importe4   money,  
@Importe5   money,  
@FormaCobro1  varchar(50),  
@FormaCobro2  varchar(50),  
@FormaCobro3  varchar(50),  
@FormaCobro4  varchar(50),  
@FormaCobro5  varchar(50)   
SELECT @AplicaPosfechado = 0,  
@Autorizar     = 0,  
@AforoImporte     = 0.0,  
@DA     = 0  
IF @MovTipo IN ('CXC.VV', 'CXC.OV', 'CXC.DV', 'CXC.AV', 'CXC.SD', 'CXC.SCH', 'CXP.SD', 'CXP.SCH') AND @Conexion = 0 SELECT @Ok = 60160  
IF @MovTipo NOT IN ('CXC.C','CXC.CD','CXC.D','CXC.DM','CXC.A','CXC.RA','CXC.AR','CXC.AA','CXC.DE','CXC.F','CXC.FA','CXC.DFA','CXC.AF','CXC.CA','CXC.VV','CXC.OV','CXC.IM','CXC.RM','CXC.NC','CXC.DV','CXC.NCP','CXC.CAP',  
'CXP.A','CXP.AA','CXP.DE','CXP.F','CXP.AF','CXP.CA','CXP.NC','CXP.NCP','CXP.CAP','CXP.NCF', -- Se agrego la clave del acuerdo proveedor ALQG  
'AGENT.P','AGENT.CO','CXC.FAC','CXP.FAC') AND @Impuestos <> 0.0  
SELECT @Ok = 20870  
IF @Accion = 'CANCELAR'  
BEGIN  
IF @Indirecto = 1 AND @Conexion = 0 SELECT @Ok = 60180  
IF @OrigenMovTipo = 'CXC.NCF' AND @Conexion = 0 SELECT @Ok = 60180  
IF @MovTipo IN ('CXC.F', 'CXC.CA', 'CXC.CAP', 'CXC.CAD', 'CXC.D', 'CXC.DM', 'CXP.F', 'CXP.CA', 'CXP.CAP', 'CXP.CAD', 'CXP.D', 'CXP.DM') AND @Condicion IS NOT NULL  
BEGIN  
IF @CfgAC = 1 OR EXISTS(SELECT * FROM Condicion With(NoLock) WHERE Condicion = @Condicion AND DA = 1)  
BEGIN  
EXEC spCxCancelarDocAuto @Empresa, @Usuario, @Modulo, @ID, @Mov, @MovID, 1, NULL, @Ok OUTPUT, @OkRef OUTPUT  
IF @Ok IS NULL SELECT @DA = 1  
END  
END  
IF @DA=0 AND @MovTipo IN ('CXC.F','CXC.FA','CXC.FAC','CXC.DAC','CXC.AF','CXC.CA', 'CXC.CAD','CXC.CAP','CXC.VV','CXC.OV','CXC.IM','CXC.RM','CXC.D','CXC.DM','CXC.DA','CXC.DP', 'CXC.CD',  
'CXP.F','CXP.AF','CXP.FAC','CXP.DAC','CXP.CA','CXP.CAD','CXP.CAP','CXP.D','CXP.DM','CXP.PAG','CXP.DA','CXP.DP', 'CXP.CD', 'CXP.FAC',  
'AGENT.C', 'AGENT.D', 'AGENT.A', 'CXC.A','CXC.AR','CXC.NC','CXC.NCD','CXC.NCF','CXC.DV','CXC.NCP','CXP.A','CXP.NC','CXP.NCD','CXP.NCF','CXP.NCP',  
'CXC.SD', 'CXC.SCH', 'CXP.SD', 'CXP.SCH')  
BEGIN  
IF NOT (@MovTipo = 'CXC.OV' AND @Conexion = 1)  
BEGIN  
IF @MovMoneda = @ContactoMoneda  
BEGIN  
IF ROUND(@Saldo + @AforoImporte, 2) <> ROUND(@Importe + @Impuestos - @Retencion - @Retencion2 - @Retencion3, 2) SELECT @Ok = 60060  
END ELSE  
BEGIN  
IF ROUND((@Saldo  + @AforoImporte) * @ContactoTipoCambio, 2) <> ROUND((@Importe + @Impuestos - @Retencion - @Retencion2 - @Retencion3) * @MovTipoCambio, 2) SELECT @Ok = 60060  
END  
END  
IF @Ok IS NOT NULL AND @MovTipo IN ('CXC.CA','CXC.CAD','CXC.CAP','CXC.A','CXC.AR','CXC.NC','CXC.NCD','CXC.NCF','CXC.DV','CXC.NCP',  
'CXP.CA','CXP.CAD','CXP.CAP','CXP.A','CXP.NC','CXP.NCD','CXP.NCF','CXP.NCP')  
BEGIN  
IF @Modulo = 'CXC' AND EXISTS (SELECT * FROM Cxc c With(NoLock), CxcD d With(NoLock) WHERE c.ID = @ID AND c.AplicaManual = 1 AND c.ID = d.ID) SELECT @Ok = NULL ELSE  
IF @Modulo = 'CXP' AND EXISTS (SELECT * FROM Cxp c With(NoLock), CxpD d With(NoLock) WHERE c.ID = @ID AND c.AplicaManual = 1 AND c.ID = d.ID) SELECT @Ok = NULL  
END  
IF @OrigenTipo IN ('PAGARE','PP/RECARGO' ,'RETENCION') AND @Conexion = 0 SELECT @Ok = 60072   
IF @OrigenTipo = 'ENDOSO' AND @Conexion = 0 SELECT @Ok = 60070  
END  
IF @MovTipo = 'CXC.FA'  
BEGIN  
SELECT @CANTSaldo = 0.0  
SELECT @CANTSaldo = SUM(ISNULL(ROUND(Saldo, @RedondeoMonetarios), 0.0)) FROM Saldo With(NoLock) WHERE Rama = 'CANT' AND Empresa = @Empresa AND Moneda = @MovMoneda AND Cuenta = @Contacto  
IF ROUND(@Importe + @Impuestos - @Retencion - @Retencion2 - @Retencion3, @RedondeoMonetarios) > @CANTSaldo  
SELECT @Ok = 30410  
END  
IF @Conexion = 0  
BEGIN  
IF @OrigenMovTipo IS NOT NULL  
BEGIN  
IF @MovTipo IN ('CXC.F','CXC.CA', 'CXC.FA','CXC.AF','CXC.A','CXC.AR','CXC.NC','CXC.NCD','CXC.NCF','CXC.DV','CXC.NCP','CXC.AJE', 'CXP.F','CXP.AF','CXP.A','CXP.NC','CXP.NCD','CXP.NCF','CXP.NCP','CXP.AJE', 'AGENT.C', 'AGENT.D')  
IF EXISTS (SELECT * FROM MovFlujo With(NoLock) WHERE Cancelado = 0 AND Empresa = @Empresa AND DModulo = @Modulo AND DID = @ID AND OModulo <> DModulo)  
SELECT @Ok = 60070  
IF @MovTipo IN ('CXC.A', 'CXC.AR', 'CXP.A') AND @OrigenMovTipo IS NOT NULL  
SELECT @Ok = 60070  
END  
END  
END ELSE  
BEGIN  
IF @MovTipo IN ('CXC.RE', 'CXP.RE') AND @OrigenTipo <> 'AUTO/RE' SELECT @Ok = 25410  
IF @Modulo = 'CXC'   SELECT @ContactoEstatus = Estatus FROM Cte    With(NoLock) WHERE Cliente   = @Contacto ELSE  
IF @Modulo = 'CXP'   SELECT @ContactoEstatus = Estatus FROM Prov   With(NoLock) WHERE Proveedor = @Contacto ELSE  
IF @Modulo = 'AGENT' SELECT @ContactoEstatus = Estatus FROM Agente With(NoLock) WHERE Agente    = @Contacto  
IF @Modulo = 'CXP' AND @ContactoEstatus = 'BLOQUEADO' AND @Autorizacion IS NULL  
BEGIN  
SELECT @Ok = 65032, @OkRef = @Contacto, @Autorizar = 1  
EXEC xpOk_65032 @Empresa, @Usuario, @Accion, @Modulo, @ID, @Ok OUTPUT, @OkRef OUTPUT  
END  
IF @MovMoneda = @ContactoMoneda AND @MovTipoCambio <> @ContactoTipoCambio AND @MovTipo NOT IN ('CXC.NCF', 'CXP.NCF') SELECT @Ok = 35110  
IF @Contacto IS NULL  
IF @Modulo = 'CXC' SELECT @Ok = 40010 ELSE SELECT @Ok = 40020  
IF @MovTipo IN ('CXC.FA','CXC.AF','CXC.DE','CXC.DI','CXC.ANC','CXC.ACA','CXP.ACA','CXC.RA','CXC.FAC','CXC.DAC','CXC.AJE','CXC.AJR', 'CXC.DA', 'CXP.AF','CXP.DE','CXP.ANC','CXP.RA','CXP.FAC','CXP.DAC','CXP.AJE','CXP.AJR', 'CXP.DA') 
	AND @MovMoneda <> @ContactoMoneda  
SELECT @Ok = 30080  
IF @MovTipo IN ('CXC.F','CXC.FA','CXC.AF','CXC.CA', 'CXC.CAD','CXC.CAP','CXC.VV','CXC.CD','CXC.D','CXC.DM','CXC.DA','CXC.DP','CXC.NCP', 'CXP.F','CXP.AF','CXP.CA', 'CXP.CAD','CXP.CAP','CXP.CD','CXP.D','CXP.DM', 'CXP.PAG','CXP.DA','CXP.DP','CXP.NCP')  
EXEC spVerificarVencimiento @Condicion, @Vencimiento, @FechaEmision, @Ok OUTPUT  
IF @MovTipo = 'CXC.C' AND @ConDesglose = 1  
BEGIN  
IF @CobroCambio > @CobroDesglosado SELECT @Ok = 30250 ELSE  
IF @CobroDelEfectivo < 0.0 SELECT @Ok = 30100  
END  
IF @MovTipo IN ('CXC.AE','CXC.DE', 'CXP.AE','CXP.DE') OR (@MovTipo = 'CXC.C' AND @ConDesglose = 1 AND @CobroDelEfectivo > 0.0)  
BEGIN  
SELECT @Efectivo = 0.0  
IF @Modulo = 'CXC'  
BEGIN  
SELECT @Efectivo = ISNULL(Saldo, 0.0) FROM CxcEfectivo With(NoLock) WHERE Empresa = @Empresa AND Cliente = @Contacto AND Moneda = @MovMoneda  
IF @MovTipo = 'CXC.C'  
BEGIN  
IF ROUND(@CobroDelEfectivo, 0) > ROUND(-@Efectivo, 0) SELECT @Ok = 30090  
END ELSE  
IF ROUND(@Importe, 0) > ROUND(-@Efectivo, 0) AND @MovTipo NOT IN ('CXC.DE', 'CXP.DE') SELECT @Ok = 30090  
END ELSE  
IF @Modulo = 'CXP'  
BEGIN  
SELECT @Efectivo = ISNULL(Saldo, 0.0) FROM CxpEfectivo With(NoLock) WHERE Empresa = @Empresa AND Proveedor = @Contacto AND Moneda = @MovMoneda  
IF ROUND(@Importe, 0) < ROUND(@Efectivo, 0) SELECT @Ok = 30090  
END  
END  
IF @MovTipo = 'CXC.FA' AND @CfgAnticiposFacturados = 0 SELECT @Ok = 70070  
IF @MovTipo = 'CXP.PAG' AND @Pagares = 0 SELECT @Ok = 30560  
IF @Ok IS NOT NULL RETURN  
IF (@Importe + @Impuestos - @Retencion - @Retencion2 - @Retencion3 < 0.0 OR ROUND(@Importe, 2) < 0.0 OR ROUND(@Impuestos, 2) < 0.0) AND @MovTipo NOT IN ('CXC.AJE', 'CXC.AJR', 'CXC.AJM', 'CXC.AJA', 'CXP.AJE', 'CXP.AJR', 'CXP.AJM', 'CXP.AJA', 'AGENT.P',
		'AGENT.CO', 'AGENT.C','AGENT.D', 'CXC.RE', 'CXP.RE') SELECT @Ok = 30100  
SELECT @ImporteTotal = @Importe + @Impuestos - @Retencion - @Retencion2 - @Retencion3  
IF @MovTipo IN ('CXC.ANC', 'CXC.ACA', 'CXP.ACA', 'CXC.RA', 'CXC.FAC', 'CXC.DAC', 'CXP.ANC', 'CXP.RA', 'CXP.FAC', 'CXP.DAC') AND @Accion <> 'CANCELAR'  
BEGIN  
IF @MovAplica IS NULL OR @MovAplicaID IS NULL SELECT @Ok = 30170  
IF @Ok IS NULL  
BEGIN  
IF @Modulo = 'CXC' SELECT @AplicaSaldo = ISNULL(Saldo, 0.0), @AplicaImporteTotal = ISNULL(Importe, 0.0) + ISNULL(Impuestos, 0.0),          @AplicaMoneda = ClienteMoneda,   @AplicaContacto = Cliente,   @MovAplicaEstatus = Estatus FROM Cxc With(NoLock)
				WHERE Empresa = @Empresa AND Mov = @MovAplica AND MovID = @MovAplicaID AND Estatus NOT IN ('SINAFECTAR', 'CONFIRMAR', 'BORRADOR', 'CANCELADO') ELSE  
IF @Modulo = 'CXP' SELECT @AplicaSaldo = ISNULL(Saldo, 0.0), @AplicaImporteTotal = ISNULL(Importe, 0.0) + ISNULL(Impuestos, 0.0), @AplicaAforo = ISNULL(Aforo, 0.0), @AplicaMoneda = ProveedorMoneda, @AplicaContacto = Proveedor, @MovAplicaEstatus = Estatus 
					FROM Cxp With(NoLock) WHERE Empresa = @Empresa AND Mov = @MovAplica AND MovID = @MovAplicaID AND Estatus NOT IN ('SINAFECTAR', 'CONFIRMAR', 'BORRADOR', 'CANCELADO')  
IF @ImporteTotal > @AplicaSaldo SELECT @Ok = 30180 ELSE  
IF @MovAplicaEstatus <> 'PENDIENTE' SELECT @Ok = 30190 ELSE  
IF @MovMoneda <> @AplicaMoneda SELECT @Ok = 20196 ELSE  
IF @MovTipo IN ('CXC.ANC', 'CXC.ACA', 'CXP.ACA', 'CXP.ANC') AND @Contacto <> @AplicaContacto SELECT @Ok = 30192 ELSE  
IF @MovTipo IN ('CXC.RA', 'CXP.RA') AND @Contacto = @AplicaContacto SELECT @Ok = 30500 ELSE  
IF @MovTipo IN ('CXC.FAC', 'CXC.DAC', 'CXP.FAC', 'CXP.DAC')  
BEGIN  
IF (/*UPPER(@ContactoTipo) <> 'INST FINANCIERA' OR */@Contacto = @AplicaContacto) SELECT @Ok = 30505  
END  
END  
END  
IF @MovTipo IN ('CXC.CD', 'CXP.CD') AND @CtaDinero IS NULL SELECT @Ok = 40030  
IF @MovTipo IN ('CXC.RA', 'CXP.RA') AND @MovAplicaMovTipo NOT IN ('CXC.A', 'CXC.AR', 'CXP.A') SELECT @Ok = 20198  
IF @MovTipo = 'AGENT.A' AND @AgenteNomina = 1 SELECT @OK = 30360  
IF @MovTipo IN ('CXC.C','CXC.A','CXC.AR','CXC.AA','CXC.DE','CXC.DI','CXC.DC',  
'CXP.P','CXP.A','CXP.AA','CXP.DE','CXP.DC','CXC.DFA',  
'AGENT.P','AGENT.CO','AGENT.A') AND @CtaDinero IS NOT NULL AND @Ok IS NULL  
BEGIN  
SELECT @CtaDineroMoneda = Moneda, @CtaDineroTipo = Tipo FROM CtaDinero With(NoLock) WHERE CtaDinero = @CtaDinero  
IF @CtaDineroTipo <> 'Caja' AND @MovMoneda <> @CtaDineroMoneda SELECT @Ok = 30200  
END  
IF ((@MovTipo IN ('CXC.C','CXC.AJM','CXC.AJA','CXC.NET','CXC.NC','CXC.NCD','CXC.CA','CXC.CAD','CXC.CAP','CXC.NCF','CXC.DV','CXC.NCP','CXC.D','CXC.DM','CXC.DA','CXC.DP','CXC.AE','CXC.ANC','CXC.ACA','CXP.ACA','CXC.DC',  
'CXP.P','CXP.AJM','CXP.AJA','CXP.NET','CXP.NC','CXP.NCD','CXP.CA','CXP.CAD','CXP.CAP','CXP.NCF','CXP.NCP','CXP.D','CXP.DM', 'CXP.PAG','CXP.DA','CXP.DP','CXP.AE','CXP.ANC','CXP.DC') AND @AplicaManual = 1) OR   
(@MovTipo IN ('CXC.IM', 'CXC.RM', 'AGENT.P','AGENT.CO')))  
AND @Accion IN ('AFECTAR', 'VERIFICAR') AND @Ok IS NULL  
BEGIN  
  --select @AutoAjusteMov as 'AutoajusteMov'  -- yrg
EXEC spCxAplicar @ID, @Accion, @Empresa, @Usuario, @Modulo, @Mov, NULL, @MovTipo, @MovMoneda, @MovTipoCambio,  
NULL, NULL, NULL, @Condicion OUTPUT, @Vencimiento OUTPUT, NULL, @FechaEmision, NULL, NULL, NULL,  
@Contacto, @ContactoEnviarA, @ContactoMoneda, @ContactoFactor, @ContactoTipoCambio, @Agente, @Importe, @Impuestos, @Retencion, @Retencion2, @Retencion3, @ImporteTotal,  
@Conexion, @SincroFinal, @Sucursal, @SucursalDestino, @SucursalOrigen, @OrigenTipo, @OrigenMovTipo, @MovAplica, @MovAplicaID, @MovAplicaMovTipo,  
@CfgContX, @CfgContXGenerar, @CfgEmbarcar, @AutoAjuste, @AutoAjusteMov, @CfgDescuentoRecargos, @CfgRefinanciamientoTasa,  
/*0, NULL, @CfgAplicaDif, 0, */0, NULL, NULL, 0, NULL,  
0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, @CfgAC,  
1, @TieneDescuentoRecargos OUTPUT, @AplicaPosfechado OUTPUT, @ImporteAplicado OUTPUT,  
@RedondeoMonetarios, @Ok OUTPUT, @OkRef OUTPUT

---select @ImporteAplicado as 'ImpAplicado YRG'  

IF @Ok IS NULL AND @CfgValidarPPMorosos = 1  
IF EXISTS(SELECT * FROM CxcD With(NoLock) WHERE ID = @ID AND ISNULL(DescuentoRecargos, 0) < 0.0)  
IF EXISTS(SELECT *  
FROM CxcPendiente p With(NoLock), MovTipo  mt  With(NoLock) 
WHERE p.Empresa = @Empresa  
AND p.Cliente = @Contacto  
AND mt.Modulo = 'CXC' AND mt.Mov = p.Mov AND mt.Clave NOT IN ('CXC.A', 'CXC.AR', 'CXC.NC', 'CXC.NCD','CXC.NCF')  
AND ISNULL(p.DiasMoratorios, 0) > 0)  
SELECT @Ok = 65090  
END  
IF @AplicaPosfechado = 1  
BEGIN  
IF @MovTipo IN ('CXC.C','CXP.P')  
BEGIN  
IF ROUND(@ImporteAplicado, @RedondeoMonetarios)<>ROUND(@ImporteTotal, @RedondeoMonetarios) SELECT @Ok = 30230 ELSE  
IF @Modulo = 'CXC' IF (SELECT COUNT(*) FROM CxcD With(NoLock) WHERE ID = @ID) > 1 SELECT @Ok = 30390 ELSE  
IF @Modulo = 'CXP' IF (SELECT COUNT(*) FROM CxpD With(NoLock) WHERE ID = @ID) > 1 SELECT @Ok = 30390  
END ELSE  
SELECT @Ok = 30380  
END  
SELECT @FormaCobroTarjetas = CxcFormaCobroTarjetas FROM EmpresaCfg With(NoLock) WHERE Empresa = @Empresa  
SELECT @TarjetasCobradas = 0.0  
SELECT @ConDesglose = ConDesglose,  
@Importe1 = ISNULL(Importe1, 0), @FormaCobro1 = FormaCobro1,  
@Importe2 = ISNULL(Importe2, 0), @FormaCobro2 = FormaCobro2,  
@Importe3 = ISNULL(Importe3, 0), @FormaCobro3 = FormaCobro3,  
@Importe4 = ISNULL(Importe4, 0), @FormaCobro4 = FormaCobro4,  
@Importe5 = ISNULL(Importe5, 0), @FormaCobro5 = FormaCobro5  
FROM Cxc  With(NoLock) 
WHERE ID = @ID  
IF @ConDesglose = 0 AND @ImporteTotal > 0.0 AND @FormaPago = @FormaCobroTarjetas  
BEGIN  
SELECT @TarjetasCobradas = @ImporteTotal, @FormaCobro1 = @FormaPago  
END  
ELSE  
BEGIN  
IF @FormaCobro1 = @FormaCobroTarjetas SELECT @TarjetasCobradas = @TarjetasCobradas + @Importe1  
IF @FormaCobro2 = @FormaCobroTarjetas SELECT @TarjetasCobradas = @TarjetasCobradas + @Importe2  
IF @FormaCobro3 = @FormaCobroTarjetas SELECT @TarjetasCobradas = @TarjetasCobradas + @Importe3  
IF @FormaCobro4 = @FormaCobroTarjetas SELECT @TarjetasCobradas = @TarjetasCobradas + @Importe4  
IF @FormaCobro5 = @FormaCobroTarjetas SELECT @TarjetasCobradas = @TarjetasCobradas + @Importe5  
END  
IF @ValesCobrados > 0.0 OR @TarjetasCobradas > 0.0  
BEGIN  
IF @MovTipo IN ('CXC.A', 'CXC.AR', 'CXC.AA', 'CXC.C')  
EXEC spValeValidarCobro @Empresa, @Modulo, @ID, @Accion, @FechaEmision, @ValesCobrados, @TarjetasCobradas, @MovMoneda, @Ok OUTPUT, @OkRef OUTPUT  
ELSE  
SELECT @Ok = 36100, @OkRef = @FormaPago  
END  
IF @MovTipo IN ('CXC.A','CXC.AR','CXC.AA','CXC.C') AND UPPER(@FormaPago) = UPPER(@CfgFormaCobroDA) AND @Accion <> 'CANCELAR' AND @ConDesglose = 0 AND @Ok IS NULL  
IF (SELECT CxcDARef FROM EmpresaCfg With(NoLock) WHERE Empresa = @Empresa) = 0  
IF NOT EXISTS (SELECT * FROM Dinero With(NoLock) WHERE Empresa = @Empresa AND Estatus = 'PENDIENTE' AND CtaDinero = @CtaDinero AND ROUND(Importe, @RedondeoMonetarios) = ROUND(@ImporteTotal, @RedondeoMonetarios) AND Moneda = @MovMoneda)  
BEGIN  
SELECT @OkRef = NULL  
SELECT @OkRef = MIN(CtaDinero) FROM Dinero With(NoLock) WHERE Empresa = @Empresa AND Estatus = 'PENDIENTE' AND ROUND(Importe, @RedondeoMonetarios) = ROUND(@ImporteTotal, @RedondeoMonetarios) AND Moneda = @MovMoneda  
IF @OkRef IS NULL  
SELECT @Ok = 35160  
ELSE SELECT @Ok = 35165  
END  
IF @MovTipo IN ('AGENT.P','AGENT.CO') AND ROUND(@ImporteAplicado, @RedondeoMonetarios) < 0.0 SELECT @Ok = 30100  
END  
IF @Accion NOT IN ('GENERAR', 'CANCELAR') AND @Ok IS NULL  
EXEC spValidarMovImporteMaximo @Usuario, @Modulo, @Mov, @ID, @Ok OUTPUT, @OkRef OUTPUT  
IF @Ok IS NULL  
EXEC xpCxVerificar @ID, @Accion, @Empresa, @Usuario, @Modulo, @Mov, @MovID, @MovTipo, @MovMoneda, @MovTipoCambio,  
@FechaEmision, @Condicion, @Vencimiento, @FormaPago, @Contacto, @ContactoMoneda, @ContactoFactor, @ContactoTipoCambio, @Importe, @Impuestos, @Saldo, @CtaDinero, @AplicaManual, @ConDesglose,  
@CobroDesglosado, @CobroDelEfectivo, @CobroCambio,  
@Indirecto, @Conexion, @SincroFinal, @Sucursal, @EstatusNuevo, @AfectarCantidadPendiente, @AfectarCantidadA, @CfgContX, @CfgContXGenerar, @CfgEmbarcar, @AutoAjuste, @CfgFormaCobroDA, @CfgRefinanciamientoTasa,  
@MovAplica, @MovAplicaID, @Ok OUTPUT, @OkRef OUTPUT  
RETURN  
END  
GO
