-- Storage and ingestion metadata for PDF, image and audio pipelines.
insert into storage.buckets (id,name,public) values ('idsanna-documents','idsanna-documents',false) on conflict (id) do nothing;
alter table public.documents add column if not exists storage_path text;
alter table public.documents add column if not exists mime_type text;
alter table public.documents add column if not exists extracted_text text;
alter table public.documents add column if not exists processing_status text not null default 'pending';
alter table public.documents add column if not exists processing_error text;
alter table public.documents add column if not exists metadata jsonb not null default '{}'::jsonb;
alter table public.document_chunks add column if not exists chunk_index integer;
alter table public.document_chunks add column if not exists content text;
alter table public.document_chunks add column if not exists metadata jsonb not null default '{}'::jsonb;
alter table public.document_chunks add column if not exists embedding extensions.vector(1536);
create index if not exists documents_status_idx on public.documents(processing_status);
create index if not exists chunks_document_index_idx on public.document_chunks(document_id,chunk_index);
create or replace function public.match_document_chunks(query_embedding extensions.vector(1536), match_threshold float, match_count int, filter_subject_id uuid)
returns table(id uuid, document_id uuid, content text, metadata jsonb, similarity float)
language sql stable security invoker set search_path=public as $$
 select c.id,c.document_id,c.content,c.metadata,1-(c.embedding <=> query_embedding) as similarity
 from public.document_chunks c join public.documents d on d.id=c.document_id
 where d.subject_id=filter_subject_id and c.embedding is not null and 1-(c.embedding <=> query_embedding)>=match_threshold
 order by c.embedding <=> query_embedding limit match_count;
$$;

drop policy if exists idsanna_documents_select on storage.objects; create policy idsanna_documents_select on storage.objects for select using(bucket_id='idsanna-documents' and auth.uid()::text=(storage.foldername(name))[1]);
drop policy if exists idsanna_documents_insert on storage.objects; create policy idsanna_documents_insert on storage.objects for insert with check(bucket_id='idsanna-documents' and auth.uid()::text=(storage.foldername(name))[1]);
drop policy if exists idsanna_documents_update on storage.objects; create policy idsanna_documents_update on storage.objects for update using(bucket_id='idsanna-documents' and auth.uid()::text=(storage.foldername(name))[1]);
drop policy if exists idsanna_documents_delete on storage.objects; create policy idsanna_documents_delete on storage.objects for delete using(bucket_id='idsanna-documents' and auth.uid()::text=(storage.foldername(name))[1]);
