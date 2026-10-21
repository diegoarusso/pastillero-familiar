-- =====================================================================
-- CERRAR EL ACCESO ANÓNIMO A LOS DATOS DE SALUD
-- =====================================================================
-- Antes: 4 políticas ALL/public/true/true -> cualquiera con la anon key
-- (que es pública por diseño) podía leer, escribir y borrar todo.
-- Después: solo sesiones autenticadas.
--
-- NO se restringe por perfil a propósito: la familia comparte visibilidad
-- (Diego carga la fiebre de Santi, su señora carga las pastillas de Diego).
--
-- APLICAR SOLO DESPUÉS de que el login esté desplegado y verificado.
-- =====================================================================

drop policy if exists "Acceso total a medicamentos" on public.medications;
drop policy if exists "Acceso total a logs"         on public.logs;
drop policy if exists "Acceso total a temperaturas" on public.temperatures;
drop policy if exists "Acceso total a episodios"    on public.fever_episodes;

create policy "Familia autenticada" on public.medications
  for all to authenticated using (true) with check (true);
create policy "Familia autenticada" on public.logs
  for all to authenticated using (true) with check (true);
create policy "Familia autenticada" on public.temperatures
  for all to authenticated using (true) with check (true);
create policy "Familia autenticada" on public.fever_episodes
  for all to authenticated using (true) with check (true);


-- =====================================================================
-- ROLLBACK DE EMERGENCIA
-- Si la familia queda sin poder registrar medicación, correr esto para
-- volver al estado anterior mientras se investiga.
-- =====================================================================
-- drop policy if exists "Familia autenticada" on public.medications;
-- drop policy if exists "Familia autenticada" on public.logs;
-- drop policy if exists "Familia autenticada" on public.temperatures;
-- drop policy if exists "Familia autenticada" on public.fever_episodes;
--
-- create policy "Acceso total a medicamentos" on public.medications
--   for all to public using (true) with check (true);
-- create policy "Acceso total a logs" on public.logs
--   for all to public using (true) with check (true);
-- create policy "Acceso total a temperaturas" on public.temperatures
--   for all to public using (true) with check (true);
-- create policy "Acceso total a episodios" on public.fever_episodes
--   for all to public using (true) with check (true);
