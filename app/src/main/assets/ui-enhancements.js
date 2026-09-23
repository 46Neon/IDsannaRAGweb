/* IDsanna interaction polish: accessibility and safe form feedback. */
(()=>{
  const status=document.getElementById('status');
  if(status){status.setAttribute('role','status');status.setAttribute('aria-live','polite');}
  const nav=document.querySelector('.bar');
  if(nav){nav.setAttribute('role','navigation');nav.setAttribute('aria-label','Navegación principal');}
  document.querySelectorAll('form').forEach(form=>{
    form.addEventListener('submit',()=>{
      const button=form.querySelector('button[type="submit"],button:not([type])');
      if(!button||button.dataset.busy==='1')return;
      button.dataset.busy='1';button.dataset.originalText=button.textContent;
      button.textContent='Procesando…';button.disabled=true;
      setTimeout(()=>{button.dataset.busy='0';button.textContent=button.dataset.originalText||'Continuar';button.disabled=false},35000);
    });
  });
  document.querySelectorAll('button').forEach(button=>{
    button.addEventListener('keydown',event=>{if(event.key===' '){event.preventDefault();button.click()}});
  });
  document.querySelectorAll('input,textarea,select').forEach(field=>{
    if(!field.id)return;
    const label=document.querySelector(`label[for="${field.id}"]`);
    if(!label&&!field.getAttribute('aria-label')){
      const wrapper=field.closest('.field');
      const text=wrapper?.childNodes?.[0]?.textContent?.trim();
      if(text)field.setAttribute('aria-label',text);
    }
    field.addEventListener('invalid',()=>field.closest('.field')?.classList.add('has-error'));
    field.addEventListener('input',()=>field.closest('.field')?.classList.remove('has-error'));
  });
  document.querySelectorAll('a[target="_blank"]').forEach(link=>link.rel='noopener noreferrer');
  document.querySelectorAll('.view').forEach(view=>view.setAttribute('aria-labelledby',`${view.id}-title`));
  document.querySelectorAll('.view h1').forEach(title=>{if(!title.id)title.id=`${title.closest('.view')?.id}-title`;title.setAttribute('tabindex','-1')});
  document.querySelectorAll('[data-v]').forEach(link=>link.addEventListener('click',()=>setTimeout(()=>document.querySelector(`#${link.dataset.v} h1`)?.focus(),30)));
  document.querySelectorAll('.panel:empty,.card:empty').forEach(box=>{box.classList.add('empty-state');box.innerHTML='<strong>Aún no hay información</strong><span>Cuando completes una actividad, aparecerá aquí.</span>'});
  const routes=['home','suite','chat','profile','access'];let swipeX=0;
  document.addEventListener('touchstart',event=>{if(event.target.closest('input,textarea,button,a'))return;swipeX=event.changedTouches[0].screenX},{passive:true});
  document.addEventListener('touchend',event=>{if(!swipeX||event.target.closest('input,textarea,button,a'))return;const dx=event.changedTouches[0].screenX-swipeX;swipeX=0;if(Math.abs(dx)<80)return;const current=routes.findIndex(id=>document.getElementById(id)?.classList.contains('active'));if(current<0)return;const next=(current+(dx<0?1:routes.length-1))%routes.length;window.go?.(routes[next])},{passive:true});
  const feed=document.getElementById('newsFeed');
  const esc=s=>String(s||'').replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));
  let feedItems=[];let feedFilter='all';function renderFeed(items){if(!feed||!items?.length)return;feedItems=items;const visible=feedFilter==='all'?items:items.filter(x=>String(x.source||'').toLowerCase().includes(feedFilter.toLowerCase()));feed.innerHTML=visible.slice(0,8).map((x,i)=>`<article class="card post news-card ${i===0?'news-featured':''}">${x.image?`<img class="news-image" src="${esc(x.image)}" alt="" loading="lazy">`:''}<div class="news-meta"><span class="news-source">${esc(x.source||'Fuente académica')}</span><span>${esc(x.date||'Reciente')}</span></div><h3>${esc(x.title)}</h3><p>${esc(x.summary||'Información reciente relacionada con tus materias.')}</p><div class="news-footer">${x.url?`<a class="news-link" href="${esc(x.url)}" target="_blank" rel="noopener">Leer artículo ↗</a>`:''}<span class="news-topic">Actualidad</span></div></article>`).join('')||'<div class="empty-state">No hay publicaciones de esta fuente todavía.</div>'}
  async function loadFeed(){if(!feed)return;try{let data=await window.idsannaSupabase?.invoke('feed-aggregator',{topics:['matemáticas','ciencia','tecnología','historia','salud'],sources:['wikipedia','browser','mcp','blogs','gdelt']});let items=data?.items||data?.feed||[];if(items.length){renderFeed(items);return}throw Error('empty')}catch(_){try{const topics=['science OR technology','matemáticas OR ciencia','educación'];const wiki=Promise.all(['ciencia','tecnología'].map(t=>fetch(`https://es.wikipedia.org/w/api.php?action=query&generator=search&gsrsearch=${encodeURIComponent(t)}&gsrnamespace=0&gsrlimit=2&prop=extracts|info&exintro=1&explaintext=1&inprop=url&format=json&origin=*`).then(r=>r.json())));const news=Promise.all(topics.map(t=>fetch(`https://api.gdeltproject.org/api/v2/doc/doc?query=${encodeURIComponent(t)}&mode=artlist&format=json&maxrecords=4&sort=datedesc`).then(r=>r.json()).catch(()=>({})))));const [wikiData,newsData]=await Promise.all([wiki,news]);const wikipedia=wikiData.flatMap(d=>Object.values(d.query?.pages||{}).map(p=>({source:'Wikipedia',title:p.title,summary:(p.extract||'').slice(0,220),url:p.fullurl||`https://es.wikipedia.org/wiki/${encodeURIComponent(p.title)}`})));const realNews=newsData.flatMap(d=>(d.articles||[]).map(a=>({source:a.domain||'Fuente web',title:a.title,summary:a.seendate?`Publicado: ${a.seendate.slice(0,8)}`:'Noticia reciente',url:a.url})));renderFeed([...realNews,...wikipedia])}catch(e){if(feed)feed.innerHTML='<article class="card post"><h3>Feed temporalmente no disponible</h3><p class="muted">Podrás actualizarlo cuando las fuentes vuelvan a estar disponibles.</p></article>'}}}
  document.querySelectorAll('.feed-filter').forEach(btn=>btn.addEventListener('click',()=>{feedFilter=btn.dataset.filter;document.querySelectorAll('.feed-filter').forEach(x=>x.classList.toggle('active',x===btn));renderFeed(feedItems)}));
  document.getElementById('refreshFeed')?.addEventListener('click',()=>{const b=document.getElementById('refreshFeed');b.disabled=true;b.textContent='↻ Cargando…';loadFeed().finally(()=>{b.disabled=false;b.textContent='↻ Actualizar'})});
  loadFeed();
})();