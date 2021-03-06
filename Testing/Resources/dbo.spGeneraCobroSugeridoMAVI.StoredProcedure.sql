SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

--========================================================================================================================================           
-- NOMBRE          : [spGeneraCobroSugeridoMAVI]      
-- AUTOR           : intelisis  
-- FECHA CREACION  :  
-- DESARROLLO      : 
-- MODULO          : CXC          
-- DESCRIPCION     :  
-- EJEMPLO         : 
-- ========================================================================================================================================   
--  MODIFICACION
--  Nombre         : Ana Luisa Gomez Montaño
--  Fecha          : 28/12/2017
--  Descripcion    : Se modificó el apartado de obtención de datos para la variable  @PorcIntaBonificar  para que vaya a leer los datos de la nueva tabla TcIRM0906_ConfigDivisionYParam
--  Ejemplo        : Exec SpGeneraCobroSugeridoMAVI 'CXC','44644621','VENTP00740','3'
-- ========================================================================================================================================   
--  Alejandra García 04/09/2018 Se agregó una validación para que en mavicob al ser la división nula la convierta a vacío y funcioné la configuración
-- ========================================================================================================================================   
CREATE PROCEDURE [dbo].[spGeneraCobroSugeridoMAVI] @Modulo char(5),
@ID int,
@Usuario varchar(10),
@Estacion int

AS
BEGIN  --1                
  DECLARE @Empresa char(5),
          @Sucursal int,
          @Hoy datetime,
          @Moneda char(10),
          @TipoCambio float,
          @Renglon float,
          @Aplica varchar(20),
          @AplicaID varchar(20),
          @AplicaMovTipo varchar(20),
          @Importe money,
          @SumaImporte money,
          @Impuestos money,
          @DesglosarImpuestos bit,
          @IDDetalle int,
          @IDCxc int,
          @ImporteReal money,
          @ImporteAPagar money,
          @ImporteMoratorio money,
          @ImporteACondonar money,
          @MovGenerar varchar(20),
          @UEN int,
          @ImporteTotal money,
          @Mov varchar(20),
          @MovID varchar(20),
          @MovPadre varchar(20),
          @Ok int,
          @OkRef varchar(255),
          @Cliente varchar(10),
          @CteMoneda varchar(10),
          @CteTipoCambio float,
          @FechaAplicacion datetime,
          @ClienteEnviarA int,
          @TotalMov money,
          @CampoExtra varchar(50),
          @Consecutivo varchar(20),
          @ValorCampoExtra varchar(255),
          @Concepto varchar(50),
          @MoratorioAPagar money,
          @MovIDGen varchar(20),
          @MovCobro varchar(20),
          @GeneraNC char(1),
          @Origen varchar(20),
          @OrigenID varchar(20),
          @Impuesto money,
          @DefImpuesto float,
          @ImporteDoc money,
          @Bonificacion money,
          @MovIDGenerado varchar(20),
          @TotalAPagar money,
          @IDCargoMor int,
          @InteresPorPolitica money,
          @MovIDCgo varchar(20),
          @IDPadre int,
          @SaldoIniDia money,
          @PorcAbonoCapital float,
          @PorcMoratorioBonificar float,
          @TotalMoratorio money,
          @MoratorioBonificado money,
          @MoratorioXPagar money,
          @TotalCobrosDia money,
          @PorcIntaBonificar float,
          @PorcPAgoCapital float,
          @Nota varchar(100),
          @CobroxPolitica int,
          @MoratoriosaBonificar money,
          @VencimientoMasAntiguo datetime,
          @IDCargoMorEst int,
          @IdCargoMoratorio int,
          @IdCargoMoratorioEst int,
          @SaldoNCPend money,
          @SaldoEstPend money,
          @EstatusNCEst varchar(15),
          @EstatusNC varchar(15),
          @IDUltCobro int,
          @TotalMoratUltCob money,
          @EstatusCargoMor varchar(15),
          @EstatusCargoMorEst varchar(15),
          @TotalBonificacion money,
          @min int,
          @max int,
          @m1 int,
          @m2 int,
          @FechaEmision datetime,
          @Quincena int,
          @Year int = YEAR(GETDATE())

  SELECT
    @Quincena =
               CASE
                 WHEN DAY(GETDATE()) > 16 THEN MONTH(GETDATE()) * 2
                 ELSE (MONTH(GETDATE()) * 2) - 1
               END

  SELECT
    @Quincena =
               CASE
                 WHEN DAY(GETDATE()) = 1 THEN @Quincena - 1
                 ELSE @Quincena
               END

  SELECT
    @Year =
           CASE
             WHEN DAY(GETDATE()) = 1 AND
               MONTH(GETDATE()) = 1 THEN @Year - 1
             ELSE @Year
           END,

    @Quincena =
               CASE
                 WHEN DAY(GETDATE()) = 1 AND
                   MONTH(GETDATE()) = 1 THEN 24
                 ELSE @Quincena
               END

  SET @CobroxPolitica = 0
  SET @FechaAplicacion = GETDATE()
  SELECT
    @CteMoneda = ClienteMoneda,
    @CteTipoCambio = ClienteTipoCambio,
    @Cliente = Cliente
  FROM CXC WITH (NOLOCK)
  WHERE ID = @ID
  SELECT
    @CobroxPolitica = ISNULL(TipoCobro, 0)
  FROM TipoCobroMAVI WITH (NOLOCK)
  WHERE IdCobro = @ID
  SELECT
    @DesglosarImpuestos = 0,
    @Renglon = 0.0,
    @SumaImporte = 0.0,
    @ImporteTotal = NULLIF(@ImporteTotal, 0.0)
  SELECT
    @Renglon = 1024.0
  SELECT
    @GeneraNC = '1'

  IF EXISTS (SELECT
      ID
    FROM tempdb.sys.sysobjects
    WHERE id = OBJECT_ID('tempdb.dbo.#crDetalle')
    AND type = 'U')
    DROP TABLE #crDetalle

  IF EXISTS (SELECT
      ID
    FROM tempdb.sys.sysobjects
    WHERE id = OBJECT_ID('tempdb.dbo.#crDoc')
    AND type = 'U')
    DROP TABLE #crDoc

  IF NOT EXISTS (SELECT
      *
    FROM NegociaMoratoriosMAVI WITH (NOLOCK)
    WHERE IDCobro = @ID)
  BEGIN
    SELECT
      'No hay sugerencia a cobrar..'
    RETURN
  END
  BEGIN TRANSACTION BonMAVI
    IF @Modulo = 'CXC'
    BEGIN  -- 2                
      UPDATE CXC WITH (ROWLOCK)
      SET AplicaManual = 1
      WHERE id = @ID
      SELECT
        @Empresa = Empresa,
        @Sucursal = Sucursal,
        @Hoy = FechaEmision,
        @Moneda = Moneda,
        @TipoCambio = TipoCambio,
        @ClienteEnviarA = ClienteEnviarA,
        @MovCobro = Mov
      FROM Cxc WITH (NOLOCK)
      WHERE ID = @ID
      DELETE CxcD
      WHERE ID = @ID
      DELETE DetalleAfectacionMAVI
      WHERE IDCobro = @ID

      SELECT TOP 1
        @ClienteEnviarA = ClienteEnviarA,
        @FechaEmision = FechaEmision
      FROM Cxc C WITH (NOLOCK)
      INNER JOIN NegociaMoratoriosMAVI N WITH (NOLOCK)
        ON C.Mov = N.Mov
        AND C.MovID = N.MovID
      WHERE N.IDCobro = @ID
      -- cambio de orden yrg 06.05.2010          
      EXEC spGeneraNCredPPMAVI @ID,
                               @Usuario,
                               @Ok OUTPUT,
                               @OkRef OUTPUT

      ----IF @Ok IS NULL                
      ----  EXEC spGeneraNCredNAMAVI @ID, @Usuario, @Ok OUTPUT, @OkRef OUTPUT                

      IF @Ok IS NULL
        AND (@ClienteEnviarA NOT IN (3, 4, 7, 11)
        OR @FechaEmision BETWEEN '2014-05-01' AND '2014-07-10')
        EXEC spGeneraNCredAPMAVI @ID,
                                 @Usuario,
                                 @Ok OUTPUT,
                                 @OkRef OUTPUT

      IF @Ok IS NULL
        AND @ClienteEnviarA = 7
        EXEC spGeneraNCredBonifMAVI @ID,
                                    @Usuario,
                                    @Ok OUTPUT,
                                    @OkRef OUTPUT

      IF @Ok IS NULL
      BEGIN  -- 1               


        SELECT
          SUM(ISNULL(MoratorioAPagar, 0) - ISNULL(ImporteACondonar, 0)) ImporteMoratorio,
          Origen,
          OrigenID,
          ROW_NUMBER() OVER (ORDER BY OrigenID) Id INTO #crDetalle
        FROM NegociaMoratoriosMAVI WITH (NOLOCK)
        WHERE IDCobro = @ID  --                
        AND Estacion = @Estacion
        AND MoratorioAPagar > 0
        GROUP BY Origen,
                 OrigenID

        SELECT
          @min = MIN(id),
          @max = MAX(Id)
        FROM #CrDetalle

        WHILE @min <= @max
        BEGIN  -- 2                
          IF @OK IS NULL
          BEGIN    -- 3

            SELECT
              @Origen = ORIGEN,
              @OrigenID = OrigenID,
              @ImporteMoratorio = ImporteMoratorio
            FROM #CrDetalle
            WHERE ID = @min

            SELECT
              @UEN = UEN,
              @ClienteEnviarA = ClienteEnviarA
            FROM CXC WITH (NOLOCK)
            WHERE Mov = @Origen
            AND MovId = @OrigenID


            IF @ImporteMoratorio > 0
            BEGIN  --   4                
              -- Verificar q mov netea este mov q genero moratorios, insertarlo y afcetarlo antes de insertarlo en el detale del cobro                 


              SELECT
                @MovGenerar = dbo.fnMaviObtieneMovSaldoMoratorios(@Origen, 'Moratorios', @UEN)
              --SELECT @MovGenerar as 'MovGenerar'  -- yrg                
              IF @MovGenerar IS NULL
                SELECT
                  @MovGenerar = 'Nota Cargo'
              IF @MovGenerar = 'Endoso'
                SELECT
                  @MovGenerar = 'Nota Cargo'

              --  22.06.09 yrg                
              SELECT
                @DefImpuesto = 1 + ISNULL(DefImpuesto, 15.0) / 100
              FROM EmpresaGral WITH (NOLOCK)
              WHERE Empresa = @Empresa

              SELECT
                @Importe = @ImporteMoratorio / @DefImpuesto   --select 1000/1.15                
              SELECT
                @Impuesto = @ImporteMoratorio - @Importe
              --SELECT @MovGenerar as 'Mov Generar'  -- yrg                
              IF @MovGenerar IN ('Nota Cargo', 'Nota Cargo VIU')
                SELECT
                  @Concepto = 'MORATORIOS MENUDEO'
              IF @MovGenerar = 'Nota Cargo Mayoreo'
                SELECT
                  @Concepto = 'MORATORIOS MAYOREO'
              IF @GeneraNC = '1'
              BEGIN  -- 5                
                --select 'Yani entra' -- yrg                                 
                INSERT INTO Cxc (Empresa, Mov, MovID, FechaEmision, Concepto, UltimoCambio, Moneda, TipoCambio, Usuario, Referencia,
                Estatus, Cliente, ClienteEnviarA, ClienteMoneda, ClienteTipoCambio, Vencimiento,
                Importe, Impuestos, AplicaManual, ConDesglose, Saldo,
                ConTramites, VIN, Sucursal, SucursalOrigen, UEN, PersonalCobrador, FechaOriginal, Nota,
                Comentarios, LineaCredito, TipoAmortizacion, TipoTasa, Amortizaciones, Comisiones, ComisionesIVA,
                FechaRevision, ContUso, TieneTasaEsp, TasaEsp, Codigo)
                  VALUES (@Empresa, @MovGenerar, NULL, dbo.fnFechaSinHora(@FechaAplicacion), @Concepto, @FechaAplicacion, @Moneda, @TipoCambio, @Usuario, NULL,  --'Prueba Moratorios',                 
                  'SINAFECTAR', @Cliente, @ClienteEnviarA, @Moneda, @TipoCambio, @FechaAplicacion, @Importe, @Impuesto, 0, 0, ISNULL(@Importe, 0) + ISNULL(@Impuesto, 0), 0, NULL, @Sucursal, @Sucursal, @UEN, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL)

                SELECT
                  @IDCxc = @@IDENTITY
                --SELECT @IDCxc as 'SELECT @IDCxc'     -- yrg                
                EXEC spAfectar 'CXC',
                               @IDCxc,
                               'AFECTAR',
                               'Todo',
                               NULL,
                               @Usuario,
                               NULL,
                               1,
                               @Ok OUTPUT,
                               @OkRef OUTPUT,
                               NULL,
                               @Conexion = 1 --1                

                --SELECT @IDCxc  as 'IDcxc'                
                --select @Ok as 'Valor al afectarNC' -- yrg                

                INSERT INTO DetalleAfectacionMAVI (IDCobro, ID, Mov, MovID, ValorOK, ValorOKRef)
                  VALUES (@ID, @IDCxc, @MovGenerar, @MovIDGen, @Ok, @OkRef)

                UPDATE NegociaMoratoriosMAVI WITH (ROWLOCK)
                SET NotaCargoMorId = @IDCxc
                WHERE IDCobro = @ID
                AND Estacion = @Estacion
                AND MoratorioAPagar > 0
                AND Origen = @Origen
                AND OrigenID = @OrigenId

                SELECT
                  @MovIDGen = MovId
                FROM CXC WITH (NOLOCK)
                WHERE ID = @IDCxc
                --select @MovGenerar as '@MovGenerar YANI'  --yrg                
                --select @MovIDGen as '@MovIDGen'  -- yrg                
                INSERT CxcD (ID, Sucursal, Renglon, Aplica, AplicaID, Importe, InteresesOrdinarios, InteresesMoratorios, ImpuestoAdicional)
                  VALUES (@ID, @Sucursal, @Renglon, @MovGenerar, @MovIDGen, NULLIF(@ImporteMoratorio, 0.0), 0.0, 0.0, 0.0)
                SELECT
                  @Renglon = @Renglon + 1024.0

                IF @Ok = 80030
                  SELECT
                    @Ok = NULL
                --select @OK as 'Ok'                 
                IF @Ok IS NULL --OR @OK = ''                
                BEGIN  -- 6                                

                  IF NOT EXISTS (SELECT
                      *
                    FROM MovCampoExtra WITH (NOLOCK)
                    WHERE Modulo = @Modulo
                    AND Mov = @MovGenerar
                    AND ID = @IDCxc)
                  BEGIN  -- 7                
                    SELECT
                      @AplicaId = MovId
                    FROM CXC WITH (NOLOCK)
                    WHERE ID = @IDCxc
                    --EXEC spCamposExtrasMovCto @Modulo, @Mov, @ID, @Tipo OUTPUT, @SubTipo OUTPUT, @Clave OUTPUT                
                    IF @MovGenerar = 'Nota Cargo'
                      SELECT
                        @CampoExtra = 'NC_FACTURA'
                    IF @MovGenerar = 'Nota Cargo VIU'
                      SELECT
                        @CampoExtra = 'NCV_FACTURA'
                    IF @MovGenerar = 'Nota Cargo Mayoreo'
                      SELECT
                        @CampoExtra = 'NCM_FACTURA'
                    SELECT
                      @ValorCampoExtra = RTRIM(@Origen) + '_' + RTRIM(@OrigenId)
                    --SELECT @ValorCampoExtra as 'Valor Campo Extra'  -- yrg                
                    IF @MovGenerar IN ('Nota Cargo', 'Nota Cargo VIU', 'Nota Cargo Mayoreo')
                      INSERT INTO MovCampoExtra (Modulo, Mov, ID, CampoExtra, Valor)
                        VALUES ('CXC', @MovGenerar, @IDCxc, @CampoExtra, @ValorCampoExtra)
                  END   -- 1                

                END  -- 2                
              END  --  3 GenerarNC                

            END -- 4                 
          END -- 5                

          SET @min = @min + 1
        END -- 6                

        --END  -- 3                

        -- Se inserta en el detalle del cobro los doctos que se cubran                

        -- La sig parte funciona para ambos tipos de cobros (Normal y por politica)                        

        SELECT
          Mov,
          MovID,
          ImporteReal,
          ImporteAPagar,
          ImporteMoratorio,
          ImporteACondonar,
          Bonificacion,
          TotalAPagar,
          ROW_NUMBER() OVER (ORDER BY MovID) id INTO #crDoc
        FROM NegociaMoratoriosMAVI WITH (NOLOCK)
        WHERE IDCobro = @ID
        AND Estacion = @Estacion
        AND ImporteAPagar > 0

        SELECT
          @m1 = MIN(id),
          @m2 = MAX(id)
        FROM #CrDoc


        WHILE @m1 <= @m2
        BEGIN  -- 1                
          IF @OK IS NULL
          BEGIN    --  2
            SELECT
              @Mov = Mov,
              @MovID = MovID,
              @ImporteReal = ImporteReal,
              @ImporteAPagar = ImporteAPagar,
              @ImporteMoratorio = ImporteMoratorio,
              @ImporteACondonar = ImporteACondonar,
              @Bonificacion = Bonificacion,
              @TotalAPagar = TotalAPagar
            FROM #CrDoc
            WHERE id = @m1
            SELECT
              @ImporteDoc = ISNULL(@ImporteAPagar, 0) - ISNULL(@Bonificacion, 0)

            --SELECT  @ImporteDoc  as 'Imp Doc'  -- yrg                
            IF @ImporteDoc > 0 --@ImporteAPagar > 0                 
            BEGIN  -- 3                
              INSERT CxcD (ID, Sucursal, Renglon, Aplica, AplicaID, Importe, InteresesOrdinarios, InteresesMoratorios, ImpuestoAdicional)
                VALUES (@ID, @Sucursal, @Renglon, @Mov, @MovID, NULLIF(@ImporteDoc, 0.0), 0.0, 0.0, 0.0)
              SELECT
                @Renglon = @Renglon + 1024.0
            END  --3                
          END  -- 2                
          SET @m1 = @m1 + 1
        END  -- 1                


        IF @CobroxPolitica = 1
        BEGIN

          UPDATE CXC WITH (ROWLOCK)
          SET Concepto = 'POLITICA QUITA MORATORIOS'
          WHERE ID = @ID
          -- aqui se calcula el importe del Moratorio a Bonificar si lo hay
          SELECT
            @InteresPorPolitica = MIN(InteresPorPolitica)
          FROM NegociaMoratoriosMAVI WITH (NOLOCK)
          WHERE IDCobro = @ID
          AND InteresPorPolitica > 0

          SELECT
            @Origen = Origen,
            @OrigenID = OrigenID
          FROM NegociaMoratoriosMAVI WITH (NOLOCK)
          WHERE IDCobro = @ID
          GROUP BY Origen,
                   OrigenID   -- solo hay docs de un padre  

          SELECT
            @IDPadre = ID,
            @UEN = UEN,
            @ClienteEnviarA = ClienteEnviarA
          FROM CXC WITH (NOLOCK)
          WHERE Mov = @Origen
          AND MovID = @OrigenID

          SELECT
            @ImporteTotal = SUM(ISNULL(ImporteAPagar, 0))
          FROM NegociaMoratoriosMAVI WITH (NOLOCK)
          WHERE IDCobro = @ID

          -- Si existen mas cobros por politica en el dia  
          IF NOT EXISTS (SELECT
              *
            FROM CobroXPoliticaHistMAVI WITH (NOLOCK)
            WHERE Mov = @Origen
            AND MovID = @OrigenID
            AND CONVERT(varchar(8), FechaEmision, 112) = CONVERT(varchar(8), @FechaAplicacion, 112)
            AND EstatusCobro = 'CONCLUIDO')
          BEGIN
            SET @TotalBonificacion = 0
            SELECT
              @TotalBonificacion = SUM(ISNULL(Bonificacion, 0))
            FROM NegociaMoratoriosMAVI WITH (NOLOCK)
            WHERE IDCobro = @ID
            SELECT
              @SaldoIniDia = dbo.fnSaldoPMMAVI(@IDPadre) + ISNULL(@TotalBonificacion, 0)
            SELECT
              @TotalCobrosDia = @ImporteTotal
          END
          ELSE
          BEGIN
            -- En caso de mas cobros por politica en el dia se toma el sdo del primer cobro del dia 
            -- y se procede a cancelar la nota de cargo pendiente        
            SELECT TOP 1
              @SaldoIniDia = SaldoInicioDelDia
            FROM CobroXPoliticaHistMAVI WITH (NOLOCK)
            WHERE Mov = @Origen
            AND MovID = @OrigenID
            AND CONVERT(varchar(8), FechaEmision, 112) = CONVERT(varchar(8), @FechaAplicacion, 112)
            AND EstatusCobro = 'CONCLUIDO'
            ORDER BY IDCobro ASC

            SELECT
              @TotalCobrosDia = SUM(ImporteCobro) + ISNULL(@ImporteTotal, 0)
            FROM CobroXPoliticaHistMAVI WITH (NOLOCK)
            WHERE Mov = @Origen
            AND MovID = @OrigenID
            AND CONVERT(varchar(8), FechaEmision, 112) = CONVERT(varchar(8), @FechaAplicacion, 112)
            AND EstatusCobro = 'CONCLUIDO'

            SELECT /*@IdCargoMoratorio = 0, */
              @IdCargoMoratorioEst = 0
            -- Se obtiene el ultimo cobro del dia para cancelar la Nota de cargo pendiente de pago y volverla a generar por el importe completo 
            SELECT TOP 1
              @IDUltCobro = idCobro,
              @PorcMoratorioBonificar = PorcMoratorioBonificar, /*@IdCargoMoratorio = IdCargoMoratorio,*/
              @IdCargoMoratorioEst = IdCargoMoratorioEst,
              @TotalMoratUltCob = TotalMoratorio
            FROM CobroXPoliticaHistMAVI WITH (NOLOCK)
            WHERE Mov = @Origen
            AND MovID = @OrigenID
            AND CONVERT(varchar(8), FechaEmision, 112) = CONVERT(varchar(8), @FechaAplicacion, 112)
            AND EstatusCobro = 'CONCLUIDO'
            ORDER BY IDCobro DESC

            SELECT
              @InteresPorPolitica = @TotalMoratUltCob
            -- se genera la nota de cargo pendiente por la diferencia de la bonificacion 

            IF @PorcMoratorioBonificar <= 100
            BEGIN
              -- se verifica que los movs generados en el cobro anterior aun esten pendientes, para cancela las notas cargo pend generadas 
              --SELECT @SaldoNCPend =  ISNULL(Saldo,0), @EstatusNC = Estatus FROM CXC WHERE ID = @IdCargoMoratorio
              SELECT
                @SaldoEstPend = ISNULL(Importe, 0) + ISNULL(Impuestos, 0),
                @EstatusNCEst = Estatus
              FROM CXC WITH (NOLOCK)
              WHERE ID = @IdCargoMoratorioEst
              --&
              /*  IF @IdCargoMoratorio > 0 AND @EstatusNC = 'PENDIENTE'
                  -- cancelar la nota, solo si esta pendiente
                  EXEC spAfectar 'CXC', @IdCargoMoratorio, 'CANCELAR', 'Todo', NULL, @Usuario,  NULL, 1, @Ok OUTPUT, @OkRef OUTPUT,NULL, @Conexion =  1 --1                  */
              IF @IdCargoMoratorioEst > 0
              BEGIN
                EXEC spAfectar 'CXC',
                               @IdCargoMoratorioEst,
                               'CANCELAR',
                               'Todo',
                               NULL,
                               @Usuario,
                               NULL,
                               1,
                               @Ok OUTPUT,
                               @OkRef OUTPUT,
                               NULL,
                               @Conexion = 1 --1                                
                UPDATE CobroxPoliticaHistMAVI WITH (ROWLOCK)
                SET EstatusCargoMorEst = 'CANCELADO'
                WHERE IdCargoMoratorioEst = @IdCargoMoratorioEst
              END
            END
          END

          IF @SaldoIniDia > 0
            SELECT
              @PorcAbonoCapital = (@TotalCobrosDia / @SaldoIniDia) * 100.0

          --SELECT @SaldoIniDia as 'SdoIni-dia'  -- yrg
          -- Se busca en la tabla de config si es cumple con el % para bonificarle moratorios  
          SELECT
            @PorcIntaBonificar = 0
          --select @PorcAbonoCapital as '@PorcAbonoCapital'  
          --SELECT ISNULL(Valor,0) FROM TablaNumD WHERE TablaNum = 'CFG QUITA MORATORIOS' AND @PorcPagoCapital > Numero   
          --SELECT @PorcIntaBonificar = ISNULL(Valor,0) FROM TablaNumD WHERE TablaNum = 'CFG QUITA MORATORIOS' AND @PorcAbonoCapital >= Numero   


          SELECT TOP 1
            @PorcIntaBonificar = ISNULL(CON.PorcDeBonificacionDeInteres, 0)
          FROM dbo.TcIRM0906_ConfigDivisionYParam CON WITH (NOLOCK)
          INNER JOIN dbo.MaviRecuperacion MA WITH (NOLOCK)
            ON ISNULL(CON.Division, '') = ISNULL(MA.Division, '')
          WHERE MA.CLIENTE = @CLIENTE
          AND MA.Ejercicio = @Year
          AND MA.QUINCENA = @Quincena
          AND @PorcAbonoCapital >= con.PorcdeAbonoFinal
          ORDER BY CON.PorcDeBonificacionDeInteres DESC
          --SELECT @PorcIntaBonificar as 'PorcIntaBonificar '  
          SELECT
            @Nota = NULL
          IF @PorcIntaBonificar > 0.0
          BEGIN
            SELECT
              @PorcMoratorioBonificar = ISNULL(@InteresPorPolitica, 0) - (ISNULL(@InteresPorPolitica, 0) * (ISNULL(@PorcIntaBonificar, 0) / 100.0))

            --UPDATE NegociaMoratoriosMAVI SET InteresAPAgarConPolitica = @PorcMoratorioBonificar WHERE IDCobro = @ID  
            SELECT
              @MoratorioXPagar = @PorcMoratorioBonificar
            -- select @PorcMoratorioBonificar as 'resto'
            --IF @PorcMoratorioBonificar > 0 
            SELECT
              @MoratoriosaBonificar = ISNULL(@InteresPorPolitica, 0) - ISNULL(@PorcMoratorioBonificar, 0)
            -- select @MoratoriosaBonificar as 'a Bonificar'
            SELECT
              @Nota = 'IM Bonificado:' + CONVERT(varchar(20), @MoratoriosaBonificar)
          END
          ELSE
          BEGIN
            UPDATE NegociaMoratoriosMAVI WITH (ROWLOCK)
            SET InteresAPAgarConPolitica = 0
            WHERE IDCobro = @ID
            SELECT
              @Nota = 'IM Bonificado: 0'
            SELECT
              @MoratoriosaBonificar = 0
            --SELECT @MoratoriosaBonificar =  ISNULL(@InteresPorPolitica,0) - ISNULL(@PorcMoratorioBonificar,0)
            SELECT
              @MoratorioXPagar = ISNULL(@InteresPorPolitica, 0) - ISNULL(@PorcMoratorioBonificar, 0)
          END

          --select 2989.61 - (2989.61 * 50.0/100)  

          -- Bonificacion Permanente Estadistico y se concluye  
          SELECT
            @EstatusCargoMorEst = NULL
          IF @InteresPorPolitica > 0
            AND @PorcIntaBonificar > 0
            AND @PorcIntaBonificar <= 100  -- Hay moratorios y entra a la config de bonif    
          BEGIN
            SELECT
              @EstatusCargoMorEst = 'CONCLUIDO'
            INSERT INTO Cxc (Empresa, Mov, MovID, FechaEmision, Concepto, UltimoCambio, Moneda, TipoCambio, Usuario, Referencia,
            Estatus, Cliente, ClienteEnviarA, ClienteMoneda, ClienteTipoCambio, Condicion, Vencimiento,
            Importe, Impuestos, AplicaManual, ConDesglose, Saldo,
            ConTramites, VIN, Sucursal, SucursalOrigen, UEN, PersonalCobrador, FechaOriginal, Nota,
            Comentarios, LineaCredito, TipoAmortizacion, TipoTasa, Amortizaciones, Comisiones, ComisionesIVA,
            FechaRevision, ContUso, TieneTasaEsp, TasaEsp, Codigo, PadreMAVI, PadreIDMAVI, IDPadreMAVI)
              VALUES (@Empresa, 'Cargo Moratorio Est', NULL, @FechaAplicacion, @Concepto, @FechaAplicacion, @Moneda, @TipoCambio, @Usuario, NULL,  --'Prueba Moratorios',                   
              'SINAFECTAR', @Cliente, @ClienteEnviarA, @Moneda, @TipoCambio, '(Fecha)', @FechaAplicacion, @MoratoriosaBonificar, @Impuesto, 0, 0, ISNULL(@MoratoriosaBonificar, 0) + ISNULL(@Impuesto, 0), 0, NULL, @Sucursal, @Sucursal, @UEN, NULL, NULL, @Nota, '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, 'Cargo Moratorio Est', NULL, @IDPadre)

            SELECT
              @IDCargoMorEst = @@IDENTITY

            EXEC spAfectar 'CXC',
                           @IDCargoMorEst,
                           'AFECTAR',
                           'Todo',
                           NULL,
                           @Usuario,
                           NULL,
                           1,
                           @Ok OUTPUT,
                           @OkRef OUTPUT,
                           NULL,
                           @Conexion = 1 --1                  

            SELECT
              @MovIDCgo = MovId
            FROM CXC WITH (NOLOCK)
            WHERE ID = @IDCargoMorEst
            UPDATE Cxc WITH (ROWLOCK)
            SET PadreIDMAVI = @MovIDCgo
            WHERE ID = @IDCargoMorEst

            INSERT INTO DetalleAfectacionMAVI (IDCobro, ID, Mov, MovID, ValorOK, ValorOKRef)
              VALUES (@ID, @IDCargoMorEst, 'Cargo Moratorio Est', @MovIDGen, @Ok, @OkRef)

            IF NOT EXISTS (SELECT
                *
              FROM MovCampoExtra WITH (NOLOCK)
              WHERE Modulo = @Modulo
              AND Mov = 'Cargo Moratorio Est'
              AND ID = @IDCargoMorEst)
            BEGIN  -- 9             
              --select 'entra campo extra 1'                                                    
              SELECT
                @CampoExtra = 'CM_FACTURA'
              SELECT
                @ValorCampoExtra = RTRIM(@Origen) + '_' + RTRIM(@OrigenId)
              --SELECT @ValorCampoExtra as 'Valor Campo Extra'  -- yrg                                                      
              INSERT INTO MovCampoExtra (Modulo, Mov, ID, CampoExtra, Valor)
                VALUES ('CXC', 'Cargo Moratorio Est', @IDCargoMorEst, @CampoExtra, @ValorCampoExtra)
            --select @@ROWCOUNT as 'rowcount 1'

            END   -- 9     

            -- Se genera en Nota de cargo el % de moratorios q no se bonifica
            --SELECT @RestoMoratorios = 
            SELECT
              @VencimientoMasAntiguo = MIN(Vencimiento)
            FROM Cxc WITH (NOLOCK)
            WHERE /*Cliente =  @Cliente*/ PadreMAVI = @Origen
            AND PadreIDMAVI = @OrigenID
            AND Estatus = 'PENDIENTE'
            IF @VencimientoMasAntiguo IS NULL
              SELECT
                @VencimientoMasAntiguo = @FechaAplicacion
          --select @VencimientoMasAntiguo as 'Vencim Mas antiguo'
          --SELECT @EstatusCargoMor = NULL    
          /* IF @PorcIntaBonificar = 100.0  --Actualizacion de remanentes y fechas a docs pagados con moratorios
         */
          -- Se registra el cobro en el Historico  
          END

          INSERT INTO CobroXPoliticaHistMAVI (IdCobro, FechaEmision, EstatusCobro, ImporteCobro, Cliente, Mov, MovID,
          SaldoIniciodelDia, TotalCobrosdelDia, PorcAbonoCapital, PorcMoratorioBonificar, TotalMoratorio, MoratorioBonificado,
          MoratorioXPagar, /*IdCargoMoratorio, EstatusCargoMoratorio,*/ IdCargoMoratorioEst, EstatusCargoMorEst)
            VALUES (@ID, @FechaAplicacion, 'SINAFECTAR', @ImporteTotal, @Cliente, @Origen, @OrigenID, @SaldoIniDia, @TotalCobrosDia, @PorcAbonoCapital, @PorcIntaBonificar, @InteresPorPolitica, ISNULL(@MoratoriosaBonificar, 0), ISNULL(@MoratorioXPagar, 0), /*@IDCargoMor, @EstatusCargoMor,*/ ISNULL(@IDCargoMorEst, 0), @EstatusCargoMorEst)

        END

        SELECT
          @Impuestos = SUM(d.importe * ISNULL(ca.IVAFiscal, 0)) --, sum(d.Importe-(d.Importe*ca.IVAFiscal)) --d.Aplica, d.AplicaID, ca.Mov, ca.MovID, ca.Saldo, isnull(ca.IVAFiscal,0.00),  ca.Saldo*isnull(ca.IVAFiscal,1)                
        FROM CXCD d WITH (NOLOCK)
        JOIN CxcAplica ca WITH (NOLOCK)
          ON d.Aplica = ca.Mov
          AND d.AplicaID = ca.MovID
          AND ca.Empresa = @Empresa
        WHERE d.ID = @ID

        SELECT
          @TotalMov = SUM(d.Importe - ISNULL(d.Importe * ca.IVAFiscal, 0))--d.Aplica, d.AplicaID, ca.Mov, ca.MovID, ca.Saldo, ca.IVAFiscal,  ca.Saldo*ca.IVAFiscal                
        FROM CXCD d WITH (NOLOCK)
        JOIN CxcAplica ca WITH (NOLOCK)
          ON d.Aplica = ca.Mov
          AND d.AplicaID = ca.MovID
          AND ca.Empresa = @Empresa
        WHERE d.ID = @ID


        UPDATE CXC WITH (ROWLOCK)
        SET Importe = ISNULL(ROUND(@TotalMov, 2), 0.00),
            Impuestos = ISNULL(ROUND(@Impuestos, 2), 0.00),
            Saldo = ISNULL(ROUND(@TotalMov, 2), 0.00) + ISNULL(ROUND(@impuestos, 2), 0.00)
        WHERE ID = @ID
        /**** Despues */


        --select ROUND(@TotalMov,2) as 'TotalMov'  -- yrg                
        -- Afectar el Cobro                  
        EXEC spAfectar 'CXC',
                       @ID,
                       'AFECTAR',
                       'Todo',
                       NULL,
                       @Usuario,
                       NULL,
                       1,
                       @Ok OUTPUT,
                       @OkRef OUTPUT,
                       NULL,
                       @Conexion = 1  --1                
        --select @OK as 'OK Cobro' -- yrg                
        --select @OkRef as 'Ok Ref'                  
        SELECT
          @MovIDGenerado = MovID
        FROM CXC WITH (NOLOCK)
        WHERE ID = @ID

        UPDATE CXC WITH (ROWLOCK)
        SET Referencia = RTRIM(@MovCobro) + '_' + RTRIM(@MovIDGenerado)
        WHERE IDCobroBonifMAVI = @ID

        -- INSERT INTO DetalleAfectacionMAVI( IDCobro, ID, Mov, MovID, ValorOK, ValorOKRef) VALUES(@ID, @ID, @MovCobro, NULL, @Ok, @OkRef )                 
        -- Actualizacion de REferencias a las notas de cargo generadas

        /*IF @IDCargoMor > 0 
          UPDATE CXC                
             SET Referencia = RTRIM(@MovCobro)+'_'+RTRIM(@MovIDGenerado)                
           WHERE ID = @IDCargoMor              */
        IF @IDCargoMorEst > 0
          UPDATE CXC WITH (ROWLOCK)
          SET Referencia = RTRIM(@MovCobro) + '_' + RTRIM(@MovIDGenerado)
          WHERE ID = @IDCargoMorEst


      END -- 3                
      IF @Ok IS NULL
        OR @Ok = 80030
      BEGIN
      COMMIT TRANSACTION BonMAVI
      SELECT
        'Proceso concluido..'
    END
    ELSE
    BEGIN
      SELECT
        @OkRef = Descripcion
      FROM MensajeLista WITH (NOLOCK)
      WHERE Mensaje = @Ok
      ROLLBACK TRANSACTION BonMAVI
      SELECT
        @OkRef   ---'Proceso con errores..'                 
    END

    RETURN
  END

  --[DESTRUCCION DE TABLAS]
  IF EXISTS (SELECT
      ID
    FROM tempdb.sys.sysobjects
    WHERE id = OBJECT_ID('tempdb.dbo.#crDetalle')
    AND type = 'U')
    DROP TABLE #crDetalle

  IF EXISTS (SELECT
      ID
    FROM tempdb.sys.sysobjects
    WHERE id = OBJECT_ID('tempdb.dbo.#crDoc')
    AND type = 'U')
    DROP TABLE #crDoc

END  -- 1       
GO
