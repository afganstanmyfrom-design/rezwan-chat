-- Paste this whole file in Supabase > SQL Editor > Run
create table profiles(
  id uuid primary key references auth.users on delete cascade,
  username text unique not null check (username ~ '^[a-z0-9_]{3,20}$'),
  display_name text not null,
  avatar_url text,
  created_at timestamptz default now());
create table contacts(
  owner uuid references profiles(id) on delete cascade,
  contact uuid references profiles(id) on delete cascade,
  primary key(owner, contact));
create table messages(
  id bigserial primary key,
  sender uuid not null references profiles(id) on delete cascade,
  receiver uuid not null references profiles(id) on delete cascade,
  type text not null default 'text',
  body text not null,
  created_at timestamptz default now());

alter table profiles enable row level security;
alter table contacts enable row level security;
alter table messages enable row level security;

create policy "profiles read" on profiles for select to authenticated using (true);
create policy "profiles insert" on profiles for insert to authenticated with check (auth.uid()=id);
create policy "profiles update" on profiles for update to authenticated using (auth.uid()=id);
create policy "contacts read" on contacts for select to authenticated using (auth.uid()=owner);
create policy "contacts insert" on contacts for insert to authenticated with check (auth.uid()=owner);
create policy "contacts delete" on contacts for delete to authenticated using (auth.uid()=owner);
create policy "msg read" on messages for select to authenticated using (auth.uid() in (sender, receiver));
create policy "msg insert" on messages for insert to authenticated with check (auth.uid()=sender);

-- when someone messages you, they appear in your contacts automatically
create function add_reverse_contact() returns trigger language plpgsql security definer as $$
begin
  insert into contacts(owner, contact) values (new.receiver, new.sender) on conflict do nothing;
  return new;
end $$;
create trigger msg_contact after insert on messages for each row execute function add_reverse_contact();

alter publication supabase_realtime add table messages;

insert into storage.buckets(id, name, public) values ('media','media',true);
create policy "media upload" on storage.objects for insert to authenticated with check (bucket_id='media');
create policy "media read" on storage.objects for select using (bucket_id='media');
