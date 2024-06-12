% nota importante en depuracion
% no dibujar en la fila superior ni en la dos inferiores, por que son del sistema
% la de arriba es para ocultar la camara fronta y ver estado de bateria, wifi, etc
% las inferiores (2) son para iconos home, atras, y demas
% en pixeles vienen a ser unos 80 arriba, y unos 160 abajo

% 10x14 : nota -> ancho es alto en el movil, al ser pantalla vertical
ancho=10 % original 10
alto =17 % original 17

% medidas de las "bolas" (ancho=alto)
anchobola=108 % original 110, pero 108 ajusta mejor en el POCO X3 con sus "1080x2400"

% escala para encajar en pantalla
escala=1 

Dim bolas[ancho-1+1,alto-1+1]
Dim bolas2[ancho+2+1,alto+2+1] % copia del bolas, con +1 por cada lado, para usar el borde como comprobacion
Dim bolas_copia[ancho-1+1,alto-1+1]

rand=0.0
verif=0
x=0
y=0
mx=0
my=0
touch=0
puntos_total=0
puntos_maximos5=0
puntos_maximos6=0

% numero de bolas a emplear: 5 o 6 (con 5, sobra la morada)
num_bolas=6

gr.open 255,178,178,178,0,1   % kind of green
gr.screen w,h
scx = 1080
scy = 2400-200 % en altura, resto 200 para "liberar" la barra inferior de android
sx  = w/scx
sy  = h/scy
%gr.scale sx,sy


File.Root tmp$
IstandAlone =Is_In("rfo-basic",tmp$)    % to know if it's an APK for the way to exit
path$ ="../rfo-basic/data/" %"../../data"
%
% creo mi Dir en la SD interna (no la externa, sino la propia de android)
SDinternal$ = "../../MisBolas" % directorio que cuelga seguido de "almacenamiento interno compartido", o sea, la SD interna
FILE.MKDIR SDinternal$ % lo creo si no existe
filename$ = SDinternal$+"/MisBolas.sav" % y el SAV se coge de ahi
%

audio.load snd_pop,"pop.mp3"
audio.load snd_final,"final.mp3"
audio.load snd_nuevo,"nuevo.mp3"
audio.load snd_muchas,"muchas.mp3"
audio.load snd_deshacer,"deshacer.mp3"
audio.load snd_nuevafila,"nuevafila.mp3"
%
gr.bitmap.load bmps, "bolas.bmp"
Font.load ft, "Batavia.TTF"
gr.text.setFont ft


gr.bitmap.crop gris1, bmps , 0 ,0 , anchobola-1, anchobola-1
gr.bitmap.crop gris2, bmps , 112,0, anchobola-1, anchobola-1
gr.bitmap.crop gris3, bmps , 224,0, anchobola-1, anchobola-1
gr.bitmap.crop gris4, bmps , 336,0, anchobola-1, anchobola-1
gr.bitmap.crop gris5, bmps , 448,0, anchobola-1, anchobola-1
gr.bitmap.crop gris6, bmps , 560,0, anchobola-1, anchobola-1
                          
gr.bitmap.crop roja , bmps , 0 , 112, anchobola-1, anchobola-1
gr.bitmap.crop verde, bmps , 112,112, anchobola-1, anchobola-1
gr.bitmap.crop azul , bmps , 224,112, anchobola-1, anchobola-1
gr.bitmap.crop amari, bmps , 336,112, anchobola-1, anchobola-1
gr.bitmap.crop cian , bmps , 448,112, anchobola-1, anchobola-1
gr.bitmap.crop morad, bmps , 560,112, anchobola-1, anchobola-1

gr.bitmap.crop vacio, bmps , 0  ,224, anchobola-1, anchobola-1

gr.bitmap.crop final, bmps , 200, 234, 142, 140
gr.bitmap.crop nuevo, bmps , 360, 234, 150, 150
gr.bitmap.crop atras, bmps , 510, 234, 150, 150

gr.bitmap.delete bmps     % free memory of the original .png file.


% --------------------------------------------------------------------------------------

% resolucion real
%ScreenRes (1080/escala)+10, (920/escala)+10,32

inicio:
% relleno la matriz inicial
For x=0 To ancho-1
	For y=0 To alto-1
		rand=Int(Rnd()*num_bolas)+1
		bolas[x+1,y+1]=rand
		bolas_copia[x+1,y+1]=rand
	Next y
Next x


% carga puntuacion maxima
% si no existe, lo crea
File.exists existe,filename$
If existe=0 Then
	text.open w, file_number, filename$
	s$=int$(0)
	text.writeln file_number, s$ % para puntos_maximos5 con 5 bolas
	text.writeln file_number, s$ % para puntos_maximos6 con 6 bolas
	text.close file_number
End If
% y ahora lo abre
text.open r, file_number, filename$
	text.readln file_number, s$
	puntos_maximos5=val(s$) % para puntos_maximos5 con 5 bolas
	text.readln file_number, s$
	puntos_maximos6=val(s$) % para puntos_maximos6 con 6 bolas
text.close file_number



% primer dibujado
gosub dibuja

% test de mis bolas, para ver-melas en pantalla
%gr.bitmap.draw nul, roja  , 0,2*anchobola
%gr.bitmap.draw nul, verde , 0,3*anchobola
%gr.bitmap.draw nul, azul  , 0,4*anchobola
%gr.bitmap.draw nul, amari , 0,5*anchobola
%gr.bitmap.draw nul, cian  , 0,6*anchobola
%gr.bitmap.draw nul, morad , 0,7*anchobola
%pause 25000

do
    gr.touch touch,mx,my
    if !background() then gr.render
	  
	mx=mx / (anchobola/escala)
	my=my / (anchobola/escala)
	
	If touch
	
			% para evitar perder la puntuacion, se guarda cada vez que pulsamos en pantalla
			% guarda puntuacion maxima
			text.open w, file_number, filename$
				s$=int$(puntos_maximos5)
				text.writeln file_number, s$
				s$=int$(puntos_maximos6)
				text.writeln file_number, s$
			text.close file_number

	
		audio.stop % paramos cualquier sonido anterior
		Pause 100 % necesario para evitar autorepeticion de click

			
		% si pulso sobre "MIS BOLAS!!!" sale mi correo electronico
		If (mx>=0 & mx<=ancho) & (my>(alto+2))
			gr.set.stroke 2 : gr.text.size 45 : gr.text.align 2
			gr.color 255, 178,178,178,2 % ROJO
			gr.text.draw nul, scx/2, scy-80, "M I S   B O L A S ! !"
			gr.color 255, 255, 0, 0, 2 % ROJO
			gr.text.draw nul, scx/2, scy-80, "Joseba Epalza <jepalza (gmail)>"
			Pause 100
			GoTo salir
		EndIf		
		
		% menu elegimos 5 bolas
		If (mx>=3 & mx<=4) & (my>alto & my<(alto+2))
			num_bolas=5
		    audio.play snd_nuevo
			For x=0 To ancho-1
				For y=0 To alto-1
					rand=Int(Rnd()*num_bolas)+1
					bolas[x+1,y+1]=rand
					bolas_copia[x+1,y+1]=rand
				Next y
			Next x
			puntos_total=0
			deshacer=0
			gosub dibuja
			Pause 100
			GoTo salir
		EndIf

		% menu elegimos 6 bolas
		If (mx>=6 & mx<=7) & (my>alto & my<(alto+2))
			num_bolas=6
		    audio.play snd_nuevo
			For x=0 To ancho-1
				For y=0 To alto-1
					rand=Int(Rnd()*num_bolas)+1
					bolas[x+1,y+1]=rand
					bolas_copia[x+1,y+1]=rand
				Next y
			Next x
			puntos_total=0
			deshacer=0
			gosub dibuja
			Pause 100
			GoTo salir
		EndIf
		
		% deshacer
		If (mx>ancho-3 & mx<ancho) & (my>alto) & deshacer>0
			audio.play snd_deshacer
			For x=0 To ancho-1
				For y=0 To alto-1
					bolas[x+1,y+1]=bolas_copia[x+1,y+1]
				Next y
			Next x
			% si hemos hecho puntuacion maxima, tambien se lo resto a ella, segun sean 5 o 6 bolas
			if puntos_total=puntos_maximos5 & num_bolas=5  then puntos_maximos5=puntos_total-deshacer % para 5 bolas
			if puntos_total=puntos_maximos6 & num_bolas=6  then puntos_maximos6=puntos_total-deshacer % para 6 bolas
			puntos_total=puntos_total-deshacer % restamos los puntos 
			gosub dibuja
			verif=0
			deshacer=0
			Pause 100
			GoTo salir
		EndIf
		
		
		% verificacion
		gosub verifica
		verif=suma
		suma=0
		
		% si no se quitan bolas (suma=0 o verif=suma=0), el deshacer permanece intacto
		if verif>0 then deshacer=verif
		
		% sumamos puntos
		If verif>0 Then puntos_total=puntos_total+verif

		% nuevo, si pulsamos abajo a la izquierda
		If (mx>=0 & mx<3) & (my>alto & my<(alto+2))  
		    audio.play snd_nuevo
			For x=0 To ancho-1
				For y=0 To alto-1
					rand=Int(Rnd()*num_bolas)+1
					bolas[x+1,y+1]=rand
					bolas_copia[x+1,y+1]=rand
				Next y
			Next x
			puntos_total=0
			deshacer=0
			gosub dibuja
			Pause 100
			GoTo salir
		EndIf 
	
	% ----------------------------
		gosub limpia_huecos
		gosub dibuja
	% ----------------------------
		
		gosub fin_juego 
		if pieza=1
			audio.stop
			audio.play snd_final
			gr.color 255,178,178,178,1
			gr.circle nul, (scx/2), (scy/2)-150, 250
			gr.color 255,220,220,0,1
			gr.circle nul, (scx/2), (scy/2)-150, 200
			gr.bitmap.draw nul, final, (scx/2)-60, (scy/2)-230
			gr.render
			do
				gr.touch touch,mx,my
			until touch
			touch=0
			mx=0
			my=0
			verif=0
			deshacer=0
			pause 500
			% guarda puntuacion maxima (tambien se guarda en TOUCH, sino, se perdian al salir del juego)
			text.open w, file_number, filename$
				s$=int$(puntos_maximos5)
				text.writeln file_number, s$
				s$=int$(puntos_maximos6)
				text.writeln file_number, s$
			text.close file_number
			puntos_total=0
			goto inicio
		EndIf
		
	salir:
	EndIf
	
	% depuracion
	%gr.color 255, 240, 240, 240, 2 % sin transparencias 8255), blanco y relleno (el 2 final)
	%gr.text.size 50
	%gr.text.draw nul, 160 , 80 , int$(mx) +"-"+ int$(my) +"-"+ int$(deshacer) +"-"+ int$(verif) +"-"+ int$(suma)
	%gr.text.draw nul, 160 , 80 , s$
	%gr.render
	
	
	%If InKey=Chr(27) Then end
until fin=1
end
% fin, aqui NUNCA llega



% -------------------------------------------------------------------------------------
% comprueba si hay fichas alrededor de nuestra posicion elegida
verifica: % entrada con coordenadas del punto tocado (mx , my )
	escala=1
	x=0
	y=0
	pieza=0
	suma=0
	salir=0
	
	If mx>ancho | my>alto Then suma=0:return % si estamos fuera de limites
	
	% bola tocada
	pieza=bolas[mx+1,my+1]
	If pieza=0 Then suma=0:return % vacios no se tratan

	% borro la matriz de calculo
	For x=0 To ancho+2
		For y=0 To alto+2
			bolas2[x+1,y+1]=0
		Next y
	Next x

	
	% copia de matriz con solo las bolas a tratar del color picado
	For x=0 To ancho-1
		For y=0 To alto-1
			If bolas[x+1,y+1]=pieza Then bolas2[x+1+1,y+1+1]=bolas[x+1,y+1]
		Next y
	Next x
	
	% primera comprobacion de piezas alrededor
	x=mx+1
	y=my+1
	
	bolas2[x+1,y+1]=99
	If bolas2[x-1+1,y  +1]=pieza Then bolas2[x-1+1,y  +1]=99:suma+=1
	If bolas2[x  +1,y-1+1]=pieza Then bolas2[x  +1,y-1+1]=99:suma+=1
	If bolas2[x+1+1,y  +1]=pieza Then bolas2[x+1+1,y  +1]=99:suma+=1
	If bolas2[x  +1,y+1+1]=pieza Then bolas2[x  +1,y+1+1]=99:suma+=1
	If suma=0 Then return % no hay parejas, esta sola, salimos
	
	% si hemos encontrado una coincidencia, buscamos mas
	do
		salir=1
		For x=1 To ancho
			For y=1 To alto
				If bolas2[x+1,y+1]=99 
					If bolas2[x-1+1,y  +1]=pieza Then bolas2[x-1+1,y  +1]=99:suma+=1:salir=0
					If bolas2[x  +1,y-1+1]=pieza Then bolas2[x  +1,y-1+1]=99:suma+=1:salir=0
					If bolas2[x+1+1,y  +1]=pieza Then bolas2[x+1+1,y  +1]=99:suma+=1:salir=0
					If bolas2[x  +1,y+1+1]=pieza Then bolas2[x  +1,y+1+1]=99:suma+=1:salir=0
				EndIf
			Next y
		Next x
	until salir=1 
	
	% copia de mis bolas antes de tocarmelas
	For x=0 To ancho-1
		For y=0 To alto-1
			bolas_copia[x+1,y+1]=bolas[x+1,y+1]
		Next y
	Next x
			
	% borro las bolas que coinciden
	For x=0 To ancho-1
		For y=0 To alto-1
			If bolas2[x+1+1,y+1+1]=99 
				gr.bitmap.draw nul, gris4, (x*anchobola)/escala, (y*anchobola)/escala
				bolas[x+1,y+1]=0
			EndIf
		Next y
	Next x
	
	gr.render
	Pause 100

	suma=suma+1 % siempre sumamos uno: representa la bola que hemos pulsado
	
	if suma<10 then audio.play snd_pop % sonido POP
	if suma>9 then audio.play snd_muchas % sonido WOW
	
	% progresion en la suma de puntos: bolas por bolas menos uno
	% ejemplo: 2 bolas, son 2x1=2, 4 bolas son 4x3=12, 20 bolas son 20x19=380....
	suma=suma*(suma-1)
	
Return


% ----------------------------------------------------------------------------------------
% arrejunto huecos
limpia_huecos:
	x=0
	y=0
	x2=0
	y2=0

	% primero filas, dejo "caer" las bolas
	For x=0 To ancho-1
		y=alto-1
		do
			x2=0
			If bolas[x+1,y+1]=0  % hueco encontrado, arrejunto hacia abajo toda la columna
				For y2=y To 1 Step -1
					bolas[x+1,y2+1]=bolas[x+1,y2-1+1]
					x2=x2+bolas[x+1,y2+1]
					%Circle(x*110+55,y2*110+55),5,RGB(255,255,255),,,,F
				Next y2
				bolas[x+1,0+1]=0 % la primera posicion de arriba se pone a 01
				If x2=0 Then y-=1
			Else 
				y-=1
			EndIf
		until y=0
	Next x
	
	
	% ahora columnas, las "pego" a la derecha y anado nueva
	For x=ancho-1 To 0 Step -1 % voy de derecha a izquierda
		%Circle(x*110+55,(alto-1)*110+55),5,RGB(255,255,255),,,,F
		If bolas[x+1,alto-1+1]=0  % si la bola de abajo del todo esta vacia, junto todo a la derecha
			For x2=x-1 To 0 Step -1
				For y2=0 To alto-1
					bolas[x2+1+1,y2+1]=bolas[x2+1,y2+1]
					%Circle((x2+1)*110+55,y2*110+55),5,RGB(255,255,0),,,,F
				Next y2
			Next x2
			% relleno la primera con una nueva aleatoria
			audio.stop
			audio.play snd_nuevafila
			For y2=0 To alto-1
				bolas[0+1,y2+1]=Int(Rnd()*num_bolas)+1
			Next
			% si al acabar, la fila recien rotada a la derecha, tambien esta vacia, repetimos el paso....
			If bolas[x+1,alto-1+1]=0 Then x+=1 % fuerzo al bucle a repetir esta fila, por que esta vacia tambien
		EndIf
	Next x	
Return


% ----------------------------------------------------------------------------------------
% compruebo si hay mas posibilidades, o si se acaba el juego
fin_juego:
	pieza=0

		% borro la matriz anterior
		For x=1 To ancho+2
			For y=1 To alto+2
				bolas2[x,y]=0
			Next y
		Next x
		
		% copio la nueva, pero saltandome los cuadros ya vaciados
		For x=1 To ancho
			For y=1 To alto
				If bolas[x,y]>0 Then bolas2[x+1,y+1]=bolas[x,y]
			Next y
		Next x

		For x=2 To ancho+1
			For y=2 To alto+1
				pieza=bolas2[x,y]
				If pieza>0 
					If bolas2[x-1,y  ]=pieza Then pieza = 0 : return
					If bolas2[x  ,y-1]=pieza Then pieza = 0 : return
					If bolas2[x+1,y  ]=pieza Then pieza = 0 : return
					If bolas2[x  ,y+1]=pieza Then pieza = 0 : return
				EndIf
			Next y
		Next x
		
		% fin, no hay mas piezas
		pieza = 1
Return


% ----------------------------------------------------------------------------------------
% poseso, dibuja
dibuja:
	escala=1
	%ScreenLock
	gr.cls
	x=0
	y=0
	pieza=0
	For x=0 To ancho-1
		For y=0 To alto-1
			pieza=bolas[x+1,y+1]
			If pieza=0 Then gr.bitmap.draw nul, vacio, (x*anchobola)/escala, (y*anchobola)/escala
			If pieza=1 Then gr.bitmap.draw nul, roja , (x*anchobola)/escala, (y*anchobola)/escala 
			If pieza=2 Then gr.bitmap.draw nul, verde, (x*anchobola)/escala, (y*anchobola)/escala 
			If pieza=3 Then gr.bitmap.draw nul, azul , (x*anchobola)/escala, (y*anchobola)/escala 
			If pieza=4 Then gr.bitmap.draw nul, amari, (x*anchobola)/escala, (y*anchobola)/escala 
			If pieza=5 Then gr.bitmap.draw nul, cian , (x*anchobola)/escala, (y*anchobola)/escala 
			% esta ultima bola-6, la morada, podemos emplearla o no, segun gustos, para mas complicacion al jugar (elegimos 5 o 6)
			If pieza=6 Then gr.bitmap.draw nul, morad, (x*anchobola)/escala, (y*anchobola)/escala 
		Next y
	Next x
	
	gr.color 255, 255, 0, 0, 2 % ROJO
	gr.set.stroke 2 : gr.text.size 45 : gr.text.align 2
	gr.text.draw nul, scx/2, scy-80, "M I S   B O L A S ! !"
	
	% menu eleccion 5 o 6 bolas
	gr.text.size 80
	gr.color 255, 0, 0, 200, 2 % AZUL
	gr.text.draw nul, (3*anchobola)+55, scy-260, "5"
	gr.text.draw nul, (6*anchobola)+75, scy-260, "6"
	gr.text.size 45
	
	% puntuacion
	%% puntos_total=9999
	gr.color 255, 250, 250, 0, 2 % AMARILLO
	gr.text.draw nul, (((ancho/2)*anchobola)/escala)+20 , ((alto*anchobola)/escala)+120 , int$(puntos_total)

	% maxima puntuacion
	gr.color 255, 0, 150, 0, 2 % VERDE
	if puntos_total>puntos_maximos5 & num_bolas=5  then puntos_maximos5=puntos_total % para 5 bolas
	if puntos_total>puntos_maximos6 & num_bolas=6  then puntos_maximos6=puntos_total % para 6 bolas
	if puntos_maximos5>9999 then puntos_maximos6=9999 % no podemos pasar de 9999, seria antinatural!!!
	if puntos_maximos6>9999 then puntos_maximos5=9999 % no podemos pasar de 9999, seria antinatural!!!
	%% puntos_maximos=9999
	gr.text.draw nul, (((ancho/2)*anchobola)/escala)-145 , ((alto*anchobola)/escala)+180 , int$(puntos_maximos5)	% maximo de 6 bolas
	gr.text.draw nul, (((ancho/2)*anchobola)/escala)+182 , ((alto*anchobola)/escala)+180 , int$(puntos_maximos6)	% maximo de 5 bolas
	
	gr.color 255, 0, 0, 0, 1 % negro
	
	%
	% linea triple arriba
	gr.line l1,0,((alto*anchobola)/escala)+20,scx,((alto*anchobola)/escala)+20
	gr.line l1,0,((alto*anchobola)/escala)+21,scx,((alto*anchobola)/escala)+21
	gr.line l1,0,((alto*anchobola)/escala)+22,scx,((alto*anchobola)/escala)+22
	% linea triple abajo
	gr.line l1,0,((alto*anchobola)/escala)+210,scx,((alto*anchobola)/escala)+210
	gr.line l1,0,((alto*anchobola)/escala)+211,scx,((alto*anchobola)/escala)+211
	gr.line l1,0,((alto*anchobola)/escala)+212,scx,((alto*anchobola)/escala)+212	
	
	%
	% dos triples verticales en el centro
	gr.line l1,300,((alto*anchobola)/escala)+20,300,((alto*anchobola)/escala)+210
	gr.line l1,301,((alto*anchobola)/escala)+21,301,((alto*anchobola)/escala)+210
	gr.line l1,302,((alto*anchobola)/escala)+22,302,((alto*anchobola)/escala)+210	
	%
	gr.line l1,800,((alto*anchobola)/escala)+20,800,((alto*anchobola)/escala)+210
	gr.line l1,801,((alto*anchobola)/escala)+21,801,((alto*anchobola)/escala)+210
	gr.line l1,802,((alto*anchobola)/escala)+22,802,((alto*anchobola)/escala)+210
	
	%
	% dos triples verticales que separan las puntuacines maximas
	gr.line l1,475,((alto*anchobola)/escala)+20,475,((alto*anchobola)/escala)+210
	gr.line l1,476,((alto*anchobola)/escala)+21,476,((alto*anchobola)/escala)+210
	gr.line l1,477,((alto*anchobola)/escala)+22,477,((alto*anchobola)/escala)+210	
	%
	gr.line l1,640,((alto*anchobola)/escala)+20,640,((alto*anchobola)/escala)+210
	gr.line l1,641,((alto*anchobola)/escala)+21,641,((alto*anchobola)/escala)+210
	gr.line l1,642,((alto*anchobola)/escala)+22,642,((alto*anchobola)/escala)+210
	
	%
	% iconos "nuevo" y "deshacer"
	gr.bitmap.draw nul, nuevo, 70, ((alto*anchobola)/escala)+40
	gr.bitmap.draw nul, atras, scx-50-150, ((alto*anchobola)/escala)+40

    gr.render	
Return
% ----------------------------------------------------------------------------------------
