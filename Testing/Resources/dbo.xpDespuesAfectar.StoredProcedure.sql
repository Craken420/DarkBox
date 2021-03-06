SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
-- ========================================================================================================================================      
-- NOMBRE         : xpDespuesAfectar    
-- AUTOR          : Intelisis    
-- FECHA CREACION :     
-- DESARROLLO     :     
-- MODULO         :      
-- DESCRIPCION    : Acciones a realizar  despues de Afectar en diferentes Modulos     
-- ULTIMA TEAM    :     
-- ULTIMA OFICIAL : 31032012 V1056 M1057    
-- ========================================================================================================================================    
-- FECHA Y ULTIMA MODIFICACION:   13/09/2014      Por: Jesus del Toro Andrade
-- Modificación para Nota Cargo, Nota Credito por concepto de localizacion y adjudicacion  
-- ========================================================================================================================================    
-- FECHA Y ULTIMA MODIFICACION:    20/08/2014      Por: Marco Maldovinos  
-- Se condiciona para que en las notas de cargo por concepto de cancelacion de cobro no inserte el registro en la tabla NCargoCCxPadre 
-- cuando no encuentre en la tabla movcampoextra el cobro al que aplica -- para el desarrollo dM0208
-- Se condiciona para que no cree la nota de credito espejo de la nota de cargo por concepto de localizacion y adjudicacion 
-- si es afectada en la bas de MAvicob.
-- Se llama a la función spRevisaCtaIncEnvioMaviCob para limpiar los registros cuando se cancela un cta incobrable
-- ========================================================================================================================================    
-- FECHA Y ULTIMA MODIFICACION:    22/07/2016     Por: Marco Maldovinos  
-- se agrega sp para Guardar en cxc la bonificacion que le corresponde a una venta 
-- incluye la uylitma modificacion de Abel paar Monedero
-- ========================================================================================================================================      
-- FECHA Y ULTIMA MODIFICACION:    27/07/2016     Por: Miguel Angel Valladolid Vazquez   
-- Se agrega la validacion de CXP para que detecte si es un Acuerdo Proveedor y corra el SP_DM0310MovFlujoAcuerdoProveedores  
-- ========================================================================================================================================    
-- FECHA Y AUTOR MODIFICACION: 2017-10-10 Miguel Valladolid  
-- Se agrega validacion para ligar los movimientos de tipo Factura con los reportes servicio  
-- ========================================================================================================================================      
-- FECHA Y ULTIMA MODIFICACION:    14/10/2017      Por: Carlos Alberto Diaz Jimenez  
-- En donde se llama el SP SP_MAVIDM0224NotaCreditoEspejo se cambiaron valores quemados por los definidos en   
-- la tabla de configuracion TcIDM0224_ConfigNotasEspejo  
-- ========================================================================================================================================   
-- FECHA Y ULTIMA MODIFICACION:   
-- 19/11/2017  Por: JoseAbel cruzMartinez  en Afectar Facturas canal 34 se manda llamar SP para crear Deduccion al Empleado en la Nomina
-- ========================================================================================================================================  
-- FECHA Y ULTIMA MODIFICACION:   
-- 23/10/2018  Por: Alejandra García  en las validaciones para la ejecución del sp xpActualizaRefAnticipo se exluyeron los movimientos 'Pedido Mayoreo' y 'Analisis Mayoreo'
-- ========================================================================================================================================  
CREATE PROCEDURE [dbo].[xpDespuesAfectar] @Modulo char(5),
@ID int,
@Accion char(20),
@Base char(20),
@GenerarMov char(20),
@Usuario char(10),
@SincroFinal bit,
@EnSilencio bit,
@Ok int OUTPUT,
@OkRef varchar(255) OUTPUT,
@FechaRegistro datetime
AS
BEGIN
  DECLARE @Mov varchar(20),
          @MovID varchar(20),
          @Cte varchar(10),
          @CteEnviarA int,
          @SeEnviaBuroCte bit,
          @SeEnviaBuroCanal bit,
          @Estatus varchar(15),
          @CxID int,
          @DineroID int,
          @OrigenCRI varchar(20),
          @OrigenIDCRI varchar(20),
          @EsCredilana bit,
          @Mayor12Meses bit,
          @AplicaIDCTI varchar(20),
          @AplicaCTI varchar(20),
          @NumeroDocumentos int,
          @Financiamiento money,
          @Personal varchar(10),
          @DinMovId varchar(20),
          @Origen varchar(20),
          @CtaDineroDin varchar(10),
          @CtaDineroDesDin varchar(10),
          @Aplica varchar(20),
          @AplicaID varchar(20),
          @IDNCMor int,
          @MovMor varchar(20),
          @FechaCancelacion datetime,
          @MovMorID varchar(20),
          @Concepto varchar(20),
          @OrigenID int,  -- nueva variable para calculo correcto de retenciones    
          @RetencionConcepto float,  -- nueva variable para calculo correcto de retenciones    
          @IdPadre int,
          @dAplica varchar(20),
          @dAplicaID varchar(20),
          @dPadreMAVI varchar(20),
          @dPadreIDMAVI varchar(20),
          @dFechaConclusion datetime,
          @dEstatus varchar(20),
          @PadreID int,
          @dFechaEmision datetime,
          @ImporteNC float,
          @IDNcCobro int,
          @CanalVenta int,
          --        @CategoriaVC varchar(50),     
          @OrigenPed varchar(20),
          @OrigenIDPed varchar(20),
          @Referencia varchar(50),
          @ReferenciaMavi varchar(50),
          @EngancheID int,
          @MovF varchar(20),
          @MovIDF varchar(20),
          @Empresa char(5),
          @Sucursal int,
          @FechaEmision datetime,
          @IdSoporte int,
          @Importe money,
          @Docs int,
          @Abono money

  SELECT
    @FechaEmision = dbo.FnfechaSinhora(GETDATE())

  -- MANERA GLOBAL    
  IF @Accion = 'AFECTAR'
  BEGIN
    EXEC spActualizaTiemposMAVI @Modulo,
                                @ID,
                                @Accion,
                                @Usuario
  END

  IF @Accion = 'CANCELAR'
  BEGIN
    EXEC spActualizaTiemposMAVI @Modulo,
                                @ID,
                                @Accion,
                                @Usuario
  END


  IF @Accion = 'AFECTAR'
    AND @Modulo = 'VTAS'
  BEGIN
    SELECT
      @Mov = Mov,
      @MovID = MovID,
      @Estatus = Estatus,
      @CanalVenta = ENVIARA,
      @Cte = Cliente,
      @Importe = Importe + Impuestos,
      @Docs = CO.daNumeroDocumentos * 2,
      @Abono =
              CASE
                WHEN @Docs > 0 THEN @Importe / @Docs
                ELSE 0
              END
    FROM Venta V WITH (NOLOCK)
    INNER JOIN CONDICION CO WITH (NOLOCK)
      ON CO.CONDICION = V.CONDICION
    WHERE ID = @ID
    EXEC spClientesNuevosCasaMAVI @Modulo,
                                  @ID,
                                  @Accion  -- Modificacion para indicar si un movimiento es Nuevo o de Casa 04-Sep-08 Arly Rubio    
    EXEC spGenerarFinanciamientoMAVI @ID,
                                     'VTAS'   -- spParaGenerar el financiamiento que se tienen que pagar por cada credilana y prestamo personal    
    IF @Mov IN ('Analisis Credito', 'Pedido') --AND @Estatus='Concluido'    
    BEGIN
      EXEC xpActualizaRefAnticipo @ID,
                                  @Mov -- SP para copiar la referencia de una Solicitud XXXX o Analisis XXXXX a un Pedido XXXXX    
    END
    --IF @Mov IN ('Factura','Factura VIU','Factura Mayoreo')    
    --EXEC xpActualizarAplicacionMAVI @ID    
    IF dbo.fnClaveAfectacionMavi(@Mov, 'VTAS') = 'VTAS.F'
      AND @Estatus = 'Concluido'
    BEGIN
      SET @CxID = NULL
      SELECT
        @CxID = Cxc.ID
      FROM Cxc WITH (NOLOCK)
      JOIN CxcD WITH (NOLOCK)
        ON Cxc.ID = CxcD.ID
      WHERE CxcD.Aplica = @Mov
      AND CxcD.AplicaID = @MovID
      AND Cxc.Estatus = 'Concluido'
      AND Cxc.Mov = 'Aplicacion Saldo'

      /* Adecuacion para corregir referencia a Aplicacion Saldo cuando se afecta el pedido. JR 02-Ene-2013 */
      /*  SELECT @OrigenPed=Origen, @OrigenIDPed=OrigenID FROM Venta WHERE ID=@ID  

        IF ((SELECT Mov FROM Venta WHERE ID=@ID) IN ('Factura', 'Factura VIU') 
          AND (SELECT C.Categoria FROM Venta V, VentasCanalMAVI C WHERE V.ID=@ID AND V.EnviarA=C.ID)='CREDITO MENUDEO')
        BEGIN               
          SELECT @OrigenPed=Origen, @OrigenIDPed=OrigenID FROM Venta WHERE Mov=@OrigenPed AND MovID=@OrigenIDPed                
          UPDATE Cxc SET Referencia=@OrigenPed+ ' ' + @OrigenIDPed WHERE ID=@CxID 
        END
        */
      IF @CxID IS NOT NULL
        EXEC xpDistribuyeSaldo @CxID


      -- SP de comercializadora al afectar una factura, para generar 'Otra Deducciones' en la Nomina
      IF @CanalVenta = 34
      BEGIN
        SELECT
          @Personal = Nomina
        FROM CTEENVIARA ce WITH (NOLOCK)
        WHERE cliente = @cte
        AND id = 34
        IF ISNULL(@Personal, '') > ''
          EXEC Comercializadora.dbo.SPIDM0221_DeduccionCompras @Cte,
                                                               @Mov,
                                                               @MoVid,
                                                               @Abono,
                                                               @Personal,
                                                               @Docs
      END

    END

    IF @Mov IN ('Cancela Credilana', 'Cancela Prestamo')
      AND @Estatus = 'CONCLUIDO'
    BEGIN
      SELECT
        @DineroID = NULL
      SELECT
        @DineroID = IDIngresoMAVI
      FROM Venta WITH (NOLOCK)
      WHERE ID = @ID
      IF EXISTS (SELECT
          ID
        FROM Dinero WITH (NOLOCK)
        WHERE ID = @DineroID
        AND Estatus = 'SINAFECTAR')
      BEGIN --1A    
        EXEC spAfectar 'DIN',
                       @DineroID,
                       'AFECTAR',
                       'TODO',
                       NULL,
                       @Usuario,
                       0,
                       0,
                       @Ok OUTPUT,
                       @OkRef OUTPUT,
                       NULL,
                       0,
                       NULL
        IF (SELECT
            Estatus
          FROM Dinero WITH (NOLOCK)
          WHERE ID = @DineroID)
          = 'CONCLUIDO'
        BEGIN --2A    
          UPDATE Dinero WITH (ROWLOCK)
          SET Referencia = @Mov + ' ' + @MovID
          WHERE ID = @DineroID
          SELECT
            @Ok = 80300
          SELECT
            @OkRef = Mov + ' ' + MovID
          FROM Dinero WITH (NOLOCK)
          WHERE ID = @DineroID
        END --2A    
      END --1A    
    END  -- Fin Mov IN ( 'Cancela Credilana', 'Cancela Prestamo' ) y Estatus = 'CONCLUIDO'      
    /* Facturacion Electronica BVF 05-05-10 */
    EXEC spActualizaDesglose @ID,
                             @Mov,
                             '',
                             'CXC'

    /* Adecuacion para aplicacion de enganches creados en el analiis de credito. JR 02-Ene-2013 */
    /*IF (@Mov='Pedido' AND @Estatus='PENDIENTE')
    BEGIN 
      SELECT @ReferenciaMavi=Origen + ' ' + OrigenID FROM Venta WHERE ID=@ID  

      IF (EXISTS (SELECT C.ID FROM Cxc C JOIN Anticipo A ON C.ID=A.ModuloID WHERE C.Mov='Enganche' AND C.Referencia<>A.Referencia 
            AND A.ModuloID=C.ID AND C.Referencia LIKE 'Analisis Credito%') )
        UPDATE A SET A.Referencia=C.Referencia FROM Cxc C JOIN Anticipo A ON C.ID=A.ModuloID WHERE C.Mov='Enganche' 
            AND A.ModuloID=C.ID AND A.Referencia<>C.Referencia AND C.Referencia=@ReferenciaMavi  

    END */

    DECLARE @clave varchar(10) -- agregado en la restructurade la bonificacion
    SELECT
      @clave = Clave
    FROM MovTipo WITH (NOLOCK)
    WHERE Modulo = @Modulo
    AND Mov = @Mov -- agregado en la restructurade la bonificacion

    -- IF ((SELECT Clave FROM MovTipo WITH (NOLOCK) WHERE Modulo=@Modulo AND Mov=@Mov) ='VTAS.F') --Se cambia y mejor se usa el valor en una variable
    IF (ISNULL(@clave, '') = 'VTAS.F') -- agregado en la restructurade la bonificacion
    BEGIN
      IF (EXISTS (SELECT TOP 1
          Mov
        FROM Cxc WITH (NOLOCK)
        WHERE Mov = 'Documento'
        AND PadreMavi = @Mov
        AND PadreIDMavi = @MovID
        AND Referencia <> ReferenciaMAVI)
        )
        UPDATE Cxc WITH (ROWLOCK)
        SET Referencia = ReferenciaMAVI
        WHERE Mov = 'Documento'
        AND PadreMavi = @Mov
        AND PadreIDMavi = @MovID
        AND Referencia <> ReferenciaMAVI
    END
    IF (ISNULL(@clave, '') IN ('VTAS.F', 'VTAS.D'))  -- agregado en la restructurade la bonificacion
    BEGIN
      EXEC SP_MAVIDM0279CalcularBonif @Mov,
                                      @MovID,
                                      @ID,
                                      0,
                                      @clave -- SP para guardar en cxc el id de las bonificaciones que le corresponden a una venta
    END


    IF (ISNULL(@clave, '') IN ('VTAS.F', 'VTAS.P'))
    BEGIN
      EXEC SpVTASActualizaEstatusTarjeta @ID
    END


  END  -- FI accion = 'Afectar' and modulo = 'VTAS'  

  IF @Accion = 'CANCELAR'
    AND @Modulo = 'VTAS'
  BEGIN
    SELECT
      @Mov = Mov,
      @MovID = MovID,
      @Estatus = Estatus
    FROM Venta WITH (NOLOCK)
    WHERE ID = @ID
    EXEC spEliminarRecuperacionMAVI @ID -- sp para elimianar de la tabla: RecuperacionCredilanasPPMAVI la credilana o PP Cancelado

    DECLARE @clavemov varchar(10) --agregado en la restructuarde Bonificaicones
    SELECT
      @clavemov = dbo.fnClaveAfectacionMavi(@Mov, 'VTAS') --agregado en la restructuarde Bonificaicones

    -- IF dbo.fnClaveAfectacionMavi(@Mov, 'VTAS') = 'VTAS.F' -- se cambia por una variable en las restructura de Bonificaciones
    IF ISNULL(@clavemov, '') = 'VTAS.F'
      AND @Estatus = 'Cancelado'
    BEGIN
      SET @CxID = NULL
      SELECT
        @CxID = Cxc.ID
      FROM Cxc WITH (NOLOCK)
      JOIN CxcD WITH (NOLOCK)
        ON Cxc.ID = CxcD.ID
      WHERE CxcD.Aplica = @Mov
      AND CxcD.AplicaID = @MovID
      AND Cxc.Estatus = 'Cancelado'
      AND Cxc.Mov = 'Aplicacion Saldo'
      IF @CxID IS NOT NULL
        EXEC xpDistribuyeSaldoCancelarMAVI @CxID
    END

    SELECT
      @clave = Clave
    FROM MovTipo WITH (NOLOCK)
    WHERE Modulo = @Modulo
    AND Mov = @Mov

    IF ISNULL(@clavemov, '') = 'VTAS.D' --agregado en la restructura de Bonificaciones
      EXEC SP_MAVIDM0279CalcularBonif @Mov,
                                      @MovID,
                                      @ID,
                                      0,
                                      @clavemov -- Se recalcula las bonificacines cuando se cancela una devolución  

    IF (ISNULL(@clave, '') IN ('VTAS.F', 'VTAS.P'))
    BEGIN
      EXEC SpVTASActualizaEstatusTarjeta @ID
    END

  END


  -- MODULO DE CUENTAS POR COBRAR    

  IF @Accion = 'AFECTAR'
    AND @Modulo = 'CXC'
  BEGIN
    EXEC spActualizarProgramaRecuperacionMAVI @ID --sp para actualizar la tabla: RecuperacionCredilanasPPMAVI y RecuperacionCredilanasPPMAVI    
    EXEC spApoyoFactorIMMavi @ID  -- sp de apoyo para Intereses Moratorios    

    /**** parte agregada para asiganar a la factura si se envia o no a buro ****/
    SELECT
      @Mov = Mov,
      @MovID = MovID,
      @Estatus = Estatus,
      @Financiamiento = Financiamiento,
      @concepto = Concepto
    FROM CxC WITH (NOLOCK)
    WHERE ID = @ID

    --Cobros    

    IF (SELECT
        Clave
      FROM MovTipo WITH (NOLOCK)
      WHERE Modulo = 'CXC'
      AND Mov = @Mov)
      = 'CXC.C'
    BEGIN

      SELECT
        @dFechaConclusion = FechaConclusion,
        @dEstatus = Estatus
      FROM Cxc WITH (NOLOCK)
      WHERE ID = @ID

      DECLARE @PadresCobrados TABLE (
        IDTmp int IDENTITY PRIMARY KEY,
        ID int,
        PadreMavi varchar(20),
        PadreIDMavi varchar(20),
        Importe float
      )

      INSERT INTO @PadresCobrados
        SELECT
          F.ID,
          F.Mov,
          F.MovID,
          SUM(D.Importe)
        FROM CxcD D WITH (NOLOCK)
        JOIN CxC C WITH (NOLOCK)
          ON D.Aplica = C.Mov
          AND D.AplicaID = C.MovID
        JOIN CxC F WITH (NOLOCK)
          ON C.PadreMavi = F.Mov
          AND C.PadreIDMavi = F.MovID
        WHERE D.ID = @ID
        GROUP BY F.ID,
                 F.Mov,
                 F.MovID



      INSERT INTO CobrosxPadre
        SELECT
          P.ID,
          @ID,
          @dFechaConclusion,
          P.Importe,
          @dEstatus,
          'CXC.C'
        FROM @PadresCobrados P
    END
    --IF ( SELECT Clave    
    --     FROM   MovTipo WITH (NOLOCK)    
    --     WHERE  Modulo = 'CXC'    
    --            AND Mov = @Mov    
    --   ) = 'CXC.C'    
    --    BEGIN    
    --        INSERT  INTO CobrosxPadre    
    --                SELECT  p.ID,   
    --                c.ID,    
    --                c.FechaConclusion,   
    --                SUM(ISNULL(d.Importe, 0)),  
    --                c.Estatus,    
    --         'CXC.C'  
    --        --INTO    #CobrosxPadre    
    --        FROM    CXC c WITH (NOLOCK)    
    --                JOIN CXCD d WITH ( NOLOCK ) ON c.ID = d.ID --Cobros    
    --                JOIN CXC doc WITH ( NOLOCK ) ON d.Aplica = doc.mov    
    --                                              AND d.AplicaID = doc.MovID  --Detalle Cobro    
    --                JOIN CXC p WITH ( NOLOCK ) ON doc.PadreMAVI = p.Mov  
    --                                              AND doc.PadreIDMAVI = p.MovID  --Padres    
    --        WHERE   c.ID = @ID  
    --        GROUP BY p.ID,  
    --                 c.ID,  
    --                 c.FechaConclusion,  
    --                 c.estatus  
    --         -- IdCobro    
    --        /*INSERT  INTO CobrosxPadre    
    --                SELECT  IDPadre ,    
    --                        IDCobro ,    
    --                        FechaConclusion ,    
    --                        SUM(ISNULL(Importe, 0)) ,    
    --                        Estatus ,    
    --                        Clave    
    --                FROM    #CobrosxPadre    
    --                GROUP BY IDPadre ,    
    --                        IDCobro ,    
    --                        FechaConclusion ,    
    --                        estatus ,    
    --                        Clave  */  
    --    END    

    --Notas de Cargo por Cancelacion de Cobro     
    IF (SELECT
        Clave
      FROM MovTipo WITH (NOLOCK)
      WHERE Modulo = 'CXC'
      AND Mov = @Mov)
      = 'CXC.CA'
      AND @Concepto LIKE 'CANC COBRO%'
    BEGIN
      /*INSERT  INTO NCargoCCxPadre    
              SELECT  p.ID AS IDPadre ,    
                      SUBSTRING( SUBSTRING(me.Valor,( CHARINDEX('_',me.Valor) + 1 ),LEN(me.valor)) ,     
                       CHARINDEX('_',( SUBSTRING(me.Valor,( CHARINDEX('_',me.Valor) + 1 ),LEN(me.valor)) )) + 1,     
                       LEN(SUBSTRING(me.Valor,( CHARINDEX('_',me.Valor) + 1 ),LEN(me.valor)) ) ) AS IDCobro ,    
                      c.ID AS IDNCargo ,    
                      c.FechaEmision AS FechaEmision ,    
                      ISNULL(c.Importe, 0) AS ImporteNCargo ,    
                      c.Estatus AS EstatusNCargo    
              FROM    CXC c WITH ( NOLOCK ) --NotaCargo    
                      JOIN CXC p WITH ( NOLOCK ) ON p.Mov = c.PadreMAVI    
                                            AND p.MovID = c.PadreIDMAVI --IDPadre    
                      JOIN MovCampoExtra me WITH ( NOLOCK ) ON me.ID = c.ID    
AND me.Mov = c.Mov --IDCobro    
              WHERE   c.ID = @ID -- IdNCcc    
                      AND me.CampoExtra IN ( 'NC_COBRO',    
                                            'NCV_COBRO' )    */
      SELECT
        @dPadreMAVI = padremavi,
        @dPadreIDMAVI = padreidmavi,
        @dFechaEmision = fechaemision,
        @mov = mov,
        @ImporteNC = ISNULL(Importe, 0) + ISNULL(Impuestos, 0),
        @dEstatus = Estatus
      FROM cxc WITH (NOLOCK)
      WHERE id = @ID
      SELECT
        @PadreID = id
      FROM cxc WITH (NOLOCK)
      WHERE mov = @dPadreMAVI
      AND movid = @dPadreIDMAVI
      SELECT
        @IDNcCobro = (SUBSTRING(SUBSTRING(Valor, (CHARINDEX('_', Valor) + 1), LEN(valor)),
        CHARINDEX('_', (SUBSTRING(Valor, (CHARINDEX('_', Valor) + 1), LEN(valor)))) + 1,
        LEN(SUBSTRING(Valor, (CHARINDEX('_', Valor) + 1), LEN(valor)))))
      FROM movcampoextra WITH (NOLOCK)
      WHERE CampoExtra IN ('NC_COBRO', 'NCV_COBRO', 'NCM_COBRO')
      AND ID = @ID
      AND mov = @mov

      /**/ IF @IDNcCobro IS NOT NULL  -- Para que no marque error de nullos cuando se ejecuta en Mavicob       
        INSERT INTO NCargoCCxPadre
          SELECT
            @PadreID,
            @IDNcCOBRO,
            @ID,
            @dFechaEmision,
            @ImporteNC,
            @dEstatus

      SELECT
        @IDPadre = IDPadre
      FROM dbo.NCargoCCxPadre WITH (NOLOCK)
      WHERE IDNCargo = @ID

      IF (SELECT
          COUNT(*)
        FROM CobrosxPadre WITH (NOLOCK)
        WHERE IDPadre = @IDPadre
        AND Estatus = 'CONCLUIDO')
        = 1
      BEGIN
        UPDATE CXC WITH (ROWLOCK)
        SET CalificacionMAVI = 0,
            PonderacionCalifMAVI = '*'
        WHERE ID = @IdPadre
        UPDATE CXCMAVI WITH (ROWLOCK)
        SET MopMavi = 0,
            MopActMAVI = NULL,
            FechaUltAbono = NULL
        WHERE ID = @IdPadre
        DELETE dbo.HistoricoMOPMAVI
        WHERE ID = @IdPadre
      END
      EXEC SP_MAVIDM0279CalcularBonif @Mov,
                                      @MovID,
                                      0,
                                      @ID,
                                      'CXC.CA'  -- SP para guardar el id de la bonifificaion que le corresponde a la venta a la nota de cargo       
    END     -- Fin  clave = 'CXC.CA'     y Concepto LIKE 'CANC COBRO%'

    --Notas de Credito por Correccion de Cobro    
    -- Este flujo ya no se usa actualmente se confirmo con Israel BVF 30082012
    /*            IF ( SELECT Clave    
                     FROM   MovTipo WITH (NOLOCK)    
                     WHERE  Modulo = 'CXC'    
                            AND Mov = @Mov    
                   ) = 'CXC.ANC'    
                    AND @Concepto LIKE 'CORR COBRO%'     
                    BEGIN    
                        INSERT  INTO CobrosxPadre    
                                SELECT  p.ID AS IDPadre ,    
                                        c.ID AS IDCobro ,    
                                        c.FechaEmision ,    
                                        SUM(ISNULL(d.Importe, 0)) AS Importe ,    
                                        c.Estatus AS Estatus ,    
                                        'CXC.ANC' AS Clave    
                                FROM    Cxc c WITH (NOLOCK)    
                                        JOIN Movtipo mt WITH (NOLOCK) ON c.Mov = mt.Mov    
                                                           AND mt.Clave = 'CXC.ANC' --Notas Credito    
                                        JOIN CXCD d WITH (NOLOCK) ON c.ID = d.ID   --Aplica    
                                        JOIN CXC doc WITH (NOLOCK) ON doc.Mov = d.Aplica    
                                                        AND doc.MovID = d.AplicaID  --Padres    
    JOIN CXC p WITH (NOLOCK) ON P.Mov = doc.PadreMAVI    
                                                      AND p.MovID = doc.PadreIDMAVI    
                                WHERE   c.Concepto LIKE 'CORR COBRO%'    
                                        AND c.ID = @ID    
                                GROUP BY p.ID ,    
                                        c.ID ,    
                                        C.FechaEmision ,    
                                        d.Importe ,    
                                        c.Estatus ,    
                                        Clave    
                    END    
    */

    IF (SELECT
        Clave
      FROM MovTipo WITH (NOLOCK)
      WHERE Modulo = 'CXC'
      AND Mov = @Mov)
      = 'CXC.NC'
      AND @Concepto LIKE 'CORR COBRO%'
    BEGIN
      /*INSERT  INTO CobrosxPadre    
              SELECT  p.ID AS IDPadre ,    
                      c.ID AS IDCobro ,    
                      c.FechaEmision ,    
           SUM(ISNULL(d.Importe, 0)) AS Importe ,    
                      c.Estatus AS Estatus ,    
                      'CXC.NC' AS Clave    
              FROM    Cxc c WITH (NOLOCK)    
                      JOIN Movtipo mt WITH (NOLOCK) ON c.Mov = mt.Mov    
                                         AND mt.Clave = 'CXC.NC' --Notas Credito    
                      JOIN CXCD d WITH (NOLOCK) ON c.ID = d.ID   --Aplica    
                      JOIN CXC doc WITH (NOLOCK) ON doc.Mov = d.Aplica    
                                      AND doc.MovID = d.AplicaID  --Padres    
                      JOIN CXC p WITH (NOLOCK) ON P.Mov = doc.PadreMAVI    
                AND p.MovID = doc.PadreIDMAVI    
              WHERE   c.Concepto LIKE 'CORR COBRO%'    
                      AND c.ID = @ID    
              GROUP BY p.ID ,    
                      c.ID ,    
                      C.FechaEmision ,    
                      d.Importe ,    
                      c.Estatus ,    
                      Clave    */
      SELECT TOP 1
        @dAplica = Aplica,
        @dAplicaID = AplicaID
      FROM CxcD WITH (NOLOCK)
      WHERE ID = @ID
      SELECT
        @dFechaEmision = FechaEmision,
        @dEstatus = Estatus
      FROM Cxc WITH (NOLOCK)
      WHERE ID = @ID
      SELECT
        @dPadreMAVI = PadreMavi,
        @dPadreIDMAVI = PadreIDMavi
      FROM Cxc WITH (NOLOCK)
      WHERE Mov = @dAplica
      AND MovID = @dAplicaID
      SELECT
        @PadreID = ID
      FROM cxc WITH (NOLOCK)
      WHERE Mov = @dPadreMAVI
      AND MovID = @dPadreIDMAVI

      INSERT INTO CobrosxPadre
        SELECT
          @PadreID,
          @ID,
          @dFechaEmision,
          SUM(ISNULL(Importe, 0)),
          @dEstatus,
          'CXC.NC'
        FROM Cxcd WITH (NOLOCK)
        WHERE id = @ID
    END
    --Endosos    

    IF (@Mov IN ('Endoso'))
    BEGIN
      SELECT
        @Mov = Mov,
        @MovID = MovID,
        @Cte = Cliente,
        @CteEnviarA = ClienteEnviarA
      FROM CxC WITH (NOLOCK)
      WHERE ID = @ID
      SELECT
        @SeEnviaBuroCte = SeEnviaBuroCreditoMavi
      FROM CteEnviarA WITH (NOLOCK)
      WHERE Cliente = @Cte
      AND ID = @CteEnviarA
      SELECT
        @SeEnviaBuroCanal = SeEnviaBuroCreditoMavi
      FROM VentasCanalMavi WITH (NOLOCK)
      WHERE ID = @CteEnviarA

      IF (@SeEnviaBuroCte = 1)
        EXEC spCambiarCxcBuroCanalVenta @Mov,
                                        @MovID
    END
    ---- sp q desactiva la factura(doctos) que se aplico a una cuenta incobrable     
    IF (@Mov IN ('Cta Incobrable F', 'Cta Incobrable NV'))
    BEGIN
      EXEC spDesactivaEnviarBuroFactEnCtaInc @ID

      /**** Validacion para actualizar el id de la cta inc en respaldo para enviar a mavicob en caso de que se
          haya generado mas de 1 cta incobrable para una factura. JR 05-Oct-2012***/
      IF (@Estatus = 'PENDIENTE')
        EXEC spActualizaCtaIncMigraMaviCob @ID
    END


    /****   fin    ****/
    --IF @Mov = 'Aplicacion Saldo' AND @Estatus='CONCLUIDO'    
    --EXEC xpDistribuyeSaldo @ID    

    --IF (@Mov = 'Devolucion Enganche') --AND @Estatus='CONCLUIDO')    
    IF dbo.fnClaveAfectacionMAVI(@Mov, 'CXC') IN ('CXC.DE')
    BEGIN
      EXEC xpDevolucionAnticipoSaldoMavi @ID,
                                         @Usuario
      UPDATE Cxc WITH (ROWLOCK)
      SET Referencia = RefAnticipoMavi
      WHERE ID = @ID
    END

    -- Se agregaron los campos de EsCredilana y Mayor12Meses a los Contra Recibo Inst      ALQG    
    IF (@Mov IN ('Contra Recibo Inst'))
    BEGIN
      SELECT
        @OrigenCRI = Origen,
        @OrigenIDCRI = OrigenID
      FROM CXC WITH (NOLOCK)
      WHERE ID = @ID
      SELECT
        @EsCredilana = EsCredilana,
        @Mayor12Meses = Mayor12Meses
      FROM CXC WITH (NOLOCK)
      WHERE Mov = @OrigenCRI
      AND MovID = @OrigenIDCRI
      AND Estatus IN ('CONCLUIDO', 'PENDIENTE')
      UPDATE Cxc WITH (ROWLOCK)
      SET EsCredilana = @EsCredilana,
          Mayor12Meses = @Mayor12Meses
      WHERE ID = @ID
    END

    -- Se agregaron los campos de EsCredilana y Mayor12Meses a las Cuentas Incobrables  ALQG    
    IF (@Mov IN ('Cta Incobrable NV', 'Cta Incobrable F'))
    BEGIN
      SELECT
        @AplicaCTI = Aplica,
        @AplicaIDCTI = MIN(AplicaId)
      FROM CxcD WITH (NOLOCK)
      WHERE Id = @ID
      GROUP BY Aplica
      SELECT
        @EsCredilana = EsCredilana,
        @Mayor12Meses = Mayor12Meses
      FROM CXC WITH (NOLOCK)
      WHERE Mov = @AplicaCTI
      AND MovId = @AplicaIDCTI
      AND Estatus IN ('CONCLUIDO', 'PENDIENTE')
      UPDATE Cxc WITH (ROWLOCK)
      SET EsCredilana = @EsCredilana,
          Mayor12Meses = @Mayor12Meses
      WHERE ID = @ID
    END

    /*** modificacion JR, se agrego sp para actualizar los campos de Mayor12Meses y EsCredilana para anticipos y devoluciones ***/
    IF (@Mov IN ('Anticipo Contado', 'Anticipo Mayoreo',
      'Apartado', 'Enganche', 'Devolucion',
      'Dev Anticipo Contado', 'Dev Anticipo Mayoreo',
      'Devolucion Enganche', 'Devolucion Apartado'))
      EXEC spMayor12AnticipoDev @ID

    -- EM - 220409    
    --IF @Mov = 'Sol Refinanciamiento' AND @Estatus='PENDIENTE'    
    --UPDATE Cxc SET Condicion=CondRef WHERE ID=@ID    

    IF @Mov = 'Refinanciamiento'
      AND @Estatus = 'CONCLUIDO'
    BEGIN
      EXEC spGenerarFinanciamientoMAVI @ID,
                                       'CXC' -- Para credilanas y prestamos personales Miguel Pe¤a    
      SELECT
        @NumeroDocumentos = 0
      EXEC spPrendeMayor12Mavi @ID
      EXEC spPrendeBitsMAVI @ID
      UPDATE Cxc WITH (ROWLOCK)
      SET Referencia = @Mov + ' ' + @MovID
      WHERE ID IN (SELECT
        IDCxc
      FROM RefinIDInvolucra WITH (NOLOCK)
      WHERE ID = @ID)
      UPDATE Cxc WITH (ROWLOCK)
      SET Concepto = 'REFINANCIAMIENTO'
      WHERE Referencia = @Mov + ' ' + @MovID
      AND Mov = 'Nota Cargo'
      AND @Estatus = 'CONCLUIDO'
      SELECT
        @NumeroDocumentos = NumeroDocumentos
      FROM DocAuto WITH (NOLOCK)
      WHERE Modulo = 'CXC'
      AND Mov = @Mov
      AND MovID = @MovID
      IF ISNULL(@NumeroDocumentos, 0) > 0
      BEGIN  -- ARC Quitar estas lineas cuando se integre la recuperacion    
        SELECT
          @Financiamiento = @Financiamiento
          / @NumeroDocumentos
        UPDATE Cxc WITH (ROWLOCK)
        SET Financiamiento = @Financiamiento
        WHERE Origen = @Mov
        AND OrigenID = @MovID
        AND Mov = 'Documento'
        AND Estatus = 'PENDIENTE'
      END
    END
    IF @Mov = 'Refinanciamiento'
      AND @Estatus = 'PENDIENTE'
      UPDATE Cxc WITH (ROWLOCK)
      SET Referencia = @Mov + ' ' + @MovID
      WHERE ID IN (SELECT
        IDCxc
      FROM RefinIDInvolucra WITH (NOLOCK)
      WHERE ID = @ID)
    -- EM - 220409 (FIN)    
    /* Facturacion Electronica BVF 05-05-10 */
    EXEC spActualizaDesglose @ID,
                             '',
                             '',
                             'CXC'

    IF @Mov IN ('Nota Cargo', 'Nota Cargo VIU',
      'Nota Cargo Mayoreo')
    BEGIN
      UPDATE Cxc WITH (ROWLOCK)
      SET FechaOriginal = Vencimiento
      WHERE ID = @ID
    END

    IF @Mov IN ('Nota Credito', 'Nota Credito VIU',
      'Nota Credito Mayoreo', 'Cancela Prestamo', 'Cancela Credilana')
      AND @Concepto LIKE 'CORR COBRO%'
    BEGIN
      UPDATE Cxc WITH (ROWLOCK)
      SET Nota = (SELECT TOP 1
        Padre.ID
      FROM CXC c WITH (NOLOCK)
      JOIN CXCd d WITH (NOLOCK)
        ON d.ID = c.ID
      JOIN CXC f WITH (NOLOCK)
        ON f.Mov = d.Aplica
        AND f.MovID = d.AplicaID
      JOIN CXC Padre WITH (NOLOCK)
        ON Padre.Mov = f.PadreMAVI
        AND Padre.MovID = f.PadreIDMAVI
      WHERE c.ID = @ID)
      WHERE ID = @ID
    END
  END  -- Fin  Accion = 'AFECTAR'   y   Modulo = 'CXC'   

  IF @Accion = 'CANCELAR'
    AND @Modulo = 'CXC'
  BEGIN
    EXEC spActualizarProgramaRecuperacionAlCancelarMAVI @ID  --sp para actualizar la tabla: RecuperacionCredilanasPPMAVI y RecuperacionCredilanasPPMAVI    

    /**** parte que activa de nuevo la factura que se aplico a una Cta incobrable al ser cancelada la cta inc  para desarrollo     
       buro de credito   ****/
    SELECT
      @Mov = Mov,
      @Estatus = Estatus,
      @Concepto = Concepto
    FROM Cxc WITH (NOLOCK)
    WHERE ID = @ID

    --Notas de Credito por correccion de cobro    
    IF (SELECT
        Clave
      FROM MovTipo WITH (NOLOCK)
      WHERE Modulo = 'CXC'
      AND Mov = @Mov)
      = 'CXC.ANC'
      AND @Concepto LIKE 'CORR COBRO%'
      UPDATE CobrosxPadre WITH (ROWLOCK)
      SET Estatus = 'CANCELADO'
      WHERE IDCobro = @ID

    IF (SELECT
        Clave
      FROM MovTipo WITH (NOLOCK)
      WHERE Modulo = 'CXC'
      AND Mov = @Mov)
      = 'CXC.NC'
      AND @Concepto LIKE 'CORR COBRO%'
      UPDATE CobrosxPadre WITH (ROWLOCK)
      SET Estatus = 'CANCELADO'
      WHERE IDCobro = @ID

    --Cobros Por Padre     
    IF @Mov LIKE 'Cobro%'
      UPDATE CobrosxPadre WITH (ROWLOCK)
      SET Estatus = 'CANCELADO'
      WHERE IDCobro = @ID

    --Notas de Cargo por cancelacion de cobro    
    IF (SELECT
        Clave
      FROM MovTipo WITH (NOLOCK)
      WHERE Modulo = 'CXC'
      AND Mov = @Mov)
      = 'CXC.CA'
      AND @Concepto LIKE 'CANC COBRO%'
      UPDATE NCargoCCxPadre WITH (ROWLOCK)
      SET EstatusNCargo = 'CANCELADO'
      WHERE IDNCargo = @ID


    IF (@Mov IN ('Cta Incobrable F', 'Cta Incobrable NV'))
      EXEC spActivaEnviarBuroFactEnCtaInc @ID

    /*** instruccion para desarrollo cobranza instituciones ARC ***/
    --IF @Mov = 'Cobro Instituciones'  se comenta el codigo por que no actualiza correctamente  
    --    AND @Estatus = 'CANCELADO'     
    --    EXEC spCancelarCobroInstMAVI @ID    


    --IF @Mov = 'Enganche' --AND @Estatus='Cancelado'    
    IF dbo.fnClaveAfectacionMAVI(@Mov, 'CXC') IN ('CXC.AA')
      AND @Estatus = 'Cancelado'
    BEGIN
      --IF (SELECT Referencia FROM Anticipo WHERE ModuloID=@ID AND Modulo='CXC') LIKE 'Pedido%'    
      EXEC xpCancelaEnganche @ID,
                             @Usuario
    END

    --IF @Mov = 'Devolucion Enganche' --AND @Estatus='Cancelado'    
    IF dbo.fnClaveAfectacionMAVI(@Mov, 'CXC') IN ('CXC.DE')
    BEGIN
      EXEC xpCancelaDevolucion @ID
    END
    --CFD  BVF    
    IF @Mov IN ('Nota Cargo', 'Nota Cargo VIU',
      'Nota Cargo Mayoreo', 'Nota Credito',
      'Nota Credito VIU', 'Nota Credito Mayoreo')
      AND @Estatus = 'CANCELADO'
    BEGIN
      IF EXISTS (SELECT
          ModuloID
        FROM CFD WITH (NOLOCK)
        WHERE ModuloID = @ID)
      BEGIN
        SELECT
          @FechaCancelacion = FechaCancelacion
        FROM CXC WITH (NOLOCK)
        WHERE ID = @ID
        UPDATE CFD WITH (ROWLOCK)
        SET FechaCancelacion = @FechaCancelacion
        WHERE ModuloID = @ID
      END
    END



    -- Limpia la tablas del proceso de envio a Mavicob cuando se cancela la cta incobrable      
    IF (dbo.fnClaveAfectacionMAVI(@Mov, 'CXC') = 'CXC.DM')
      AND @Accion = 'CANCELAR'
      AND @Ok IS NULL
      EXEC spRevisaCtaIncEnvioMaviCob @ID






  END


  -- MODULO DE ACTIVOS FIJOS    

  IF @Accion = 'AFECTAR'
    AND @Modulo = 'AF'
  BEGIN
    EXEC spActualizarServicioAFAlAfectarMAVI @ID  -- Modifica el ultimo km y tipo de servicio del activo fijo 01-Sep-08 (Arly)    
  END

  IF @Accion = 'CANCELAR'
    AND @Modulo = 'AF'
  BEGIN
    EXEC spActualizarServicioAFAlCancelarMAVI @ID -- Modifica el ultimo km y tipo de servicio del activo fijo 01-Sep-08 (Arly)       
  END


  -- MODULO DE GASTOS    

  IF @Accion = 'AFECTAR'
    AND @Modulo = 'GAS'
  BEGIN
    SELECT
      @Mov = Mov,
      @MovID = MovID
    FROM Gasto WITH (NOLOCK)
    WHERE Id = @Id

    IF @Mov = 'Cargo Bancario'
      UPDATE Gasto WITH (ROWLOCK)
      SET GenerarDinero = 0
      WHERE Id = @Id

    IF @Mov = 'Contrato'
    BEGIN

      EXEC spSolGastoContratoDF @ID

      -- Actualizar la fecha de vencimiento de la solicitud BVF 29032012    
      UPDATE Gasto WITH (ROWLOCK)
      SET Vencimiento = FechaRequerida
      WHERE Origen = @Mov
      AND OrigenID = @MovID

    END

    -- validacion para calculo correcto de retenciones    
    SELECT
      @Mov = Mov,
      @MovID = MovID
    FROM Gasto WITH (NOLOCK)
    WHERE ID = @ID
    SELECT
      @OrigenID = ID
    FROM CxP WITH (NOLOCK)
    WHERE Mov = @Mov
    AND MovID = @MovID
    IF @Mov = 'GASTO'
    BEGIN
      IF (EXISTS (SELECT
          Retencion2
        FROM MovImpuesto WITH (NOLOCK)
        WHERE Modulo = 'GAS'
        AND ModuloID = @ID
        AND Retencion2 > 9)
        )
      BEGIN
        SELECT DISTINCT
          @RetencionConcepto = Retencion2
        FROM Concepto WITH (NOLOCK)
        WHERE Modulo = 'GAS'
        AND Retencion2 > 9
        UPDATE MovImpuesto WITH (ROWLOCK)
        SET Retencion2 = @RetencionConcepto /*10.67*/
        WHERE Modulo = 'GAS'
        AND ModuloID = @ID
        AND Retencion2 > 9
        UPDATE MovImpuesto WITH (ROWLOCK)
        SET Retencion2 = @RetencionConcepto /*10.67*/
        WHERE Modulo = 'CXP'
        AND ModuloID = @OrigenID
        AND Retencion2 > 9
      END
    END
  -- termina validacion calculo retenciones    

  END




  -- MODULO EMBARQUES    


  IF @Accion = 'AFECTAR'
    AND @Modulo = 'EMB'
  BEGIN /* --ARC 28-Feb-09 adaptaci¢n para desarrollo de comisiones choferes*/
    SELECT
      @Mov = Mov,
      @Estatus = Estatus
    FROM Embarque WITH (NOLOCK)
    WHERE ID = @ID
    IF @Mov = 'Embarque'
      AND @Estatus = 'CONCLUIDO'
      UPDATE EmbarqueD WITH (ROWLOCK)
      SET ParaComisionChoferMAVI = 1
      WHERE Estado = 'Entregado'
      AND ID = @ID
  END


  -- MODULO DE ACTIVOS FIJOS    

  IF @Accion = 'AFECTAR'
    AND @Modulo = 'AF'
  BEGIN
    SELECT
      @Mov = Mov,
      @Personal = Personal
    FROM ActivoFijo WITH (NOLOCK)
    WHERE Id = @Id

    IF @Mov = 'Asignacion'
    BEGIN

      UPDATE Personal WITH (ROWLOCK)
      SET AFComer = 1
      WHERE Personal = @Personal
    END
    IF @Mov = 'Devolucion'
    BEGIN
      UPDATE Personal WITH (ROWLOCK)
      SET AFComer = 0
      WHERE Personal = @Personal
    END
  END


  -- FIN MODULO DE ACTIVOS FIJOS    



  -- MODULO TESORERIA    
  IF @Modulo = 'DIN'
  BEGIN
    SELECT
      @Mov = Mov,
      @DinMovId = MovID,
      @Estatus = Estatus,
      @Origen = Origen,
      @CtaDineroDin = CtaDinero,
      @CtaDineroDesDin = CtaDineroDestino
    FROM Dinero WITH (NOLOCK)
    WHERE ID = @ID
    IF @Mov = 'Ingreso'
      AND @Estatus = 'CONCLUIDO'
    BEGIN
      INSERT INTO MovFlujo (Sucursal,
      Empresa,
      OModulo,
      OID,
      OMov,
      OMovID,
      DModulo,
      DID,
      DMov,
      DMovID,
      Cancelado)
        SELECT
          c.Sucursal,
          'MAVI',
          'CXC',
          c.ID,
          c.Mov,
          c.MovID,
          'DIN',
          a.ID,
          a.Mov,
          a.MovID,
          0
        FROM Dinero a WITH (NOLOCK),
             Venta b WITH (NOLOCK),
             Cxc c WITH (NOLOCK)
        WHERE a.ID = @ID
        AND a.Id = b.IDIngresoMAVI
        AND b.Mov = c.Origen
        AND b.MovID = C.OrigenID
      IF @Origen IS NULL
      BEGIN
        UPDATE Dinero WITH (ROWLOCK)
        SET Dinero.OrigenTipo = 'CXC',
            Dinero.Origen = MovFlujo.OMov,
            Dinero.OrigenID = MovFlujo.OMovID
        FROM MovFlujo WITH (NOLOCK)
        WHERE Dinero.Mov = 'Ingreso'
        AND MovFlujo.DModulo = 'DIN'
        AND Dinero.ID = MovFlujo.DID
        AND Dinero.Mov = MovFlujo.DMov
        AND Dinero.MovID = MovFlujo.DMovID
        AND Dinero.ID = @ID
      END
    END

    -- Para conocer el estatus de las Cajas    
    -- Concluidos          
    IF @Estatus = 'CONCLUIDO'
    BEGIN
      IF @Mov = 'Apertura Caja'
      BEGIN
        UPDATE CtaDinero WITH (ROWLOCK)
        SET Estado = 1
        WHERE CtaDinero = @CtaDineroDesDin
      END
      IF @Mov = 'Corte Caja'
      BEGIN
        UPDATE CtaDinero WITH (ROWLOCK)
        SET Estado = 0
        WHERE CtaDinero = @CtaDineroDin
      END
    END
    -- Cancelados    
    IF @Estatus = 'CANCELADO'
    BEGIN
      IF @Mov = 'Apertura Caja'
      BEGIN
        UPDATE CtaDinero WITH (ROWLOCK)
        SET Estado = 0
        WHERE CtaDinero = @CtaDineroDesDin
      END
      IF @Mov = 'Corte Caja'
      BEGIN
        UPDATE CtaDinero WITH (ROWLOCK)
        SET Estado = 1
        WHERE CtaDinero = @CtaDineroDin
      END
    END


  END
  -- FIN MODULO TESORERIA    
  -- YRG 05.02.2010    
  IF @Modulo = 'CXC'
    AND dbo.fnClaveAfectacionMAVI(@Mov, 'CXC') IN ('CXC.C')
    AND @Estatus = 'Cancelado'
  --@MovTipo = 'CXC.C' AND @EstatusNuevo = 'CANCELADO'      
  BEGIN
    DECLARE C2 CURSOR FAST_FORWARD FOR
    SELECT
      Aplica,
      AplicaID--, Importe --, Renglon --, MovMoratorioMAVI, MovIDMoratorioMAVI, TotalInteresMoratorioMAVI       
    FROM CxcD WITH (NOLOCK)
    WHERE ID = @ID
    AND Aplica IN ('Nota Cargo', 'Nota Cargo VIU', 'Nota Cargo Mayoreo') -- AND Concepto =     
    OPEN C2
    FETCH NEXT FROM C2 INTO @Aplica, @AplicaID--, @Importe--, @Renglon --, @MovMoratorioMAVI, @MovIDMoratorioMAVI, @TotalInteresMoratorio      
    WHILE @@Fetch_Status = 0
    BEGIN -- 14        
      --SELECT @ImporteInteres = 0.0, @InteresesMoratorios = 0.0      

      SELECT
        @IDNCMor = ID
      FROM CXC WITH (NOLOCK)
      WHERE Mov = @Aplica
      AND MovId = @AplicaID
      DECLARE crCancelNC CURSOR FAST_FORWARD FOR
      --      SELECT Mov, MovId/*, ImporteACondonar*/ FROM NegociaMoratoriosMAVI      -- SELECT * FROM NegociaMoratoriosMAVI          
      SELECT
        Origen,
        OrigenId/*, ImporteACondonar*/ ---pzamudio 29julio10    
      FROM NegociaMoratoriosMAVI WITH (NOLOCK)     -- SELECT * FROM NegociaMoratoriosMAVI          
      WHERE IDCobro = @ID
      AND NotaCargoMorId = @IDNCMor
      GROUP BY Origen,
               OrigenId
      OPEN crCancelNC
      FETCH NEXT FROM crCancelNC INTO @MovMor, @MovMorID--, @ImporteACondonar       
      WHILE @@Fetch_Status = 0
      BEGIN -- 16         
        -- sig linea 05.02.2010 yrg    
        EXEC spAfectar 'CXC',
                       @IDNCMor,
                       'CANCELAR',
                       'Todo',
                       NULL,
                       @Usuario,
                       NULL,
                       0,
                       @Ok OUTPUT,
                       @OkRef OUTPUT,
                       NULL,
                       @Conexion = 0

        FETCH NEXT FROM crCancelNC INTO @MovMor, @MovMorID--, @ImporteACondonar       
      END  -- 16    
      CLOSE crCancelNC
      DEALLOCATE crCancelNC
      --END -- 14    
      FETCH NEXT FROM C2 INTO @Aplica, @AplicaID--, @Importe--, @Renglon --, @MovMoratorioMAVI, @MovIDMoratorioMAVI, @TotalInteresMoratorio      
    END  --        
    CLOSE C2
    DEALLOCATE C2
  END

  IF DB_NAME() != 'MaviCob'
  BEGIN
    IF @Modulo = 'CXC'
      AND ISNULL(@Accion, '') IN ('CANCELAR', 'AFECTAR')
      AND ISNULL(@Ok, 0) = 0
      AND EXISTS (SELECT
        ID
      FROM CXC WITH (NOLOCK)
      WHERE ID = @ID
      AND Mov IN (SELECT DISTINCT
        MovCargo
      FROM TcIDM0224_ConfigNotasEspejo WITH (NOLOCK)
      UNION ALL
      SELECT DISTINCT
        MovCredito
      FROM TcIDM0224_ConfigNotasEspejo WITH (NOLOCK))
      AND ISNULL(Concepto, '') IN (SELECT DISTINCT
        ConceptoCargo
      FROM TcIDM0224_ConfigNotasEspejo WITH (NOLOCK)
      UNION ALL
      SELECT DISTINCT
        ConceptoCredito
      FROM TcIDM0224_ConfigNotasEspejo WITH (NOLOCK))
      AND Estatus NOT IN ('CANCELADO', 'SINAFECTAR'))
    BEGIN
      EXEC dbo.SP_MAVIDM0224NotaCreditoEspejo @ID,
                                              @Accion,
                                              @Usuario,
                                              @Ok OUTPUT,
                                              @OkRef OUTPUT,
                                              'DESPUES'
    END


    -- jacm 2017may12 ----------------------------------------------------------------------------------------------      
    --    inicia MODIFICACION MONEDERO para detectar si se liquidan Facturas de Contado y pagar puntos generados

    IF @Modulo = 'CXC'
      AND @Accion = 'AFECTAR'
      AND @Estatus = 'CONCLUIDO'
    BEGIN -- afectar, cxc
      -- si tiene cxcd
      --  traer cxcd aplica
      -- si cxc=aplica,aplicaid y mov = 'factura','factura viu', saldo = null, condicion = contado, estatus = 'concluido'
      --   traer cxc segun aplica,aplicaid
      -- buscar en politicasmonederoaplicadasmavi 
      -- si pendiente->> aplicar puntos

      --  movimiento cxc  que llega
      --if @ok is not null
      --select  'xpDespuesAfectar,cxc,afectar: ok= ' + convert(varchar,isnull(@Ok,0))

      SELECT
        @Mov = Mov,
        @MovID = MovID,
        @Estatus = Estatus,
        @concepto = Concepto
      FROM CxC WITH (NOLOCK)
      WHERE ID = @ID
      -- ver si existe a quien aplica el movimiento cxc 
      IF EXISTS (SELECT
          Aplica,
          AplicaId
        FROM CXCD WITH (NOLOCK)
        WHERE ID = @ID)
      BEGIN
        SELECT
          @Aplica = Aplica,
          @Aplicaid = AplicaId
        FROM CXCD WITH (NOLOCK)
        WHERE ID = @ID

        -- ver si es factura a la que se paga, y este concluida, sin saldo y sea de contado 
        IF EXISTS (SELECT
            Id
          FROM CxC WITH (NOLOCK)
          JOIN CONDICION CO WITH (NOLOCK)
            ON cxc.condicion = co.condicion
          WHERE MOV = @Aplica
          AND MOVID = @Aplicaid
          --and Mov in ('Factura','Factura VIU')
          AND dbo.fnClaveAfectacionMavi(Mov, 'VTAS') = 'VTAS.F'
          AND Estatus = 'CONCLUIDO'
          AND Saldo = NULL
          AND co.tipocondicion = 'CONTADO'
          AND co.grupo = 'MENUDEO')
        BEGIN
          SELECT
            @OrigenID = v.Id,
            @MovF = cc.Mov,
            @MovIDF = cc.MovID,
            @Empresa = v.Empresa,
            @Sucursal = v.Sucursal
          FROM Venta v WITH (NOLOCK)
          JOIN CXC cc WITH (NOLOCK)
            ON v.mov = cc.mov
            AND v.movid = cc.movid
          WHERE cc.MOV = @Aplica
          AND cc.MOVID = @Aplicaid

          -- buscar si tiene puntos generados pendientes de aplicar
          IF EXISTS (SELECT
              *
            FROM PoliticasMonederoAplicadasMavi WITH (NOLOCK)
            WHERE Modulo = 'VTAS'
            AND ID = @OrigenID
            AND cveEstatus = 'P') -- PUNTOS GENERADOS          
          BEGIN
            --if @ok is not null
            --select  'xpDespuesAfectar,antes xpMovEstatusCxc: ok= ' + convert(varchar,isnull(@Ok,0))

            -- desde modulo 'cxc' para cargar puntos generados pendientes
            EXEC xpMovEstatusCxC @Empresa,
                                 @Sucursal,
                                 @Modulo,
                                 @OrigenID,
                                 @Estatus,
                                 @Estatus,
                                 @Usuario,
                                 @FechaEmision,
                                 @FechaRegistro,
                                 @MovF,
                                 @MovIDF,
                                 'VTAS.F',
                                 @Ok OUTPUT,
                                 @OkRef OUTPUT
          END  -- si tiene puntos generados pendientes
        END  -- si es factura contado pagada
      END  --si tiene cxcd

    END    -- afectar, cxc


    IF @Modulo = 'CXC'
      AND @Accion = 'CANCELAR'
      AND @Estatus = 'CANCELADO'
    BEGIN -- afectar, cxc
      -- si tiene cxcd
      --  traer cxcd aplica
      -- si cxc=aplica,aplicaid y mov = 'factura','factura viu', tiene saldo, condicion = contado, estatus no 'concluido'
      --   traer cxc segun aplica,aplicaid
      -- buscar en politicasmonederoaplicadasmavi con cveestatus = 'A'
      -- si pendiente->> aplicar puntos

      --if @ok is not null
      --select  'xpDespuesAfectar,cxc,afectar: ok= ' + convert(varchar,isnull(@Ok,0))


      --  movimiento cxc  que llega
      SELECT
        @Mov = Mov,
        @MovID = MovID,
        @Estatus = Estatus,
        @concepto = Concepto
      FROM CxC WITH (NOLOCK)
      WHERE ID = @ID
      -- ver si existe a quien aplica el movimiento cxc 
      IF EXISTS (SELECT
          Aplica,
          AplicaId
        FROM CXCD WITH (NOLOCK)
        WHERE ID = @ID)
      BEGIN
        SELECT
          @Aplica = Aplica,
          @Aplicaid = AplicaId
        FROM CXCD WITH (NOLOCK)
        WHERE ID = @ID

        -- ver si es factura a la que se paga, y ya no este concluida, con saldo y sea de contado 
        IF EXISTS (SELECT
            Id
          FROM CxC WITH (NOLOCK)
          JOIN CONDICION CO WITH (NOLOCK)
            ON cxc.condicion = co.condicion
          WHERE MOV = @Aplica
          AND MOVID = @Aplicaid
          --and Mov in ('Factura','Factura VIU')
          AND dbo.fnClaveAfectacionMavi(Mov, 'VTAS') = 'VTAS.F'
          AND Estatus <> 'CONCLUIDO'
          AND ISNULL(Saldo, 0) > 0
          AND co.tipocondicion = 'CONTADO'
          AND co.grupo = 'MENUDEO')
        BEGIN
          SELECT
            @OrigenID = v.Id,
            @MovF = cc.Mov,
            @MovIDF = cc.MovID,
            @Empresa = v.Empresa,
            @Sucursal = v.Sucursal
          FROM Venta v WITH (NOLOCK)
          JOIN CXC cc WITH (NOLOCK)
            ON v.mov = cc.mov
            AND v.movid = cc.movid
          WHERE cc.MOV = @Aplica
          AND cc.MOVID = @Aplicaid

          -- buscar si tiene puntos generados pendientes de aplicar y ya se aplicaron
          IF EXISTS (SELECT
              *
            FROM PoliticasMonederoAplicadasMavi WITH (NOLOCK)
            WHERE Modulo = 'VTAS'
            AND ID = @OrigenID
            AND ISNULL(cveEstatus, '') = 'A') -- PUNTOS GENERADOS          
          BEGIN
            -- desde modulo 'cxc' para cargar puntos generados pendientes
            EXEC xpMovEstatusCxC @Empresa,
                                 @Sucursal,
                                 @Modulo,
                                 @OrigenID,
                                 @Estatus,
                                 @Estatus,
                                 @Usuario,
                                 @FechaEmision,
                                 @FechaRegistro,
                                 @MovF,
                                 @MovIDF,
                                 'VTAS.F',
                                 @Ok OUTPUT,
                                 @OkRef OUTPUT
          END  -- si tiene puntos generados pendientes
        END
      END  --si tiene cxcd

    END    -- cancelar, cxc




  END -- Fin de la  condicion base diferente a Mavicob



  IF @Modulo = 'CXP' --GUARDA EL MOVIMIENTO 'Acuerdo Proveedor' EN LA TABLA MOVFLUJO
  BEGIN
    SELECT
      @Mov = Mov,
      @Estatus = Estatus
    FROM Cxp WITH (NOLOCK)
    WHERE ID = @ID
    IF @Mov = 'Acuerdo Proveedor'
      AND @Estatus = 'PENDIENTE'
      EXEC SP_DM0310MovFlujoAcuerdoProveedores @ID
  END

  IF @Modulo = 'CXP'
    AND @Accion = 'Cancelar'
  BEGIN
    SELECT
      @Mov = Mov,
      @Estatus = Estatus,
      @Origen = Origen,
      @OrigenIdPed = Origenid
    FROM Cxp WITH (NOLOCK)
    WHERE ID = @ID
    IF @Mov = 'Acuerdo Proveedor'
      AND @Estatus = 'CANCELADO'
      UPDATE Cxp WITH (ROWLOCK)
      SET Situacion = 'Por Generar Acuerdo'
      WHERE Mov = @origen
      AND MovID = @OrigenIDPed
  END

  /*Flujo para ligar una Factura con un ReporteServicio*/
  IF @Accion = 'Afectar'
    AND @Mov IN ('Factura', 'Factura VIU')
  BEGIN
    SELECT
      @IdSoporte = ReporteServicio
    FROM Venta WITH (NOLOCK)
    WHERE ID = @ID
    IF @IdSoporte IS NOT NULL
    BEGIN

      UPDATE s WITH (ROWLOCK)
      SET ControlRepServ = 1
      FROM Soporte s
      WHERE s.ID = @IdSoporte
    END
  END


  IF @Accion = 'Afectar'
    AND @Mov IN ('Factura', 'Factura VIU')
  BEGIN
    SELECT
      @IdSoporte = ReporteServicio
    FROM Venta WITH (NOLOCK)
    WHERE ID = @ID
    IF @IdSoporte IS NOT NULL
    BEGIN

      UPDATE s WITH (ROWLOCK)
      SET ControlRepServ = 1
      FROM Soporte s
      WHERE s.ID = @IdSoporte
    END
  END

  RETURN

END
GO
