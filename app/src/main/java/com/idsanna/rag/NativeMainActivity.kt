package com.idsanna.rag

import android.content.Intent
import android.graphics.Color
import android.net.Uri
import android.os.Bundle
import android.view.Gravity
import android.view.View
import android.widget.*
import androidx.appcompat.app.AppCompatActivity
import com.google.android.material.button.MaterialButton
import com.google.android.material.card.MaterialCardView
import com.google.android.material.textfield.TextInputEditText
import com.google.android.material.textfield.TextInputLayout
import kotlinx.coroutines.*
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody.Companion.toRequestBody
import org.json.JSONObject

/** Native Kotlin frontend foundation. Backend remains Supabase; no private keys are bundled. */
class NativeMainActivity : AppCompatActivity() {
    private val scope = MainScope()
    private val http = OkHttpClient()
    private lateinit var root: LinearLayout
    private lateinit var content: FrameLayout
    private var token: String? = null
    private var downX = 0f
    private var screenIndex = 0
    private val teal = Color.WHITE
    private val bg = Color.rgb(8,8,8)
    private val card = Color.rgb(25,25,25)
    private val white = Color.WHITE
    private val muted = Color.rgb(166,166,166)

    override fun onCreate(state: Bundle?) { super.onCreate(state); token=getPreferences(0).getString("token",null); renderShell(); showHome() }
    private fun renderShell(){ root=LinearLayout(this).apply{orientation=LinearLayout.VERTICAL;setBackgroundColor(bg);setPadding(24,20,24,16)}; content=FrameLayout(this); root.addView(content,LinearLayout.LayoutParams(-1,0,1f)); setContentView(root) }
    private fun title(text:String, size:Float=30f)=TextView(this).apply{this.text=text;setTextColor(white);textSize=size;setTypeface(null,android.graphics.Typeface.BOLD);setPadding(0,8,0,8)}
    private fun body(text:String)=TextView(this).apply{this.text=text;setTextColor(muted);textSize=15f;setPadding(0,4,0,12)}
    private fun button(text:String, action:()->Unit)=MaterialButton(this).apply{this.text=text;isAllCaps=false;cornerRadius=16;backgroundTintList=android.content.res.ColorStateList.valueOf(Color.WHITE);setTextColor(Color.BLACK);setOnClickListener{isEnabled=false;action();postDelayed({isEnabled=true},1200)}}
    private fun panel():MaterialCardView=MaterialCardView(this).apply{setCardBackgroundColor(card);radius=28f;cardElevation=5f;setContentPadding(20,18,20,18)}
    private fun show(view:View){content.removeAllViews();content.addView(view,FrameLayout.LayoutParams(-1,-1));content.setOnTouchListener{_,event->when(event.action){android.view.MotionEvent.ACTION_DOWN->{downX=event.x;false};android.view.MotionEvent.ACTION_UP->{val dx=event.x-downX;if(kotlin.math.abs(dx)>90){if(dx<0)nextScreen() else previousScreen()};false};else->false}};content.requestFocus()}
    private fun nextScreen(){screenIndex=(screenIndex+1)%4;when(screenIndex){0->showHome();1->showSubjects();2->showChat();else->showProfile()}}
    private fun previousScreen(){screenIndex=(screenIndex+3)%4;when(screenIndex){0->showHome();1->showSubjects();2->showChat();else->showProfile()}}
    private fun showHome(){val box=LinearLayout(this).apply{orientation=LinearLayout.VERTICAL};box.addView(title("Tu espacio de estudio"));box.addView(body("Aprende con contexto, evidencia y agentes académicos."));val p=panel();val x=LinearLayout(this).apply{orientation=LinearLayout.VERTICAL};x.addView(title("Resumen de hoy",20f));x.addView(body(if(token==null)"Inicia sesión para ver tu progreso." else "Continúa tus materias, documentos y conversaciones."));x.addView(button(if(token==null)"Iniciar sesión" else "Abrir materias"){if(token==null)showAccess() else showSubjects()});p.addView(x);box.addView(p);box.addView(title("Acciones rápidas",20f));box.addView(button("Crear materia"){showSubjects()});box.addView(button("Abrir chat Mini-RAG"){showChat()});box.addView(navigation());show(box)}
    private fun navButton(label:String,index:Int)=MaterialButton(this).apply{this.text=label;isAllCaps=false;textSize=12f;setTextColor(if(index==screenIndex)teal else white);setBackgroundColor(Color.TRANSPARENT);cornerRadius=10;setPadding(8,0,8,0);setOnClickListener{screenIndex=index;when(index){0->showHome();1->showSubjects();2->showChat();else->showProfile()}}}
    private fun navigation():HorizontalScrollView{val row=LinearLayout(this).apply{orientation=LinearLayout.HORIZONTAL;gravity=Gravity.CENTER_VERTICAL;setPadding(8,8,8,8)};listOf("⌂\nInicio","▦\nMaterias","◌\nChat","●\nPerfil").forEachIndexed{index,label->row.addView(navButton(label,index),LinearLayout.LayoutParams(0,62,1f))};return HorizontalScrollView(this).apply{isHorizontalScrollBarEnabled=false;setBackgroundColor(Color.rgb(13,27,46));addView(row)}}
    private fun field(hint:String,password:Boolean=false)=TextInputLayout(this).apply{this.hint=hint;setBoxBackgroundMode(TextInputLayout.BOX_BACKGROUND_OUTLINE);setBoxCornerRadii(12f,12f,12f,12f);val e=TextInputEditText(this@NativeMainActivity);e.setTextColor(white);e.setHintTextColor(muted);if(password)e.inputType=0x81;addView(e)}
    private fun showAccess(){val box=LinearLayout(this).apply{orientation=LinearLayout.VERTICAL};box.addView(title("Acceso seguro"));box.addView(body("Usa tu cuenta de IDsanna para separar tus materias, documentos y créditos."));val email=field("Correo electrónico");val pass=field("Contraseña",true);box.addView(email);box.addView(pass);box.addView(button("Iniciar sesión"){auth(email.editText?.text.toString(),pass.editText?.text.toString(),false)});box.addView(button("Crear cuenta"){auth(email.editText?.text.toString(),pass.editText?.text.toString(),true)});box.addView(button("Volver"){showHome()});show(box)}
    private fun auth(email:String,pass:String,signup:Boolean){if(email.isBlank()||pass.length<8){Toast.makeText(this,"Escribe un correo y una contraseña de 8 caracteres.",Toast.LENGTH_LONG).show();return};scope.launch{try{val cfg=JSONObject(assets.open("config.json").bufferedReader().readText());val url=cfg.getString("supabaseUrl");val key=cfg.getString("supabasePublishableKey");val endpoint=if(signup)"$url/auth/v1/signup" else "$url/auth/v1/token?grant_type=password";val body=JSONObject().put("email",email).put("password",pass).apply{if(signup)put("email_redirect_to",cfg.optString("authRedirectUrl"))};val req=Request.Builder().url(endpoint).addHeader("apikey",key).post(body.toString().toRequestBody("application/json".toMediaType())).build();val res=withContext(Dispatchers.IO){http.newCall(req).execute()};val data=JSONObject(res.body?.string()?:("{}"));if(!res.isSuccessful)throw IllegalStateException(data.optString("msg",data.optString("error_description","No se pudo completar la operación")));val access=data.optString("access_token");if(access.isNotBlank()){token=access;getPreferences(0).edit().putString("token",access).apply();withContext(Dispatchers.Main){Toast.makeText(this@NativeMainActivity,"Sesión iniciada",Toast.LENGTH_SHORT).show();showHome()}}else withContext(Dispatchers.Main){showVerification(email)} }catch(e:Exception){withContext(Dispatchers.Main){Toast.makeText(this@NativeMainActivity,e.message?:"Error de conexión",Toast.LENGTH_LONG).show()}}}}
    private fun showVerification(email:String){val box=LinearLayout(this).apply{orientation=LinearLayout.VERTICAL};box.addView(title("Verifica tu correo"));box.addView(body("Confirma $email para activar tu cuenta. Revisa Recibidos, Spam y Promociones."));box.addView(button("Abrir Gmail"){try{startActivity(Intent(Intent.ACTION_VIEW,Uri.parse("https://mail.google.com/mail/u/0/#inbox")))}catch(_:Exception){}});box.addView(button("Volver al acceso"){showAccess()});show(box)}
    private fun showSubjects(){val box=LinearLayout(this).apply{orientation=LinearLayout.VERTICAL};box.addView(title("Mis materias"));box.addView(body("Organiza cada materia con unidades, documentos y conversaciones aisladas."));box.addView(button("Nueva materia"){Toast.makeText(this@NativeMainActivity,"Formulario de materia listo para conectar al runtime.",Toast.LENGTH_SHORT).show()});box.addView(button("Abrir chat"){showChat()});box.addView(navigation());show(box)}
    private fun showChat(){val box=LinearLayout(this).apply{orientation=LinearLayout.VERTICAL};box.addView(title("Chat Mini-RAG"));box.addView(body("Pregunta con contexto y recibe respuestas con citas."));val input=EditText(this).apply{hint="Escribe tu pregunta";setTextColor(white);setHintTextColor(muted);minLines=3};box.addView(input);box.addView(button("Preguntar"){Toast.makeText(this@NativeMainActivity,"La pregunta se enviará al runtime unificado.",Toast.LENGTH_SHORT).show()});box.addView(button("Importar documento"){Toast.makeText(this@NativeMainActivity,"Selector de documentos disponible en la siguiente capa.",Toast.LENGTH_SHORT).show()});box.addView(navigation());show(box)}
    private fun showProfile(){val box=LinearLayout(this).apply{orientation=LinearLayout.VERTICAL};box.addView(title("Perfil y analíticas"));box.addView(body("Tu actividad, créditos y progreso académico en un solo lugar."));box.addView(panel().apply{addView(body("Comprensión    —\nConstancia      —\nRendimiento     —\n\nPlan actual: Freemium"))});box.addView(button("Cerrar sesión"){token=null;getPreferences(0).edit().clear().apply();showAccess()});box.addView(navigation());show(box)}
    override fun onDestroy(){scope.cancel();super.onDestroy()}
}
