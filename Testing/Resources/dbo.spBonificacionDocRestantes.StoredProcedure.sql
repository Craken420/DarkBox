SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

-- ========================================================================================================================================
-- MODIFICACION:
-- NOMBRE			: spBonificacionDocRestantes
-- AUTOR			: Jesus Del Toro
-- FECHA			: 11/01/2012
-- DESARROLLO		: DM0172
-- MODULO			: Cxc
-- ========================================================================================================================================
-- ========================================================================================================================================  
-- FECHA Y AUTOR MODIFICACION:  28/06/2015  Por: MArco Valdovinos
-- Se agregó una tabla para poner un  descuento en el Pago Puntual para los documentos vencidos que cumplan con  los días vencidos que se especifican
-- ========================================================================================================================================  

-- ========================================================================================================================================  
-- FECHA Y AUTOR MODIFICACION:  30/12/2015  Por: MArco Valdovinos
-- Se quita el Curso y mejor se usa una tabla temporal para recorrerla
-- ========================================================================================================================================  

 CREATE PROCEDURE [dbo].[spBonificacionDocRestantes]  
  @Bonificacion varchar(50),  
  @EnCascada    varchar(5),  
  @Origen       varchar(20),  
  @OrigenId     varchar(20),  
  @Idventa      int,  
  @lineaVta     varchar(50),  
  @Sucursal     int,  
  @TipoSucursal varchar(50),   
  @Estacion     int,  
  @Uen          int,  
  @Condicion    VarChar(50),  
  @ImporteVenta float,  
  @Tipo         VarChar(10),  
  @idCxc        int ,  
  @IdCoBro      int,  
  @MaxDiasAtrazo float,  
  @IdBonifica   int,   
  @StrBonifica  varchar(50),  
  @BaseParaAPlicar Float,   
  @Incluye      char(10),   
  @MontoBonifPapa float ,   
  @FechaEmisionBase  Datetime  
    
AS   
BEGIN  
  DECLARE  
----- 1. Declara  
  @Empresa          VarChar(5),  
  @Mov              VarChar(20),  
  @MovId            VarChar(20),  
  @FechaEmision     Datetime,  
  @Concepto         VarChar(50),  
  @TipoCambio       float,  
  @ClienteEnviarA   int,  
  @Vencimiento      Datetime,  
  @Impuestos        float,  
  @Saldo            float,       
  @ImporteDocto     float,  
  @ImporteCasca     float,  
  @Referencia       varchar(50),  
  @Documento1de     Int,  
  @DocumentoTotal   Int,   
  @OrigenTipo       varchar(20),     
  @ExtraeD          Int,  
  @ExtraeA          Int,  
  @MovIdVenta       varchar(20),  
  @MovVenta         varchar(20),  
  @DiasMenoresA       Int,  
  @DiasMayoresA       Int,  
------   Factura AAA6 (12/13)  
  @Id                int,  
  @IdBonificacion    Int,  
  @Estatus           varchar(15),  
  @PorcBon1          float,  
  @PorcBon1Bas       float,  
  @MontoBonif        float,  
  @Financiamiento    float,  
  @FechaIni          datetime,  
  @FechaFin          datetime,  
  @PagoTotal         bit,  
  @ActVigencia       bit,  
  @CascadaCalc       bit,  
  @AplicaA           Char(30),  
  @PlazoEjeFin       int,   
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
  @NoPuedeAplicarSola Bit,  
  @Ejercicio         Int,  
  @LineaCelulares    float,   
  @LineaCredilanas   float,   
  @ImporteVenta2   FLOAT,  
  @LineaMotos VARCHAR(25),
  @MesesAdelanto INT  
  ,@DVextra INT
  , @PorcBonextra float

------------------------------------------------------------------------------------------------------------------------------
	  IF EXISTS(SELECT * FROM TEMPDB.SYS.SYSOBJECTS WHERE ID=OBJECT_ID('tempdb..#MovsPendientes') AND TYPE='U')
		DROP TABLE #MovsPendientes
      SELECT Id, Empresa,Mov,MovId, FechaEmision,Concepto, Estatus, 
          ClienteEnviarA,Vencimiento,Importe, Impuestos,Saldo,Referencia,
          PadreMAVI, PadreIDMAVI
      INTO #MovsPendientes
      FROM CxcPendiente cp WITH(NOLOCK)  
      WHERE cp.PadreMAVI = @Origen AND cp.PadreIDMAVI = @OrigenId  
       AND NOT Referencia IS NULL AND cp.Estatus= 'PENDIENTE'  

		UPDATE M SET Importe = Calc.Calculo,Impuestos=CAST(0.00 AS MONEY)
		FROM #MovsPendientes M
		INNER JOIN (
			SELECT
				Importe = Doc.Importe+Doc.Impuestos,
				Documentos = Con.DANumeroDocumentos,
				Doc.PadreMAVI,
				Doc.PadreIDMAVI,
				Monedero = ISNULL(Mon.Abono,0),
				Calculo = (((Doc.Importe+Doc.Impuestos))-ISNULL(Mon.Abono,0))/Con.DANumeroDocumentos
			FROM dbo.Cxc Doc WITH(NOLOCK)
			LEFT JOIN dbo.Condicion Con WITH(NOLOCK) ON Con.Condicion=Doc.Condicion
			LEFT JOIN dbo.AuxiliarP Mon WITH(NOLOCK) ON Mon.Mov=Doc.Mov AND Mon.MovID=Doc.MovID AND ISNULL(Mon.Abono,0)>0
			WHERE Doc.Mov=@Origen AND Doc.MovID=@OrigenId AND Doc.Estatus<>'CANCELADO'
		)Calc ON Calc.PadreMAVI=M.PadreMAVI AND Calc.PadreIDMAVI=M.PadreIDMAVI
------------------------------------------------------------------------------------------------------------------------------
  
----- 2. Inicializanas   
      SELECT @Ok = null , @OkRef = '', @Ejercicio = year(getdate()), @Periodo = Month(getdate()), @Mov = '',@DiasMenoresA=0, @DiasMayoresA=0, @CharReferencia= 0 , @ImporteCasca=0.00  
      SELECT @ImporteVenta2 = 0.00  
      SELECT @Mov = Mov FROM CXC WITH(NOLOCK) WHERE Id = @IdCxc  
  
----- 3. Carga Bonificacion  

   
 
  IF @Incluye = 'Incluye'  
    SELECT    
      @IdBonificacion = Id,@PorcBon1Bas = PorcBon1,@Financiamiento = Financiamiento,@FechaIni = FechaIni,  
      @FechaFin = FechaFin,@PagoTotal = PagoTotal,@AplicaA = AplicaA,@PlazoEjeFin = PlazoEjeFin,@VencimientoAntes = VencimientoAntes,  
      @VencimientoDesp = VencimientoDesp,@DiasAtrazo = DiasAtrazo,@DiasMenoresA = DiasMenoresA,@DiasMayoresA = DiasMayoresA,  
      @Factor = Factor,@Linea = Linea, @NoPuedeAplicarSola = isnull(NoPuedeAplicarSola,0)  
      FROM 
 (   
        SELECT Id, PorcBon1, Financiamiento,  FechaIni,  FechaFin, PagoTotal, AplicaA,  PlazoEjeFin, VencimientoAntes,  
          VencimientoDesp,  DiasAtrazo,  DiasMenoresA, DiasMayoresA,  Factor,  Linea,  NoPuedeAplicarSola 
           ,Row_number() over (Partition BY   Bonificacion order by  id) perbonif
		FROM MaviBonificacionConf WITH(NOLOCK)
		JOIN MaviBonificacionMov bm WITH(NOLOCK) ON ID = bm.IDBonificacion  
		WHERE Bonificacion = @Bonificacion   
		AND Estatus = 'CONCLUIDO'      
		AND FechaIni <= @FechaEmisionBase  AND FechaFin >= @FechaEmisionBase  
		AND bm.Movimiento = @Mov  
	 )Boni 
	     WHERE perbonif = 1
	  
  SELECT @Mov = ''      
  
  IF @Incluye <> 'Incluye'  
    SELECT    
      @IdBonificacion = Id,@PorcBon1bas = PorcBon1,@Financiamiento = Financiamiento,@FechaIni = FechaIni,  
      @FechaFin = FechaFin,@PagoTotal = PagoTotal,@AplicaA = AplicaA,@PlazoEjeFin = PlazoEjeFin,@VencimientoAntes = VencimientoAntes,  
      @VencimientoDesp = VencimientoDesp,@DiasAtrazo = DiasAtrazo,@DiasMenoresA = DiasMenoresA,@DiasMayoresA = DiasMayoresA,  
      @Factor = Factor,@Linea = Linea, @NoPuedeAplicarSola = isnull(NoPuedeAplicarSola,0)   
    FROM MaviBonificacionConf WITH(NOLOCK)
    WHERE Bonificacion = @Bonificacion   
    AND ID = @IdBonifica  
    AND Estatus = 'CONCLUIDO'      
 AND FechaIni <= @FechaEmisionBase  AND FechaFin >= @FechaEmisionBase  
  
    IF EXISTS(SELECT * FROM tempdb.sys.sysobjects WHERE id=OBJECT_ID('tempdb.dbo.#CrCxCPendientes') AND TYPE ='U')
	  DROP TABLE #CrCxCPendientes 

   CREATE TABLE #CrCxCPendientes( Consec int identity, IdCxC INT, Empresa Varchar(50),Mov varchar(30) ,MovId Varchar(30), FechaEmision DATETIME ,  
          ClienteEnviarA INT,Vencimiento Datetime ,ImporteDocto float, Impuestos float,Saldo float,Concepto Varchar(50) NULL, Referencia  Varchar(50) NULL )


  IF @Tipo = 'Total'  AND @NoPuedeAplicarSola = 0   
  Begin   
  
      INSERT INTO #CrCxCPendientes ( IdCxC , Empresa ,Mov  ,MovId , FechaEmision ,ClienteEnviarA ,Vencimiento  ,ImporteDocto , Impuestos ,
									  Saldo ,Concepto , Referencia )
	  SELECT Id, Empresa,Mov,MovId, FechaEmision,  ClienteEnviarA,Vencimiento,Importe, Impuestos,Saldo,Concepto,Referencia  
      FROM #MovsPendientes cp 
      WHERE cp.PadreMAVI = @Origen AND cp.PadreIDMAVI = @OrigenId  
       AND NOT Referencia IS NULL AND cp.Estatus= 'PENDIENTE'  
       UNION   
      SELECT cp.Id, cp.Empresa,cp.Mov,cp.MovId, cp.FechaEmision,cp.ClienteEnviarA,cp.Vencimiento,cp.Importe, cp.Impuestos,cp.Saldo,cp.Concepto,cp.Referencia  
      FROM CxcPendiente cp WITH(NOLOCK)
      JOIN NegociaMoratoriosMAVI nmm  with(NOLOCK) ON(cp.Mov = nmm.Mov AND cp.MovID = nmm.MovID)
      WHERE cp.PadreMAVI = @Origen AND cp.PadreIDMAVI = @OrigenId   
       AND cp.Estatus= 'PENDIENTE'  
       AND (nmm.Mov LIKE '%Nota Cargo%' OR nmm.Mov LIKE '%Contra Recibo%')  
       AND nmm.IDCobro=@IdCoBro  
  END    
  ELSE IF ISNULL(@Tipo,'')<>'Total' AND @NoPuedeAplicarSola = 0   
  BEGIN  
 
      
	  INSERT INTO #CrCxCPendientes ( IdCxC , Empresa ,Mov  ,MovId , FechaEmision ,ClienteEnviarA ,Vencimiento  ,ImporteDocto , Impuestos ,
									  Saldo ,Concepto , Referencia )
	  SELECT Id, Empresa,Mov,MovId, FechaEmision, ClienteEnviarA,Vencimiento,Importe, Impuestos,Saldo,Concepto,Referencia  
      FROM #MovsPendientes cp WITH(NOLOCK)  
      WHERE cp.PadreMAVI = @Origen AND cp.PadreIDMAVI = @OrigenId  
       AND NOT Referencia IS NULL AND cp.Estatus= 'PENDIENTE'  
       UNION   
      SELECT cp.Id, cp.Empresa,cp.Mov,cp.MovId, cp.FechaEmision,  
          cp.ClienteEnviarA,cp.Vencimiento,cp.Importe, cp.Impuestos,cp.Saldo,cp.Concepto,cp.Referencia  
      FROM CxcPendiente cp WITH(NOLOCK)
      JOIN NegociaMoratoriosMAVI nmm WITH(NOLOCK) ON(cp.Mov = nmm.Mov AND cp.MovID = nmm.MovID )
      WHERE cp.PadreMAVI = @Origen AND cp.PadreIDMAVI = @OrigenId   
       AND cp.Estatus= 'PENDIENTE'  
       AND (nmm.Mov LIKE '%Nota Cargo%' OR nmm.Mov LIKE '%Contra Recibo%')  
       AND nmm.IDCobro=@IdCoBro  
  END    
   
  SELECT @DVextra = MaxDV, @PorcBonextra =PorcBon From MaviBonificacionConVencimiento  with(NOLOCK) where IdBonificacion = @IdBonifica

  IF @NoPuedeAplicarSola = 1    
  BEGIN  

	  INSERT INTO #CrCxCPendientes ( IdCxC , Empresa ,Mov  ,MovId , FechaEmision ,ClienteEnviarA ,Vencimiento  ,ImporteDocto , Impuestos ,
									  Saldo ,Concepto , Referencia )
      SELECT TOP(1)Id, Empresa,Mov,MovId, FechaEmision,  ClienteEnviarA,Vencimiento,Importe, Impuestos,Saldo,Concepto,Referencia  
      FROM #MovsPendientes cp   
      WHERE cp.PadreMAVI = @Origen AND cp.PadreIDMAVI = @OrigenId  
       AND NOT Referencia IS NULL AND cp.Estatus= 'PENDIENTE'        
  END   
  
  IF @IDBonificacion is not null   
  BEGIN  
    

	DECLARE @totreg int , @recorre int
    SELECT  @totreg =MAX(Consec) ,   @recorre = 1 FROM #CrCxCPendientes
	
	WHILE @recorre <=  @totreg 
	BEGIN  
       
	   SELECT @IdCxC = IdCxC , @Empresa = Empresa ,@Mov = Mov ,@MovId =MovId , @FechaEmision =FechaEmision ,@Concepto = Concepto,  
             @ClienteEnviarA =ClienteEnviarA,@Vencimiento = Vencimiento,@ImporteDocto = ImporteDocto, @Impuestos = Impuestos,@Saldo = Saldo,
			 @Concepto = Concepto ,@Referencia =Referencia
		     FROM #CrCxCPendientes
			 where Consec= @recorre 
	    --- suma total + Impuestos  
       SELECT @ImporteDocto = @ImporteDocto + isnull(@Impuestos,0.00), @PorcBon1 = @PorcBon1Bas, @Ok = NULL, @OkRef = ''  
  
       IF @Mov LIKE '%Nota Cargo%'   
       BEGIN   
          IF ISNULL(@Concepto,'') NOT LIKE 'CANC COBRO%'
            SELECT @Ok=1, @OkRef = 'La Nota No Pertenece a un Concepto para Bonificaci¢n'   
       END  
  
        IF patindex('%/%',@Referencia) > 0    
        BEGIN  
          SELECT @ExtraeD = patindex('%(%',@Referencia), @ExtraeA = patindex('%/%',@Referencia)  
          SELECT @Documento1de = substring(@Referencia,@ExtraeD+1,@ExtraeA - @ExtraeD -1)      
          SELECT @ExtraeD = patindex('%/%',@Referencia), @ExtraeA = patindex('%)%',@Referencia)  
          SELECT @DocumentoTotal = substring(@Referencia,@ExtraeD+1,@ExtraeA - @ExtraeD -1)  
        END  
  
        IF @VencimientoAntes <> 0 AND (NOT @Mov like '%Nota Cargo%' OR NOT @Mov like '%Contra%')  
		BEGIN  
			SET @CharReferencia = rtrim(@VencimientoAntes) + '/' + rtrim(@DocumentoTotal)  
            IF NOT EXISTS(SELECT ID FROM CxcPendiente WITH(NOLOCK)  
                          WHERE PadreMAVI = @Origen AND PadreIDMAVI = @OrigenId  
             AND Estatus = 'PENDIENTE' AND referencia LIKE '%' + @CharReferencia + '%')  
                SELECT @Ok=1, @OkRef = 'Excede el N£mero M¡nimo del Pago a jalar'   
        END          
  
          IF @VencimientoDesp <= @Documento1de AND @VencimientoDesp <> 0  AND (NOT @Mov like '%Nota Cargo%' OR NOT @Mov like '%Contra%')  
          BEGIN    
           SET @CharReferencia = rtrim(@Documento1de) + '/' + rtrim(@DocumentoTotal)    
            IF NOT EXISTS(SELECT ID FROM CxcPendiente WITH(NOLOCK)    
                          WHERE PadreMAVI = @Origen AND PadreIDMAVI = @OrigenID  
                AND Estatus = 'PENDIENTE' AND referencia LIKE '%' + @CharReferencia + '%')     
                SELECT @Ok=1, @OkRef = 'Excede el Numero Maximo del Pago a jalar'     
          END  
                    -- 5.2 Dias Atrazo  
          IF @DiasAtrazo <> 0 AND @Mov <> 'Nota Cargo'  
          BEGIN  
            IF @MaxDiasAtrazo > @DiasAtrazo SELECT @Ok=1, @OkRef = 'Excede el n£mero de dias de atraso permitidos '     
          END  
            
          ---- 5.3  
          IF @DiasMenoresA <> 0 AND @Bonificacion NOT LIKE '%Contado Comercial%'  
          BEGIN  
           IF @DiasMenoresA < DATEDIFF(DAY, @FechaEmision, getdate() )  
              SELECT @Ok=1, @OkRef = 'Excede d¡as menores'  + CONVERT (char(30),@DiasMenoresA)  
          END  
          -- 5.3 Dias de Mayores  
          IF @DiasMayoresA <> 0 AND @Bonificacion NOT LIKE '%Contado Comercial%'  
          BEGIN  
         IF @DiasMayoresA > DATEDIFF(DAY, @FechaEmision, getdate() )  
                 SELECT @Ok=1, @OkRef = 'Excede d¡as mayores'  + CONVERT (char(30),@DiasMayoresA)  
          END  
  
          ---- 5.4   Validacion para VencimientoDespues, traida desde spBonificacionesCalculaTabla GRB 24/07/10   
          IF @VencimientoDesp <> 0  
          BEGIN      
            SET @CharReferencia = '(' +  rtrim(@VencimientoDesp) + '/' + rtrim(@DocumentoTotal)      
                            
              IF dbo.fnFechaSinHora(GETDATE())  <=  dbo.fnFechaSinHora((Select c.Vencimiento FROM Cxc c WITH(NOLOCK) WHERE c.Origen = @Origen AND c.OrigenID = @OrigenId AND c.Referencia LIKE '%' + @CharReferencia + '%'))    
                SELECT @Ok=1, @OkRef = 'No cumple con el límite de pago posterior2'      
              
          END  
  
            IF @PorcBon1 = 0 AND @Linea <> 0 SELECT @PorcBon1 = @Linea  
            IF @Linea < (SELECT isnull(PorcLin,0.00) FROM MaviBonificacionLinea WITH(NOLOCK) WHERE IdBonificacion=@id AND Linea = @LineaVta)   
                  SELECT @Linea = (SELECT isnull(PorcLin,0.00) FROM MaviBonificacionLinea WITH(NOLOCK) WHERE IdBonificacion=@id AND Linea = @LineaVta)                           
                    
            SELECT @LineaCredilanas=isnull(PorcLin,0.00) FROM MaviBonificacionLinea mbl WITH(NOLOCK) WHERE Linea LIKE '%Credilana%' AND IdBonificacion = @IdBonificacion  
            SELECT @LineaCelulares=isnull(PorcLin,0.00) FROM MaviBonificacionLinea mbl WITH(NOLOCK) WHERE Linea LIKE '%Celular%' AND IdBonificacion = @IdBonificacion  
            --Je.deltoro  
            SELECT @LineaMotos=isnull(PorcLin,0.00) FROM MaviBonificacionLinea mbl WITH(NOLOCK) WHERE Linea LIKE '%MOTOCICLETA%' AND IdBonificacion = @IdBonificacion  
                    
            --- 6.2 Canal Ventas  
            IF EXISTS(SELECT IdBonificacion FROM MaviBonificacionCanalVta BonCan WITH(NOLOCK) WHERE BonCan.IdBonificacion=@IdBonificacion)  
            BEGIN              
              IF NOT EXISTS(SELECT IdBonificacion FROM MaviBonificacionCanalVta BonCan WITH(NOLOCK) WHERE CONVERT(varchar(10),BonCan.CanalVenta)=@ClienteEnviarA AND BonCan.IdBonificacion=@IdBonificacion)  
                 SELECT @Ok=1, @OkRef = 'Venta de Canal No Configurada Para esta Bonificaci¢n'               
            END       
          --- 6.3 UEN's  
            IF EXISTS(SELECT IdBonificacion FROM MaviBonificacionUEN mbu WITH(NOLOCK) WHERE mbu.idBonificacion=@IdBonificacion)  
            BEGIN    
              IF NOT @UEN is NULL AND NOT EXISTS(SELECT IdBonificacion FROM MaviBonificacionUEN mbu WITH(NOLOCK) WHERE mbu.UEN = @UEN AND mbu.idBonificacion=@IdBonificacion)  
                 SELECT @Ok=1, @OkRef = 'UEN No Configurada Para este Caso'   
            END  
          --- 6.4 Condicion  
            IF EXISTS(SELECT IdBonificacion FROM MaviBonificacionCondicion WITH(NOLOCK) WHERE IdBonificacion=@IdBonificacion)  
          BEGIN                          
              IF NOT EXISTS(SELECT IdBonificacion FROM MaviBonificacionCondicion WITH(NOLOCK) WHERE COndicion=@Condicion AND IdBonificacion=@IdBonificacion)  
                 SELECT @Ok=1, @OkRef = 'Condicion No Configurada Para esta Bonificaci¢n'   
            END       
          --- 6.5 Bonif Exclu  
  
            IF EXISTS(SELECT IdBonificacion FROM MaviBonificacionExcluye Exc WITH(NOLOCK) WHERE BonificacionNo=@Bonificacion)  
            BEGIN                          
                
              IF EXISTS(SELECT BonTest.IdBonificacion FROM MaviBonificacionTest BonTest WITH(NOLOCK) JOIN MaviBonificacionExcluye Exc WITH(NOLOCK) ON(Bontest.IdBonificacion = Exc.IdBonificacion)   
                WHERE Exc.BonificacionNo=@Bonificacion AND Bontest.OkRef = ''  AND BonTest.MontoBonif > 0   
                AND idcobro = @IdCoBro AND Origen=@Origen AND OrigenId=@OrigenId)   
                SELECT @Ok=1, @OkRef = 'Excluye esta Bonificacion Una anterior  Detalle'   
    
                
            END                  
          --- 6.6 Sucursal  
            IF EXISTS(SELECT IdBonificacion FROM MaviBonificacionSucursal Exc WITH(NOLOCK) WHERE IdBonificacion=@IdBonificacion)  
            BEGIN                          
              IF NOT @TipoSucursal IS NULL AND NOT EXISTS(SELECT IdBonificacion FROM MaviBonificacionSucursal WITH(NOLOCK) WHERE Sucursal=@TipoSucursal AND idBonificacion=@IdBonificacion)  
                 SELECT @Ok=1, @OkRef = 'Bonificaci¢n No Configurada Para este tipo de Sucursal'                
            END       
  
  
          IF NOT EXISTS(SELECT IdBonificacion FROM MaviBonificacionTest WITH(NOLOCK) WHERE idBonificacion=rtrim(@IdBonificacion) AND Docto = @IdCxC AND Estacion = @Estacion AND MontoBonif = @MontoBonif)  
          BEGIN  -- Z
  
                    IF @AplicaA = 'Importe de Factura'    
                      BEGIN   
                       IF @Linea <> 0 SELECT @PorcBon1=@Linea  
                       IF @LineaCelulares <> 0  AND @Bonificacion NOT LIKE '%Contado%'  AND @Bonificacion NOT LIKE '%Atraso%'  SELECT @PorcBon1=@LineaCelulares  
                       IF @LineaCredilanas <> 0  AND @Bonificacion NOT LIKE '%Contado%'  AND @Bonificacion NOT LIKE '%Atraso%'  SELECT @PorcBon1=@LineaCredilanas                          
                       IF @EnCascada = 'Si' SELECT @ImporteVenta2 = @ImporteVenta - @MontoBonifPapa  
					   IF @EnCascada <> 'Si' SELECT @ImporteVenta2 = @ImporteVenta  
                       SELECT @MontoBonif = (@PorcBon1/100) * @ImporteVenta2 ------ Importe Sobre el Plaxo Eje  
  
                      END   
                    IF @Bonificacion LIKE '%Adelanto%' AND @Tipo = 'Total'
                      BEGIN   
                       IF @Linea <> 0 SELECT @PorcBon1=@Linea  
                       IF ISNULL(@LineaCelulares,0) <> 0  AND @lineaVta LIKE '%CELULAR%' SELECT @PorcBon1=@LineaCelulares  
					   IF ISNULL(@LineaCredilanas,0) <> 0  AND @lineaVta LIKE '%CREDILA%' SELECT @PorcBon1=@LineaCredilanas  
					   --Je.deltoro  
					   IF @Bonificacion LIKE '%Contado%' SELECT @PorcBon1=@LineaMotos                 
					   IF @EnCascada = 'Si' SELECT @ImporteVenta2 = @ImporteVenta - @MontoBonifPapa  
					   IF @EnCascada <> 'Si' SELECT @ImporteVenta2 = @ImporteVenta
					   SELECT 
							@MesesAdelanto=COUNT(ID)
					   FROM Cxc WITH(NOLOCK)
					   WHERE PadreMAVI = @Origen AND PadreIDMAVI = @OrigenId AND PadreMAVI <> Mov AND Vencimiento>GETDATE()
					   IF @MesesAdelanto > @DocumentoTotal SELECT @MesesAdelanto = @DocumentoTotal
					   SELECT @PorcBon1 = @PorcBon1 * @MesesAdelanto
					   SELECT @ImporteVenta2 = (@ImporteVenta2 / @DocumentoTotal) * @MesesAdelanto
   					   SELECT @ImporteVenta2 = @ImporteVenta2 / (SELECT COUNT(ID) FROM (
												  SELECT Id, Empresa,Mov,MovId, FechaEmision,Concepto,  
													  ClienteEnviarA,Vencimiento,Importe, Impuestos,Saldo,Referencia  
												  FROM Cxc cp WITH(NOLOCK)
												  WHERE cp.PadreMAVI = @Origen AND cp.PadreIDMAVI = @OrigenId  
												   AND NOT Referencia IS NULL AND cp.Estatus= 'PENDIENTE'  
												   UNION   
												  SELECT cp.Id, cp.Empresa,cp.Mov,cp.MovId, cp.FechaEmision,cp.Concepto,  
													  cp.ClienteEnviarA,cp.Vencimiento,cp.Importe, cp.Impuestos,cp.Saldo,cp.Referencia  
												  FROM CxcPendiente cp WITH(NOLOCK)
												  JOIN NegociaMoratoriosMAVI nmm WITH(NOLOCK) ON(cp.Mov = nmm.Mov AND cp.MovID = nmm.MovID)
												  WHERE cp.PadreMAVI = @Origen AND cp.PadreIDMAVI = @OrigenId   
												   AND cp.Estatus= 'PENDIENTE'  
												   AND (nmm.Mov LIKE '%Nota Cargo%' OR nmm.Mov LIKE '%Contra Recibo%')  
												   AND nmm.IDCobro=@IdCoBro)x )
                      END   
                    IF @AplicaA <> 'Importe de Factura' AND @Bonificacion<>'Bonificacion Pago Puntual' 
						SELECT @MontoBonif = (@PorcBon1/100) * @ImporteVenta2  
					IF @AplicaA <> 'Importe de Factura' AND @Bonificacion='Bonificacion Pago Puntual' 
						SELECT @MontoBonif = (@PorcBon1/100) * @ImporteDocto  
                     
					IF NOT @Ok is NULL SELECT @MontoBonif = 0.00,@PorcBon1 = 0.00    ---- Pone en Ceros los que no aplica  
  
					-- Verificar si aplica para descuento con vencimiento en Pago Puntual 
					IF @Bonificacion LIKE '%Puntual%' AND (dbo.fnFechaSinHora(GETDATE()) > (dbo.fnFechaSinHora(@Vencimiento)))  
					BEGIN   
						If (  Select  DV = DATEDIFF(dd,@Vencimiento, convert(datetime,convert(varchar(10),getdate(),10))) ) <= @DVextra
						SELECT @PorcBon1 = @PorcBonextra, @MontoBonif = (@PorcBonextra/100) * @ImporteDocto 
						Else  		
							SELECT @Ok = 1 , @OkRef = 'Excede el vencimiento', @MontoBonif = 0.00 , @PorcBon1 = 0.00                       
    
					END     
  
  
				   IF @Bonificacion LIKE '%Adelanto%' AND dbo.fnFechaSinHora(GETDATE()) >= dbo.fnFechaSinHora(@Vencimiento) ----pto 33 pzamudio   
					SELECT @MontoBonif = 0.00 , @PorcBon1 = 0.00, @Ok = 1 , @OkRef = 'Por el Vencimiento del Docto'                      
   
  
				   IF @Bonificacion LIKE '%Adelanto%' AND @Tipo<>'Total' SELECT @MontoBonif = 0.00 , @PorcBon1 = 0.00 , @Ok = 1 , @OkRef = 'Adelanto Aplica a puro Total'                          
				   IF @Bonificacion LIKE '%Atraso%' AND @Tipo<>'Total' SELECT @MontoBonif = 0.00 , @PorcBon1 = 0.00        
				   IF @Bonificacion LIKE '%Atraso%' AND @Tipo<>'Total' SELECT @BaseParaAPlicar = @BaseParaAPlicar - @MontoBonifPapa  
				   IF @Bonificacion LIKE '%Atraso%' SELECT @BaseParaAPlicar = @ImporteVenta2  
				   IF @Bonificacion LIKE '%Puntual%' SELECT @BaseParaAPlicar = @ImporteDocto      
             
				   INSERT MaviBonificacionTest (idBonificacion, IdCoBro, Docto,Bonificacion,    Estacion, Documento1de,DocumentoTotal,Mov, MovId,Origen,OrigenId,ImporteVenta,ImporteDocto, MontoBonif, TipoSucursal,LineaVta,IdVenta,UEN,Condicion,PorcBon1,  
												  Financiamiento, Ok,OkRef,Factor,Sucursal1, PlazoEjeFin,FechaEmision,Vencimiento, LineaCelulares, LineaCredilanas,DiasMenoresA,DiasMayoresA,BaseParaAPlicar)  
										  VALUES(@IdBonificacion,@IdCoBro, @IdCxC,isnull(@Bonificacion,''),@Estacion, isnull(@Documento1de,0),isnull(@DocumentoTotal,0),isnull(@Mov,''),isnull(@MovId,''), isnull(@Origen,''),isnull(@OrigenId,''),  
										  round(isnull(@ImporteVenta,0.00),2), round(isnull(@ImporteDocto,0.00),2), round(isnull(@MontoBonif,0.00),2), isnull(@TipoSucursal,''),isnull(@LineaVta,''),isnull(@IdVenta,0),isnull(@UEN,0),isnull(@Condicion,''),  
										  isnull(@PorcBon1,0.00), isnull(@Financiamiento,0.00), isnull(@Ok,0),isnull(@OkRef,''),isnull(@factor,0.00),@Sucursal,@PlazoEjeFin,@FechaEmision,@Vencimiento, isnull(@LineaCelulares,0.00), isnull(@LineaCredilanas,0.00),  
										  @DiasMenoresA,@DiasMayoresA,round(isnull(@BaseParaAPlicar,0.00),2))  
     
         END   -- Z      
   
	 SET @recorre = @recorre + 1
    END  -- Fin del While
     
  END  -- fin si @IDBonificacion is not null 
  
  IF EXISTS(SELECT * FROM TEMPDB.SYS.SYSOBJECTS WHERE ID=OBJECT_ID('tempdb..#MovsPendientes') AND TYPE='U')
	DROP TABLE #MovsPendientes   
  IF EXISTS(SELECT * FROM tempdb.sys.sysobjects WHERE id=OBJECT_ID('tempdb.dbo.#CrCxCPendientes') AND TYPE ='U')
	DROP TABLE #CrCxCPendientes 
	
	  
END -- fin del SP  
GO
