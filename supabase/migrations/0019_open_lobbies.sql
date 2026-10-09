-- Migration 0019 : salons ouverts énumérables pour découverte en temps réel.
-- (Renommée de 0015 → 0019 : collision de préfixe avec 0015_custom_cards.sql,
-- deux branches de fonctionnalités développées en parallèle sur ce numéro.)
--
-- Permet aux joueurs de découvrir la liste des parties hébergées en attente
-- d'adversaire (status = 'lobby' et seat_b is null).

create or replace function public.list_open_games()
returns table (
  id uuid,
  code text,
  created_at timestamptz,
  seat_a uuid,
  assisted boolean
)
language sql
security definer
set search_path = public
stable
as $$
  select g.id, g.code, g.created_at, g.seat_a, g.assisted
  from public.games g
  where g.status = 'lobby'
    and g.seat_b is null
    and g.created_at > now() - interval '1 hour'
  order by g.created_at desc
  limit 20;
$$;

revoke all on function public.list_open_games() from public;
grant execute on function public.list_open_games() to authenticated, anon;
