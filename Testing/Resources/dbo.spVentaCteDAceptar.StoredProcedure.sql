SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
-- ========================================================================================================================================    
-- NOMBRE   : spVentaCteDAceptar    
-- AUTOR    : 
-- FECHA CREACION : 
-- DESARROLLO     : 
-- DESCRIPCION    : 
-- uso:  spVentaCteDAceptar 26, 250027, 4159012, 'VTAS.SD', 0
-- ========================================================================================================================================    
-- 25/jul/2016 - jacm se corrige para devoluciones parciales
-- ========================================================================================================================================   
-- ========================================================================================================================================    
-- MODIFICACION
-- AUTOR: ERIKA JEANETTE PEREZ OROZCO
-- FECHA: 26/04/2018
-- DESCRIPCION: SE AGREGO UNA CONDICION PARA SABER SI YA TIENE DATOS EN LA TABLA VENTAD, SI TIENE YA NO INSERTARA MAS, ESTO PASARA CUANDO 
--				LA VENTA SEA EN PUNTO DE VENTA.
-- ======================================================================================================================================== 
-- ========================================================================================================================================    
-- MODIFICACION
-- AUTOR: ERIKA JEANETTE PEREZ OROZCO
-- FECHA: 25/07/2018
-- DESCRIPCION: SE VOLVIO AGREGAR LA CONDICION DEL DETALLE DE ARTICULOS Y UNA ACTUALIZACION EN LOS PUNTOS GENERADOS DE LA FACTURA QUE SE QUIERE DEVOLVER.
-- FECHA: 18/09/2018
-- DESCRIPCION: SE CORRIGIO EL UPDATE DE PUNTOS A REDIMIR EN LAS DEVOLUCIONES.
-- ======================================================================================================================================== 

CREATE PROCEDURE [dbo].[spVentaCteDAceptar] @Sucursal int,
@Estacion int,
@VentaID int,
@MovTipo char(20),
@CopiarAplicacion bit = 0,
@CopiaridVenta int = 0
--set @Sucursal = 26
--set @Estacion = 250027
--set @VentaID =  4159194
--set @MovTipo = 'VTAS.SD'
--set @CopiarAplicacion = 0

AS
BEGIN
  DECLARE @Empresa char(5),
          @ID int,
          @Mov char(20),
          @MovID varchar(20),
          @MovReferencia varchar(50),
          @TieneAlgo bit,
          @Directo bit,
          @Cliente char(10),
          @Renglon float,
          @RenglonID int,
          @VentaDRenglon float,
          @VentaDRenglonID int,
          @VentaDRenglonSub int,
          @RenglonTipo char(1),
          @ZonaImpuesto varchar(30),
          @Cantidad float,
          @CantidadInventario float,
          @Almacen char(10),
          @Codigo varchar(50),
          @Articulo char(20),
          @SubCuenta varchar(50),
          @Unidad varchar(50),
          @Precio money,
          @DescuentoTipo char(1),
          @DescuentoLinea money,
          @Impuesto1 float,
          @Impuesto2 float,
          @Impuesto3 money,
          @DescripcionExtra varchar(100),
          @Costo money,
          @ContUso varchar(20),
          @Aplica char(20),
          @AplicaID char(20),
          @Agente char(10),
          @AgenteD char(10),
          @Descuento varchar(30),
          @DescuentoGlobal float,
          @FormaPagoTipo varchar(50),
          @SobrePrecio float,
          @ArtTipo varchar(20),
          @Departamento int,
          @DepartamentoD int,
          @DescuentoImporte money,
          @CfgSeriesLotesAutoOrden char(20),
          @Financiamiento float,
          @importeVD money,
          @Puntos money


  SELECT
    @TieneAlgo = 0,
    @RenglonID = 0
  SELECT
    @Renglon = ISNULL(MAX(Renglon), 0)
  FROM VentaD WITH (NOLOCK)
  WHERE ID = @VentaID
  SELECT
    @Empresa = Empresa,
    @Cliente = Cliente,
    @Directo = Directo,
    @RenglonID = ISNULL(RenglonID, 0)
  FROM Venta WITH (NOLOCK)
  WHERE ID = @VentaID
  SELECT
    @ZonaImpuesto = ZonaImpuesto
  FROM Cte WITH (NOLOCK)
  WHERE Cliente = @Cliente

  SELECT
    @CfgSeriesLotesAutoOrden = ISNULL(UPPER(RTRIM(SeriesLotesAutoOrden)), 'NO')
  FROM EmpresaCfg WITH (NOLOCK)
  WHERE Empresa = @Empresa

  BEGIN TRANSACTION

    DECLARE crVentaCteD CURSOR FOR
    SELECT
      d.Financiamiento,
      l.ID,
      l.CantidadA,
      (l.CantidadA * d.CantidadInventario / ISNULL(NULLIF(d.Cantidad, 0.0), 1.0)),
      d.Renglon,
      d.RenglonSub,
      d.RenglonID,
      RenglonTipo,
      Almacen,
      Codigo,
      Articulo,
      Subcuenta,
      Unidad,
      Precio,
      DescuentoTipo,
      DescuentoLinea,
      DescuentoImporte,
      Impuesto1,
      Impuesto2,
      Impuesto3,
      Costo,
      ContUso,
      Aplica,
      AplicaID,
      Agente,
      Departamento,
      D.Puntos --ARC 14-May-09 Se agrego el campo d.Financiamiento  
    FROM VentaD d WITH (NOLOCK),
         VentaCteDLista l WITH (NOLOCK)
    WHERE l.Estacion = @Estacion
    AND ISNULL(l.CantidadA, 0.0) > 0
    AND d.ID = l.ID
    AND d.Renglon = l.Renglon
    AND d.RenglonSub = l.RenglonSub
    ORDER BY l.ID, l.Renglon, l.RenglonSUB

    OPEN crVentaCteD
    FETCH NEXT FROM crVentaCteD INTO @Financiamiento, @ID, @Cantidad, @CantidadInventario, @VentaDRenglon, @VentaDRenglonSub, @VentaDRenglonID, @RenglonTipo, @Almacen,
    @Codigo, @Articulo, @Subcuenta, @Unidad, @Precio, @DescuentoTipo, @DescuentoLinea, @DescuentoImporte, @Impuesto1, @Impuesto2,
    @Impuesto3, @Costo, @ContUso, @Aplica, @AplicaID, @AgenteD, @DepartamentoD, @Puntos--ARC 14-May-09 Se agrego la variable @Financiamiento  

    WHILE @@FETCH_STATUS <> -1
    BEGIN  -- -1
      IF @@FETCH_STATUS <> -2
      BEGIN    -- -2
        IF @TieneAlgo = 0
        BEGIN    -- @TieneAlgo = 0 
          SELECT
            @TieneAlgo = 1

          SELECT
            @Empresa = Empresa,
            @Mov = Mov,
            @MovID = MovID,
            @MovReferencia = NULLIF(RTRIM(Referencia), ''),
            @Agente = Agente,
            @Descuento = Descuento,
            @DescuentoGlobal = DescuentoGlobal,
            @FormaPagoTipo = FormaPagoTipo,
            @SobrePrecio = SobrePrecio,
            @Departamento = Departamento
          FROM Venta WITH (NOLOCK)
          WHERE ID = @ID

          IF EXISTS (SELECT
              *
            FROM PoliticasMonederoAplicadasMavi WITH (NOLOCK)
            WHERE Empresa = @Empresa
            AND Modulo = 'VTAS'
            AND ID = @VentaID)
            DELETE FROM PoliticasMonederoAplicadasMavi
            WHERE Empresa = @Empresa
              AND Modulo = 'VTAS'
              AND ID = @VentaID

          -- 20160722 - jacm se cambia para devoluciones parciales x articulos
          IF EXISTS (SELECT
              *
            FROM VentaCteDLista VL WITH (NOLOCK)
            WHERE ID = @ID
            AND ISNULL(Vl.CantidadA, 0.0) > 0)
            INSERT PoliticasMonederoAplicadasMavi (Empresa, Modulo, ID, Renglon, Articulo, IDPolitica)
              SELECT
                V.EMPRESA,
                'VTAS',
                @VentaID,
                D.Renglon,
                D.Articulo,
                (D.PUNTOS / D.CANTIDAD) * ISNULL(Vl.CantidadA, 0.0)--D.PUNTOS  
              FROM Venta V WITH (NOLOCK)
              JOIN VentaD D WITH (NOLOCK)
                ON V.ID = D.ID											-- de la factura
                JOIN VentaCteDLista VL WITH (NOLOCK)
                  ON D.RENGLON = VL.RENGLON
                  AND ISNULL(Vl.CantidadA, 0.0) > 0
                  AND VL.ID = @ID
              WHERE V.ID = @ID

          --IF EXISTS(SELECT * FROM PoliticasMonederoAplicadasMavi WHERE Empresa = @Empresa AND Modulo = 'VTAS' AND ID = @ID)
          --SELECT Empresa, Modulo, @VentaID, Renglon, Articulo, IDPolitica
          --  FROM PoliticasMonederoAplicadasMavi
          -- WHERE Empresa = @Empresa 
          --   AND Modulo = 'VTAS' 
          --   AND ID = @ID


          IF EXISTS (SELECT
              *
            FROM TarjetaSerieMovMAVI WITH (NOLOCK)
            WHERE Empresa = @Empresa
            AND Modulo = 'VTAS'
            AND ID = @VentaID)
            DELETE FROM TarjetaSerieMovMAVI
            WHERE Empresa = @Empresa
              AND Modulo = 'VTAS'
              AND ID = @VentaID

          IF EXISTS (SELECT
              *
            FROM TarjetaSerieMovMAVI WITH (NOLOCK)
            WHERE Empresa = @Empresa
            AND Modulo = 'VTAS'
            AND ID = @ID)
            INSERT TarjetaSerieMovMAVI (Empresa, Modulo, ID, Serie, Importe, Sucursal)
              SELECT
                Empresa,
                Modulo,
                @VentaID,
                Serie,
                Importe,
                Sucursal
              FROM TarjetaSerieMovMAVI WITH (NOLOCK)
              WHERE Empresa = @Empresa
              AND Modulo = 'VTAS'
              AND ID = @ID

        --			SELECT @importeVD = SUM(CANTIDAD * PRECIO)  FROM VENTAD VD WITH (NOLOCK) WHERE ID = @VentaID	
        --	        INSERT TarjetaSerieMovMAVI
        --	               (Empresa, Modulo, ID, Serie, Importe, Sucursal)
        ----	        SELECT ts.Empresa, ts.Modulo, @VentaID, ts.Serie, ROUND((ts.Importe / (VF.IMPORTE+VF.IMPUESTOS)) * (VD.IMPORTE+VD.IMPUESTOS),2), ts.Sucursal
        --	        SELECT ts.Empresa, ts.Modulo, @VentaID, ts.Serie, ROUND((ts.Importe / (VF.IMPORTE+VF.IMPUESTOS)) * (@importeVD),2), ts.Sucursal
        --            FROM TarjetaSerieMovMAVI ts With (NOLOCK)
        --			JOIN Venta               VF With (NOLOCK) ON VF.id = ts.id     
        ----			JOIN Venta               VD With (NOLOCK) ON VD.id = @VentaID
        --		    WHERE ts.Empresa = @Empresa 
        --			    AND Modulo = 'VTAS' 
        --				AND ts.ID = @ID
        --			END


        END  -- @TieneAlgo = 0 

        -- para actualizar  ventad		
        SELECT
          @Puntos = iDpOLITICA
        FROM PoliticasMonederoAplicadasMavi WITH (NOLOCK)
        WHERE Empresa = @Empresa
        AND Modulo = 'VTAS'
        AND ID = @VentaID
        AND RENGLON = @VentaDRenglon

        EXEC spZonaImp @ZonaImpuesto,
                       @Impuesto1 OUTPUT
        EXEC spZonaImp @ZonaImpuesto,
                       @Impuesto2 OUTPUT

        SELECT
          @Renglon = @Renglon + 2048,
          @RenglonID = @RenglonID + 1

        IF @MovTipo NOT IN ('VTAS.D', 'VTAS.DF', 'VTAS.SD', 'VTAS.DFC')
          SELECT
            @Costo = NULL

        IF @CopiarAplicacion = 0
          SELECT
            @Aplica = NULL,
            @AplicaID = NULL

        IF @Aplica IS NOT NULL
          SELECT
            @Directo = 0

        IF (@CopiaridVenta = 1)
        BEGIN
          IF NOT EXISTS (SELECT
              *
            FROM VentaD WITH (NOLOCK)
            WHERE ID = @VentaID
            AND Articulo = @Articulo)
          BEGIN
            INSERT VentaD (Financiamiento, IDCopiaMAVI, Sucursal, ID, Renglon, RenglonSub, RenglonID, RenglonTipo, Almacen, Codigo, Articulo, Subcuenta, Unidad, Cantidad, CantidadInventario, Precio, DescuentoTipo, DescuentoLinea, DescuentoImporte,
            Impuesto1, Impuesto2, Impuesto3, Costo, ContUso, Aplica, AplicaID, Agente, Departamento, Puntos) -- Se agrego el campo IDCopiaMAVI Arly Rubio Camacho (09-Oct-08) y Financiamiento  
              VALUES (@Financiamiento, @ID, @Sucursal, @VentaID, @Renglon, 0, @RenglonID, @RenglonTipo, @Almacen, @Codigo, @Articulo, @Subcuenta, @Unidad, @Cantidad, @CantidadInventario, @Precio, @DescuentoTipo, @DescuentoLinea, @DescuentoImporte, @Impuesto1, @Impuesto2, @Impuesto3, @Costo, @ContUso, @Aplica, @AplicaID, @AgenteD, @DepartamentoD, @Puntos)
          END
          ELSE
          BEGIN
            UPDATE VentaD WITH (ROWLOCK)
            SET puntos = @Puntos
            WHERE Articulo = @Articulo AND ID=@VentaID

          END
        END
        ELSE
        BEGIN
          INSERT VentaD (Financiamiento, IDCopiaMAVI, Sucursal, ID, Renglon, RenglonSub, RenglonID, RenglonTipo, Almacen, Codigo, Articulo, Subcuenta, Unidad, Cantidad, CantidadInventario, Precio, DescuentoTipo, DescuentoLinea, DescuentoImporte,
          Impuesto1, Impuesto2, Impuesto3, Costo, ContUso, Aplica, AplicaID, Agente, Departamento, Puntos) -- Se agrego el campo IDCopiaMAVI Arly Rubio Camacho (09-Oct-08) y Financiamiento  
            VALUES (@Financiamiento, @ID, @Sucursal, @VentaID, @Renglon, 0, @RenglonID, @RenglonTipo, @Almacen, @Codigo, @Articulo, @Subcuenta, @Unidad, @Cantidad, @CantidadInventario, @Precio, @DescuentoTipo, @DescuentoLinea, @DescuentoImporte, @Impuesto1, @Impuesto2, @Impuesto3, @Costo, @ContUso, @Aplica, @AplicaID, @AgenteD, @DepartamentoD, @Puntos)
        END

        EXEC spArtTipo @RenglonTipo,
                       @ArtTipo OUTPUT

        IF @ArtTipo IN ('SERIE', 'LOTE', 'VIN', 'PARTIDA')
          EXEC spVentaCteDSerieLote @Empresa,
                                    @Sucursal,
                                    @CfgSeriesLotesAutoOrden,
                                    @ID,
                                    @VentaDRenglonID,
                                    @RenglonID,
                                    @VentaID,
                                    @Articulo,
                                    @SubCuenta,
                                    @Cantidad


        IF (@CopiaridVenta = 0)
        BEGIN
          IF @ArtTipo = 'JUEGO'
            EXEC spVentaCteDComponentes @Sucursal,
                                        @ID,
                                        @VentaDRenglon,
                                        @VentaDRenglonSub,
                                        @Cantidad,
                                        @MovTipo,
                                        @VentaID,
                                        @Almacen,
                                        @Renglon,
                                        @RenglonID,
                                        @CopiarAplicacion,
                                        @Empresa,
                                        @CfgSeriesLotesAutoOrden


        END

      END  -- -2
      FETCH NEXT FROM crVentaCteD INTO @Financiamiento, @ID, @Cantidad, @CantidadInventario, @VentaDRenglon, @VentaDRenglonSub, @VentaDRenglonID, @RenglonTipo, @Almacen, @Codigo, @Articulo, @Subcuenta, @Unidad, @Precio, @DescuentoTipo, @DescuentoLinea, @DescuentoImporte, @Impuesto1, @Impuesto2, @Impuesto3, @Costo, @ContUso, @Aplica, @AplicaID, @AgenteD, @DepartamentoD, @Puntos --ARC 14-May-09 Se agrego el campo Financiamiento  
    END    -- -1
    CLOSE crVentaCteD
    DEALLOCATE crVentaCteD



    IF @TieneAlgo = 1
    BEGIN
      IF @MovReferencia IS NULL
        SELECT
          @MovReferencia = RTRIM(@Mov) + ' ' + RTRIM(@MovID)
      UPDATE Venta WITH (ROWLOCK)
      SET Referencia = @MovReferencia,
          Directo = @Directo,
          Agente = @Agente,
          Descuento = @Descuento,
          DescuentoGlobal = @DescuentoGlobal,
          FormaPagoTipo = @FormaPagoTipo,
          SobrePrecio = @SobrePrecio,
          RenglonID = @RenglonID,
          Departamento = @Departamento
      WHERE ID = @VentaID
    END

    DELETE VentaCteDLista
    WHERE Estacion = @Estacion

  COMMIT TRANSACTION
END
GO
