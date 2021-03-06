SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

-- =======================================================================================================================================    
-- NOMBRE   : xpAntesAfectar  
-- AUTOR   :   
-- FECHA CREACION :  
-- DESARROLLO  :   
-- MODULO   :   
-- DESCRIPCION  :   
--   
-- ========================================================================================================================================    
-- ========================================================================================================================================    
-- FECHA Y ULTIMA MODIFICACION:   13/09/2014      Por: Jesus del Toro Andrade
-- Modificación para Nota Cargo, Nota Credito por concepto de localizacion y adjudicacion  
-- ========================================================================================================================================    
-- ========================================================================================================================================    
-- FECHA Y ULTIMA MODIFICACION:    20/08/2014      Por: Marco Maldovinos  
-- Se condiciona para que no permita eliminar ctas incobrables o Notas de credito aplicadas a ctas incobrables cuando estas  ya se enviaron a Mavicob.
-- para el desarrollo dM0208
-- ========================================================================================================================================  
-- ========================================================================================================================================    
-- FECHA Y ULTIMA MODIFICACION:    22/08/2016      Por: Moises Adrian Hernandez Cajero  
-- Se condiciona para poder realizar devoluciones parciales segun la tabla de configuracion proporcionada
-- Se integran los with(nolock)
-- ========================================================================================================================================    
-- ========================================================================================================================================    
-- FECHA Y ULTIMA MODIFICACION:    19/10/2016      Por: Victor Alain Sanabria Castañon 
-- Se modificaron las condiciones de error "20305" para poder modificar el precio de los articulos Q (Desarrollo DM0292 Articulos Q Calzado)
-- ========================================================================================================================================
-- ========================================================================================================================================    
-- FECHA Y ULTIMA MODIFICACION:    14/10/2017      Por: Carlos Alberto Diaz Jimenez
-- En donde se llama el SP SP_MAVIDM0224NotaCreditoEspejo se cambiaron valores quemados por los definidos en 
-- la tabla de configuracion TcIDM0224_ConfigNotasEspejo
-- ========================================================================================================================================  
-- FECHA Y ULTIMA MODIFICACION:    04/07/2018      Por: Perez Orozco Erika Jeanette
-- Se agrego validacion para que cuando el movimiento provenga de una sucursal de linia no me valide el precio.
-- ========================================================================================================================================  

CREATE PROC [dbo].[xpAntesAfectar] @Modulo char(5),
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
          @Estatus varchar(20),
          @MovTipo varchar(20),
          @Situacion varchar(50),
          @Proveedor varchar(20),
          @Encontrado int,
          @Diferente int,
          @NumReg int,
          @Comentarios varchar(255),
          @Cliente varchar(15),
          @Empresa char(5),
          @Cantidad int,
          @RenglonID varchar(3),
          @Articulo varchar(20),
          @reg int,
          @Error int,
          @ProvTipo varchar(30),
          @Concepto varchar(50),
          @TipoCte varchar(15), -- Variable agragada para validar el tipo de cliente 30-Sep-08 (Arly Rubio Camacho)          
          @PrefijoCte varchar(2), -- Variable agragada para validar el tipo de cliente 30-Sep-08 (Arly Rubio Camacho)          
          @NuloCopia bit,
          @GpoTrabajo varchar(50),
          @Condicion varchar(50),
          @Condicion2 varchar(50),
          @CteEnviarA int,
          @ImporteTotal money,
          @DineroID int,
          @Origen varchar(20),
          @OrigenID varchar(20),
          @Clave varchar(20),
          @IDOrigen int,
          @Costo money,
          @CostoAnt money,
          @Almacen varchar(10),
          @Mensaje varchar(100),
          @IVA float,
          @IVAFiscal float,
          @Financiamiento money,
          @Capital float,
          @Renglon float,
          @SaldoTotal money,
          @Agente varchar(10), --ARC CM 18-May-09          
          @NivelCobranza varchar(100), --ARC CM 18-May-09          
          @ImporteARefinanciar money,
          @CondRef varchar(50),
          @AplicaManual bit,  --JGD          
          @Aplica varchar(20),--JGD          
          @AplicaID varchar(20),--JGD          
          @Vencimiento datetime, --JGD          
          @AplicaManualCxc bit, -- YRG 290509          
          @OrigenCob varchar(20), -- YRG 290509          
          @CCategoria int,
          @Personal varchar(10),
          @Estado bit,
          @PadreMavi varchar(20), ---pz  20100416         
          @PadreMaviID varchar(20), ---pz  20100416         
          @cont int, ---pz  20100416         
          @contfinal int, ---pz  20100416         
          @idAux int, ---pz  20100416           
          @RFCCompleto int,  -- JRD          
          @DevOrigen int, -- BVF 20100505        
          @FacDesgloseIVA bit, --BVF 20100505        
          @ArtP varchar(20),
          @Precio money,
          @PrecioArt money,
          @PrecioAnterior money,
          @Agente2 varchar(20),
          @Licencia varchar(20),
          @Licencia2 varchar(20),
          @Ruta varchar(50),
          @EstatusSol varchar(20),
          @MovIDSol varchar(20),
          @MovSol varchar(20),
          @FechaEmision datetime,
          @FechaActual datetime,
          @TipoCobro int,
          @FechaCobroAntxpol datetime,
          @Directo bit,
          @ConDesglose bit,
          @AlmacenOrigen varchar(15),
          @AlmacenDestino varchar(15),
          @AlmacenOrigenTipo varchar(15),
          @AlmacenDestinoTipo varchar(15),
          @Redime bit,
          @bloq varchar(15),
          @suc int

  SET @suc = (SELECT TOP 1
    Sucursal
  FROM venta WITH (NOLOCK)
  WHERE id = @ID)

  SET @FechaActual = GETDATE()
  SET @FechaActual = CONVERT(varchar(8), @FechaActual, 112)

  IF EXISTS (SELECT
      *
    FROM TEMPDB.SYS.SYSOBJECTS
    WHERE ID = OBJECT_ID('Tempdb.dbo.#ValidaConceptoGas')
    AND TYPE = 'U')
    DROP TABLE #ValidaConceptoGas

  IF EXISTS (SELECT
      *
    FROM TEMPDB.SYS.SYSOBJECTS
    WHERE ID = OBJECT_ID('Tempdb.dbo.#cobro')
    AND TYPE = 'U')
    DROP TABLE #cobro

  IF EXISTS (SELECT
      *
    FROM TEMPDB.SYS.SYSOBJECTS
    WHERE ID = OBJECT_ID('Tempdb.dbo.#cobroAplica')
    AND TYPE = 'U')
    DROP TABLE #cobroAplica

  IF EXISTS (SELECT
      *
    FROM TEMPDB.SYS.SYSOBJECTS
    WHERE ID = OBJECT_ID('Tempdb.dbo.#temp2')
    AND TYPE = 'U')
    DROP TABLE #temp2

  --@Cliente varchar(10)        

  SELECT
    @Mov = NULL
  SELECT
    @MovTipo = NULL
  SELECT
    @Cliente = NULL
  SELECT
    @TipoCte = NULL
  SELECT
    @PrefijoCte = NULL
  SELECT
    @NuloCopia = 0
  SET @DineroID = NULL

  -- Inicia Validacion de Existencias        
  IF @Modulo = 'VTAS'
  BEGIN
    SELECT
      @Mov = Mov,
      @Estatus = Estatus
    FROM Venta WITH (NOLOCK)
    WHERE ID = @ID
    IF @Mov IN ('Factura', 'Factura Mayoreo', 'Factura VIU')
      AND @Estatus <> 'CONCLUIDO'
      AND @Accion <> 'CANCELAR'
    BEGIN
      IF dbo.fn_ValidarExistenciaInv(@ID) IN (2)
        SELECT
          @Ok = 20020
    END
  END
  --Termina Validacion de Existencias         

  ----Inicia Validacion de Accesos Especificos      

  IF @Modulo = 'COMS'
    AND @Accion IN ('AFECTAR', 'VERIFICAR')
  BEGIN
    --- agregado 14-Abr-10 jrd        
    EXEC spValidaNivelAccesoAgente @ID,
                                   'COMS',
                                   @Ok OUTPUT,
                                   @OkRef OUTPUT
  END

  IF @Modulo = 'CXC'
    AND @Accion IN ('AFECTAR', 'VERIFICAR')
  BEGIN
    --- agregado 14-Abr-10 jrd        
    EXEC spValidaNivelAccesoAgente @ID,
                                   'CXC',
                                   @Ok OUTPUT,
                                   @OkRef OUTPUT
  END

  IF @Modulo = 'CXP'
    AND @Accion IN ('AFECTAR', 'VERIFICAR')
  BEGIN
    --- agregado 14-Abr-10 jrd        
    EXEC spValidaNivelAccesoAgente @ID,
                                   'CXP',
                                   @Ok OUTPUT,
                                   @OkRef OUTPUT
  END

  IF @Modulo = 'VTAS'
    AND @Accion IN ('AFECTAR', 'VERIFICAR')
  BEGIN
    --- agregado 14-Abr-10 jrd        
    EXEC spValidaNivelAccesoAgente @ID,
                                   'VTAS',
                                   @Ok OUTPUT,
                                   @OkRef OUTPUT
  END

  IF @Modulo = 'DIN'
    AND @Accion IN ('AFECTAR', 'VERIFICAR')
  BEGIN
    --- agregado 14-Abr-10 jrd        
    EXEC spValidaNivelAccesoAgente @ID,
                                   'DIN',
                                   @Ok OUTPUT,
                                   @OkRef OUTPUT
  END


  IF @Modulo = 'INV'
    AND @Accion IN ('AFECTAR', 'VERIFICAR')
  BEGIN
    --- agregado 14-Abr-10 jrd        
    EXEC spValidaNivelAccesoAgente @ID,
                                   'INV',
                                   @Ok OUTPUT,
                                   @OkRef OUTPUT

    -- integracion para punto 24 09-03-2011. Evita generar movid antes de generar error. JR 16-Mar-2011      
    SELECT
      @Mov = Mov
    FROM Inv WITH (NOLOCK)
    WHERE ID = @ID
    IF (@Mov = 'Recibo Traspaso')
      EXEC spValidaSerieDevuelta @ID,
                                 @Ok OUTPUT,
                                 @OkRef OUTPUT

    --Inicia Validacion tipos de Almacenes    
    SELECT
      @AlmacenOrigen = Almacen,
      @AlmacenDestino = AlmacenDestino
    FROM INV WITH (NOLOCK)
    WHERE ID = @ID
    IF (@AlmacenOrigen IS NOT NULL)
      AND (@AlmacenDestino IS NOT NULL)
    BEGIN
      SELECT
        @AlmacenOrigenTipo = Tipo
      FROM Alm WITH (NOLOCK)
      WHERE Almacen = @AlmacenOrigen
      SELECT
        @AlmacenDestinoTipo = Tipo
      FROM Alm WITH (NOLOCK)
      WHERE Almacen = @AlmacenDestino
      IF @AlmacenOrigenTipo <> @AlmacenDestinoTipo
        SELECT
          @OK = 20120
    END
  --Termina Validacion tipos de Almacenes        
  END


  IF @Modulo = 'ST'
    AND @Accion IN ('AFECTAR', 'VERIFICAR')
  BEGIN
    --- agregado 14-Abr-10 jrd        
    EXEC spValidaNivelAccesoAgente @ID,
                                   'ST',
                                   @Ok OUTPUT,
                                   @OkRef OUTPUT
  END


  IF @Modulo = 'AGENT'
    AND @Accion IN ('AFECTAR', 'VERIFICAR')
  BEGIN
    --- agregado 14-Abr-10 jrd        
    EXEC spValidaNivelAccesoAgente @ID,
                                   'AGENT',
                                   @Ok OUTPUT,
                                   @OkRef OUTPUT
  END


  IF @Modulo = 'EMB'
    AND @Accion IN ('AFECTAR', 'VERIFICAR')
  BEGIN
    --- agregado 14-Abr-10 jrd        
    EXEC spValidaNivelAccesoAgente @ID,
                                   'EMB',
                                   @Ok OUTPUT,
                                   @OkRef OUTPUT
  END
  ----Termina Validacion de Accesos Especificos         

  --- Validacion de Situaciones en el Modulo de CXP ---          

  IF @Modulo = 'CXP'
    AND @Accion = 'AFECTAR'
  BEGIN
    SELECT
      @Estatus = Estatus,
      @Mov = Mov,
      @Situacion = Situacion
    FROM CXP WITH (NOLOCK)
    WHERE ID = @ID
    IF @Estatus = 'SINAFECTAR'
      AND @Mov IN ('Aplicacion', 'Canc Acuerdo Espejo')
      AND @Situacion IS NULL
    BEGIN
      SELECT
        @Ok = 99990
    END

  END

  IF @Modulo = 'DIN'
    AND @Accion <> 'CANCELAR'
  BEGIN
    SELECT
      @Mov = Mov,
      @Directo = Directo,
      @ConDesglose = ConDesglose
    FROM Dinero WITH (NOLOCK)
    WHERE ID = @ID
    SELECT
      @Clave = Clave
    FROM Movtipo WITH (NOLOCK)
    WHERE Mov = @Mov

    IF @Clave = 'DIN.TC'
      AND @ConDesglose = 0
      AND @Directo = 1
      DELETE DineroD
      WHERE ID = @ID

  END

  IF @Modulo = 'DIN'
    AND @Accion = ('AFECTAR')
  BEGIN
    SELECT
      @Mov = Mov,
      @ImporteTotal = Importe
    FROM Dinero WITH (NOLOCK)
    WHERE ID = @ID
    SELECT
      @Clave = Clave
    FROM Movtipo WITH (NOLOCK)
    WHERE Mov = @Mov
    AND Modulo = @Modulo

    /* validacion para evitar que la apertura de caja tenga importe. JRD 15-Abr-2013. */
    IF (@Clave = 'DIN.A')
    BEGIN
      IF (@ImporteTotal > 0)
        UPDATE Dinero
        SET Importe = 0.0
        WHERE ID = @ID
    END

  END


  --- Validacion de Situaciones en el Modulo de Inventarios ---          

  IF @Modulo = 'INV'
    AND @Accion = 'AFECTAR'
  BEGIN
    SELECT
      @Estatus = Estatus,
      @Mov = Mov,
      @Situacion = Situacion
    FROM INV WITH (NOLOCK)
    WHERE ID = @ID
    SELECT
      @MovTipo = Clave
    FROM MovTipo WITH (NOLOCK)
    WHERE Mov = @Mov
    AND Modulo = @Modulo
    IF @Estatus = 'SINAFECTAR'
      AND @Mov IN ('Devolucion Transito', 'Ajuste')
      AND @Situacion IS NULL
    BEGIN
      SELECT
        @Ok = 99990
    END
    IF @Estatus = 'SINAFECTAR'
      AND @MovTipo IN ('INV.IF')
      AND @Situacion IS NULL
    BEGIN
      SELECT
        @Ok = 99990
    END
    -- Se limita a que no se permitan realizar movimientos de Ajuste e Inventario fisicos para los articulos tipo Activo Fijos. ALQG 24/11/09          
    IF @MovTipo IN ('INV.A', 'INV.IF')
    BEGIN
      IF EXISTS (SELECT
          *
        FROM Art a WITH (NOLOCK),
             Inv b WITH (NOLOCK),
             InvD c WITH (NOLOCK)
        WHERE b.Id = c.Id
        AND c.Articulo = a.Articulo
        AND b.Id = @Id
        AND a.Categoria IN ('ACTIVOS FIJOS'))
      BEGIN
        SELECT
          @Ok = 100026
      END
    END

  END

  --- Validacion de Situaciones en el Modulo de Gastos ---          

  IF @Modulo = 'GAS'
    AND @Accion = 'AFECTAR'
  BEGIN
    SELECT
      @Estatus = Estatus,
      @Mov = Mov,
      @Situacion = Situacion
    FROM Gasto WITH (NOLOCK)
    WHERE ID = @ID
    SELECT
      @MovTipo = Clave
    FROM MovTipo WITH (NOLOCK)
    WHERE Mov = @Mov
    AND Modulo = @Modulo
    IF @Estatus = 'SINAFECTAR'
      AND @Mov IN ('Comprobante Inst', 'Amortizacion', 'Consumo')
      AND @Situacion IS NULL
    BEGIN
      SELECT
        @Ok = 99990
    END
    IF @Estatus = 'SINAFECTAR'
      AND @Mov IN ('Contrato')
    BEGIN
      --EXEC spSolicitudGastoAFMAVI @ID          
      EXEC spSolGastoContratoAF @ID
    END

    -- Validacion de Conceptos asignados a movimientos de Gastos a traves de configuracion general GRB 30/07/10        
    IF @Estatus = 'SINAFECTAR'
      AND EXISTS (SELECT TOP 1
        Mov
      FROM Empresaconceptovalidar WITH (NOLOCK)
      WHERE Modulo = @Modulo
      AND Mov = @Mov)
    BEGIN
      IF EXISTS (SELECT
          *
        FROM TEMPDB.SYS.SYSOBJECTS
        WHERE ID = OBJECT_ID('Tempdb.dbo.#ValidaConceptoGas')
        AND TYPE = 'U')
        DROP TABLE #ValidaConceptoGas
      SELECT
        G.ID,
        G.Mov,
        G.MovID,
        GasConcepto = D.Concepto,
        ValidaConcepto = C.Concepto INTO #ValidaConceptoGas
      FROM dbo.Gasto G WITH (NOLOCK)
      INNER JOIN dbo.GastoD D WITH (NOLOCK)
        ON G.ID = D.ID
        AND G.ID = @ID
      LEFT JOIN dbo.EmpresaConceptoValidar C WITH (NOLOCK)
        ON C.Mov = G.Mov
        AND C.Empresa = G.Empresa
        AND C.Modulo = @Modulo
        AND C.Concepto = D.Concepto
      GROUP BY G.ID,
               G.Mov,
               G.MovID,
               D.Concepto,
               C.Concepto

      SELECT
        @Concepto = ISNULL(GasConcepto, '')
      FROM #ValidaConceptoGas WITH (NOLOCK)
      WHERE ISNULL(GasConcepto, '') <> ISNULL(ValidaConcepto, '')

      IF EXISTS (SELECT
          GasConcepto
        FROM #ValidaConceptoGas WITH (NOLOCK)
        WHERE GasConcepto = '*')
        SELECT
          @Ok = 20481,
          @OkRef = 'Concepto "*" '

      IF ISNULL(@Concepto, '') <> ''
        SELECT
          @Ok = 20485,
          @OkRef = RTRIM(@Mov) + ' (' + RTRIM(@Concepto) + ')'

      IF EXISTS (SELECT
          *
        FROM TEMPDB.SYS.SYSOBJECTS
        WHERE ID = OBJECT_ID('Tempdb.dbo.#ValidaConceptoGas')
        AND TYPE = 'U')
        DROP TABLE #ValidaConceptoGas
    END
  END


  ---------- MODULO DE COMPRAS -----------          

  --- Validacion de Situaciones en el Modulo de Compras ---          


  IF @Modulo = 'COMS'
    AND @Accion IN ('AFECTAR', 'VERIFICAR')
  BEGIN
    SELECT
      @Estatus = Estatus,
      @Mov = Mov,
      @Situacion = Situacion,
      @Origen = Origen,
      @OrigenId = OrigenID
    FROM COMPRA WITH (NOLOCK)
    WHERE ID = @ID
    SELECT
      @MovTipo = Clave
    FROM MovTipo WITH (NOLOCK)
    WHERE Mov = @Mov
    AND Modulo = @Modulo
    IF @Estatus = 'SINAFECTAR'
      AND @Mov IN ('Compra Consignacion', 'Entrada Compra', 'Entrada con Gastos', 'Remision')
      AND @Situacion IS NULL
    BEGIN
      SELECT
        @Ok = 99990
    END
    IF NOT EXISTS (SELECT
        c.Proveedor,
        d.Articulo
      FROM compra c WITH (NOLOCK)
      INNER JOIN CompraD d WITH (NOLOCK)
        ON d.ID = c.ID
      INNER JOIN DM0289ConfigArticulos ca WITH (NOLOCK)
        ON ca.Articulo = d.Articulo
      INNER JOIN DM0289ConfigProveedores cp WITH (NOLOCK)
        ON cp.Proveedor = c.Proveedor
      INNER JOIN Usuario u WITH (NOLOCK)
        ON u.Usuario = c.Usuario
      INNER JOIN DM0289ConfigGrupoTrabajo gt WITH (NOLOCK)
        ON gt.GrupoTrabajo = u.GrupoTrabajo
      WHERE c.ID = @ID
      AND Mov = 'Devolucion Compra')
    BEGIN
      IF @Mov IN ('Orden Devolucion', 'Devolucion Compra')
      BEGIN
        IF EXISTS (SELECT
            IDCopiaMAVI
          FROM CompraD WITH (NOLOCK)
          WHERE IDCopiaMAVI IS NULL
          AND ID = @ID)
          SELECT
            @NuloCopia = 1
        IF @NuloCopia = 1 --AND @GpoTrabajo not in ('CONTABILIDAD')          
          SELECT
            @Ok = 99992
        ELSE
          EXEC spValidarCantidadDevMAVI @ID,
                                        @Modulo,
                                        @Ok OUTPUT,
                                        @OkRef OUTPUT  -- Validar que no se devuelva mas de lo facturado (ARC 13-Nov-08).          
      END
    END
    --- Validacion de las solicitudes de compra que no vengan del planeador          

    IF @Estatus = 'SINAFECTAR'
      AND @Mov IN ('Solicitud Compra')
    BEGIN
      IF EXISTS (SELECT
          C.Id
        FROM CompraD CD WITH (NOLOCK)
        INNER JOIN Compra C WITH (NOLOCK)
          ON CD.Id = C.ID
        INNER JOIN Art A WITH (NOLOCK)
          ON CD.Articulo = A.Articulo
        WHERE C.Planeador = 0
        AND A.Categoria = 'VENTA'
        AND C.Id = @Id)
        SELECT
          @Ok = 99990
    END

    --- Se valida el precio de la entrada de compra.          

    IF @MovTipo IN ('COMS.F', 'COMS.EI', 'COMS.EG')
    BEGIN   -- 1          
      SELECT
        @Clave = Clave
      FROM MovTipo WITH (NOLOCK)
      WHERE Modulo = 'COMS'
      AND Mov = @Origen --AND @Directo =0          
      IF @Clave = 'COMS.O' -- Solo si viene de una Orden de compra            

      BEGIN   -- 2          
        SELECT
          @IDOrigen = ID
        FROM Compra WITH (NOLOCK)
        WHERE Mov = @Origen
        AND MovID = @OrigenID

        DECLARE CRDetalle CURSOR LOCAL FOR
        SELECT
          Articulo,
          ISNULL(Costo, 0),
          Almacen
        FROM CompraD WITH (NOLOCK)
        WHERE ID = @ID
        OPEN CRDetalle
        FETCH NEXT FROM CRDetalle INTO @Articulo, @Costo, @Almacen
        WHILE @@FETCH_STATUS <> -1

        BEGIN   -- 3          
          IF @@FETCH_STATUS <> -2
          BEGIN   -- 4          
            -- Obtener el costo del mov anterior          
            SELECT
              @CostoAnt = ISNULL(Costo, 0)
            FROM CompraD WITH (NOLOCK)
            WHERE ID = @IDOrigen
            AND Articulo = @Articulo ---AND Almacen = @Almacen             
            IF @Costo > @CostoAnt
            BEGIN  -- 5          
              SET @Ok = 80110---20610          
              SET @OkRef = 'Movimiento bloqueado: El costo excede al m ximo indicado en la orden de Compra. Art¡culo:  ' + CAST(@Articulo AS varchar(50)) + ' Costo: $' + CAST(@Costo AS varchar(15))
            END    -- 5          
          END  -- 4          
          FETCH NEXT FROM CRDetalle INTO @Articulo, @Costo, @Almacen
        END  -- 3          

        CLOSE CRDetalle
        DEALLOCATE CRDetalle
      END -- 2          
    END  -- 1          

  END

  ---------- MODULO DE CUENTAS POR COBRAR -----------          

  --- Validacion de Situaciones en el CXC ---          
  IF @Modulo = 'CXC'
    AND @Accion IN ('AFECTAR', 'VERIFICAR')
  BEGIN
    SELECT
      @AplicaManual = AplicaManual,
      @Estatus = Estatus,
      @Mov = Mov,
      @Situacion = Situacion,
      @Origen = Origen,
      @OrigenID = OrigenID,
      @Concepto = Concepto
    FROM CXC WITH (NOLOCK)
    WHERE ID = @ID
    SELECT
      @AplicaManualCxc = AplicacionManualCxcMAVI
    FROM UsuarioCfg2 WITH (NOLOCK)
    WHERE Usuario = @Usuario
    SELECT
      @MovTipo = Clave
    FROM MovTipo WITH (NOLOCK)
    WHERE Mov = @Mov
    AND Modulo = @Modulo

    IF (@AplicaManual = 0
      AND EXISTS (SELECT
        ID
      FROM CxcD WITH (NOLOCK)
      WHERE ID = @ID)
      AND @Mov <> 'Sol Refinanciamiento')
      DELETE FROM CxcD
      WHERE ID = @ID

    /*Se anexaron las siguentes lineas para validacion en la factura electronica BVF 05-May-10*/
    IF @Mov IN ('Nota Cargo')
      EXEC spValidarMayor12meses @ID,
                                 @Mov,
                                 'CXC'


    /*IF NOT EXISTS(SELECT * FROM CxcD WHERE ID = @ID) AND @MovTipo = 'CXC.C' AND (@AplicaManualCxc = 0 OR @AplicaManualCxc is null)        
    BEGIN                             
    SET @Ok=100029  -- 21        
    SET @OkRef= 'Debera utilizar la herramienta de Sugerir Cobro 1'          
              
    END     */
    IF NOT EXISTS (SELECT
        COUNT(*)
      FROM NegociaMoratoriosMAVI WITH (NOLOCK)
      WHERE IDCobro = @ID)
      AND @Origen IS NULL
      AND (@AplicaManualCxc = 0
      OR @AplicaManualCxc IS NULL)
      AND @MovTipo = 'CXC.C'
    BEGIN
      --select 'Entra 1'          
      SET @Ok = 100029  -- 22          
    --SET @OkRef= 'Debera utilizar la herramienta de Sugerir Cobro 1'                    
    END
    ELSE
    -- Caso sin uso de la herramienta y sin permisos,generando cobro directo               
    IF /*NOT EXISTS(SELECT COUNT(*) FROM NegociaMoratoriosMAVI WHERE IDCobro = @ID) AND */ (@AplicaManualCxc = 0
      OR @AplicaManualCxc IS NULL)
      AND @MovTipo = 'CXC.C'
      AND @Origen IS NOT NULL
    BEGIN
      --select 'entra 2'               
      SET @Ok = 100022  -- 22          
    -- SET @OkRef= RTRIM(@Mov)+' '+RTRIM(@MovId) --'Debera utilizar la herramienta de Sugerir Cobro 2'                    
    END
    ELSE
    IF @Origen IS NULL
      AND (@AplicaManualCxc = 0
      OR @AplicaManualCxc IS NULL)
      AND @MovTipo = 'CXC.C'
      AND (SELECT
        COUNT(*)
      FROM NegociaMoratoriosMAVI WITH (NOLOCK)
      WHERE IDCobro = @ID)
      = 0
    BEGIN
      --select 'Entra 3'        
      SET @Ok = 100029  -- 22          
    -- SET @OkRef= 'Debera utilizar la herramienta de Sugerir Cobro 3'                    
    END

    -- Inicia Cobro por Politica      
    IF @MovTipo = 'CXC.C'
    BEGIN
      SELECT
        @TipoCobro = TipoCobro
      FROM TipoCobroMAVI WITH (NOLOCK)
      WHERE IdCobro = @ID
      IF @TipoCobro = 0 -- Cobro x Normal      
      BEGIN
        -- Se verifica q no exista un cobro x politica para cada padre      
        DECLARE crCobroP CURSOR FOR
        SELECT
          Origen,
          OrigenID
        FROM NegociaMoratoriosMAVI WITH (NOLOCK)
        WHERE IDCobro = @ID
        GROUP BY Origen,
                 OrigenId
        OPEN crCobroP
        FETCH NEXT FROM crCobroP INTO @Origen, @OrigenID
        WHILE @@FETCH_STATUS <> -1
        BEGIN
          IF @@FETCH_STATUS <> -2
          BEGIN

            SELECT
              @FechaCobroAntxpol = dbo.fnfechasinhora(FechaEmision)
            FROM CXC WITH (NOLOCK)
            WHERE ID = (SELECT
              MAX(IDCobro)
            FROM NegociaMoratoriosMAVI WITH (NOLOCK)
            WHERE Origen = @Origen
            AND OrigenID = @OrigenID
            AND IDCobro < @ID
            AND IDCobro IN (SELECT
              t.IDCobro
            FROM TipoCobroMAVI t WITH (NOLOCK)
            WHERE t.TipoCobro = 1))

            IF dbo.fnfechaSinHora(@FechaCobroAntxpol) = dbo.fnfechaSinHora(GETDATE())
            BEGIN
              SET @Ok = '100036'
              SET @OkRef = 'Ya existe un cobro previo por politica'
            END
          END
          FETCH NEXT FROM crCobroP INTO @Origen, @OrigenID

        END
        CLOSE crCobroP
        DEALLOCATE crCobroP
      END
    END
    --Termina Cobro por Politica      

    ------------punto 23 pzamudio sustituye al codigo de arriba        
    IF @Estatus = 'SINAFECTAR'
      AND (@MovTipo IN ('CXC.C', 'CXC.DP')
      OR @Mov = 'Cheque Posfechado')
      AND @AplicaManual = 1
      AND @OK IS NULL
      AND NOT EXISTS (SELECT
        idCobro
      FROM NegociaMoratoriosMavi WITH (NOLOCK)
      WHERE idCobro = @id) ----pzamudio punto 22 12-05-2010        
    BEGIN

      CREATE TABLE #temp2 (
        Origen varchar(20),
        OrigenID varchar(20),
        Mov varchar(20),
        MovID varchar(20),
        Vencimiento datetime
      )

      CREATE TABLE #cobro (
        Mov varchar(20) NOT NULL,
        MovID varchar(20) NOT NULL,
        importeCobro money NULL
      )

      CREATE TABLE #cobroAplica (
        idmov int,
        Mov varchar(20) NOT NULL,
        MovID varchar(20) NOT NULL,
        PadreMavi varchar(20) NULL,
        PadreMaviID varchar(20) NULL,
        concepto varchar(50) NULL,
        NumDoc int NULL,
        listo bit DEFAULT 0,
        idVence int,
        importeCobro money NULL,
        Saldo money NULL,
        Vencimiento datetime
      )


      INSERT INTO #cobro (Mov, MovID, importeCobro)
        SELECT
          Aplica,
          AplicaID,
          Importe
        FROM CxcD WITH (NOLOCK)
        WHERE ID = @ID
        AND Aplica IN ('Documento', 'Contra Recibo', 'Contra Recibo Inst', 'Nota Cargo', 'Nota Cargo VIU', 'Nota Cargo Mayoreo') -- select * from MovTipo where modulo = 'CXC' and mov like '%contra%'          

      INSERT INTO #cobroAplica (idmov, Mov, MovID, PadreMavi, PadreMaviID, concepto, Vencimiento, numDoc, idVence, importeCobro, Saldo)
        SELECT
          c.id,
          ca.mov,
          ca.MovID,
          c.PadreMAVI,
          c.PadreIDMAVI,
          c.Concepto,
          c.Vencimiento,
          COUNT(0) OVER (PARTITION BY c.PadreMAVI, c.PadreIDMAVI),
          ROW_NUMBER() OVER (PARTITION BY c.PadreMAVI, c.PadreIDMAVI ORDER BY c.Vencimiento),
          ca.importeCobro,
          c.Saldo
        FROM cxc c WITH (NOLOCK)
        JOIN #cobro ca
          ON ca.Mov = c.Mov
          AND ca.MovID = c.MovID
        WHERE (c.Mov IN ('Documento', 'Contra Recibo', 'Contra Recibo Inst')
        OR (c.mov IN ('Nota Cargo', 'Nota Cargo VIU', 'Nota Cargo Mayoreo')
        AND c.Concepto IN ('CANC COBRO FACTURA', 'CANC COBRO FACTURA VIU', 'CANC COBRO MAYOREO', 'CANC COBRO CRED Y PP', 'CANC COBRO SEG AUTO', 'CANC COBRO SEG VIDA')))
        AND c.Estatus NOT IN ('CANCELADO')

      DECLARE crCxcD CURSOR FOR
      SELECT
        ca.PadreMavi,
        ca.PadreMaviID,
        ca.NumDoc
      FROM #cobroAplica ca WITH (NOLOCK)
      GROUP BY ca.PadreMavi,
               ca.PadreMaviID,
               ca.NumDoc
      OPEN crCxcD
      FETCH NEXT FROM crCxcD INTO @PadreMavi, @PadreMaviID, @contfinal
      WHILE @@FETCH_STATUS <> -1
      BEGIN
        IF @@FETCH_STATUS <> -2
        BEGIN

          SELECT
            @cont = 1--, @contfinal = 0         

          WHILE @cont <= @contfinal
          BEGIN

            SELECT
              @Aplica = mov,
              @AplicaID = ca.MovID,
              @Vencimiento = Vencimiento,
              @idAux = ca.idmov
            FROM #cobroAplica ca WITH (NOLOCK)
            WHERE ca.PadreMavi = @PadreMavi
            AND ca.PadreMaviID = @PadreMaviID
            AND ca.idVence = @cont

            IF @Aplica IN ('Nota Cargo', 'Nota Cargo VIU', 'Nota Cargo Mayoreo')
            BEGIN

              INSERT INTO #temp2
                SELECT
                  PadreMAVI,
                  PadreIDMAVI,
                  mov,
                  MovID,
                  Vencimiento
                FROM cxc WITH (NOLOCK)
                WHERE id IN (SELECT
                  id
                FROM MovCampoExtra WITH (NOLOCK)
                WHERE Modulo = 'CXC'
                AND Valor = @PadreMavi + '_' + @PadreMaviID)
                AND Estatus IN ('PENDIENTE')
                AND id <> @idAux
                AND Vencimiento < @Vencimiento
                AND id NOT IN (SELECT
                  idmov
                FROM #cobroAplica ca WITH (NOLOCK)
                WHERE PadreMavi = @PadreMavi
                AND PadreMaviID = @PadreMaviID
                AND ca.listo = 1)
                ORDER BY Vencimiento DESC

            END
            ELSE
            BEGIN

              -- Meter los doctos del mismo padre q el del doc q se esta evaluando        
              INSERT INTO #temp2
                SELECT
                  Origen,
                  OrigenID,
                  Mov,
                  MovID,
                  Vencimiento
                FROM CxcPendiente WITH (NOLOCK)
                WHERE Origen = @PadreMavi
                AND OrigenID = @PadreMaviID
                AND NOT (MovID = @AplicaID
                AND Mov = @Aplica)
                AND Vencimiento < @Vencimiento
                AND id NOT IN (SELECT
                  idmov
                FROM #cobroAplica ca WITH (NOLOCK)
                WHERE PadreMavi = @PadreMavi
                AND PadreMaviID = @PadreMaviID
                AND ca.listo = 1)
                ORDER BY Vencimiento ASC

            END

            IF @cont <> @contfinal
            BEGIN
              UPDATE #cobroAplica
              SET listo = 1
              WHERE importeCobro = Saldo
              AND PadreMavi = @PadreMavi
              AND PadreMaviID = @PadreMaviID
              AND idVence = @cont
            END

            SELECT
              @cont = @cont + 1
          END

          IF EXISTS (SELECT
              Vencimiento
            FROM #temp2)

          BEGIN
            SELECT
              @Ok = 100020
          END
        END
        FETCH NEXT FROM crCxcD INTO @PadreMavi, @PadreMaviID, @contfinal
      END
      CLOSE crCxcD
      DEALLOCATE crCxcD
    END

    IF @Mov IN ('Nota Credito', 'Nota Credito VIU', 'Nota Credito Mayoreo', 'Cancela Prestamo', 'Cancela Credilana')
      AND @Concepto LIKE 'CORR COBRO%'
    BEGIN
      IF (SELECT
          COUNT(*)
        FROM (SELECT DISTINCT
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
        WHERE c.ID = @ID) AS Padres)
        > 1
        SELECT
          @OK = 100035
    END
  END


  IF @Modulo = 'CXC'
    AND @Accion IN ('AFECTAR', 'VERIFICAR')
    AND @OK IS NULL  -- yrg 220609          
  BEGIN

    SELECT
      @Agente = Agente,
      @Financiamiento = Financiamiento,/* @CondRef = CondRef,*/
      @Estatus = Estatus,
      @Mov = Mov,
      @Situacion = Situacion,
      @Origen = Origen,
      @OrigenID = OrigenID,
      @SaldoTotal = (ISNULL(Importe, 0) + ISNULL(Impuestos, 0))
    FROM CXC WITH (NOLOCK)
    WHERE ID
    =


    @ID
    SELECT
      @MovTipo = Clave
    FROM MovTipo WITH (NOLOCK)
    WHERE Mov = @Mov
    AND Modulo = @Modulo

    -- INICIO Validación para Importe en COBRO GRB 07-05-10        
    SELECT
      @ImporteTotal = Importe
    FROM CXC WITH (NOLOCK)
    WHERE ID = @ID
    IF @Mov = 'Cobro'
    BEGIN
      IF (SELECT
          ValorAfectar
        FROM CXC WITH (NOLOCK)
        WHERE ID = @ID)
        = 1
      BEGIN
        IF ISNULL(@ImporteTotal, 0) = 0
        BEGIN
          SELECT
            @Ok = 40140
        END
        IF (SELECT
            AplicaManual
          FROM CXC WITH (NOLOCK)
          WHERE ID = @ID)
          <> 1
          AND ISNULL(@ImporteTotal, 0) <> 0
        BEGIN
          SELECT
            @Ok = 20170
        END
        UPDATE Cxc WITH (ROWLOCK)
        SET ValorAfectar = 0
        WHERE id = @ID
      END
    END
    -- FIN Validación para Importe en COBRO        

    IF @Estatus = 'SINAFECTAR'
      AND @Mov IN ('Dev Anticipo Contado', 'Devolucion Apartado')
      AND @Situacion IS NULL
    BEGIN
      SELECT
        @Ok = 99990
    END
    --- Validaci¢n de Movimiento 'Aplicacion' en CXC ---          
    --- Edgar Montelongo 24/Nov/2008 ---          
    --- Se ingreso la validacion de la condicion, canal y tipo de cliente para los movimientos Diverso Deudor 02/12/08 ALQG ---          
    IF @Mov = 'Aplicacion'
    BEGIN
      EXEC spValidarCtasIncobrableMAVI @ID,
                                       @Mov,
                                       @Ok OUTPUT,
                                       @OkRef OUTPUT,
                                       0
    --EXEC xpValidarAplicacionCXC @ID, NULL, @Ok=@Ok OUTPUT          
    END
    ELSE
    IF (@Mov IN ('Nota Credito Mayoreo', 'Nota Credito', 'Nota Credito VIU', 'Cancela Credilana', 'Cancela Prestamo', 'Cancela Seg Auto', 'Cancela Seg Vida'))
    BEGIN
      EXEC spValidarCtasIncobrableMAVI @ID,
                                       @Mov,
                                       @Ok OUTPUT,
                                       @OkRef OUTPUT,
                                       0
    --EXEC xpValidarAplicacionCXC @ID, @Mov, @Ok=@Ok OUTPUT          
    END
    IF @Mov IN ('Prestamo', 'Diversos Deudores')
    BEGIN
      SELECT
        @PrefijoCte = SUBSTRING(Cte.Cliente, 1, 1),
        @TipoCte = Cte.Tipo,
        @Condicion = Cxc.Condicion,
        @CteEnviarA = Cxc.ClienteEnviarA
      FROM CTE WITH (NOLOCK),
           CXC WITH (NOLOCK)
      WHERE Cte.Cliente = Cxc.Cliente
      AND Cxc.ID = @ID
      SELECT
        @Condicion2 = Cadena
      FROM VentasCanalMAVI WITH (NOLOCK)
      WHERE ID = @CteEnviarA
      IF @TipoCte <> 'Deudor'
        OR @PrefijoCte <> 'D'
        OR @Condicion2 <> 'CONTADO MA'
        OR @CteEnviarA <> 2
        OR @Condicion <> 'CONTADO DEUDOR'
      BEGIN
        SELECT
          @Ok = 99990
      END
    END

    IF @Mov = 'Cobro Div Deudores'
    BEGIN
      SELECT
        @PrefijoCte = SUBSTRING(Cte.Cliente, 1, 1),
        @TipoCte = Cte.Tipo,
        @Condicion = Cxc.Condicion,
        @CteEnviarA = Cxc.ClienteEnviarA
      FROM CTE WITH (NOLOCK),
           CXC WITH (NOLOCK)
      WHERE Cte.Cliente = Cxc.Cliente
      AND Cxc.ID = @ID
      SELECT
        @Condicion2 = Cadena
      FROM VentasCanalMAVI WITH (NOLOCK)
      WHERE ID = @CteEnviarA
      IF @TipoCte <> 'Deudor'
        OR @PrefijoCte <> 'D'
        OR @Condicion2 <> 'CONTADO MA'
        OR @CteEnviarA <> 2
      BEGIN
        SELECT
          @Ok = 99990
      END
    END

    /**** Modificacion: se agrego validacion para determinar la base y poder afectar los movs en migraciones. JR 09-Jun-2011 ****/
    IF ((SELECT
        DB_NAME())
      = 'MAVICOB')
      IF @Mov = 'Documento'
        AND @Estatus = 'SINAFECTAR'
        AND @MovTipo = 'CXC.D'
        SELECT
          @Ok = 60160  -- ARC 26-Ene-09 Validacion para que no se puedan generar documentos directos en cxc          
    IF ((SELECT
        DB_NAME())
      = 'INTELISISTMP')
      IF @Mov = 'Documento'
        AND @Estatus = 'SINAFECTAR'
        SELECT
          @Ok = 60160  -- ARC 26-Ene-09 Validacion para que no se puedan generar documentos directos en cxc          

    IF @Mov = 'Contra Recibo Inst'
      AND @Estatus = 'SINAFECTAR' -- ARC 28-Ene-09 Validacion para el movimiento          
    BEGIN
      IF (SELECT
          COUNT(ID)
        FROM CxcD WITH (NOLOCK)
        WHERE ID = @ID)
        > 1
        SELECT
          @Ok = 100001
      IF EXISTS (SELECT
          ID
        FROM CxcD WITH (NOLOCK)
        WHERE ID = @ID
        AND Aplica IN ('Contra Recibo Inst', 'Cta Incobrable F', 'Cta Incobrable NV'))
        SELECT
          @Ok = 100002
    END

    IF @MovTipo = 'CXC.FAC'
      AND @Estatus = 'SINAFECTAR' -- ARC 28-Ene-09 Validacion para generar los movimientos con clave de afectacion de endoso           
    BEGIN
      IF EXISTS (SELECT
          ID
        FROM Cxc WITH (NOLOCK)
        WHERE ID = @ID
        AND MovAplica IN ('Contra Recibo Inst', 'Cta Incobrable F', 'Cta Incobrable NV'))
        SELECT
          @Ok = 100003
      ELSE
        EXEC spValidarCtasIncobrableMAVI @ID,
                                         'Endoso',
                                         @Ok OUTPUT,
                                         @OkRef OUTPUT,
                                         0
    END
    IF @Mov IN ('Cta Incobrable NV') --ARC 06-Feb-09 Candados para los movimientos de Ctas Incobrables          
      EXEC spValidarCtasIncobrableMAVI @ID,
                                       @Mov,
                                       @Ok OUTPUT,
                                       @OkRef OUTPUT,
                                       1

    IF @Mov IN ('Cta Incobrable F') --ARC 06-Feb-09 Candados para los movimientos de Ctas Incobrables          
      EXEC spValidarCtasIncobrableMAVI @ID,
                                       @Mov,
                                       @Ok OUTPUT,
                                       @OkRef OUTPUT,
                                       1
    IF @Mov = 'React Incobrable F'  -- ARC 06-Feb-09 Candado para el movimiento Reactivacion          
    BEGIN
      IF EXISTS (SELECT
          CD.ID
        FROM CxcD CD WITH (NOLOCK)
        WHERE CD.ID = @ID
        AND CD.Aplica NOT IN ('Cta Incobrable F'))
        SELECT
          @Ok = 100002
      IF (SELECT
          COUNT(ID)
        FROM CxcD WITH (NOLOCK)
        WHERE ID = @ID)
        > 1
        SELECT
          @Ok = 100001
    END

    IF @Mov = 'React Incobrable NV'
    BEGIN
      IF EXISTS (SELECT
          CD.ID
        FROM CxcD CD WITH (NOLOCK)
        WHERE CD.ID = @ID
        AND CD.Aplica NOT IN ('Cta Incobrable NV'))
        SELECT
          @Ok = 100002
      IF (SELECT
          COUNT(ID)
        FROM CxcD WITH (NOLOCK)
        WHERE ID = @ID)
        > 1
        SELECT
          @Ok = 100001
    END

    --IF @Mov IN ('Enganche')          
    IF dbo.fnClaveAfectacionMAVI(@Mov, 'CXC') IN ('CXC.AA')
    BEGIN
      -- Validar que el Movimiento Origen y el Anticipo tengan mismo canal de Venta          
      SELECT
        @Ok =
             CASE dbo.fnEsMismoCanalMAVI(@ID)
               WHEN 0 THEN 100007
               WHEN 2 THEN 100013
             END
      IF (SELECT
          dbo.fnValidarValorAnticipoMAVI(@ID))
        <> 1 -- Validar que el Importe del anticipo no sea mayor al del Movimiento Origen          
        SELECT
          @Ok = 100008
    END
    --IF (@Mov = 'Devolucion Enganche')          
    IF dbo.fnClaveAfectacionMAVI(@Mov, 'CXC') IN ('CXC.DE')
    BEGIN
      EXEC xpValidarDevolucionMAVI @ID,
                                   @Ok OUTPUT
      /*** validacion para generar devoluciones sin importe ***/
      IF (@OK IS NULL)
      BEGIN
        SELECT
          @ImporteTotal = Importe
        FROM Cxc WITH (NOLOCK)
        WHERE ID = @ID
        IF (@ImporteTotal IS NULL)
          SELECT
            @OK = 40140
      END
    END
    /**** Validacion comentada para poder utilizar el mov en el desarrollo de MaviCob. JR 08-Jun-2011 *****/
    /*IF dbo.fnClaveAfectacionMAVI(@Mov, 'CXC') IN('CXC.AE') AND @Estatus='SinAfectar'          
    SELECT @Ok = 60160    */
    /*********/

    -- Inicia desarrollo por Refinanciamiento - ALQG 300309          

    -- EM - 220409          
    IF @Mov = 'Sol Refinanciamiento'
      AND @Estatus IN ('SINAFECTAR', 'PENDIENTE')
    BEGIN
      SELECT
        @ImporteARefinanciar = 0
      IF (SELECT
          ISNULL(Importe, 0.0)
        FROM Cxc WITH (NOLOCK)
        WHERE ID = @ID)
        <= 0.0
        SELECT
          @Ok = 99996

      IF @Ok = NULL
        IF EXISTS (SELECT
            CxcD.ID
          FROM CxcD WITH (NOLOCK)
          WHERE CxcD.ID = @ID
          AND dbo.fnIDDelMovimientoMAVI(CxcD.Aplica, CxcD.AplicaID) NOT IN (SELECT
            IDOrigen
          FROM MaviRefinaciamientos WITH (NOLOCK)
          WHERE ID = @ID))
          SELECT
            @Ok = 100015


      IF @Ok IS NULL
      BEGIN
        SELECT
          @ImporteARefinanciar = SUM(ISNULL(dbo.fnSaldoPendienteMovPadreMAVI(IDOrigen), 0))
        FROM MaviRefinaciamientos WITH (NOLOCK)
        WHERE ID = @ID
        IF ISNULL(@SaldoTotal, 0) <> ISNULL(@ImporteARefinanciar, 0)
          SELECT
            @Ok = 100016
      END
      IF @Ok IS NULL
        IF (@Agente IS NULL)
          OR (@Agente = '')
          OR (ISNULL(@Agente, '') = '')
          SELECT
            @Ok = 20930

    --ELSE          
    --UPDATE Cxc SET CondRef=Condicion WHERE ID=@ID          
    END
    /*           
    IF @Mov = 'Sol Refinanciamiento' AND @Estatus='PENDIENTE'          
    BEGIN          
    UPDATE Cxc SET Condicion=CondRef WHERE ID=@ID          
    END */
    -- EM - 220409 (FIN)          

    IF @Mov = 'Refinanciamiento'
      AND ISNULL(@Origen, '') = ''
      AND ISNULL(@OrigenID, '') = ''
    BEGIN
      SET @Ok = 60160
      SELECT
        @Mensaje = Descripcion
      FROM MensajeLista WITH (NOLOCK)
      WHERE Mensaje = @Ok
    END

    -- EM - 220409          
    IF @Mov = 'Refinanciamiento'
      AND @Estatus = 'SINAFECTAR'
    BEGIN
      UPDATE Cxc WITH (ROWLOCK)
      SET EsCredilana = 1
      WHERE ID = @ID
    END
    -- EM - 220409 (FIN)          

    -- ALQG 280409 ( Inicia validacion de refinanciamientos en cero )          
    IF @Mov = 'Refinanciamiento'
      AND @Estatus = 'SINAFECTAR'
      AND @SaldoTotal = 0
    BEGIN
      SET @Ok = 99996
    END
    IF @Mov = 'Refinanciamiento'
      AND @Estatus = 'SINAFECTAR'
    BEGIN
      IF @Ok = NULL
      BEGIN
        SELECT
          @ImporteARefinanciar = NULL
        SELECT
          @IDOrigen = dbo.fnIDDelMovimientoMAVI(@Origen, @OrigenID)
        SELECT
          @ImporteARefinanciar = SUM(ISNULL(dbo.fnSaldoPendienteMovPadreMAVI(IDOrigen), 0))
        FROM MaviRefinaciamientos WITH (NOLOCK)
        WHERE ID = @IDorigen
        SELECT
          @SaldoTotal = ISNULL(@SaldoTotal, 0) - ISNULL(@Financiamiento, 0)
        IF ISNULL(@SaldoTotal, 0) <> ISNULL(@ImporteARefinanciar, 0)
          SELECT
            @Ok = 100016
      END
    END
    -- ALQG 280409 ( Termina validacion de refinanciamientos en cero )          

    -- Termina desarrollo por Refinanciamiento          

    /**** Integracion de sp para respaldar registros y cancelacion de cargo moratorio a traves de la cta inc para desarrollo de mavicob. JR 08-Jun-2011 **/

    IF (@Mov IN ('Cta Incobrable F', 'Cta Incobrable NV')
      AND @Estatus = 'SINAFECTAR'
      AND @Ok IS NULL)
      EXEC spCtaIncMigraMaviCob @ID,
                                @Usuario,
                                @Ok OUTPUT,
                                @OkRef OUTPUT

    /**** Integracion de sp para cambiar el estatus de historico de envios de ctas inc para desarrollo de mavicob. JR 08-Jun-2011 ***/

    IF (@MovTipo = 'CXC.NC'
      AND @Estatus = 'SINAFECTAR')
      EXEC spCambiaEstadoEnvioMaviCob @ID,
                                      @Accion

    /*** validacion para evitar aplicar cheques posfechados que sobrepasen el monto total del documento. JR 03-Oct-2012. *****/
    IF (@Mov = 'Cheque Posfechado'
      AND @Ok IS NULL)
      EXEC spValidaAplicacionChequePos @ID,
                                       @Ok OUTPUT,
                                       @OkRef OUTPUT


  END

  IF @Modulo = 'CXC'
    AND @Accion = 'GENERAR'
  BEGIN
    SELECT
      @ImporteARefinanciar = 0
    SELECT
      @Financiamiento = Financiamiento,
      @CondRef = CondRef,
      @Estatus = Estatus,
      @Mov = Mov,
      @Situacion = Situacion,
      @Origen = Origen,
      @OrigenID = OrigenID,
      @SaldoTotal = (ISNULL(Importe, 0) + ISNULL(Impuestos, 0))
    FROM CXC WITH (NOLOCK)
    WHERE ID = @ID

    IF @Mov = 'Sol Refinanciamiento'
      AND @Estatus = 'PENDIENTE'
    BEGIN
      IF @Estatus = 'PENDIENTE'
        AND @Ok = NULL
      BEGIN
        IF (ISNULL(@CondRef, '') = ''
          OR @CondRef = '')
          SELECT
            @Ok = 100017
        IF @Financiamiento <= 0
          SELECT
            @Ok = 100018
      END

      IF @SaldoTotal <= 0.0
        SELECT
          @Ok = 99996

      IF @Ok = NULL
        IF EXISTS (SELECT
            CxcD.ID
          FROM CxcD WITH (NOLOCK)
          WHERE CxcD.ID = @ID
          AND dbo.fnIDDelMovimientoMAVI(CxcD.Aplica, CxcD.AplicaID) NOT IN (SELECT
            IDOrigen
          FROM MaviRefinaciamientos WITH (NOLOCK)
          WHERE ID = @ID))
          SELECT
            @Ok = 100015


      IF @Ok = NULL
      BEGIN
        SELECT
          @ImporteARefinanciar = SUM(ISNULL(dbo.fnSaldoPendienteMovPadreMAVI(IDOrigen), 0))
        FROM MaviRefinaciamientos WITH (NOLOCK)
        WHERE ID = @ID
        IF ISNULL(@SaldoTotal, 0) <> ISNULL(@ImporteARefinanciar, 0)
          SELECT
            @Ok = 100016
      END
    END
  END

  IF @Modulo = 'CXC'
    AND @Accion = 'CANCELAR'
  BEGIN
    EXEC spValidaNoCancelarCobrosIntermediosMAVI @Modulo,
                                                 @ID,
                                                 @Accion,
                                                 @Base,
                                                 @EnSilencio,
                                                 @Ok OUTPUT,
                                                 @OkRef OUTPUT,
                                                 @FechaRegistro
    SELECT
      @Estatus = Estatus,
      @Mov = Mov,
      @Situacion = Situacion
    FROM Cxc WITH (NOLOCK)
    WHERE ID = @ID
    --IF @Mov = 'Enganche'          
    IF dbo.fnClaveAfectacionMAVI(@Mov, 'CXC') IN ('CXC.AA')
    BEGIN
      IF (SELECT
          ISNULL(SaldoAplicadoMavi, 0.0) + ISNULL(SaldoDevueltoMavi, 0.0)
        FROM Cxc WITH (NOLOCK)
        WHERE ID = @ID)
        > 0
        SET @Ok = 100009
    --EXEC xpPedidoNoConcluidoMAVI @ID, @Ok OUTPUT          
    END

    IF @Mov = 'Aplicacion Saldo'
    BEGIN
      DECLARE @MovRef varchar(50),
              @MovIDRef varchar(50)
      SELECT
        @MovRef = Aplica,
        @MovIDRef = AplicaID
      FROM CxcD WITH (NOLOCK)
      WHERE ID = @ID
      IF (SELECT
          Estatus
        FROM Cxc WITH (NOLOCK)
        WHERE Mov = @MovRef
        AND MovID = @MovIDRef)
        = 'Concluido'
        SET @Ok = 100010
    END

    IF dbo.fnClaveAfectacionMAVI(@Mov, 'CXC') IN ('CXC.C') --  Se verifica su fecha de emision      
    BEGIN
      SELECT
        @FechaEmision = CONVERT(varchar(8), FechaEmision, 112)
      FROM Cxc WITH (NOLOCK)
      WHERE ID = @ID
      IF @FechaEmision <> @FechaActual
      BEGIN
        SET @Ok = '60050'  -- 21          
      --SET @OkRef= 'Este Movimiento Ya No se Puede Cancelar'      
      END
    END


    /*          
    IF dbo.fnClaveAfectacionMAVI(@Mov, 'CXC') IN('CXC.NC')          
    BEGIN          
    IF EXISTS(SELECT IDCxc FROM RefinIDInvolucra WHERE IDCxc=@ID)          
    SELECT @Ok = 60180   --22-May-09 Para evitar que se cancelen las notas de credito que se generan de forma automatica con el refinanciamiento          
    END          
    */
    --IF @Ok is null        
    --EXEC spValidaNoCancelarCobrosIntermediosMAVI @Modulo, @ID, @Accion, @Base, @EnSilencio, @Ok OUTPUT, @OkRef OUTPUT, @FechaRegistro        
    --EXEC spValidaNoCancelarCobrosIntermediosMAVI 'CXC', 8673585, 'CANCELAR', 'Todo', 1, @Ok OUTPUT, @OkRef OUTPUT, @Hoy            
    --EXEC spValidarCtasIncobrableMAVI @ID, @Mov, @Ok OUTPUT, @OkRef OUTPUT, 1          

    -- Actualizacion de validacion para cancelacion sol Refinanciamiento  BVF 23052011      
    IF dbo.fnClaveAfectacionMAVI(@Mov, 'CXC') IN ('CXC.EST')
      AND @Mov = 'Sol Refinanciamiento'
    BEGIN
      SELECT
        @EstatusSol = Estatus,
        @MovSol = Mov,
        @MovIDSol = MovID
      FROM CXC WITH (NOLOCK)
      WHERE ID = @ID
      IF @EstatusSol IN ('CONCLUIDO', 'PENDIENTE')
      BEGIN
        IF EXISTS (SELECT
            Mov
          FROM CXC WITH (NOLOCK)
          WHERE Origen = @MovSol
          AND OrigenID = @MovIDSol
          AND Mov = 'Refinanciamiento'
          AND estatus NOT IN ('CANCELADO'))
          SET @Ok = 30151
      END
    END

    /**** Integracion de sp para cambiar el estatus de historico de envios de ctas inc para desarrollo mavicob. JR 08-Jun-2011 ***/
    --EVITAR QUE SE CANCELE UNA NOTA CREDITO CON UNA CTA INCOBRABLE YA ENVIADA

    IF (dbo.fnClaveAfectacionMAVI(@Mov, 'CXC') = 'CXC.NC') --- este es cuando se cancela        
    BEGIN
      IF (SELECT
          h.Estatus
        FROM CXCD D WITH (NOLOCK)
        JOIN MOVTIPO M WITH (NOLOCK)
          ON D.APLICA = M.MOV
          AND M.CLAVE = 'CXC.DM'
          AND M.MODULO = 'CXC'
        JOIN CXC C WITH (NOLOCK)
          ON C.MOV = D.APLICA
          AND C.MOVID = D.APLICAID
        JOIN CtasMaviCobHist H WITH (NOLOCK)
          ON C.ID = H.IDCtaIncobrable
        WHERE d.id = @id)
        = 'ENVIADO'
      BEGIN
        SELECT
          @ok = 100036 --,@OkRef ='No se puede cancelar porque la cta ya fuen enviada a mavicob'
      END
      ELSE
      BEGIN
        EXEC spCambiaEstadoEnvioMaviCob @ID,
                                        @Accion
      END
    END

    --Evitar que se cancele la cta incobrabel si ya se envió a Mavicob
    IF (dbo.fnClaveAfectacionMAVI(@Mov, 'CXC') = 'CXC.DM')
      AND @Accion = 'CANCELAR'
    BEGIN
      IF (SELECT
          Estatus
        FROM CtasMaviCobHist WITH (NOLOCK)
        WHERE IDCtaIncobrable = @ID)
        = 'ENVIADO'
        SELECT
          @ok = 100036 --,@OkRef ='No se puede cancelar porque la cta ya fuen enviada a mavicob'
    END


  /**/
  --IF (dbo.fnClaveAfectacionMAVI(@Mov, 'CXC') = 'CXC.DM') And @Accion = 'CANCELAR'
  --EXEC spRevisaCtaIncEnvioMaviCob @ID   

  END


  ---------- MODULO DE EMBARQUES -----------          
  --- Validacion de Situaciones en el Modulo de Embarques ---          

  IF @Modulo = 'EMB'
    AND @Accion = 'AFECTAR'  --ARC CM 18-May-09          
  BEGIN
    SELECT
      @Agente = Agente,
      @Estatus = Estatus,
      @Mov = Mov,
      @Situacion = Situacion
    FROM Embarque WITH (NOLOCK)
    WHERE ID = @ID
    SELECT
      @NivelCobranza = NivelCobranzaMAVI
    FROM Agente WITH (NOLOCK)
    WHERE Agente = @Agente
    SELECT
      @MovTipo = Clave
    FROM MovTipo WITH (NOLOCK)
    WHERE Mov = @Mov
    AND Modulo = @Modulo
    IF @Estatus = 'SINAFECTAR'
      AND @Mov IN ('Embarque Mayoreo', 'Embarque', 'Embarque Sucursal', 'Embarque Magisterio')
      AND @Situacion IS NULL
    BEGIN
      SELECT
        @Ok = 99990
    END
    ELSE
    IF (@Mov = 'Orden Cobro'
      AND @Estatus = 'SINAFECTAR')
      IF EXISTS (SELECT
          Cx.Mov,
          Cx.MovID
        FROM EmbarqueD ED WITH (NOLOCK)
        JOIN EmbarqueMov EM WITH (NOLOCK)
          ON ED.EmbarqueMov = EM.ID
          AND EM.Modulo = 'CXC'
        JOIN Cxc Cx WITH (NOLOCK)
          ON EM.ModuloID = Cx.ID
        JOIN Cte Cte WITH (NOLOCK)
          ON Cte.Cliente = Cx.Cliente
        LEFT OUTER JOIN CteEnviarA E WITH (NOLOCK)
          ON E.ID = Cx.ClienteEnviarA
          AND E.Cliente = Cx.Cliente
        WHERE ED.ID = @ID
        AND ISNULL(E.NivelCobranzaMAVI, 'SIN NIVEL') <> @NivelCobranza)
        SELECT
          @Ok = 100014

    SELECT
      @Agente = Agente,
      @Mov = Mov,
      @Agente2 = Agente2,
      @Licencia = LicenciaAgente,
      @Licencia2 = LicenciaAgente2,
      @Ruta = Ruta
    FROM Embarque WITH (NOLOCK)
    WHERE ID = @ID

    -- agregar nueva validacion        
    IF (@Estatus = 'SINAFECTAR'
      AND @Mov <> 'Orden Cobro')
    BEGIN
      IF (LTRIM(RTRIM(@Agente)) IN ('', NULL))
        SELECT
          @Ok = 60260,
          @OkRef = ' Agente '

      IF (LTRIM(RTRIM(@licencia)) IN ('', NULL))
        SELECT
          @Ok = 60260,
          @OkRef = ' Licencia '

      IF (LTRIM(RTRIM(@Ruta)) IN ('', NULL))
        SELECT
          @Ok = 60260,
          @OkRef = ' Ruta '

      IF (@Agente2 NOT IN ('', NULL)
        AND LTRIM(RTRIM(@Licencia2)) IN ('', NULL))
        SELECT
          @Ok = 60260,
          @OkRef = ' Licencia Agente 2 '

    END




  END


  ---------- MODULO DE ACTIVOS FIJOS -----------          

  IF @Modulo = 'AF'
    AND @Accion = 'AFECTAR'
  BEGIN

    SELECT
      @Estatus = Estatus,
      @Mov = Mov,
      @Situacion = Situacion,
      @Concepto = Concepto,
      @Personal = ISNULL(Personal, 'SINASIGNAR')
    FROM ActivoFijo WITH (NOLOCK)
    WHERE ID = @ID
    IF @Estatus = 'SINAFECTAR'
      AND @Mov IN ('Mantenimiento Ligero', 'Mantenimiento Severo')
      AND ((@Situacion IS NULL)
      OR (@Situacion = 'Por Autorizar'))
    BEGIN
      IF @Concepto = 'OMITIR MANNTO'
        SELECT
          @Ok = 99990
    END
    ---- Validacion para Asignacion de AF -- GRB 23-Nov-09          
    IF @Mov = 'Asignacion'
    BEGIN
      IF @Personal IN ('SINASIGNAR', ' ')
      BEGIN
        SELECT
          @Ok = 100027
      END
    END

    -- agregar asignacion a la lista         
    SELECT
      @Proveedor = Proveedor
    FROM ActivoFijo WITH (NOLOCK)
    WHERE ID = @ID

    -- agregar nueva validacion        
    IF (@Estatus = 'SINAFECTAR'
      AND @Mov IN ('Mannto Maquinaria', 'Mantenimiento', 'Mantenimiento Ligero', 'Mantenimiento Severo',
      'Poliza Mantenimiento', 'Poliza Seguro', 'Reparacion'))
    BEGIN
      IF (LTRIM(RTRIM(@Proveedor)) IN ('', NULL))
        SELECT
          @Ok = 40020
    END

  END



  ---------- MODULO DE VENTAS -----------          

  IF @Modulo = 'VTAS'
    AND @Accion = 'AFECTAR'  --Validar que en los movimientos de ventas de clave de afectacion diferente de VTAS.P no se tenga un cliente prospecto o con prefijo P (Arly Rubio C 30-Sep-08)          
  BEGIN
    SELECT
      @Mov = Mov,
      @Cliente = Cliente
    FROM Venta WITH (NOLOCK)
    WHERE ID = @ID
    SELECT
      @ImporteTotal = SUM(ISNULL(Cantidad, 0) * ISNULL(Precio, 0))
    FROM VentaD WITH (NOLOCK)
    WHERE ID = @ID
    SELECT
      @MovTipo = Clave
    FROM MovTipo WITH (NOLOCK)
    WHERE Mov = @Mov
    AND Modulo = 'VTAS'
    --  C¢digo agregado 15-Dic-2008 EM Validar que el Movimiento Negativo de Venta corresponda al Positivo correcto           
    IF @Mov IN ('Devolucion Venta', 'Devolucion Venta VIU', 'Devolucion Mayoreo', 'Cancela Credilana', 'Cancela Prestamo', 'Cancela Seg Auto', 'Cancela Seg Vida')    --Cambio Dev Venta Mayoreo X Devolucion Mayoreo JC      
    BEGIN
      SELECT
        @mov = (SELECT
          Origen
        FROM Venta WITH (NOLOCK)
        WHERE ID = @ID)
      IF (SELECT
          Origen
        FROM Venta WITH (NOLOCK)
        WHERE ID = @ID)
        = 'Sol Dev Unicaja'
      BEGIN
        EXEC xpValidarMovSolDevUnicaja @ID,
                                       @Ok OUTPUT,
                                       2
      END
      ELSE
      IF (SELECT
          Origen
        FROM Venta WITH (NOLOCK)
        WHERE ID = @ID)
        = 'Solicitud Devolucion'
      BEGIN
        EXEC xpValidarMovSolDevolucion @ID,
                                       @Ok OUTPUT,
                                       2
      END
      ELSE
      IF (SELECT
          Origen
        FROM Venta WITH (NOLOCK)
        WHERE ID = @ID)
        = 'Sol Dev Mayoreo'
      BEGIN
        EXEC xpValidarMovSolDevolucion @ID,
                                       @Ok OUTPUT,
                                       4
      END
    END
    IF @ImporteTotal <= 0
      AND dbo.fnClaveAfectacionMAVI(@Mov, 'VTAS') IN ('VTAS.P', 'VTAS.F') -- Validaci¢n para que no se emitan pedidos o facturas en 0 (ARC 09-Dic-08)          
      SELECT
        @Ok = 99996
    IF @Mov NOT IN ('Analisis Mayoreo', 'Solicitud Mayoreo', 'Analisis Credito', 'Solicitud Credito')
    BEGIN
      SELECT
        @TipoCte = Tipo
      FROM Cte WITH (NOLOCK)
      WHERE Cliente = @Cliente
      SELECT
        @PrefijoCte = LEFT(@Cliente, 1)
      IF @PrefijoCte = 'P'
        OR @TipoCte = 'Prospecto'
        SELECT
          @Ok = 99991
    END
    ELSE
    BEGIN
      IF @Mov IN ('Analisis Credito', 'Solicitud Credito')  -- Validar que no se generen los movimientos cuando la condicion es tipo 'Contado' ARC(09-Dic-08)          
        IF EXISTS (SELECT
            *
          FROM Venta V WITH (NOLOCK)
          LEFT OUTER JOIN Condicion C WITH (NOLOCK)
            ON V.Condicion = C.Condicion
          WHERE V.ID = @ID
          AND C.TipoCondicion = 'Contado')
          SELECT
            @Ok = 99997
    END

    -- Inicia Modificacion para ingresar validacion de las Devoluciones ALQG 23Marzo2010        

    IF dbo.fnClaveAfectacionMAVI(@Mov, 'VTAS') IN ('VTAS.D', 'VTAS.SD')
    BEGIN
      IF @Mov = 'Sol Dev Unicaja'  -- INICIO Se agregaron estas lineas Inicia modificacion ARC (25-Nov-08)        
      BEGIN
        IF EXISTS (SELECT
            IDCopiaMavi
          FROM VentaD WITH (NOLOCK)
          WHERE IdCopiaMavi IS NOT NULL
          AND ID = @ID)
          SELECT
            @Ok = 99995
        ELSE  -- Agregar aquí el proceso para Sol Dev Unicaja (15-Dic-2008 EM)        
        BEGIN
          EXEC xpValidarMovSolDevUnicaja @ID,
                                         @Ok OUTPUT,
                                         1
          SELECT
            @NuloCopia = 0
          SELECT
            @GpoTrabajo = GrupoTrabajo
          FROM Usuario WITH (NOLOCK)
          WHERE Usuario = @Usuario

          IF EXISTS (SELECT
              IDCopiaMavi
            FROM VentaD WITH (NOLOCK)
            WHERE ((IDCopiaMavi IS NULL)
            OR (IdCopiaMAVI = ''))
            AND ID = @ID)
            SELECT
              @NuloCopia = 1
          IF @NuloCopia = 1
            AND @GpoTrabajo NOT IN ('CONTABILIDAD')
            SELECT
              @Ok = 100028
        END
      END
      ELSE
      BEGIN
        IF (SELECT
            Origen
          FROM Venta WITH (NOLOCK)
          WHERE ID = @ID)
          <> 'Sol Dev Unicaja'
        BEGIN
          IF EXISTS (SELECT
              IDCopiaMavi
            FROM VentaD WITH (NOLOCK)
            WHERE IdCopiaMavi IS NULL
            AND ID = @ID)
            SELECT
              @Ok = 99992
        END
        IF (@Mov = 'Sol Dev Mayoreo')-- OR @Mov = 'Devolucion Mayoreo') --comentado JC       
        BEGIN
          EXEC xpValidarMovSolDevolucion @ID,
                                         @Ok OUTPUT,
                                         3    -- 16-Dic-2008 EM        
        END
        ELSE
        BEGIN
          EXEC xpValidarMovSolDevolucion @ID,
                                         @Ok OUTPUT,
                                         1    -- 15-Dic-2008 EM        
        END
        EXEC spValidarCantidadDevMAVI @ID,
                                      @Modulo,
                                      @Ok OUTPUT,
                                      @OkRef OUTPUT
        IF @Mov IN ('Cancela Credilana', 'Cancela Prestamo')
          AND @Ok IS NULL -- ARC 18-Feb-09 PAra generar Ingreso        
          EXEC spGenerarIngresoAlDevolverMAVI @ID,
                                              @Usuario,
                                              @Ok OUTPUT,
                                              @OkRef OUTPUT
      END
    END

    -- Termina Modificacion para ingresar validacion de las Devoluciones ALQG 23Marzo2010        

    -- Agregado 03-Feb-09 EM          
    --IF @Mov IN ('Solicitud Credito','Analisis Credito','Pedido','Pedido Mayoreo','Factura VIU','Factura Mayoreo')          
    IF dbo.fnClaveAfectacionMAVI(@Mov, 'VTAS') IN ('VTAS.P', 'VTAS.F')
    BEGIN
      -- ALQG 26Marzo2010 Se ingreso la validacion de las series y lotes en la venta. Solucon Punto No. 4 TFS. mvelasco        
      EXEC xpValidarSerieLoteMAVI @ID,
                                  @Ok OUTPUT,
                                  @OkRef OUTPUT
      IF ISNULL((SELECT
          Agente
        FROM Venta WITH (NOLOCK)
        WHERE ID = @ID)
        , '') = ''
        SELECT
          @Ok = 100004
    END
    IF @Mov IN ('Solicitud Mayoreo', 'Analisis Mayoreo', 'Pedido Mayoreo')
    BEGIN
      IF ISNULL((SELECT
          FormaEnvio
        FROM Venta WITH (NOLOCK)
        WHERE ID = @ID)
        , '') = ''
        SELECT
          @Ok = 100005
    END

    --- VALIDACION PARA FACTURA MAYOREO --- GRB 19-Nov-09          
    IF @Mov = 'FACTURA MAYOREO'
    BEGIN
      IF 'ACTIVOS FIJOS' IN (SELECT
          a.categoria
        FROM art a WITH (NOLOCK),
             ventad vd WITH (NOLOCK)
        WHERE vd.ID = @ID
        AND a.articulo = vd.articulo)
      BEGIN
        -- Guardamos en este cursor los numeros de serie de los activos fijos que se encuentren para el moval momento de afectar          
        DECLARE @Serie varchar(20),
                @Art varchar(20)
        DECLARE AFSeries_Cursor CURSOR FOR
        SELECT
          SerieLote,
          Articulo
        FROM serielotemov WITH (NOLOCK)
        WHERE ID = @ID
        OPEN AFSeries_Cursor
        FETCH NEXT FROM AFSeries_Cursor
        INTO @Serie, @Art
        WHILE @@FETCH_STATUS = 0
          AND @Ok IS NULL
        BEGIN
          IF (SELECT
              responsable
            FROM ActivoF WITH (NOLOCK)
            WHERE Serie = @Serie
            AND Articulo = @Art)
            <> NULL
            SELECT
              @Ok = 100024
          -- Agarramos la siguiente serie en caso de existir mas AF --          
          FETCH NEXT FROM AFSeries_Cursor
          INTO @Serie, @Art
        END
        CLOSE AFSeries_Cursor
        DEALLOCATE AFSeries_Cursor
      END
      IF ISNULL((SELECT
          FormaEnvio
        FROM Venta WITH (NOLOCK)
        WHERE ID = @ID)
        , '') = ''
        SELECT
          @Ok = 100005
    END

    /******   Validacion de RFC para el cliente  JRD 25-Feb-10 ******/
    IF (@Mov IN ('Solicitud Credito', 'Pedido', 'Solicitud Mayoreo'))
    BEGIN
      SELECT
        @Cliente = Cliente
      FROM Venta WITH (NOLOCK)
      WHERE ID = @ID
      IF ((SELECT
          FacDesgloseIVA
        FROM Venta WITH (NOLOCK)
        WHERE ID = @ID)
        = 1)
      BEGIN
        SELECT
          @RFCCompleto = dbo.fnValidaRFC(@Cliente)
        IF (@RFCCompleto = 1)
          SELECT
            @OK = 80110,
            @OKRef = 'El RFC del Cliente No Está Completo'
        IF (@RFCCompleto = 2)
          SELECT
            @OK = 80110,
            @OKRef = 'El RFC del Cliente Está Incorrecto'
      END
    END
    -- Se trae el check en base a la factura devuelta BVF 05-May-10        
    IF @Mov IN ('Solicitud Devolucion', 'Sol Dev Mayoreo')
    BEGIN
      SELECT
        @DevOrigen = ISNULL(IDCopiaMavi, 0)
      FROM VentaD WITH (NOLOCK)
      WHERE ID = @ID
      SELECT
        @FacDesgloseIVA = FacDesgloseIVA
      FROM Venta WITH (NOLOCK)
      WHERE Id = @DevOrigen
      UPDATE Venta WITH (ROWLOCK)
      SET FacDesgloseIVA = @FacDesgloseIVA
      WHERE ID = @ID
    END
    --Validacion para la factura electronica mayor de 12 meses  BVF 05-May-10        
    IF @Mov IN ('Solicitud Credito', 'Analisis Credito', 'Pedido', 'Factura', 'Factura VIU')
      EXEC spValidarMayor12meses @ID,
                                 @Mov,
                                 'VTAS'


    -- VALIDACION PRECIO PROPRE 
    -- || MODIFICADO PARA EL DESARROLLO DM0292 Articulos Q Calzado        
    SELECT
      @Estatus = Estatus,
      @Origen = Origen,
      @OrigenId = OrigenID
    FROM Venta WITH (NOLOCK)
    WHERE ID = @ID
    IF dbo.fnClaveAfectacionMAVI(@Mov, 'VTAS') IN ('VTAS.P')
      AND @Origen IS NULL
      AND @OrigenID IS NULL
      AND @Estatus = 'SINAFECTAR'
    BEGIN
      SELECT
        @Redime = RedimePtos
      FROM Venta WITH (NOLOCK)
      WHERE ID = @ID
      DECLARE crArtPrecio CURSOR LOCAL FORWARD_ONLY FOR
      SELECT
        Renglon,
        D.Articulo,
        Precio,
        D.PrecioAnterior,
        A.Estatus
      FROM VentaD D WITH (NOLOCK)
      LEFT JOIN Art A WITH (NOLOCK)
        ON A.Articulo = D.Articulo
        AND A.Familia = 'Calzado'
        AND A.Estatus = 'Bloqueado'
      WHERE ID = @ID
      OPEN crArtPrecio
      FETCH NEXT FROM crArtPrecio INTO @Renglon, @ArtP, @PrecioArt, @PrecioAnterior, @bloq
      WHILE @@FETCH_STATUS <> -1
        AND @Ok IS NULL
      BEGIN
        IF @@FETCH_STATUS <> -2
          AND NULLIF(@ArtP, '') IS NOT NULL
        BEGIN

          SET @Precio = dbo.fnPropreprecio(@ID, @ArtP, @Renglon, @Redime)
          IF (ISNULL(@PrecioAnterior, @PrecioArt) <> @Precio)
            AND (@bloq <> 'Bloqueado')
            AND (@suc NOT IN (SELECT
              Nombre
            FROM TablaStD WITH (NOLOCK)
            WHERE TablaSt = 'SUCURSALES LINEA')
            )
            SELECT
              @Ok = 20305,
              @OkRef = RTRIM(@ArtP)
        END
        FETCH NEXT FROM crArtPrecio INTO @Renglon, @ArtP, @PrecioArt, @PrecioAnterior, @bloq
      END
      CLOSE crArtPrecio
      DEALLOCATE crArtPrecio
    END

    -- validacion para evitar afectar movs con impuesto1 en 0 cuando son articulos de venta con impuestos. JRD 01-Abr-2013.
    IF (dbo.fnClaveAfectacionMAVI(@Mov, 'VTAS') IN ('VTAS.P')
      AND (SELECT
        Origen
      FROM Venta WITH (NOLOCK)
      WHERE ID = @ID)
      IS NULL
      AND @Ok IS NULL)
    BEGIN
      EXEC spValidaVentaSinImpuestosMAVI @ID,
                                         @Ok OUTPUT,
                                         @OkRef OUTPUT
    END




  END


  -- Validacion en Ventas para no poder cancelar una Factura si tiene una Devolucion de Ventas o En algun Movimiento de embarque. (Juan Mendez 02-Ene-09)          
  IF @Modulo = 'VTAS'
    AND @Accion = 'CANCELAR'
  BEGIN
    SELECT
      @Mov = Mov,
      @Estatus = Estatus,
      @DineroID = IDIngresoMAVI
    FROM Venta WITH (NOLOCK)
    WHERE ID = @ID
    IF EXISTS (SELECT
        VD.ID
      FROM VentaD VD WITH (NOLOCK)
      INNER JOIN Venta V WITH (NOLOCK)
        ON VD.ID = V.ID
      WHERE VD.IDCopiaMavi = @ID
      AND V.Estatus NOT IN ('CANCELADO', 'SINAFECTAR'))
      SELECT
        @Ok = 100000
    IF EXISTS (SELECT
        EM.AsignadoID
      FROM EmbarqueMov EM WITH (NOLOCK)
      INNER JOIN Embarque E WITH (NOLOCK)
        ON EM.AsignadoID = E.ID
      WHERE EM.ModuloID = @ID
      AND EM.Modulo = 'VTAS'
      AND E.Estatus NOT IN ('CANCELADO', 'SINAFECTAR'))
      SELECT
        @Ok = 100000
    IF @Mov IN ('Cancela Credilana', 'Cancela Prestamo')
    BEGIN
      IF EXISTS (SELECT
          ID
        FROM Dinero WITH (NOLOCK)
        WHERE ID = @DineroID
        AND Estatus IN ('PENDIENTE', 'CONCLUIDO'))
        SELECT
          @Ok = 60060
    END
  END

  IF @Modulo = 'CXC'
    AND ISNULL(@Accion, '') IN ('CANCELAR', 'AFECTAR')
    AND ISNULL(@Ok, 0) = 0
    AND EXISTS (SELECT
      ID
    FROM CXC WITH (NOLOCK)
    WHERE ID = @ID
    AND ((Mov IN (SELECT DISTINCT
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
    )
    OR Mov = 'Aplicacion'
    )
    AND Estatus NOT IN ('CANCELADO'))
  BEGIN
    EXEC dbo.SP_MAVIDM0224NotaCreditoEspejo @ID,
                                            @Accion,
                                            @Usuario,
                                            @Ok OUTPUT,
                                            @OkRef OUTPUT,
                                            'ANTES'
  END

  RETURN
  IF EXISTS (SELECT
      *
    FROM TEMPDB.SYS.SYSOBJECTS
    WHERE ID = OBJECT_ID('Tempdb.dbo.#ValidaConceptoGas')
    AND TYPE = 'U')
    DROP TABLE #ValidaConceptoGas

  IF EXISTS (SELECT
      *
    FROM TEMPDB.SYS.SYSOBJECTS
    WHERE ID = OBJECT_ID('Tempdb.dbo.#cobro')
    AND TYPE = 'U')
    DROP TABLE #cobro

  IF EXISTS (SELECT
      *
    FROM TEMPDB.SYS.SYSOBJECTS
    WHERE ID = OBJECT_ID('Tempdb.dbo.#cobroAplica')
    AND TYPE = 'U')
    DROP TABLE #cobroAplica

  IF EXISTS (SELECT
      *
    FROM TEMPDB.SYS.SYSOBJECTS
    WHERE ID = OBJECT_ID('Tempdb.dbo.#temp2')
    AND TYPE = 'U')
    DROP TABLE #temp2
END
GO
