GDPC                 P                                                                      
   P   res://.godot/exported/133200997/export-5c1b5421b3a3843354800198f9326b19-node.scn�-      \      �!�'�A�G�� �W    ,   res://.godot/global_script_class_cache.cfg  �<      �       �3�Oq�����ۺU�    D   res://.godot/imported/icon.svg-218a8f2b3041327d8a5756f3a245f83b.ctex       �      �̛�*$q�*�́        res://.godot/uid_cache.bin  PA      9       J��Z<���i*�WF�       res://Canvas.gd               �u��J��}y�ˉ       res://Controller.gd       �      F����71��!M       res://icon.svg  �=      �      C��=U���^Qu��U3       res://icon.svg.import   �,      �       A-�aؓ��Kf0L*�       res://node.tscn.remap    <      a       �!>��!#28�橸       res://project.binary�A      �      ����b&���*qѢ�            class_name Canvas
extends Control

# Cada ponto possui sua posição e uma cor para seu vértice
class Ponto:
	var coordenadas: Vector2;
	var cor: Color;
	
	func _init(coords: Vector2, nova_cor: Color = Color.BLACK):
		coordenadas.x = coords.x;
		coordenadas.y = coords.y;
		cor = nova_cor;

# Cada triângulo possui 3 pontos e uma cor para as arestas
class Triangulo:
	var pontos: Array;
	var cor_arestas: Color;
	var scanlines: Array;
	
	func _init(pts: Array):
		for pt in pts:
			pontos.append(pt);
		cor_arestas = Color.WHITE;

@export var limite: int; # limite inferior das coordenadas do canvas
var lista_triangulos: Array; # Guarda todos os triângulos
var pontos_novo_triangulo: Array; # Guarda pontos do triângulo sendo criado
var triangulo_selecionado: int = -1;

# Ações do canvas no estado desenhar: 
#	- Adicionar novo ponto à lista de pontos
#	- Caso a lista de pontos esteja cheia (3 vértices), criar novo triângulo e limpar lista
func action_desenhar(pos: Vector2):
	pontos_novo_triangulo.append(Ponto.new(pos));
	if pontos_novo_triangulo.size() == 3:
		var novo_triangulo: Triangulo = Triangulo.new(pontos_novo_triangulo);
		lista_triangulos.append(novo_triangulo);
		fill_poly(lista_triangulos.size()-1);
		pontos_novo_triangulo.clear();
	queue_redraw(); # Atualizar Canvas

# Ações do canvas no estado selecionar: 
#	- Checar se o ponto seleciona algum triângulo
#	- Retornar posição do triângulo selecionado na lista de triângulos
#	- Retornar -1 caso não tenha selecionado nenhum triângulo
func action_selecionar(pos: Vector2) -> int:
	for i in range(lista_triangulos.size()):
		if is_dentro_triangulo(pos, lista_triangulos[i]):
			triangulo_selecionado = i;
			queue_redraw();
			return i;
	return -1;

# Desenha todos os elementos do canvas na tela, precisa redesenhar tudo sempre que for chamado
func _draw():
	# Desenha pontos do novo triângulo
	for novo_ponto in pontos_novo_triangulo:
		draw_line(novo_ponto.coordenadas, novo_ponto.coordenadas+Vector2(5,0), Color.WHITE, 5);

	# Desenha todos os triângulos e suas scanlines
	for triangulo in lista_triangulos:
		for ponto_scanline in triangulo.scanlines:
			draw_line(ponto_scanline.coordenadas, ponto_scanline.coordenadas+Vector2(1,0), ponto_scanline.cor, 1);
		var pontos: Array = triangulo.pontos;
		for i in range(pontos.size()):
			var f: int = (i+1) % pontos.size();
			draw_line(pontos[i].coordenadas, pontos[f].coordenadas, triangulo.cor_arestas, 1);
	
	# Desenha bouding box do triangulo selecionado
	if triangulo_selecionado != -1:
		var triangulo: Triangulo = lista_triangulos[triangulo_selecionado];
		for ponto in triangulo.pontos:
			draw_line(ponto.coordenadas, ponto.coordenadas+Vector2(10,0), ponto.cor, 10);

# Checa se dado ponto está contido na área de um dado triângulo
func is_dentro_triangulo(P: Vector2, triangulo: Triangulo) -> bool:
	var A: Vector2 = triangulo.pontos[0].coordenadas;
	var B: Vector2 = triangulo.pontos[1].coordenadas;
	var C: Vector2 = triangulo.pontos[2].coordenadas;
	var area = area_triangulo(A,B,P) + area_triangulo(P,B,C) + area_triangulo(A,P,C);
	return area == area_triangulo(A,B,C);

# Calcula a área de um triângulo a partir de 3 dados pontos 
func area_triangulo(p1: Vector2, p2: Vector2, p3: Vector2) -> float:
	return abs((p1.x*(p2.y-p3.y)+p2.x*(p3.y-p1.y)+p3.x*(p1.y-p2.y))/2);

func fill_poly(t: int):
	var triangulo: Triangulo = lista_triangulos[t];
	triangulo.scanlines.clear();
	var intersecs: Dictionary = {};
	
	for i in range(triangulo.pontos.size()):
		var f: int = (i+1) % triangulo.pontos.size();
		var Vi: Ponto = triangulo.pontos[i];
		var Vf: Ponto = triangulo.pontos[f];
		
		if Vi.coordenadas.y == Vf.coordenadas.y:
			continue;
		if Vi.coordenadas.y > Vf.coordenadas.y:
			var aux: Ponto = Vi;
			Vi = Vf;
			Vf = aux;
		
		var x = Vi.coordenadas.x;
		var r = Vi.cor.r;
		var g = Vi.cor.g;
		var b = Vi.cor.b;
		var dx = (Vf.coordenadas.x-Vi.coordenadas.x)/(Vf.coordenadas.y-Vi.coordenadas.y);
		var dr = (Vf.cor.r-Vi.cor.r)/(Vf.coordenadas.y-Vi.coordenadas.y);
		var dg = (Vf.cor.g-Vi.cor.g)/(Vf.coordenadas.y-Vi.coordenadas.y);
		var db = (Vf.cor.b-Vi.cor.b)/(Vf.coordenadas.y-Vi.coordenadas.y);
		for y in range(Vi.coordenadas.y, Vf.coordenadas.y, 1):
			if !intersecs.has(y):
				intersecs[y] = [];
			intersecs[y].append(Ponto.new(Vector2(x,y), Color(r,g,b)));
			x += dx;
			r += dr;
			g += dg;
			b += db;
	for y in intersecs:
		intersecs[y].sort_custom(sort_por_x);
		for i in range(0, intersecs[y].size(), 2):
			var Xi = intersecs[y][i].coordenadas.x;
			var Xf = intersecs[y][i+1].coordenadas.x;
			var dx = Xf - Xi;
			if dx == 0:
				continue;
			
			var r = intersecs[y][i].cor.r;
			var g = intersecs[y][i].cor.g;
			var b = intersecs[y][i].cor.b;
			var dr = (intersecs[y][i+1].cor.r-r)/dx;
			var dg = (intersecs[y][i+1].cor.g-g)/dx;
			var db = (intersecs[y][i+1].cor.b-b)/dx;
			
			for x in range(Xi, Xf+1, 1):
				triangulo.scanlines.append(Ponto.new(Vector2(x,y), Color(r,g,b)));
				r += dr;
				g += dg;
				b += db;
	queue_redraw();

func sort_por_x(a, b) -> bool:
	if a.coordenadas.x < b.coordenadas.x:
		return true;
	return false;
    class_name Controller
extends Node

# Canvas usado para desenhar na tela
@export var canvas: Canvas;

# Elementos UI relacionados à seleção de triângulos
@export var color_picker_v1: ColorPickerButton;
@export var color_picker_v2: ColorPickerButton;
@export var color_picker_v3: ColorPickerButton;
@export var color_picker_aresta: ColorPickerButton;
@export var btn_pintar: Button;
@export var btn_remover: Button;

# Controle do triângulo selecionado e dos elementos UI que precisam deste
var triangulo_selecionado: int = -1:
	set(novo_valor):
		triangulo_selecionado = novo_valor;
		var desabilitar: bool = false;
		if triangulo_selecionado == -1:
			desabilitar = true;
		else:
			color_picker_v1.color = canvas.lista_triangulos[triangulo_selecionado].pontos[0].cor;
			color_picker_v2.color = canvas.lista_triangulos[triangulo_selecionado].pontos[1].cor;
			color_picker_v3.color = canvas.lista_triangulos[triangulo_selecionado].pontos[2].cor;
			color_picker_aresta.color = canvas.lista_triangulos[triangulo_selecionado].cor_arestas;
		color_picker_v1.disabled = desabilitar;
		color_picker_v2.disabled = desabilitar;
		color_picker_v3.disabled = desabilitar;
		color_picker_aresta.disabled = desabilitar;
		btn_pintar.disabled = desabilitar;
		btn_remover.disabled = desabilitar;
# Estado do programa: 0 - Desenhar, 1 - Pintar
var estado: bool = false:
	set(novo_valor):
		estado = novo_valor;
		if estado:
			canvas.pontos_novo_triangulo.clear();
			canvas.queue_redraw();
		else:
			triangulo_selecionado = -1;
			canvas.triangulo_selecionado = -1;

# Controle dos inputs do mouse e das ações do canvas
func _input(event):
	if event is InputEventMouseButton and event.pressed and event.position.y > canvas.limite:
		var canvas_pos: Vector2 = event.position-Vector2(0,canvas.limite);
		if !estado:
			canvas.action_desenhar(canvas_pos);
		else:
			triangulo_selecionado = canvas.action_selecionar(canvas_pos);

# Sair do programa
func _on_sair_pressed():
	get_tree().quit();

# Atualizar cores do triângulo selecionado
func _on_vertice_1_color_changed(color):
	canvas.lista_triangulos[triangulo_selecionado].pontos[0].cor = color;
	canvas.queue_redraw();

func _on_vertice_2_color_changed(color):
	canvas.lista_triangulos[triangulo_selecionado].pontos[1].cor = color;
	canvas.queue_redraw();

func _on_vertice_3_color_changed(color):
	canvas.lista_triangulos[triangulo_selecionado].pontos[2].cor = color;
	canvas.queue_redraw();

func _on_arestas_color_changed(color):
	canvas.lista_triangulos[triangulo_selecionado].cor_arestas = color;
	canvas.queue_redraw(); # Atualizar Canvas

# FillPoly apenas no triangulo_selecionado
func _on_pintar_pressed():
	canvas.fill_poly(triangulo_selecionado);

# Remover triangulo_selecionado da lista do canvas
func _on_remover_pressed():
	canvas.lista_triangulos.remove_at(triangulo_selecionado);
	triangulo_selecionado = -1;
	canvas.triangulo_selecionado = -1;
	canvas.queue_redraw(); # Atualizar Canvas

# Switch para troca de estados
func _on_switch_estado_toggled(button_pressed):
	estado = button_pressed;
          GST2   �   �      ����               � �        �  RIFF�  WEBPVP8L�  /������!"2�H�$�n윦���z�x����դ�<����q����F��Z��?&,
ScI_L �;����In#Y��0�p~��Z��m[��N����R,��#"� )���d��mG�������ڶ�$�ʹ���۶�=���mϬm۶mc�9��z��T��7�m+�}�����v��ح�m�m������$$P�����එ#���=�]��SnA�VhE��*JG�
&����^x��&�+���2ε�L2�@��		��S�2A�/E���d"?���Dh�+Z�@:�Gk�FbWd�\�C�Ӷg�g�k��Vo��<c{��4�;M�,5��ٜ2�Ζ�yO�S����qZ0��s���r?I��ѷE{�4�Ζ�i� xK�U��F�Z�y�SL�)���旵�V[�-�1Z�-�1���z�Q�>�tH�0��:[RGň6�=KVv�X�6�L;�N\���J���/0u���_��U��]���ǫ)�9��������!�&�?W�VfY�2���༏��2kSi����1!��z+�F�j=�R�O�{�
ۇ�P-�������\����y;�[ ���lm�F2K�ޱ|��S��d)é�r�BTZ)e�� ��֩A�2�����X�X'�e1߬���p��-�-f�E�ˊU	^�����T�ZT�m�*a|	׫�:V���G�r+�/�T��@U�N׼�h�+	*�*sN1e�,e���nbJL<����"g=O��AL�WO!��߈Q���,ɉ'���lzJ���Q����t��9�F���A��g�B-����G�f|��x��5�'+��O��y��������F��2�����R�q�):VtI���/ʎ�UfěĲr'�g�g����5�t�ۛ�F���S�j1p�)�JD̻�ZR���Pq�r/jt�/sO�C�u����i�y�K�(Q��7őA�2���R�ͥ+lgzJ~��,eA��.���k�eQ�,l'Ɨ�2�,eaS��S�ԟe)��x��ood�d)����h��ZZ��`z�պ��;�Cr�rpi&��՜�Pf��+���:w��b�DUeZ��ڡ��iA>IN>���܋�b�O<�A���)�R�4��8+��k�Jpey��.���7ryc�!��M�a���v_��/�����'��t5`=��~	`�����p\�u����*>:|ٻ@�G�����wƝ�����K5�NZal������LH�]I'�^���+@q(�q2q+�g�}�o�����S߈:�R�݉C������?�1�.��
�ڈL�Fb%ħA ����Q���2�͍J]_�� A��Fb�����ݏ�4o��'2��F�  ڹ���W�L |����YK5�-�E�n�K�|�ɭvD=��p!V3gS��`�p|r�l	F�4�1{�V'&����|pj� ߫'ş�pdT�7`&�
�1g�����@D�˅ �x?)~83+	p �3W�w��j"�� '�J��CM�+ �Ĝ��"���4� ����nΟ	�0C���q'�&5.��z@�S1l5Z��]�~L�L"�"�VS��8w.����H�B|���K(�}
r%Vk$f�����8�ڹ���R�dϝx/@�_�k'�8���E���r��D���K�z3�^���Vw��ZEl%~�Vc���R� �Xk[�3��B��Ğ�Y��A`_��fa��D{������ @ ��dg�������Mƚ�R�`���s����>x=�����	`��s���H���/ū�R�U�g�r���/����n�;�SSup`�S��6��u���⟦;Z�AN3�|�oh�9f�Pg�����^��g�t����x��)Oq�Q�My55jF����t9����,�z�Z�����2��#�)���"�u���}'�*�>�����ǯ[����82һ�n���0�<v�ݑa}.+n��'����W:4TY�����P�ר���Cȫۿ�Ϗ��?����Ӣ�K�|y�@suyo�<�����{��x}~�����~�AN]�q�9ޝ�GG�����[�L}~�`�f%4�R!1�no���������v!�G����Qw��m���"F!9�vٿü�|j�����*��{Ew[Á��������u.+�<���awͮ�ӓ�Q �:�Vd�5*��p�ioaE��,�LjP��	a�/�˰!{g:���3`=`]�2��y`�"��N�N�p���� ��3�Z��䏔��9"�ʞ l�zP�G�ߙj��V�>���n�/��׷�G��[���\��T��Ͷh���ag?1��O��6{s{����!�1�Y�����91Qry��=����y=�ٮh;�����[�tDV5�chȃ��v�G ��T/'XX���~Q�7��+[�e��Ti@j��)��9��J�hJV�#�jk�A�1�^6���=<ԧg�B�*o�߯.��/�>W[M���I�o?V���s��|yu�xt��]�].��Yyx�w���`��C���pH��tu�w�J��#Ef�Y݆v�f5�e��8��=�٢�e��W��M9J�u�}]釧7k���:�o�����Ç����ս�r3W���7k���e�������ϛk��Ϳ�_��lu�۹�g�w��~�ߗ�/��ݩ�-�->�I�͒���A�	���ߥζ,�}�3�UbY?�Ӓ�7q�Db����>~8�]
� ^n׹�[�o���Z-�ǫ�N;U���E4=eȢ�vk��Z�Y�j���k�j1�/eȢK��J�9|�,UX65]W����lQ-�"`�C�.~8ek�{Xy���d��<��Gf�ō�E�Ӗ�T� �g��Y�*��.͊e��"�]�d������h��ڠ����c�qV�ǷN��6�z���kD�6�L;�N\���Y�����
�O�ʨ1*]a�SN�=	fH�JN�9%'�S<C:��:`�s��~��jKEU�#i����$�K�TQD���G0H�=�� �d�-Q�H�4�5��L�r?����}��B+��,Q�yO�H�jD�4d�����0*�]�	~�ӎ�.�"����%
��d$"5zxA:�U��H���H%jس{���kW��)�	8J��v�}�rK�F�@�t)FXu����G'.X�8�KH;���[             [remap]

importer="texture"
type="CompressedTexture2D"
uid="uid://ch8naiwpciywl"
path="res://.godot/imported/icon.svg-218a8f2b3041327d8a5756f3a245f83b.ctex"
metadata={
"vram_texture": false
}
                RSRC                    PackedScene            ��������                                                  CanvasLayer    VBoxContainer    Control    PanelContainer    HBoxContainer    TrianguloSelecionado 	   Vertice1 	   Vertice2 	   Vertice3    Arestas    Pintar    Remover    resource_local_to_scene    resource_name 	   _bundled    script       Script    res://Controller.gd ��������   Script    res://Canvas.gd ��������      local://PackedScene_5cj7h �         PackedScene          	         names "   5      Node    script    canvas    color_picker_v1    color_picker_v2    color_picker_v3    color_picker_aresta    btn_pintar    btn_remover    CanvasLayer    VBoxContainer    offset_right    offset_bottom    size_flags_horizontal    size_flags_vertical    PanelContainer    layout_mode    HBoxContainer    SwitchEstado    size_flags_stretch_ratio %   theme_override_constants/margin_left &   theme_override_constants/margin_right '   theme_override_constants/margin_bottom    MarginContainer    Label    text    horizontal_alignment    CheckButton    TrianguloSelecionado 	   Vertice1 	   disabled    ColorPickerButton 	   Vertice2 	   Vertice3    Arestas    Pintar    Button    Remover    SairPrograma    Sair    Control    limite    _on_switch_estado_toggled    toggled    _on_vertice_1_color_changed    color_changed    _on_vertice_2_color_changed    _on_vertice_3_color_changed    _on_arestas_color_changed    _on_pintar_pressed    pressed    _on_remover_pressed    _on_sair_pressed    	   variants                                                                                                                                              	                            
                                    �D     �D                  @                         Alternar Desenhar/Selecionar                   
       Pintar       Remover       Sair do Programa      �@            �         node_count             nodes     ,  ��������        ����            @     @     @     @     @     @     @               	   	   ����               
   
   ����            	      
      
                    ����            
                    ����                          ����            
                                            ����                                ����                                            ����                                      ����            
                         	             ����             
             ����            
                         
              ����            
                         
          !   ����            
                         
          "   ����            
                         
       $   #   ����                                     
       $   %   ����                                               &   ����            
                                $   '   ����                                      (   (   ����            
               )                conn_count             conns     8          +   *                     -   ,                     -   .                     -   /                     -   0                     2   1                     2   3                     2   4                    node_paths              editable_instances              version             RSRC    [remap]

path="res://.godot/exported/133200997/export-5c1b5421b3a3843354800198f9326b19-node.scn"
               list=Array[Dictionary]([{
"base": &"Control",
"class": &"Canvas",
"icon": "",
"language": &"GDScript",
"path": "res://Canvas.gd"
}, {
"base": &"Node",
"class": &"Controller",
"icon": "",
"language": &"GDScript",
"path": "res://Controller.gd"
}])
          <svg height="128" width="128" xmlns="http://www.w3.org/2000/svg"><rect x="2" y="2" width="124" height="124" rx="14" fill="#363d52" stroke="#212532" stroke-width="4"/><g transform="scale(.101) translate(122 122)"><g fill="#fff"><path d="M105 673v33q407 354 814 0v-33z"/><path fill="#478cbf" d="m105 673 152 14q12 1 15 14l4 67 132 10 8-61q2-11 15-15h162q13 4 15 15l8 61 132-10 4-67q3-13 15-14l152-14V427q30-39 56-81-35-59-83-108-43 20-82 47-40-37-88-64 7-51 8-102-59-28-123-42-26 43-46 89-49-7-98 0-20-46-46-89-64 14-123 42 1 51 8 102-48 27-88 64-39-27-82-47-48 49-83 108 26 42 56 81zm0 33v39c0 276 813 276 813 0v-39l-134 12-5 69q-2 10-14 13l-162 11q-12 0-16-11l-10-65H447l-10 65q-4 11-16 11l-162-11q-12-3-14-13l-5-69z"/><path d="M483 600c3 34 55 34 58 0v-86c-3-34-55-34-58 0z"/><circle cx="725" cy="526" r="90"/><circle cx="299" cy="526" r="90"/></g><g fill="#414042"><circle cx="307" cy="532" r="60"/><circle cx="717" cy="532" r="60"/></g></g></svg>
             K\[��J   res://icon.svg�3C3:�h   res://node.tscn       ECFG      application/config/name      
   FillPolyCG     application/run/main_scene         res://node.tscn    application/config/features$   "         4.2    Forward Plus       application/config/icon         res://icon.svg  "   display/window/size/viewport_width      �  #   display/window/size/viewport_height      8     display/window/size/mode            dotnet/project/assembly_name      
   FillPolyCG          