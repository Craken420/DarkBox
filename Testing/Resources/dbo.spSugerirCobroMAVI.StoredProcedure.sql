SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].[spSugerirCobroMAVI]
		    @SugerirPago	varchar(20),
		    @Modulo		char(5),
		    @ID			int,
    		@ImporteTotal	money, -- = NULL,
		    @Usuario	varchar(10),
			@Estacion	int

-- Se cambia el sp para q inserte en la tabla previa para Negociacion y condonacion de Moratorios antes de generar el cobro
--//WITH ENCRYPTION
AS BEGIN
  DECLARE
    @Empresa			char(5),
    @Sucursal			int,
    @Hoy			datetime,
    @Vencimiento		datetime,
    @DiasCredito		int,
    @DiasVencido		int,
    @TasaDiaria			float,
    @Moneda			char(10),
    @TipoCambio			float,
    @Contacto			char(10),
    @Renglon			float,
    @Aplica			varchar(20),
    @AplicaID			varchar(20),
    @AplicaMovTipo		varchar(20),
    @Capital			money,
    @Intereses			money,
    @InteresesOrdinarios	money,
    @InteresesFijos		money,
    @InteresesMoratorios	money,
    @ImpuestoAdicional		float,
    @Importe			money,
    @SumaImporte		money,
    @Impuestos			money,
    @DesglosarImpuestos 	bit,
    @LineaCredito		varchar(20),
    @Metodo			int,
    @GeneraMoratorioMAVI	char(1),
    @MontoMinimoMor			float,
	@CondonaMoratorios		int,
	@IDDetalle				int,
	@ImpReal				money,
	@MoratorioAPagar		money,
    @Origen				varchar(20),
    @OrigenID			varchar(20),
	@MovPadre			varchar(20),
    @MovPadreID			varchar(20),
    @MovPadre1			varchar(20),
    @MovIDPadre			varchar(20)
    ,@PadreMAviPend  varchar(20)  ---pzamudio
    ,@PadreMaviIDPend  varchar(20) ---pzamudio,
     ,@NotaCredxCanc	  char(1), -- JB
     @Mov              varchar(20),
    @AplicaNota varchar(20),
    @AplicaIDNota varchar(20) 
    
--select @Modulo as 'Modulo'  -- yrg
  -- Se  hace una primer pasada (cursor) para calculo de moratorios hasta donde cubra el importe del cobro
  --  si @ImporteTotal > 0 se hace una segunda pasada para ver cuanto de los doctos se alcanza a cubrir
  DELETE NegociaMoratoriosMAVI WHERE IDCobro = @ID --AND Usuario = @Usuario AND Estacion = @Estacion
  DELETE FROM HistCobroMoratoriosMAVI WHERE IDCobro = @ID ---- pzamudio 30 julio 2010
  IF EXISTS(SELECT * FROM TipoCobroMAVI WITH (NOLOCK) WHERE IDCobro = @ID)
    UPDATE TipoCobroMAVI WITH (ROWLOCK) SET TipoCobro = 0  WHERE IDCobro = @ID
  ELSE
    INSERT INTO TipoCobroMAVI(IDCobro, TipoCobro) VALUES(@ID, 0)

  --Se comento el prestamo personal porque con la nueva configuracion no aplicara a prestamos personales
  CREATE TABLE #NotaXCanc(Mov varchar(20) NULL,MovID varchar(20) NULL)
  INSERT INTO  #NotaXCanc(Mov,MovID)
  SELECT DISTINCT d.mov,d.movid from negociamoratoriosmavi  c WITH (NOLOCK), cxcpendiente d WITH (NOLOCK), cxc n WITH (NOLOCK) WHERE c.mov in('Nota Cargo','Nota Cargo VIU') and d.cliente=@Contacto
  and d.mov=c.mov and d.movid=c.movid and d.padremavi in ('Credilana','Prestamo Personal') and n.mov=c.mov and n.movid=c.movid
  and n.concepto in ('CANC COBRO CRED Y PP')  

  SELECT @DesglosarImpuestos = 0 , @Renglon = 0.0, @SumaImporte = 0.0, @ImporteTotal = NULLIF(@ImporteTotal, 0.0), @SugerirPago = UPPER(@SugerirPago)
  SELECT @Empresa = Empresa, @Sucursal = Sucursal, @Hoy = FechaEmision, @Moneda = Moneda, @TipoCambio = TipoCambio, @Contacto = Cliente, @Mov = Mov   FROM Cxc WITH (NOLOCK) WHERE ID = @ID 
  
  IF @SugerirPago <> 'IMPORTE ESPECIFICO' SELECT @ImporteTotal = 9999999 --NULL  
  
  --- jb
/*     IF @Mov in ('Credilana','Prestamo Personal')
        SET @NotaCredxCanc = '1'
      ELSE
        SET @NotaCredxCanc = NULL*/
  ---
  SELECT @MontoMinimoMor = ISNULL(MontoMinMoratorioMAVI,0.0) FROM EmpresaCfg2 WITH (NOLOCK) WHERE Empresa = @Empresa   
  --SELECT @MontoMinimoMor  as 'Monto Minimo'  -- yrg
  -- OJO hacer otro cursor para el caso de varias facturas
  -- Tabla donde se inserten las Facturas pendientes de pago del cte (ListaSt)
  IF @Modulo = 'CXC'
  BEGIN
    
    SELECT @Empresa = Empresa, @Sucursal = Sucursal, @Hoy = FechaEmision, @Moneda = Moneda, @TipoCambio = TipoCambio, @Contacto = Cliente   FROM Cxc WITH (NOLOCK) WHERE ID = @ID 
    DELETE CxcD WHERE ID = @ID 
    DECLARE crAplica CURSOR FOR
     SELECT p.Mov, p.MovID, p.Vencimiento, mt.Clave, ISNULL(p.Saldo*mt.Factor*p.MovTipoCambio/@TipoCambio, 0.0), ISNULL(p.InteresesOrdinarios*mt.Factor*p.MovTipoCambio/@TipoCambio, 0.0), ISNULL(p.InteresesFijos*p.MovTipoCambio/@TipoCambio, 0.0), 
     ISNULL(p.InteresesMoratorios*mt.Factor*p.MovTipoCambio/@TipoCambio, 0.0), ISNULL(p.Origen, p.Mov), ISNULL(p.OrigenID, p.MovId)
      ,p.PadreMAVI, p.PadreIDMAVI  ----pzamudio               
       FROM CxcPendiente p WITH (NOLOCK)
       JOIN MovTipo mt WITH (NOLOCK) ON mt.Modulo = @Modulo AND mt.Mov = p.Mov
       LEFT OUTER JOIN CfgAplicaOrden a WITH (NOLOCK) ON a.Modulo = @Modulo AND a.Mov = p.Mov
       LEFT OUTER JOIN Cxc r WITH (NOLOCK) ON r.ID = p.RamaID
       LEFT OUTER JOIN TipoAmortizacion ta WITH (NOLOCK) ON ta.TipoAmortizacion = r.TipoAmortizacion
      WHERE p.Empresa = @Empresa AND p.Cliente = @Contacto AND mt.Clave NOT IN ('CXC.SCH','CXC.SD', 'CXC.NC')
      ORDER BY a.Orden, p.Vencimiento, p.Mov, p.MovID
    SELECT @DesglosarImpuestos = ISNULL(CxcCobroImpuestos, 0) FROM EmpresaCfg2 WITH (NOLOCK) WHERE Empresa = @Empresa
  END ELSE
    RETURN

  OPEN crAplica
  FETCH NEXT FROM crAplica INTO @Aplica, @AplicaID, @Vencimiento, @AplicaMovTipo, @Capital, @InteresesOrdinarios, @InteresesFijos, @InteresesMoratorios, @Origen, @OrigenID
  ,@PadreMAviPend, @PadreMaviIDPend   ---pzamudio
  WHILE @@FETCH_STATUS <> -1 AND ((@SugerirPago = 'SALDO VENCIDO' AND @Vencimiento<=@Hoy AND @ImporteTotal > @SumaImporte ) OR (@SugerirPago = 'IMPORTE ESPECIFICO' AND @ImporteTotal > @SumaImporte) OR @SugerirPago = 'SALDO TOTAL')
  BEGIN
    IF @@FETCH_STATUS <> -2 
    BEGIN
      --Select * from NegociaMoratoriosMAVI  
      --SELECT @Capital as 'Capital 1 vez'
      SELECT @CondonaMoratorios = 0, @GeneraMoratorioMAVI = NULL, @IDDetalle = 0, @MoratorioAPagar = 0      
      
		-- YANI
      SELECT @IDDetalle = ID FROM CXC WITH (NOLOCK) WHERE Mov = @Aplica AND MovId = @AplicaID --AND OrigenTipo = 'CXC'
      --select @IDDetalle as 'IDMovYani'  -- yrg

		-- Si el docto esta en tiempo de pagarse no se le generan moratorios solo se traspasa al detalle del cobro
      -- Verificar si el mov, el canal de venta y el cliente deben generar moratorios
      SELECT @GeneraMoratorioMAVI = dbo.fnGeneraMoratorioMAVI(@IDDetalle)
      IF @GeneraMoratorioMAVI = '1'
      BEGIN
        --select @GeneraMoratorioMAVI as 'Genera Mor'   -- yrg
        SELECT @InteresesMoratorios = 0
        SELECT @InteresesMoratorios = dbo.fnInteresMoratorioMAVI(@IDDetalle)
        SELECT @MoratorioAPagar = @InteresesMoratorios
        -- SELECT @TotalInteresMoratorio = @InteresesMoratorios       
        --SELECT @InteresesMoratorios as 'Antes'  -- yrg
        IF @InteresesMoratorios <= @MontoMinimoMor AND  @InteresesMoratorios > 0
        BEGIN  -- 
          -- Aun cuando el usuario esté autorizado a condonar moratorios, si estos son menores al monto mínimo se condonan y registran
          IF EXISTS(SELECT * FROM CondonaMorxSistMAVI WITH (NOLOCK) WHERE IDCobro = @ID AND IDMov = @IDDetalle AND Estatus = 'ALTA')
            UPDATE CondonaMorxSistMAVI WITH (ROWLOCK)
               SET MontoOriginal = @InteresesMoratorios,
                   MontoCondonado =  @InteresesMoratorios
             WHERE IDCobro = @ID AND IDMov = @IDDetalle AND Estatus = 'ALTA'

          ELSE
            INSERT INTO CondonaMorxSistMAVI(Usuario,  FechaAutorizacion, IDMov,			RenglonMov,	Mov,	MovID,		MontoOriginal,		  MontoCondonado, TipoCondonacion, Estatus, IDCobro)
                                       VALUES(@Usuario, Getdate(),		 @IDDetalle,	0,			@Aplica, @AplicaID, @InteresesMoratorios, @InteresesMoratorios, 'Por Sistema', 'ALTA', @ID)	
          SELECT @InteresesMoratorios = 0
		END   --SELECT @CondonaMoratorios   = 1	
          --ELSE
          --SELECT @InteresesMoratorios as 'SELECT @InteresesMoratorios'   -- yrg
        IF @InteresesMoratorios > 0  AND @InteresesMoratorios > @MontoMinimoMor  --ISNULL(@MontoMinimoMor,0) AND  @InteresesMoratorios > 0
        BEGIN
          IF @SumaImporte + @InteresesMoratorios > @ImporteTotal  SELECT @MoratorioAPagar = @ImporteTotal - @SumaImporte
          -- antes arriba SELECT @InteresesMoratorios = @ImporteTotal - @SumaImporte
            SELECT @SumaImporte = @SumaImporte + @MoratorioAPagar  -- antes @InteresesMoratorios		      		
     
            --select @InteresesMoratorios as 'Importe Moratorio'  -- yrg
            IF @InteresesMoratorios > 0 --AND @MoratorioAPagar > 0   -- Ivan
            BEGIN
              INSERT NegociaMoratoriosMAVI( IDCobro, Estacion, Usuario, Mov, MovID, ImporteReal, ImporteAPagar, ImporteMoratorio, ImporteACondonar, MoratorioAPagar, Origen, OrigenID)
--              VALUES(@ID, @Estacion, @Usuario, @Aplica, @AplicaId, @Capital, 0, @InteresesMoratorios, 0, @MoratorioAPagar, @Origen, @OrigenID)
              VALUES(@ID, @Estacion, @Usuario, @Aplica, @AplicaId, @Capital, 0, @InteresesMoratorios, 0, @MoratorioAPagar, @PadreMAviPend, @PadreMaviIDPend)  ----pzamudio

			IF @Aplica IN ('Nota Cargo','Nota Cargo VIU')
					BEGIN
					  SELECT @AplicaNota= ISNULL(Mov,'NA'), @AplicaIDNota = ISNULL(MovID,'NA') FROM #NotaXCanc WHERE Mov=@Aplica and MovID=@AplicaID 
						  IF @AplicaNota <> 'NA' AND @AplicaIDNota <> 'NA'
							UPDATE NegociaMoratoriosMAVI WITH (ROWLOCK) SET NotaCreditoxCanc = '1' WHERE IDCobro = @ID AND Estacion = @Estacion AND Mov = @Aplica AND MovID = @AplicaID      
					  END     

/* esta de mas pzamudio
              IF @Aplica in ('Contra Recibo','Contra Recibo Inst')
              BEGIN
                SELECT @MovPadre1 = Origen, @MovIDPadre = OrigenID FROM CXC WHERE ID = @IDDetalle
                SELECT @MovPadre = Origen, @MovPadreID = MovId FROM CXC WHERE Mov = @MovPadre1 AND MovID = @MovIDPadre
                UPDATE NegociaMoratoriosMAVI
                   SET Origen = @MovPadre, OrigenID = @MovPadreID
                 WHERE IDCobro = @ID AND Mov = @Aplica AND MovID = @AplicaId
              END
*/              
            END
        END
      
      END 
      ELSE   SELECT @InteresesMoratorios = 0
      -- Intereses Moratorios

      FETCH NEXT FROM crAplica INTO @Aplica, @AplicaID, @Vencimiento, @AplicaMovTipo, @Capital, @InteresesOrdinarios, @InteresesFijos, @InteresesMoratorios, @Origen, @OrigenID
      ,@PadreMAviPend, @PadreMaviIDPend   ---pzamudio    
    END
  END
  CLOSE crAplica
  DEALLOCATE crAplica

  -- 2da  pasada a evaluar doctos mientras alcance el importe del cobro segun la opcion seleccionada 
  --select @SumaImporte as 'SumaImporte'
  --select @ImporteTotal as '@ImporteTotal'
  --IF @SumaImporte <=  @ImporteTotal 
  IF @Modulo = 'CXC' AND @SumaImporte <=  @ImporteTotal 
  BEGIN
    SELECT @Empresa = Empresa, @Sucursal = Sucursal, @Hoy = FechaEmision, @Moneda = Moneda, @TipoCambio = TipoCambio, @Contacto = Cliente   FROM Cxc WITH (NOLOCK) WHERE ID = @ID 
    


    DECLARE crDocto CURSOR FOR
     SELECT p.Mov, p.MovID, p.Vencimiento, mt.Clave, ROUND(ISNULL(p.Saldo*mt.Factor*p.MovTipoCambio/@TipoCambio, 0.0),2), ISNULL(p.InteresesOrdinarios*mt.Factor*p.MovTipoCambio/@TipoCambio, 0.0), ISNULL(p.InteresesFijos*p.MovTipoCambio/@TipoCambio, 0.0), 
    ISNULL(p.InteresesMoratorios*mt.Factor*p.MovTipoCambio/@TipoCambio, 0.0), ISNULL(p.Origen,p.Mov), ISNULL(p.OrigenID, p.MovID)
       ,p.PadreMAVI , p.PadreIDMAVI   ---pzamudio       
       FROM CxcPendiente p WITH (NOLOCK)
       JOIN MovTipo mt WITH (NOLOCK) ON mt.Modulo = @Modulo AND mt.Mov = p.Mov
       LEFT OUTER JOIN CfgAplicaOrden a WITH (NOLOCK) ON a.Modulo = @Modulo AND a.Mov = p.Mov
       LEFT OUTER JOIN Cxc r WITH (NOLOCK) ON r.ID = p.RamaID
       LEFT OUTER JOIN TipoAmortizacion ta WITH (NOLOCK) ON ta.TipoAmortizacion = r.TipoAmortizacion
      WHERE p.Empresa = @Empresa AND p.Cliente = @Contacto AND mt.Clave NOT IN ('CXC.SCH','CXC.SD', 'CXC.NC')
      ORDER BY a.Orden, p.Vencimiento, p.Mov, p.MovID
    --SELECT @DesglosarImpuestos = ISNULL(CxcCobroImpuestos, 0) FROM EmpresaCfg2 WHERE Empresa = @Empresa
  END ELSE
    RETURN

  OPEN crDocto
  FETCH NEXT FROM crDocto INTO @Aplica, @AplicaID, @Vencimiento, @AplicaMovTipo, @Capital, @InteresesOrdinarios, @InteresesFijos, @InteresesMoratorios, @Origen, @OrigenID 
  ,@PadreMAviPend, @PadreMaviIDPend   ---pzamudio
  WHILE @@FETCH_STATUS <> -1 AND ((@SugerirPago = 'SALDO VENCIDO' AND @Vencimiento<=@Hoy AND @ImporteTotal > @SumaImporte ) OR (@SugerirPago = 'IMPORTE ESPECIFICO' AND @ImporteTotal > @SumaImporte) OR @SugerirPago = 'SALDO TOTAL')
  BEGIN
    IF @@FETCH_STATUS <> -2 
    BEGIN  
      -- Capital
      --select @SumaImporte as 'SumaImporte antes'  --yrg
      /*select @Aplica as 'Mov'
      select @AplicaID as 'MovID'
      select @Capital as 'Capital'-- yrg  */
--      select @OrigenID as 'Origen'  -- yrg
      SELECT @ImpReal = @Capital
      IF @SumaImporte + @Capital > @ImporteTotal SELECT @Capital = @ImporteTotal - @SumaImporte
--      SELECT @SumaImporte = @SumaImporte + @Capital
      --select @SumaImporte as 'SumaImporte'
      IF @Capital > 0
      BEGIN
        SELECT @SumaImporte = @SumaImporte + @Capital
 
        IF EXISTS(SELECT * FROM NegociaMoratoriosMAVI WITH (NOLOCK) WHERE IDCobro = @ID AND Estacion = @Estacion AND Mov = @Aplica AND MovID = @AplicaID)
        begin  -- yrg
          --select 'Entra a act'  -- yrg
          UPDATE NegociaMoratoriosMAVI WITH (ROWLOCK)
             SET ImporteAPagar = @Capital
           WHERE Estacion = @Estacion
             --AND Usuario  = @Usuario 
             AND Mov      = @Aplica
             AND MovID    = @AplicaID
             AND IDCobro  = @ID
             
        IF @Aplica IN ('Nota Cargo','Nota Cargo VIU')
					BEGIN
					  SELECT @AplicaNota= ISNULL(Mov,'NA'), @AplicaIDNota = ISNULL(MovID,'NA') FROM #NotaXCanc WHERE Mov=@Aplica and MovID=@AplicaID 
						  IF @AplicaNota <> 'NA' AND @AplicaIDNota <> 'NA'
							UPDATE NegociaMoratoriosMAVI WITH (ROWLOCK) SET NotaCreditoxCanc = '1' WHERE IDCobro = @ID AND Estacion = @Estacion AND Mov = @Aplica AND MovID = @AplicaID      
					  END     
                 
        end 
        ELSE 
        BEGIN
          INSERT NegociaMoratoriosMAVI( IDCobro, Estacion, Usuario, Mov, MovID, ImporteReal, ImporteAPagar, ImporteMoratorio, ImporteACondonar, Origen, OrigenID)
--          VALUES(@ID, @Estacion, @Usuario, @Aplica, @AplicaId, @ImpReal, @Capital, 0, 0, @Origen, @OrigenID)
          VALUES(@ID, @Estacion, @Usuario, @Aplica, @AplicaId, @ImpReal, @Capital, 0, 0, @PadreMAviPend, @PadreMaviIDPend)
          
          IF @Aplica IN ('Nota Cargo','Nota Cargo VIU')
					BEGIN
					  SELECT @AplicaNota= ISNULL(Mov,'NA'), @AplicaIDNota = ISNULL(MovID,'NA') FROM #NotaXCanc WHERE Mov=@Aplica and MovID=@AplicaID 
						  IF @AplicaNota <> 'NA' AND @AplicaIDNota <> 'NA'
							UPDATE NegociaMoratoriosMAVI WITH (ROWLOCK) SET NotaCreditoxCanc = '1' WHERE IDCobro = @ID AND Estacion = @Estacion AND Mov = @Aplica AND MovID = @AplicaID      
					  END     

/* pzamudio esta demas
          IF @Aplica in ('Contra Recibo','Contra Recibo Inst')
          BEGIN
            SELECT @MovPadre1 = Origen, @MovIDPadre = OrigenID FROM CXC WHERE ID = @IDDetalle
            SELECT @MovPadre = Origen, @MovPadreID = MovId FROM CXC WHERE Mov = @MovPadre1 AND MovID = @MovIDPadre
            UPDATE NegociaMoratoriosMAVI
               SET Origen = @MovPadre, OrigenID = @MovPadreID
             WHERE IDCobro = @ID AND Mov = @Aplica AND MovID = @AplicaId
          END
*/          
        END
      END
      FETCH NEXT FROM crDocto INTO @Aplica, @AplicaID, @Vencimiento, @AplicaMovTipo, @Capital, @InteresesOrdinarios, @InteresesFijos, @InteresesMoratorios, @Origen, @OrigenID
      ,@PadreMAviPend, @PadreMaviIDPend   ---pzamudio
    END
  END 
  CLOSE crDocto
  DEALLOCATE crDocto
  --Select * from NegociaMoratoriosMAVI  -- yrg
  DROP TABLE #NotaXCanc
  -- Determina el tipo de pago q se esta haciendo
--  EXEC spTipoPagoBonifMAVI @SugerirPago, @ID
  EXEC spOrigenNCxCancMAVI @ID
  EXEC spOrigenCobrosInstMAVI @ID
  EXEC spTipoPagoBonifMAVI @SugerirPago, @ID
  -- Calcula Bnificaciones
  EXEC spBonifMonto	@ID
  -- Totaliza Capital + Mor - Bonif
  EXEC spImpTotalBonifMAVI @ID
  -- Actualiza el Origen de Ncargo x cancel
  

  RETURN
END
GO
