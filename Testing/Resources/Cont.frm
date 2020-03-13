;*** 22-03-19 Reacomodo de los archivos especiales

[Cont.frm/Acciones.DesAfectar]
ActivoCondicion=Cont:Cont.Estatus=EstatusConcluido

[Cont.frm/Acciones.DesafectarLote]
Expresion=Si<BR>  (ContA:Cont.Estatus=EstatusConcluido)<BR>Entonces<BR>  DesAfectar(<T>Cont<T>, ContA:Cont.ID, ContA:Cont.Mov, ContA:Cont.MovID)<BR>Fin
