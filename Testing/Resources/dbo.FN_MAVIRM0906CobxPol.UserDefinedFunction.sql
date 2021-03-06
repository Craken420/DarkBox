SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
-- ========================================================================================================================================           
-- NOMBRE          : FN_MAVIRM0906CobxPol    
-- AUTOR           :           
-- FECHA CREACION  :             
-- DESARROLLO      :     
-- MODULO          : CXC          
-- DESCRIPCION     : 
-- EJEMPLO         : select dbo.FN_MAVIRM0906CobxPol ('18059951')
-- ========================================================================================================================================   
--  MODIFICACION
--  Nombre         : Ana Luisa Gomez Montaño
--  Fecha          : 20/12/2017
--  Descripcion    : Se modificó el apartado de obtención de datos para las variables @DV y @DI para que vaya a leer los datos de la nueva tabla TcIRM0906_ConfigDivisionYParam
--                   Se agregaron las variables @Quincena, @Year, para obtener el año y mes actual, tomando en cuenta los inicios de año para tomar en cuenta la quincena anterior
-- ========================================================================================================================================   
--                   Alejandra García 04/09/2018 Se agregó validación para que considere las divisiones nulas ON ISNULL(CON.Division,'') = ISNULL(MA.Division,'')
-- ========================================================================================================================================   
CREATE FUNCTION [dbo].[FN_MAVIRM0906CobxPol] (@ID int)
RETURNS varchar(10)
AS
BEGIN
  DECLARE @COB varchar(10),
          @DV int,
          @DI int,
          @DVEC int,
          @DINAC int,
          @SECC varchar(50),
          @Cliente varchar(10),
          @Quincena int,
          @Year int = YEAR(GETDATE())

  SELECT
    @Cliente = C.Cliente,
    @SECC = ISNULL(CE.SeccionCobranzaMAVI, ''),
    @DVEC = ISNULL(CM.DiasVencActMAVI, 0),
    @DINAC = ISNULL(CM.DiasInacActMAVI, 0)
  FROM CxcMavi CM WITH (NOLOCK)
  JOIN Cxc C WITH (NOLOCK)
    ON C.ID = CM.ID
  JOIN TablaStD T WITH (NOLOCK)
    ON T.TablaSt = 'MOVIMIENTOS COBRO X POLITICA'
    AND T.Nombre = C.Mov
  LEFT JOIN CteEnviarA CE WITH (NOLOCK)
    ON CE.ID = C.ClienteEnviarA
    AND CE.Cliente = C.Cliente
  WHERE CM.ID = @ID

  IF ISNULL(@Cliente, '') != ''
    AND ISNULL(@SECC, '') != 'INSTITUCIONES'
    AND (ISNULL(@DVEC, 0) > 0
    OR ISNULL(@DINAC, 0) > 0)
  BEGIN
    SET @Quincena =
                   CASE
                     WHEN DAY(GETDATE()) > 16 THEN MONTH(GETDATE()) * 2
                     ELSE (MONTH(GETDATE()) * 2) - 1
                   END
    SET @Quincena =
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

    SELECT TOP 1
      @DV = ISNULL(CON.DV, 0),
      @DI = ISNULL(CON.DI, 0)
    FROM TcIRM0906_ConfigDivisionYParam CON WITH (NOLOCK)
    JOIN MaviRecuperacion MA WITH (NOLOCK)
      ON ISNULL(CON.Division, '') = ISNULL(MA.Division, '')
      AND MA.Quincena = @Quincena
      AND MA.Ejercicio = @Year
      AND MA.Cliente = @Cliente

    SELECT
      @DV = ISNULL(@DV, 0),
      @DI = ISNULL(@DI, 0),
      @DVEC = ISNULL(@DVEC, 0),
      @DINAC = ISNULL(@DINAC, 0)

    SET @COB =
              CASE
                WHEN ((@DVEC >= @DV AND
                  @DV <> 0) OR
                  (@DINAC >= @DI AND
                  @DI <> 0)) THEN 'SI'
                ELSE 'NO'
              END
  END

  SET @COB = ISNULL(@COB, 'NO')

  RETURN @COB
END
GO
