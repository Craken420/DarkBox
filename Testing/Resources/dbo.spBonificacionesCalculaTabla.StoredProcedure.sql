SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
-- ========================================================================================================================================
-- MODIFICACION:
-- NOMBRE			: spBonificacionesCalculaTabla
-- AUTOR			: Jesus Del Toro
-- FECHA			: 11/01/2012
-- DESARROLLO		: DM0172
-- MODULO			: Cxc
-- ULTIMA TEAM			: 29032012 E0923 R1320
-- ULTIMA OFICIAL		: 30032012 V1810 M1811
-- ========================================================================================================================================

-- ========================================================================================================================================  
-- FECHA Y AUTOR MODIFICACION:  10/10/2015  Por: Marco Valdovinos
-- Se hace una correccion poque en el contado comercial no descontaba las nota de creditos hechas a facturas de VIU 
-- ========================================================================================================================================  
-- ========================================================================================================================================  
-- FECHA Y AUTOR MODIFICACION: 06/11/2015  Por: MArco Valdovinos
-- Se hace una modificación para que el calculo de días transcurridos para la bonificacion de contado Comercial se use la fecha de emisión de la factura 
-- y no la de la solcitud. Pero se sigue usando la fecha de la solicitud para determinar si entra dentro de la fecha inicio y fin de la bonificación 
-- ======================================================================================================================================== 

-- ========================================================================================================================================  
-- FECHA Y AUTOR MODIFICACION:  30/12/2015  Por: MArco Valdovinos
-- Se quitan los cursores y se sustituyen  por una tabla temporal para recorrerla
-- ========================================================================================================================================   


CREATE PROCEDURE [dbo].[spBonificacionesCalculaTabla]  @IdCxC    Int,
  @Estacion int = 1,
  @Tipo     char(10),
  @IdCobro  int 
  
AS 
BEGIN
  DECLARE
----- 1. Declara
  @Empresa          VarChar(5),
  @Mov              VarChar(20),
  @MovId            VarChar(20),
  @FechaEmision     Datetime,
  @Concepto         VarChar(50),
  @UEN              int,
  @TipoCambio       float,
  @ClienteEnviarA   int,
  @Condicion        VarChar(50),
  @Vencimiento      Datetime,
  @ImporteVenta     float,
  @ImporteDocto     float,
  @ImporteCasca     float,
  @Impuestos        float,
  @Saldo            float,     
  @Referencia       varchar(50),
  @Documento1de     Int,
  @DocumentoTotal   Int, 
  @OrigenTipo       varchar(20),   
  @Origen           varchar(20),   
  @OrigenId         varchar(20),
  @Sucursal         int,
  @TipoSucursal     varchar(50),
  @ExtraeD          Int,
  @ExtraeA          Int,
  @IdVenta          int, 
  @MovIdVenta       varchar(20),
  @MovVenta         varchar(20),
  @LineaVta         varchar(50),
  @MaxDiasAtrazo    float,
  @DiasMenoresA       Int,
  @DiasMayoresA       Int,
------  	Factura AAA6 (12/13)
  @Id                int,
  @Bonificacion      varchar(50),
  @Estatus           varchar(15),
  @PorcBon1          float,
  @MontoBonif        Float, 
  @Financiamiento    float,
  @FechaIni          datetime,
  @FechaFin          datetime,
  @PagoTotal         bit,
  @ActVigencia       bit,
  @CascadaCalc       bit,
  @AplicaA           Char(30),
  @PlazoEjeFin       int, 
  @VAlBonif          Float,
  @VencimientoAntes  Int,
  @VencimientoDesp   Int,
  @DiasAtrazo        Int,
  @Factor            float,
  @MesesExced        int,
  @Linea             Float,
  @FechaCancelacion  datetime,
  @FechaRegistro     datetime,
  @Usuario           Varchar(10),
  @Ok                int, 
  @OkRef             Varchar(50),
  @Periodo           int,
  @CharReferencia    Varchar(20),
  @Ejercicio         Int,
  @BonificHijo       Varchar(50),
  @BonificHijoCascad Varchar(5),
  @Refinan           Varchar(5),
  @LineaCelulares    Float,
  @DiasVencimiento   int,
  @LineaCredilanas   Float,
  @BaseParaAplicar   Float
  ,@PadreMavi            varchar(20)  
  ,@PadreMaviID          varchar(20),
  @EsOrigenNulo		 int -- Variable bandera para identificar cuando Origen es Nulo, lo que indica saldo inicial GRB 24/07/10  
  ,@LineaMotos Float
  ,@LineaBonif VARCHAR(25)
  /**/,  @FechaEmisionFact     Datetime


----- 2. Inicializa
      SELECT @OkRef = '', @Ejercicio = year(getdate()), @Periodo = Month(getdate()), @MaxDiasAtrazo = 0.00, @Mov = '',@DiasMenoresA=0, @DiasMayoresA=0
      SELECT @CharReferencia= 0 , @ImporteVenta = 0.00, @ImporteDocto = 0.00, @MesesExced=0, @ImporteCasca = 0.00, @BaseParaAplicar = 0.00,@EsOrigenNulo=0
      IF @IdCobro = NULL SELECT @IdCobro= 0

----- 3. CargaCxC
-- Insertamos codigo para obtener MaxDiasVencidosMAVI de CXCMAVI GRB 23/07/10
  SELECT @Empresa=c.Empresa,@Mov=c.Mov,@MovId=c.MovId, @FechaEmision=c.FechaEmision,@Concepto=c.Concepto,@UEN=c.UEN, /**/@FechaEmisionFact = c.fechaemision ,
    @TipoCambio=c.TipoCambio,@ClienteEnviarA=c.ClienteEnviarA,@Condicion=c.Condicion,@Vencimiento=c.Vencimiento,@ImporteDocto=c.Importe+c.Impuestos,
    @Impuestos=c.Impuestos,@Saldo=c.Saldo,@Vencimiento=c.Vencimiento,@Concepto=c.Concepto,@Referencia=isnull(c.ReferenciaMAvi,c.Referencia),
    @OrigenTipo=c.OrigenTipo,@Origen=c.Origen, @OrigenId=c.OrigenId,@Sucursal=c.SucursalOrigen,@MaxDiasAtrazo=isnull(cm.MaxDiasVencidosMAVI,0.00)
      ,@PadreMavi = c.PadreMAVI, @PadreMaviID = c.PadreIDMAVI
	FROM CXC c WITH(NOLOCK)
	LEFT JOIN CXCMAVI cm WITH(NOLOCK) on cm.id=c.id
	WHERE c.Id = @IdCxC

  IF @origen is null 
  begin 

-- Insertamos codigo para obtener MaxDiasVencidosMAVI de CXCMAVI GRB 23/07/10  	
      SELECT @Empresa=c.Empresa,@Mov=c.Mov,@MovId=c.MovId, @FechaEmision=c.FechaEmision,@Concepto=c.Concepto,@UEN=c.UEN,
        @TipoCambio=c.TipoCambio,@ClienteEnviarA=c.ClienteEnviarA,@Condicion=c.Condicion,@Vencimiento=c.Vencimiento,@ImporteDocto=c.Importe+c.Impuestos,
        @Impuestos=c.Impuestos,@Saldo=c.Saldo,@Vencimiento=c.Vencimiento,@Concepto=c.Concepto,@Referencia=isnull(c.ReferenciaMAvi,c.Referencia),
        @OrigenTipo=c.OrigenTipo,@Origen=c.Origen, @OrigenId=c.OrigenId,@Sucursal=c.SucursalOrigen,@MaxDiasAtrazo=isnull(cm.MaxDiasVencidosMAVI,0.00)
      FROM CXC c WITH(NOLOCK)
      LEFT JOIN CXCMAVI cm WITH(NOLOCK) on cm.id=c.id 
      WHERE c.Mov = @Mov AND c.Movid = @MovId
	
      Select @Origen = @Mov , @OrigenId = @MovId
      -- Indicamos que Origen es NULO GRB 24/07/10
      Select @EsOrigenNulo=1 

      SELECT top(1)@LineaVta = Linea, @ImporteVenta = PrecioToTal, @Sucursal = SucursalVenta
        FROM BonifSIMAVI WITH(NOLOCK) WHERE IDCxc = @idcxc
  end 
  
  DELETE MaviBonificacionTest WHERE Origen= @PadreMavi AND OrigenId = @PadreMaviID 
  
  --Se agrego el order by para regresar siempre el valor correcto. GRB 24/07/10
  IF @Referencia IS NULL OR rtrim(@Referencia)= '' OR NOT @Referencia LIKE '%/%'
  Begin 
--*** Se agrego orden para tomar el docto mas chico. JR 14-Nov-2011. ***
	 SELECT TOP (1) @Referencia=Referencia FROM Cxc WITH(NOLOCK) WHERE PadreMavi = @Mov AND PadreIDMAVI = @MovID and Mov = 'Documento' ORDER BY MovID  
   End
  IF patindex('%/%',@Referencia) > 0  
  BEGIN
    SELECT @ExtraeD = patindex('%(%',@Referencia), @ExtraeA = patindex('%/%',@Referencia)
	SELECT @Documento1de = substring(@Referencia,@ExtraeD+1,@ExtraeA - @ExtraeD -1) 
    SELECT @ExtraeD = patindex('%/%',@Referencia), @ExtraeA = patindex('%)%',@Referencia)
    SELECT @DocumentoTotal = substring(@Referencia,@ExtraeD+1,@ExtraeA - @ExtraeD -1)
  END
  
    --- Grales del documento
    ---LineadeVenta
      EXEC spMAviBuscaCxCVentaBonif @MovID,@Mov, @MovIdVenta output , @MovVenta output, @IdVenta output 
      
      ----  Saldos 
     if @importeventa is null 
      SELECT top(1)@LineaVta = Linea, @ImporteVenta = PrecioToTal, @Sucursal = SucursalVenta
        FROM BonifSIMAVI WITH(NOLOCK) WHERE IDCxc = @IdVenta

      IF @Mov LIKE '%Refinan%' SELECT @Refinan='Ok',@ImporteVenta = Importe+Impuestos FROM Cxc WITH(NOLOCK) WHERE Mov=@Mov AND MovID=@MovID
      
      IF @Refinan is NULL OR @LineaVta Is null 
      BEGIN 
        SELECT @LineaVta = isnull(A.Linea,'') FROM venta WITH(NOLOCK),ventad WITH(NOLOCK) 
          LEFT OUTER JOIN Art a WITH(NOLOCK) ON a.Articulo = ventad.Articulo
          WHERE venta.id = ventad.id 
          AND venta.id = @IdVenta 

        --- Importe de Venta y Sucursal
        IF @ImporteVenta IS NULL  or @ImporteVenta =0
          SELECT @ImporteVenta = PrecioToTal FROM Venta WITH(NOLOCK) WHERE Id = @IdVenta  
      END ELSE
      BEGIN  
      	 SELECT @Sucursal=39, @LineaVta = ''                         ---  Ventas Refinanciamiento I GArcia 29  Junio
      	 SELECT @ImporteVenta = Importe FROM Cxc WITH(NOLOCK) WHERE id = @IdVenta
      END

      ---Sucursal Tipo
        SELECT @TipoSucursal=SucursalTipo.Tipo FROM Sucursal WITH(NOLOCK), SucursalTipo WITH(NOLOCK) WHERE Sucursal.Tipo = SucursalTipo.Tipo 
          AND Sucursal.Sucursal=@Sucursal
     
     -- Se Busca la fecha de la Solicitud Credito
		IF EXISTS ( SELECT 
						SolC.FechaEmision
					FROM Venta Fac WITH(NOLOCK)
					INNER JOIN Venta Ped WITH(NOLOCK) ON Fac.Origen = Ped.Mov AND Fac.OrigenID = Ped.MovID
					INNER JOIN Venta AnaC WITH(NOLOCK) ON Ped.Origen = AnaC.Mov AND Ped.OrigenID = AnaC.MovID
					INNER JOIN Venta SolC WITH(NOLOCK) ON AnaC.Origen = SolC.Mov AND AnaC.OrigenID = SolC.MovID
					WHERE Fac.Mov = @Mov AND Fac.MovID = @MovID)
		BEGIN
			SELECT 
				@FechaEmision = SolC.FechaEmision
			FROM Venta Fac WITH(NOLOCK)
			INNER JOIN Venta Ped WITH(NOLOCK) ON Fac.Origen = Ped.Mov AND Fac.OrigenID = Ped.MovID
			INNER JOIN Venta AnaC WITH(NOLOCK) ON Ped.Origen = AnaC.Mov AND Ped.OrigenID = AnaC.MovID
			INNER JOIN Venta SolC WITH(NOLOCK) ON AnaC.Origen = SolC.Mov AND AnaC.OrigenID = SolC.MovID
			WHERE Fac.Mov = @Mov AND Fac.MovID = @MovID
		END
     
		SELECT
			@ImporteVenta = (((Doc.Importe+Doc.Impuestos))-ISNULL(Mon.Abono,0))
		FROM dbo.Cxc Doc WITH(NOLOCK)
		LEFT JOIN dbo.Condicion Con WITH(NOLOCK) ON Con.Condicion=Doc.Condicion
		LEFT JOIN dbo.AuxiliarP Mon WITH(NOLOCK) ON Mon.Mov=Doc.Mov AND Mon.MovID=Doc.MovID AND ISNULL(Mon.Abono,0)>0
		WHERE Doc.Mov=@Mov AND Doc.MovID=@MovID


----- 4. CargaBonificaciones Vigentes
--===========================================================================================================================================

	 IF EXISTS(SELECT * FROM tempdb.sys.sysobjects WHERE id=OBJECT_ID('tempdb.dbo.#CrBonifAplicar') AND TYPE ='U')
	  DROP TABLE #CrBonifAplicar  

	  CREATE TABLE #CrBonifAplicar (reg int identity, Id int,  Bonificacion varchar(100),PorcBon1 float NULL, Financiamiento float NULL,  FechaIni datetime,FechaFin datetime, PagoTotal bit , ActVigencia bit
					 ,AplicaA varchar(30) NULL , PlazoEjeFin int,VencimientoAntes int NULL,VencimientoDesp int NULL ,DiasAtrazo int NULL,DiasMenoresA int NULL, DiasMayoresA int NULL ,
					  Factor float NULL ,Linea float NULL , FechaCancelacion datetime NULL,FechaRegistro datetime NULL ,Usuario varchar(10) NULL ,LineaBonif varchar(50)  NULL)
	  
	  
	  IF @Tipo = 'Total' 
      BEGIN   
             
			  INSERT INTO #CrBonifAplicar (Id ,  Bonificacion ,PorcBon1 , Financiamiento ,  FechaIni ,FechaFin , PagoTotal , ActVigencia ,AplicaA , PlazoEjeFin ,VencimientoAntes 
			  ,VencimientoDesp ,DiasAtrazo ,DiasMenoresA , DiasMayoresA , Factor ,Linea , FechaCancelacion ,FechaRegistro ,Usuario ,LineaBonif )
			  SELECT  mbc.Id,  mbc.Bonificacion,mbc.PorcBon1,mbc.Financiamiento, mbc.FechaIni,mbc.FechaFin,mbc.PagoTotal,mbc.ActVigencia
					 ,mbc.AplicaA,mbc.PlazoEjeFin,VencimientoAntes=isnull(mbc.VencimientoAntes,0),VencimientoDesp=isnull(mbc.VencimientoDesp,0)
					 ,DiasAtrazo=isnull(mbc.DiasAtrazo,0),DiasMenoresA=isnull(mbc.DiasMenoresA,0),DiasMayoresA=isnull(mbc.DiasMayoresA,0),
					  mbc.Factor,Linea=isnull(mbc.Linea,0.00),mbc.FechaCancelacion,mbc.FechaRegistro,mbc.Usuario,mbl.Linea 
			  FROM MaviBonificacionConf mbc WITH(NOLOCK)
			  INNER JOIN MaviBonificacionMoV mbmv WITH(NOLOCK) ON mbc.Id = mbmv.IdBonificacion
			  INNER JOIN dbo.MaviBonificacionCondicion mbc2 WITH(NOLOCK) ON mbc2.IdBonificacion=mbc.ID
			  LEFT JOIN dbo.MaviBonificacionLinea mbl WITH(NOLOCK) ON mbl.IdBonificacion=mbc.ID
			  WHERE mbmv.Movimiento = @Mov
			  AND COndicion = @Condicion
			  AND mbc.Estatus = 'CONCLUIDO'    ----- Quitar en Produccion
			  AND @FechaEmision BETWEEN mbc.FechaIni AND mbc.FechaFin
			  AND mbc.NoPuedeAplicarSola = 0
			  ORDER BY mbc.Orden DESC
			  
--===========================================================================================================================================
      END    
      ELSE
      BEGIN  
	    
           INSERT INTO #CrBonifAplicar (Id ,  Bonificacion ,PorcBon1 , Financiamiento ,  FechaIni ,FechaFin , PagoTotal , ActVigencia ,AplicaA , PlazoEjeFin ,VencimientoAntes 
			  ,VencimientoDesp ,DiasAtrazo ,DiasMenoresA , DiasMayoresA , Factor ,Linea , FechaCancelacion ,FechaRegistro ,Usuario ,LineaBonif )
          SELECT  mbc.Id,  mbc.Bonificacion,mbc.PorcBon1,mbc.Financiamiento, mbc.FechaIni,mbc.FechaFin,mbc.PagoTotal,mbc.ActVigencia,mbc.AplicaA,mbc.PlazoEjeFin,
                  isnull(mbc.VencimientoAntes,0), isnull(mbc.VencimientoDesp,0),
                  isnull(mbc.DiasAtrazo,0),isnull(mbc.DiasMenoresA,0),isnull(mbc.DiasMayoresA,0),
				  mbc.Factor,isnull(mbc.Linea,0.00),mbc.FechaCancelacion,mbc.FechaRegistro,mbc.Usuario,NULL
          FROM MaviBonificacionConf mbc WITH(NOLOCK)
          INNER JOIN MaviBonificacionMoV mbmv WITH(NOLOCK) ON mbc.Id = mbmv.IdBonificacion
          INNER JOIN dbo.MaviBonificacionCondicion mbc2 WITH(NOLOCK) ON mbc2.IdBonificacion=mbc.ID
          WHERE mbmv.Movimiento = @Mov
          AND COndicion = @Condicion
          AND mbc.Estatus = 'CONCLUIDO'    ----- Quitar en Produccion
          AND @FechaEmision BETWEEN mbc.FechaIni AND mbc.FechaFin
          AND mbc.NoPuedeAplicarSola = 0 
          AND NOT mbc.Bonificacion LIKE '%Contado Comercial%'
          ORDER BY mbc.Orden Desc
      END

  

	DECLARE @totbonifs int, @recorre int , @tincluye int,@avanza  int 
	Select @totbonifs = MAX(reg) , @recorre = 1
	From #CrBonifAplicar

	WHILE  @recorre <= @totbonifs  -- W1
	BEGIN
    	    SELECT @Ok = NULL, @OkRef = NULL ,
			  @Id=Id, @Bonificacion = Bonificacion ,@PorcBon1 = PorcBon1 ,@Financiamiento = Financiamiento ,@FechaIni = FechaIni  ,@FechaFin = FechaFin,@PagoTotal = PagoTotal
			  ,@ActVigencia = ActVigencia ,@AplicaA = AplicaA,@PlazoEjeFin = PlazoEjeFin, @VencimientoAntes = VencimientoAntes, @VencimientoDesp = VencimientoDesp, 
			   @DiasAtrazo = DiasAtrazo, @DiasMenoresA = DiasMenoresA, @DiasMayoresA = DiasMayoresA, @Factor = Factor ,@Linea = Linea,@FechaCancelacion = FechaCancelacion
			   ,@FechaRegistro = FechaRegistro ,@Usuario = Usuario ,@LineaBonif = LineaBonif
			 FROM #CrBonifAplicar 
			 where reg = @recorre


------------------------------------------------------------------------------------------------------------------------------------------------------------
    	 
		  DECLARE @LineaVentaBonif VARCHAR(50)
    	  
    	  SELECT TOP 1 @LineaVentaBonif = ISNULL(Linea,@LineaVta)
			FROM BonifSIMAVI WITH(NOLOCK)
				 WHERE IDCxc = @IdVenta AND Linea IN (SELECT mbl.Linea
														FROM MaviBonificacionConf mbc WITH(NOLOCK)
														INNER JOIN MaviBonificacionMoV mbmv WITH(NOLOCK) ON mbc.Id = mbmv.IdBonificacion
														INNER JOIN MaviBonificacionCondicion mbc2 WITH(NOLOCK) ON mbc2.IdBonificacion=mbc.ID
														LEFT JOIN MaviBonificacionLinea mbl WITH(NOLOCK) ON ID=mbl.IdBonificacion
														WHERE mbmv.Movimiento = @Mov
														AND COndicion = @Condicion
														AND mbc.Estatus = 'CONCLUIDO'
														AND @FechaEmision BETWEEN mbc.FechaIni AND mbc.FechaFin
														AND mbc.NoPuedeAplicarSola = 0
														AND Bonificacion LIKE '%Contado Comercial%'
														)
    	  
    	  SELECT @LineaVentaBonif = ISNULL(A.Linea,@LineaVta) FROM venta WITH(NOLOCK),ventad WITH(NOLOCK) 
          LEFT OUTER JOIN Art a WITH(NOLOCK) ON a.Articulo = ventad.Articulo
          WHERE venta.id = ventad.id 
          AND venta.id = @IdVenta 
          AND A.Linea IN (SELECT mbl.Linea
							FROM MaviBonificacionConf mbc WITH(NOLOCK)
							INNER JOIN MaviBonificacionMoV mbmv WITH(NOLOCK) ON mbc.Id = mbmv.IdBonificacion
							INNER JOIN MaviBonificacionCondicion mbc2 WITH(NOLOCK) ON mbc2.IdBonificacion=mbc.ID
							LEFT JOIN MaviBonificacionLinea mbl WITH(NOLOCK) ON ID=mbl.IdBonificacion
							WHERE mbmv.Movimiento = @Mov
							AND COndicion = @Condicion
							AND mbc.Estatus = 'CONCLUIDO'
							AND @FechaEmision BETWEEN mbc.FechaIni AND mbc.FechaFin
							AND mbc.NoPuedeAplicarSola = 0
							AND Bonificacion LIKE '%Contado Comercial%')
    	  SELECT @LineaVentaBonif = ISNULL(@LineaVentaBonif,@LineaVta)
    	  SELECT @LineaVta=@LineaVentaBonif
    	  
    	  IF @LineaVentaBonif IN (SELECT mbl.Linea
							FROM MaviBonificacionConf mbc WITH(NOLOCK)
							INNER JOIN MaviBonificacionMoV mbmv WITH(NOLOCK) ON mbc.Id = mbmv.IdBonificacion
							INNER JOIN MaviBonificacionCondicion mbc2 WITH(NOLOCK) ON mbc2.IdBonificacion=mbc.ID
							LEFT JOIN MaviBonificacionLinea mbl WITH(NOLOCK) ON ID=mbl.IdBonificacion
							WHERE mbmv.Movimiento = @Mov
							AND COndicion = @Condicion
							AND mbc.Estatus = 'CONCLUIDO'
							AND @FechaEmision BETWEEN mbc.FechaIni AND mbc.FechaFin
							AND mbc.NoPuedeAplicarSola = 0
							AND Bonificacion LIKE '%Contado Comercial%') AND @Bonificacion LIKE '%Contado Comercial%'
			BEGIN
				IF ISNULL(@LineaBonif,'')<>'' AND ISNULL(@LineaVentaBonif,'')<>'' AND @Bonificacion LIKE '%Contado Comercial%'
    			BEGIN
    				IF @LineaBonif = @LineaVentaBonif
    					SELECT @Ok = NULL, @OkRef = NULL
    			END
    			ELSE SELECT @Ok = 1, @OkRef = 'No cumple con el parametro linea para esta bonificacion'
			END
    	  ELSE IF ISNULL(@LineaBonif,'')='' AND ISNULL(@LineaVentaBonif,'')<>'' AND @Bonificacion LIKE '%Contado Comercial%' 
    		BEGIN
    			IF EXISTS(SELECT Bonificacion FROM dbo.MaviBonificacionTest WITH(NOLOCK) WHERE Bonificacion=@Bonificacion AND Ok=0 AND IdCobro=@IdCobro)
    				SELECT @Ok = 1, @OkRef = 'No cumple con el parametro de la linea para esta bonificacion'
    			ELSE
    				SELECT @Ok = NULL, @OkRef = NULL
    		END
    		ELSE IF @Bonificacion LIKE '%Contado Comercial%' 
    			SELECT @Ok = 1, @OkRef = 'No cumple con el parametro de la linea para esta bonificacion'

		  SELECT @LineaBonif=''
		  
		  IF @Bonificacion LIKE '%Adelanto%' AND @LineaVta<>@LineaBonif AND @Tipo = 'Total'
			 AND EXISTS (SELECT * FROM MaviBonificacionTest WITH(NOLOCK) WHERE IdCobro=@IdCobro AND Ok=0 AND Bonificacion=@Bonificacion)
				SELECT @Ok = 1, @OkRef = 'No cumple con el parametro de la linea para esta bonificacion'
				
------------------------------------------------------------------------------------------------------------------------------------------------------------
		/**/--aqui  modifico para que en esta validacion de días trasncurridos sena en base  a la fecha de emision de la factura y no de la Soclicitud 06/11/2015  Marco Valdovinos
		  IF @Tipo = 'Total' AND @Bonificacion NOT LIKE '%Adelanto%' 
			 AND EXISTS (SELECT IdBonificacion FROM MaviBonificacionExcluye WITH(NOLOCK) WHERE BonificacionNo=@Bonificacion 
					        AND IdBonificacion IN (
					        SELECT ID FROM (
								SELECT mbc.ID
										,Ok=CASE WHEN @EsOrigenNulo = 0 
											THEN
												CASE WHEN dbo.fnFechaSinHora(GETDATE()) >= dbo.fnFechaSinHora((Select c.Vencimiento+1 FROM Cxc c WITH(NOLOCK) WHERE c.Origen = @Origen AND c.OrigenID = @OrigenId AND c.Referencia LIKE '%' + '(' + rtrim(mbc.VencimientoAntes) + '/' + rtrim(@DocumentoTotal) + '%'))
													 THEN 1 ELSE 0 END
											ELSE 
												CASE WHEN dbo.fnFechaSinHora(GETDATE()) > dbo.fnFechaSinHora(ISNULL((Select c.Vencimiento FROM Cxc c WITH(NOLOCK) WHERE c.Origen = @Origen AND c.OrigenID = @OrigenId 
																								AND c.Referencia LIKE '%' + '(' + rtrim(mbc.VencimientoAntes) + '/' + rtrim(@DocumentoTotal) + '%'), 
																							(CASE WHEN mbc.VencimientoAntes=1 THEN @Vencimiento 
																								 WHEN mbc.VencimientoAntes>1 THEN  DATEADD(mm, (mbc.VencimientoAntes - @Documento1de), (SELECT Vencimiento FROM CxC WITH(NOLOCK) WHERE Origen=@Origen AND OrigenID=@OrigenId AND Referencia=@Referencia) ) END ) )   ) 
												 THEN 1 ELSE 0 END
										END,
										DiasAtrazo=CASE WHEN @MaxDiasAtrazo > mbc.DiasAtrazo AND mbc.DiasAtrazo <> 0 THEN 1 ELSE 0 END,
										DiasMenoresA=CASE WHEN @Condicion LIKE '%PP%' AND mbc.DiasMenoresA <> 0 THEN 
														/**/	CASE WHEN mbc.DiasMenoresA < datediff(day,@FechaEmisionFact,getdate()) THEN 1 ELSE 0 END
														  WHEN @Condicion LIKE '%DIF%' AND mbc.DiasMenoresA <> 0 THEN
														/**/	CASE WHEN mbc.DiasMenoresA < DATEDIFF(DAY, @FechaEmisionFact, getdate()) THEN 1 ELSE 0 END
													 ELSE 0 END,
										DiasMayoresA=CASE WHEN @Condicion LIKE '%PP%' AND mbc.DiasMayoresA <> 0 THEN
														/**/	CASE WHEN mbc.DiasMayoresA >= datediff(dd,@FechaEmisionFact,@Vencimiento) THEN 1 ELSE 0 END
														  WHEN @Condicion LIKE '%DIF%' AND mbc.DiasMayoresA <> 0 THEN
														/**/	CASE WHEN mbc.DiasMayoresA <= DATEDIFF(DAY, @FechaEmisionFact, getdate()) THEN 1 ELSE 0 END
													 ELSE 0 END
								FROM MaviBonificacionConf mbc WITH(NOLOCK)
									INNER JOIN MaviBonificacionMoV mbmv WITH(NOLOCK) ON mbc.Id = mbmv.IdBonificacion
									INNER JOIN MaviBonificacionCondicion mbc2 WITH(NOLOCK) ON mbc2.IdBonificacion=mbc.ID
									LEFT JOIN MaviBonificacionLinea mbl WITH(NOLOCK) ON ID=mbl.IdBonificacion
								WHERE mbmv.Movimiento = @Mov
									AND COndicion = @Condicion
									AND mbc.Estatus = 'CONCLUIDO'
									AND @FechaEmision BETWEEN mbc.FechaIni AND mbc.FechaFin
									AND mbc.NoPuedeAplicarSola = 0
									AND Bonificacion = 'Bonificacion Contado Comercial'
							)Cont WHERE Ok = 0 AND DiasAtrazo = 0 AND DiasMenoresA = 0 AND DiasMayoresA = 0 ) ) 
					SELECT @Ok = 1, @OkRef = 'Se excluye esta bonificacion por otra'

------------------------------------------------------------------------------------------------------------------------------------------------------------
    			
          IF @VencimientoAntes <> 0 AND @Bonificacion not LIKE '%Adelanto%' AND @Tipo = 'Total'
          BEGIN   
            SET @CharReferencia = '(' + rtrim(@VencimientoAntes) + '/' + rtrim(@DocumentoTotal)
            IF @EsOrigenNulo=0
            Begin                                 
				IF dbo.fnFechaSinHora(GETDATE())  >=  dbo.fnFechaSinHora((Select c.Vencimiento+1 FROM Cxc c WITH(NOLOCK) WHERE c.Origen = @Origen AND c.OrigenID = @OrigenId AND c.Referencia LIKE '%' + @CharReferencia + '%'))  
					SELECT @Ok=1, @OkRef = 'No cumple con el límite de pago posterior1'
			END		
			ELSE
			Begin
				-- **** Modificacion de validacion para que considere el vencimiento antes del no. docto establecido en la config. JR 14-Nov-2011 ****
				IF ( dbo.fnFechaSinHora(getdate()) > dbo.fnFechaSinHora(ISNULL((Select c.Vencimiento FROM Cxc c WITH(NOLOCK) WHERE c.Origen = @Origen AND c.OrigenID = @OrigenId 
																					AND c.Referencia LIKE '%' + @CharReferencia + '%'), 
																				(CASE WHEN @VencimientoAntes=1 THEN @Vencimiento 
																					 WHEN @VencimientoAntes>1 THEN  DATEADD(mm, (@VencimientoAntes - @Documento1de), (SELECT Vencimiento FROM CxC WITH(NOLOCK) WHERE Origen=@Origen AND OrigenID=@OrigenId AND Referencia=@Referencia) ) END ) )   ) ) 
					SELECT @Ok=1, @OkRef = 'No cumple con el límite de pago posterior1'    
            END
            
          END  
          IF @VencimientoAntes <> 0 AND @Bonificacion LIKE '%Adelanto%' AND @Tipo = 'Total'
          BEGIN    
            SET @CharReferencia = '(' + rtrim(@VencimientoAntes) + '/' + rtrim(@DocumentoTotal)                 
            IF dbo.fnFechaSinHora(GETDATE())  >=  dbo.fnFechaSinHora((Select c.Vencimiento + 1 FROM Cxc c WITH(NOLOCK) WHERE c.Origen = @Origen AND c.OrigenID = @OrigenId AND c.Referencia LIKE '%' + @CharReferencia + '%'))  
                SELECT @Ok=1, @OkRef = 'No cumple con el límite de pago posterior1'    
            
          END  

          -- **** Nueva validacion para que genere bonificacion x adelanto si ha pasado el no. de docto especificado en vencimientodesp en la config. JR 14-Nov-2011 ****
          IF @VencimientoDesp <> 0 AND @Bonificacion LIKE '%Adelanto%' AND @Tipo = 'Total'
          BEGIN    
            SET @CharReferencia = '(' + rtrim(@VencimientoDesp) + '/' + rtrim(@DocumentoTotal)                 
            IF (dbo.fnFechaSinHora(GETDATE()) <=  
				dbo.fnFechaSinHora(ISNULL((Select c.Vencimiento FROM Cxc c WITH(NOLOCK) WHERE c.Origen = @Origen AND c.OrigenID = @OrigenId 
												AND c.Referencia LIKE '%' + @CharReferencia + '%'), 
											(CASE WHEN @VencimientoDesp=1 THEN @Vencimiento 
												 WHEN @VencimientoDesp>1 THEN  DATEADD(mm, (@VencimientoDesp - @Documento1de), (SELECT Vencimiento FROM CxC WITH(NOLOCK) WHERE Origen=@Origen AND OrigenID=@OrigenId AND Referencia=@Referencia) ) END ) )   ) ) 
                SELECT @Ok=1, @OkRef = 'No cumple con el límite de pago posterior1'    
            
          END  

          -- 5.2 Dias Atrazo  
          IF @DiasAtrazo <> 0 AND @Bonificacion LIKE '%Contado Comercial%'
          BEGIN
            IF @MaxDiasAtrazo > @DiasAtrazo SELECT @Ok=1, @OkRef = 'Excede el número de dias de atraso permitidos ' 	 
          END

           ---5.3 Dias de ADelanto   --- Pronto Pago 
          IF @DiasMenoresA <> 0 AND @Bonificacion LIKE '%Contado Comercial%' AND @Condicion LIKE '%PP%'
          BEGIN
          -- Modificamos validacion para opcion PP
		  -- Se modifica para que calcules los días tranascurridos a partir de la fecha de emsion de la factura 06/11/2015
			IF @DiasMenoresA < datediff(day,/**/@FechaEmisionFact,getdate()) SELECT @Ok=1, @OkRef = 'Excede días menores' 

          END
          -- 5.3 Dias de Mayores
          IF @DiasMayoresA <> 0 AND @Bonificacion LIKE '%Contado Comercial%' AND @Condicion LIKE '%PP%'
          BEGIN
			-- Se modifica para que calcules los días tranascurridos a partir de la fecha de emsion de la factura 06/11/2015
            IF @DiasMayoresA >= datediff(dd,/**/@FechaEmisionFact,@Vencimiento) SELECT @Ok=1, @OkRef = 'Excede dias mayores' 
          END

           ----5.3 Dias de ADelanto   --- Pronto Pago 
          IF @DiasMenoresA <> 0 AND @Bonificacion LIKE '%Contado Comercial%' AND @Condicion LIKE '%DIF%'
          BEGIN
				-- Se modifica para que calcules los días transcurridos a partir de la fecha de emsion de la factura 06/11/2015
				IF @DiasMenoresA < DATEDIFF(DAY,/**/@FechaEmisionFact, getdate() )
          	      SELECT @Ok=1, @OkRef = 'Excede días menores'  + CONVERT (char(30),@DiasMenoresA)				
          END
           ----5.3 Dias de Mayores
          IF @DiasMayoresA <> 0 AND @Bonificacion LIKE '%Contado Comercial%' AND @Condicion LIKE '%DIF%'
          BEGIN
		   -- Se modifica para que calcules los días transcurridos a partir de la fecha de emsion de la factura 06/11/2015
          	IF getdate() >= (/**/@FechaEmisionFact + @DiasMayoresA)
          	      SELECT @Ok=1, @OkRef = 'Excede días mayores'  + CONVERT (char(30),@DiasMayoresA)
          END

          -- 5.3 Dias de ADelanto

                    ------   Test5
          --- 6.1 Lineas Art
           IF @PorcBon1 = 0 AND @Linea <> 0 SELECT @PorcBon1 = @Linea
            IF @Linea < (SELECT isnull(PorcLin,0.00) FROM MaviBonificacionLinea WITH(NOLOCK) WHERE IdBonificacion=@id AND Linea = @LineaVta) 
                SELECT @Linea = (SELECT isnull(PorcLin,0.00) FROM MaviBonificacionLinea WITH(NOLOCK) WHERE IdBonificacion=@id AND Linea = @LineaVta) 

            SELECT @LineaCelulares=isnull(PorcLin,0.00) FROM MaviBonificacionLinea mbl WITH(NOLOCK) WHERE Linea LIKE '%Credilana%' AND IdBonificacion = @Id
            SELECT @LineaCredilanas=isnull(PorcLin,0.00) FROM MaviBonificacionLinea mbl WITH(NOLOCK) WHERE Linea LIKE '%Celular%' AND IdBonificacion = @Id
            --Je.deltoro--
            SELECT @LineaMotos=isnull(PorcLin,0.00) FROM MaviBonificacionLinea mbl WITH(NOLOCK)
            INNER JOIN MaviBonificacionCondicion Mbc WITH(NOLOCK) ON Mbc.IdBonificacion=mbl.IdBonificacion
			WHERE Mbc.COndicion=@Condicion AND @Bonificacion LIKE '%Contado Comercial%'
				  AND Mbl.IdBonificacion = @Id AND Linea=@LineaBonif
            
          --- 6.2 Canal Ventas
            IF EXISTS(SELECT IdBonificacion FROM MaviBonificacionCanalVta BonCan WITH(NOLOCK) WHERE BonCan.IdBonificacion=@id)
            BEGIN  
              IF NOT EXISTS(SELECT IdBonificacion FROM MaviBonificacionCanalVta BonCan WITH(NOLOCK) WHERE CONVERT(varchar(10),BonCan.CanalVenta)=@ClienteEnviarA AND BonCan.IdBonificacion=@id)
                 SELECT @Ok=1, @OkRef = 'Venta de Canal No Configurada Para esta Bonificación'             
            END 
          --- 6.3 UEN's
            IF EXISTS(SELECT IdBonificacion FROM MaviBonificacionUEN mbu WITH(NOLOCK) WHERE mbu.idBonificacion=@Id)
            BEGIN  
              IF NOT @UEN is NULL AND NOT EXISTS(SELECT IdBonificacion FROM MaviBonificacionUEN mbu WITH(NOLOCK) WHERE mbu.UEN = @UEN AND mbu.idBonificacion=@Id)
                 SELECT @Ok=1, @OkRef = 'UEN No Configurada Para este Caso' 
            END
          --- 6.4 Condicion
            IF EXISTS(SELECT IdBonificacion FROM MaviBonificacionCondicion WITH(NOLOCK) WHERE IdBonificacion=@Id)
            BEGIN              
              IF NOT EXISTS(SELECT IdBonificacion FROM MaviBonificacionCondicion WITH(NOLOCK) WHERE COndicion=@Condicion AND IdBonificacion=@Id)
                 SELECT @Ok=1, @OkRef = 'Condicion No Configurada Para esta Bonificación' 
            END
          --- 6.5 Bonif Exclu
            IF EXISTS(SELECT IdBonificacion FROM MaviBonificacionExcluye Exc WITH(NOLOCK) WHERE BonificacionNo=@Bonificacion)
            BEGIN              
              IF EXISTS(SELECT BonTest.IdBonificacion FROM MaviBonificacionTest BonTest WITH(NOLOCK), MaviBonificacionExcluye Exc WITH(NOLOCK)
                WHERE Bontest.IdBonificacion = Exc.IdBonificacion
                AND Bontest.OkRef = '' AND Exc.BonificacionNo=@Bonificacion AND BonTest.IdCobro = @IdCobro
				AND BonTest.MontoBonif > 0 AND BonTest.Origen = @Mov AND BonTest.OrigenId = @MovId  
				) 
                SELECT @Ok=1, @OkRef = 'Excluye esta Bonificacion Una anterior ' 
            END
          --- 6.6 Sucursal

            IF NOT @TipoSucursal IS NULL AND NOT EXISTS(SELECT IdBonificacion FROM MaviBonificacionSucursal WITH(NOLOCK) WHERE Sucursal=rtrim(@TipoSucursal) AND idBonificacion=rtrim(@Id))
                             SELECT @Ok=1, @OkRef = 'Bonificación No Configurada Para este tipo de Sucursal' 
           
              IF NOT EXISTS(SELECT IdBonificacion FROM MaviBonificacionTest WITH(NOLOCK) WHERE idBonificacion=rtrim(@Id) AND Docto = @IdCxC )
              BEGIN 
              ----  Calcula Valor 
                    
                    SELECT @MesesExced = isnull(@DocumentoTotal,0) -  isnull(@PlazoEjeFin,0) 
                    SELECT @Factor = 1 + (@MesesExced * (isnull(@Financiamiento,0.00)/100))
                    SELECT @BaseParaAplicar = isnull(@ImporteVenta / @Factor,0.00)

                    IF @AplicaA = 'Importe de Factura'  
                      BEGIN 
         	IF @Linea <> 0 SELECT @PorcBon1=@Linea
                      	IF @LineaCelulares <> 0  AND @Bonificacion NOT LIKE '%Contado%'  AND @Bonificacion NOT LIKE '%Atraso%'  SELECT @PorcBon1=isnull(@LineaCelulares,0.00)
                      	IF @LineaCredilanas <> 0 AND @Bonificacion NOT LIKE '%Contado%' AND @Bonificacion NOT LIKE '%Atraso%'  SELECT @PorcBon1=isnull(@LineaCredilanas,0.00)
                      	--Je.deltoro
                      	IF @Bonificacion LIKE '%Contado%' SELECT @PorcBon1=ISNULL(@LineaMotos,@PorcBon1)
                      	SELECT @MontoBonif = (@PorcBon1/100) * (@ImporteVenta / @Factor) ------ Importe Sobre el Plaxo Eje
                      END 
                    IF @AplicaA <> 'Importe de Factura' SELECT @MontoBonif = (@PorcBon1/100) * @ImporteDocto


               	    ------  Cambio del 29 de Sept ContadoComercial
                IF @Bonificacion LIKE '%Contado Comercial%' AND @Ok IS NULL
                BEGIN
                	SELECT @MontoBonif = @ImporteVenta - ((@ImporteVenta / @Factor)-@MontoBonif)
                END

                IF NOT @Ok is NULL SELECT @MontoBonif = 0.00,@PorcBon1 = 0.00    ---- Pone en Ceros los que no aplica
                IF @Bonificacion LIKE '%Adelanto%' AND dbo.fnFechaSinHora(GETDATE()) = dbo.fnFechaSinHora(@Vencimiento) SELECT @MontoBonif = 0.00 , @PorcBon1 = 0.00

------------------------------------------------------------------------------------------------------------------------------------------------------------
				IF @Bonificacion LIKE '%Contado Comercial%' AND @Ok IS NULL
					SELECT @MontoBonif=ISNULL(@MontoBonif,0)-Bonif FROM (
						SELECT CMov.Mov,CMov.MovID,Bonif=ISNULL( SUM(cd.Importe),0) FROM Cxc CMov WITH(NOLOCK)
																			INNER JOIN Cxc Ccte WITH(NOLOCK) ON Ccte.Cliente=CMov.Cliente AND Ccte.Mov like 'Nota Credito%' AND Ccte.Estatus='CONCLUIDO'
																			INNER JOIN Cxc CBonif WITH(NOLOCK) ON Ccte.ID=CBonif.ID
																			INNER JOIN CxcD cd WITH(NOLOCK) ON CBonif.ID = cd.ID
																			INNER JOIN Cxc CPadre WITH(NOLOCK) ON CPadre.Mov=cd.Aplica AND CPadre.MovID=cd.AplicaID AND CPadre.PadreMAVI=CMov.Mov AND CPadre.PadreIDMAVI=CMov.MovID
																			WHERE Ccte.Concepto LIKE '%PAGO PUNTUAL%' AND CMov.Mov=@Mov AND CMov.MovID=@MovId
																			GROUP BY CMov.Mov,CMov.MovID
																)Resta
------------------------------------------------------------------------------------------------------------------------------------------------------------

                IF @Bonificacion LIKE '%Contado Comercial%'
                BEGIN   
                INSERT MaviBonificacionTest (idBonificacion,IdCoBro,Docto, Bonificacion,    Estacion, Documento1de,DocumentoTotal,Mov, 
                        MovId, Origen,OrigenId, ImporteDocto,ImporteVenta, MontoBonif, TipoSucursal,LineaVta,IdVenta,UEN,Condicion,PorcBon1,Financiamiento, Ok,OkRef, Factor,Sucursal1,PlazoEjeFin, FechaEmision, Vencimiento, LineaCelulares, LineaCredilanas,DiasMenoresA,DiasMayoresA,BaseParaAplicar)
                                    VALUES(@Id ,@IdCobro,@IdCxC,isnull(@Bonificacion,''), @Estacion, isnull(@Documento1de,0),isnull(@DocumentoTotal,0),isnull(@Mov,''),
                                    isnull(@MovId,''),isnull(@Origen,''),isnull(@OrigenId,''), round(isnull(@ImporteDocto,0.00),2), round(isnull(@ImporteVenta,0.00),2), 
                                    round(isnull(@MontoBonif,0.00),2) , isnull(@TipoSucursal,''),isnull(@LineaVta,''),isnull(@IdVenta,0),isnull(@UEN,0),isnull(@Condicion,''),isnull(@PorcBon1,0.00), isnull(@Financiamiento,0.00), isnull(@Ok,0),isnull(@OkRef,''),isnull(@Factor,0.00),@Sucursal,@PlazoEjeFin,@FechaEmision,@Vencimiento, isnull(@LineaCelulares,0.00), isnull(@LineaCredilanas,0.0),@DiasMenoresA,@DiasMayoresA,round(isnull(@BaseParaAplicar,0.00),2))
                END                                    
              END                                  
            
			IF (@Ok is NULL AND EXISTS(SELECT IdBonificacion FROM MaviBonificacionIncluye Exc WITH(NOLOCK) WHERE Exc.IdBonificacion=@Id) 
			AND EXISTS (Select Movimiento from MaviBonificacionMoV WITH(NOLOCK) WHERE Movimiento =  @Mov AND IdBonificacion in 
			(Select id from MaviBonificacionConf WITH(NOLOCK) where Bonificacion like '%Atraso%' ))) OR
			(@Ok is NULL AND @Tipo = 'Total' AND NOT @Bonificacion LIKE '%Contado Comercial%') OR
			(@Ok is NULL AND @Tipo = 'Total' AND NOT @Bonificacion LIKE '%Adelanto%') OR
			(@Ok is NULL AND @Tipo <> 'Total' AND NOT @Bonificacion LIKE '%Contado Comercial%') 
			BEGIN
			IF (@Ok is NULL AND EXISTS(SELECT IdBonificacion FROM MaviBonificacionIncluye Exc WITH(NOLOCK) WHERE Exc.IdBonificacion=@Id)
			AND EXISTS (Select Movimiento from MaviBonificacionMoV WITH(NOLOCK) WHERE Movimiento =  @Mov AND IdBonificacion in 
			( Select id from MaviBonificacionConf WITH(NOLOCK) where Bonificacion like '%Atraso%' ))) 
---
              BEGIN 
                     
					IF EXISTS(SELECT * FROM tempdb.sys.sysobjects WHERE id=OBJECT_ID('tempdb.dbo.#crVerificaDetalle') AND TYPE ='U')
					  DROP TABLE #crVerificaDetalle

					Select Row_number() over (order by BonificacionNo )ind ,  BonificHijo = BonificacionNo,  BonificHijoCascad = EnCascada
					Into #crVerificaDetalle
					 FROM MaviBonificacionIncluye WITH(NOLOCK)
					  WHERE IdBonificacion = @Id
                      Order BY Orden 
					  
				

				   SET @tincluye =0
				   SET @avanza = 0

				   Select @tincluye = MAX(ind),@avanza = 1 From #crVerificaDetalle

                    WHILE @avanza <= @tincluye AND @Ok IS NULL --W2
					BEGIN
	
						 SELECT  @BonificHijo = BonificHijo , @BonificHijoCascad = BonificHijoCascad
						  FROM #crVerificaDetalle
						  WHERE ind = @avanza 
						 
                      	 IF rtrim(@BonificHijo) like '%Atraso%' AND @Bonificacion LIKE  '%Adelanto%'    SELECT @BaseParaAPlicar = @ImporteVenta
                      	 IF rtrim(@BonificHijo) like '%Atraso%' AND @Bonificacion LIKE  '%Comercial%'   SELECT @BaseParaAPlicar = @ImporteVenta * (@PorcBon1/100)

                         EXEC spBonificacionDocRestantes @BonificHijo,@BonificHijoCascad, @PadreMavi, @PadreMaviID ,@Idventa , @lineaVta,  
                              @Sucursal , @TipoSucursal, @Estacion ,@Uen,@Condicion, @ImporteVenta, @Tipo, @IdCxC, @IdCobro,@MaxDiasAtrazo, @Id,@Bonificacion,@BaseParaAPlicar, 'Incluye', @MontoBonif, @FechaEmision
						

                    
					   SET @avanza = @avanza + 1

					END -- W2

         
              	  END 

              	  ------  Recorrido de los pendientes
              	  IF (@Ok is NULL AND @Tipo = 'Total' AND NOT @Bonificacion LIKE '%Contado Comercial%') OR
              	     (@Ok is NULL AND @Tipo <> 'Total' AND NOT @Bonificacion LIKE '%Contado Comercial%') 
              	  BEGIN             	               	  	    

			             EXEC spBonificacionDocRestantes @Bonificacion,'No', @PadreMavi, @PadreMaviId ,@Idventa , @lineaVta,
                              @Sucursal , @TipoSucursal, @Estacion ,@Uen,@Condicion, @ImporteVenta, @Tipo, @IdCxC,@IdCobro, @MaxDiasAtrazo, @Id, @Bonificacion, @BaseParaAPlicar, '', @MontoBonif, @FechaEmision
              	  END
              	  -------------------------Pasar aqui comprobando 
              	  
              	  ----  Fin recorrido
              END 
         
  
   SET @recorre = @recorre+1
   END -- W1
  
END
GO
