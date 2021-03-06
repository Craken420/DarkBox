SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

-- ========================================================================================================================================
-- NOMBRE			: spDocAuto
-- AUTOR			:  
-- FECHA			:  
-- DESARROLLO		:  
-- MODULO			: Ventas
-- ULTIMA TEAM			: 
-- ULTIMA OFICIAL		: 
-- ========================================================================================================================================
-- FECHA Y AUTOR MODIFICACION:  31/07/2018     Por: Marco Valdovinos  
-- NOTA : Se hace corrección porque cuando se hace una factura, credilna etc,  desde el punto de venta, pone espacios entre el movid y el el numero de consecutivo 
-- y por eso en cxc no sale completa referencia
-- ========================================================================================================================================

CREATE PROCEDURE [dbo].[spDocAuto] @ID int,
@InteresesMov char(20),
@DocMov char(20),
@Usuario char(10) = NULL,
@Conexion bit = 0,
@SincroFinal bit = 0,
@Ok int = NULL OUTPUT,
@OkRef varchar(255) = NULL OUTPUT

AS
BEGIN
  DECLARE @Sucursal int,
          @a int,
          @Empresa char(5),
          @Modulo char(5),
          @Cuenta char(10),
          @Moneda char(10),
          @Mov char(20),
          @MovID varchar(20),
          @MovTipo char(20),
          @MovAplicaImporte money,
          @Condicion varchar(50),
          @Importe money,
          @Impuestos money,
          @ImporteDocumentar money,
          @ImporteTotal money,
          @Intereses money,
          @InteresesImpuestos money,
          @InteresesConcepto varchar(50),
          @InteresesAplicaImporte money,
          @NumeroDocumentos int,
          @PrimerVencimiento datetime,
          @Periodo char(15),
          @Concepto varchar(50),
          @Observaciones varchar(100),
          @Estatus char(15),
          @DocEstatus char(15),
          @FechaEmision datetime,
          @FechaRegistro datetime,
          @MovUsuario char(10),
          @Proyecto varchar(50),
          @Referencia varchar(50),
          @TipoCambio float,
          @Saldo money,
          @InteresesID int,
          @InteresesMovID varchar(20),
          @DocID int,
          @DocMovID varchar(20),
          @DocImporte money,
          @SumaImporte1 money,
          @SumaImporte2 money,
          @SumaImporte3 money,
          @DocAutoFolio char(20),
          @Importe1 money,
          @Importe2 money,
          @Importe3 money,
          @Dif money,
          @Vencimiento datetime,
          @Dia int,
          @EsQuince bit,
          @ImpPrimerDoc bit,
          @Mensaje varchar(255),
          @PPFechaEmision datetime,
          @PPVencimiento datetime,
          @PPDias int,
          @PPFechaProntoPago datetime,
          @PPDescuentoProntoPago float,
          @ClienteEnviarA int,
          @Cobrador varchar(50),
          @PersonalCobrador char(10),
          @Agente char(10),
          @DesglosarImpuestos bit,
          @AplicaImpuestos money,
          @RedondeoMonetarios int,
          @Tasa varchar(50),
          @RamaID int,
          @InteresPorcentaje float,
          @PagoMensual money,
          @CapitalAnterior money,
          @CapitalInsoluto money,
          @CfgDocAutoBorrador bit,
          @CorteDias int,
          @MenosDias int

  SET @CorteDias = 2 -- FOX QUEMADO DIAS DESPUES DE LA QUINCENA DA DIAS 17 y 2 DE CORTE
  SELECT
    @RedondeoMonetarios = RedondeoMonetarios
  FROM Version WITH (NOLOCK)
  SELECT
    @EsQuince = 0,
    @Saldo = 0.0,
    @Proyecto = NULL,
    @FechaRegistro = GETDATE(),
    @SumaImporte1 = 0.0,
    @SumaImporte2 = 0.0,
    @SumaImporte3 = 0.0,
    @DesglosarImpuestos = 0
  SELECT
    @Sucursal = Sucursal,
    @Empresa = Empresa,
    @Modulo = Modulo,
    @Cuenta = Cuenta,
    @Moneda = Moneda,
    @Mov = Mov,
    @MovID = MovID,
    @ImporteDocumentar = ImporteDocumentar,
    @Intereses = ISNULL(Intereses, 0.0),
    @InteresesImpuestos = ISNULL(InteresesImpuestos, 0.0),
    @InteresesConcepto = InteresesConcepto,
    @NumeroDocumentos = NumeroDocumentos,
    @PrimerVencimiento = PrimerVencimiento,
    @Periodo = UPPER(Periodo),
    @Concepto = Concepto,
    @Observaciones = Observaciones,
    @Estatus = Estatus,
    @FechaEmision = FechaEmision,
    @MovUsuario = Usuario,
    @ImpPrimerDoc = ImpPrimerDoc,
    @Condicion = Condicion,
    @InteresPorcentaje = NULLIF(Interes / 100, 0)
  FROM DocAuto WITH (NOLOCK)
  WHERE ID = @ID
  SELECT
    @TipoCambio = TipoCambio
  FROM Mon WITH (NOLOCK)
  WHERE Moneda = @Moneda
  IF NULLIF(RTRIM(@Usuario), '') IS NULL
    SELECT
      @Usuario = @MovUsuario
  SELECT
    @MovTipo = Clave
  FROM MovTipo WITH (NOLOCK)
  WHERE Modulo = @Modulo
  AND Mov = @Mov
  SELECT
    @PPFechaEmision = @FechaEmision,
    @DocMov = NULLIF(NULLIF(RTRIM(@DocMov), ''), '0')
  IF @DocMov IS NULL
    SELECT
      @Ok = 10160
  SELECT
    @CfgDocAutoBorrador = ISNULL(CASE @Modulo
      WHEN 'CXC' THEN CxcDocAutoBorrador
      ELSE CxpDocAutoBorrador
    END, 0)
  FROM EmpresaCfg2 WITH (NOLOCK)
  WHERE Empresa = @Empresa
  IF @CfgDocAutoBorrador = 1
    SELECT
      @DocEstatus = 'BORRADOR'
  ELSE
    SELECT
      @DocEstatus = 'SINAFECTAR'
  IF @MovTipo IN ('CXC.A', 'CXC.AR', 'CXC.DA', 'CXC.NC', 'CXC.DAC', 'CXP.A', 'CXP.DA', 'CXP.NC', 'CXP.DAC')
  BEGIN
    SELECT
      @Intereses = 0.0,
      @InteresesImpuestos = 0.0
    SELECT
      @DocAutoFolio =
                     CASE @Modulo
                       WHEN 'CXC' THEN NULLIF(RTRIM(CxcDocAnticipoAutoFolio), '')
                       WHEN 'CXP' THEN NULLIF(RTRIM(CxpDocAnticipoAutoFolio), '')
                       ELSE NULL
                     END
    FROM EmpresaCfg WITH (NOLOCK)
    WHERE Empresa = @Empresa
  END
  ELSE
    SELECT
      @DocAutoFolio =
                     CASE @Modulo
                       WHEN 'CXC' THEN NULLIF(RTRIM(CxcDocAutoFolio), '')
                       WHEN 'CXP' THEN NULLIF(RTRIM(CxpDocAutoFolio), '')
                       ELSE NULL
                     END
    FROM EmpresaCfg WITH (NOLOCK)
    WHERE Empresa = @Empresa
  IF @Modulo = 'CXC'
    SELECT
      @DesglosarImpuestos = ISNULL(CxcCobroImpuestos, 0)
    FROM EmpresaCfg2 WITH (NOLOCK)
    WHERE Empresa = @Empresa
  IF @Estatus = 'SINAFECTAR'
    AND @NumeroDocumentos > 0
  BEGIN
    IF @Modulo = 'CXC'
      SELECT
        @RamaID = ID,
        @Importe = ISNULL(Importe, 0.0),
        @Impuestos = ISNULL(Impuestos, 0.0),
        @Saldo = ISNULL(Saldo, 0.0),
        @Proyecto = Proyecto,
        @ClienteEnviarA = ClienteEnviarA,
        @Agente = Agente,
        @Cobrador = Cobrador,
        @PersonalCobrador = PersonalCobrador
      FROM Cxc WITH (NOLOCK)
      WHERE Empresa = @Empresa
      AND Cliente = @Cuenta
      AND Mov = @Mov
      AND MovID = @MovID
      AND Estatus = 'PENDIENTE'
    ELSE
    IF @Modulo = 'CXP'
      SELECT
        @RamaID = ID,
        @Importe = ISNULL(Importe, 0.0),
        @Impuestos = ISNULL(Impuestos, 0.0),
        @Saldo = ISNULL(Saldo, 0.0),
        @Proyecto = Proyecto
      FROM Cxp WITH (NOLOCK)
      WHERE Empresa = @Empresa
      AND Proveedor = @Cuenta
      AND Mov = @Mov
      AND MovID = @MovID
      AND Estatus = 'PENDIENTE'
    SELECT
      @ImporteTotal = @ImporteDocumentar + @Intereses + @InteresesImpuestos
    IF @Saldo < @ImporteDocumentar
      SELECT
        @Ok = 35190
    IF @Ok IS NULL
    BEGIN
      IF @Conexion = 0
        BEGIN TRANSACTION
        IF @Intereses > 0.0
        BEGIN
          SELECT
            @Referencia = RTRIM(@Mov) + ' ' + LTRIM(CONVERT(char, @MovID))
          IF @Modulo = 'CXC'
          BEGIN
            INSERT Cxc (Sucursal, OrigenTipo, Origen, OrigenID, Empresa, Mov, FechaEmision, Concepto, Proyecto, Moneda, TipoCambio, Usuario, Referencia, Observaciones, Estatus,
            Cliente, ClienteMoneda, ClienteTipoCambio, Importe, Impuestos,
            ClienteEnviarA, Agente, Cobrador, PersonalCobrador, Tasa, RamaID)
              VALUES (@Sucursal, @Modulo, @Mov, @MovID, @Empresa, @InteresesMov, @FechaEmision, @InteresesConcepto, @Proyecto, @Moneda, @TipoCambio, @Usuario, @Referencia, @Observaciones, @DocEstatus, @Cuenta, @Moneda, @TipoCambio, @Intereses, @InteresesImpuestos, @ClienteEnviarA, @Agente, @Cobrador, @PersonalCobrador, @Tasa, @RamaID)
            SELECT
              @InteresesID = @@IDENTITY
          END
          ELSE
          IF @Modulo = 'CXP'
          BEGIN
            INSERT Cxp (Sucursal, OrigenTipo, Origen, OrigenID, Empresa, Mov, FechaEmision, Concepto, Proyecto, Moneda, TipoCambio, Usuario, Referencia, Observaciones, Estatus,
            Proveedor, ProveedorMoneda, ProveedorTipoCambio, Importe, Impuestos, Tasa, RamaID)
              VALUES (@Sucursal, @Modulo, @Mov, @MovID, @Empresa, @InteresesMov, @FechaEmision, @InteresesConcepto, @Proyecto, @Moneda, @TipoCambio, @Usuario, @Referencia, @Observaciones, @DocEstatus, @Cuenta, @Moneda, @TipoCambio, @Intereses, @InteresesImpuestos, @Tasa, @RamaID)
            SELECT
              @InteresesID = @@IDENTITY
          END
          IF @CfgDocAutoBorrador = 0
            EXEC spCx @InteresesID,
                      @Modulo,
                      'AFECTAR',
                      'TODO',
                      @FechaRegistro,
                      NULL,
                      @Usuario,
                      1,
                      0,
                      @InteresesMov OUTPUT,
                      @InteresesMovID OUTPUT,
                      NULL,
                      @Ok OUTPUT,
                      @OkRef OUTPUT
        END
        ELSE
          SELECT
            @InteresesImpuestos = 0.0
        --IF @Periodo = 'QUINCENAL'
        --BEGIN
        --SELECT @Dia = DATEPART(dd, @PrimerVencimiento)
        --IF @Dia <= 15
        --BEGIN
        --SELECT @EsQuince = 1, @PrimerVencimiento = DATEADD(dd, 15 -@Dia, @PrimerVencimiento)
        --SET @PrimerVencimiento = DATEADD(dd, @CorteDias, @PrimerVencimiento)
        --UPDATE VENTA WITH(ROWLOCK) SET vencimiento = @PrimerVencimiento where mov = @Mov and MovID = @MovID 
        --UPDATE CXC WITH(ROWLOCK) SET vencimiento = @PrimerVencimiento where mov = @Mov and MovID = @MovID 
        --END
        --ELSE
        --BEGIN
        --SELECT @EsQuince = 0, @PrimerVencimiento = DATEADD(dd, -DATEPART(dd, @PrimerVencimiento), DATEADD(mm, 1, @PrimerVencimiento))
        --SET @PrimerVencimiento = DATEADD(dd, @CorteDias, @PrimerVencimiento)
        --UPDATE VENTA WITH(ROWLOCK) SET vencimiento = @PrimerVencimiento where mov = @Mov and MovID = @MovID 
        --UPDATE CXC WITH(ROWLOCK) SET vencimiento = @PrimerVencimiento where mov = @Mov and MovID = @MovID 
        --END
        --END

        IF @Periodo = 'QUINCENAL'
        BEGIN
          SELECT
            @Dia = DATEPART(dd, @PrimerVencimiento)
          SELECT
            @MenosDias = DATEPART(dd, DATEADD(mm, 1, @PrimerVencimiento))
          SELECT
            @MenosDias = (@Dia - @MenosDias) + 15
          IF @Dia <= 15
          BEGIN
            SELECT
              @EsQuince = 1,
              @PrimerVencimiento = DATEADD(dd, 15 - @Dia, @PrimerVencimiento)
            SET @PrimerVencimiento = DATEADD(dd, @CorteDias, @PrimerVencimiento)
            UPDATE VENTA WITH (ROWLOCK)
            SET vencimiento = @PrimerVencimiento
            WHERE mov = @Mov
            AND MovID = @MovID
            UPDATE CXC WITH (ROWLOCK)
            SET vencimiento = @PrimerVencimiento
            WHERE mov = @Mov
            AND MovID = @MovID
          END
          ELSE
          BEGIN
            IF @Dia >= 16
              AND @Dia <= 30
            BEGIN
              SELECT
                @EsQuince = 0,
                @PrimerVencimiento = DATEADD(dd, -DATEPART(dd, @PrimerVencimiento), DATEADD(mm, 1, @PrimerVencimiento))
              SET @PrimerVencimiento = DATEADD(dd, @CorteDias, @PrimerVencimiento)
              IF (DATEPART(dd, @PrimerVencimiento) = 1)
                SET @PrimerVencimiento = DATEADD(dd, 1, @PrimerVencimiento)
              IF (DATEPART(dd, @PrimerVencimiento) = 31)
                SET @PrimerVencimiento = DATEADD(dd, 2, @PrimerVencimiento)
              UPDATE VENTA WITH (ROWLOCK)
              SET vencimiento = @PrimerVencimiento
              WHERE mov = @Mov
              AND MovID = @MovID
              UPDATE CXC WITH (ROWLOCK)
              SET vencimiento = @PrimerVencimiento
              WHERE mov = @Mov
              AND MovID = @MovID
            END
            ELSE
            BEGIN
              SELECT
                @EsQuince = 0,
                @PrimerVencimiento = DATEADD(dd, -DATEPART(dd, @PrimerVencimiento), DATEADD(mm, 1, @PrimerVencimiento))
              SET @PrimerVencimiento = DATEADD(dd, @CorteDias + @MenosDias, @PrimerVencimiento)
              UPDATE VENTA WITH (ROWLOCK)
              SET vencimiento = @PrimerVencimiento
              WHERE mov = @Mov
              AND MovID = @MovID
              UPDATE CXC WITH (ROWLOCK)
              SET vencimiento = @PrimerVencimiento
              WHERE mov = @Mov
              AND MovID = @MovID
            END
          END
        END
        IF @ImpPrimerDoc = 1
          AND @ImporteDocumentar = @Importe + @Impuestos
          SELECT
            @ImporteDocumentar = @Importe
        SELECT
          @a = 1,
          @MovAplicaImporte = ROUND(@ImporteDocumentar / @NumeroDocumentos, @RedondeoMonetarios),
          @InteresesAplicaImporte = ROUND((@Intereses + @InteresesImpuestos) / @NumeroDocumentos, @RedondeoMonetarios),
          @Vencimiento = @PrimerVencimiento
        SELECT
          @PagoMensual = @MovAplicaImporte + ISNULL(@InteresesAplicaImporte, 0)
        IF @ImpPrimerDoc = 1
          SELECT
            @DocImporte = @MovAplicaImporte
        ELSE
          SELECT
            @DocImporte = @MovAplicaImporte + @InteresesAplicaImporte
        SELECT
          @CapitalAnterior = @ImporteDocumentar
        WHILE (@a <= @NumeroDocumentos)
          AND @Ok IS NULL
        BEGIN
          SELECT
            @Importe1 = 0.0,
            @Importe2 = 0.0,
            @Importe3 = 0.0
          IF @ImpPrimerDoc = 1
            AND @a = 1
          BEGIN
            SELECT
              @Importe1 = @DocImporte + @Impuestos + @Intereses + @InteresesImpuestos,
              @Importe2 = @DocImporte + @Impuestos,
              @Importe3 = @Intereses + @InteresesImpuestos
          END
          ELSE
          BEGIN
            SELECT
              @Importe1 = @DocImporte,
              @Importe2 = @MovAplicaImporte
            IF @ImpPrimerDoc = 1
              SELECT
                @Importe3 = 0.0
            ELSE
            BEGIN
              SELECT
                @Importe3 = @InteresesAplicaImporte
              IF @InteresPorcentaje IS NOT NULL
              BEGIN
                SELECT
                  @CapitalInsoluto = (@ImporteDocumentar * POWER(1 + @InteresPorcentaje, @a)) - (@PagoMensual * ((POWER(1 + @InteresPorcentaje, @a) - 1) / @InteresPorcentaje))
                SELECT
                  @Importe2 = @CapitalAnterior - @CapitalInsoluto
                SELECT
                  @Importe3 = @MovAplicaImporte + @InteresesAplicaImporte - @Importe2
                SELECT
                  @CapitalAnterior = @CapitalInsoluto
              END
            END
          END
          SELECT
            @SumaImporte1 = @SumaImporte1 + @Importe1,
            @SumaImporte2 = @SumaImporte2 + @Importe2,
            @SumaImporte3 = @SumaImporte3 + @Importe3
          IF @a = @NumeroDocumentos
          BEGIN
            SELECT
              @Dif = @SumaImporte2 - @ImporteDocumentar
            IF @Dif <> 0.0
              SELECT
                @Importe1 = @Importe1 - @Dif,
                @Importe2 = @Importe2 - @Dif
            SELECT
              @Dif = @SumaImporte3 - (@Intereses + @InteresesImpuestos)
            IF @Dif <> 0.0
              SELECT
                @Importe1 = @Importe1 - @Dif,
                @Importe3 = @Importe3 - @Dif
          END
          SELECT
            @Referencia = RTRIM(@Mov) + ' ' + LTRIM(RTRIM(CONVERT(char, @MovID))) + ' (' + LTRIM(RTRIM(CONVERT(char, @a))) + '/' + LTRIM(RTRIM(CONVERT(char, @NumeroDocumentos))) + ')'
          IF @Mov = @DocAutoFolio
            SELECT
              @DocMovID = RTRIM(@MovID) + '-' + LTRIM(CONVERT(char, @a))
          ELSE
            SELECT
              @DocMovID = NULL
          EXEC spCalcularVencimientoPP @Modulo,
                                       @Empresa,
                                       @Cuenta,
                                       @Condicion,
                                       @PPFechaEmision,
                                       @PPVencimiento OUTPUT,
                                       @PPDias OUTPUT,
                                       @PPFechaProntoPago OUTPUT,
                                       @PPDescuentoProntoPago OUTPUT,
                                       @Tasa OUTPUT,
                                       @Ok OUTPUT
          IF @Modulo = 'CXC'
          BEGIN
            INSERT Cxc (Sucursal, OrigenTipo, Origen, OrigenID, Empresa, Mov, MovID, FechaEmision, Concepto, Proyecto, Moneda, TipoCambio, Usuario, Referencia, Observaciones, Estatus,
            Cliente, ClienteMoneda, ClienteTipoCambio, Importe, Condicion, Vencimiento, AplicaManual, FechaProntoPago, DescuentoProntoPago,
            ClienteEnviarA, Agente, Cobrador, PersonalCobrador, Tasa, RamaID)
              VALUES (@Sucursal, @Modulo, @Mov, @MovID, @Empresa, @DocMov, @DocMovID, @FechaEmision, @Concepto, @Proyecto, @Moneda, @TipoCambio, @Usuario, @Referencia, @Observaciones, @DocEstatus, @Cuenta, @Moneda, @TipoCambio, @Importe1, '(Fecha)', @Vencimiento, 1, @PPFechaProntoPago, @PPDescuentoProntoPago, @ClienteEnviarA, @Agente, @Cobrador, @PersonalCobrador, @Tasa, @RamaID)
            SELECT
              @DocID = @@IDENTITY
            IF @Importe2 > 0.0
              INSERT CxcD (Sucursal, ID, Renglon, Aplica, AplicaID, Importe)
                VALUES (@Sucursal, @DocID, 2048, @Mov, @MovID, @Importe2)
            IF @Importe3 > 0.0
              INSERT CxcD (Sucursal, ID, Renglon, Aplica, AplicaID, Importe)
                VALUES (@Sucursal, @DocID, 4096, @InteresesMov, @InteresesMovID, @Importe3)
            IF @DesglosarImpuestos = 1
            BEGIN
              SELECT
                @AplicaImpuestos = NULLIF(SUM(d.Importe * c.IVAFiscal * ISNULL(c.IEPSFiscal, 1)), 0)
              FROM CxcD d WITH (NOLOCK),
                   Cxc c WITH (NOLOCK)
              WHERE d.ID = @DocID
              AND c.Empresa = @Empresa
              AND c.Mov = d.Aplica
              AND c.MovID = d.AplicaID
              AND c.Estatus = 'PENDIENTE'
              AND FechaEmision = @FechaEmision
              IF @AplicaImpuestos IS NOT NULL
                UPDATE Cxc WITH (ROWLOCK)
                SET Importe = Importe - @AplicaImpuestos,
                    Impuestos = @AplicaImpuestos
                WHERE ID = @DocID
            END
          END
          ELSE
          IF @Modulo = 'CXP'
          BEGIN
            INSERT Cxp (Sucursal, OrigenTipo, Origen, OrigenID, Empresa, Mov, MovID, FechaEmision, Concepto, Proyecto, Moneda, TipoCambio, Usuario, Referencia, Observaciones, Estatus,
            Proveedor, ProveedorMoneda, ProveedorTipoCambio, Importe, Condicion, Vencimiento, AplicaManual, FechaProntoPago, DescuentoProntoPago, Tasa, RamaID)
              VALUES (@Sucursal, @Modulo, @Mov, @MovID, @Empresa, @DocMov, @DocMovID, @FechaEmision, @Concepto, @Proyecto, @Moneda, @TipoCambio, @Usuario, @Referencia, @Observaciones, @DocEstatus, @Cuenta, @Moneda, @TipoCambio, @Importe1, '(Fecha)', @Vencimiento, 1, @PPFechaProntoPago, @PPDescuentoProntoPago, @Tasa, @RamaID)
            SELECT
              @DocID = @@IDENTITY
            IF @Importe2 > 0.0
              INSERT CxpD (Sucursal, ID, Renglon, Aplica, AplicaID, Importe)
                VALUES (@Sucursal, @DocID, 2048, @Mov, @MovID, @Importe2)
            IF @Importe3 > 0.0
              INSERT CxpD (Sucursal, ID, Renglon, Aplica, AplicaID, Importe)
                VALUES (@Sucursal, @DocID, 4096, @InteresesMov, @InteresesMovID, @Importe3)
          END
          IF @CfgDocAutoBorrador = 0
            EXEC spCx @DocID,
                      @Modulo,
                      'AFECTAR',
                      'TODO',
                      @FechaRegistro,
                      NULL,
                      @Usuario,
                      1,
                      0,
                      @DocMov OUTPUT,
                      @DocMovID OUTPUT,
                      NULL,
                      @Ok OUTPUT,
                      @OkRef OUTPUT
          IF @Ok IS NULL
          BEGIN
            SELECT
              @PPFechaEmision = DATEADD(DAY, 1, @Vencimiento)
            IF ISNUMERIC(@Periodo) = 1
              SELECT
                @Vencimiento = DATEADD(DAY, CONVERT(int, @Periodo) * @a, @PrimerVencimiento)
            ELSE
            IF @Periodo = 'SEMANAL'
              SELECT
                @Vencimiento = DATEADD(wk, @a, @PrimerVencimiento)
            ELSE
            IF @Periodo = 'MENSUAL'
              SELECT
                @Vencimiento = DATEADD(mm, @a, @PrimerVencimiento)
            ELSE
            IF @Periodo = 'BIMESTRAL'
              SELECT
                @Vencimiento = DATEADD(mm, @a * 2, @PrimerVencimiento)
            ELSE
            IF @Periodo = 'TRIMESTRAL'
              SELECT
                @Vencimiento = DATEADD(mm, @a * 3, @PrimerVencimiento)
            ELSE
            IF @Periodo = 'SEMESTRAL'
              SELECT
                @Vencimiento = DATEADD(mm, @a * 6, @PrimerVencimiento)
            ELSE
            IF @Periodo = 'ANUAL'
              SELECT
                @Vencimiento = DATEADD(yy, @a, @PrimerVencimiento)
            ELSE
            IF @Periodo = 'QUINCENAL'
            BEGIN
              IF @EsQuince = 1
                SELECT
                  @EsQuince = 0,
                  @Vencimiento = DATEADD(dd, -15, DATEADD(mm, 1, @Vencimiento))
              ELSE
                SELECT
                  @EsQuince = 1,
                  @Vencimiento = DATEADD(dd, 15, @Vencimiento)
            END
            ELSE
              SELECT
                @Ok = 55140
            SELECT
              @a = @a + 1
          END
        END
        IF @Conexion = 0
        BEGIN
          IF @Ok IS NULL
          COMMIT TRANSACTION
        ELSE
          ROLLBACK TRANSACTION
      END
    END
  END
  ELSE
    SELECT
      @Ok = 60040
  IF @Ok IS NULL
    SELECT
      @Mensaje = "Proceso Concluido."
  ELSE
  BEGIN
    SELECT
      @Mensaje = Descripcion
    FROM MensajeLista WITH (NOLOCK)
    WHERE Mensaje = @Ok
    IF @OkRef IS NOT NULL
      SELECT
        @Mensaje = RTRIM(@Mensaje) + '<BR><BR>' + @OkRef
  END
  IF @Conexion = 0
    SELECT
      @Mensaje
  RETURN
END
GO
