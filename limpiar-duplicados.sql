-- =====================================================================
-- LIMPIAR LOS REGISTROS DUPLICADOS
-- =====================================================================
-- Origen: la app cargaba solo 1000 filas (tope de la API). Al pasar ese
-- tope, los registros mas nuevos no llegaban, la toma aparecia sin marcar
-- y al volver a marcarla se insertaba una fila repetida.
--
-- La causa ya esta arreglada (commit d89d51f): esto solo limpia las filas
-- que quedaron. Son 128, de 7 items, entre el 11/12/2025 y el 16/10/2026.
--
-- Verificado antes de escribir esto:
--   - ninguna esta referenciada por temperatures.med_log_id
--   - ninguna pertenece a un item con track_stock, asi que el stock
--     registrado no quedo descontado de mas
--
-- Criterio: de cada grupo (profile_id, med_id, name, date, time) se
-- conserva la fila de menor id, que es la original, y se borran las copias
-- posteriores.
--
-- El "name" en la particion NO es decorativo: las tomas ocasionales tienen
-- med_id nulo, y en SQL los nulos cuentan como iguales entre si. Sin "name"
-- se agrupaban como duplicados cosas distintas cargadas en el mismo minuto
-- (Ibuprofeno con Paracetamol el 31/03, Ibu con Betametasona de Santi el
-- 17/09, y Tafirol migra con Factor AG y Aloe vera el 16/05): cinco
-- registros legitimos que no hay que tocar.
-- =====================================================================

-- PASO 1 - respaldo. Deja una copia completa de lo que se va a borrar.
create table if not exists logs_duplicados_respaldo as
with ranked as (
  select l.*,
         row_number() over (partition by profile_id, med_id, name, date, time order by id) as rn
  from logs l)
select * from ranked where rn > 1;

-- La copia no deberia quedar accesible con la anon key.
alter table logs_duplicados_respaldo enable row level security;

-- Control: tiene que decir 128.
select count(*) as filas_respaldadas from logs_duplicados_respaldo;

-- PASO 2 - borrado. Correr solo si el control anterior dio 128.
delete from logs
where id in (select id from logs_duplicados_respaldo);

-- PASO 3 - verificacion. Las dos columnas tienen que dar 0.
select
  (select count(*) from (
     select 1 from logs group by profile_id, med_id, name, date, time having count(*) > 1
   ) d) as grupos_duplicados_restantes,
  (select count(*) from temperatures t
    where t.med_log_id is not null
      and not exists (select 1 from logs l where l.id = t.med_log_id)) as temperaturas_huerfanas;


-- =====================================================================
-- ROLLBACK
-- Restituye las filas borradas con sus ids originales. La columna id es
-- identity BY DEFAULT, asi que acepta el id explicito.
-- =====================================================================
-- insert into logs (id, created_at, med_id, profile_id, date, time, taken_at, name, dose)
-- select id, created_at, med_id, profile_id, date, time, taken_at, name, dose
--   from logs_duplicados_respaldo;

-- Una vez confirmado que todo quedo bien, se puede soltar el respaldo:
-- drop table logs_duplicados_respaldo;
