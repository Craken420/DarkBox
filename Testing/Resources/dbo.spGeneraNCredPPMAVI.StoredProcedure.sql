SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************/    
CREATE PROCEDURE [dbo].[spGeneraNCredPPMAVI]  
   @ID   int,                
   @Usuario varchar(10),                
   @Ok         int                OUTPUT,                
   @OkRef      varchar(255)       OUTPUT                     
                     
AS BEGIN               
  DECLARE                
    @Empresa   char(5),                
    @Sucursal   int,                
    @Hoy   datetime,                
    @Vencimiento  datetime,                
    @Moneda   char(10),                
    @TipoCambio   float,                
    @Contacto   char(10),                
    @Renglon   float,                
    @Aplica   varchar(20),                
    @AplicaID   varchar(20),                
    @ImpReal    money,                
    @MoratorioAPagar  money,                
    @Origen    varchar(20),                
    @OrigenID   varchar(20),                                  
    @MovPadre   varchar(20),                
    @MovPadre1   varchar(20),                
    @MovIDPadre   varchar(20),                
    @PagoPuntual money,                
    @UEN    int,                
    @MovCrear   varchar(20),                
    @Mov    varchar(20),                
    @IDCxc    int,                
    @FechaAplicacion datetime,                
    @CtaDinero   varchar(10),                
    @Concepto   varchar(50),                
    @IDPol    int,                
    @NumDoctos   int,                
    @ImpDocto   money,                           
    @MovID    varchar(20),                
    @TotalMov   money,                           
    @Referencia   varchar(100),                
    @CanalVenta   int,                
    @Impuestos   money,            
    @HayNotasCredCanc    int,          
    @DocsPend   int,                  
    @SdoDoc   money,          
    @ImpTotalBonif  money,  
    @DefImpuesto float,  
    @IDCxc2    int,
    @minbon    int,
    @maxbon    int,
    @mindet    int,
    @maxdet    int,
    @minbon2   int,
    @maxbon2   int,
    @mindet2   int,
    @maxdet2   int                
                
  SET @DocsPend = 0             
  SET @FechaAplicacion = GetDate()                
  SELECT @Empresa = Empresa, @Sucursal = Sucursal, @Hoy = FechaEmision, @Moneda = Moneda, @TipoCambio = TipoCambio, @Contacto = Cliente   FROM Cxc WITH(NOLOCK) WHERE ID = @ID                 
  -- OJO es importante tomar el concepto de cada politica                
  --IF             
  SELECT @HayNotasCredCanc = COUNT(*) FROM NegociaMoratoriosMAVI WITH(NOLOCK) WHERE IDCobro = @ID AND PagoPuntual > 0 AND NotaCreditoxCanc = '1'            
   	IF EXISTS(SELECT ID FROM tempdb.sys.sysobjects WHERE id=OBJECT_ID('tempdb.dbo.#crGenBonifP') AND type ='U')
		DROP TABLE #crGenBonifP 
		
		CREATE TABLE #crGenBonifP(
			ID int Primary Key identity(1,1) Not Null,	
			PagoPuntual money Null,
			Origen Varchar(25) Null,
			OrigenID Varchar(25) Null,
			IDPagoPuntual int Null
		)	
  
 	IF EXISTS(SELECT ID FROM tempdb.sys.sysobjects WHERE id=OBJECT_ID('tempdb.dbo.#crDetNCBonifPP') AND type ='U')
		DROP TABLE #crDetNCBonifPP   
        
       CREATE TABLE #crDetNCBonifPP(
			ID int primary key identity(1,1) not Null,
			Mov  Varchar(25) Null, 
			MovID Varchar(25) Null, 
			PagoPuntual money Null
       )  
       
   	IF EXISTS(SELECT ID FROM tempdb.sys.sysobjects WHERE id=OBJECT_ID('tempdb.dbo.#crGenBonifPP2') AND type ='U')
		DROP TABLE #crGenBonifPP2 
		CREATE TABLE #crGenBonifPP2(
			ID int Primary Key identity(1,1) Not Null,	
			PagoPuntual money Null,
			Origen Varchar(25) Null,
			OrigenID Varchar(25) Null,
			IDPagoPuntual int Null
		)
 	IF EXISTS(SELECT ID FROM tempdb.sys.sysobjects WHERE id=OBJECT_ID('tempdb.dbo.#crDetNCBonifPP2') AND type ='U')
		DROP TABLE #crDetNCBonifPP2   
        
       CREATE TABLE #crDetNCBonifPP2(
			ID int primary key identity(1,1) not Null,
			Mov  Varchar(25) Null, 
			MovID Varchar(25) Null, 
			PagoPuntual money Null
       )
  IF @HayNotasCredCanc = 0            
  BEGIN  -- 1          
   --select 'No hay notasx canc'      
    insert into #crGenBonifP (PagoPuntual,Origen,OrigenID,IDPagoPuntual)               
     SELECT SUM(ISNULL(PagoPuntual,0)), Origen, OrigenId, IDPagoPuntual                
       FROM NegociaMoratoriosMAVI WITH(NOLOCK) WHERE IDCobro = @ID  AND PagoPuntual > 0                  
      GROUP BY Origen, OrigenId, IDPagoPuntual                
    
    select @minbon=MIN(ID), @maxbon=MAX(ID) From #crGenBonifP 
                  
    
    WHILE @minbon <= @maxbon                 
    BEGIN  -- 2               
         select @PagoPuntual=PagoPuntual, @Origen=Origen, @OrigenID=OrigenID,@IDPol=IDPagoPuntual From #crGenBonifP where ID=@minbon
           
        SET @ImpTotalBonif = @PagoPuntual                      
        SET @Renglon = 1024.0                 
        SELECT @UEN = UEN, @CanalVenta = ClienteEnviarA FROM CXC WITH(NOLOCK) WHERE Mov = @Origen AND MovId = @OrigenID                 
                
        SELECT @MovPadre = @Origen                 
        SELECT @MovCrear = ISNULL(MovCrear, 'Nota Credito')  FROM MovCrearBonifMAVI WITH(NOLOCK) WHERE Mov = @Movpadre AND UEN = @UEN                                           
                   
        IF @MovCrear IS NULL SELECT @MovCrear = 'Nota Credito'                                 
                        
        SELECT @Concepto = Concepto                
          FROM MaviBonificacionConf WITH(NOLOCK) where ID = @IDPol                                           
          
        SELECT @DocsPend = Count(*) FROM CXC WITH(NOLOCK) WHERE PadreMAVI = @Origen AND PadreIDMAVI = @OrigenID AND Estatus = 'PENDIENTE'            
        IF @DocsPend > 0            
        BEGIN  -- 3           
          INSERT INTO Cxc(Empresa, Mov, MovID, FechaEmision, UltimoCambio, Concepto, Proyecto, Moneda, TipoCambio, Usuario, Autorizacion, Referencia, DocFuente,                 
                        Observaciones, Estatus, Situacion, SituacionFecha, SituacionUsuario, SituacionNota, Cliente, ClienteEnviarA, ClienteMoneda, ClienteTipoCambio,   -- 2                
                        Cobrador, Condicion, Vencimiento, FormaCobro, CtaDinero, Importe, Impuestos, Retencion, AplicaManual, ConDesglose, FormaCobro1, FormaCobro2,                 
                        FormaCobro3, FormaCobro4, FormaCobro5, Referencia1, Referencia2, Referencia3, Referencia4, Referencia5, Importe1, Importe2, Importe3,   --4                
                        Importe4, Importe5, Cambio, DelEfectivo, Agente, ComisionTotal, ComisionPendiente, MovAplica, MovAplicaID, OrigenTipo, Origen, OrigenID,                 
                        Poliza, PolizaID, FechaConclusion, FechaCancelacion, Dinero, DineroID, DineroCtaDinero, ConTramites, VIN, Sucursal, SucursalOrigen, Cajero,                 
                        UEN, PersonalCobrador, FechaOriginal, Nota, Comentarios, LineaCredito, TipoAmortizacion, TipoTasa, Amortizaciones, Comisiones, ComisionesIVA,                 
                        FechaRevision, ContUso, TieneTasaEsp, TasaEsp, Codigo)                
          VALUES (@Empresa, @MovCrear, NULL, cast(convert(varchar, @FechaAplicacion, 101) as datetime), @FechaAplicacion, @Concepto, NULL, @Moneda, @TipoCambio, @Usuario, NULL, @Referencia, NULL, --1                
                        NULL, 'SINAFECTAR', NULL, NULL, NULL, NULL, @Contacto, @CanalVenta, @Moneda, @TipoCambio,   --2                
                        NULL, NULL, cast(convert(varchar, @FechaAplicacion, 101) as datetime), NULL, @CtaDinero, NULL, NULL, NULL, 1, 0, NULL, NULL,   -- 3                
                        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,  -- 4                
                        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, -- 5                
                        NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, @Sucursal, @Sucursal, NULL,                 
                        @UEN, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL, NULL, NULL,                 
                        NULL, NULL, 0, NULL, NULL)  -- 7                
                
          SELECT @IDCxc = @@IDENTITY                
                
        --SELECT @IDCxc as 'Nota Cred'   -- yrg                
        -- Cursor para el detalle de la NCred               
                           
          insert into #crDetNCBonifPP (Mov,MovID,PagoPuntual)               
           SELECT Mov, MovID, PagoPuntual                 
             FROM NegociaMoratoriosMAVI WITH(NOLOCK) WHERE IDCobro = @ID AND PagoPuntual > 0                  
              AND Origen = @Origen AND OrigenId = @OrigenID --AND IDPagoPuntual = @IdPol                
          select @mindet=MIN(ID), @maxdet=MAX(ID) From #crDetNCBonifPP                 
                
          WHILE @mindet <= @maxdet                 
          BEGIN  -- 4          
              select @Mov=Mov, @MovID=MovID, @ImpDocto=PagoPuntual From #crDetNCBonifPP Where ID=@mindet
              
              SELECT @SdoDoc = Saldo FROM CXC WITH(NOLOCK) WHERE Mov = @Mov AND MovId = @MovId                                       

              IF @ImpDocto > @SdoDoc--                  
              BEGIN    -- 5        
     --          select 'Bonif > SdoDoc'            
                  
                SELECT @ImpDocto = @SdoDoc                  
       --        SELECT @ImpDocto as 'Importe detalle NC'                  
                SET @ImpTotalBonif = @ImpTotalBonif - @ImpDocto                  
               --insert cxcd                
                INSERT INTO CxcD(ID, Renglon, RenglonSub, Aplica, AplicaID, Importe, Fecha, Sucursal, SucursalOrigen, DescuentoRecargos, InteresesOrdinarios,              
                                 InteresesMoratorios, InteresesOrdinariosQuita, InteresesMoratoriosQuita, ImpuestoAdicional, Retencion)                
                VALUES(@IDCxc, @Renglon, 0, @Mov, @MovId, @ImpDocto, NULL, @Sucursal, @Sucursal, NULL, NULL, NULL, NULL, NULL, NULL, NULL)                
                
                SET @Renglon = @Renglon + 1024.0                
                            
                UPDATE NegociaMoratoriosMAVI WITH(ROWLOCK)                 
                   SET NotaCredBonId = @IDCxc                
                 WHERE IDCobro = @ID                  
                   AND Origen = @Origen AND OrigenId = @OrigenID  AND IDPagoPuntual = @IdPol                 
          
              END -- 5                  
              ELSE                  
              BEGIN  -- 6                                      

                IF @ImpDocto <= @SdoDoc --                   
                BEGIN  -- 7   
 
                SET @ImpTotalBonif = @ImpTotalBonif - @ImpDocto                          

                  -- antes 14.05.2010 SET @ImpTotalBonif = @ImpTotalBonif - @ImpDocto                  
              -- SET @ImpTotalBonif = @ImpDocto       
         --         select 'ImpBonif <= SdoDoc'      
           --      select @ImpDocto as 'ImpNcredDetalle 2'                 
                  INSERT INTO CxcD(ID, Renglon, RenglonSub, Aplica, AplicaID, Importe, Fecha, Sucursal, SucursalOrigen, DescuentoRecargos, InteresesOrdinarios,                   
                                  InteresesMoratorios, InteresesOrdinariosQuita, InteresesMoratoriosQuita, ImpuestoAdicional, Retencion)                  
                  VALUES(@IDCxc, @Renglon, 0, @Mov, @MovId, @ImpDocto, NULL, @Sucursal, @Sucursal, NULL, NULL, NULL, NULL, NULL, NULL, NULL)                  
                  
                  SET @Renglon = @Renglon + 1024.0                  
                         
                  UPDATE NegociaMoratoriosMAVI WITH(ROWLOCK)                  
                     SET NotaCredBonId = @IDCxc                  
                   WHERE IDCobro = @ID                    
                     AND Origen = @Origen AND OrigenId = @OrigenID  AND IDPagoPuntual = @IdPol            
                END   -- 7                
              END -- 6                 
          
              
            SET @mindet = @mindet + 1                
          END  -- 4                 
                      
         
          SELECT @Impuestos = SUM(d.Importe*isnull(ca.IVAFiscal,0.00))                
            FROM CXCD d WITH(NOLOCK)                
            JOIN CxcAplica ca WITH(NOLOCK) ON d.Aplica = ca.Mov AND d.AplicaID = ca.MovID AND ca.Empresa = @Empresa                
           WHERE d.ID = @IDCxc                
                
          SELECT @TotalMov = SUM(d.Importe-isnull(d.Importe*ca.IVAFiscal,0)) --d.Aplica, d.AplicaID, ca.Mov, ca.MovID, ca.Saldo, ca.IVAFiscal,  ca.Saldo*ca.IVAFiscal                
            FROM CXCD d WITH(NOLOCK)               
            JOIN CxcAplica ca WITH(NOLOCK) ON d.Aplica = ca.Mov AND d.AplicaID = ca.MovID AND ca.Empresa = @Empresa                
           WHERE d.ID = @IDCxc                
                    
          UPDATE CXC WITH(ROWLOCK)               
             SET Importe = isnull(ROUND(@TotalMov,2),0.00),                 
                 Impuestos = isnull(ROUND(@Impuestos,2),0.00),                
                 Saldo = isnull(ROUND(@TotalMov,2),0.00) + isnull(ROUND(@impuestos,2),0.00),                
                 IDCobroBonifMAVI = @ID                
           WHERE ID = @IDCxc                
        END -- 3             
       --select @TotalMov as 'TotalMov'  -- yrg                                        
  IF @IDCxc > 0            
  BEGIN     -- aa    
   EXEC spAfectar 'CXC', @IDCxc, 'AFECTAR', 'Todo', NULL, @Usuario,  NULL, 1, @Ok OUTPUT, @OkRef OUTPUT,NULL, @Conexion = 1   --1 dentro de trans                
   --select @OK as 'Ok NCred'                
   --select @OKRef as 'OkRef NCred'                
   INSERT INTO DetalleAfectacionMAVI( IDCobro, ID, Mov, MovID, ValorOK, ValorOKRef) VALUES(@ID, @IDCxc, @MovCrear, NULL, @Ok, @OkRef )                                         
  END -- aa     

        IF @ImpTotalBonif > 0  -- Aun sobra bonificacion        
        BEGIN  -- bb              
            SELECT @DefImpuesto = DefImpuesto FROM EmpresaGral WITH(NOLOCK) WHERE Empresa = @Empresa        
            INSERT INTO Cxc(Empresa, Mov, MovID, FechaEmision, UltimoCambio, Concepto, Proyecto, Moneda, TipoCambio, Usuario, Autorizacion, Referencia, DocFuente,         
                             Observaciones, Estatus, Situacion, SituacionFecha, SituacionUsuario, SituacionNota, Cliente, ClienteEnviarA, ClienteMoneda, ClienteTipoCambio,   -- 2        
                             Cobrador, Condicion, Vencimiento, FormaCobro, CtaDinero, Importe, Impuestos, Retencion, AplicaManual, ConDesglose, FormaCobro1, FormaCobro2,         
                             FormaCobro3, FormaCobro4, FormaCobro5, Referencia1, Referencia2, Referencia3, Referencia4, Referencia5, Importe1, Importe2, Importe3,   --4        
                             Importe4, Importe5, Cambio, DelEfectivo, Agente, ComisionTotal, ComisionPendiente, MovAplica, MovAplicaID, OrigenTipo, Origen, OrigenID,         
                             Poliza, PolizaID, FechaConclusion, FechaCancelacion, Dinero, DineroID, DineroCtaDinero, ConTramites, VIN, Sucursal, SucursalOrigen, Cajero,         
                             UEN, PersonalCobrador, FechaOriginal, Nota, Comentarios, LineaCredito, TipoAmortizacion, TipoTasa, Amortizaciones, Comisiones, ComisionesIVA,         
                             FechaRevision, ContUso, TieneTasaEsp, TasaEsp, Codigo)        
            VALUES (@Empresa, @MovCrear, NULL, cast(convert(varchar, @FechaAplicacion, 101) as datetime), @FechaAplicacion, @Concepto, NULL, @Moneda, @TipoCambio, @Usuario, NULL, @Referencia, NULL, --1        
                           NULL, 'SINAFECTAR', NULL, NULL, NULL, NULL, @Contacto, @CanalVenta, @Moneda, @TipoCambio,   --2        
                          NULL, NULL, @FechaAplicacion, NULL, @CtaDinero, NULL, NULL, NULL, 0, 0, NULL, NULL,   -- 3        
                          NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,  -- 4        
                          NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, -- 5        
                          NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, @Sucursal, @Sucursal, NULL,         
                          @UEN, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL, NULL, NULL,         
                          NULL, NULL, 0, NULL, NULL)  -- 7        
        
            SELECT @IDCxc2 = @@IDENTITY        
        
            UPDATE CXC WITH(ROWLOCK)        
               SET Importe = ROUND(@ImpTotalBonif/ (1+@DefImpuesto/100.0), 2),        
                   Impuestos = ROUND(@ImpTotalBonif/ (1+@DefImpuesto/100.0), 2)*(@DefImpuesto/100.0),       
                   Saldo = ROUND(@ImpTotalBonif/ (1+@DefImpuesto/100.0), 2) + ROUND(@ImpTotalBonif/ (1+@DefImpuesto/100.0), 2)*(@DefImpuesto/100.0),        
                   --select Importe = ROUND(1000/1.15,2)        
                   --select Impuesto = ROUND(1000/1.15*(15/100.0),2)        
                   IDCobroBonifMAVI = @ID        
             WHERE ID = @IDCxc2        
        
            EXEC spAfectar 'CXC', @IDCxc2, 'AFECTAR', 'Todo', NULL, @Usuario,  NULL, 1, @Ok OUTPUT, @OkRef OUTPUT,NULL, @Conexion = 1  --1 dentro de trans        
                
            INSERT INTO DetalleAfectacionMAVI( IDCobro, ID, Mov, MovID, ValorOK, ValorOKRef) VALUES(@ID, @IDCxc2, @MovCrear, NULL, @Ok, @OkRef )         
        END    -- bb          
         
      SET @minbon = @minbon + 1                   
    END --   2                
             
  END  -- 1            
  ELSE    -- Hay Notas de cred x canc          
  BEGIN  -- 1.1          
    insert into #crGenBonifP (PagoPuntual,Origen,OrigenID,IDPagoPuntual)               
     SELECT SUM(ISNULL(PagoPuntual,0)), Origen, OrigenId, IDPagoPuntual                
       FROM NegociaMoratoriosMAVI WITH(NOLOCK) WHERE IDCobro = @ID  AND PagoPuntual > 0 AND NotaCreditoxCanc = '1'                 
      GROUP BY Origen, OrigenId, IDPagoPuntual                
    Select @minbon=MIN(ID), @maxbon=MAX(ID) from #crGenBonifP                
                    
    WHILE @minbon <= @maxbon                 
    BEGIN  -- 1.2                
        select @PagoPuntual=PagoPuntual, @Origen=Origen, @OrigenID=OrigenID, @IDPol=IDPagoPuntual From #crGenBonifP Where ID=@minbon 
             
        SET @Renglon = 1024.0                 
        SELECT @UEN = UEN, @CanalVenta = ClienteEnviarA FROM CXC WITH(NOLOCK) WHERE Mov = @Origen AND MovId = @OrigenID                 
                
        SELECT @MovPadre = @Origen                 
        SELECT @MovCrear = ISNULL(MovCrear, 'Nota Credito')  FROM MovCrearBonifMAVI WITH(NOLOCK) WHERE Mov = @Movpadre AND UEN = @UEN                
                        
        IF @MovPadre = 'Credilana' SET @MovCrear = 'Nota Credito'            
        IF @MovPadre = 'Prestamo Personal' SET @MovCrear = 'Nota Credito VIU'            
        IF @MovCrear IS NULL SELECT @MovCrear = 'Nota Credito'                                 
                        
        SELECT @Concepto = Concepto                
          FROM MaviBonificacionConf WITH(NOLOCK) where ID = @IDPol                               
                 
        INSERT INTO Cxc(Empresa, Mov, MovID, FechaEmision, UltimoCambio, Concepto, Proyecto, Moneda, TipoCambio, Usuario, Autorizacion, Referencia, DocFuente,                 
                        Observaciones, Estatus, Situacion, SituacionFecha, SituacionUsuario, SituacionNota, Cliente, ClienteEnviarA, ClienteMoneda, ClienteTipoCambio,   -- 2                
                        Cobrador, Condicion, Vencimiento, FormaCobro, CtaDinero, Importe, Impuestos, Retencion, AplicaManual, ConDesglose, FormaCobro1, FormaCobro2,                 
                        FormaCobro3, FormaCobro4, FormaCobro5, Referencia1, Referencia2, Referencia3, Referencia4, Referencia5, Importe1, Importe2, Importe3,   --4                
                        Importe4, Importe5, Cambio, DelEfectivo, Agente, ComisionTotal, ComisionPendiente, MovAplica, MovAplicaID, OrigenTipo, Origen, OrigenID,                 
                        Poliza, PolizaID, FechaConclusion, FechaCancelacion, Dinero, DineroID, DineroCtaDinero, ConTramites, VIN, Sucursal, SucursalOrigen, Cajero,                 
                        UEN, PersonalCobrador, FechaOriginal, Nota, Comentarios, LineaCredito, TipoAmortizacion, TipoTasa, Amortizaciones, Comisiones, ComisionesIVA,                 
                        FechaRevision, ContUso, TieneTasaEsp, TasaEsp, Codigo)                
        VALUES (@Empresa, @MovCrear, NULL, cast(convert(varchar, @FechaAplicacion, 101) as datetime), @FechaAplicacion, @Concepto, NULL, @Moneda, @TipoCambio, @Usuario, NULL, @Referencia, NULL, --1                
                        NULL, 'SINAFECTAR', NULL, NULL, NULL, NULL, @Contacto, @CanalVenta, @Moneda, @TipoCambio,   --2                
                        NULL, NULL, cast(convert(varchar, @FechaAplicacion, 101) as datetime), NULL, @CtaDinero, NULL, NULL, NULL, 1, 0, NULL, NULL,   -- 3                
                        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,  -- 4                
                        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, -- 5                
                        NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, @Sucursal, @Sucursal, NULL,                 
                        @UEN, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL, NULL, NULL,                 
                        NULL, NULL, 0, NULL, NULL)  -- 7                
                
     SELECT @IDCxc = @@IDENTITY                
                
        --SELECT @IDCxc as 'Nota Cred'   -- yrg                
        -- Cursor para el detalle de la NCred                
        insert into #crDetNCBonifPP(Mov,MovID,PagoPuntual)                
         SELECT Mov, MovID, PagoPuntual                 
           FROM NegociaMoratoriosMAVI WITH(NOLOCK) WHERE IDCobro = @ID AND PagoPuntual > 0  AND NotaCreditoxCanc = '1'                      
            AND Origen = @Origen AND OrigenId = @OrigenID --AND IDPagoPuntual = @IdPol                
        Select @mindet=MIN(ID), @maxdet=MAX(ID) From #crDetNCBonifPP                 
              
        WHILE @mindet <= @maxdet                 
        BEGIN  -- 1.3                
             Select @Mov=Mov, @MovID=MovID, @ImpDocto=PagoPuntual From #crDetNCBonifPP Where ID=@mindet
            --insert cxcd                
            INSERT INTO CxcD(ID, Renglon, RenglonSub, Aplica, AplicaID, Importe, Fecha, Sucursal, SucursalOrigen, DescuentoRecargos, InteresesOrdinarios,                 
                             InteresesMoratorios, InteresesOrdinariosQuita, InteresesMoratoriosQuita, ImpuestoAdicional, Retencion)                
            VALUES(@IDCxc, @Renglon, 0, @Mov, @MovId, @ImpDocto, NULL, @Sucursal, @Sucursal, NULL, NULL, NULL, NULL, NULL, NULL, NULL)                
                
            SET @Renglon = @Renglon + 1024.0                
                            
            UPDATE NegociaMoratoriosMAVI WITH(ROWLOCK)                 
               SET NotaCredBonId = @IDCxc                
             WHERE IDCobro = @ID                  
               AND Origen = @Origen AND OrigenId = @OrigenID  AND IDPagoPuntual = @IdPol                 
                     
          SET @mindet=@mindet + 1                
        END  -- 1.3               
               
                
        ----SELECT @Impuestos = SUM(d.Importe*ca.IVAFiscal)--, sum(d.Importe-(d.Importe*ca.IVAFiscal)) --d.Aplica, d.AplicaID, ca.Mov, ca.MovID, ca.Saldo, ca.IVAFiscal,  ca.Saldo*ca.IVAFiscal                
        SELECT @Impuestos = SUM(d.Importe*isnull(ca.IVAFiscal,0.00))                
          FROM CXCD d WITH(NOLOCK)                
          JOIN CxcAplica ca WITH(NOLOCK) ON d.Aplica = ca.Mov AND d.AplicaID = ca.MovID AND ca.Empresa = @Empresa                
         WHERE d.ID = @IDCxc                
                
        SELECT @TotalMov = SUM(d.Importe-isnull(d.Importe*ca.IVAFiscal,0)) --d.Aplica, d.AplicaID, ca.Mov, ca.MovID, ca.Saldo, ca.IVAFiscal,  ca.Saldo*ca.IVAFiscal                
          FROM CXCD d WITH(NOLOCK)                
          JOIN CxcAplica ca WITH(NOLOCK) ON d.Aplica = ca.Mov AND d.AplicaID = ca.MovID AND ca.Empresa = @Empresa                
         WHERE d.ID = @IDCxc                
                    
        UPDATE CXC WITH(ROWLOCK)                
           SET Importe = isnull(ROUND(@TotalMov,2),0.00),                 
               Impuestos = isnull(ROUND(@Impuestos,2),0.00),                
               Saldo = isnull(ROUND(@TotalMov,2),0.00) + isnull(ROUND(@impuestos,2),0.00),                
               IDCobroBonifMAVI = @ID                
         WHERE ID = @IDCxc                
                
        --select @TotalMov as 'TotalMov'  -- yrg                        
                    
        EXEC spAfectar 'CXC', @IDCxc, 'AFECTAR', 'Todo', NULL, @Usuario,  NULL, 1, @Ok OUTPUT, @OkRef OUTPUT,NULL, @Conexion = 1   --1 dentro de trans                
        --select @OK as 'Ok NCred'                
        --select @OKRef as 'OkRef NCred'                
        INSERT INTO DetalleAfectacionMAVI( IDCobro, ID, Mov, MovID, ValorOK, ValorOKRef) VALUES(@ID, @IDCxc, @MovCrear, NULL, @Ok, @OkRef )                        
                
        --        SELECT @Referencia = RTRIM(@Origen)+'_'+RTRIM(@OrigenID)                
                
             
      SET @minbon = @minbon + 1                
      --FETCH NEXT FROM crGenBonif INTO @ContadoComercial, @Origen, @OrigenID, @IdPol                
    END -- 1.2                    
        
    -- Se generan las notas de cred normales cuando hay notas de credito por canc             
             
    insert into #crGenBonifPP2(PagoPuntual,Origen,OrigenID,IDPagoPuntual)                
     SELECT SUM(ISNULL(PagoPuntual,0)), Origen, OrigenId, IDPagoPuntual                
       FROM NegociaMoratoriosMAVI WITH(NOLOCK) WHERE IDCobro = @ID  AND PagoPuntual > 0 AND NotaCreditoxCanc is null                          
      GROUP BY Origen, OrigenId, IDPagoPuntual                
    select @minbon2=MIN(ID), @maxdet2=MAX(ID) From #crGenBonifPP2                
    
    WHILE @minbon2 <= @maxbon2                  
    BEGIN  --1.4               
        select @PagoPuntual=PagoPuntual, @Origen=Origen, @OrigenID=OrigenID,@IDPol=IDPagoPuntual From #crGenBonifPP2 Where ID=@minbon2      
        SET @Renglon = 1024.0                 
        SELECT @UEN = UEN, @CanalVenta = ClienteEnviarA FROM CXC WITH(NOLOCK) WHERE Mov = @Origen AND MovId = @OrigenID                 
                
        SELECT @MovPadre = @Origen                 
        SELECT @MovCrear = ISNULL(MovCrear, 'Nota Credito')  FROM MovCrearBonifMAVI WITH(NOLOCK) WHERE Mov = @Movpadre AND UEN = @UEN                                    
                   
        IF @MovCrear IS NULL SELECT @MovCrear = 'Nota Credito'                                 
                        
        SELECT @Concepto = Concepto                
          FROM MaviBonificacionConf WITH(NOLOCK) where ID = @IDPol                
                         
        --Bonificacion LIKE '%Contado Comercial%' AND Estatus = 'CONCLUIDO'                
                 
        INSERT INTO Cxc(Empresa, Mov, MovID, FechaEmision, UltimoCambio, Concepto, Proyecto, Moneda, TipoCambio, Usuario, Autorizacion, Referencia, DocFuente,                 
                        Observaciones, Estatus, Situacion, SituacionFecha, SituacionUsuario, SituacionNota, Cliente, ClienteEnviarA, ClienteMoneda, ClienteTipoCambio,   -- 2                
                        Cobrador, Condicion, Vencimiento, FormaCobro, CtaDinero, Importe, Impuestos, Retencion, AplicaManual, ConDesglose, FormaCobro1, FormaCobro2,                 
                        FormaCobro3, FormaCobro4, FormaCobro5, Referencia1, Referencia2, Referencia3, Referencia4, Referencia5, Importe1, Importe2, Importe3,   --4                
                        Importe4, Importe5, Cambio, DelEfectivo, Agente, ComisionTotal, ComisionPendiente, MovAplica, MovAplicaID, OrigenTipo, Origen, OrigenID,                 
                        Poliza, PolizaID, FechaConclusion, FechaCancelacion, Dinero, DineroID, DineroCtaDinero, ConTramites, VIN, Sucursal, SucursalOrigen, Cajero,                 
                        UEN, PersonalCobrador, FechaOriginal, Nota, Comentarios, LineaCredito, TipoAmortizacion, TipoTasa, Amortizaciones, Comisiones, ComisionesIVA,                 
                        FechaRevision, ContUso, TieneTasaEsp, TasaEsp, Codigo)                
        VALUES (@Empresa, @MovCrear, NULL, cast(convert(varchar, @FechaAplicacion, 101) as datetime), @FechaAplicacion, @Concepto, NULL, @Moneda, @TipoCambio, @Usuario, NULL, @Referencia, NULL, --1                
                        NULL, 'SINAFECTAR', NULL, NULL, NULL, NULL, @Contacto, @CanalVenta, @Moneda, @TipoCambio,   --2                
                        NULL, NULL, cast(convert(varchar, @FechaAplicacion, 101) as datetime), NULL, @CtaDinero, NULL, NULL, NULL, 1, 0, NULL, NULL,   -- 3                
                        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,  -- 4                
      NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, -- 5                
                        NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, @Sucursal, @Sucursal, NULL,                 
                        @UEN, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL, NULL, NULL,                 
NULL, NULL, 0, NULL, NULL)  -- 7                
                
        SELECT @IDCxc = @@IDENTITY                
                
        --SELECT @IDCxc as 'Nota Cred'   -- yrg                
        -- Cursor para el detalle de la NCred                
        insert into #crDetNCBonifPP2(Mov,MovID,PagoPuntual)                
         SELECT Mov, MovID, PagoPuntual                 
           FROM NegociaMoratoriosMAVI WITH(NOLOCK) WHERE IDCobro = @ID AND PagoPuntual > 0 AND NotaCreditoxCanc is null                  
            AND Origen = @Origen AND OrigenId = @OrigenID --AND IDPagoPuntual = @IdPol                
        select @mindet2=MIN(ID), @maxdet2=MAX(ID) From #crDetNCBonifPP2                 
                    
        WHILE @mindet2 <= @maxdet2                 
        BEGIN  --1.5                
             select @Mov=Mov, @MovID=MovID, @ImpDocto=PagoPuntual From #crDetNCBonifPP2 Where ID=@mindet2  
            --insert cxcd                
            -- verificar el sdo del docto      
            INSERT INTO CxcD(ID, Renglon, RenglonSub, Aplica, AplicaID, Importe, Fecha, Sucursal, SucursalOrigen, DescuentoRecargos, InteresesOrdinarios,                 
                             InteresesMoratorios, InteresesOrdinariosQuita, InteresesMoratoriosQuita, ImpuestoAdicional, Retencion)                
            VALUES(@IDCxc, @Renglon, 0, @Mov, @MovId, @ImpDocto, NULL, @Sucursal, @Sucursal, NULL, NULL, NULL, NULL, NULL, NULL, NULL)                
                
            SET @Renglon = @Renglon + 1024.0                
                            
            UPDATE NegociaMoratoriosMAVI WITH(ROWLOCK)                 
               SET NotaCredBonId = @IDCxc                
             WHERE IDCobro = @ID                  
               AND Origen = @Origen AND OrigenId = @OrigenID  AND IDPagoPuntual = @IdPol                 
                       
          set @mindet2 = @mindet2 + 1               
        END --1.5                
                
                
        ----SELECT @Impuestos = SUM(d.Importe*ca.IVAFiscal)--, sum(d.Importe-(d.Importe*ca.IVAFiscal)) --d.Aplica, d.AplicaID, ca.Mov, ca.MovID, ca.Saldo, ca.IVAFiscal,  ca.Saldo*ca.IVAFiscal                
        SELECT @Impuestos = SUM(d.Importe*isnull(ca.IVAFiscal,0.00))                
          FROM CXCD d WITH(NOLOCK)               
          JOIN CxcAplica ca WITH(NOLOCK) ON d.Aplica = ca.Mov AND d.AplicaID = ca.MovID AND ca.Empresa = @Empresa                
         WHERE d.ID = @IDCxc                
                
        SELECT @TotalMov = SUM(d.Importe-isnull(d.Importe*ca.IVAFiscal,0)) --d.Aplica, d.AplicaID, ca.Mov, ca.MovID, ca.Saldo, ca.IVAFiscal,  ca.Saldo*ca.IVAFiscal                
          FROM CXCD d WITH(NOLOCK)               
          JOIN CxcAplica ca WITH(NOLOCK) ON d.Aplica = ca.Mov AND d.AplicaID = ca.MovID AND ca.Empresa = @Empresa                
         WHERE d.ID = @IDCxc                
                    
        UPDATE CXC WITH(ROWLOCK)               
           SET Importe = isnull(ROUND(@TotalMov,2),0.00),                 
               Impuestos = isnull(ROUND(@Impuestos,2),0.00),                
               Saldo = isnull(ROUND(@TotalMov,2),0.00) + isnull(ROUND(@impuestos,2),0.00),                
               IDCobroBonifMAVI = @ID                
         WHERE ID = @IDCxc                
                
        --select @TotalMov as 'TotalMov'  -- yrg                
        -- Afectar el Cobro                                  
        EXEC spAfectar 'CXC', @IDCxc, 'AFECTAR', 'Todo', NULL, @Usuario,  NULL, 1, @Ok OUTPUT, @OkRef OUTPUT,NULL, @Conexion = 1  --1 dentro de trans                
        --select @OK as 'Ok NCred'                
        --select @OKRef as 'OkRef NCred'                
        INSERT INTO DetalleAfectacionMAVI( IDCobro, ID, Mov, MovID, ValorOK, ValorOKRef) VALUES(@ID, @IDCxc, @MovCrear, NULL, @Ok, @OkRef )                                              
                
		     
      SET @minbon2 = @minbon2 + 1                
    END -- 2                    
               
              
  END                
END                            
RETURN   

GO
