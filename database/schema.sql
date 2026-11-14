-- BAS KUPI POS - PostgreSQL / Supabase schema
create extension if not exists pgcrypto;
create type public.app_role as enum ('owner','cashier');
create type public.order_status as enum ('open','paid','cancelled');
create table public.profiles (id uuid primary key references auth.users(id) on delete cascade, full_name text not null default '', role public.app_role not null default 'cashier', created_at timestamptz not null default now());
create table public.menu_categories (id uuid primary key default gen_random_uuid(), name text not null unique);
create table public.menu_items (id uuid primary key default gen_random_uuid(), category_id uuid references public.menu_categories(id), name text not null, price bigint not null check(price>=0), is_available boolean not null default true, created_at timestamptz not null default now());
create table public.cafe_tables (number int primary key check(number between 1 and 100), label text not null);
insert into public.cafe_tables(number,label) select n, 'Meja '||lpad(n::text,2,'0') from generate_series(1,100) n on conflict do nothing;
create table public.orders (id uuid primary key default gen_random_uuid(), table_number int not null references public.cafe_tables(number), status public.order_status not null default 'open', created_by uuid references public.profiles(id), paid_at timestamptz, payment_method text check(payment_method in ('Tunai','Transfer','QRIS')), created_at timestamptz not null default now());
create table public.order_items (id uuid primary key default gen_random_uuid(), order_id uuid not null references public.orders(id) on delete cascade, menu_item_id uuid references public.menu_items(id), item_name text not null, unit_price bigint not null check(unit_price>=0), quantity int not null check(quantity>0));
create table public.expenses (id uuid primary key default gen_random_uuid(), description text not null, amount bigint not null check(amount>0), category text not null default 'Operasional', recorded_by uuid references public.profiles(id), created_at timestamptz not null default now());
alter table public.profiles enable row level security;
alter table public.menu_categories enable row level security;
alter table public.menu_items enable row level security;
alter table public.cafe_tables enable row level security;
alter table public.orders enable row level security;
alter table public.order_items enable row level security;
alter table public.expenses enable row level security;
-- Initial single-cafe access policy: authenticated staff can read operational data.
create policy "authenticated staff read profiles" on public.profiles for select to authenticated using (true);
create policy "authenticated staff read categories" on public.menu_categories for select to authenticated using (true);
create policy "authenticated staff read menu" on public.menu_items for select to authenticated using (true);
create policy "authenticated staff read tables" on public.cafe_tables for select to authenticated using (true);
create policy "authenticated staff manage orders" on public.orders for all to authenticated using (true) with check (true);
create policy "authenticated staff manage order items" on public.order_items for all to authenticated using (true) with check (true);
create policy "authenticated staff read expenses" on public.expenses for select to authenticated using (true);
-- Restrict expense writes and menu writes to owners in production policies before launch.
