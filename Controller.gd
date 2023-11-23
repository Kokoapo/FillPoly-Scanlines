class_name Controller
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

func _on_vertice_2_color_changed(color):
	canvas.lista_triangulos[triangulo_selecionado].pontos[1].cor = color;

func _on_vertice_3_color_changed(color):
	canvas.lista_triangulos[triangulo_selecionado].pontos[2].cor = color;

func _on_arestas_color_changed(color):
	canvas.lista_triangulos[triangulo_selecionado].cor_arestas = color;
	canvas.queue_redraw(); # Atualizar Canvas

# FillPoly apenas no triangulo_selecionado
func _on_pintar_pressed():
	canvas.fill_poly(triangulo_selecionado);

# Remover triangulo_selecionado da lista do canvas
func _on_remover_pressed():
	canvas.lista_triangulos.remove_at(triangulo_selecionado);
	canvas.scanlines.clear();
	canvas.queue_redraw(); # Atualizar Canvas

# Switch para troca de estados
func _on_switch_estado_toggled(button_pressed):
	estado = button_pressed;
