-- =====================================================================
-- MANTENIMIENTO DE DATOS  ·  APLICADO el 20/10/2026
-- =====================================================================
-- Las dos operaciones de abajo YA SE EJECUTARON. Quedan documentadas con
-- su respaldo y su rollback, por si hay que volver atras.
--
-- Estado final: 1038 registros, todos de 2026, sin duplicados.
-- =====================================================================


-- =====================================================================
-- 1) DUPLICADOS  ·  128 filas borradas
-- =====================================================================
-- Origen: la app cargaba solo 1000 filas (tope de la API). Al pasar ese
-- tope los registros mas nuevos no llegaban, la toma aparecia sin marcar
-- y al volver a marcarla se insertaba una copia. Arreglado en d89d51f.
-- De las 128: 118 por ese tope y 10 por doble toque.
--
-- Criterio: de cada grupo (profile_id, med_id, name, date, time) se
-- conserva la fila de menor id y se borran las copias posteriores.
--
-- El "name" en la particion NO es decorativo: las tomas ocasionales
-- tienen med_id nulo, y en SQL los nulos cuentan como iguales entre si.
-- Sin "name" se agrupaban como duplicados cosas distintas cargadas en el
-- mismo minuto (Ibuprofeno con Paracetamol el 31/03, Ibu con Betametasona
-- de Santi el 17/09, Tafirol migra con Factor AG y Aloe vera el 16/05):
-- cinco registros legitimos que no habia que tocar.

-- create table if not exists logs_duplicados_respaldo as
-- with ranked as (
--   select l.*,
--          row_number() over (partition by profile_id, med_id, name, date, time order by id) as rn
--   from logs l)
-- select * from ranked where rn > 1;
-- alter table logs_duplicados_respaldo enable row level security;
-- delete from logs where id in (select id from logs_duplicados_respaldo);


-- =====================================================================
-- 2) REGISTROS VIEJOS  ·  58 filas archivadas (26/11/2025 al 31/12/2025)
-- =====================================================================
-- Pedido de Diego: dejar solo lo vigente de este ano. No se borraron:
-- se movieron a logs_archivo_2025, asi que son recuperables.
-- No habia temperaturas ni episodios febriles en 2025.

-- create table if not exists logs_archivo_2025 as
--   select * from logs where date < '2026-01-01';
-- alter table logs_archivo_2025 enable row level security;
-- delete from logs where date < '2026-01-01' and id in (select id from logs_archivo_2025);


-- =====================================================================
-- ROLLBACK
-- La columna id es identity BY DEFAULT, asi que acepta el id explicito y
-- las filas vuelven con su id original.
-- =====================================================================
-- insert into logs (id, created_at, med_id, profile_id, date, time, taken_at, name, dose)
-- select id, created_at, med_id, profile_id, date, time, taken_at, name, dose
--   from logs_duplicados_respaldo;

-- insert into logs (id, created_at, med_id, profile_id, date, time, taken_at, name, dose)
-- select id, created_at, med_id, profile_id, date, time, taken_at, name, dose
--   from logs_archivo_2025;

-- Verificacion despues de cualquier rollback (las dos columnas en 0):
-- select
--   (select count(*) from (select 1 from logs group by profile_id, med_id, name, date, time having count(*) > 1) d) as duplicados,
--   (select count(*) from temperatures t where t.med_log_id is not null
--      and not exists (select 1 from logs l where l.id = t.med_log_id)) as temperaturas_huerfanas;

-- Cuando ya no hagan falta los respaldos:
-- drop table logs_duplicados_respaldo;
-- drop table logs_archivo_2025;
