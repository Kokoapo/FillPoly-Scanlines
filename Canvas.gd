class_name Canvas
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
