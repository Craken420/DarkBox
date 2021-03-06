SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

-- ========================================================================================================================================
-- FECHA Y AUTOR MODIFICACION:     02/09/2014     Por: Moises Adrian Hernandez Cajero
-- Se agrego el campo de telefono para venta entrega
-- ========================================================================================================================================
-- FECHA  AUTOR  MODIFICACION: 2018/07/9  FERNANDO ROMERO ROBLES:  
-- Se agrega campo Telefonomovil al inserte de la tabla ventaEntrega 
-- ======================================================================================================================================== 

CREATE PROCEDURE [dbo].[spMovCopiarAnexos] @Sucursal int,
@OModulo char(5),
@OID int,
@DModulo char(5),
@DID int,
@CopiarBitacora bit = 0

AS
BEGIN
  IF @OModulo IS NOT NULL
    AND @OID IS NOT NULL
    AND @DModulo IS NOT NULL
    AND @DID IS NOT NULL
  BEGIN
    INSERT AnexoMov (Sucursal, Rama, ID, Nombre, Direccion, Icono, Tipo, Orden, Comentario)
      SELECT
        @Sucursal,
        @DModulo,
        @DID,
        Nombre,
        Direccion,
        Icono,
        Tipo,
        Orden,
        Comentario
      FROM AnexoMov WITH (NOLOCK)
      WHERE Rama = @OModulo
      AND ID = @OID
      AND Nombre <> 'Comprobante Fiscal Digital'
    IF @OModulo IN ('VTAS', 'INV', 'COMS', 'PROD')
      AND @DModulo IN ('VTAS', 'INV', 'COMS', 'PROD')
      INSERT AnexoMovD (Sucursal, Rama, ID, Cuenta, Nombre, Direccion, Icono, Tipo, Orden, Comentario)
        SELECT
          @Sucursal,
          @DModulo,
          @DID,
          Cuenta,
          Nombre,
          Direccion,
          Icono,
          Tipo,
          Orden,
          Comentario
        FROM AnexoMovD WITH (NOLOCK)
        WHERE Rama = @OModulo
        AND ID = @OID
    IF @CopiarBitacora = 1
      INSERT MovBitacora (Sucursal, Modulo, ID, Fecha, Evento, Usuario)
        SELECT
          @Sucursal,
          @DModulo,
          @DID,
          Fecha,
          Evento,
          Usuario
        FROM MovBitacora WITH (NOLOCK)
        WHERE Modulo = @OModulo
        AND ID = @OID
    IF @OModulo = 'VTAS'
      AND @DModulo = 'VTAS'
    BEGIN
      INSERT VentaDAgente (ID, Renglon, RenglonSub, Agente, Fecha, HoraD, HoraA, Minutos, Actividad, Estado, Comentarios, CantidadEstandar, CostoActividad, FechaConclusion)
        SELECT
          @DID,
          Renglon,
          RenglonSub,
          Agente,
          Fecha,
          HoraD,
          HoraA,
          Minutos,
          Actividad,
          Estado,
          Comentarios,
          CantidadEstandar,
          CostoActividad,
          FechaConclusion
        FROM VentaDAgente WITH (NOLOCK)
        WHERE ID = @OID
      INSERT VentaEntrega (ID, Sucursal, Embarque, EmbarqueFecha, EmbarqueReferencia, Recibo, ReciboFecha, ReciboReferencia,
      Direccion, DireccionNumero, DireccionNumeroInt, CodigoPostal, Delegacion, Colonia, Poblacion, Estado, Telefono, TelefonoMovil)
        SELECT
          @DID,
          @Sucursal,
          Embarque,
          EmbarqueFecha,
          EmbarqueReferencia,
          Recibo,
          ReciboFecha,
          ReciboReferencia, -- Se agregaron nuevos campos ARC 26-Dic-08:
          Direccion,
          DireccionNumero,
          DireccionNumeroInt,
          CodigoPostal,
          Delegacion,
          Colonia,
          Poblacion,
          Estado,
          Telefono,
          TelefonoMovil
        FROM VentaEntrega WITH (NOLOCK)
        WHERE ID = @OID
      /* Inicia Modificacion para copiar los vales ARC 26-Dic-08 */
      INSERT INTO VentaValeMAVI (ID, Vale)
        SELECT
          @DID,
          VV.Vale
        FROM VentaValeMAVI VV WITH (NOLOCK)
        WHERE ID = @OID
    /* Termina Modificacion para copiar los vales ARC 26-Dic-08 */

    END
  /*IF @OModulo = 'COMS' AND @DModulo = 'COMS'
  INSERT CompraDProrrateo (ID, RenglonID, Articulo, SubCuenta, Almacen, Cantidad, Sucursal, SucursalOrigen)
  SELECT @DID, RenglonID, Articulo, SubCuenta, Almacen, Cantidad, Sucursal, SucursalOrigen
  FROM CompraDProrrateo
  WHERE ID = @OID*/
  END
END
GO
